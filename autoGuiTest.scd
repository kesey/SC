(
MIDIClient.init; // post a list of available devices

// MIDIClient.sources; // list avalaible midi sources
// MIDIIn.connectAll; // connect to all attached input sources
MIDIIn.connect(0, MIDIClient.sources[0]);

~samplerStereoSynthDef = SynthDef(\samplerStereo,{ arg out = 0, buffer = 0, rate = 1, startPos = 0, loop = 0, attack = 0.001, release = 1, pan = 0, amp = 1, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, gate, doneAction: doneAction);
	sig = PlayBuf.ar(2, buffer, BufRateScale.kr(buffer) * rate, gate, BufFrames.kr(buffer)*startPos, loop, doneAction) * env;
	sig = Balance2.ar(sig[0], sig[1], pan, amp.curvelin(0, 1, 0, amp, log(10)));
	Out.ar(out, sig);
}).add;

~sinBassSynthDef = SynthDef(\sinBass,{arg out = 0, gate = 1, amp = 1, curve = \lin, loopNode = nil, attack = 0.01, release = 4, pan = 0, envFreq1 = 0, envFreq2 = 40, envFreq3 = 32, envFreq4 = 50, envFreq5 = 0, envFreq6 = 60, envTime1 = 0.5, envTime2 = 0.3, envTime3 = 0.25, envTime4 = 1, envTime5 = 0.5, doneAction = 2;
	var freqEnv, env, sig;
	freqEnv = EnvGen.kr(Env.new([envFreq1, envFreq2, envFreq3, envFreq4, envFreq5, envFreq6], [envTime1, envTime2, envTime3, envTime4, envTime5], curve, loopNode: loopNode));
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, gate, doneAction: doneAction);
	sig = LPF.ar(SinOsc.ar(freqEnv, mul: env), 20);
	Out.ar(out, Pan2.ar(sig, pan, amp));
}).add;

~synthWindow = Dictionary.new;
)

