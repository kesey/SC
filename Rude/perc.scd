
(
SynthDef(\snare, { arg out=0,tu=1, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var env = EnvGen.ar(Env.perc(0.01,1));
	var enf = EnvGen.ar(Env([600,177,230],[0.01,0.01],-4));
	sig = SinOsc.ar(tu*enf+127,0,0.5)*env;
	sig = [WhiteNoise.ar,sig];
	sig = RHPF.ar(sig, \hpf.kr(170)*tu, \hrq.kr(0.5));
	sig = sig + Mix.ar(BPF.ar(sig,[127]++( {10 + ExpRand(10,14443.0)}!48  ),[0.5,0.5])*0.4);
	sig = sig/2;
	sig = RLPF.ar(sig, \lpf.kr(11100)*tu , \lrq.kr(0.5));
	//sig = SelectX.ar(MouseX.kr(0,1), sig);
	sig[1] = sig[1]* EnvGen.ar(Env.perc(0.01,0.01,-4),gate,doneAction:0);
	sig = sig.mean;

	sig = sig * EnvGen.ar(Env.perc(0.01,\rel.kr(0.1)*2,-4),gate,doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)

(
Pdef(\demo, Pbind(
	\instrument, \snare,
	\degree, Pseq([0],inf),
	\dur, 1,
	\amp, 0.1
)).play;
);

//////////////////////////////////////////////////////
// funky drummer !!!

(
SynthDef(\snapkick, { |out = 0, pan = 0, amp = 0.3|
    var body, bodyFreq, bodyAmp;
    var pop, popFreq, popAmp;
    var click, clickAmp;
    var snd;

    // body starts midrange, quickly drops down to low freqs, and trails off
    bodyFreq = EnvGen.ar(Env([261, 120, 51], [0.035, 0.08], curve: \exp));
    bodyAmp = EnvGen.ar(Env.linen(0.005, 0.1, 0.3), doneAction: 2);
    body = SinOsc.ar(bodyFreq) * bodyAmp;
    // pop sweeps over the midrange
    popFreq = XLine.kr(750, 261, 0.02);
    popAmp = EnvGen.ar(Env.linen(0.001, 0.02, 0.001)) * 0.15;
    pop = SinOsc.ar(popFreq) * popAmp;
    // click is spectrally rich, covering the high-freq range
    // you can use Formant, FM, noise, whatever
    clickAmp = EnvGen.ar(Env.perc(0.001, 0.01)) * 0.15;
    click = LPF.ar(Formant.ar(910, 4760, 2110), 3140) * clickAmp;

    snd = body + pop + click;
    snd = snd.tanh;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;
SynthDef(\phyhat, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	sig = SinOsc.ar(freq);
	sig = WhiteNoise.ar;
	env1 = EnvGen.kr(Env([8210,4100,4051],[0.1,0.8]), 1, levelScale:LFNoise1.kr((1..8)/8).range(0.7,1.1) );
	env2 = EnvGen.kr(Env([18210,2100,451],[0.1,0.8],-4), 1, levelScale:LFNoise1.kr((1..8)/8).range(0.7,1.1) );
	sig = BPF.ar(sig, env1, LFNoise1.kr((1..8)/8).range(0.1,0.9));
	//sig = RLPF.ar(sig, env2, \rq.kr(0.5));
	sig = HPF.ar(sig, 20000-env2);
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,0.4,1,-4),gate,doneAction:2);
	sig = Pan2.ar(sig, pan, amp).sum;
	Out.ar(out, sig);
}).add;

SynthDef(\snarebpf1, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	// variation not used
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
    var pop, popAmp, popFreq;
	sig = SinOsc.ar(freq);
	sig = WhiteNoise.ar;

    popFreq = EnvGen.ar(Env([3261, 410, 160], [0.005, 0.01], curve: \exp));
    popAmp = EnvGen.ar(Env.perc(0.001, 0.11)) * 0.7;
    pop = SinOsc.ar(popFreq * ( 1 + ( SinOsc.ar(410) * 0.4 ))) * popAmp;
	env1 = EnvGen.kr(Env([1840,2010,1831],[0.01,0.4]), 1, levelScale:LFNoise1.kr((1..8)/8).range(0.9,1.1) );
	env2 = EnvGen.kr(Env([411,150,245],[0.01,0.7],-4), 1, levelScale:LFNoise1.kr((1..8)/8).range(0.9,1.1) );
	sig = pop + ( sig/2 );
	sig = BPF.ar(sig, env1, LFNoise1.kr((1..8)/8).range(0.01,0.9)) + LPF.ar(WhiteNoise.ar(0.1), 11300);
	sig = ( pop/2 ) + ( sig );
	sig = BPF.ar(sig, [130,220], 0.1).mean + sig; // eq
	sig = HPF.ar(sig, env2);
	sig = sig * EnvGen.kr(\adsr.kr(Env.adsr(0.001,0.1,0.8,0.4,1,-6)), gate, doneAction:2);
	sig = Pan2.ar(sig, pan, amp).sum;
	Out.ar(out, sig);
}).add;

SynthDef(\snarebpf, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
    var pop, popAmp, popFreq;
	sig = SinOsc.ar(freq);
	sig = WhiteNoise.ar;

    popFreq = EnvGen.ar(Env([3261, 410, 160], [0.005, 0.01], curve: \exp));
    popAmp = EnvGen.ar(Env.perc(0.001, 0.11)) * 0.7;
    pop = SinOsc.ar(popFreq * ( 1 + ( SinOsc.ar(410) * 0.4 ))) * popAmp;
	env1 = EnvGen.kr(Env([1840,2010,1831],[0.01,0.4]), 1, levelScale:LFNoise1.kr((1..8)/8).range(0.9,1.1) );
	env2 = EnvGen.kr(Env([411,150,245],[0.01,0.7],-4), 1, levelScale:LFNoise1.kr((1..8)/8).range(0.9,1.1) );
	sig = pop + ( sig/2 );
	sig = BPF.ar(sig, env1, LFNoise1.kr((1..8)/8).range(0.01,0.9)) + LPF.ar(WhiteNoise.ar(0.1), 11300);
	sig = ( pop/2 ) + ( sig );
	sig = BPF.ar(sig, [130,220], 0.1).mean + sig; // eq
	sig = HPF.ar(sig, env2);
	sig = sig * EnvGen.kr(\adsr.kr(Env.adsr(0.001,0.1,0.8,0.4,1,-6)), gate, doneAction:2);
	sig = Pan2.ar(sig, pan, amp).sum;
	Out.ar(out, sig);
}).add;

SynthDef(\phycymbal, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
    var pop, popAmp, popFreq;
	sig = SinOsc.ar(freq);
	sig = WhiteNoise.ar;

    popFreq = EnvGen.ar(Env([8261, 11410, 1460], [0.005, 0.01], curve: \exp));
    popAmp = EnvGen.ar(Env.perc(0.001, 0.01)) * 0.7;
    pop = SinOsc.ar(popFreq * ( 1 + ( SinOsc.ar(10) * 0.4 ))) * popAmp;
	env1 = EnvGen.kr(Env([1180,6810,1831],[0.01,0.4]), 1, levelScale:LFNoise1.kr((1..8)/8).range(0.7,1.3) );
	env2 = EnvGen.kr(Env([3171,7470,13845],[0.04,\rel.kr(0.1)],-4), 1, levelScale:LFNoise1.kr((1..8)/8).range(0.7,1.1) );
	sig = pop/2 + ( sig/2 );
	sig = BPF.ar(sig, env1, LFNoise1.kr((1..8)/8).range(0.71,0.9) * XLine.kr(1.3,1,1)) + LPF.ar(WhiteNoise.ar(0.1), 11300);
	sig = ( pop/2 ) + ( sig );
	sig = HPF.ar(sig, env2);
	sig = LPF.ar(sig, 17000);
	sig = LPF.ar(sig, 11000) + ( sig/2 );
	//sig = BRF.ar(sig, MouseX.kr(20,20000).poll, MouseY.kr(0.1,1));
	sig = BRF.ar(sig, 12000);
	sig = sig * 0.6;
	sig = sig * EnvGen.ar(\adsr.kr( Env.adsr(0.1,0.1,0.8,0.4,1,-8) ),gate,doneAction:2);
	sig = Pan2.ar(sig, pan, amp).sum;
	Out.ar(out, sig);
}).add;

