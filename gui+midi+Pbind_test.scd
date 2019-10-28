(
MIDIClient.init; // post a list of available devices

// MIDIClient.sources; // list avalaible midi sources
// MIDIIn.connectAll; // connect to all attached input sources
MIDIIn.connect(0, MIDIClient.sources[0]);

SynthDef(\samplerStereo,{ arg out = 0, buffer = 0, rate = 1, startPos = 0, loop = 0, attack = 0.001, release = 1, pan = 0, amp = 1, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, gate, doneAction: doneAction);
	sig = PlayBuf.ar(2, buffer, BufRateScale.kr(buffer) * rate, gate, BufFrames.kr(buffer)*startPos, loop, doneAction) * env;
	sig = Balance2.ar(sig[0], sig[1], pan, amp);
	Out.ar(out, sig);
}).add;
)

(
var knob, button, activeKnob;

b = Buffer.read(s, "/Users/Fabien/SuperCollider/ORBM/Audio/Bowed_Empty_Sweep_Slow/waterharp_fx_empty_sweep_slow_01.wav");

~samplerStereo = Synth(\samplerStereo, [\buffer, b.bufnum, \gate, 0, \doneAction, 0]);

~ccStart = 21; // start mapping midi cc from here
~ccStart = ~ccStart.max(0).min(127); // limit ccStart

w = Window("GUI_TEST",Rect(0, 0, 250, 225), scroll: true);
w.front;
//w.alwaysOnTop_(true);
w.view.decorator = FlowLayout(w.view.bounds, 3@3, 3@3);

activeKnob = false;
knob = EZKnob(w, 120@70, 'rate', ControlSpec(0, 5, step: 0.1, default: 1), { arg guiControl; Pbindef(\unit1, \rate, guiControl.value); if (~samplerStereo.notNil, { ~samplerStereo.set(\rate, guiControl.value); }); activeKnob = false; }, margin: 39@0);

MIDIFunc.cc({ arg val, num, chan, src;
	var guiControl, midiControl, threshold;
	midiControl = val.linlin(0, 127, 0, 5);
	guiControl = knob.value;
	threshold = 0.1;
	if ( // soft takeover
		(activeKnob or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
		{
			activeKnob = true;
			{
				if (~samplerStereo.notNil, { ~samplerStereo.set(\rate, midiControl) });
				Pbindef(\unit1, \rate, midiControl);
				knob.value_(midiControl);
			}.defer;
		}
	);
}, ~ccStart, 0);
(~ccStart).debug("rate cc number");

button = Button(w, Rect(10,110,112,35))
.states_([["Gate", Color.black, Color.white],["Stop", Color.white, Color.grey]])
.action = { arg guiControl;
	if (~samplerStereo.notNil, { ~samplerStereo.set(\gate, guiControl.value); });
};

~ccStart = ~ccStart + 1;
MIDIFunc.cc({ arg val, num, chan, src;
	var midiControl;
	midiControl = val.linlin(0, 127, 0, 1);
	{
		button.valueAction_(midiControl);
	}.defer;
}, ~ccStart, 0);
(~ccStart).debug("gate cc number");

s.plotTree; // node tree

)

(
Pdef(\unit1,
	Pbind(
		\instrument, \samplerStereo,
		\buffer, b.bufnum,
		\dur, 1,
		\amp, 1,
		\rate, Pseq([1, 2, 3, 2, 1], inf)
	)
).play;
)

Pbindef(\unit1, \rate, 6);
Pbindef(\unit1).stop;