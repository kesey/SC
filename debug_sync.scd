(
// init
~sequenceQuant = 1.5;
~globalQuant = 1.5/2;
~pdefNumber = 2; // number of pdef or units

~sequencer = Dictionary.new;
~synthWindow = Dictionary.new;
~autoGuiControl = Dictionary.new;

//Function

~removePrev = { arg synthWindowKey; // use it inside a defer function
	var synthView;
	if (~synthWindow.includesKey(synthWindowKey), {
		synthView = ~synthWindow.at(synthWindowKey);
		synthView.removeAll; // removes all children
		synthView.remove; // remove the composite view
		{ ~synthWindow.removeAt(synthWindowKey); }.fork(t, 0.2);

		~autoGuiControl.keysDo({ arg key; // remove controls no longer in use
			if(key.contains(synthWindowKey), {
				~autoGuiControl.removeAt(key);
			});
		});

		MIDIdef.all.keysDo({ arg key; // remove mididef no longer in use
			if(key.contains(synthWindowKey), {
				MIDIdef(key).free;
			});
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

		active = Dictionary.new;

		arguments.do({
			arg control, i;
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
				active.put(controlId, false);
				~autoGuiControl.put(controlId, EZListView(synthWindow, 60@70, controlName, controlSpec, {
					arg guiControl;
					if (instance.isSymbol,
						{ Pbindef(instance, controlNameSymb, guiControl.value).quant_(~globalQuant); },
						{ instance.set(controlNameSymb, guiControl.value); }
					);
					active.put(controlId, false);
				}));

				if (midiMap, { // list midi map
					MIDIdef.cc(controlId, { arg val, num, chan, src;
						var guiControl, midiControl, threshold;
						threshold = 0.5;
						midiControl = val.linlin(0, 127, 0, ~autoGuiControl.at(controlId).items.size - 1);
						{
							guiControl = ~autoGuiControl.at(controlId).value;
							if ( // soft takeover
								(active.at(controlId) or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
								{
									active.put(controlId, true);
									if (instance.isSymbol,
										{ Pbindef(instance, controlNameSymb, midiControl).quant_(~globalQuant); },
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
				active.put(controlId, false);
				~autoGuiControl.put(controlId, EZSlider(synthWindow, 60@70, controlName, controlSpec, {
					arg guiControl;
					if (instance.isSymbol,
						{ Pbindef(instance, controlNameSymb, guiControl.value).quant_(~globalQuant); },
						{ { instance.set(controlNameSymb, guiControl.value); }.fork(t, ~globalQuant); }
					);
					active.put(controlId, false);
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
							(active.at(controlId) or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
							{
								active.put(controlId, true);
								{
									if (instance.isSymbol,
										{ Pbindef(instance, controlNameSymb, midiControl).quant_(~globalQuant); },
										{ { instance.set(controlNameSymb, midiControl); }.fork(t, ~globalQuant); }
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
				~autoGuiControl.put(controlId,
					Button(synthWindow, Rect(10,110,60,25))
					.states_([
						[controlName ++ " on", Color.black, Color.white],
						[controlName ++ " off", Color.white, Color.grey]
					])
					.action = {
						arg guiControl;
						if (instance.isSymbol,
							{ Pbindef(instance, controlNameSymb, guiControl.value).quant_(~globalQuant); },
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
				active.put(controlId, false);
				~autoGuiControl.put(controlId, EZKnob(synthWindow, 60@70, controlName, controlSpec, {
					arg guiControl;
					if (instance.isSymbol,
						{ Pbindef(instance, controlNameSymb, guiControl.value).quant_(~globalQuant); },
						{ { instance.set(controlNameSymb, guiControl.value); }.fork(t, ~globalQuant); }
					);
					active.put(controlId, false);
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
							(active.at(controlId) or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
							{
								active.put(controlId, true);
								{
									if (instance.isSymbol,
										{ Pbindef(instance, controlNameSymb, midiControl).quant_(~globalQuant); },
										{ { instance.set(controlNameSymb, midiControl); }.fork(t, ~globalQuant); }
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

// return an Array of Penvir use it in Ppar to play all the units
~listUnits = { arg sequencer;
	var listUnits;
	listUnits = sequencer.size.collect({ arg i;
		sequencer.at(("unit" ++ (i + 1)).asSymbol);
	});
	listUnits;
};

// Synthdef
~kickMistSynthDef = SynthDef(\kickMist, { arg out = 0, level = 1, tu = 1, noise = 1, env0L1 = 0.5, env0L2 = 1, env0L3 = 0.3, env0L4 = 0, env0T1 = 0.01, env0T2 = 0.5, env0T3 = 0.26, env1L1 = 120, env1L2 = 43, env1L3 = 29, env1T1 = 0.03, env1T2 = 0.29;
	var env0, env1, env1m, sig;
	env0 =  EnvGen.ar(Env.new([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3], #[-4, -2, -4]), doneAction: 2);
	env1 = EnvGen.ar(Env.new([env1L1, env1L2, env1L3], [env1T1, env1T2], #[-4, -5]));
	env1m = env1.midicps;
	sig = LFPulse.ar(env1m*tu, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(noise);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m*tu, 0.5, env0*4);
	sig = sig.clip2(1);
	OffsetOut.ar(out, Pan2.ar(sig, 0, level));
}).add;

~cymbalic_mcldSynthDef = SynthDef(\cymbalic_mcld, { |amp=0.1, out=0, t_trig = 1, pan=0, relLow = 5, relHi = 3, attTh = 0.001, relTh = 0.001, doneAction = 2|
	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack, sig;

	locutoffenv = EnvGen.ar(Env.perc(0.5, 5), t_trig, doneAction: doneAction) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.ar(Env.perc(1, 3), t_trig, doneAction: doneAction) * 10000);
	hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);
	hidriver = hidriver * EnvGen.ar(Env.perc(1, 2, 0.25));

	thwack = EnvGen.ar(Env.perc(attTh,relTh,1), t_trig, doneAction: doneAction);

	// This bit will regenerate new freqs every time you evaluate the SynthDef!
	freqs  = {exprand(300, 20000)}.dup(100);

	res    = Ringz.ar(lodriver + hidriver + thwack, freqs).mean;
	sig = (res * 1) + (lodriver * 2) + thwack;
	Out.ar(out, Pan2.ar(sig, pan, amp));
}).add;

//Pattern
~song2Pattern1 = Pbind(
	\instrument, \kickMist,
	[\dur, \lag], Pseq([[1, 0], [0.5, 0.02]], inf),
	//\timingOffset, 0.75,
	\tu, 0.47,
	\level, 0.08,
	\out, 0,
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kickMistSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_gate", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), true],
					"level", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\level)), true],
					"tu", ["knob", ControlSpec(0, 2, step: 0.01, default: event.at(\tu)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song2Pattern2 = Pbind(
	\instrument, \cymbalic_mcld,
	\dur, Pseq([Pn(0.125, 6), 0.4375, 0.3125], inf), // 0.125*6 + 0.4375 + 0.3125 == 1.5
	\amp, 0.015,
	\relLow, 2,
	\relHi, 6,
	\relTh, 0.01,
	\pan, Pwhite(-0.5, 0.5, inf),
	\out, 0,
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~cymbalic_mcldSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), true],
					"amp", ["knob", ControlSpec(0, 1, step: 0.001, default: event.at(\amp)), true],
					"relLow", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\relLow)), true],
					"relHi", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\relHi)), true],
					"attTh", ["knob", ControlSpec(0, 10, step: 0.01, default: 0.001), true],
					"relTh", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\relTh)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

// Sequencer

~pdefNumber.do({ // sequencer creation with pdefNumber of units
	arg i;
	var name;
	name = ("unit" ++ (i + 1)).asSymbol;
	~sequencer.put(name,
		Penvir(
			(pdefName: name, pdefPrevInstr: nil, pdefCcStart: 21, pdefMidiChan: i + 2),
			Pdef(name)/*.quant_(~globalQuant)*/;
		)
	);
});

p = Ppar(~listUnits.value(~sequencer), inf); // all units in parallel

// Song
~song2 = {
	loop {
		Pdef(\unit1, ~song2Pattern1).quant_(~sequenceQuant);
		Pdef(\unit2, ~song2Pattern2).quant_(~sequenceQuant);
		18.0.wait;
		Pbindef(\unit2, \type, \rest).quant_(~sequenceQuant);
		6.0.wait;
		Pbindef(\unit2, \type, \note).quant_(~sequenceQuant);
	}
};

// GUI
x = Window("SynthDef", Rect(600, 30, 800, 725));
x.layout = VLayout();
x.front;

v = ScrollView(x, x.view.bounds);
v.canvas = View();
v.canvas.layout = VLayout();
)

( // Play Both
Tdef(\song, ~song2).play(t, true, ~sequenceQuant);
if (~sequencerTransport.isPlaying.not, { ~sequencerTransport = p.play(t, quant: ~sequenceQuant); });
)

( // Stop Both
Tdef(\song).stop;
~sequencerTransport.stop;
)

( // Reset Both
Tdef(\song).reset;
~sequencerTransport.reset;
)

/////////// Song transport

Tdef(\song, ~testSong).play(t, true, ~sequenceQuant); // Play Song

Tdef(\song).pause;
Tdef(\song).resume(t, ~sequenceQuant);
Tdef(\song).stop;
Tdef(\song).reset;

Pbindef(\unit2, \type, \rest).quant_(~sequenceQuant);
Pbindef(\unit2, \type, \note).quant_(~sequenceQuant);
Pbindef(\unit2, \relLow, 0.98).quant_(~sequenceQuant);
Pbindef(\unit2, \relLow, 8.5).quant_(~sequenceQuant);