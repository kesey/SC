//// techniques
// - basic sampling: start + sustain, speed (constant duration)
// - slice sampling: start + end, speed (always reach end and can start from end in reverse)
// - oscsampling + posenv
// - granulation

// options:
// - specify position (and Phaser): BufRd
// - specify rate: BufPlay
// - keep sample panning or sum + custom pan
// - hpf + lpf
// - fixed sustain: use another key for sustain to allow timeline no caring about sustain
// - startpos in seconds or normalized

// fx:
// - freqshift
// - am
// - ring






//////////////////////////////

SynthDef(\recorder, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, bufnum;
	var sig;
	var sig1;
	sig = InFeedback.ar(\inbus.kr(BusDef(\zero, \audio)), 2);
	sig.poll;
	sig1 = EnvGen.ar(Env.adsr(0.01,0,1,0.01),gate,doneAction:0);
	RecordBuf.ar(sig, bufnum, offset:0, recLevel:1, preLevel:\prelevel.kr(0), run:1, loop:0, trigger:1, doneAction:2);
	//sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
SynthDef(\player, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, bufnum, speed=1, pos=0, doneAction=2, loop=0, trigger=1;
	var sig;
	var sig1;
	// pos from 0 to 1
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * speed, trigger, startPos: (pos*BufFrames.kr(bufnum)), doneAction:doneAction, loop: loop);
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,0.01),gate,doneAction:doneAction);
	//sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig * \gain.kr(1));
}).add;
SynthDef(\playerbeat, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, bufnum, speed=1, pos=0, doneAction=2, loop=0, trigger=1;
	// pos in seconds
	var sig;
	var sig1;
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * speed, trigger, startPos: (pos*BufSampleRate.kr(bufnum)), doneAction:doneAction, loop: loop);
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.001,0,1,0.01)),gate,doneAction:doneAction);
	//sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig * \gain.kr(1));
}).add;
SynthDef(\playerpansec, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, bufnum, speed=1, pos=0, doneAction=2, loop=0, trigger=1, velamp=1;
	// pos in seconds
	var sig;
	var sig1;
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * speed, trigger, startPos: (pos*BufSampleRate.kr(bufnum)), doneAction:doneAction, loop: loop);
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.001,0,1,0.01)),gate,doneAction:doneAction);
	sig = Pan2.ar(sig, pan, 1).sum;
	Out.ar(out, sig * \gain.kr(1) * velamp);
}).add;
SynthDef(\playersec, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, bufnum, speed=1, pos=0, doneAction=2, loop=0, trigger=1, velamp=1;
	// pos in seconds
	var sig;
	var sig1;
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * speed, trigger, startPos: (pos*BufSampleRate.kr(bufnum)), doneAction:doneAction, loop: loop);
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.001,0,1,0.01)),gate,doneAction:doneAction);
	//sig = Pan2.ar(sig, pan, 1).sum;
	Out.ar(out, sig * \gain.kr(1) * velamp);
}).add;

SynthDef(\playersec_hlpf, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, bufnum, speed=1, pos=0, doneAction=2, loop=0, trigger=1, velamp=1;
	// pos in seconds
	var sig;
	var sig1;
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * speed, trigger, startPos: (pos*BufSampleRate.kr(bufnum)), doneAction:doneAction, loop: loop);
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.001,0,1,0.01)),gate,doneAction:doneAction);
	sig = LPF.ar(sig, \lpf.kr(19000));
	sig = HPF.ar(sig, \hpf.kr(40));
	//sig = Pan2.ar(sig, pan, 1).sum;
	Out.ar(out, sig * \gain.kr(1) * velamp);
}).add;
MenuSpecFuncDef(\patkitdef_synthdefs).addUnique(\playersec_hlpf);

// fm + shift with lfo
SynthDef(\playersec_fx, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, bufnum, speed=1, pos=0, doneAction=2, loop=0, trigger=1, velamp=1;
	// pos in seconds
	var sig;
	var sig1;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	env1 = EnvGen.kr(Env([1,0.5,0],[0.1,0.8]), 1);
	env2 = EnvGen.kr(Env([1,0.5,0],[0.1,0.8]), 1);
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * speed, trigger, startPos: (pos*BufSampleRate.kr(bufnum)), doneAction:doneAction, loop: loop);
	sig = sig * SinOsc.ar(\amplfo.kr(8*~t)).range(env1,1);
	sig = sig + FreqShift.ar(sig, SinOsc.kr(\shiftlfo.kr(4*~t)).range(env2,1));
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.001,0,1,0.01)),gate,doneAction:doneAction);
	//sig = Pan2.ar(sig, pan, 1).sum;
	Out.ar(out, sig * \gain.kr(1) * velamp);
}).add;

