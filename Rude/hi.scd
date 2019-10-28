(
SynthDef(\chordb, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3;
	sig = {arg x; 
		var isig;
		var ffac = 8;
		isig = LFSaw.ar( freq/2 * x + ExpRand(freq/64,2*freq/64));
		isig = isig + LFPulse.ar( freq/ffac * x + ExpRand(freq/64/ffac,2*freq/64/ffac));

		isig = RLPF.ar(isig, freq/2 * x + ExpRand(freq/64,2*freq/64)* LFNoise1.kr(1/4).range(1.1,1) * \lpffac.kr(2) , \rq.kr(0.5));
	}!5;
	sig = sig.scramble;
	sig = TScramble.ar(sig, Impulse.kr(4),1);
	//sig = FreqShift.ar(sig, 4 * SinOsc.kr(1/45).range(0,1)) + sig;
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(1.01,0.1,1,1.1)),gate,doneAction:doneAction);
	sig = Splay.ar(sig, spread, amp, pan) / 5;
	Out.ar(out, sig);
}).add;

Pdef(\chordb, Pbind(
	//\freq, 100,
	\instrument, \chordb,
	\amp, 0.2,
	\degree, Pseq([
		Prand([0,1,4,0]),
		Prand([0,1,4,0])+8,
	],inf) + Ptuple([0,Pseq([3,5],inf)]),
	\lpffac, Ndef(\lfo1, { CuspN.ar(1/7).range(0.50,4)  }),
	\adsr, Prand([
		[ Env.adsr(0.1,0.1,0.8,0.1) ],
		[ Env.adsr(0.001,0.1,0.8,1.1) ],
		[ Env.adsr(0.1,0.1,0.8,0.001) ],
		[ Env.adsr(1.1,0.1,0.8,0.1) ],
	],inf).stutter(4),
	\scale, Scale.minor,
	\octave, 4,
	\dur, 1/4,
	\legato, Pseq([
		4,2,1,1,
	],inf),
	\isRest, false,
)).play;
)

/////////////////////////////////:

SynthDef(\oscsampler3, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, bufnum, pos=0, finepos=0, range=0.01,
						lpmix=0.5, ffreq=500, rq=0.1, spread=0.8, fshift=0;
	// env longer
	var ou, ou2;
	var osc;
	var bufsig;
	var phase;
	var ffreqtab;
	osc = SinOsc.ar(freq*[1.001,0.999,1]);
	//osc = osc.sum;
	pos = EnvGen.kr(\posenv.kr(Env([1,0,0.5,0.2, 0.2], [0.2,0.1,0.1,0.1])),gate, levelScale:\levelScale.kr(1), timeScale:\timeScale.kr(1)) + pos;
	range = (range + (\framerange.kr(0)/BufFrames.ir(bufnum)));
	phase = osc * range + pos + finepos.lag(\fineposlag.kr(0));

	bufsig = BufRd.ar(2, bufnum, phase*BufFrames.ir(bufnum), 1);
	bufsig = bufsig.sum;
	ou = bufsig;
	ffreqtab = \ffreqtab.kr(1!8);
	ou = FreqShift.ar(ou, fshift);
	ou2 = RLPF.ar(ou, (ffreq * ffreqtab).clip(10,18000), rq);
	ou = SelectX.ar(lpmix, [ou, ou2]);
	ou2 = HPF.ar(ou, (\hpfreq.kr(180) * ffreqtab).clip(10,18000));
	ou = SelectX.ar(\hpmix.kr(0), [ou, ou2]);

	ou2 = (ou * \distpreamp.kr(18)).tanh / \distamp.kr(1);
	ou = SelectX.ar(\distmix.kr(0), [ou, ou2]);
	ou = Splay.ar(ou, spread, amp, pan);

	ou = ou * EnvGen.ar(\adsr.kr(Env.adsr(0.01,0.1,0.8,0.1)),gate,doneAction:2);
	
	Out.ar(out, ou);
}, metadata:(specs:(
	finepos: ControlSpec(-0.001,0.001,\lin, 0, 1),
	range: ControlSpec(-0.01,0.01,\lin, 0, 1),
	adsr: \env -> [nil, nil, nil, nil, Env.adsr(0.01,0.1,0.8,0.1)],
	posenv: \env -> [nil, nil, nil, nil, Env([1,0,0.5,0.2, 0.2], [0.2,0.1,0.1,0.1])],
	fshift: ControlSpec(-2000,2000,\lin,0,0),
	spread: \unipolar.asSpec,
	lpmix: \unipolar.asSpec,
	pos: \unipolar.asSpec,
))).add;


(
	t = ~t;
~buf = BufDef(\moeten, "voices/02_moeten.flac");
Ndef(\lfo1).quant = Pdef.defaultQuant;
Ndef(\lfo3).quant = Pdef.defaultQuant;

Ndef(\lfo1, { arg freq=1; SinOsc.kr(freq * t).range(50,7500).lag(0.051)});
Ndef(\lfo1).put(1, \set -> Pbind(
	\freq, Pseq([1,1,16,1,1,8,1,1],inf),
	\dur, 1/8,
));

Ndef(\lfo3, { arg freq=20; freq.lag(0.101).round(0.1) * SinOsc.kr(1/16*~t).range(0.5,1.5).round(0.1)});
Ndef(\lfo3).put(1, \set -> Pbind(
	\freq, Pseq([
		2,2,2,2,
		2,4,4,6,
		2,2,2,2,
		2,4,4,6,
	]*50,inf),
	\dur, 1/4,
));

Pdef(\oscsampler, 
	Pbind(
		\instrument, \oscsampler3,
	\freq, 700,
	\pos, 0.412,
	\fshift, 148,
	\hpmix, 0.0,
	\hpfreq, 10,
	\rq, 0.1,
	\posenv, Pseq([
		//[ Env([0.42,0.3903,0.3513],[0.3,0.4]) ],
		[ Env([0.004,0.0009,0.0071].integrate.postln,[0.42,5.4]) ],
		[ Env([0.004,0.0019,0.0071].integrate.postln,[0.42,7.4]) ],
	],inf),
	\levelScale, 2,
	\timeScale, 1,
	\range, 0.0001,
	\ffreq, Ndef(\lfo1),
	\freq, Ndef(\lfo3).bus.asMap,
	\bufnum, ~buf,
	\ffreqtab, Pseq([[Array.geom(8,4.1,0.8).postln]],inf),
	\adsr, Pseq([
		[ Env.adsr(0.01,0.3,0.5,0.21) ],
	],inf),
	\legato, 1.0,
	\dur, 4,
	\isRest, Pseq([
		1,
	],inf).coin.not,
	\amp, 1 * Pkey(\amp),
)).play;
);


////////////////////////////////