SynthDef(\phycymbal2, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, fac1=1;
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
	sig = SinOsc.ar(freq);
	sig = WhiteNoise.ar;
	env1 = EnvGen.kr(Env([8210,4100,4051],[0.1,0.8]), 1, levelScale:LFNoise1.kr((1..8)/8).range(0.7,1.1) );
	env2 = EnvGen.kr(Env([18210,200,451],[0.1,0.8],-4), 1, levelScale:LFNoise1.kr((1..8)/8).range(0.7,1.1) );
	sig = BPF.ar(sig, env1, LFNoise1.kr((1..8)/8).range(0.1,0.9));
	sig = HPF.ar(sig, 20000-env2);
	sig1 = sig;
	//sig = RLPF.ar(sig, env2, \rq.kr(0.5));
	sig = WhiteNoise.ar;
	env3 = EnvGen.kr(Env([1,0.9,1]*Rand(0.91,1.1),[0.01+Rand(0,0.1),0.8]), 1);
	sig = sig + Ringz.ar(sig, [9400,17030,16410,8000.14,15000] * env3, 0.001).mean/10;
	env1 = EnvGen.kr(Env([8821,1810,13251],[0.01,0.8*fac1]), 1, levelScale:LFNoise1.kr((1..8)/8).range(0.7,1.1) );
	env2 = EnvGen.kr(Env([13820,14800,3151],[0.07,0.8*fac1],-4), 1, levelScale:LFNoise1.kr((1..8)/8).range(0.7,1.1) );
	sig = HPF.ar(sig, env1);
	sig = LPF.ar(sig, env2);
	sig2 = sig*1.3;

	sig = sig1+sig2;

	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,1.8,1,-4),gate,doneAction:2);
	sig = Pan2.ar(sig, pan, amp).sum;
	Out.ar(out, sig);
}).add;

SynthDef(\stickfight, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	sig = SinOsc.ar(freq);
	sig = WhiteNoise.ar;
	env1 = EnvGen.kr(Env([4410,100,451],[0.1,0.2]), 1, levelScale:LFNoise1.kr((1..8)/8).range(0.7,1.1) );
	//env2 = EnvGen.kr(Env([18210,2100,451],[0.1,0.8],-4), 1, levelScale:LFNoise1.kr((1..8)/8).range(0.7,1.1) );
	env2 = EnvGen.kr(Env([110,12100,451],[0.1,0.2],-4), 1, levelScale:LFNoise1.kr((1..8)/8).range(0.7,1.1) );
	sig = BPF.ar(sig, env1, LFNoise1.kr((1..8)/8).range(0.1,0.9));
	//sig = RLPF.ar(sig, env2, \rq.kr(0.5));
	sig = HPF.ar(sig, env2);
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,0.4,1,-4),gate,doneAction:2);
	sig = Pan2.ar(sig, pan, amp).sum;
	Out.ar(out, sig);
}).add;
)