/////////////////////

SynthDef(\playersec_looper, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, bufnum, speed=1, pos=0, doneAction=2, loop=0, velamp=1;
	// pos in seconds
	var sig;
	var sig1;
	var trigger = Impulse.kr(\trigfreq.kr(0));
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * speed, trigger, startPos: (pos*BufSampleRate.kr(bufnum)), doneAction:doneAction, loop: loop);
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.001,0,1,0.01)),gate,doneAction:doneAction);
	//sig = Pan2.ar(sig, pan, 1).sum;
	Out.ar(out, sig * \gain.kr(1) * velamp);
}).add;

(
	~t = 185/1/60; TempoClock.default.tempo = ~t;
Pdef(\amen,
	Pbind(
			\instrument, \playersec_looper,
			\bufnum, BufDef(\amen),
			\bufnum, BufDef('loop/loop3b_185bpm.flac'),
			\degree, Pseq([0],inf),
			\speed, 2*~t/(137/60),
			\speed, 1*~t/(185/60),
			\speed, 1,
			\legato, 1,
			\gain, 1/4,
			\amp, 0.1
	) <>
	Pseq([
		Pbind(
			\pos, Pseq([0],2)/( 137/60 ),
			\dur, 2,
		),
		Pfindur(4,Pbind(
			\pos, Pseq([2],inf)*( 137/60 )+0.04,
			\trigfreq, Prand([
				1,2,4,8,16,32,64,
				1/16, 1/16, 1/16, 1/16, 1/16,
			],inf)/8*~t,
			\dur, PdurStutter(Prand([1,2,4],inf), 1),
		)),
	],inf),
).play;
);

/////////////////////////////////////////

(
Pdef(\sample,
	Ppar([
		Pbind(
			\instrument, \playersec,
			\bufnum, BufDef('voices/feynman.flac'),
			\pos, Pseq([
				1.9,0.5,2,0.6,
				1.9,0.5,2.1,0.6,
				1.9,0.5,2,0.6,
				1.5,0.5,2.1,0.6,
			],inf),
			\legato, Pseq([
				1.8,0.1, 0.8,0.1,
			],inf),
			\gain, 0.5,
			\dur, 1/8,
			\amp, 0.1,
		),
		Pbind(
			\instrument, \playersec_fx,
			\bufnum, BufDef('voices/feynman.flac'),
			\pos, Pseq([
				4,
				2,
			],inf).stutter(8),
			\isRest, Pseq([
				0,0,0,0, 0,0,0,0,
				0,0,0,0, 1,0,0,0,
			],inf).coin.not,
			\speed, 1.2,
			\legato, Pseq([
				Pser([
					8.2,
				],8*2),
			],inf),
			\gain, 0.6,
			\dur, 1/8,
			\amp, 0.1,
		),
		Pbind(
			\instrument, \playersec,
			\bufnum, BufDef('voices/feynman.flac'),
			\pos, Pseq([
				1.9,0.5,2,0.6,
				1.9,0.5,2.1,0.6,
				1.9,0.5,2,0.6,
				1.5,0.5,2.1,0.6,
			],inf) +0.3,
			\legato, 0.6,
			\isRest, Pseq([
				1,0,1,0, 1,0,1,0,
				0,1,1,1, 1,0,1,1,
				1,0,1,0, 1,0,1,0,
				1,0,1,1, 0,1,1,0,
			],inf).coin.not,
			\speed, 4.0,
			\gain, 0.2,
			\dur, 1/16,
			\amp, 0.1,
		),
	])
).play;
)
//////////////////////////////////////////////
// use the sampler as an oscillator with pmodenv to modulate position