(
	~buf = BufDef(\moeten, "voices/02_moeten.flac");
	Ndef(\lfo1).quant = Pdef.defaultQuant;
	Ndef(\lfo3).quant = Pdef.defaultQuant;

	Ndef(\lfo1, { arg freq=1; SinOsc.kr(freq * t).range(50,7500).lag(0.051)});
	Ndef(\lfo1).put(1, \set -> Pbind(
		\freq, Pseq([1,1,16,1,1,8,1,1],inf),
		\freq, 700,
		\dur, 1/1,
	));
	Ndef(\lfo3, { arg freq=20; freq.lag(0.401).round(0.1) * SinOsc.kr(1/16*t).range(0.5,1.5).round(0.1)});
	Ndef(\lfo3).put(1, \set -> Pbind(
		\freq, Pseq([
			2,2,2,2,
			2,4,4,6,
			2,8,2,2,
			2,4,4,6,
		]*250,inf),
		\dur, 1/4,
	));

	Pdef(\treb, 
		Pbind(
			\instrument, \oscsampler3,
			\freq, 700,
			\pos, 0.312,
			\fshift, 0,
			\fshift, -148,
			\lpmix, 0.01,
			\hpmix, 0.0,
			\hpfreq, 10,
			\rq, 0.1,
			\posenv, Pseq([
				[ Env([0.004,0.0019,0.3071].integrate.postln,[1.22,8.4]) ],
			],inf),
			\levelScale, 1,
			\timeScale, 1,
			\range, 0.00001,
			\ffreq, Ndef(\lfo1),
			\freq, Ndef(\lfo3).bus.asMap,
			\bufnum, ~buf,
			\ffreqtab, Pn(Plazy({
				[{ 2.rand } ! 8]
			})),
			\ffreqtab, Pseq([[Array.geom(8,4.1,0.8).postln]],inf),
			\adsr, Pseq([
				[ Env.adsr(0.01,0.3,0.5,0.21) ],
			],inf),
			\legato, 3.0,
			\dur, 1/4,
			\isRest, Pseq([
				0,0,0,0,
				0,0,0,0,
				0,0,0,0,
				0,0,1,0,
			],inf).coin.not,
			\amp, 5 * Pkey(\amp),
		)).play;
	)


////////////////////////////

(
~buf = BufDef(\moeten, "voices/02_moeten.flac");

Ndef(\lfo1).quant = Pdef.defaultQuant;
Ndef(\lfo3).quant = Pdef.defaultQuant;

Ndef(\lfo1, { arg freq=1; XLine.kr(1000,50,8) });
Ndef(\lfo1).put(1, \set -> Pbind(
	\freq, Pseq([1,1,16,1,1,8,1,1],inf),
	\freq, 700,
	\dur, 1/1,
));

Ndef(\lfo3, { arg freq=1; XLine.kr(1000,50,8) });
Ndef(\lfo3).put(1, \set -> Pbind(
	\freq, Pseq([
		2,2,2,2,
		2,4,4,6,
		2,8,2,2,
		2,4,4,6,
	]*250,inf),
	\dur, 1/4,
));

Pdef(\treb,
	Pbind(
		\instrument,\oscsampler3,
	\freq, 700,
	\pos, Pseq([0.0,0.01,0.02,0.03],inf),
	\pos, Pseg(Pseq([0,0.1],inf),32)+0.5,
	\pos, 0.312,
	\fshift, 0,
	\fshift, Pseq([0,48,-40],inf),
	\fshift, 748,
	\lpmix, 0.01,
	\hpmix, 0.0,
	\hpfreq, 10,
	\rq, 0.1,
	\posenv, Pseq([
		[ Env([0.004,0.0019,0.3071].integrate.postln,[1.22,8.4]) ],
		[ Env([0.004,0.0049,0.1071].integrate.postln,[0.02,2.4]) ],
	],inf).stutter(16),
	\levelScale, 1,
	\timeScale, 1,
	\range, 0.00001,
		\ffreq, Ndef(\lfo1),
		\freq, Ndef(\lfo3).bus.asMap,
	\bufnum, ~buf,
	\ffreqtab, Pseq([[Array.geom(8,4.1,0.8).postln]],inf),
	\adsr, Pseq([
		[ Env.adsr(0.01,0.3,0.5,0.21) ],
	],inf),
	\legato, 4.0,
	\dur, 1/4,
	\isRest, Pseq([
		0,0,0,0,
		1,0,0,0,
		0,0,0,0,
		0,0,0,0,
	],inf).coin.not,
	\amp, 5 * Pkey(\amp),
)).play;
)

///////////////////////////////////////


(
Ndef(\shifttreb).put(0, { arg pan=0, amp=0.1;

	var sig, sig1, sig2;
	var ffreq;
	var lfo1;
	var seq1;
	var seq2, seq3, seq4, seq5, seq6;
	var dscale = 4/~t;
	seq1 = Duty.ar(1/2*dscale, 0, Dseq([
		4,8,4,4, 1,8,1,8,
	]*~t,inf));
	seq2 = Duty.ar(1*dscale, 0, Dseq([80,50],inf)).lag(0.1);
	seq3 = Duty.ar(1/4*dscale, 0, Dseq([
		Dseq([0,1,3,4].midiratio * 400)
	],inf)).lag(0.1);
	seq4 = Duty.ar(1/4*dscale, 0, Dseq([
		1,2,1,4,
		1,1,2,2,

		1,2,1,4,
		1,4,1,2,

		1,2,1,4,
		1,1,2,2,

		1,1/2,4,1,
		1,1,2,2,
	],inf)).lag(0.1);
	seq5 = Duty.ar(1/2*dscale, 0, Dseq([
		1,1/2,4,1,
	]*~t,inf));
	sig = LFPulse.ar(seq3 * [1, SinOsc.ar(seq1).range(1,1.001)]);
	sig = sig * SinOsc.ar(seq1);
	sig1 = LPF.ar(sig, 100);
	sig1 = FreqShift.ar(sig1, seq3.lag(0.4)*seq4) + sig1;
	sig2 = HPF.ar(sig, 100);
	sig2 = RLPF.ar(sig, LFPulse.ar(seq1).range(100,1000));

	sig = sig2 + sig1;

	sig1 = LFPulse.ar(seq3 * [1, SinOsc.ar(seq1).range(1,1.001)], mul: SinOsc.kr(seq5).unipolar);
	sig1 = RLPF.ar(sig1, LFPulse.ar(seq5).range(100,2000));
	sig1 = sig1 / 1.3;
	sig = sig + sig1;
	//sig2 = FreqShift.ar(sig1, seq2);
	sig = Pan2.ar(sig, pan, amp).sum;


}).play;
)

////////////////////////////////////////////////

// freq spreading !!!!
// some cliping to reduce amp and at the same time add brightness
// legato > 1 to have nice blending effect
// Splay put the sound all around

(

SynthDef(\star, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3;
	var env1;
	var fspread;
	env1 = EnvGen.kr(Env([1,2,1],[1.7,0.8]), 1);
	fspread = 0.0007 + Rand(0,0.007);
	sig = SinOsc.ar(freq * ((0..7)/7 - 0.5 * fspread + 1));
	sig = sig * ( sig/(sig+1.1)*50 * env1 ).clip(0.5);
	sig1 = sig * (sig.abs > Rand(0.1,0.7));
	sig = SelectX.ar( EnvGen.kr(Env([0,1,0],[0.1+Rand(0,2.0),0.1+Rand(0,2.0)]), 1), [sig, sig1]);
	sig = sig * 2;
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(1.01,0.1,1,1.1)),gate,doneAction:doneAction);
	sig = sig /10;
	sig = Splay.ar(sig, spread, amp, pan);
	Out.ar(out, sig);
}).add;

