(

///////////////////////////////////////  Function

// call on server boot
~initAllocators = { arg server;
	server.newBusAllocators;
	server.newBufferAllocators;
};

~makeBuffers = { // create a dictionary with folders names under the Audio folder in the first key and sample number in the next
	b = Dictionary.new;
	PathName(~path ++ "Audio").entries.do{ arg subfolder;
		b.add(
			subfolder.folderName.asSymbol ->
			Array.fill(
				subfolder.entries.size,
				{
					arg i;
					Buffer.read(s, subfolder.entries[i].fullPath);
				}
			)
		);
	};
};
// b[\sampler_stereo][0].play;
// use it in a SynthDef like this: s.bind { Synth(\samplerStereo, [\out, 0, \buffer, b[\sampler_stereo][0].bufnum]) };

// call on server quit
~cleanup = { arg server;
	Window.closeAll;
	Buffer.freeAll;
	MIDIdef.freeAll;
	currentEnvironment.removeAll;
	Pdef.removeAll;
	Tdef.removeAll;
	server.freeAll;
};

// return an Array of Penvir use it in Ppar to play all the units
~listUnits = { arg sequencer;
	var listUnits;
	listUnits = sequencer.size.collect({ arg i;
		sequencer.at(("unit" ++ (i + 1)).asSymbol);
	});
	listUnits;
};

// remove previous Pdef, use it when you reset sequencer
~resetPdefView = {
	~synthWindow.keysValuesDo({ arg key, value;
		if(key.contains("unit"), {
			value.removeAll;
			value.remove;
			{ ~synthWindow.removeAt(key); }.fork(t, 0.2); // need to be delayed
		});
	});
};

~cleanDict = { arg dict, synthWindowKey;
	dict.keysDo({ arg key; // remove control no longer in use
		if(key.contains(synthWindowKey), {
			dict.removeAt(key);
		});
	});
};

~removePrev = { arg synthWindowKey; // use it inside a defer function
	var synthView;
	if (~synthWindow.includesKey(synthWindowKey), {
		synthView = ~synthWindow.at(synthWindowKey);
		synthView.removeAll; // removes all children
		synthView.remove; // remove the composite view
		{ ~synthWindow.removeAt(synthWindowKey); }.fork(t, 0.2);

		~cleanDict.value(~autoGuiControl, synthWindowKey);
		~cleanDict.value(~active, synthWindowKey);
		~cleanDict.value(~firstTime, synthWindowKey);

		~controlBus.keysDo({ arg key; // remove control bus no longer in use
			if(key.contains(synthWindowKey), {
				~controlBus.at(key).free;
				~controlBus.removeAt(key);
			});
		});

		MIDIdef.all.keysDo({ arg key; // remove mididef no longer in use
			if(key.contains(synthWindowKey), {
				MIDIdef(key).free;
			});
		});
	});
};

~changePattern = { arg pdef, pattern;
	var pdefNameSymbol, pdefNameString;

	pdefNameSymbol = pdef.key.asSymbol;
	pdefNameString = pdefNameSymbol.asString;

	~firstTime.keysValuesDo({ arg key, value; // reset control bus creation
		if((key.contains(pdefNameString) and: value.not), {
			~firstTime.put(key, true);
		});
	});

	Pdef(pdefNameSymbol, pattern).quant_(~globalQuant);
};

~songInit = {
	var unit;
	~pdefNumber.do({ arg i;
		unit = (\unit ++ (1 + i)).asSymbol;
		~changePattern.value(Pdef(unit), ~initPattern);
	});
};

// use it with SynthDef sync on a clock like sync delay
~updateTempo = { arg synth, tempoClock;
	var updater;
	updater = SimpleController(tempoClock).put(\tempo, {
		synth.set(\tempoClock, tempoClock.tempo);
	})
	// clean up garbage when the clock is stopped
	.put(\stop, { updater.remove; });
};

~resetControlBus = { arg controlId;
	if (controlId.isArray, {
		~controlBus.keysDo({ arg key;
			if(controlId.includesEqual(key), {
				~controlBus.at(key).free;
				~controlBus.removeAt(key);
			});
		});

		~firstTime.keysValuesDo({ arg key, value;
			if((controlId.includesEqual(key) and: value.not), {
				~firstTime.put(key, true);
			});
		});
	});

	if (controlId.isString, {
		~controlBus.keysDo({ arg key;
			if(key.contains(controlId), {
				~controlBus.at(key).free;
				~controlBus.removeAt(key);
			});
		});

		~firstTime.keysValuesDo({ arg key, value;
			if((key.contains(controlId) and: value.not), {
				~firstTime.put(key, true);
			});
		});
	});
};

~resetAllControlBus = {
	var unit;
	~pdefNumber.do({ arg i;
		unit = ("unit" ++ (1 + i)).asString;
		~resetControlBus.value(unit);
	});
};

~pdefUpdate = { arg controlId, instance, controlNameSymb, value;
	if (~firstTime.at(controlId), {
		~controlBus.put(controlId, Bus.control(s, 1).set(value));
		Pbindef(instance, controlNameSymb, ~controlBus.at(controlId).asMap).quant_(~globalQuant);
		~firstTime.put(controlId, false);
	}, {
		~controlBus.at(controlId).set(value);
	});
};

// automatic GUI creation and midi mapping
~autoGui = { arg parentWindow = nil, synthDef = nil, instance = nil, ccStart = 10, midiChan = 0, backGroundColor = Color.white, specDict = Dictionary.new;
	var arguments, synthWindow, list, slider, button, knob, active, synthDefName, pdefName, id;

	if ((parentWindow.notNil and: synthDef.notNil and: instance.notNil), {
		synthDefName = synthDef.name.asString;
		arguments = synthDef.allControlNames;
		midiChan = midiChan.max(0).min(15);

		specDict.put("default", ["knob", ControlSpec(0, 1, step: 0.01, default: 0), true]);

		if (instance.isSymbol, {
			pdefName = instance.asString;
		}, {
			pdefName = UniqueID.next;
			if (instance.isString, {
				pdefName = instance;
				instance = instance.asSymbol;
			});
		});

		id = (synthDefName ++ pdefName).asString;
		(midiChan).debug(synthDefName ++ " " ++ pdefName ++ " midi channel");

		~synthWindow.put(id,
			CompositeView(bounds: (arguments.size * 64)@110)
			.scroll(autoScrolls: true)
			.minHeight_(115)
			.minWidth_(230)
			.background_(backGroundColor);
		);
		synthWindow = ~synthWindow.at(id);

		synthWindow.decorator_(FlowLayout(synthWindow.bounds, 3@3, 6@3));

		// SynthDef name
		StaticText(synthWindow, 100@26)
		.string_(synthDefName ++ " " ++ pdefName)
		.stringColor_(Color.black)
		.align_(\center);
		synthWindow.decorator.nextLine;

		arguments.do({ arg control, i;
			var caseFind, controlName, controlNameSymb, controlType, controlSpec, midiMap, controlId;

			caseFind = false;
			controlName = control.name.asString;
			controlId = (id ++ controlName).asString;
			controlNameSymb = control.name.asSymbol;

			if (control.defaultValue.notNil, {
				specDict.add("default" -> ["knob", ControlSpec(0, 1, step: 0.01, default: control.defaultValue), true]);
			});

			if (specDict.includesKey(controlName),
				{
					controlType = specDict.at(controlName)[0].value.asString.toLower;
					if (specDict.at(controlName)[1].notNil, { controlSpec = specDict.at(controlName)[1].value; });
					if (specDict.at(controlName)[2].notNil, { midiMap = specDict.at(controlName)[2].value; });
				},
				{
					controlType = specDict.at("default")[0].value.asString.toLower;
					controlSpec = specDict.at("default")[1].value;
					midiMap = specDict.at("default")[2].value;
				}
			);

			case
			{ controlType == "none" or: "out in input output inbus outbus doneaction".contains(controlName.toLower) }
			{
				caseFind = true;
			}
			{ controlType == "list" and: caseFind.not }
			{
				// list creation
				~active.put(controlId, false);
				~firstTime.put(controlId, true);
				~autoGuiControl.put(controlId, EZListView(synthWindow, 60@70, controlName, controlSpec, {
					arg guiControl;
					if (instance.isSymbol,
						{ ~pdefUpdate.value(controlId, instance, controlNameSymb, guiControl.value); },
						{ instance.set(controlNameSymb, guiControl.value); }
					);
					~active.put(controlId, false);
				}));

				if (midiMap, { // list midi map
					MIDIdef.cc(controlId, { arg val, num, chan, src;
						var guiControl, midiControl, threshold;
						threshold = 0.5;
						midiControl = val.linlin(0, 127, 0, ~autoGuiControl.at(controlId).items.size - 1);
						{
							guiControl = ~autoGuiControl.at(controlId).value;
							if ( // soft takeover
								(~active.at(controlId) or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
								{
									~active.put(controlId, true);
									if (instance.isSymbol,
										{ ~pdefUpdate.value(controlId, instance, controlNameSymb, midiControl); },
										{ instance.set(controlNameSymb, midiControl); }
									);
									~autoGuiControl.at(controlId).value_(midiControl);
								}
							);
						}.defer;
					}, ccStart, midiChan);
					(ccStart).debug(synthDefName ++ " " ++ pdefName ++ " " ++ controlName ++ " cc number");
					ccStart = ccStart + 1;
				});

				caseFind = true;
			}
			{ controlType == "slider" and: caseFind.not }
			{
				// slider creation
				~active.put(controlId, false);
				~firstTime.put(controlId, true);
				~autoGuiControl.put(controlId, EZSlider(synthWindow, 60@70, controlName, controlSpec, {
					arg guiControl;
					if (instance.isSymbol,
						{ ~pdefUpdate.value(controlId, instance, controlNameSymb, guiControl.value); },
						{ instance.set(controlNameSymb, guiControl.value); }
					);
					~active.put(controlId, false);
				}, layout: \vert, gap: 6@6));

				if (midiMap, { // slider midi map
					MIDIdef.cc(controlId, { arg val, num, chan, src;
						var guiControl, midiControl, threshold, minValue, maxValue;
						minValue = ~autoGuiControl.at(controlId).controlSpec.minval;
						maxValue = ~autoGuiControl.at(controlId).controlSpec.maxval;
						threshold = ((maxValue - minValue) * 5) / 100; // 5% of the range
						midiControl = val.linlin(0, 127, minValue, maxValue);
						guiControl = ~autoGuiControl.at(controlId).value;
						if ( // soft takeover
							(~active.at(controlId) or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
							{
								~active.put(controlId, true);
								{
									if (instance.isSymbol,
										{ ~pdefUpdate.value(controlId, instance, controlNameSymb, midiControl); },
										{ instance.set(controlNameSymb, midiControl); }
									);
									~autoGuiControl.at(controlId).value_(midiControl);
								}.defer;
							}
						);
					}, ccStart, midiChan);
					(ccStart).debug(synthDefName ++ " " ++ pdefName ++ " " ++ controlName ++ " cc number");
					ccStart = ccStart + 1;
				});

				caseFind = true;
			}
			{ /*"trigger trig gate t_trig t_gate loop mute start stop on off".contains(controlName) or: */controlType == "button" and: caseFind.not } // in this case create button
			{
				// button creation
				~firstTime.put(controlId, true);
				~autoGuiControl.put(controlId,
					Button(synthWindow, Rect(10,110,60,25))
					.states_([
						[controlName ++ " on", Color.black, Color.white],
						[controlName ++ " off", Color.white, Color.grey]
					])
					.action = {
						arg guiControl;
						if (instance.isSymbol,
							{ ~pdefUpdate.value(controlId, instance, controlNameSymb, guiControl.value); },
							{ instance.set(controlNameSymb, guiControl.value); }
						);
					}
				);

				if (midiMap, { // button midi map
					MIDIdef.cc(controlId, { arg val, num, chan, src;
						var midiControl;
						midiControl = val.linlin(0, 127, 0, 1);
						{
							~autoGuiControl.at(controlId).valueAction_(midiControl);
						}.defer;
					}, ccStart, midiChan);
					(ccStart).debug(synthDefName ++ " " ++ pdefName ++ " " ++ controlName ++ " cc number");
					ccStart = ccStart + 1;
				});

				caseFind = true;
			}
			{  controlType == "knob" or: caseFind.not } // default case create knob
			{
				// knob creation
				~active.put(controlId, false);
				~firstTime.put(controlId, true);
				~autoGuiControl.put(controlId, EZKnob(synthWindow, 60@70, controlName, controlSpec, {
					arg guiControl;
					if (instance.isSymbol,
						{ ~pdefUpdate.value(controlId, instance, controlNameSymb, guiControl.value); },
						{ instance.set(controlNameSymb, guiControl.value); }
					);
					~active.put(controlId, false);
				}));

				if (midiMap, { // knob midi map
					MIDIdef.cc(controlId, { arg val, num, chan, src;
						var guiControl, midiControl, threshold, minValue, maxValue;
						minValue = ~autoGuiControl.at(controlId).controlSpec.minval;
						maxValue = ~autoGuiControl.at(controlId).controlSpec.maxval;
						threshold = ((maxValue - minValue) * 5) / 100; // 5% of the range
						midiControl = val.linlin(0, 127, minValue, maxValue);
						guiControl = ~autoGuiControl.at(controlId).value;
						if ( // soft takeover
							(~active.at(controlId) or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
							{
								~active.put(controlId, true);
								{
									if (instance.isSymbol,
										{ ~pdefUpdate.value(controlId, instance, controlNameSymb, midiControl); },
										{ instance.set(controlNameSymb, midiControl); }
									);
									~autoGuiControl.at(controlId).value_(midiControl);
								}.defer;
							}
						);
					}, ccStart, midiChan);
					(ccStart).debug(synthDefName ++ " " ++ pdefName ++ " " ++ controlName ++ " cc number");
					ccStart = ccStart + 1;
				});
			};
		});

		parentWindow.canvas.layout.insert(synthWindow);

		if (instance.isSymbol, {
			// removes all the children of the view and destroys them then remove the composite view
			Button(synthWindow, Rect(10,110,20,20)).states_([["X", Color.white, Color.new255(255, 48, 48)]]).action = {
				~removePrev.value(id);
			};
		});
	}, {
		"autoGui wrong arguments".postln;
	});
};

)