(
// adapted from a post by Neil Cosgrove (other three are original)
SynthDef(\stick, { |out = 0, amp = 0.5, pan = 0, dur = 1|
    var env1, env2, snd, noise1, noise2;

    // noise 1 - 4 short repeats
    env1 = EnvGen.ar(
        Env.new(
            [0, 1, 0.9, 0.9, 0.9, 0.7, 0, 0.7, 0],
            [0.001, 0.001, 0, 0.008, 0, 0.01, 0, 0.01],
            [0, 0, 0, 00, 0, -3, 0, -4]
        )
    );

    noise1 = WhiteNoise.ar(env1);
    noise1 = HPF.ar(noise1, 600);
    noise1 = LPF.ar(noise1, XLine.kr(7200, 7000, 0.03)/2);
    noise1 = BPF.ar(noise1, 1620, 3);

    // noise 2 - 1 longer single
    env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.18], [0, -4]), doneAction:2);

    noise2 = WhiteNoise.ar(env2);
    noise2 = HPF.ar(noise2, 1000);
    noise2 = LPF.ar(noise2, 7600);
    noise2 = BPF.ar(noise2, 1230, 0.7, 0.7);

    snd = noise1 + noise2;
    snd = snd * 2;
    snd = snd.softclip;

    Out.ar(out, Pan2.ar(snd,pan,amp));
}).add;
);

(
Pdef(\funkydrummer, 
	Ppar([
		Pbind(
			\instrument, \snapkick,
			\isRest, Pseq([
				1,0,1,0, 0,0,0,0,
				0,0,1,0, 0,1,0,0,
			],inf).coin.not,
			\dur, 1/8,
			\sustain, 0.1/2,
			\amp, 0.1
		),
		Pbind(
			\instrument, \snarebpf,
			\sustain, 0.1/2,
			\adsr, Pseq([
				 [ Env.adsr(0.1/3,0.1,0.8,0.2,1,-6) ]
			],inf),
			\isRest, Pseq([
				0,0,0,0, 1,0,0,0,
			],inf).coin.not,
			\dur, 1/8,
			\pan, 0.1,
			\amp, 0.1,
		),
		Pbind(
			\instrument, \snarebpf,
			\sustain, 0.04,
			\adsr, Pseq([
				 [ Env.adsr(0.1/2,0.1,0.8,0.1,1,-6) ]
			],inf),
			\isRest, Pseq([
				0,0,0,0, 0,0,0,1,
				0,1,0,1, 0,0,0,0,
			],inf).coin.not,
			\dur, 1/8,
			\pan, 0.1/2,
			\amp, 0.1/3,
		),
		Pbind(
			\instrument, \phycymbal,
			\sustain, 0.1/3,
			\adsr, Pseq([
				 [ Env.adsr(0.001,0.1,1.8,0.07,1,-3) ],
				 [ Env.adsr(0.002,0.1,0.8,0.04,1,-3) ],
			],inf).stutter(2),
			\pan, -0.1,
			\isRest, Pseq([
				1,1,1,1, 
			],inf).coin.not,
			\rel, Pseq([
				1,1,1,1, 1,1,8,1,
			],inf)*0.1,
			\dur, 1/8,
			\sustain, Pseq([
				0.05, 0.02, 0.05, 0.02,
				0.05, 0.02, 1/6/~t, 0.02,
			],inf)/2,
			\amp, 0.1/2,
			\amp, Pkey(\amp) * Pseq([
				1, 0.7, 0.9, 0.5,
				Plazy({ Pseq([
					1, 0.7, 0.9, 0.5,
				].scramble,1) }),
			],inf),
		),

		
	])
).play;
)


////////////////////////////////// compo
/// here the \lag of 0.08 change totally the rhytm
// tricks used here
//	- side pattern to add 16th notes to hat
//	- ghost snare
//	- 

~t = 96/2/60; TempoClock.default.tempo = ~t;