Pdef(\treb, Pbind(
	\instrument,\star,
	//\freq, 100,
	\freq, (60 * Pseq([
		Prand([
			0,3,[0,4,7]
		],4) + Pseq([
			0,12
		]).stutter(4),
		Prand([
			7,10,[7,10]
		],4) + Pseq([
			0,12
		]).stutter(4),
		Prand([
			5,9,7
		],4) + Pseq([
			0,12
		]).stutter(4),
	],inf).midiratio * 16) * Prand([1,1/2,1/4,1],inf).stutter(4),
	\scale, Scale.minor,
	\octave, 4,
	\dur, 2,
	\legato, 3.5,
	\isRest, false,
	\amp, 0.1,
)).play;
)

(
Pdef(\treb, Pbind(
	\instrument, \star,
	//\freq, 100,
	\degree, Pseq([
		Pwalk(
			[
				0,2,4,9,0+12,2+12,4+12
			],
			Pseq([
				1,-2,Pwhite(0,3), Pwhite(0,-3)
			],inf),
		),
	],inf),
	\mtranspose, 3,
	\scale, Scale.minor,
	\octave, 4,
	\dur, 2,
	\legato, 3.5,
	\isRest, false,
)).play;
)

// more piano
(
Pdef(\treb, Pbind(
	\instrument,\star,
	//\freq, 100,
	\degree, Pseq([
		Pwalk(
			[
				0,2,4,0+12,2+12,4+12, [0,2,4]+12
			],
			Pseq([
				1,-2,Pwhite(0,3), Pwhite(0,-3)
			],inf),
		),
	],inf),
	//\root, Pstep(Pseq([0,5,7,5],inf),4),
	//\root, Pstep(Pseq([0,4,2,5],inf),4),
	\mtranspose, Pstep(Pseq([0,4,2,5],inf),4),
	\scale, Scale.major,
	\octave, 4,
	\dur, 1/4,
	\lag, Pseq([0,1/4 + Pwhite(0,0.01,1)],inf) / ~t,
	\adsr, Pseq([
		[ Env.adsr(0.5,0.1,1.8,0.8) ],
	],inf),
	\legato, 0.5,
	\isRest, false,
)).play;
)

(
Pdef(\treb, Pbind(
	\instrument, Pseq([\starlet,\star, Prand([\starlet,\star],2)],inf).stutter(1),
	//\freq, 100,
	\degree, Pseq([
		Pwalk(
			[
				[0,2,4, 7],
				[0,2,4, 9],
				0,2,4,
				[0,2+12],
				[0,4+12],
				0+12,2+12,4+12,
				[2,4],
			],
			Prand([
				Pseq([
					1,-2,Pwhite(0,3,1), Pwhite(0,-3,5),
				],1),
				Pseq([
					1,-2,Pwhite(0,3,1), Pwhite(0,-3,1),
				],1),
				Pseq([
					Pwhite(0,3,8),
				],1),
			],inf),
		),
	],inf),
	//\root, Pstep(Pseq([0,5,7,5],inf),4),
	//\root, Pstep(Pseq([0,4,2,5],inf),8),
	//\root, Pstep(Pseq([0,1,0,2],inf),12),
	\mtranspose, Pstep(Pseq([5,4,2,3],inf),4),
	//\mtranspose, Pstep(Pseq([0,3,4,3],inf),8),
	//\ctranspose, Pstep(Pseq([0,5,7,5],inf),4),
	\scale, Scale.major,
	\octave, 4,
	\dur, 1/4,
	\lag, 
		Pseq([
			Pseq([0,0],8) / ~t,
			Pseq([0,1/4 + Pwhite(0,0.01,1)],4) / ~t,
			Pseq([0,0],4) / ~t,
			Pseq([0,1/2 + Pwhite(0,0.01,1)],4) / ~t,
			Pseq([0,0],4) / ~t,
			Pseq([0,1/8 + Pwhite(0,0.01,1)],4) / ~t,
			Pseq([0,0],Pwhite(4,8,1)) / ~t,
			Pseq([0,1/8 + Pwhite(0,0.05,1)],Pwhite(4,8,1)) / ~t,
		],inf),
	\adsr, Pseq([
		Prand([
			[ Env.adsr(0.005,0.1,1.0,1.8) ],
			//[ Env.adsr(0.015,0.1,1.8,1.8) ],
			//[ Env.adsr(0.005,0.1,1.8,1.4) ],
			//[ Env.adsr(0.005,0.1,1.8,1.0) ],
			//[ Env.adsr(0.005,0.1,1.8,2.0) ],
		],1),
	],inf),
	\legato, 0.2,
	\isRest, false,
)).play;
)

(
Pdef(\treb, Pbind(
	\instrument, \star,
	\degree, Pseq([
		Pwalk(
			[
				[0,2,4, 7],
				[0,2,4, 9],
				0,2,4,
				[0,2+12],
				[0,4+12],
				0+12,2+12,4+12,
				[2,4],
			],
			Pseq([
				1,-2,Pwhite(0,3), Pwhite(0,-3)
			],inf),
		),
	],inf),
	\mtranspose, Pstep(Pseq([5,4,2,3],inf),4),
	\scale, Scale.major,
	\octave, 4,
	\dur, 1/4,
	\lag, 
		Pseq([
			Pseq([0,0],8) / ~t,
			Pseq([0,1/4 + Pwhite(0,0.01,1)],4) / ~t,
			Pseq([0,0],4) / ~t,
			Pseq([0,1/2 + Pwhite(0,0.01,1)],4) / ~t,
			Pseq([0,0],4) / ~t,
			Pseq([0,1/8 + Pwhite(0,0.01,1)],4) / ~t,
		],inf),
	[\adsr, \legato], 
	Pseq([
		[
			[ Env.adsr(0.005,0.1,1.8,1.8) ],
			0.2,
		],
		Ptuple([
			[ Env.adsr(0.005,0.1,1.8,0.1) ],
			Pfuncn({ arg ev;
				ev[\degree].debug("degree");
				[
					1.2,
					0.5,
					0.1,
				];
				1.2;
			},1)
		]).trace,
	],inf),
	\isRest, false,
)).play;
)

//////////

(
SynthDef(\starb, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3;
	sig = {arg x; SinOsc.ar( freq/2 * x + ExpRand(freq/64,2*freq/64))}!9;
	sig = sig.scramble;
	sig = TScramble.ar(sig, Impulse.kr(4),1);
	sig = FreqShift.ar(sig, 4 * SinOsc.kr(1/45).range(0,1)) + sig;
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(1.01,0.1,1,1.1)),gate,doneAction:doneAction);
	sig = sig /10;
	sig = Splay.ar(sig, spread, amp, pan);
	Out.ar(out, sig);
}).add;

Pdef(\treb, Pbind(
	\instrument,\starb,
	//\freq, 100,
	\freq, (60 * Pseq([
		Prand([
			0,3,[0,4,7]
		],4) + Pseq([
			0,12
		]).stutter(4),
		Prand([
			7,10,[7,10]
		],4) + Pseq([
			0,12
		]).stutter(4),
		Prand([
			5,9,7
		],4) + Pseq([
			0,12
		]).stutter(4),
	],inf).midiratio * 16) * Prand([1,1/2,1/4,1],inf).stutter(4),
	\scale, Scale.minor,
	\octave, 4,
	\dur, 2,
	\legato, 3.5,
	\isRest, false,
	\amp, 0.1,
)).play;
)

