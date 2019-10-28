(

///////////////////////////////////////  Drone

SynthDef(\drono, { arg out = 0, freq=200, pan=0, amp=0.1;
	var sig;
	sig = SinOsc.ar(freq * ( 1 + ( SinOsc.kr(freq*1.123) * 1 ))) * LFSaw.ar(freq*4/3 * SinOsc.kr(1/12).range(1.1,1)) ;
	sig = RLPF.ar(sig, 3000 * LFNoise1.ar(1/13!4).range(1/4,4), \rq.kr(0.5) * LFNoise1.ar(1/13!4).range(1/4,2)).mean;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;

SynthDef(\algofm, { arg out = 0, freq=3200, pan=0, amp=0.1;
	var sig;
	var op;
	var randfreq;

	op = { arg freq;
		[
			LFSaw.ar(freq),
			LFPulse.ar(freq),
			LFCub.ar(freq),
			SinOsc.ar(freq),
			WhiteNoise.ar,
		].choose;
	};

	randfreq = {
		exprand(1/20,14000);
	};

	sig = op.(exprand(200, 14000));

	15.do { arg idx;
		var algos = [
			{ op.(sig * exprand(0.01,2) + 1 * randfreq.value); }, // fm
			{ op.(sig * exprand(0.01,2) + 1 * randfreq.value) + sig; }, // fm + sig
			{ sig * exprand(0.01,2) + 1 * op.(randfreq.value); }, // am
			{ sig * op.(randfreq.value); }, // ring
			{ sig + op.(randfreq.value); }, // sum
		];
		sig = algos.choose.value;
	};

	sig = LPF.ar(sig, 14000);
	sig = HPF.ar(sig, 140);
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;

SynthDef(\ambi, { arg out = 0, freq=200, pan=0, amp=0.1;
	var sig;
	sig = ( WhiteNoise.ar + 0.8 ) * LFSaw.ar({ exprand(100.0,10000) }!20 * ( 1 + ( SinOsc.kr((1..4).rand(0.0)/18) * 1/41 )));
	sig = DelayC.ar(sig, {rrand(1/100,1/10000)}!4) + sig / 2;
	sig = DelayC.ar(sig, {rrand(1/100,1/10000)}!4) + sig / 2;
	sig = BRF.ar(sig, { ( exprand(100.0,10000) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(20,20000) }!10,1);
	sig = LeakDC.ar(sig) * 5;
	sig = Pan2.ar(sig, pan, amp).mean;
	Out.ar(out, sig);
}).add;

SynthDef(\ambi1, { arg out = 0, freq=200, pan=0, amp=0.1;
	var sig;
	sig = ( WhiteNoise.ar + 0.8 ) * LFSaw.ar({ exprand(10.0,10000) }!20 * ( 1 + ( SinOsc.kr((1..4).rand(0.0)/18) * 1/41 )));
	sig = DelayC.ar(sig, 0.2, {rrand(1/5,1/10000)}!4) + sig / 2;
	sig = DelayC.ar(sig, 0.2, {rrand(1/5,1/10000)}!4) + sig / 2;
	sig = sig + BPF.ar(
		sig,
		{ ( exprand(100.0,10000) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(20,20000) }!10,
		{ ( rand(0.01,1) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(0.01,1) }!10
	);
	sig = BRF.ar(
		sig,
		{ ( exprand(100.0,10000) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(20,20000) }!10,
		{ ( rand(0.01,1) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(0.01,1) }!10
	);
	sig = LeakDC.ar(sig);
	sig = LPF.ar(sig, 17000);
	sig = sig * 5 * 2;
	sig = Pan2.ar(sig, pan, amp).mean;
	Out.ar(out, sig);
}).add;

SynthDef(\ambi2, { arg out = 0, freq=200, pan=0, amp=0.1;
	var sig;
	sig = ( WhiteNoise.ar + 0.8 ) * LFSaw.ar({ exprand(10.0,10000) }!20 * ( 1 + ( SinOsc.kr((1..4).rand(0.0)/18) * 1/41 )));
	sig = DelayC.ar(sig, 0.2, {rrand(1/5,1/10000)}!4) + sig / 2;
	sig = DelayC.ar(sig, 0.2, {rrand(1/5,1/10000) * XLine.kr(1,1/1000,14)}!4) + sig / 2;
	sig = sig + BPF.ar(
		sig,
		{ ( exprand(100.0,10000) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(20,20000) }!10,
		{ ( rand(0.01,1) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(0.01,1) }!10
	);
	sig = BRF.ar(
		sig,
		{ ( exprand(100.0,10000) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(20,20000) }!10,
		{ ( rand(0.01,1) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(0.01,1) }!10
	);
	sig = LeakDC.ar(sig);
	sig = LPF.ar(sig, 17000 * XLine.kr(1/100,1,4));
	sig = sig * 5 * 3;
	sig = Pan2.ar(sig, pan, amp).mean;
	Out.ar(out, sig);
}).add;

SynthDef(\fall, { arg out = 0, freq=200, pan=0, amp=0.1;
	var sig;
	sig = ( WhiteNoise.ar + 0.8 ) * LFSaw.ar({ exprand(10.0,10000) }!20 * ( 1 + ( SinOsc.ar(rrand(1,4.0!4)/18 * XLine.kr(1,121200,80)) * 1/41 * XLine.kr(1,180,60) )));
	sig = DelayC.ar(sig, 0.2, {rrand(1/5,1/10000) }!4* ( 1 + ( SinOsc.ar(rrand(1,4.0!4)/12 * XLine.kr(0.001,121200,60)) * 1/41 * XLine.kr(1,180,60) ))) + sig / 2;
	sig = DelayC.ar(sig, 0.2, {rrand(1/5,1/10000) * XLine.kr(1,1/1000,14)}!4) + sig / 2;
	sig = sig + BPF.ar(
		sig,
		{ ( exprand(100.0,10000) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(20,20000) }!10,
		{ ( rand(0.01,1) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(0.01,1) }!10
	);
	sig = BRF.ar(
		sig,
		{ ( exprand(100.0,10000) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(20,20000) }!10,
		{ ( rand(0.01,1) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(0.01,1) }!10
	);
	sig = LeakDC.ar(sig);
	sig = LPF.ar(sig, 17000 * XLine.kr(1/100,1,4));
	sig = sig * 5 * 1/3;
	sig = sig.debug("sig1");
	sig = sig.flop.clump(2).mean;
	sig = sig.debug("sig");
	sig = sig * amp;
	Out.ar(out, sig);
}).add;

SynthDef(\fall1, { arg out = 0, freq=200, pan=0, amp=0.1;
	var sig;
	sig = ( WhiteNoise.ar + 0.8 ) * LFSaw.ar({ exprand(10.0,10000) }!20 * ( 1 + ( SinOsc.ar((1..4).rand(0.0)/18 * XLine.kr(1,121200,80)) * 1/41 * XLine.kr(1,180,60) )));
	sig = DelayC.ar(sig, 0.2, {rrand(1/5,1/10000) * ( 1 + ( SinOsc.ar((1..2).rand(0.0)/18 * XLine.kr(1,121200,60)) * 1/41 * XLine.kr(1,180,60) ))}!4) + sig / 2;
	sig = DelayC.ar(sig, 0.2, {rrand(1/5,1/10000) * XLine.kr(1,1/1000,14)}!4) + sig / 2;
	sig = sig + BPF.ar(
		sig,
		{ ( exprand(100.0,10000) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(20,20000) }!10,
		{ ( rand(0.01,1) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(0.01,1) }!10
	);
	sig = BRF.ar(
		sig,
		{ ( exprand(100.0,10000) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(20,20000) }!10,
		{ ( rand(0.01,1) * LFNoise1.ar(1/100.0.rand).range(1,2) ).clip(0.01,1) }!10
	);
	sig = LeakDC.ar(sig);
	sig = LPF.ar(sig, 17000 * XLine.kr(1/100,1,4));
	sig = sig * 5 * 3;
	sig = sig.mean;
	sig = sig * amp;
	Out.ar(out, sig);
}).add;

SynthDef(\drone1, { arg out = 0, freq=200, pan=0, amp=0.1;
	var sig;
	sig = WhiteNoise.ar;
	sig = Klank.ar(Ref([ exprand(20.0,10100!48), 0.001!8 ]), sig);
	sig = sig  / 1;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;

SynthDef(\drone2, { arg out = 0, freq=200, pan=0, amp=0.1;
	var sig;
	sig = WhiteNoise.ar;
	sig = Klank.ar(Ref([ exprand(20.0,10100!48!2), 0.001!8 ]), sig);
	//sig = sig * SinOsc.kr(8).range(0,1);
	sig = sig * EnvGen.kr(\env.kr(Env([0,2,1,0],[0.1,0.8,0.1].normalizeSum)), Impulse.kr(4), timeScale:1/2);
	sig = sig  / 4;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;

SynthDef(\drone3, { arg out = 0, freq=200, pan=0, amp=0.1;
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	env1 = XLine.kr(1,10,10);
	sig = WhiteNoise.ar;
	sig = Klank.ar(Ref([ exprand(20.0,10100!2!48), 0.001!8 ]), sig);
	sig = sig.debug("sig");
	sig = FreqShift.ar(sig, XLine.kr(0.0001,1000*[1,2,3],10*[1,2,3])).sum + sig;
	//sig = sig * SinOsc.kr(8).range(0,1);
	//sig = sig.clump(2).sum;
	sig = sig * EnvGen.kr(\env.kr(Env([0,2,1,0],[0.1,0.8,0.1].normalizeSum)), Impulse.kr(4*env1), timeScale:1/2);
	sig = sig  * 2;
	sig = sig * amp;
	Out.ar(out, sig);
}).add;

SynthDef(\drone4, { arg out = 0, freq=200, pan=0, amp=0.1;
	var sig;
	sig = WhiteNoise.ar;
	sig = 2.collect({
		DynKlank.ar(Ref([ rrand(0,1.0!48).round(SinOsc.kr(1/10).range(0.0001,1/80) ).linexp(0,1,20.0,15000) * [ [1,1.0 + SinOsc.kr(1/11).range(0,0.0051)] ], 0.001!8 ]), sig);
	});
	sig = sig.collect({ arg isig;
		isig * SinOsc.kr(rrand(0.1,1)).range(0,1)
	});

	sig = sig  / 1;
	sig = sig.debug("sig");
	sig = sig * amp;
	Out.ar(out, sig);
}).add;

SynthDef(\drone5).put(0, { arg out = 0, amp = 0.1;
	var sig;
	var freq;
	var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
	var trig;
	var lpfenv;

	trig = Dust.ar(14);

	sig = Decay2.ar(trig, 0.01, 0.2);
	//sig = Ringz.ar(sig, TRand.kr(200,4700,trig),0.1);
	sig = Ringz.ar(sig,
		LFNoise1.kr(1/9).range(0.8,1.2) *
		Demand.ar(trig, 0, Drand([
			100,120,130,440,
		]*3,inf)),0.1);
	sig = sig * (CuspN.ar(1/24)+0.2);
	sig = sig * 0.1;


	//sig = sig * EnvGen.ar(Env.adsr(0.1,0.4,0.4,0.1),Trig.kr(trig,0.5),doneAction:0);
	amp = amp * \gain.kr(1);
	sig = Splay.ar(sig, \spread.kr(0.8), amp, \pan.kr(0));
	Out.ar(out, sig);
}).add;

SynthDef(\drone6, { arg out=0, amp=0.8, pan=0, freq=200, mbufnum,
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
	var baseffreq = 1000;

	freq = Duty.ar(8,0,Dseq([40,60,400,800,20,50,30,20],inf));

	ou = LFPulse.ar(freq * (1/(1..8))) | SinOsc.ar(SinOsc.ar(freq * (1..8))+1*200,0,10);
	//ou = Splay.ar(ou, 1, amp);
	ou = ou.sum;
	ou = BRF.ar(ou, 50 * (SinOsc.kr(1/(1..8)).unipolar *8));
	ou = ou * -25.dbamp;
	ou = ou.sum;
	ou = [ou, ou.tanh];
	ou = ou / 6;
	ou = ou.collect({ arg sig,x;
		Pan2.ar(sig, SinOsc.kr((x+1*200)), amp);
	}).sum;
	Out.ar(out, ou);
}).add;

SynthDef(\drone7, { arg out=0,  pan=0, amp=1;
	var in;
	in = SinOsc.ar(80 * [1,1.00001].mirror2.clump(2)).mean;
	in = in.fold2(0.9 * SinOsc.kr(1/(1..8)).unipolar);
	in.postln;
	in = Pan2.ar(in, pan + LFNoise1.kr(1), amp);
	in = in.mean;
	in = in * 1.8;
	Out.ar(out, in);
}).add;

SynthDef(\drone8, { arg out=0, pan=0, amp=1;
	var s1, in;
	s1 = SinOsc.ar(700*1/(1..7)) * LFNoise1.kr((1..8)).unipolar;
	in = SinOsc.ar(80 * [1,1.00001].mirror2.clump(2), s1).mean;
	in = in.fold2(0.9 * SinOsc.kr(1/(1..8)).unipolar);
	in = Pan2.ar(in, pan + LFNoise1.kr(10)/2, amp);
	in = in.mean;
	in = in * 0.8;
	Out.ar(out, in);
}).add;

SynthDef(\drone9, { arg out = 0, freq=200, pan=0, amp=0.1;
	var sig;
	sig = Dust.ar(100 * LFNoise1.kr(1).range(1/100,2));
	sig = Ringz.ar(sig, LFNoise0.kr(10).exprange(40.0,16000),0.1)/1;
	sig = AllpassL.ar(sig, 0.1,0.1,2)+sig;
	sig = AllpassL.ar(sig, 0.3,0.221,2)+sig;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;

SynthDef(\drone10, { arg out=0, freq=200, pan=0, amp=0.1;
	var sig;
	sig = Dust.ar(100!2 * LFNoise1.kr(1/21).range(1/100,2));
	sig = Ringz.ar(sig, LFNoise0.kr(1).exprange(40.0,16000) * SinOsc.kr(1/43).range(1/10,1),0.1)/1;
	sig = AllpassL.ar(sig, 0.1,0.1 * SinOsc.kr(1/42).range(0.8,1),2)+sig;
	sig = AllpassL.ar(sig, 0.1,0.1 * SinOsc.kr(1/35).range(0.1,1),2)+sig;
	sig = AllpassL.ar(sig, 0.3,0.221,2)+sig;
	sig = Pan2.ar(sig, pan, amp).sum;
	Out.ar(out, sig);
}).add;

SynthDef(\drone11, { arg out = 0, freq=200, pan=0, amp=0.1;
	var sig;
	sig = Dust.ar(freq*4);
	sig = Ringz.ar(sig, SinOsc.ar((1..10)) * freq, 0.001);
	sig = (sig + 0.05) * (SinOsc.ar(freq));
	//sig = BPF.ar(sig, freq * SinOsc.kr((1..10)).range(1,1.02));
	sig = sig * 1/2;
	sig = Pan2.ar(sig, SinOsc.kr((1..10)) * 0.1, amp).flop;
	sig = LeakDC.ar(sig);
	Out.ar(out, sig);
}).add;

SynthDef(\drone12, { arg out=0,  freq=200, pan=0, amp=0.5;
	var sig;
	var in;
	freq = freq * Duty.kr(1/2, 0, Dseq([
		1,0,0,0,
		4,4,3,3,
	],inf)).midiratio;
	in = LocalIn.ar(10);
	sig = Dust.ar(freq * \dustfac.kr(1));
	sig = Ringz.ar(sig, freq, \ringz.kr(0.1));
	//sig = (sig + 0.05) * (SinOsc.ar(freq));
	sig = sig + (in * \fbfac.kr(1.4));
	sig = LPF.ar(sig, freq * SinOsc.ar((1..10)*freq).range(1,8.02));
	//sig = sig * 0.7;
	sig = sig.tanh;
	sig = FreqShift.ar(sig, [0.01,0]) + sig;
	LocalOut.ar(sig);

	//sig = sig/ 2;

	sig = Pan2.ar(sig, SinOsc.kr((1..10)) * 0.1, amp).mean;
	sig = LeakDC.ar(sig);
	Out.ar(out, sig);
}).add;

SynthDef(\drone13, { arg out=0, freq=200, pan=0, amp=0.1;
	var sig;
	var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
	var size = 24;
	sig = Dust.ar(100 * SinOsc.kr(1/13).range(1/10,1));
	sig = Ringz.ar(sig, exprand(50.0!size,15000) * LFNoise0.ar(exprand(1/10000!size,1/10)).range(1/2,1), SinOsc.kr(exprand(1/10000!size,1/10)).range(4,40));
	sig = sig.collect({ arg si;
		si = [
			{ si.fold2(0.8) },
			{ si.tanh },
			{ si * 0.4 },
		].choose.value;
		si = si * SinOsc.kr(exprand(1/10000,1/10), 1.0.rand).exprange(0.01,1);
		si;
	});
	sig = sig * 6;
	sig = sig.mean;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;

SynthDef(\ambitek, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = Saw.ar([50,50.1]);
	4.do{|i|
		var f = 2 ** (8 - i);
		sig = BRF.ar(
			AllpassN.ar(sig,1,0.1/(12-i),2),
			80 ** TRand.ar(0,1,Impulse.ar(f/32,1/2)).lag(1/f) * 80,
			2
		);
	};
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\Lumbricost, {arg out = 0, amp = 1, pan = 0, attTim= 1, relTim=2.5, scale= 6, offset = 40, synch = 10, timescale = 10, widthmod = 0.4, width = 0.2, totVol, abc = 0, randLo = 0, randHi = 20000, bpfrq = 1, doneAction = 2;
	var generation =
	Pulse.ar(SinOsc.kr(5/synch, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(30/synch),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(7/synch, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(7/synch),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(9/synch, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(2/synch),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(10/synch, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(5/synch),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(3/synch, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(9/synch),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(2/synch, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(40/synch),widthmod,width,timescale), mul: 0.1);
	var env = generation * Env.perc(attackTime:attTim,releaseTime: relTim).ar(doneAction);
	var env1 = LeakDC.ar(env);
	var sig =  env1* ((totVol + amp -15).dbamp);
	sig = BPF.ar(sig, Rand(randLo-100, randHi+100), bpfrq);
	OffsetOut.ar(out, Pan2.ar(sig, pan));
}).add;

// be carefull this one create a temporary node
SynthDef(\rohrhuber, { arg out = 0, amp = 1, lfnFreq1 = 2, lfnFreq2 = 62, att = 0.01, rel = 2, gate = 1, doneAction = 2;
	var sig, env;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	Ndef(\x, {
		SinOsc.ar(
			BrownNoise.ar(30 ! 2, 200),
			Ndef(\x).ar * LFNoise1.kr([17, 4], 1, 1)
		)
	});
	sig = Ndef(\x) * LFNoise0.kr([lfnFreq1, lfnFreq2]) * env * amp;
	OffsetOut.ar(out, sig);
}).add;

// be carefull this one create a temporary node
SynthDef(\lirgo, { arg out = 0, amp = 1, att = 0.01, rel = 5, gate = 1, doneAction = 2;
	var sig, env, bpf;

	env = Linen.kr(gate, att, 1, rel, doneAction);
	sig = Ndef('x', {
		sig = Ndef('x').ar + 0.01;
		bpf = BPF.ar(sig, 6 ** Latch.ar(sig, Dust.ar(sig)) * 150, 0.2).sin;
		4.do{
			bpf = AllpassN.ar(bpf, 0.2, {0.2.rand}!2, 9)
		};
		bpf + bpf.mean;
	});
	OffsetOut.ar(out, sig * env * amp * 0.1);
}).add;

)