(
Pdef(\testdrums3, 
	Ppar([
		Pbind(
			\instrument, \snapkick,
			\isRest, Pseq([
				1,0,0,1, 0,0,0,0,
				1,0,0,0, 0,1,0,0,
			],inf).coin.not,
			\dur, 1/8,
			\sustain, 0.1/2,
			\amp, 0.1
		),
		Pbind(
			\instrument, \snarebpf,
			\sustain, 0.1/2,
			\adsr, Pseq([
				 [ Env.adsr(0.1/3,0.1,0.8,0.2,1,-6) ]
			],inf),
			\isRest, Pseq([
				0,0,0,0, 1,0,0,0,
			],inf).coin.not,
			\dur, 1/8,
			\pan, 0.1,
			\amp, 0.1,
		),
		Pbind(
			\instrument, \snarebpf,
			\sustain, 0.04,
			\adsr, Pseq([
				 [ Env.adsr(0.1/2,0.1,0.8,0.1,1,-6) ]
			],inf),
			\isRest, Pseq([
				0,0,0,0, 0,0,0,1,
				0,0,0,0, 0,1,0,1,
				0,0,1,0, 0,0,1,0,
				0,1,0,0, 0,0,0,1,
			],inf).coin.not,
			\dur, 1/8,
			\pan, 0.1/2,
			\amp, 0.1/3,
		),
		Pbind(
			// lagger
			\instrument, \stickfight,
			\sustain, 0.04,
			\adsr, Pseq([
				 [ Env.adsr(0.1/2,0.1,0.8,0.1,1,-6) ]
			],inf),
			\isRest, Pseq([
				Pseq([
					0,0,0,0, 0,0,0,0,
				],4),
				0,0,0,0, 0,0,0,1,
				0,0,0,0, 0,1,0,1,
				0,0,1,0, 0,0,1,0,
				0,1,0,0, 0,0,0,1,
			],inf).coin.not,
			\dur, 1/8,
			\lag, 0.08,
			\pan, 0.1/2,
			\amp, 0.1/3,
		),
		Pbind(
			\instrument, \phycymbal,
			\sustain, 0.1/3,
			\adsr, Pseq([
				 [ Env.adsr(0.001,0.1,1.8,0.07,1,-3) ],
				 [ Env.adsr(0.002,0.1,0.8,0.04,1,-3) ],
			],inf).stutter(2),
			\pan, -0.1,
			\isRest, Pseq([
				1,1,1,1, 
			],inf).coin.not,
			\rel, Pseq([
				1,1,1,1, 1,1,8,1,
			],inf)*0.1,
			\dur, 1/8,
			\sustain, Pseq([
				0.05, 0.02, 0.05, 0.02,
				0.05, 0.02, 1/6/~t, 0.02,
			],inf)/2,
			\amp, 0.1/2,
			\amp, Pkey(\amp) * Pseq([
				1, 0.7, 0.9, 0.5,
				Plazy({ Pseq([
					1, 0.7, 0.9, 0.5,
				].scramble,1) }),
			],inf),
		),
		Pbind(
			\instrument, \phycymbal,
			\sustain, 0.1/3,
			\adsr, Pseq([
				 [ Env.adsr(0.001,0.1,1.8,0.07,1,-3) ],
				 [ Env.adsr(0.002,0.1,0.8,0.04,1,-3) ],
			],inf).stutter(2),
			\pan, -0.1,
			\isRest, Pseq([
				0,0,0,0, 0,0,0,0,
				0,0,0,0, 0,0,0,1,
				0,0,0,0, 0,0,0,0,
				0,0,0,0, 0,0,0,0,

				0,0,0,0, 0,0,0,0,
				0,1,0,0, 0,0,0,0,
				0,0,0,0, 0,0,0,0,
				0,0,0,0, 0,0,0,0,

				0,0,0,0, 0,0,0,0,
				0,0,0,0, 0,0,0,0,
				0,0,0,0, 0,1,0,1, 
				0,0,0,0, 0,0,0,0,

				0,0,0,0, 0,0,0,0,
				0,0,0,0, 0,0,0,0,
				0,0,0,0, 0,0,0,0,
				0,0,0,0, 0,0,0,0,

				0,0,0,0, 0,0,0,0,
				0,1,0,1, 0,0,0,0,
				0,0,0,0, 0,0,0,0,
			],inf).coin.not,
			\rel, Pseq([
				1,1,1,1,
			],inf)*0.1,
			\dur, 1/16,
			\sustain, Pseq([
				0.05, 0.02, 0.05, 0.02,
				0.05, 0.02, 1/6/~t, 0.02,
			],inf)/2,
			\amp, 0.1/2,
			\amp, Pkey(\amp) * Pseq([
				1, 0.7, 0.9, 0.5,
				Plazy({ Pseq([
					1, 0.7, 0.9, 0.5,
				].scramble,1) }),
			],inf),
		),

		
	])
).play;
)

//////////////////////////////////:


(
	// nice generic hat cymbal
SynthDef(\noiser, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, tsustain=1;
	var sig;
	var hpfenv = EnvGen.kr(\hpfenv.kr(Env([1,2,1,2],[0.1,0.8,0.1].normalizeSum)), gate, timeScale:tsustain);
	var lpfenv = EnvGen.kr(\lpfenv.kr(Env([1,2,1,2],[0.1,0.8,0.1].normalizeSum)), gate, timeScale:tsustain);
	var bpfenv = EnvGen.kr(\bpfenv.kr(Env([2,1/2,1,2],[0.1,0.8,0.1].normalizeSum)), gate, timeScale:tsustain);
	sig = WhiteNoise.ar;
	sig = HPF.ar(sig, \hpf.kr(200) * hpfenv);
	sig = LPF.ar(sig, \lpf.kr(10000) * lpfenv);
	sig = sig + BPF.ar(sig, \bpf.kr(200) * bpfenv, \rq.kr(0.1));
	sig = sig * EnvGen.kr(\adsr.kr(Env.adsr(0.01,0.1,0.8,0.1)), gate, doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;

		Pdef(\perc,Pbind(
			\instrument, \noiser,
			\lpfenv, [ Env([1,1,1/2,1],[0.1,0.1,0.8]) ],
			\adsr, Pseq([
				[ Env.adsr(0.01,0.1,0.8,0.1) ],
			],inf),
			\hpf, 200,
			\hpfenv, [ Env([1/2,74,82,81],[0.4,0.1,0.8]) ],
			\isRest, Pseq([
				0,0,1,0, 0,0,0,0,
			],inf).coin.not,
			\tsustain, 1/2/~t,
			\legato, 2,
			\dur, 1/8,
			\amp, 0.1
		)).play;
);

///////////////////////////////////////////////////
// congas (or whatever)


(
SynthDef(\conga, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3, sig4, sig5;
	sig1 = LFTri.ar(111);
	sig1 = FreqShift.ar(sig1, 175);
	sig1 = sig1 + FreqShift.ar(sig1, [224 * \harm2.kr(1),224 * \harm1.kr(1)]);
	sig1 = sig1 * EnvGen.ar(Env.perc(0.0001,0.22), gate);

	sig2 = SinOsc.ar(330) + SinOsc.ar(180);
	sig2 = sig2 * EnvGen.ar(Env.perc(0.0001,0.151), gate);

	sig3 = PinkNoise.ar(1);
	sig3 = BRF.ar(sig3, [100,800,300,400]*2).sum;
	sig3 = LPF.ar(sig3, [5000,6000,100,10000]*1);
	sig3 = sig3 * EnvGen.ar(Env.perc(0.0001,0.201, 1, \sqr), gate);

	sig4 = WhiteNoise.ar(1);
	sig4 = BRF.ar(sig4, [100,900,300,400]*4).sum;
	sig4 = LPF.ar(sig4, [500,4000,100,1000]*2*XLine.kr(1,0.100,0.01));
	sig4 = sig4 * EnvGen.ar(Env.perc(0.0001,0.251, 1, \cub), gate);

	sig5 = PinkNoise.ar(1) * sig2;
	//sig5 = BRF.ar(sig5, [100,800,300,400]*2).sum;
	sig5 = LPF.ar(sig5, [500,600,100,1000]*0.21);
	sig5 = sig5 * EnvGen.ar(Env.perc(0.0001,0.111, 1, \sqr), gate) * 4;

	sig = sig1 + sig3 + sig4 + sig5;
	//sig = (HPF.ar(sig,100)*14).distort + LPF.ar(sig, 100);
	sig = sig * 2;




	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.0001,0.1,0.8,2.4)),gate,doneAction:doneAction);
	//sig = DetectSilence.ar(sig, doneAction:2);
	sig = Splay.ar(sig, spread, amp, pan);
	Out.ar(out, sig);
}).add;