/////////////

(
SynthDef(\starlet, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3;
	var env1;
	var fspread;
	env1 = EnvGen.kr(Env([1,20,1],[1.7,0.8]), 1);
	fspread = 0.0007 + Rand(0,0.007)* env1;
	sig = SinOsc.ar(freq * ((0..7)/7 - 0.5 * fspread + 1) );
	sig1 = sig * ( sig/(sig+1.1)*50 * env1 ).clip(0.5);
	sig = SelectX.ar(\mix.kr(0.5), [sig, sig1]);
	sig = sig * 2;
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(1.01,0.1,1,1.1)),gate,doneAction:doneAction);
	sig = sig /10;
	sig = Splay.ar(sig, spread, amp, pan);
	Out.ar(out, sig);
}).add;

Pdef(\treb, Pbind(
	\instrument,\starlet,
	//\freq, 100,
	\mix, Pseg(Pseq([0,1],inf),Prand([8,3]*3,inf)),
	\freq, (60 * Pseq([
		Prand([
			0,3,[0,4,7]
		],4) + Pseq([
			0,12
		]).stutter(4),
		Prand([
			7,10,[7,10]
		],4) + Pseq([
			0,12
		]).stutter(4),
		Prand([
			5,9,7
		],4) + Pseq([
			0,12
		]).stutter(4),
	],inf).midiratio * 16) * Prand([1,1/2,1/4,1],inf).stutter(4),
	//\freq, Pseq([1000,330],inf),
	\scale, Scale.minor,
	\octave, 4,
	\dur, 2,
	\legato, 3.5,
	\isRest, false,
	\amp, 0.1,
)).play;
)
///////////////////////////////
//////////////////////////////////////////////////////////////////


(
Ndef(\trebfx).put(0, { arg amp=0.1;
	var sig;
	var freq;
	var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
	var trig;
	var lpfenv;

	trig = TDuty.kr(1/~t, 0, Dseq([
		1,0,0,0, 1,0,0,0,
		1,0,1,0, 1,0,1,0,
	],inf));

	freq = EnvGen.kr(
		Env([410,221,270,120.12],[4.1,0.8,8.1], [-4]) , trig, timeScale:0.1) 
		* TRand.kr(0.3,1.5, trig);
	//freq =  TChoose.kr(trig, [500,250,750]) + TRand.kr(0.3,8.5, trig);
	freq = freq * [1,1+EnvGen.kr(Env([1,2,1]/100,[4.1,8.8], trig)),-3.midiratio + TRand.kr(0.000,0.001, trig)];
	
	sig1 = LFSaw.ar(freq);
	sig2 = LFPulse.ar(freq);
	sig3 = SinOsc.ar(freq);
	sig = SelectX.ar( EnvGen.kr(Env([2,1,0],[1.1,0.8]), trig, timeScale:0.1), [sig1, sig2, sig3]);

	lpfenv = EnvGen.kr(Env([1,TRand.kr(0.7,2.6,trig),1],[TRand.kr(0.1,1.6,trig),0.8]), trig, timeScale:0.1);
	sig1 = RLPF.ar(sig, TRand.kr(400,12000,trig) * lpfenv + 0.5, \rq.kr(0.5));
	sig = SelectX.ar(\lpmix.kr(0.5), [sig, sig1]);

	sig = sig * EnvGen.ar(Env.adsr(0.1,0.4,0.4,0.1),Trig.kr(trig,0.1),doneAction:0);
	amp = amp * \gain.kr(1) * 4;
	sig = Splay.ar(sig, \spread.kr(0.8), amp, \pan.kr(0));
	sig;
}).play;

Ndef(\trebfx).put(50, \filter -> { arg in;
	var sig = in;
	//sig = AllpassL.ar(sig, 4, 1/8/~t * SinOsc.kr(1/45).range(0.9,1.1),14) + sig;
	//sig = AllpassL.ar(sig, 4, 1/4/~t * SinOsc.kr(1/25).range(0.9,1.1),8) + sig;
	sig = AllpassL.ar(sig, 4, SinOsc.kr(1/45).unipolar(0.03) + 1 * 1/9/~t ,18) + sig;
	
	sig;
});

);
///////////////////////////////////////////////////////
(
SynthDef(\distbass, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3;
	freq = SinOsc.ar(freq*\fmfreq.kr(1).lag(0.3)) * \fmrange.kr(0.5).lag(0.3) * LFNoise1.kr(1/7).range(0.9,1.1) + 1 * freq;
	sig = SinOsc.ar(freq.lag(0.1) * [1,8,2,4,1.002]);
	sig1 = LFPulse.ar(freq * [1,4,1.001,2 * LFNoise1.kr(1/10).range(0.999,1.001),1/2], mul:1.00);
	sig = sig + sig1;
	sig = sig.fold2(SinOsc.kr(1/13).range(0.9,1));
	sig = sig.wrap2(SinOsc.kr(1/14).range(0.9,1));
	sig = RLPF.ar(sig, \lpf.kr(500).lag(0.4) * LFNoise1.kr(1/9).range(0.9,1.1), \rq.kr(0.5));
	sig = HPF.ar(sig, \hpf.kr(40));
	sig = sig * EnvGen.ar(\iadsr.kr(Env.adsr(0.01,0.1,0.8,0.1)),\igate.kr(1),doneAction:0);
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.01,0.1,0.8,0.1)),gate,doneAction:doneAction);
	sig = Splay.ar(sig, spread, amp, pan);
	Out.ar(out, sig);
}).add;


Pdef(\treb, Pmono(\distbass,
	\freq, 70 * Pseq(( [0,1]+(2*12) ).midiratio,inf).stutter(16),
	\fmrange, Pseq([0.5,1,1.5],inf),
	\fmfreq, Pseq([0.5,1,2,4],inf),
	\dur, 1/4,
	\igate, Pseq([
		1,0,0,0,
		0,0,0,0,
	],inf),
	\iadsr, Pseq([
		[ Env.adsr(0.1,0.1,0.8,4.1) ],
	],inf),
	\lpf, Pkey(\freq) * Pseq([2,1,4,8],inf).stutter(8),
	\hpf, Pkey(\freq) / 2,

	\amp, Pkey(\amp) * 2,
	\isRest, false,
)).play;
)

