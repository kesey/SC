

(
	SynthDef(\cymbalsimple, { | out = 0, pan = 0.0, amp=0.1 |
		var sig, env;
		env = EnvGen.ar(Env.perc(0.01, 2, curve: -4), doneAction: 2);
		sig = HPF.ar(Ringz.ar(WhiteNoise.ar(0.1), {exprand(1000, 20000)}.dup(100)).mean, 4000);
		sig = sig * amp;
		Out.ar(out, Pan2.ar(sig * env, pan));
	}).add;
	SynthDef(\cymbalsimple2, { | out = 0, pan = 0.0 |
		var sig, env;
		var env1, env2, env3, env4, env5, env6, env7, env8;
		var freqs;
		env = EnvGen.ar(Env.perc(0.01, 2, curve: -4), doneAction: 2);
		env1 = EnvGen.kr(Env([0,1,0],[0.01,0.08]), 1);
		freqs = {exprand(30, 20000)}.dup(50) ++ {exprand(1020, 10000)}.dup(50);
		sig = HPF.ar(Ringz.ar(WhiteNoise.ar(0.1), freqs).mean, ( 1.1- env1 )*4000);
		sig = sig + EnvGen.ar(Env.perc(0.001,0.001,1), levelScale:1/2);
		sig = sig + LPF.ar(WhiteNoise.ar(0.1),EnvGen.ar(Env.perc(0.5,5,1))* 20000+10,mul:2);
		sig = sig / 3;
		Out.ar(out, Pan2.ar(sig * env, pan));
	}).add;
)



(
SynthDef(\cymbaldan, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;

	locutoffenv = EnvGen.ar(Env.perc(0.5, 5)) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.ar(Env.perc(1, 3)) * 10000);
	hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);
	hidriver = hidriver * EnvGen.ar(Env.perc(1, 2, 0.25));

	thwack = EnvGen.ar(Env.perc(0.001,0.001,1));

	freqs  = {exprand(300, 20000)}.dup(100);
	res    = Ringz.ar(lodriver + hidriver + thwack, freqs).mean;
	sig = ((res * 1) + (lodriver * 2) + thwack);
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,1.1,1,-4),gate,doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
);



(
Pdef(\demo, 
	Pseq([
		Pbind(
			\instrument, Pseq([
				\cymbalsimple,
				\cymbalsimple2,
				\cymbaldan,
			],inf),
			\freq, 200,
			\dur, 1,
			\amp, 0.1,
		)
	])
).play;
)


(
Pdef(\demo, 
	Pseq([
		Pbind(
			\instrument, Pseq([
				//\cymbalsimple,
				//\cymbalsimple2,
				\cymbaldan,
			],inf),
			\freq, 200,
			\dur, 4,
			\amp, 0.2,
		)
	])
).play;
)

/////////////////////////
// iron


(
SynthDef(\iron, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	// cpu light
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	sig = SinOsc.ar(freq * ( LFSaw.ar(freq * \fmr.kr(4) * ((0..7)/7 - 0.5 * \diff.kr(1) + 1)) * \fmamp.kr(1) + 1 ));
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.01,0.1,0.8,0.1)),gate,doneAction:2);
	sig = sig.fold( SinOsc.ar( (1..8)/8 * \foldfreq.kr(1), (1..8) ) * \foldlevel.kr(1) + \foldbias.kr(1) ).flop.mean;
	sig.debug("sig");
	env1 = EnvGen.kr(\env1.kr(Env(2.01-[1,2,1],[0.1,0.8])), \trigenv.tr(1));
	sig = RLPF.ar(sig, \lpfr.kr(1.7) * env1 * freq, \rq.kr(0.5));
	pan = pan + (sig.collect({ arg x;
		SinOsc.kr(1/( x+1 ) * \panfreq.kr(1));
	}) * \panwidth.kr(1));
	sig = LeakDC.ar(sig);
	sig = HPF.ar(sig, \hpf.kr(10));
	sig = sig * \gain.kr(18);
	sig = Pan2.ar(sig, pan, amp).mean;
	Out.ar(out, sig);
}, metadata:(specs:(
	env1: XEnvSpec(),
))).add;
)
(
	// kind of hat
Pdef(\demo, Pdef(\xdemo, 
	Ppar([
		Pbind(
			\instrument, \iron,
			\note, Pstep(Pseq([
				0,0,0,-1,
			],inf),1/2),
			\octave, 8,
			\hpf, 30,
			\env1, Pseq([
				[ Env([1,1.5,1],[0.1,0.8]) ]
			],inf),
			\diff, 1.1,
			\fmr, 1/2,
			\lpfr,4,
			\adsr, Pseq([
				[ Env.adsr(0.01,0.01,0.8,0.1) ],
			],inf),
			\lag, 0.04,
			\legato, Pseq([
				0,0,1,0, 1,0,8,0, 0,0,1,1, 0,0,1,0,
				0,0,0,0, 0,0,0,0, 0,0,0,0, 0,1,0,0,
				0,0,1,0, 0,0,0,0, 0,0,1,1, 0,0,1,0,
				8,0,7,0, 8,0,8,0, 0,0,0,0, 0,1,0,0,
			],inf)/10,
			\isRest, Pfunc({ arg ev; ev[\legato] <= 0 }),
			\dur, 1/16,
			\amp,0.01,
		),
	])
)).play;
)