Pdef(\conga, Pbind(
	\instrument, \conga,
	\harm1, Pseq([
		Pseq([1,1.92],12).stutter(4),
		Pseq([1.2,1.42],4).stutter(4),
	],inf),
	\freq, 100,
	\dur, 1/8,
	\isRest, Pseq([
		Pser([
			0,0,0,0, 1,0,0,0,
			0,0,1,0, 0,0,0,0,
			0,0,0,0, 1,0,0.5,0,
			0.51,0,0,0, 1,0,0,0,
		],inf),
	],inf).coin.not,
)).play;
)

//////////////////////////

(
SynthDef(\hardhat, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3, sig4, sig5;
	sig1 = LFTri.ar(111);
	sig1 = FreqShift.ar(sig1, 175);
	sig1 = sig1 + FreqShift.ar(sig1, 224);
	sig1 = sig1 * EnvGen.ar(Env.perc(0.0001,0.02), gate);

	sig2 = SinOsc.ar(330) + SinOsc.ar(180);
	sig2 = sig2 * EnvGen.ar(Env.perc(0.0001,0.051), gate);

	sig3 = PinkNoise.ar(1);
	sig3 = BRF.ar(sig3, [100,800,300,400]*2).sum;
	sig3 = LPF.ar(sig3, [5000,6000,100,10000]*2);
	sig3 = sig3 * EnvGen.ar(Env.perc(0.0001,0.151), gate);

	sig4 = WhiteNoise.ar(1);
	sig4 = BRF.ar(sig3, [100,800,300,400]*2).sum;
	sig4 = LPF.ar(sig3, [5000,6000,100,10000]*1);
	sig4 = sig3 * EnvGen.ar(Env.perc(0.0001,0.151), gate);

	sig = sig1 + sig2 + sig3 + sig4;
	sig = (HPF.ar(sig,100)*14).distort + LPF.ar(sig, 100);
	sig = sig * 1;




	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.0001,0.1,0.8,0.4)),gate,doneAction:doneAction);
	//sig = DetectSilence.ar(sig, doneAction:2);
	sig = Splay.ar(sig, spread, amp, pan);
	Out.ar(out, sig);
}).add;

Pdef(\hardhat, Pbind(
	\instrument, \hardhat,
	\freq, 100,
	\dur, 1/8,
	\isRest, Pseq([
		Pser([
			1,0,0,0, 0,0,0,0,
		],inf),
	],inf).coin.not,
)).play;
);

//////////////////////////////////////////////

// frapper sur de la taule