//////////////
(
SynthDef(\distreb, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3;
	freq = SinOsc.ar(freq*\fmfreq.kr(1).lag(0.3)) * \fmrange.kr(0.5).lag(0.3) * LFNoise1.kr(1/7).range(0.9,1.1) + 1 * freq;
	sig = SinOsc.ar(freq.lag(0.1) * [1,8,2,4,1.002]);
	sig1 = LFPulse.ar(freq * [1,4,1.001,2 * LFNoise1.kr(1/10).range(0.999,1.001),1/2], mul:1.00);
	sig = sig + sig1;
	sig = sig.fold2(SinOsc.kr(1/13).range(0.9,1));
	sig = sig.wrap2(SinOsc.kr(1/14).range(0.9,1));
	sig = RLPF.ar(sig, \lpf.kr(500).lag(0.4) * LFNoise1.kr(1/9).range(0.9,1.1), \rq.kr(0.5));
	sig = HPF.ar(sig, \hpf.kr(40));
	sig = sig * EnvGen.ar(\iadsr.kr(Env.adsr(0.01,0.1,0.8,0.1)),Trig.kr(\itrig.tr(1), \tsustain.kr(0.1)),doneAction:0);
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.01,0.1,0.8,0.1)),gate,doneAction:doneAction);
	sig = Splay.ar(sig, spread, amp, pan);
	Out.ar(out, sig);
}).add;
)
(
Pdef(\treb, Pmono(\distreb,
	\freq, 70 * Pseq(( [0,1]+(2*12) ).midiratio,inf).stutter(16*2),
	\fmrange, Pseq([0.5,1,1.5],inf),
	\fmfreq, Pseq([0.5,1,2,4],inf),
	\dur, 1/8,
	\itrig, Pseq([
		1,0,0,0,
		0,0,0,0,
		0,0,0,0,
		0,0,0,0,

		0,0,0,0,
		1,0,0,0,
		1,1,1,1,
		1,0,1,1,
	],inf),
	\iadsr, Pseq([
		Prand([
			Pseq([
				Prand([
					[ Env.adsr(0.01,0.1,0.8,0.14) ],
					[ Env.adsr(0.01,0.1,0.8,0.04) ],
				],1),
			],16),
			Pseq([
				[ Env.adsr(0.01,0.1,0.8,2.04) ],
			],16),
			Pseq([
				Pfuncn({
					[ Env.adsr(0.01,0.1,0.8,2.44.rand) ]
				},1),
			],16),
		],1),
		Prand([
			Pseq([
				[ Env.adsr(0.01,0.1,0.8,0.04) ],
			],8),
			Pseq([
				Pfuncn({
					[ Env.adsr(0.01,0.1,0.8,2.44.rand) ]
				},1),
			],8),
		],1),
		Pseq([
			[ Env.adsr(0.01,0.1,0.8,0.04) ],
		],8),
	],inf),
	\xlegato, Pseq([
		1,0.3,0.3,0.3, 
		1,1,1,1,
		0.1,0.1,1,1, 
		1,0.1,1,1,
	],inf)+0.1,
	\tsustain, Pkey(\dur) * Pkey(\xlegato)/~t,
	\lpf, Pkey(\freq) * Pseq([2,1,4,8],inf).stutter(2),
	\hpf, Pkey(\freq) / 2,

	\amp, Pkey(\amp) * 2,
	\isRest, false,
)).play;
)

///////////////////////////


(
Ndef(\treb).put(0, { arg amp=0.1;
	var sig;
	var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;

	var freq;
	var lpspread;
	var env1, env2, env3;
	var trig;

	trig = Impulse.kr(1/8*~t);
	env1 = EnvGen.kr(Env([0,1,0],[0.01,9.8],[0,-2]), trig);

	freq = 140 * [-1,5,15,10,20].midiratio;
	freq = freq *.t [1,TChoose.kr(trig, [4,2,1,1/2]),TRand.kr(0,0.01, trig)+1,1/2,TRand.kr(0,0.01, trig) + TChoose.kr(trig, [4,2,1,1/2]),1.001,2];
	freq = freq.flatten;
	freq = env1/100 + 1  * freq;

	sig1 = LFSaw.ar(freq);
	sig2 = LFPulse.ar(freq);
	sig3 = SinOsc.ar(freq);
	sig = SelectX.ar(LFNoise1.kr(0.5).unipolar*2 * env1, [sig1, sig2, sig3]);
	//sig = SelectX.ar(0.3, [sig1, sig2, sig3]);

	sig1 = sig.fold2( SinOsc.kr(1/4/(1..11)).range(0.1,2) * env1);
	sig2 = sig.wrap2( SinOsc.kr(1/4/(1..11).reverse).range(0.1,2) * env1);
	sig = SelectX.ar( LFNoise1.kr(1/2).range(0.0,1.0)*2, [sig, sig1, sig2]);

	sig = sig * SinOsc.kr(1/3/(1..10)).pow(2).range(0,1);

	lpspread = SinOsc.kr(1/5*(1..11)/9)*1.5;
	lpspread = (env1/3 + 0.01).exp;
	//lpspread = 0;
	sig = RLPF.ar(sig, \lpf.kr(400) * (env1 + 1), \rq.kr(0.5));
	sig = HPF.ar(sig, 700);
	sig = sig * 2;
	sig.postln;

	
	amp = amp * \gain.kr(1);
	sig = Splay.ar(sig, \spread.kr(0.2), amp, \pan.kr(0));

	sig = sig * env1;

	sig;
}).play;

)

/////////////////////////////////////////


(
SynthDef(\treb, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3;
	var env;
	freq = freq.lag(\flag.kr(0.1));
	env = EnvGen.ar(Env([0.1,1.1,4.4],[0.01,1]),gate,doneAction:0);
	//sig = SinOsc.ar(freq * [1,1.001]);
	//sig = sig + LFPulse.ar(freq * [1,1.001]);
	sig1 = SinOsc.ar(freq, SinOsc.kr(XLine.kr(1000,0.001,0.11)));
	sig = SinOsc.ar(freq * [1,1/2,2,1.001], sig1 * \ampB.kr(1));
	sig = SelectX.ar(\select1.kr(0.5), [sig, sig1]);

	sig = LeakDC.ar(sig);
	sig = RLPF.ar(sig, (freq*[1.01,2.1,2,1] * \lfratio.kr(1)).clip(10,18000));
	sig = sig * EnvGen.ar(\iadsr.kr(Env.adsr(0.01,0.1,0.8,0.01)),\igate.kr(1),doneAction:0);
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.01,0.1,0.8,0.01)),gate,doneAction:doneAction);
	sig = Splay.ar(sig, spread, amp, pan);
	Out.ar(out, sig);
}).add;
)

(
Ndef(\lfo1, { 
	var freq = Duty.kr(2/~t,0,Dseq([4,8,2,1],inf));
	SinOsc.kr(freq / ~t / 4 ).range(0,10)  
});
Ndef(\lfo1).quant = Pdef.defaultQuant;

Ndef(\lfo2, { 
	var freq = Duty.kr(2/~t,0,Dseq([4,8,2,1],inf));
	SinOsc.kr(freq / ~t / 4 ).range(0,1)  
});
Ndef(\lfo2).quant = Pdef.defaultQuant;

Pdef(\treb, PmonoArtic(\treb,
	//\freq, Pseq([])462,
	\degree, Pseq([
		-3,0,-8,0,
		-3,0,4,0,
	],inf).stutter(4),
	\freq, Pstep(Pseq([200,220,210,230],inf),4),
	\freq, Pstep(Pseq([200,220,210,230],inf),4) * Pseq([1,2,1,1, 0.5,2,1,4],inf).stutter(6) * 2,
	\octave, 6,
	\adsr, Pseq([
		[ Env.adsr(0.01,0.1,0.8,0.04) ],
	],inf),
	\iadsr, Pseq([
		[ Env.adsr(0.01,0.1,0.8,0.04) ],
		[ Env.adsr(0.01,0.1,0.8,0.14) ],
	],inf),
	\legato, 1,
	\ampB, 1000.01,
	\ampB, 0.01,
	\dur, 1/8,
	\select1, 0,
	\ampB, Ndef(\lfo1),
	\select1, Ndef(\lfo2),
	\lfratio, 9,
	\igate, Pseq([
		1,0,1,1, 0,0,1,0,
		1,0,0,0, 1,0,0,0,
		1,0,0,0, 1,0,0,0,
		1,0,1,1, 0,0,1,0,
	],inf),
	\isRest, Pseq([1,1,1,1],inf).coin.not,
)).play;
)