SynthDef(\playersec_osc, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, bufnum, speed=1, pos=0, doneAction=2, loop=0, velamp=1;
	// pos in seconds
	var sig;
	var sig1;
	var trigger = Impulse.ar(\trigfreq.kr(0));
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * speed, trigger, startPos: (pos*BufSampleRate.kr(bufnum)), doneAction:doneAction, loop: loop);
	sig1 = RLPF.ar(sig, \lpfr.kr(1) * \trigfreq.kr, \rq.kr(0.5));
	sig = SelectX.ar(\lpmix.kr(0.5), [sig, sig1]);
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.001,0,1,0.01)),gate,doneAction:doneAction);
	//sig = Pan2.ar(sig, pan, 1).sum;
	Out.ar(out, sig * \gain.kr(1) * velamp);
}).add;
SynthDef(\playersec_osczig, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, bufnum, speed=1, pos=0, doneAction=2, loop=0, velamp=1;
	// pos in seconds
	var sig;
	var sig1;
	var trigger = Impulse.ar(\trigfreq.kr(0));
	var speedtrigger = Impulse.ar(\trigfreq.kr*2);
	speed = speed * Demand.ar(speedtrigger, 0, Dseq([
		1,-1,
	],inf));
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * speed, trigger, startPos: (pos*BufSampleRate.kr(bufnum)), doneAction:doneAction, loop: loop);
	sig1 = RLPF.ar(sig, \lpfr.kr(1) * \trigfreq.kr, \rq.kr(0.5));
	sig = SelectX.ar(\lpmix.kr(0.5), [sig, sig1]);
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.001,0,1,0.01)),gate,doneAction:doneAction);
	//sig = Pan2.ar(sig, pan, 1).sum;
	Out.ar(out, sig * \gain.kr(1) * velamp);
}).add;
)


(
Pdef(\glitch,
	Ppar([
		Pbind(
			\instrument, \playersec_osczig,
			\trigfreq, 400 * 1/8 * Pseq([
				0,0,0,-1,
			],inf).midiratio,
			\pos, Pseg(Pseq([0,0.1],inf),8)+0.1,
			\pos, ~pmodenv.(Pseq([0.1,1,0.1,2]/4,inf), 8)+0.3,
			\speed, ~pmodenv.(Pseq([2.1,1,0.1,2],inf), 8),
			\lpfr, 8,
			\legato, 1,
			\bufnum, BufDef(\table, "field/table.flac"),
			\bufnum, BufDef('voices/feynman.flac'),
			\freq, 200,
			\dur, 1/2,
			\gain, 30,
			\gain, 1/2,
			\amp, 0.1,
		);

	])
).play;
)

////////////
// hear the sampled voice pitched

(
SynthDef(\playersec_osczig_stereo, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, bufnum, speed=1, pos=0, doneAction=2, loop=0, velamp=1;
	// pos in seconds
	var sig;
	var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
	var trigger = Impulse.ar(\trigfreq.kr(0));
	var speedtrigger = Impulse.ar(\trigfreq.kr*2);
	speed = speed * Demand.ar(speedtrigger, 0, Dseq([
		1,-1,
	],inf));
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * speed, trigger, startPos: (pos+[0,0.01]*BufSampleRate.kr(bufnum)), doneAction:doneAction, loop: loop);
	sig1 = RLPF.ar(sig, \lpfr.kr(1) * \trigfreq.kr, \rq.kr(0.5));
	sig = SelectX.ar(\lpmix.kr(0.5), [sig, sig1]);
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.001,0,1,0.01)),gate,doneAction:doneAction);
	sig.debug("sig");
	sig = sig.flop.sum.debug("sig");
	//sig = Pan2.ar(sig, pan, 1).sum;
	Out.ar(out, sig * \gain.kr(1) * velamp);
}).add;
)


(
Pdef(\glitch,
	Ppar([
		Pbind(
			\instrument, \playersec_osczig_stereo,
			\trigfreq, 400 * 1/4 * Pseq([
				0,0,0,-1,
			],inf).midiratio,
			\pos, Pseg(Pseq([0,0.1],inf),8)+0.1,
			\pos, 0.4,
			\speed, Pseq([
				1,1.1,0.8,
			],inf),
			\speed, ~pmodenv.(Pseq([2.1,1,0.1,2],inf), 1),
			\pos, ~pmodenv.(Pseq([0.1,4,0.1,2]/4,inf), 1)+2.0,
			\lpfr, 8,
			\legato, 1,
			\bufnum, BufDef(\table, "field/table.flac"),
			\bufnum, BufDef('loop/clean7_135bpm.flac'),
			\bufnum, BufDef('loop/loop3b_185bpm.flac'),
			\bufnum, BufDef('voices/feynman.flac'),
			\freq, 200,
			\dur, 1/2,
			\gain, 30,
			\gain, 1/2,
			\amp, 0.1,
		);

	])
).play;
)

