(

///////////////////////////////////////  Sound

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

SynthDef(\corde, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, fspread=0.01;
	var sig;
	var spread =1;
	sig = SinOsc.ar(freq * ((0..7)/7 - 0.5 * fspread + 1) * ( SinOsc.ar(freq*1.2) * 1 + 1 )) * ( SinOsc.ar(freq * 0.2) * 1 + 1 );
	sig = sig * 0.9;
	sig = Splay.ar(sig, spread, amp, pan);
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,2.1),gate,doneAction:2);
	Out.ar(out, sig);
}).add;

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

///////////////////////////////////////  Sequence

SynthDef(\virgo, { arg out = 0, feedback = 7.5, freq1 = 32, freq2 = 33, amp = 0.2, delaytime = 2, decaytime = 40, gate = 1, attack = 0.01, release = 1, doneAction = 2;
	var sig, input, modFreq;
	input = LocalIn.ar(2) * feedback;
	sig = input + Saw.ar([freq1, freq2], amp);
	modFreq = 2 ** LFNoise0.kr(4/3, 4) * 300;
	sig = BPF.ar(sig, modFreq, 0.1).distort;
	sig = CombN.ar(sig, 1, delaytime, decaytime);
	LocalOut.ar(sig);
	sig = sig * EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\tweetSynth, { arg out = 0, amp = 1, freq = 25, t_trig = 1, attack = 0.01, release = 1, doneAction = 2;
	var sig, demand;
	demand = Demand.kr(
		t_trig,
		0,
		Drand(freq,inf)
	);
	sig = (
		BHiPass.ar(
			LFNoise1.ar(8) ** 3,
			[demand, demand + 0.2].midicps,
			demand / 2e3, 67 - demand
		)
	).tanh;
	sig = sig * EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\scratchi, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env, waveForm, trig;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	waveForm = SinOsc.ar(1/2,[0,1],3,1);
	trig = Impulse.ar([waveForm+0.2,waveForm]);
	sig = FreeVerb.ar(Decay.ar(trig,waveForm,MoogFF.ar(SinOsc.ar(([waveForm.asin])*50),400)).softclip/2);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\tweetCheul, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env, freq;
	freq = {rrand(1, 2.1)};
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = Klank.ar(
			`[{exprand(100,1000)}.dup(50)],
			Saw.ar(MouseX.kr(3, LFPulse.kr(6/3,0,1/5).range(3,3000),1),0.0005)
	);
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\2001, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = PinkNoise.ar(1);
	20.do{
		sig = BBandStop.ar(sig, LFNoise1.kr(0.05.rand).exprange(40,15000), exprand(0.1,2));
	};
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\seqTwit, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env, input;
	input = LocalIn.ar(2) * 7.5 + Saw.ar([32,33],0.2);
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = CombN.ar(
		BPF.ar(
			input,
			2**LFNoise0.kr(4/3,4)*300,
			0.1
		).distort,
		2,
		2,
		40
	);
	LocalOut.ar(sig);
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\nathanielVirgo, { arg out = 0, amp = 1, feedBack = 7.5, sawFreq1 = 32, sawFreq2 = 33, sawAmp = 0.2, bpff = 2, bpffModSpeed = 1.33, bpffModAmt = 4, delayTime = 2, decayTime = 40, gate = 1, doneAction = 2;
	var sig, env;
	env = Linen.kr(gate, 0.01, 1, 20, doneAction);
	sig = LocalIn.ar(2) * feedBack + Saw.ar(
		[sawFreq1, sawFreq2],
		sawAmp
	) * env;
	sig = BPF.ar(
		sig,
		bpff ** LFNoise0.kr(bpffModSpeed, bpffModAmt) * 300,
		0.1
	).distort;
	sig = CombN.ar(sig, 2, delayTime, decayTime);
	LocalOut.ar(sig);
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\talters, { arg out = 0, amp = 1, gate = 1, doneAction = 2;
	var sig, env;
	env = Linen.kr(gate, 0.01, 1, 10, doneAction);
	sig = ({
		|k|
		({
			|i|
			y = SinOsc;
			y.ar(i*k*k, y.ar(i*k**i/[{4.rand}, {5.rand}]) * Decay.kr(Dust.kr(1/4**i), y.ar(0.1)+1*k+i, k*999))
		}!4).product
	}!8).sum;
	OffsetOut.ar(out, sig * env * amp);
}).add;

SynthDef(\bozkurt, { arg out = 0, amp = 1, att = 0.01, rel = 10, impFreq = 0.25, freq1 = 4, freq2 = 6, delTime = 0.3, decTime = 50, feedBack = 1, gate = 1, doneAction = 2;
	var sig, env, input, ctrl;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	input = LocalIn.ar(2).tanh * feedBack;
	ctrl = Latch.kr(input[0].abs, Impulse.kr(impFreq));
	sig = Blip.ar([freq1, freq2], 100 * ctrl + 50, 0.9);
	sig = CombC.ar(
		sig,
		1,
		ctrl * delTime,
		decTime * input
	);
	LocalOut.ar(sig);
	sig = Splay.ar(sig * env, amp);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\nozkurt, { arg out = 0, amp = 1, att = 0.01, rel = 5, sinFreq = 55, impMin = 0.0002, impMax = 0.7, impFreq = 8, gate = 1, doneAction = 2;
	var sig, env, delayTime;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	sig = SinOsc.ar(sinFreq).tanh;
	delayTime = TExpRand.ar(impMin, impMax, Impulse.ar(impFreq)).round([2e-3, 4e-3]);
	sig = AllpassC.ar(sig, 1, delayTime, 2);
	OffsetOut.ar(out, sig * env * amp);
}).add;

SynthDef(\tirgo, { arg out = 0, amp = 1, att = 0.01, rel = 5, blipFreqMod = 2, blipHarmo = 400, brfFreq = 150, brfRq = 2, gate = 1, doneAction = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	noise = PinkNoise.ar(1!2);
	rainStep = noise + Blip.ar(noise + blipFreqMod, blipHarmo);
	rainStep = BRF.ar(
		rainStep,
		brfFreq,
		brfRq,
		0.1
	);
	thunder = LPF.ar(FreeVerb2.ar(*LPF.ar(noise + 0.2 * Dust.ar(0.1), 60) ++ [1, 1, 0.2, 1e4]).tanh, 2000);
	sig = rainStep + thunder;
	OffsetOut.ar(out, sig * env * amp);
}).add;

)