///////////////////////////////////////////////

(
Ndef(\clochete, { arg freq=200, pan=0, amp=0.1;
	var sig;
	var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
	sig = SinOsc.ar(freq);
	sig1 = Dust.ar(10 * SinOsc.kr(1/8).range(10,1/2));
	sig1 = Ringz.ar(sig1, rrand(100,10000.0!8) * LFNoise0.kr(1/2).range(1/4,1), 1.1).mean/2;
	sig2 = Dust.ar(7);
	sig2 = Ringz.ar(sig2, rrand(100,10000.0!8), 1.1).mean/2;
	sig = sig1 + sig2;
	sig = Pan2.ar(sig, pan, amp);
}).play(BusDef(\mixer5).index, 2);
);

(
SynthDef(\clochete, { arg out=0, gate=1, freq=200, pan=0, amp=0.1;
	var sig;
	var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
	sig = SinOsc.ar(freq);
	sig1 = Dust.ar(10 * SinOsc.kr(1/8).range(10,1/2));
	sig1 = Ringz.ar(sig1, rrand(100,10000.0!8) * LFNoise0.kr(1/2).range(1/4,1), 1.1).mean/2;
	sig2 = Dust.ar(7);
	sig2 = Ringz.ar(sig2, rrand(100,10000.0!8), 1.1).mean/2;
	sig = sig1 + sig2;
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * EnvGen.kr(\adsr.kr(Env.adsr(0.1,0.1,0.8,0.1)), gate, doneAction:2);
	Out.ar(out, sig);
}).add;
);

(
Pdef(\treb, 
	Pbind(
		\instrument, \clochete,
		\degree, Pseq([0],inf),
		\dur, 1,
		\amp, 0.1,
	)
).play;
);


//////////////////////////////////////////
// bits


(
Ndef(\bitshift, {
	var t = PulseCount.ar(Impulse.ar(8e3));
	var sig = HPF.ar(
		(  
			((t * 15) & (t >> 5)) |
			((t * 5) & (t >> [3, 4])) |
			((t * 2) & (t >> 9)) |
			((t * 8) & (t >> 11))
			- 3 % 256
		) / 127-1 * 3
		, 20
	).distort * 0.2; 
	sig/4;
	//sig = Greyhole.ar(sig, sig, 0.5, sig).flop.mean/4;
}).play;
)


//////////////////////////////////////////


(
SynthDef(\fmbell, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
	freq = freq * EnvGen.kr(Env([1,1.002,0.998,1],[0.1,0.8]), 1);
	sig1 = SinOsc.ar(freq * 2.6706 + 0.13) * 2 + 1; 
	sig2 = SinOsc.ar(freq * 0.9998 * sig1);
	sig3 = SinOsc.ar(freq * 2.6629 * sig1 + 2.04);
	sig4 = LFCub.ar(freq * 0.9991 * sig1 + 2.14);
	sig5 = SinOsc.ar(freq * 2.6656 * sig1 - 2);
	sig6 = SinOsc.ar(freq * 1 * sig1 + 1.84);
	//sig = sig2 + sig3 + sig4 + sig5 + sig6;
	sig = [sig1, sig2, sig3, sig4, sig5, sig6] * DC.ar([0,0.5,0.5, 0.5,0.5,0.5]);
	//sig.debug("sig");
	//sig = sig /34;
	sig = sig * EnvGen.ar(Env.adsr(0.01,0,1,2.1,1,-1),gate,doneAction:2);
	sig = Pan2.ar(sig, pan + [ 0, -0.5, -0.5, 0.5, 0.5, 0], amp).sum;
	Out.ar(out, sig);
}).add;
);

(
SynthDef(\chorus, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var in = InFeedback.ar(\inbus.kr(BusDef(\zero, \audio)), 2); 
	sig = LocalIn.ar(2) * \fb.kr(0.4);
	sig = sig + in;
	sig = DelayC.ar(sig, \maxdelay.ir(0.2), \delay.kr(0.0101) * ((0..7)/7 - 0.5 * \diff.kr(0.4001) + 1) * ( SinOsc.kr(\modfreq.kr(8.1)) * \modamp.kr(0.48) + 1 )).mean;
	//sig = LPF.ar(sig, \dif.kr(7500));
	LocalOut.ar(sig);

	sig = LPF.ar(sig, \lpf.kr(15000));
	sig = HPF.ar(sig, \hpf.kr(50));
	sig = SelectX.ar(\mix.kr(0.5), [in, sig]);
	sig = sig * EnvGen.ar(\adsr.kr( Env.adsr(0.01,0.1,0.8,0.1) ),gate,doneAction:2);
	Out.ar(out, sig);
}).add;
);


(
Pdef(\demo, Pdef(\demotreb, 
	Ppar([
		Pbind(
			\instrument, \fmbell,
			\note, Pseq([
				2,9,5,-4,
			],inf),
			\octave, 4,
			\sustain, 0.1,
			\dur, 1,
			\out, BusDef(\fx1, \audio),
			\amp, 0.1,
		),
		Pmono(\chorus,
			\inbus, BusDef(\fx1, \audio),
			\freq, 200,
			\dur, 1,
			\amp, 0.1,
		),
	])
)).play;
)

//////////////////////////////////



(
Pdef(\demo, Pdef(\demomo, 
	Ppar([
		20.collect({ arg n;
			
		Pbind(
			\instrument, \default,
			\note, Pseq([
				n*1,
				n*2,
				n*3,
			],inf),
			\dur, 1 + 0.1.rand,
			\amp, 0.1,
		);
		})
	].flat)
)).play;
)

////////////////////////////////
(
SynthDef(\crackle, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	sig = Crackle.ar(\chaos.kr(1));
	sig = Formlet.ar(sig, freq,\format.kr(0.21),\formdec.kr(0.1));
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,0.1),gate,doneAction:2);
	sig = HPF.ar(sig, 50);
	sig = Limiter.ar(sig);
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
);

(
Pdef(\demo, Pdef(\demomo, 
	Ppar([
		Pmono(\crackle,
			\chaos, 1.93500,
			\note, Pseq([
				1,3,12,4,
			],inf).stutter(2),
			\octave, 5,
			\format, Pseq([
				1,2,3,4,5
			],inf)/4,
			\formdec, 0.03 * Pseq([
				1,1,1,2,2,20,3
			],inf),
			\dur, 1/2,
			\amp, 0.1,
		),
	])
)).play;
)

(
SynthDef(\crackle2, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	sig = Crackle.ar(\chaos.kr(1));
	sig = LFSaw.ar(freq * ( sig* 10.1 + 1 )); 
	//sig = Formlet.ar(sig, freq,\format.kr(0.21),\formdec.kr(0.1));
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,0.1),gate,doneAction:2);
	sig = HPF.ar(sig, 50);
	sig = Limiter.ar(sig);
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
Pdef(\part2).reset;
);

(
Pdef(\demo, Pdef(\demomo, 
	Ppar([
		Pmono(\crackle2,
			\chaos, 1.93500,
			\note, Pseq([
				1,3,12,4,
			],inf),
			\octave, 5,
			\format, Pseq([
				1,2,3,4,5
			],inf)/4,
			\formdec, 0.03,
			\dur, 1,
			\amp, 0.1/2,
		),
	])
)).play;
)


