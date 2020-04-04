(

///////////////////////////////////////  Function

// call on server boot
~initAllocators = { arg server;
	server.newBusAllocators;
	server.newBufferAllocators;
};

// call on server quit
~cleanup = { arg server;
	Window.closeAll;
	MIDIdef.freeAll;
	currentEnvironment.removeAll;
	Pdef.removeAll;
	Tdef.removeAll;
	server.freeAll;
	{
		Buffer.freeAll;
		server.sync;
	}.fork;
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

~syncSCtoSD = { arg tempo = TempoClock.default, bool = true;
	if (bool, {
		~dirt.receiveAction = { |e|
			var cycle = e[\cycle];
			var cps = e[\cps];
			var latency = e[\latency];
			cycle !? {
				if(cycle % ~globalQuant == 0) { // set clock only quant in cycle
					tempo.beats = cycle;
				};
			};
			cps !? {
				tempo.tempo = cps;
			};
			latency !? {
				Server.default.latency = latency;
			}
		}
	}, {
		~dirt.receiveAction = nil;
	});
};

~cleanDict = { arg dict, synthWindowKey;
	dict.keysDo({ arg key;
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

~resetFirstTime = { arg pdefNameString;
	~firstTime.keysValuesDo({ arg key, value; // reset control bus creation
		if((key.contains(pdefNameString) and: value.not), {
			~firstTime.put(key, true);
		});
	});
};

~changePattern = { arg pdef, pattern;
	var pdefNameSymbol, pdefNameString;
	pdefNameSymbol = pdef.key.asSymbol;
	pdefNameString = pdefNameSymbol.asString;

	~resetFirstTime.value(pdefNameString);

	Pdef(pdefNameSymbol, pattern).quant_(~globalQuant);
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

	    ~resetFirstTime.value(controlId);

	});
};

~resetAllControlBus = {
	var unit;
	~pdefNumber.do({ arg i;
		unit = ("unit" ++ (1 + i)).asString;
		~resetControlBus.value(unit);
	});
};

~songInit = {
	var unit;
	~pdefNumber.do({ arg i;
		unit = (\unit ++ (1 + i)).asSymbol;
		~changePattern.value(Pdef(unit), ~initPattern);
	});
};

// remove previous Pdef, use it when you reset sequencer
~resetPdefView = {
	~synthWindow.keysValuesDo({ arg key, value;
		if(key.contains("unit"), {
			value.removeAll;
			value.remove;
			{ ~synthWindow.removeAt(key); }.defer(s.latency * 2); // need to be delayed
		});
	});
	~resetAllControlBus.value;
};

~pdefUpdate = { arg controlId, instance, controlNameSymb, value;
	var exceptions;
	exceptions = [\amp, \amplitude, \vol, \volume, \level];
	if (exceptions.includesEqual(controlNameSymb), {
		Pbindef(instance, controlNameSymb, value * Pfunc({ 1 - ~muteState.at(instance); })).quant_(~globalQuant);
	}, {
		if (~firstTime.at(controlId), {
			~controlBus.put(controlId, Bus.control(s, 1).set(value));
			Pbindef(instance, controlNameSymb, ~controlBus.at(controlId).asMap).quant_(~globalQuant);
			~firstTime.put(controlId, false);
		}, {
			~controlBus.at(controlId).set(value);
		});
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
			{ controlType == "none" or: ["out", "in", "input", "output", "inbus", "outbus", "doneaction"].includesEqual(controlName.toLower) }
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
		pdefName;
	}, {
		"autoGui wrong arguments".postln;
	});
};

~patternCodeGen = { arg synthDef = nil, unit = nil; // generates pattern based on SynthDef. If arg unit is supply: get values from view, if not: get synthDef default values
	var arguments, name, code, specList;
	if (synthDef.notNil, {
		arguments = synthDef.allControlNames;
		name = synthDef.name.asString;
		unit = unit.asString;
		code = "Pbind(
    \\instrument, \\" ++ name ++ ",
	\\dur, 1,";
		specList = "";
		arguments.do{ arg control;
			var codeAdd, controlName, controlNameLower, controlValue, controlType, min, max, step, caseFind, key;
			caseFind = false;
			controlType = "knob";
			min = "0";
			max = "1";
			step = "0.01";
			controlName = control.name.asString;
			controlNameLower = controlName.toLower;
			key = name ++ unit ++ controlName;

			if ((unit.notNil and: ~autoGuiControl.at(key).notNil), {
				controlValue = ~autoGuiControl.at(key).value.asFloat; // get value from view
			}, {
				controlValue = control.defaultValue.asFloat; // get SynthDef default value
			});

			if (["out", "in", "input", "output", "inbus", "outbus", "doneaction", "gate", "t_gate", "trig", "t_trig"].includesEqual(controlNameLower), {
				codeAdd = "";
				specList = specList ++ "\n					\"" ++ controlName ++ "\", [\"none\"],";
			}, {

				if (["amp", "level", "vol", "volume"].includesEqual(controlNameLower), {
					codeAdd = "\n    \\" ++ controlName ++ ", " ++ controlValue.asString ++ " * Pfunc({ 1 - ~muteState.at(~pdefName); }),";
				}, {
					codeAdd = "\n    \\" ++ controlName ++ ", " ++ controlValue.asString ++ ",";
				});

				case
				{ ["pan"].includesEqual(controlNameLower) }
				{
					min = "-1";
					caseFind = true;
				}
				{ (["frq", "freq", "frequence", "frequency", "cutoff", "hpf", "lpf"].includesEqual(controlNameLower) or: (controlValue > 200)) and: caseFind.not }
				{
					min = "20";
					max = "20000";
					step = "1";
					caseFind = true;
				}
				{ ["att", "attack", "dec", "decay", "sus", "sustain", "rel", "release", "timescale", "envT"].includesEqual(controlNameLower) and: caseFind.not }
				{
					controlType = "slider";
					max = "10";
					caseFind = true;
				}
				{ (["curve", "crv", "envC"].includesEqual(controlNameLower) or: (controlValue <= (-4))) and: caseFind.not }
				{
					min = "-20";
					max = "20";
				};

				specList = specList ++ "\n					\"" ++ controlName ++ "\", [\""++ controlType ++ "\", ControlSpec(" ++ min ++ ", " ++ max ++ ", step: " ++ step ++ ", default: event.at(\\" ++ controlName ++ ")), true],";
			});
			code = code ++ codeAdd;
		};
		code = code ++ "\n    \\out, ~channelBus[0],
	\\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\\instrument);\n
		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
~autoGui.value(v, ~" ++ name ++ "SynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[";
		code = code ++ specList;
		code = code ++ "\n				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);";
		Post << code;
	}, {
		"patternCodeGen wrong arguments".postln;
	});
};

// ~patternCodeGen.value(~resSynthDef); // generates pattern with synthDef default values
// ~patternCodeGen.value(~feedbackOscSynthDef, "unit1"); // generates pattern with actual view values

~synthSetCodeGen = { arg synthDef = nil, fromDefault = false;
	var arguments, name, code;
	if (synthDef.notNil, {
		arguments = synthDef.allControlNames;
		name = synthDef.name.asString;
		code = "";

		arguments.do{ arg control;
			var controlName, controlNameLower, controlValue, key;
			controlName = control.name.asString;
			controlNameLower = controlName.toLower;

			if (~nodeId.at(name).notNil, {
				key = name ++ ~nodeId.at(name) ++ controlName;
			}, {
				key = name ++ "<check name in ~nodeId>" ++ controlName;
			});

			if ((fromDefault.not and: ~autoGuiControl.at(key).notNil), {
				controlValue = ~autoGuiControl.at(key).value.asFloat; // get value from view
			}, {
				controlValue = control.defaultValue.asFloat; // get SynthDef default value
			});

			if (["out", "in", "input", "output", "inbus", "outbus", "doneaction", "gate", "t_gate", "trig", "t_trig"].includesEqual(controlNameLower), {
				code = code ++ "";
			}, {
				code = code ++ "~autoGuiControl.at(\"" ++ name ++ "\"" ++ " ++ ~nodeId.at(\"" ++ name ++ "\") ++ " ++ "\"" ++ controlName ++ "\").valueAction_(" ++ controlValue ++ ");\n";
			});

		};

		Post << code;
	}, {
		"staticSynthCodeGen wrong arguments".postln;
	});
};

// ~synthSetCodeGen.value(~quadDelaySynthDef);
// ~synthSetCodeGen.value(~verbSynthDef); // generates code with actual view values
// ~synthSetCodeGen.value(~sinBassSynthDef, true); // generates code with synthDef default values

)