///////////////////////////////////////////

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
~buf = BufDef(\moeten, "voices/02_moeten.flac");
Ndef(\lfo1).quant = Pdef.defaultQuant;
Ndef(\lfo3).quant = Pdef.defaultQuant;

Ndef(\lfo1, { arg freq=1; SinOsc.kr(freq * t).range(50,7500).lag(0.051)});
Ndef(\lfo1).put(1, \set -> Pbind(
	\freq, Pseq([1,1,16,1,1,8,1,1],inf),
	\dur, 1/1,
));
Ndef(\lfo3, { arg freq=20; freq.lag(0.401).round(0.1) * SinOsc.kr(1/16*t).range(0.5,1.5).round(0.1)});
Ndef(\lfo3).put(1, \set -> Pbind(
	\freq, Pseq([
		2,2,2,2,
		2,4,4,6,
		2,2,2,2,
		2,4,4,6,
	]*250,inf),
	\dur, 1,
));

Pdef(\sample,
	Pbind(
		\instrument, \oscsampler3,
		\freq, 700,
		\pos, 0.012,
		\fshift, -148,
		\lpmix, 0.01,
		\hpmix, 0.0,
		\hpfreq, 10,
		\rq, 0.1,
		\posenv, Pseq([
			[ Env([0.004,0.0019,0.1071].integrate.postln,[0.42,8.4]) ],
		],inf),
		\levelScale, 8,
		\timeScale, 1,
		\range, 0.0001,
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
			1,0,0,0,
			0,0,0,0,
		],inf).coin.not,
		\amp, 1 * Pkey(\amp),
	)
).play

)


/////////////////////////////////////////////



(
~buf = BufDef(\crepe, "field/crepe.flac");

Pdef(\sample,
	Pbind(
		\instrument, \oscsampler3,
		\pos, 0.208,
		\freq, 187,
		\range, 0.00001,
		\posenv, Pseq([
			[ Env([0.00,0.01001,0].integrate.postln,[0.41,0.1]) ],
			[ Env([0.00,0.01,0.012].integrate.postln,[0.21,0.4]) ],
		],inf),
		\finepos, 4/400,
		\legato, Pseq([
			0,0,0,0,
			1,1,0,1,
			0,0,1,0,
			1,0,1,0,
		],inf).linlin(0,1,0.5,4)/2,
		//\legato, 1,
		\dur, 1/3 * 1/2,
		\fshift, 400,
		\lpmix, 1,
		\rq, 0.1,
		\hpmix, 0,
		\hpfreq, 100,
		\isRest, Pseq([
			1,0,0,
			1,0.5,0,
			1,1,1,
			1,0,1,
		],inf).coin.not,
		\ffreq, Pseq([
			1000,5000,150,500,
		],inf) * Pseq([1,2,1/2],inf).stutter(4),
		\amp, 0.2,
		\bufnum, ~buf,

	)
).play;
)

(
Pdef(\sample, Pdef(\zed,
	Ppar([

	Pbind(
		\instrument, \oscsampler3,
		\pos, 1.208,
		\freq, 187,
		\range, 0.0000001,
		\posenv, Pseq([
			[ Env([0.00,0.01001,0].integrate.postln,[0.41,8.1]) ],
		],inf),
		\finepos, 4/400,
		\legato, Pseq([
			2,0,
		],inf),
		\isRest, Pfunc({ arg ev; ev[\legato] <= 0 }),
		\dur, 1/8,
		\fshift, 40,
		\lpmix, 1,
		\rq, 0.4,
		\hpmix, 0,
		\hpfreq, 100,
		\ffreq, Pseq([
			1020,5240,450,700,
		],inf) * Pseq([1,2,1/2],inf).stutter(4),
		\amp, 0.1,
			\bufnum, BufDef('voices/feynman.flac'),

	)
	])
)).play;
)