(
SynthDef(\cracksoft, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	env1 = EnvGen.kr(\env.kr(Env([1,2,1],[0.1,0.8])), 1);
	sig = Crackle.ar(\chaos.kr(1));
	sig = LFSaw.ar(freq * [1/2,1,2,1.001,2.0001] * ( sig* \modamp.kr(1.1)  + 1 )); 
	//sig = Formlet.ar(sig, freq,\format.kr(0.21)* env1,\formdec.kr(0.1));
	sig = LPF.ar(sig, \lpf.kr(300) * env1);
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,1.4),gate,doneAction:2);
	sig = HPF.ar(sig, \hpf.kr(50));
	sig = Limiter.ar(sig);
	sig = Pan2.ar(sig, pan, amp).mean;
	Out.ar(out, sig);
}).add;
);

(
Pdef(\demo, Pdef(\plop2, 
	Ppar([
		Pbind(
			\instrument, \cracksoft,
			\chaos, 1.93500,
			\note, Pseq([
				[1,3,9],
				//[1,3,9],
				//[1,3,9],
				//[1,3,9]+4,
			],inf),
			\lpf, ~pmodenv.(Pseq([100,2000,4001],inf), 8),
			\legato, Pseq([
					7,0,0,0, 0,0,0,1,
			],inf)*0.7,
			\isRest, Pfunc({ arg ev; ev[\legato] <= 0 }),
			\octave, 5,
			\format, Pseq([
				1,2,3,4,5
			],inf)/14,
			\formdec, 0.3,
			\dur, 1,
			\amp, 0.3,
		),
	])
)).play;
)
Pdef(\part2).clear


/////////////////////////



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
Pdef(\demo, Pdef(\xdemo, 
	Ppar([
		Pbind(
			\instrument, \iron,
			\note, Pseq([
				1,0,
			],inf),
			\dur, 1,
			\fmr,1,
			\diff, 1,
			\rq, 0.7,
			\gain, 5,
			\amp, 0.1,
		);
		
	])
)).play;
)
(
Pdef(\demo, Pdef(\xdemo, 
	Ppar([
		Pmono(\iron,
			\note, Pseq([
				0,2,7,0,
			],inf),
			\lpfr, 1,
			\trigenv, 1,
			\fmamp, 1.5,
			\dur, 1,
			\amp, 0.1,
		),
	])
)).play;
)

Pdef(\demo).clear
(
Pdef(\demo, Pdef(\xdemo, 
	Ppar([
		Pbind(
			\instrument, \iron,
			\note, Pseq([
				1,0,
			],inf),
			\octave, 4,
			\dur, 1,
			\fmr,1/8,
			\fmamp, 00.1,
			\lpfr, 1,
			\diff, 1.01,
			\foldbias, 1.5,
			\foldlevel, 1.5,
			\rq, 0.7,
			\gain, 15,
			\amp, 0.1,
		);
		
	])
)).play;
)

(
Pdef(\demo, Pdef(\xdemo, 
	Ppar([
		Pmono(\iron,
			\note, Pseq([
				0,2,1,0,
			],inf),
			\octave, 6,
			\env1, Pseq([
				[ Env([1,2,1],[0.1,0.8]) ]
			],inf),
			\gain,8,
			\fmr, 1/8,
			\lpfr, 1,
			\rq, 0.1,
			\foldbias, -1.5,
			\foldlevel, 1.5,
			\diff, 0.02 * Pseq([1,1/10],inf),
			\trigenv, 1,
			\fmamp, 1.5,
			\dur, 1,
			\amp, 0.1,
		),
	])
)).play;
)


(
	//skank
Pdef(\demo, Pdef(\plopix, 
	Ppar([
		Pbind(
			\instrument, \iron,
			\note, Pstep(Pseq([
				0,0,0,-1,
			],inf),1/2) + [0,3,7],
			\octave, Pseq([
				5,
			],inf),
			\hpf, 30,
			\env1, Pseq([
				[ Env([1,1.5,1],[0.1,0.8]) ]
			],inf),
			\diff, 1/Pseq([
				1
			],inf),
			\fmr, 2,
			\lpfr,4,
			\adsr, Pseq([
				[ Env.adsr(0.01,0.01,0.8,0.1) ],
			],inf),
			\lag, 0.04,
			\legato, Pseq([
				0,0,4,0, 10,0,2,0, 0,0,0,0, 10,0,1,0,
				0,0,4,0, 10,0,20,0, 0,0,0,0, 10,0,10,0,
				0,0,0,0, 10,0,20,0, 0,0,1,0, 1,0,10,0,
			],inf)/10*2,
			\isRest, Pfunc({ arg ev; ev[\legato] <= 0 }),
			\dur, 1/16,
			\amp,0.02,
		),
	])
)).play;
)
// skank2
(
Pdef(\part, Pdef(\plop, 
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
		Pbind(
			\instrument, \iron,
			\note, Pstep(Pseq([
				0,0,0,-1,
			],inf),1/2) + [0,3,7],
			\octave, Pseq([
				6,5,7,8,6,
			],inf),
			\hpf, 30,
			\env1, Pseq([
				[ Env([1,1.5,1],[0.1,0.8]) ]
			],inf),
			\diff, 1/Pseq([
				1,8,5,10,0.5
			],inf),
			\fmr, 2,
			\lpfr,4,
			\adsr, Pseq([
				[ Env.adsr(0.01,0.01,0.8,0.1) ],
			],inf),
			\lag, 0.04,
			\legato, Pseq([
				0,0,6,0, 1,0,1,0, 0,0,0,0, 4,0,1,0,
				0,0,0,0, 4,0,0,0, 0,0,0,0, 1,0,0,0,
				0,0,0,0, 1,0,0,0, 0,0,0,0, 4,0,1,0,
				0,0,0,0, 10,0,0,0, 0,0,1,0, 1,0,0,0,
			],inf)/10*2,
			\isRest, Pfunc({ arg ev; ev[\legato] <= 0 }),
			\dur, 1/16,
			\amp,0.02,
		),
		Pbind(
			\instrument, \default,
			\note, Pstep(Pseq([
				0,0,0,-1,
			],inf),1/2) + [0,3,7],
			\octave, 7,
			\hpf, 30,
			\env1, Pseq([
				[ Env([1,1.5,1],[0.1,0.8]) ]
			],inf),
			\diff, 1/Pseq([
				20,
			],inf),
			\fmr, 2,
			\lpfr,4,
			\adsr, Pseq([
				[ Env.adsr(0.01,0.01,0.8,0.1) ],
			],inf),
			\lag, 0.04,
			\legato, Pseq([
				0,1,
			],inf)/10*2,
			\isRest, Pfunc({ arg ev; ev[\legato] <= 0 }),
			\dur, 1/4,
			\amp,0.051,
		),
		
	])
)).play;
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


////////////////
// simple acid

(
	// aka silead
SynthDef(\simpleacid, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	env1 = EnvGen.kr(\env1.kr(Env([1,2,1],[0.01,0.8])), 1);
	sig = LFSaw.ar(freq + [ [0,0.0001] ] * [1,1/2,2]).sum;
	sig.debug("sig");
	sig = RLPF.ar(sig, \lpfr.kr(2.1) * freq * env1, \rq.kr(0.5));
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,0.1),gate,doneAction:2);
	//sig = Pan2.ar(sig, pan, amp);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)