(
SynthDef(\taule, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3, sig4, sig5;
	var osig, asig;
	sig1 = LFTri.ar(291);
	sig1 = FreqShift.ar(sig1, 75);
	sig1 = sig1 + FreqShift.ar(sig1, 24);
	sig1 = sig1 * EnvGen.ar(Env.perc(0.0001,0.01), gate) * 1;

	sig2 = SinOsc.ar(330) + SinOsc.ar(210);
	sig2 = sig2 * EnvGen.ar(Env.perc(0.0001,0.03), gate) * 1;

	sig3 = SinOsc.ar(100, SinOsc.ar(10, SinOsc.ar(40)) * 122);
	sig3 = SinOsc.ar(615.00, 
		LFSaw.ar(410.87) +
			WhiteNoise.ar(2) +
		SinOsc.ar(487, 
			WhiteNoise.ar(4) +
			SinOsc.ar(4390, 
				WhiteNoise.ar(1) +
				SinOsc.ar(497) * 10.43) 
			* 1.250) 
		* 1.31);
	//sig3 = WhiteNoise.ar(1);
	sig3 = BRF.ar(sig3, [100,800,300,400]*1).sum;
	sig3 = BPF.ar(sig3, [100,100,100,200]*6);
	sig3 = sig3 * EnvGen.ar(Env.perc(0.0001,0.151, 1, \sqr), gate);

	sig4 = WhiteNoise.ar(1);
	sig4 = BRF.ar(sig4, [100,800,1900,400,900]*2).sum;
	sig4 = BPF.ar(sig4, [500,3000,740,1000]*1*XLine.kr(1,0.1100,[0.13,0.1,0.3]));
	sig4 = sig4 * EnvGen.ar(Env.perc(0.0001,0.451, 1, \cub), gate);
	asig = sig4;

	sig4 = WhiteNoise.ar(1);
	sig4 = BRF.ar(sig4, [100,800,1900,400,900]*1).sum;
	sig4 = LPF.ar(sig4, [500,3000,740,1000]*1*XLine.kr(1,0.5100,[0.13,0.1,0.3]));
	sig4 = sig4 * EnvGen.ar(Env.perc(0.0001,0.451, 1, -4), gate);

	sig = 
		0
		+ sig1
		+ sig2 
		+ sig3
		+ sig4
		+ asig
		;
	sig = (HPF.ar(sig,4000 * XLine.kr(1,0.01,0.02))*4).tanh + LPF.ar(sig, 1200);


	osig = sig;
	sig = AllpassL.ar(sig,0.1,[0.012,0.02,0.014,0.0132] *2,0) + sig;
	sig = AllpassL.ar(sig,0.1,0.001,0) + sig;
	sig = LPF.ar(sig, 3000);
	//sig = BRF.ar(sig, [100,940,1700,4000,9000]*1) / 2;
	sig = sig + osig;
	//sig = osig;
	sig.postln;
	sig = sig * 0.51;


	//sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.00001,0.1,0.1,0.2,1,\sqr)),gate,doneAction:doneAction);
	sig = Splay.ar(sig, spread, amp, pan);
	DetectSilence.ar(sig, 0.001,0.1,doneAction:2);
	Out.ar(out, sig);
}).add;

Pdef(\perc, Pbind(
	\instrument, \taule,
	\freq, 100,
	\dur, 1/4,
	\isRest, Pseq([
		Pser([
			1,0,0,0, 0,0,0,0,
		],inf),
	],inf).coin.not,
)).play;
)

///////////
(
SynthDef(\taule, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3, sig4, sig5;
	var osig, asig;
	sig1 = LFTri.ar(291);
	sig1 = FreqShift.ar(sig1, 75);
	sig1 = sig1 + FreqShift.ar(sig1, 24);
	sig1 = sig1 * EnvGen.ar(Env.perc(0.0001,0.01), gate) * 1;

	sig2 = SinOsc.ar(330) + SinOsc.ar(210);
	sig2 = sig2 * EnvGen.ar(Env.perc(0.0001,0.03), gate) * 1;

	sig3 = SinOsc.ar(100, SinOsc.ar(10, SinOsc.ar(40)) * 122);
	sig3 = SinOsc.ar(615.00, 
		LFSaw.ar(410.87) +
			WhiteNoise.ar(2) +
		SinOsc.ar(487, 
			WhiteNoise.ar(4) +
			SinOsc.ar(4390, 
				WhiteNoise.ar(1) +
				SinOsc.ar(497) * 10.43) 
			* 1.250) 
		* 1.31);
	//sig3 = WhiteNoise.ar(1);
	sig3 = BRF.ar(sig3, [100,800,300,400]*2).sum;
	sig3 = BPF.ar(sig3, [100,100,100,200]*1);
	sig3 = FreqShift.ar(sig3, -400)+sig3/2;
	sig3 = FreqShift.ar(sig3, 300)+sig3/2;
	sig3 = sig3 * EnvGen.ar(Env.perc(0.1001,0.151, 1, -1), gate);

	sig4 = WhiteNoise.ar(1);
	sig4 = BRF.ar(sig4, [100,800,1900,400,900]*2).sum;
	sig4 = BPF.ar(sig4, [500,3000,740,1000]*1*XLine.kr(1,4.7100,[0.13,0.1,0.3]));
	sig4 = sig4 * EnvGen.ar(Env.perc(0.0001,0.151, 1, \cub), gate);
	asig = sig4;

	sig4 = WhiteNoise.ar(1);
	sig4 = BRF.ar(sig4, [100,800,1900,400,900]*2).sum;
	sig4 = LPF.ar(sig4, [500,3000,740,1000]*1*XLine.kr(1,2.7100,[0.13,0.1,0.3]));
	sig4 = sig4 * EnvGen.ar(Env.perc(0.1001,0.051, 1/2, 4), gate);

	sig = 
		0
		+ sig1
		+ sig2 
		+ sig3
		+ sig4
		+ asig
		;
	sig = (HPF.ar(sig,4000 * XLine.kr(1,0.51,0.02))*4).tanh + LPF.ar(sig, 1200);


	osig = sig;
	sig = AllpassL.ar(sig,0.1,[0.012,0.02,0.014,0.0132] *2,0) + sig;
	sig = AllpassL.ar(sig,0.1,0.001,0) + sig;
	sig = LPF.ar(sig, 3000);
	//sig = BRF.ar(sig, [100,940,1700,4000,9000]*1) / 2;
	sig = sig + osig;
	//sig = osig;
	sig.postln;
	sig = sig * 0.51;


	//sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.00001,0.1,0.1,0.2,1,\sqr)),gate,doneAction:doneAction);
	//sig = Splay.ar(sig, spread, amp, pan);
	sig = Pan2.ar(sig, pan, amp).mean*2;
	DetectSilence.ar(sig, 0.001,0.1,doneAction:2);
	Out.ar(out, sig);
}).add;

