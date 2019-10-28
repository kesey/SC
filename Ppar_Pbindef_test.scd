(
s.boot;
SynthDef(\bass, { arg out = 0, t_trig = 0, pan = 0, amp = 1;
	var env, sin, sig;
	env = EnvGen.ar(Env(#[0, 0.5, 0.4, 0], #[0, 0.2, 0.01], -5), t_trig, doneAction: 2);
	sin = SinOsc.ar(0, (Sweep.ar(t_trig, 2pi * [52.8, 740]) + (pi/3)).wrap(-pi, pi), #[2, 0.05]).mean.tanh;
	sig = (sin * env)!2;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\hiNoise, { arg out = 0, t_trig = 0, attack = 0.02, decay = 0.1, amp = 0.05, rq = 0.9, pan = 0, level = 10;
	var noise, sig;
	noise = WhiteNoise.ar(Decay2.kr(t_trig, attack, decay, amp));
	sig = BPF.ar(noise, TRand.kr(12000, 15000, t_trig), rq);
	DetectSilence.ar(sig, 0.001, doneAction:2);
	OffsetOut.ar(out, Pan2.ar(sig, pan, level));
}).add;
)

// in the example below (simple nesting) no problem when change \type value
(

Pdef(\unit1,
	Pbind(
		\instrument, \hiNoise,
		\dur, 0.25,
		\amp, 0.06
	)
).play;

Pdef(\unit2,
	Pbind(
	\instrument, \bass,
	\dur, Pseq([1, 0.5], inf),
	\amp, 0.8
)
).play;
)

Pbindef(\unit2, \type, \rest); // mute
Pbindef(\unit2, \type, \note); // unmute

(
Pdef(\unit1).stop;
Pdef(\unit2).stop;
)

// in the example below (complex nesting) changing \type value break the synchro between the two synth
(
~unit3 = Penvir((pdefName: "unit3Name", prevInstr: "unit3Instr"), Pdef(\unit3,
	Pbind(
		\instrument, \hiNoise,
		\dur, 0.25,
		\amp, 0.06,
		\function, Pfunc({
			~pdefName.debug("pdefName");
			~prevInstr.debug("prevInstr");
			0;
		})
	)
).quant_(0));

~unit4 = Penvir((pdefName: "unit4Name", prevInstr: "unit4Instr"), Pdef(\unit4,
	Pbind(
		\instrument, \bass,
		\dur, Pseq([1, 0.5], inf),
		\amp, 0.8,
		\function, Pfunc({
			~pdefName.debug("pdefName");
			~prevInstr.debug("prevInstr");
			0;
		})
	)
).quant_(0));

p = Ppar([~unit3, ~unit4], inf).play;
)

p.stop;

Pbindef(\unit4, \type, \rest).quant_(0);
Pbindef(\unit4, \type, \note).quant_(0);