(
Pdef(\sample, Pdef(\zed,
	Ppar([

	Pbind(
		\instrument, \oscsampler3,
		\pos, 1.208,
		\freq, 187,
		\range, 0.0000001,
		\posenv, Pseq([
			[ Env([0.00,0.01001,0].integrate.postln,[0.41,8.1]) ],
		],inf),
		\finepos, 1/400,
		\legato, Pseq([
			4,0,0,0, 1,0,0,1,
		   	0,0,2,0, 1,0,1,1,
		],inf),
		\isRest, Pfunc({ arg ev; ev[\legato] <= 0 }),
		\dur, 1/8,
		\fshift, 40,
		\lpmix, 1,
		\rq, 0.4,
		\hpmix, 0,
		\hpfreq, 100,
		\ffreq, Pseq([
			1020,5240,450,700,
		],inf) * Pseq([1,2,1/2],inf).stutter(4),
		\amp, 0.1,
			\bufnum, BufDef('voices/feynman.flac'),

	)
	])
)).play;
)
//////////////////////////////////////////


(
Ndef(\sample, { arg amp=0.5, pan=0, freq=200, mbufnum,
						gdur=12, trate=100, time_stretch=1, pos=0, pitch_stretch = 1,
						randframes=0.01, randrate=1, doneAction=2, finepos=0,
						release=0.2;
	var ou;
	var ou1, ou2;
	var dur, clk;
	var bufnum = mbufnum;
	var randclk;
	var pitch;
	var sr, phasor;

	bufnum = BufDef.mono(\rocksteady, "vipere/rocksteady.flac");
	pitch_stretch = 1;
	time_stretch = 0;
	trate = 100;
	pos = SinOsc.kr(1/4*~t,pi).range(0,1) * 0.04 + 0.11;
	//pos = EnvGen.ar(Env([0,0.4,0.2],[0.4,0.2]),LFPulse.kr(1/1*~t),doneAction:0);
	//pos = pos + EnvGen.ar(Env([0,0.2,0.4],[0.4,0.1]),LFPulse.kr(1*~t).poll,doneAction:0).poll;
	clk = Impulse.kr(trate);
	randclk = Impulse.kr(randrate * trate);
	dur = 0.1;
	pan = (WhiteNoise.kr(0.6) + pan).clip(-1,1);
	sr = SampleRate.ir;
	phasor = Phasor.ar(0, time_stretch.abs / sr / BufDur.kr(bufnum), 0, 1);
	phasor = Select.ar(time_stretch.sign + 1 /2, [
		pos - phasor,
		phasor + pos,
	]);

	pos = phasor * BufDur.kr(bufnum) + finepos ;
	ou = TGrains.ar(2, clk, bufnum, pitch_stretch, pos % BufDur.kr(bufnum), dur, pan, 1);
	ou1 = HPF.ar(ou, 7000);
	//ou1 = ou;
	ou2 = LPF.ar(ou, 200);
	ou = ou1 + ou2;
	ou = Splay.ar(ou, 1, amp);
}).play;
);

/////////////////////////////////////////////////////////
// famous strange perc noise


		(
		Pdef(\sample, Pbind(
			\instrument, \oscsampler3,
			\pos, 0.014 + Pseq([0,1,0,2],inf).stutter(8)/100,
			\pos, 0.577,
			\freq, 187,
			\range, 0.0000001,
			\ffreqtab, Pseq([[Array.geom(8,1.8,1.2).postln]],inf),
			\posenv, Prand([
				//[ Env([0.42,0.3903,0.3513],[0.3,0.4]) ],
				//[ Env([0.00,0.0189,0.401].integrate.postln,[0.01,0.1]) ],
				[ Env([0.00,0.00011,0.01011].integrate.postln,[0.01,2.4]) ],
				[ Env([0.00,0.00011,0.01111].integrate.postln,[0.01,2.4]) ],
				[ Env([0.00,0.00011,0.01051].integrate.postln,[0.02,2.4]) ],
			],inf).stutter(2),
			\legato, 0.2,
			\dur, 1,
			\isRest, false,
			\adsr, Pseq([
				Pwrand([
					[ Env.adsr(0.01,0.3,0.5,0.9) ],
					[ Env.adsr(0.01,0.3,0.5,0.19) ],
					[ Env.adsr(0.01,0.3,0.5,0.29) ],
					[ Env.adsr(0.01,0.3,0.5,0.49) ],
				], [2,0.1,0.1,0.1].normalizeSum),
			],inf),
			\bufnum, BufDef(\table, "field/table.flac"),
			\rq, 0.1,
			\fshift, Pwrand([0,-400,-300,200],[1.90, 0.1,0.1,0.1].normalizeSum,inf),
			\lpmix, 1,
			\ffreq, 200 + Pwhite(0.0,100),
			\amp, 89.0 * Pkey(\amp),

		)).play
		)