Pdef(\perc, Pbind(
	\instrument, \taule,
	\freq, 100,
	\dur, 1/4,
	\isRest, Pseq([
		Pser([
			1,0,0,0, 0,0,0,0,
		],inf),
	],inf).coin.not,
)).play;
)

///////////////////////////////////////////////
//racle perc

(
~buf = BufDef(\crepe, "field/crepe.flac");
Pdef(\racle, 
	Pbind(
		\instrument, \oscsampler3,
		\pos, 0.014 + Pseq([0,1,0,2],inf).stutter(8)/100,
		\pos, 0.110,
		\freq, Pseq([100,200,150,200]*4,inf) * Pseg(Pseq([0.25,2],inf),10),
		\range, 0.000001,
		\posenv, Pseq([
			//[ Env([0.42,0.3903,0.3513],[0.3,0.4]) ],
			//[ Env([0.00,0.0189,0.401].integrate.postln,[0.01,0.1]) ],
			[ Env([0.00,0.0011,0.0012].integrate.postln,[0.01,0.1]) ],
			[ Env([0.00,0.0001,0.0012].integrate.postln,[0.01,0.1]) ],
			[ Env([0.00,0.0001,0.0012].integrate.postln,[0.01,0.1]) ],
			[ Env([0.00,0.0001,0.0012].integrate.postln,[0.01,0.1]) ],
		],inf),
		//\finepos, ~envNdefq.(~name+++\lfo1, Env([1,2]/100,1/t)),
		\legato, Pseq([0.4,0.2,0.8,0.2],inf) * Pseg(Pseq([0.5],inf),8),
		\dur, 1/4,
		\fshift, 0,
		\lpmix, Pseq([0,0,0.56,1, 0,1,0,1, 0.2,0.5,0.7,0.2],inf),
		\isRest, false,
		\ffreq, Pseq([1000,500],inf).stutter(1),
		\amp, 24.0 * Pkey(\amp),
		\amp, Pkey(\amp) * Pseq([
			0.5,0.2,1,0.2,
			0.7,0.4,1,0.2,
		],inf) + Pwhite(0.0,0.1),

	) <>
	
	Pbind(
		\pos, Pseq([0.0,0.01,0.02,0.03],inf),
		\pos, Pseg(Pseq([0,0.1],inf),32)+0.8,
		\pos, 0.172,
		\posenv, Pseq([
			//[ Env([0.42,0.3903,0.3513],[0.3,0.4]) ],
			[ Env([0.001,0.002,0.004].integrate.postln,[0.01,0.1]) ],
			[ Env([0.001,0.003,0.004].integrate.postln,[0.01,0.1]) ],
			[ Env([0.101,0.0013,0.004].integrate.postln,[0.01,0.1]) ],
		],inf),
		\fshift, 0,
		\fshift, -48,
		\fshift, Pseq([0,48,-40],inf),
		\lpmix, 0.79,
		\rq, 0.1,
		\posenv, Pseq([
			//[ Env([0.42,0.3903,0.3513],[0.3,0.4]) ],
			[ Env([0.001,0.0089,-0.3481].integrate.postln,[0.01,0.1]) ],
		],inf),
		//\pos, Ndef(~name+++\lfo1),
		//\pos, Pseq([0,0.1,0.5],inf) + Pwhite(0,0.01),
		//\finepos, Ndef(~name+++\lfo1),
		//\range, Pseg(Pseq([0.001,0.21],inf),8),
		//\range, Ndef(~name+++\lfo2),
		\range, 0.0001,
		\ffreq, Pseq([100,300,200,200],inf),
		\ffreq, Pseq([60,1000,3000,200,2000],inf),
		\ffreq, Pseq([60,70,100,120],inf),
		\ffreq, Pseq([3000,120],inf),
		\ffreq, Pseq([6000,4000,120,300],inf),
		\ffreq, Pwhite(50,10000).stutter(16),
		//\ffreq, 2000,
		\bufnum, ~buf,
		\freq, Pseq([
			Pser([50,55],16),
			Pser([40,45],16-4),
			100,1040,120,300,
		],inf),
		\ffreqtab, Pseq([[Array.series(8,0.5,0.1).postln]],inf),
		\ffreqtab, Pn(Plazy({
			[{ 1.rand } ! 8]
		})),
		\ffreqtab, Pseq([[Array.geom(8,1.8,1.2).postln]],inf),
		\ffreqtab, Pseq([
			[[2.3,3.2,0.1,0.1, 0.2,0.8,1.2,1.5]],
		],inf),
		\dur, 1/8,
		\pos, Pwhite(0.0,0.4).stutter(32),
		\pos, Pseq([0.1,0.1],inf).stutter(2),
		\adsr, Pseq([
			[ Env.adsr(0.01,0.3,0.5,0.01) ],
		],inf),
		\isRest, Pseq([1],inf).coin.not,
		\isRest, Pseq([
			Pser([1],1),
			Pser([0,0,0,0],4),
		],inf).coin.not,
		\legato, Pseq([1,0.4,1,0.3, Pn(1,4)],inf),
		\legato, Pseq([
			Pser([1,1,1,1],32-4),
			0.6,1.0,1.0,0.6
		],inf),
		\legato, Pseq([
			1,0.2,0.1,0.2,
			1,1,1,1,

			1,0.2,0.1,0.2,
			1,1,1,1,

			1,0.5,1,1,
			1,1,1,1,
		],inf),
		\legato, Pseq([
			Pser([
				1.0,1.3,0.9,0.8,
				1.0,0.3,0.9,0.3,
			], 64),
			Pser([1,1,1,1],32),
			Pser([1,0.31,1,1],32),
		],inf).collect({ arg x; if(x == 1) { 1 } { if(x.coin) { 1 } { x.rand + 0.1 } } }),
		\legato, Pseq([
			1,1,1,1,
			1,1,1,0.1,
		],inf).stutter(4),
		//\lag, Pseq([0.05, 0, 0.05, 0],inf) / t,
		\isRest, false,
	)
).play;
)