(
	// hard cymbal
Pdef(\demo, Pdef(\plopxx, 
	Ppar([
		Pbind(
			\instrument, \iron,
			\note, Pstep(Pseq([
				0,0,0,-1,
			],inf),1/2) + [0,3,7],
			\octave, 8,
			\hpf, 30,
			\env1, Pseq([
				[ Env([1,1.5,1],[0.1,0.8]) ]
			],inf),
			\diff, 1.1,
			\fmr, 1/2,
			\lpfr,2,
			\adsr, Pseq([
				[ Env.adsr(0.01,0.01,0.8,0.1) ],
			],inf),
			\lag, 0.04,
			\legato, Pseq([
				0,0,0,0, 1,0,0,0, 0,0,0,0, 4,0,1,0,
				0,0,0,0, 30,0,0,0, 0,0,0,0, 1,0,0,0,
			],inf)/10,
			\isRest, Pfunc({ arg ev; ev[\legato] <= 0 }),
			\dur, 1/16,
			\panwidth, 0.2,
			\gain, 5,
			\amp,0.05,
		),
	])
)).play;
)


(
	// hat
Pdef(\demo, 
	Pbind(
		\instrument, \iron,
		\note, Pstep(Pseq([
			0,0,0,-1,
		],inf),1/2) + [0,3,7],
		\octave, 9,
		\hpf, 30,
		\env1, Pseq([
			[ Env([1,1.5,1],[0.1,0.8]) ]
		],inf),
		\diff, 1.1,
		\fmr, 1/4 * Pseq([1,0.1],inf).stutter(2),
		\lpfr,2,
		\adsr, Pseq([
			[ Env.adsr(0.051,0.01,0.8,0.2) ],
			[ Env.adsr(0.051,0.01,0.8,0.1) ],
		],inf).stutter(2),
		\legato, Pseq([
			1,0,1,0, 
		],inf)/10,
		\isRest, Pfunc({ arg ev; ev[\legato] <= 0 }),
		\dur, 1/16,
		\panwidth, 0.2,
		\gain, 5,
		\amp,0.05,
	),
).play;
)

(
Pdef(\demo, Pdef(\xdemo, 
	Ppar([
		Pbind(
			\instrument, \iron,
			\note, Pstep(Pseq([
				0,0,0,-1,
			],inf),1/2) + [0,3,7],
			\octave, 9,
			\hpf, 30,
			\env1, Pseq([
				[ Env([1,1.5,1],[0.1,0.8]) ]
			],inf),
			\diff, 1.1,
			\fmr, 1/4 * Pseq([1,0.1],inf).stutter(2),
			\lpfr,2,
			\adsr, Pseq([
				[ Env.adsr(0.051,0.01,0.8,0.2) ],
				[ Env.adsr(0.051,0.01,0.8,0.1) ],
				[ Env.adsr(0.011,0.01,0.8,0.2) ],
				[ Env.adsr(0.051,0.01,0.8,0.2) ],
				[ Env.adsr(0.051,0.01,0.8,0.1) ],
				[ Env.adsr(0.011,0.01,0.8,0.2) ],
				[ Env.adsr(0.051,0.01,0.8,0.1) ],
				[ Env.adsr(0.011,0.01,0.8,0.2) ],
			],inf).stutter(2),
			\legato, Pseq([
				1,0,1,0, 1,0,1,0, 
				1,0,1,0, 1,0,1,0, 
				1,0,1,0, 1,0,1,0, 
				1,1,0,1, 1,0,1,0, 
		
				1,0,1,0, 1,0,1,0, 
				1,0,1,1, 1,0,1,0, 
				1,0,1,0, 1,0,1,0, 
				1,0,1,0, 1,1,0,1, 
			],inf)/10,
			\isRest, Pfunc({ arg ev; ev[\legato] <= 0 }),
			\dur, 1/16,
			\panwidth, 0.2,
			\gain, 5,
			\lag, 0.04,
			\amp,0.05,
		),
	])
)).play;
)

///////////////////////:

(
SynthDef(\cymbalsimple3, { | out = 0, pan = 0.0 |
	var sig, env;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	var freqs;
	env = EnvGen.ar(\perc.kr(Env.perc(0.01, 2, curve: -4)), doneAction: 2);
	env1 = EnvGen.kr(Env([0,1,0],[0.01,0.08]), 1);
	freqs = \freqtab.kr({exprand(8030, 12000)}.dup(50) ++ {exprand(720, 7000)}.dup(50));
	sig = HPF.ar(Ringz.ar(WhiteNoise.ar(0.1), freqs, 4.1).mean, ( 1.1- env1 )*4000);
	sig = sig + EnvGen.ar(Env.perc(0.001,0.001,1), levelScale:1/2);
	sig = sig + LPF.ar(WhiteNoise.ar(0.1),EnvGen.ar(Env.perc(0.5,5,1))* 20000+10,mul:2);
	sig = sig / 3;
	Out.ar(out, Pan2.ar(sig * env, pan));
}).add;
)

(
Pdef(\demo, Pdef(\demomo, 
	Ppar([
		Pbind(
			\instrument, \cymbalsimple3,
			\freq, 200,
			\freqtab, Pfunc({ arg ev;
				thisThread.randSeed = 10;
				[ {exprand(8030, 12000)}.dup(50) ++ {exprand(720, 7000)}.dup(50) ]
			}),
			\dur, 1,
			\amp, 0.1,
		),
	])
)).play;
)