///////////////////////////
/// racle perc

(

	Pdef(\sample, Pbind(
		\instrument, \oscsampler3,
		\pos, 0.014 + Pseq([0,1,0,2],inf).stutter(8)/100,
		\pos, 0.44474474474474 + Pwhite(0,0.0001),
		\freq, 187,
		\range, 0.0000001,
		\ffreqtab, Pseq([[Array.geom(8,1.8,1.2).postln]],inf),
		\posenv, Pseq([
			//[ Env([0.42,0.3903,0.3513],[0.3,0.4]) ],
			//[ Env([0.00,0.0189,0.401].integrate.postln,[0.01,0.1]) ],
			Pseq([
				[ Env([0.00,0.00111,0.00011].integrate.postln,[0.01,0.4]) ],
				[ Env([0.00,0.00211,0.00011].integrate.postln,[0.01,0.4]) ],
			],4),
			Pseq([
				[ Env([0.00,0.00121,0.00011].integrate.postln,[0.01,0.4]) ],
				[ Env([0.00,0.00151,0.00015].integrate.postln,[0.04,0.4]) ],
			],4),
		],inf).stutter(2),
		\legato, 1.0,
		\dur, PdurStutter(Pseq([1,4,2,8],inf), 1/2),
		\isRest, false,
		\adsr, Pseq([
			[ Env.adsr(0.0001,0.3,0.5,0.11) ],
		],inf),
		\bufnum, ~buf,
		\rq, 0.3,
		\fshift, 0,
		\lpmix, 0.81,
		\ffreq, 8800,
		\hpmix, 0.9,
		\hpfreq, Pseq([1,100,200,500,1,1000],inf).stutter(4),
		\amp, 389.0 * Pkey(\amp),
	)).play;
)


/////////////////////////


(
Pdef(\rand, Pbind(
	\instrument, \playersec,
	\bufnum, BufDef('loop/clean7_135bpm.flac'),
	\pos, Pwhite(0,2.0),
	\speed, Pseg(Pseq([0,4],inf),8),
	\pos, Pseg(Pseq([0,1,1/4],inf),1),
	\dur, 1/16,
	\amp, 0.1,
)).play;
);

///////////////////////// like a scratch which start the sample
(
SynthDef(\playersec_zix2, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, bufnum, speed=1, pos=0, doneAction=2, loop=0, trigger=1, velamp=1;
	// pos in seconds
	var sig;
	var sig1;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	env1 = EnvGen.kr(Env([1,0.5,0],[0.1,0.8]), 1);
	env2 = EnvGen.kr(Env([1,0.5,0],[0.1,0.8]), 1);
	speed = speed * EnvGen.kr(Env([0.21,1,1],[0.12,0.8]), 1);
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * speed, trigger, startPos: (pos*BufSampleRate.kr(bufnum)), doneAction:doneAction, loop: loop);
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.001,0,1,0.01)),gate,doneAction:doneAction);
	//sig = FreqShift.ar(LPF.ar(sig, 4000), 2300) + HPF.ar(sig, 4000);
	sig = HPF.ar(sig, 6000)*18;
	//sig = Pan2.ar(sig, pan, 1).sum;
	Out.ar(out, sig * \gain.kr(1) * velamp);
}).add;
)


////////////////////////////::
/////// granulation


(
SynthDef(\simplegran, { arg out=0, mix=0.5, gain=1, gate=1, mbufnum=0, pitch_stretch=1, pos=0, gdur=0.1, pan;
	var sig;
	var clk;
	var phase;
	clk = Impulse.ar(\gfreq.kr(40));
	//phase = Phasor.ar(1, 1,0,BufDur.kr(bufnum)) + pos;
	phase = pos;
	sig = TGrains.ar(2, clk, mbufnum, pitch_stretch, phase % BufDur.kr(mbufnum), gdur, pan, 1);
	sig = sig * EnvGen.ar(\asr.kr(Env.asr(0.01,1,0.01)),gate,doneAction:2);
	sig = sig * gain;
	Out.ar(out, sig);
}).add;
SynthDef(\doublegran, { arg out=0, mix=0.5, gain=1, gate=1, mbufnum=0, pitch_stretch=1, pos=0, gdur=0.1, pan;
	var sig;
	var clk;
	var phase;
	clk = Impulse.ar(\gfreq.kr(40));
	//phase = Phasor.ar(1, 1,0,BufDur.kr(bufnum)) + pos;
	phase = pos;
	sig = TGrains.ar(2, clk, mbufnum, pitch_stretch, phase + [0,\dephase.kr(0)] % BufDur.kr(mbufnum), gdur, pan, 1);
	sig = sig.mean * 0.6;
	sig.debug("sig");
	sig = sig * EnvGen.ar(\asr.kr(Env.asr(0.01,1,0.01)),gate,doneAction:2);
	sig = sig * gain;
	Out.ar(out, sig);
}).add;
Pdef(\part).reset;
)