/////////////////////////////////


(
SynthDef(\cling, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	env1 = EnvGen.kr(Env([1/8,1,1/2,1/4],[0.01,1.7,4],-3), 1);
	sig1 = ( 1 + ( SinOsc.ar(rrand(0.01,1000!4)) * rrand(0.1,10!4) ));
	sig = SinOsc.ar(exprand(50.0,1000!4) * env1 * ( 1 + ( SinOsc.ar(rrand(0.01,1000!4) * sig1) * rrand(0.01,10!4))));
	sig = sig * ( 1 + ( SinOsc.ar(rrand(100.0,1000!4)) * 1 ));
	sig = CombL.ar(sig, 0.01,1/rrand(100.0,1000!14)) + sig;
	sig = CombL.ar(sig, 0.01,1/rrand(100.0,1000!14)) + sig;
	sig = ( sig*\distamp.kr(10) ).tanh * \distpostamp.kr(1/2);
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,0.4,1,-4),gate,doneAction:2);
	sig = Pan2.ar(sig, pan, amp).mean * 4;
	Out.ar(out, sig);
}).add;
Pdef(\cling, Pbind(\instrument, \cling,
	\degree, Pseq([0],inf),
	\legato, Pseq([
		0.1,0.1, 0.1,0.1,
	],inf),
	\dur, 1,
	\amp, 0.1,
)).play;
);


/////////////////// funky drummer accelerated by pattern

(
Pdef(\test, 
	Ppar([
		Pbind(
			\instrument, \playersec,
			\bufnum, BufDef('loop/funky3_135bpm.flac'),
			\isRest, Pseq([
				1,
			],inf).coin.not,
			\pos, Pseq([
				Pseq((1..16))
			],inf)/4/~t+0.04,
			\speed, 1,
			\gain, 1,
			\freq, 200,
			\legato, 1.00,
			\dur, Pseq([1/8],inf),
			\amp, 0.1,
		),
	])
).play;
)

/////////////////////


(
SynthDef(\chh, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	env1 = EnvGen.kr(Env([12000,182,61],[4.1,2.8],[1,1]),1);
	env2 = EnvGen.kr(Env([1000,152,91],[4.1,2.8],[1,1]), 1);
	env3 = EnvGen.kr(Env([7100,1000,100],[4.5,0.8],[1,1]), 1);
	sig = WhiteNoise.ar;
	sig = Ringz.ar(sig, rrand(70.0!8,1000),0.01).mean;
	//sig = RLPF.ar(sig, env2, \rq2.kr(0.8));
	sig = RLPF.ar(sig,  [env3, env2, env1 ], \rq.kr(0.5));
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,2.4),gate,doneAction:2);
	sig = Pan2.ar(sig, [-1,0,1]*0.1, amp).mean;
	Out.ar(out, sig);
}).add;
);

(
Pdef(\demo, Pdef(\plop, 
	Ppar([
		Pbind(
			\instrument, \chh,
			\freq, 200,
			\dur, 4,
			\amp, 0.1,
		);
	])
)).play;
)

/////////////////////
(
SynthDef(\iron, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	// cpu light
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	sig = SinOsc.ar(freq * ( LFSaw.ar(freq * \fmr.kr(4) * ((0..7)/7 - 0.5 * \diff.kr(1) + 1)) * \fmamp.kr(1) + 1 ));
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.01,0.1,0.8,0.1)),gate,doneAction:2);
	sig = sig.fold( SinOsc.ar( (1..8)/8, (1..8) ) * \foldlevel.kr(1) + \foldbias.kr(1) ).flop.mean;
	sig.debug("sig");
	env1 = EnvGen.kr(\env1.kr(Env(2.01-[1,2,1],[0.1,0.8])), \trigenv.tr(1));
	sig = RLPF.ar(sig, \lpfr.kr(1.7) * env1 * freq, \rq.kr(0.5));
	pan = pan + sig.collect({ arg x;
		SinOsc.kr(1/( x+1 ));
	});
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
Pdef(\demo, Pdef(\plop, 
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
				0,0,0,0, 4,0,0,0, 0,0,0,0, 1,0,0,0,
			],inf)/10,
			\isRest, Pfunc({ arg ev; ev[\legato] <= 0 }),
			\dur, 1/16,
			\amp,0.05,
		),
	])
)).play;
)


/////////// FM Cowbell
(
SynthDef(\fmcowbell, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	// cpu light
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	sig = SinOsc.ar(freq * ( LFSaw.ar(freq * \fmr.kr(4) * ((0..7)/7 - 0.5 * \diff.kr(1) + 1)) * \fmamp.kr(1) + 1 ));
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(1/70,0.1,0.8,0.2)),gate,doneAction:2);
	sig = sig.fold(\fold.kr(0.23));
	sig = sig * \gain.kr(1);
	sig = Pan2.ar(sig, pan, amp).mean;
	Out.ar(out, sig);
}).add;
Pdef(\plop, Pbind(
	\instrument, \fmcowbell,
	\freq, 5200,
	\fmr, 1/2,
	\diff, 0.2,
	\fold, 0.7,
	\gain, 1,
	\sustain, 0.1,
	\dur, 1,
	\amp, 0.1,
)).play;
)