(
// automatic GUI creation and midi mapping
~autoGui = { arg parentWindow = nil, synthDef = nil, instance = nil, ccStart = 10, backGroundColor = Color.white, specDict = Dictionary.new;
	var arguments, synthWindow, list, slider, button, knob, active, synthDefName, pdefName;

	if ((parentWindow.notNil and: synthDef.notNil and: instance.notNil), {
		synthDefName = synthDef.name.asString;
		arguments = synthDef.allControlNames;
		specDict.put("default", ["knob", ControlSpec(0, 1, step: 0.01, default: 0), true]);

		if (instance.isSymbol, {
			pdefName = instance.asString;
		}, {
			pdefName = "";
			if (instance.isString, {
				instance = instance.asSymbol;
			});
		});

		~synthWindow.put(synthDefName ++ pdefName,
			CompositeView(bounds: (arguments.size * 62)@110)
			.scroll(autoScrolls: true)
			.minHeight_(115)
			.minWidth_(230)
			.background_(backGroundColor);
		);
		synthWindow = ~synthWindow.at(synthDefName ++ pdefName);

		synthWindow.decorator_(FlowLayout(synthWindow.bounds, 3@3, 6@3));

		// SynthDef name
		StaticText(synthWindow, 100@26)
		.string_(synthDefName ++ " " ++ pdefName)
		.stringColor_(Color.black)
		.align_(\center);
		synthWindow.decorator.nextLine;

		list = Dictionary.new;
		slider = Dictionary.new;
		button = Dictionary.new;
		knob = Dictionary.new;
		active = Dictionary.new;

		arguments.do({
			arg control, i;
			var caseFind, controlName, controlNameSymb, controlType, controlSpec, midiMap;
			caseFind = false;
			controlName = control.name.asString;
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
			{ controlType == "none" or: "out in input output doneaction".contains(controlName.toLower) }
			{
				caseFind = true;
			}
			{ controlType == "list" and: caseFind.not }
			{
				// list creation
				active.put(("list" ++ i ++ "Active").asString, false);
				list.put(("list" ++ i).asString, EZListView(synthWindow, 60@70, controlName, controlSpec, { arg guiControl; if (instance.isSymbol, { Pbindef(instance, controlNameSymb, guiControl.value); }, { instance.set(controlNameSymb, guiControl.value); }); active.put(("list" ++ i ++ "Active").asString, false); }));

				if (midiMap, { // list midi map
					MIDIFunc.cc({ arg val, num, chan, src;
						var guiControl, midiControl, threshold;
						threshold = 0.5;
						midiControl = val.linlin(0, 127, 0, list.at(("list" ++ i).asString).items.size - 1);
						{
							guiControl = list.at(("list" ++ i).asString).value;
							if ( // soft takeover
								(active.at(("list" ++ i ++ "Active").asString) or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
								{
									active.put(("list" ++ i ++ "Active").asString, true);
									if (instance.isSymbol, { Pbindef(instance, controlNameSymb, midiControl); }, { instance.set(controlNameSymb, midiControl); });
									list.at(("list" ++ i).asString).value_(midiControl);
								}
							);
						}.defer;
					}, ccStart, 0);
					(ccStart).debug(synthDefName ++ " " ++ controlName ++ " cc number");
					ccStart = ccStart + 1;
				});

				caseFind = true;
			}
			{ controlType == "slider" and: caseFind.not }
			{
				// slider creation
				active.put(("slider" ++ i ++ "Active").asString, false);
				slider.put(("slider" ++ i).asString, EZSlider(synthWindow, 60@70, controlName, controlSpec, { arg guiControl; if (instance.isSymbol, { Pbindef(instance, controlNameSymb, guiControl.value); }, { instance.set(controlNameSymb, guiControl.value); }); active.put(("slider" ++ i ++ "Active").asString, false); }, layout: \vert, gap: 6@6));

				if (midiMap, { // slider midi map
					MIDIFunc.cc({ arg val, num, chan, src;
						var guiControl, midiControl, threshold, minValue, maxValue;
						minValue = slider.at(("slider" ++ i).asString).controlSpec.minval;
						maxValue = slider.at(("slider" ++ i).asString).controlSpec.maxval;
						threshold = ((maxValue - minValue) * 5) / 100; // 5% of the range
						midiControl = val.linlin(0, 127, minValue, maxValue);
						guiControl = slider.at(("slider" ++ i).asString).value;
						if ( // soft takeover
							(active.at(("slider" ++ i ++ "Active").asString) or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
							{
								active.put(("slider" ++ i ++ "Active").asString, true);
								{
									if (instance.isSymbol, { Pbindef(instance, controlNameSymb, midiControl); }, { instance.set(controlNameSymb, midiControl); });
									slider.at(("slider" ++ i).asString).value_(midiControl);
								}.defer;
							}
						);
					}, ccStart, 0);
					(ccStart).debug(synthDefName ++ " " ++ controlName ++ " cc number");
					ccStart = ccStart + 1;
				});

				caseFind = true;
			}
			{ /*"trigger trig gate t_trig t_gate loop mute start stop on off".contains(controlName) or: */controlType == "button" and: caseFind.not } // in this case create button
			{
				// button creation
				button.put(("button" ++ i).asString, Button(synthWindow, Rect(10,110,40,25)).states_([[controlName, Color.black, Color.white],["stop", Color.white, Color.grey]]).action = { arg guiControl; if (instance.isSymbol, { Pbindef(instance, controlNameSymb, guiControl.value); }, { instance.set(controlNameSymb, guiControl.value); }); });

				if (midiMap, { // button midi map
					MIDIFunc.cc({ arg val, num, chan, src;
						var midiControl;
						midiControl = val.linlin(0, 127, 0, 1);
						{
							button.at(("button" ++ i).asString).valueAction_(midiControl);
						}.defer;
					}, ccStart, 0);
					(ccStart).debug(synthDefName ++ " " ++ controlName ++ " cc number");
					ccStart = ccStart + 1;
				});

				caseFind = true;
			}
			{  controlType == "knob" or: caseFind.not } // default case create knob
			{
				// knob creation
				active.put(("knob" ++ i ++ "Active").asString, false);
				knob.put(("knob" ++ i).asString, EZKnob(synthWindow, 60@70, controlName, controlSpec, { arg guiControl; if (instance.isSymbol, { Pbindef(instance, controlNameSymb, guiControl.value); }, { instance.set(controlNameSymb, guiControl.value); }); active.put(("knob" ++ i ++ "Active").asString, false); }));

				if (midiMap, { // knob midi map
					MIDIFunc.cc({ arg val, num, chan, src;
						var guiControl, midiControl, threshold, minValue, maxValue;
						minValue = knob.at(("knob" ++ i).asString).controlSpec.minval;
						maxValue = knob.at(("knob" ++ i).asString).controlSpec.maxval;
						threshold = ((maxValue - minValue) * 5) / 100; // 5% of the range
						midiControl = val.linlin(0, 127, minValue, maxValue);
						guiControl = knob.at(("knob" ++ i).asString).value;
						if ( // soft takeover
							(active.at(("knob" ++ i ++ "Active").asString) or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
							{
								active.put(("knob" ++ i ++ "Active").asString, true);
								{
									if (instance.isSymbol, { Pbindef(instance, controlNameSymb, midiControl); }, { instance.set(controlNameSymb, midiControl); });
									knob.at(("knob" ++ i).asString).value_(midiControl);
								}.defer;
							}
						);
					}, ccStart, 0);
					(ccStart).debug(synthDefName ++ " " ++ controlName ++ " cc number");
					ccStart = ccStart + 1;
				});
			};
		});

		parentWindow.layout.add(synthWindow);

		if (instance.isSymbol, {
			// removes all the children of the view and destroys them then remove the composite view
			Button(synthWindow, Rect(10,110,20,20)).states_([["X", Color.white, Color.red]]).action = { synthWindow.removeAll; synthWindow.remove; };
		});
	}, {
		"autoGui wrong arguments".postln;
	});
};

~removePrevView = { arg synthWindow, synthWindowKey;
	var synthView;
	if (synthWindow.includesKey(synthWindowKey), {
		synthView = synthWindow.at(synthWindowKey);
		synthView.removeAll; // removes all children
		synthView.remove; // remove the composite view
	});
};

b = Buffer.read(s, "/Users/Fabien/SuperCollider/ORBM/Audio/Bowed_Empty_Sweep_Slow/waterharp_fx_empty_sweep_slow_01.wav");

~samplerStereo = Synth(\samplerStereo, [\out, 0, \gate, 0, \buffer, b.bufnum, \doneAction, 0]);
~sinBass = Synth(\sinBass, [\out, 0, \gate, 0, \doneAction, 0]);

w = Window("GUI_TEST", Rect(0, 0, 1050, 800), scroll: true);
w.layout = VLayout();
w.front;

// auto Gui
~autoGui.value(w, ~samplerStereoSynthDef, ~samplerStereo, 85, Color.new255(107, 142, 35), Dictionary.newFrom(List["buffer", ["none"], "pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), false], "attack", ["slider", ControlSpec(0, 10, step: 0.01, default: 0), true], "gate", ["button", ControlSpec(0, 1, step: 1, default: 0), true], "loop", ["button", ControlSpec(0, 1, step: 1, default: 0), true]]));

~autoGui.value(w, ~sinBassSynthDef, ~sinBass, 93, Color.yellow, Dictionary.newFrom(List["pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), false], "attack", ["slider", ControlSpec(0, 10, step: 0.01, default: 0), true], "gate", ["button", ControlSpec(0, 1, step: 1, default: 0), true], "loopNode", ["slider", ControlSpec(0, 10, step: 0.01, default: 2), true], "amp", ["knob", ControlSpec(0, 10, step: 0.01, default: 1), true]]));

)

(
~pattern1 = Pbind(
	\instrument, \samplerStereo,
	\dur, 1,
	\buffer, b.bufnum,
	\amp, 0.7,
	\rate, Pseq([0.8, 0.3, 0.8, 0.2], inf),
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~prevInstr, {
			synthWindowKey = (~prevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			{
				~removePrevView.value(~synthWindow, synthWindowKey);
				~autoGui.value(w, ~samplerStereoSynthDef, instance, 103, Color.white, Dictionary.newFrom(List["buffer", ["none"], "pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), true], "attack", ["slider", ControlSpec(0, 10, step: 0.01, default: 0), true], "gate", ["none"], "loop", ["button", ControlSpec(0, 1, step: 1, default: 0), true], "amp", ["knob", ControlSpec(0, 2, step: 0.1, default: 1), true]]));
			}.defer;
			~prevInstr = currentInstr;
		});
		0;
	}),
	\out, 0
);

~pattern2 = Pbind(
	\instrument, \sinBass,
	\dur, 1.5,
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~prevInstr, {
			synthWindowKey = (~prevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			{
				~removePrevView.value(~synthWindow, synthWindowKey);
				~autoGui.value(w, ~sinBassSynthDef, instance, 113, Color.white, Dictionary.newFrom(List["pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), false], "attack", ["slider", ControlSpec(0, 10, step: 0.01, default: 0), true], "loopNode", ["slider", ControlSpec(0, 10, step: 0.01, default: 2), true], "gate", ["none"], "amp", ["knob", ControlSpec(0, 10, step: 0.01, default: 1), true]]));
			}.defer;
			~prevInstr = currentInstr;
		});
		0;
	}),
	\out, 0
);

Penvir((pdefName: \unit1, prevInstr: nil), Pdef(\unit1,
	~pattern1
)).play;

Penvir((pdefName: \unit2, prevInstr: nil), Pdef(\unit2,
	~pattern2
)).play;

~pdefName.debug("pdefName Ext");
~prevInstr.debug("prevInstr Ext");
)

Pdef(\unit1, ~pattern2);
Pdef(\unit1, ~pattern1);
Pdef(\unit2, ~pattern1);

Pdef(\unit1, \dur, 0.5);
Pdef(\unit1).set(\amp, 0.1);
Pbindef(\unit1, \amp, 0.1);
Pbindef(\unit1, \amp, 0.7);