(
Pdef(\demo, 
	Ppar([
				Pbind(
					\instrument, \simpleacid,
					//\out, BusDef(\fx2),
					\env1, Pseq([
						Pseq([
							[ Env([1,2,1],[0.01,0.8]) ],
							[ Env([1,2,1],[0.1,0.8]) ],
						],8),
						Pseq([
							[ Env([1,2,1],[0.01,0.8]) ],
							[ Env([1,2,1],[0.01,0.2]) ],
						],4),
						Pseq([
							[ Env([1,2,1],[0.01,0.6]) ],
							[ Env([1,2,1],[0.1,0.8]) ],
							[ Env([1,2,1],[0.01,0.8]) ],
						],8),
					],inf),
					\lpfr, ~pmodenv.(Pseq([1,2,1,4]/2,inf), Pseq([4],inf)),
					\rq, ~pmodenv.(Pseq([0.1,0.2,0.1,0.4]/2,inf), Pseq([4],inf)),
					\note, Pseq([
						[1+12, 7], 
					],inf),
					\octave, 6,
					\legato, Pseq([
						Pser([
							0.2,0.7,
						],12),
						Pser([
							2,1,1,1,
						],4),
					],inf) * Pseg(Pseq([0.4,1,0.2,0.8],inf),8),
					\dur, 1/8,
					\amp, 0.011,
				),
	])
).play;
)

(
Pdef(\demo, 
	Ppar([
				Pbind(
					\instrument, \simpleacid,
					//\out, BusDef(\fx2),
					\env1, Pseq([
						Pseq([
							[ Env([1,2,1],[0.01,0.8]) ],
							[ Env([1,2,1],[0.1,0.8]) ],
						],8),
						Pseq([
							[ Env([1,2,1],[0.01,0.8]) ],
							[ Env([1,2,1],[0.01,0.2]) ],
						],4),
						Pseq([
							[ Env([1,2,1],[0.01,0.6]) ],
							[ Env([1,2,1],[0.1,0.8]) ],
							[ Env([1,2,1],[0.01,0.8]) ],
						],8),
					],inf),
					\lpfr, ~pmodenv.(Pseq([1,2,1,4]/2,inf), Pseq([4],inf)),
					\rq, ~pmodenv.(Pseq([0.1,0.2,0.1,0.4]/2,inf), Pseq([4],inf)),
					\note, Pseq([
						Pseq([
							[2-12, 5, 10],
							[5, 10, 2-12],
							\r,
							[10-12, 5, 10],

							\r,
							[5, 10, 2-12],
							Prand([ \r, [5, 10], ],1),
							[5-12, 5, 10],

							Prand([ \r, [5, 10, 2-12], ],1),
							[5, 10],
							\r,
							\r
						],1),
						[1+12, 7], \r,\r,\r,
					],8),
					\octave, 6,
					\legato, Pseq([
						Pser([
							0.2,0.7,
						],12),
						Pser([
							2,1,1,1,
						],4),
					],inf) * Pseg(Pseq([0.4,1,0.2,0.8],inf),8),
					\dur, 1/8,
					\amp, 0.011,
				),
	])
).play;
)


///////////////////
(
SynthDef(\tredrone, { arg lagf=0, freq=200, pan=0, amp=0.1, out=0;
	var sig;
	var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
	freq = freq.lag(lagf);
	freq = freq * [1, 5/3];
	sig = LFPulse.ar(freq * ( 1 + ( CuspL.ar(\cusfreq.kr(10) + [1,2,3],\cus2.kr(1.1),\cus3.kr(1)).lag(0.1) * ( CuspL.ar(0.1)/3 + 0.1+[ [0,0.01] ] ) * \fma.kr(1) ))).mean;
	sig.debug("kjkj");
	sig = sig /13;
	sig1 = sig;
	sig = RLPF.ar(sig, \lpfr.kr(1.1) * freq.lag(1) * SinOsc.kr(1*~t * [1,3/5]).range(0,1), \rq.kr(0.5));
	sig = sig + BPF.ar(sig1, freq.lag(1) * 8);
	//sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
(
Pdef(\demo, PmonoArtic(\tredrone,
	\legato, 1,
	\cus3, { rrand(0.01,10) }.dup(3),
	\fma, 0.01,
	\cus2, [1,2,3]*10,
	\cusfreq, [1,2,3]/3,
	\lpfr, 2,
	\lagf, Pseq([1,0,0,1]/2,inf).stutter(8),
	\degree, Pseq([
		[0,2,4],
		[0,2,4]+2,
		[0,2,4],
		[0,2,4]+2-12,
		[0,2,4],
		[0,2,4]+2,
		[0,2,4],
		[-20,-20,-20],
	],inf).stutter(8),
	\dur, 1,
	\amp, 0.1
)).play;
);
);

////////////////////////////:


(
SynthDef(\corde, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, fspread=0.01;
	var sig;
	var spread =1;
	sig = SinOsc.ar(freq * ((0..7)/7 - 0.5 * fspread + 1) * ( SinOsc.ar(freq*1.2) * 1 + 1 )) * ( SinOsc.ar(freq * 0.2) * 1 + 1 );
	sig = sig * 0.9;
	sig = Splay.ar(sig, spread, amp, pan);
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,2.1),gate,doneAction:2);
	Out.ar(out, sig);
}).add;
Pdef(\part).reset;
);

(
Pdef(\demo, Pdef(\demomo, 
	Ppar([
		Pbind(
			\instrument, \corde,
			\note, Pseq([
				18,0,7,8
			],inf),
			\octave, 5,
			\fspread, 1/Pkey(\freq) * Pseq([1,1.2,4,8],inf).stutter(8),
			\dur, 1,
			\amp, 0.1,
		),
	])
)).play;
)


(
SynthDef(\freecorde, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, fspread=0.01, spread=1;
	var sig;
	sig = SinOsc.ar(freq * ((0..7)/7 - 0.5 * fspread + 1) * ( SinOsc.ar(freq*\fmr.kr(1.2)) * \fmamp.kr(1) + 1 )) * ( SinOsc.ar(freq * \amr.kr(0.2)) * \amamp.kr(1) + 1 );
	sig = sig * 0.9;
	sig = SelectX.ar( LFNoise1.ar((1..8)/12).range(0,1), sig  );
	sig = Splay.ar(sig, spread, amp, pan);
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,2.1),gate,doneAction:2);
	Out.ar(out, sig);
}).add;
Pdef(\part).reset;
);

(
Pdef(\demo, Pdef(\demomo, 
	Ppar([
		Pbind(
			\instrument, \freecorde,
			\note, Pseq([
				0,7,8
			],inf),
			\octave, 5,
			\fspread, 1/Pkey(\freq) * Pseq([1,1.2,4,8],inf).stutter(8),
			\amr, 1.01,
			\fmr, 1.4,
			\fmr, ~pmodenv.(Pseq([1,1.002,1.1,7.4,1.04]+0.7,inf), 3),
			\ampamp,1,
			\dur, 1,
			\amp, 0.1,
		),
	])
)).play;
)


//////////////////////////////:
