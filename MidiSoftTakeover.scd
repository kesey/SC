(
MIDIIn.connectAll;
SynthDef(\SimpleSynth, { arg out = 0, freq = 1000, t_trig = 0, level =
0.2;
        var sig, env;
	env = EnvGen.kr(Env.adsr(releaseTime: 240), t_trig, doneAction: 0);
        sig = SinOsc.ar(freq, 0, env * level);
        Out.ar(out, sig!2);
}).add;
)

(
var knob, active;
active = false;

~a = Synth(\SimpleSynth);

w = Window("Test",Rect(0, 0, 200, 200), scroll: true);
w.front;

knob = EZKnob(w, 112@70, 'freq', ControlSpec(20, 20000, step: 1,
default: 20, units: 'hz'), { arg knob; ~a.set(\freq, knob.value); active = false; },
margin: 39@0);

MIDIFunc.cc({ arg val, num, chan, src;
	var guiControl, midiControl, treshold;
	midiControl = val.linlin(0, 127, 20, 20000);
	guiControl = knob.value;
	treshold = 500; // adapt this with your needs, it depends on the values of step in ControlSpec and the value of step of your midi controller
	if ( // soft takeover
		(active or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
		{
			active = true;
			{
				~a.set(\freq, midiControl);
				knob.value_(midiControl);
			}.defer;
		}
	);
	(midiControl).debug("Ext Contoller value");
	(guiControl).debug("GUI value");
}, 21, 0, 0); // cc number 21 on channel 1
)

~a.set(\t_trig, 1);