(
Pdef(\part, Pdef(\plop,
	Ppar([
		Pmono(\simplegran,
			\freq, 200,
			\mbufnum, BufDef.mono('loop/loop3b_185bpm.flac'),
			\mbufnum, BufDef.mono('voices/kaspi.flac'),
			\mbufnum, BufDef.mono('voices/feynman.flac'),
			\pos, Pseq([
				~pmodenv.(Pseq([1,1.4]+0.4,1), 1/2),
				~pmodenv.(Pseq([1.4,1]+0.4,1), 1/2),
			],inf),
			\dephase, ~pmodenv.(Pseq([0,0.02,0.1,1],inf), 8),
			\gdur, ~pmodenv.(Pseq([0.1,0.02],inf), 4),
			\pitch_stretch, 2,
			\dur, 1/4,
			\amp, 0.1,
		),
	])
)).play;
)

///////////////////////////////////


(
Pdef(\demo, Pdef(\demomo,
	Ppar([
		Pbind(
			\instrument, \playersec,
			\bufnum, BufDef('loop/loop2_185bpm.flac'),
			\bufnum, BufDef('voices/feynman.flac'),
			\bufnum, BufDef('fix4/snare1.flac'),
			\bufnum, BufDef(\ukraine, "bruit1/07_ukraine.flac"),
			\speed, 1.031 * Pseq([
				1,
			],inf),
			\pos, Pseq([
				4,2,5
			],inf),
			\isRest, Pseq([
				1,1,1,1,
			],inf).coin.not,
			\dur, Pn(1/2,inf),
			\gain, 2,
			\out, BusDef(\smpbus3, \audio),
		),
		Pmono(\fx_stutter,
			\inbus, BusDef(\smpbus3),
			\time, 1/16/~t * Pseq([1],inf).stutter(2),
			\mix, Pseq([
				0,1,0,1, 1,0,1,1,
				1,0,1,0, 1,1,0,1,
			],inf),
			\dur, 1/8,
		),

		Pbind(
			\instrument, \playersec,
			\bufnum, BufDef('loop/loop2_185bpm.flac'),
			\bufnum, BufDef('voices/feynman.flac'),
			\speed, 2.031 * Pseq([
				1,0.7,1.2,0.5,
			],inf),
			\pos, Pseq([
				0,1,2,2,
				0.1,1,2,2.4,
				0,1,2,2,
				0,1/2,5,3,
			],inf),
			\isRest, Pseq([
				1,0,1,0,
				1,1,1,1,
			],inf).coin.not,
			\dur, Pn(1/2,inf),
			\gain, 1/2,
			\out, BusDef(\smpbus2, \audio),
		),
		Pmono(\fx_stutter,
			\inbus, BusDef(\smpbus2),
			\time, 1/16/~t,
			\mix, Pseq([
				0,1,0,1,
				0,1,1,1,
			],inf),
			\dur, 1/8,
		),

		Pbind(
			\instrument, \playersec,
			\bufnum, BufDef('voices/feynman.flac'),
			\bufnum, BufDef('loop/loop2_185bpm.flac'),
			\speed, 1.031,
			\pos, Pseq([
				0,1,2,2,
				0.1,1,2,2.4,
			],inf),
			\dur, Pn(1/2,inf),
			\gain, 1/2,
			\out, BusDef(\smpbus, \audio),
		),
		Pmono(\fx_stutter,
			\inbus, BusDef(\smpbus),
			\time, 1/16/~t,
			\mix, Pseq([
				0,0,1,1,
				0,1,0,1,
			],inf),
			\dur, 1/8,
		),
	])
)).play;
)
