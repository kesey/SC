s.boot;

s.meter;
s.plotTree;

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=3, c1=1, c2=(-1), freq=500, detune=0.2, pan=0, cfhzmin=0.1, cfhzmax=0.3, cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2, lsf=200, ldb=0, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env([0,1,1,0],[atk, sus, rel],[c1,0,c2]), doneAction: 2);
	sig = Saw.ar(freq * {LFNoise1.kr(0.5, detune).midiratio}!2);
	sig = BPF.ar(
		sig,
		{LFNoise1.kr(
			LFNoise1.kr(4).exprange(cfhzmin, cfhzmax)
		).exprange(cfmin, cfmax)}!2,
		{LFNoise1.kr(0.1).exprange(rqmin, rqmax)}!2
	);
	sig = BLowShelf.ar(sig,lsf,0.5,ldb);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

(
~marimba = Pbind(
	\instrument, \bpfsaw,
	\dur, Prand([1,0.5],inf),
	\freq, Prand([1/2,2/3,1,4/3,2,5/2,3,4,6,8],inf),
	\detune, 0, //Pwhite(0,0.1,inf),
	\rqmin, 0.005,
	\rqmax, 0.008,
	\cfmin, Prand((Scale.major.degrees+64).midicps, inf) * Prand([0.5,1,2,4],inf),
	\cfmax, Pkey(\cfmin) * Pwhite(1.008,1.025,inf),
	\atk, 3,
	\sus, 1,
	\rel, 5,
	\amp, 1,
	\out, 0,
).play;
)

~marimba.stop;


(
~chords = Pbind(
	\instrument, \bpfsaw,
	\dur, Pwhite(4.5,7.0,inf),
	\midinote, Pxrand([
		[23,35,54,63,64],
		[43,52,54,59,61,64],
		[28,40,47,56,59,63],
		[42,52,57,61,63]
	],inf),
	\detune, Pexprand(0.05,0.2,inf),
	\cfmin, 100,
	\cfmax, 1500,
	\rqmin, Pexprand(0.01,0.15,inf),
	\atk, Pwhite(2.0,2.5,inf),
	\rel, Pwhite(6.5,10.0,inf),
	\ldb, 6,
	\amp, 0.2,
	\out, 0
).play;
)

~chords.stop;