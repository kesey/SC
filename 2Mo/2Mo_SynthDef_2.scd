(

///////////////////////////////////////  SynthDef

///////////////////////////////////////  Bass

SynthDef(\bass1,{ arg out = 0, amp = 1, pan = 0, att = 0, dec = 8, sus = 1, rel = 4, tu = 1, gate = 1, doneAction = 2;
    var env = EnvGen.ar(Env.adsr(att, dec, sus, rel), gate, doneAction: doneAction);
    var freq = EnvGen.ar(\freqenv.kr(Env([50, 40],[0.1, 0.3, 0.3])));
    var sig = SyncSaw.ar(freq*tu,20);
    sig = BRF.ar(sig,432,1);
    sig = HPF.ar(sig,300);
	sig = Pan2.ar(sig.distort, pan, amp) * env;
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\bass3,{ arg gate = 1, amp=1, out=0,rel=0.1,pan=0,tu=1.54;
    var env = EnvGen.ar(Env.adsr(0,4,1,0.1),gate,doneAction:2);
    var freq = EnvGen.ar(Env([14000,50,30],[0.001,0.1,0.1]));
    var sig = LFPar.ar([tu,tu+1],SinOsc.kr([2,1]))+LFPar.ar(tu,SinOsc.kr([1,2]));
    sig = Splay.ar(sig,SinOsc.kr(0.1),1,SinOsc.kr(pan));
    OffsetOut.ar(out,sig*amp*env);
}).add;

SynthDef(\bass,{ arg out=0, gate = 1 ,dis = 0.5,freq=60,tu = 1,amp=1,atf = 80, rel =1;
    var env = EnvGen.ar(Env.adsr(0.05,0,1,rel),gate,doneAction:2);
    var frequ = EnvGen.ar(Env([freq+1000,freq-100],[0.05,0.1]));
    var sig = LFSaw.ar(LFSaw.ar(frequ-100,0,frequ-200,frequ*tu),0,env);
    sig = CrossoverDistortion.ar(sig,dis,0.05)+sig;
    sig = DelayL.ar(sig,0.05,0.001)+sig;
    sig = DelayL.ar(sig,0.05,0.001)+sig;
    sig = DelayL.ar(sig,0.05,0.01)+sig;
    sig = BPeakEQ.ar(sig,80,1,6);
    sig = sig *0.4*(env);
    //sig = LPF.ar(sig,100);
    sig = Compander.ar(sig,In.ar(0,1),0.05,1,0.1,0.01,0.1);
    OffsetOut.ar(out,sig * amp);
}).add;

~sinBassSynthDef = SynthDef(\sinBass, { arg out = 0, gate = 1, amp = 1, pan = 0, bhpf = 80, attack = 0.2, release = 4, curve = (-4), envLevel1 = 0, envLevel2 = 40, envLevel3 = 32, envLevel4 = 50, envLevel5 = 0, envLevel6 = 60, envTime1 = 0.5, envTime2 = 0.3, envTime3 = 0.25, envTime4 = 1, envTime5 = 0.5, doneAction = 2;
	var freqEnv, env, sig;
	freqEnv = EnvGen.kr(Env([envLevel1, envLevel2, envLevel3, envLevel4, envLevel5, envLevel6], [envTime1, envTime2, envTime3, envTime4, envTime5], curve), gate);
	env = EnvGen.kr(Env.asr(attack, 1, release, curve), gate, doneAction: doneAction);
	sig = SinOsc.ar(freqEnv, mul: env);
	//sig = HPF.ar(sig, 20);
	sig = BHiPass4.ar(sig, bhpf, 1, env);
	OffsetOut.ar(out, Pan2.ar(sig, pan, Lag.kr(amp, 0.5)));
}).add;

SynthDef(\moogbasstone2,{ arg out = 0, freq = 440, amp = 0.1, gate = 1, attackTime = 0.2, fenvamount = 0.5, cutoff =  1000, gain = 2.0, pan = 0.0;

	var osc, filter, env, filterenv;

	//alternative: richer source
	osc = Mix(Pulse.ar(freq.lag(0.05)*[1.0,1.001,2.0],Rand(0.45,0.5)!3,0.33));

	filterenv = EnvGen.ar(Env.adsr(attackTime,0.0,1.0,0.2),gate,doneAction:2);
	filter =  MoogFF.ar(osc,cutoff*(1.0+(fenvamount*filterenv)),gain);

	env = EnvGen.ar(Env.adsr(0.001,0.3,0.9,0.2),gate,doneAction:2);

	OffsetOut.ar(out,Pan2.ar((0.7*filter+(0.3*filter.distort))*env*amp,pan));

}).add;

SynthDef(\moogBass, { arg out = 0, amp = 0.1, pan = 0, freq = 40, cutoff = 1000, gain = 2.0, lagamount = 0.01, att = 0.001, dec = 0.3, sus = 0.9, rel = 0.2, chorus = 0.7, gate = 1, doneAction = 2;
	var osc, filter, env, filterenv, snd, chorusfx;

	osc = Mix(VarSaw.ar(
		freq: freq.lag(lagamount) * [1.0, 1.001, 2.0],
		iphase: Rand(0.0,1.0) ! 3,
		width: Rand(0.5,0.75) ! 3,
		mul: 0.5));

	filterenv = EnvGen.ar(
		envelope: Env.asr(0.2, 1, 0.2),
		gate: gate);

	filter =  MoogFF.ar(
		in: osc,
		freq: cutoff * (1.0 + (0.5 * filterenv)),
		gain: gain);

	env = EnvGen.ar(
		envelope: Env.adsr(0.001, 0.3, 0.9, 0.2, amp),
		gate: gate,
		doneAction: doneAction);

	snd = (0.7 * filter + (0.3 * filter.distort)) * env;

	chorusfx = Mix.fill(7, {

		var maxdelaytime = rrand(0.005, 0.02);
		DelayC.ar(
			in: snd,
			maxdelaytime: maxdelaytime,
			delaytime: LFNoise1.kr(
				freq: Rand(4.5, 10.5),
				mul: 0.25 * maxdelaytime,
				add: 0.75 * maxdelaytime)
		)
	});

	snd = snd + (chorusfx * chorus);

	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

~tweetAnaBassSynthDef = SynthDef(\tweetAnaBass, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 2, freq = 60, ffreq = 60, tu = 9, compTresh = 0.5, t_trig = 1, doneAction = 2;
	var sig, env, bw;
	bw = LFNoise0.ar(_);
	sig = max(
		max(bw.(4),l=bw.(6)),
		SinOsc.ar(freq * ceil(l*tu).lag(0.1))*0.7
	);
	sig = tanh(
		BBandPass.ar(sig, ffreq, bw.(1).abs/2)*700*l.lag(1)
	);
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = sig * env;
	sig = Compander.ar(sig, sig, compTresh, 1, 1/8, 0.002);
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\triangleWaveBells,{ arg out = 0, amp = 1.0, pan = 0.0, att = 0.01, dec = 0.1, sus = 1, rel = 0.5, freq = 40, lforate = 10, lfowidth = 0.0, cutoff = 100, rq = 0.5, gate = 1, doneAction = 2;

	var osc1, osc2, vibrato, filter, env;
	vibrato = SinOsc.ar(lforate, Rand(0, 2.0));
	osc1 = Saw.ar(freq * (1.0 + (lfowidth * vibrato)), 0.75);
	osc2 = Mix(LFTri.ar((freq.cpsmidi + [11.9, 12.1]).midicps));
	filter = RHPF.ar((osc1 + (osc2 * 0.5)) * 0.5, cutoff, rq);
	env = EnvGen.ar(
		envelope: Env.adsr(att, dec, sus, rel, amp),
		gate: gate,
		doneAction: doneAction
	);
	OffsetOut.ar(out, Pan2.ar(filter * env, pan));
}).add;

///////////////////////////////////////  Tonal

SynthDef(\cow, { arg out=0, amp=0.5, pan=0, att = 0.001, rel=1, tu=1, gate=1, doneAction=2;
	var sig;
	var env = EnvGen.ar(Env.asr(att,1,rel), gate, doneAction: doneAction);
	sig = LFPulse.ar(550*tu)+LFPulse.ar(tu*400*(env+250));
	sig = Ringz.ar(sig,(30..35)*10.234*tu,1).mean;
	sig = Pan2.ar(sig*env, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\notes,{arg out = 0, amp = 0.5, pan = 0, att = 0.01, rel = 0.1, freq = 69, tu = 1, t_gate = 1, doneAction = 2;
	var env = EnvGen.ar(Env.perc(att, rel), t_gate, doneAction: doneAction);
	var sig = WhiteNoise.ar(env);
	sig = CombL.ar(sig,0.2,(freq+(432.cpsmidi-69)).midicps/SampleRate.ir,1)+sig;
	sig = CombL.ar(sig,0.2,(freq+(432.cpsmidi-69)).midicps/SampleRate.ir,0.2)+sig;
	sig = sig *env *0.5;
	sig = CompanderD.ar(sig*2,0.5,1,0.5);
	sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\notes2,{arg out=0,gate =1,notes=68,at = 0.01,sus=0.4,snd=18;
	var env = EnvGen.ar(Env.adsr(at,1,sus,1.4),gate,doneAction:2);
	//var env = EnvGen.ar(Env.perc(0.01,1),gate,doneAction:2);
	var note = (notes+(432.cpsmidi-69)).midicps;
	var sig = Mix.ar(SinOsc.ar([note,note*2,note/2]));
	sig = Splay.ar(sig*0.1);
	OffsetOut.ar(out,sig*env*0.5);
	//Out.ar(snd,sig*env);
}).add;

SynthDef(\sinus,{arg out = 0, amp = 0.5, pan = 0, freq = 100, t_gate = 1, attack = 0, release = 0.1, lfo = 1, doneAction = 2;
	var env  = EnvGen.ar(Env.perc(attack,  release), t_gate, doneAction: doneAction);
	var sig = SinOsc.ar(freq+(432-69.midicps)*SinOsc.kr(lfo),0,env);
	sig = HPF.ar(sig,100);
	sig = CompanderD.ar(sig,0.3,0.3,1.5,0.0001,0.01);
	sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

~prayerBellSynthDef = SynthDef(\prayerBell, { |out = 0, t_trig = 1, amp = 0.5, pan = 0, sing_switch = 0, freq = 2434, decayscale = 1, lag = 10, level = 0.08, i_doneAction = 2|
	var sig, input, first, freqscale, mallet, sing;
	freq = freq.max(20).min(5000);
	freqscale = freq / 2434;
	decayscale = decayscale.min(1);
	freqscale = Lag3.kr(freqscale, lag);
	decayscale = Lag3.kr(decayscale, lag);

	mallet = LPF.ar(Trig.ar(t_trig, SampleDur.ir)!2, 10000 * freqscale);
	sing = LPF.ar(
		LPF.ar(
			{
				PinkNoise.ar * Integrator.kr(sing_switch * 0.001, 0.999).linexp(0, 1, 0.01, 1) * amp
			} ! 2,
			2434 * freqscale
		) + Dust.ar(0.1), 10000 * freqscale
	) * LFNoise1.kr(0.5).range(-45, -30).dbamp;
	input = mallet + (sing_switch.clip(0, 1) * sing);


	sig = DynKlank.ar(`[
		[
			(first = LFNoise1.kr(0.5).range(2424, 2444)) + Line.kr(20, 0, 0.5),
			first + LFNoise1.kr(0.5).range(1,3),
			LFNoise1.kr(1.5).range(5435, 5440) - Line.kr(35, 0, 1),
			LFNoise1.kr(1.5).range(5480, 5485) - Line.kr(10, 0, 0.5),
			LFNoise1.kr(2).range(8435, 8445) + Line.kr(15, 0, 0.05),
			LFNoise1.kr(2).range(8665, 8670),
			LFNoise1.kr(2).range(8704, 8709),
			LFNoise1.kr(2).range(8807, 8817),
			LFNoise1.kr(2).range(9570, 9607),
			LFNoise1.kr(2).range(10567, 10572) - Line.kr(20, 0, 0.05),
			LFNoise1.kr(2).range(10627, 10636) + Line.kr(35, 0, 0.05),
			LFNoise1.kr(2).range(14689, 14697) - Line.kr(10, 0, 0.05)
		],
		[
			LFNoise1.kr(1).range(-10, -5).dbamp,
			LFNoise1.kr(1).range(-20, -10).dbamp,
			LFNoise1.kr(1).range(-12, -6).dbamp,
			LFNoise1.kr(1).range(-12, -6).dbamp,
			-20.dbamp,
			-20.dbamp,
			-20.dbamp,
			-25.dbamp,
			-10.dbamp,
			-20.dbamp,
			-20.dbamp,
			-25.dbamp
		],
		[
			20 * freqscale.pow(0.2),
			20 * freqscale.pow(0.2),
			5,
			5,
			0.6,
			0.5,
			0.3,
			0.25,
			0.4,
			0.5,
			0.4,
			0.6
		] * freqscale.reciprocal.pow(0.5)
	], input, freqscale, 0, decayscale);
	DetectSilence.ar(sig, doneAction: i_doneAction);
	sig = Pan2.ar(sig, pan, level);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\prayerBellBr, { arg out = 0, amp = 0.5, pan = 0, singSwitch = 0, freq = 2434, decayScale = 1, lag = 10, doneAction = 2;
	var snd, input, first, freqScale, mallet, sing;
	freqScale = freq / 2434;
	freqScale = Lag3.kr(freqScale, lag);
	decayScale = Lag3.kr(decayScale, lag);

	// mallet
	mallet = LPF.ar(
		in: Impulse.ar(0) ! 2 * amp,
		freq: 10000 * freqScale
	);

	// sing
	sing = LPF.ar(
		in: {PinkNoise.ar * Integrator.kr(singSwitch * 0.001, 0.999).linexp(0, 1, 0.01, 1) * amp} ! 2,
		freq: 2434 * freqScale
	);

	sing = sing + Dust.ar(0.1);
	sing = LPF.ar(sing, 10000 * freqScale);
	sing = sing * LFNoise1.kr(0.5).range(-45, -30).dbamp;

	// input = mallet + sing
	input = mallet + (singSwitch.clip(0, 1) * sing);

	// resonant filter bank
	snd = DynKlank.ar(
		specificationsArrayRef: `[
			// Array of filter frequencies
			[
				(first = LFNoise1.kr(0.5).range(2424, 2444)) + Line.kr(20, 0, 0.5),
				first + LFNoise1.kr(0.5).range(1,3),
				LFNoise1.kr(1.5).range(5435, 5440) - Line.kr(35, 0, 1),
				LFNoise1.kr(1.5).range(5480, 5485) - Line.kr(10, 0, 0.5),
				LFNoise1.kr(2).range(8435, 8445) + Line.kr(15, 0, 0.05),
				LFNoise1.kr(2).range(8665, 8670),
				LFNoise1.kr(2).range(8704, 8709),
				LFNoise1.kr(2).range(8807, 8817),
				LFNoise1.kr(2).range(9570, 9607),
				LFNoise1.kr(2).range(10567, 10572) - Line.kr(20, 0, 0.05),
				LFNoise1.kr(2).range(10627, 10636) + Line.kr(35, 0, 0.05),
				LFNoise1.kr(2).range(14689, 14697) - Line.kr(10, 0, 0.05)
			],
			// Array of filter amplitudes
			[
				LFNoise1.kr(1).range(-10, -5).dbamp,
				LFNoise1.kr(1).range(-20, -10).dbamp,
				LFNoise1.kr(1).range(-12, -6).dbamp,
				LFNoise1.kr(1).range(-12, -6).dbamp,
				-20.dbamp,
				-20.dbamp,
				-20.dbamp,
				-25.dbamp,
				-10.dbamp,
				-20.dbamp,
				-20.dbamp,
				-25.dbamp
			],
			// Array of filter decay times
			[
				20 * freqScale.pow(0.2),
				20 * freqScale.pow(0.2),
				5,
				5,
				0.6,
				0.5,
				0.3,
				0.25,
				0.4,
				0.5,
				0.4,
				0.6
			] * freqScale.reciprocal.pow(0.5)
		],
		input: input,
		freqscale: freqScale,
		freqoffset: 0,
		decayscale: decayScale
	);

	DetectSilence.ar(snd, doneAction: doneAction);

	OffsetOut.ar(out, Pan2.ar(Mix.ar(snd), pan));
}).add;

SynthDef(\glockenspiel, { arg out = 0, amp = 0.01, pan = 0, att = 0.001, rel = 6, freq = 440, exciterRel = 0.05, doneAction = 2;
	var env, snd, exciter;

	env = Env.perc(att, exciterRel, 0.25).kr;

	exciter = WhiteNoise.ar(env);

	snd = DynKlank.ar(
		specificationsArrayRef:
	        	Ref.new([
	        		[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // harmonics
			        [1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
		        	[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]     // ring times
		        ]),
		input: exciter,
		freqscale: freq,
		decayscale: rel
	);

	DetectSilence.ar(
		        in: snd,
		        amp: 0.001,
		        time: 0.5,
		        doneAction: doneAction
		    );

	OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\rissetBell, { arg out = 0, amp = 0.1, pan = 0, att = 0.005, rel = 2, freq = 400, gate = 1, doneAction = 2;
	var amps = #[1, 0.67, 1, 1.8, 2.67, 1.67, 1.46, 1.33, 1.33, 1, 1.33];
	var durs = #[1, 0.9, 0.65, 0.55, 0.325, 0.35, 0.25, 0.2, 0.15, 0.1, 0.075];
	var frqs = #[0.56, 0.56, 0.92, 0.92, 1.19, 1.7, 2, 2.74, 3, 3.76, 4.07];
	var dets = #[0, 1, 0, 1.7, 0, 0, 0, 0, 0, 0, 0];
	var doneActionEnv = Env.linen(0, att+rel, 0).ar(gate: gate, doneAction: doneAction);
	var snd = Mix.fill(11, {arg i;
		var env = Env.perc(
			attackTime: att,
			releaseTime: rel * durs[i],
			level: amps[i],
			curve: att.explin(0.005, 4, -4.5, 0)
	).ar(gate: gate);
		SinOsc.ar(
			freq: freq * frqs[i] + dets[i],
			mul: amp * env
		);
	});
	snd = snd * doneActionEnv * 0.5;
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\sosBell, { arg out = 0, amp = 0.1, pan = 0, freq = 440, rel = 2, curve = \lin,
	//ring Controls (wobbleDepth goes from 0 to 1)
	ringAmp = 1, ringRel = 0.9, wobbleDepth = 0.6, wobbleMin = 1, wobbleMax = 1.8,
	//strike Controls
	strikeAmp = 1, strikeDec = 0.01, strikeRel = 0.04, strikeDepth = 0.028, strikeHarmonic = 8,
	//hum Controls
	humAmp = 0.5, humAtt = 0.5, humDec = 0.5, humRel = 1,
	doneAction = 2;

	var snd, ring, ringEnv, ringFreqs, strike, strikeEnv, strikeMod, hum, humEnv;

	ringFreqs = [2, 3, 4.1, 5.43, 6.8, 8.21];

	ringEnv = Env.new(
		            levels: [1, 0.3, 0.2, 0],
		            times: [1/3, 1/3, 1/3] * ringRel * rel,
		            curve: curve).kr;

	ring = SinOsc.ar(
		            freq: ringFreqs * freq,
		            mul: Array.series(6, 1, -0.1) * ringEnv);

	ring = ring * LFTri.ar(
		            freq: {Rand(wobbleMin, wobbleMax)}.dup(6)).range((1 - wobbleDepth), 1);

	strikeEnv = Env.new(
		            levels: [1, 0.1, 0],
		            times: [strikeDec, strikeRel * rel],
		            curve: curve).kr;

	strikeMod = LFNoise1.ar(freq * 36).range(1/ (strikeDepth + 1), strikeDepth + 1);

	strike = SinOsc.ar(
                    freq: freq * strikeHarmonic * strikeMod,
		            mul: strikeEnv);

	humEnv = Env.new(
		            levels: [0, 1, 0.8, 0],
		            times: [humAtt, humDec, humRel * rel],
		            curve: curve).kr;

	hum = SinOsc.ar(
		            freq: freq * [1.01, 0.47],
		            mul: humEnv);

	snd = Mix.ar((ring * ringAmp) + (strike * strikeAmp) + (hum * humAmp)) * amp;

	DetectSilence.ar(in: snd, doneAction: doneAction);

    OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\tubularBell, { arg out = 0, amp = 0.1, pan = 0, att = 0.005, rel = 9, freq = 440, exciterRel = 0.05, doneAction = 2;

	var env, snd, exciter;

	env = Env.perc(att, exciterRel, 0.05).kr;

	exciter = GrayNoise.ar(env);

	snd = DynKlank.ar(
		specificationsArrayRef:
	        	Ref.new([
	        		[1.013, 1.512, 2.113, 2.525, 3.35, 4.57, 6.48],   // harmonics
			        [1, 0.78, 0.89, 0.63, 0.31, 0.56, 0.25], // amplitudes
		        	[1, 0.9, 0.8, 0.65, 0.45, 0.3, 0.1]     // ring times
		        ]),
		input: exciter,
		freqscale: freq,
		decayscale: rel
	);

	snd = LPF.ar(snd, freq * 9.5);

	DetectSilence.ar(
		        in: snd,
		        amp: 0.001,
		        time: 0.5,
		        doneAction: doneAction
		    );

	OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\waveguideFlute, { arg out = 0, amp = 0.5, scl = 0.2, freq = 440, ipress = 0.9, ibreath = 0.09, ifeedbk1 = 0.4, ifeedbk2 = 0.4, dur = 1, doneAction = 2;

	var kenv1, kenv2, kenvibr, kvibr, sr, cr, block;
	var poly, signalOut, ifqc;
	var aflow1, asum1, asum2, afqc, atemp1, ax, apoly, asum3, avalue, atemp2, aflute1;
	var fdbckArray;

	sr = SampleRate.ir;
	cr = ControlRate.ir;
	block = cr.reciprocal;

	ifqc = freq;

	// noise envelope
	kenv1 = EnvGen.kr(Env.new(
		[ 0.0, 1.1 * ipress, ipress, ipress, 0.0 ], [ 0.06, 0.2, dur - 0.46, 0.2 ], 'linear' )
	);
	// overall envelope
	kenv2 = EnvGen.kr(Env.new(
		[ 0.0, amp, amp, 0.0 ], [ 0.1, dur - 0.02, 0.1 ], 'linear' ), doneAction: doneAction
	);
	// vibrato envelope
	kenvibr = EnvGen.kr(Env.new( [ 0.0, 0.0, 1, 1, 0.0 ], [ 0.5, 0.5, dur - 1.5, 0.5 ], 'linear') );

	// create air flow and vibrato
	aflow1 = LFClipNoise.ar( sr, kenv1 );
	kvibr = SinOsc.ar( 5, 0, 0.1 * kenvibr );

	asum1 = ( ibreath * aflow1 ) + kenv1 + kvibr;
	afqc = ifqc.reciprocal - ( asum1/20000 ) - ( 9/sr ) + ( ifqc/12000000 ) - block;

	fdbckArray = LocalIn.ar( 1 );

	aflute1 = fdbckArray;
	asum2 = asum1 + ( aflute1 * ifeedbk1 );

	//ax = DelayL.ar( asum2, ifqc.reciprocal * 0.5, afqc * 0.5 );
	ax = DelayC.ar( asum2, ifqc.reciprocal - block * 0.5, afqc * 0.5 - ( asum1/ifqc/cr ) + 0.001 );

	apoly = ax - ( ax.cubed );
	asum3 = apoly + ( aflute1 * ifeedbk2 );
	avalue = LPF.ar( asum3, 2000 );

	aflute1 = DelayC.ar( avalue, ifqc.reciprocal - block, afqc );

	fdbckArray = [ aflute1 ];

	LocalOut.ar( fdbckArray );

	signalOut = avalue;

	OffsetOut.ar(out, [ signalOut * kenv2, signalOut * kenv2 ] );
}).add;

SynthDef(\justwannahavefun,{|out= 0 amp = 0.1 pan=(-0.1) freq = 440 ringTime=10.0 |

	var impulse, filter, env;

  	impulse = Impulse.ar(0);

	filter = Ringz.ar(impulse,(freq.cpsmidi + (Rand(0.2,1.2)*SinOsc.kr(Rand(10,50)))).midicps,ringTime);

	env = EnvGen.ar(Env([0.0,1.0,1.0,0.0],[0.001,0.04,0.04]),doneAction:2);

	OffsetOut.ar(out,Pan2.ar((filter.softclip(0.9))*env*amp,pan));

}).add;

SynthDef(\marimba1, { arg out = 0, freq = 440, amp = 0.4;
	var snd, env;
	env = Env.linen(0.015, 1, 0.5, amp).kr(doneAction: 2);
	snd = BPF.ar(Saw.ar(0), freq, 0.02);
	snd = BLowShelf.ar(snd, 220, 0.81, 6);
	snd = snd * env;
	OffsetOut.ar(out, Splay.ar(snd));
}).add;

SynthDef(\kalimba, { arg out = 0, amp = 0.1, pan = 0, att = 0.001, freq = 44,
	// Mix control goes from 0 to 1
	mix = 0.1,
	// Release controls for different parts of the sound
	minRel = 2.5, maxRel = 3.5, clickRel = 0.01,
	doneAction = 2;

	var note, env, body, snd;

	env = Env.perc(att * 3, Rand(minRel, maxRel), 1, -8).kr(doneAction: doneAction);
	note = SinOsc.ar(freq) * env;
	body = DynKlank.ar(
		specificationsArrayRef:
		Ref.new([
			[240 * ExpRand(0.9, 1.1), 2020 * ExpRand(0.9, 1.1), 3151 * ExpRand(0.9, 1.1)],
			[-7, 0, 3].dbamp, // same as 10.pow([-7, 0, 3] / 20),
			[0.75, 0.04, 0.06] + clickRel
		]),
		input:
		// Try BrownNoise, GrayNoise, etc. here, but you may need to change ring times above
		(PinkNoise.ar * Env.perc(att, clickRel).kr)
	);
	snd = (note * (1 - mix)) + (body * mix) * amp;

	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\pmCrotales, { arg out = 0, amp = 0.2, pan = 0, att = 0, rel = 2, curve = -6, freq = 261, tone = 3, modLo = 5.25, modHi = 5.5;
	var env, snd, mod;

	env = Env.perc(attackTime: 0, releaseTime: rel, curve: curve).kr(doneAction: 2);

	mod = Rand(modLo, modHi);

	snd = PMOsc.ar(
	    	carfreq: freq,
	    	modfreq: mod * freq,
	    	pmindex: env * tone,
	    	mul: env * amp
	    );

	snd = HPF.ar(snd, freq / 2);

	snd = Mix.ar(snd);

	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\steelDrum, { arg out = 0, amp = 0.1, pan = 0, att = 0.01, dec = 1.5, curve = -6, freq = 440, filterHarmonic = 6, doneAction = 2;
	var resFreqArray, resAmpArray, resDecArray, enva, envb, envc, snda, sndb, sndc, snd;

	//Arrays for the bank of resonators, mostly harmonics near 5ths and 9ths, and random amplitudes:
	resFreqArray = [2, 2.98, 4.75, 6.21, 9, 9.15, 11.87];
	resAmpArray = [0.35, 0.23, 0.10, 0.06, 0.07, 0.05, 0.01];
	resDecArray = [0.86, 0.72, 0.37, 0.55, 0.32, 0.21, 0.16];

	//Custom envelope shapes attempting to capture the aparrent "bloom" of a note:
	enva = Env.pairs([[0, 0], [att, 1], [(att + dec), 0]], curve).kr;
	envb = Env.pairs([[0, 0], [(att * 5), 0.25], [(att * 6), 0.75], [((att * 6) + (dec / 2)), 0]], curve).kr;
	envc = Env.pairs([[0, 0], [(att * 5), 0.1], [(att * 8), 0.5], [((att * 8) + (dec / 3)), 0]], curve).kr;

	//Fundamental, octave up, and a bank of enharmonic resonators excited by a metalic sound:
	snda = SinOsc.ar(freq: freq, mul: enva);
	sndb = SinOsc.ar(freq: freq * 2.015, mul: envb);
	sndc = DynKlank.ar(
		specificationsArrayRef:
		    Ref.new([
		    	resFreqArray * freq,
		    	resAmpArray,
			    resDecArray * dec
		    ]),
		input:
		LPF.ar(HPF.ar(CombN.ar(PinkNoise.ar(1), 1/freq, 1/freq, -1, envc), freq * 2), freq * filterHarmonic)
	);

	//Output stages with a tiny bit of compression to smooth things out:

	snd = Mix.ar([snda, sndb, sndc]) * (amp / 3);
	snd = Limiter.ar(snd, amp);
	DetectSilence.ar(in: snd, amp: 0.0001, time: 0.5, doneAction: doneAction);
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\noisyTone, { arg out = 0, freq = 440, amp = 0.2, pan = 0.5;
	var snd, env;
	env = Env.perc(0.02, 0.1).kr(doneAction: 2);
	snd = Mix(LFPulse.ar(
		freq: freq * [1, 5/2],
		iphase: 0.0,
		width: 0.5,
		mul: amp));
	snd = snd * env ;
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

~ping_mhSynthDef = SynthDef(\ping_mh,{arg out=0, amp=0.2, pan=0, freq=440, dur=0.1, attack=0.001;
    var sig, freq2;
    freq=freq*rrand(1,1.01);
    freq2=freq*rrand(1,1.01);
	e=EnvGen.ar(Env.perc(attack,dur.max(0.01),curve:-4),doneAction:2);
    sig=SinOsc.ar([freq,freq2],0,amp*e);
    sig=Pan2.ar(sig,pan);
    OffsetOut.ar(out,sig)
}).add;

SynthDef(\plucking, {arg amp = 0.1, freq = 440, decay = 5, coef = 0.1;
var env, snd;
env = EnvGen.kr(Env.linen(0, decay, 0), doneAction: 2);
snd = Pluck.ar(
        in: WhiteNoise.ar(amp),
        trig: Impulse.kr(0),

        maxdelaytime: 0.1,
        delaytime: freq.reciprocal,
        decaytime: decay,
        coef: coef);
    OffsetOut.ar(0, [snd, snd]);
}).add;

SynthDef(\pwmbling,{|out= 0 freq = 440 amp = 0.1 gate=1 lforate = 4.85 lfowidth= 0.5 cutoff= 12000 rq=0.25 pan = 0.0|

	var lfo, pulse, filter, env;
	var basefreq =  ((freq.cpsmidi)+[0,12.12]).midicps;

	lfo = LFTri.kr(lforate*[1,1.01],Rand(0,2.0)!2);

	pulse = Pulse.ar(basefreq,lfo*lfowidth+0.5);

	env = EnvGen.ar(Env.adsr(0.0,1.0,0.2,1.5),gate,doneAction:2);

	filter = RLPF.ar(pulse,(cutoff*(env.squared))+100,rq);

	OffsetOut.ar(out,Pan2.ar(Mix(filter)*env*amp,pan));

}).add;

SynthDef(\ressquares,{|out= 0 freq = 440 amp = 0.1 gate=1 cutoff=8000 rq=0.8 pan=(-0.1)|

	var pulse, filter, env;

	//2 cents detune for second oscillator
	pulse = Mix(Pulse.ar( ((freq.cpsmidi)+[0,0.02]).midicps, 0.5))*0.5;

	filter =  BLowPass.ar(pulse,100+cutoff,rq);

	env = EnvGen.ar(Env.adsr(0.002,0.1,1.0,0.2),gate,doneAction:2);

	OffsetOut.ar(out,Pan2.ar(filter*env*amp,pan));

}).add;

SynthDef(\glauk, { arg out = 0, amp = 0.2, attack = 0.01, release = 2, gate = 1, doneAction = 2;
	var sig, env;
	// env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = Splay.ar(
		SinOsc.ar(
			Array.fill(50,{\freq.asSpec.map(LFNoise2.kr(0.001))})
		)
	);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\scinty, { arg out = 0, amp = 0.2, t_trig = 1, attack = 0.01, release = 10, doneAction = 2;
	var sig, env;
	// env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	sig = Splay.ar(
		Array.fill(15,{Ringz.ar(Dust.ar(Rand(1,10)), Rand(50,9000).round(100), 2)},
			1,
			0.5,
			0
		)
	);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\bublybub, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 10, x = 165, doneAction = 2;
	var sig, env, waveForm, freq, dur, input;
	// env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	waveForm = SinOsc;
	freq = Trig.ar(Saw.ar(x),1);
	dur = waveForm.ar(freq * x);
	input = waveForm.ar(freq);
	sig = GVerb.ar(GrainIn.ar(2,dur,dur/2,input,freq*input,-1),9);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\chdegaulleabout, { arg out = 0, amp = 1, pan = 0, freq = 0.01, attack = 0.01, release = 10, t_trig = 1, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	sig = SinOsc.ar(LFNoise1.kr(freq).exprange(100,{exprand(300,10000)}!120)).mean;
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\t2001, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 10, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	sig = PinkNoise.ar(1);
	20.do{
		sig = BBandStop.ar(sig, LFNoise1.kr(0.05.rand).exprange(40,15000), exprand(0.1,2));
	};
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\claudTweet, { arg out = 0, amp = 0.2, t_trig = 1, attack = 0.01, release = 10, doneAction = 2;
	var sig, env, x;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	sig = LFTri.ar(
		Duty.ar(Dseq([3,1]/12,inf),
			0,
			Dseq(
				x = (3..6);
				allTuples(x/.t x).flat*[100,200,400]++0
			)
		)
	);
	sig = GVerb.ar(sig, 25, 5)/5;
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

~ambitekSynthDef = SynthDef(\ambitek, { arg out = 0, amp = 0.5, attack = 0.01, release = 10, envSL1 = 0, envSL2 = 0.72, envSL3 = 0.16, envSL4 = 0, envST1 = 0.2, envST2 = 0.6, envST3 = 0.8, envSCurve = (-4), sawFreq = 50, delTime = 0.1, delDecay = 2, brfRq = 2, t_trig = 1, doneAction = 2;
	var sig, env, envS;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	envS = EnvGen.kr(Env([envSL1, envSL2, envSL3, envSL4], [envST1, envST2, envST3], envSCurve));
	sig = Saw.ar(sawFreq * envS);
	2.do{|i|
		var f = 2 ** (8 - i);
		sig = BRF.ar(
			AllpassN.ar(sig, 1, Lag2.kr(delTime, 0.2) / (12 - i), delDecay),
			Lag2.ar(80 ** TRand.ar(0, 1, Impulse.ar(f / 32, 1/2)).lag(1 / f) * 80, 0.5),
			brfRq
		);
	};
	sig = sig * env;
	OffsetOut.ar(out, sig!2 * amp);
}).add;

~mainSynthDef = SynthDef(\main,{arg out = 0, amp = 0.5, pan = 0, lev = 10, freq = 50, wnoiseAmp = 1, sinAmp = 1, sinFreq = 30, sel = 0, envLevel1 = 0.0, envLevel2 = 1.0, envLevel3 = 0.0, levelScale = 1, levelBias = 0, att = 0.0, rel = 0.1, timeScale = 1, noiseAmp = 1, hpf = 8000, revtime = 3, room = 10, damp = 0.5, revMix = 0, t_trig = 1, doneAction = 2;
	var revSig;
	var fmod = SinOsc.ar(freq/60, 0, freq/60);
	var sig = [
		SinOsc.ar([freq, freq + 600] + fmod, 0, [lev, 0.005]).mean.tanh,
		HPF.ar(WhiteNoise.ar(wnoiseAmp), hpf),
		SinOsc.ar(sinFreq, 0, sinAmp),
		VarSaw.ar(freq/40, mul: lev * 10000)
	];
	var env = EnvGen.kr(Env.new([envLevel1, envLevel2, envLevel3], [att, rel]), t_trig, levelScale, levelBias, timeScale, doneAction);
	sig = (Select.ar(sel, sig) * env).fold(-1, 1) * 0.7 + SinOsc.ar(40, 0, 0.3) * (1 + HPF.ar(WhiteNoise.ar(0.02 * noiseAmp), hpf));
	revSig = GVerb.ar(sig, Lag3.kr(room).max(0.01), revtime, damp);
	sig = SelectX.ar(revMix, [sig, revSig]);
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\flash, { arg out = 0, amp = 0.3, fund = 400, decay = 4, filter = 1, doneAction = 2;
	var sig;
	sig = Mix.ar( Array.fill(7,
		{
			arg counter;
			var partial;
			partial = counter + 1;
			SinOsc.ar(fund*partial) * EnvGen.kr(Env.linen(0, 0, decay), levelScale: 1/(partial*filter)
			) * max(0, LFNoise1.kr(rrand(5.0, 12.0)));
		}
	)
	);
	sig = Pan2.ar(sig, Rand(-1.0, 1.0), amp);
	DetectSilence.ar(sig, doneAction: doneAction);
	OffsetOut.ar(out, sig)
}).add;

SynthDef(\elifm, { arg freq = 500, mRatio = 1, cRatio = 1, index = 1, iScale = 5, amp = 0.2, atk = 0.01, rel = 3, cAtk = 4, cRel = (-4), pan = 0;
    var car, mod, env, iEnv;
    iEnv = EnvGen.kr(
        Env.new(
            [index, index * iScale, index],
            [atk, rel],
            [cAtk, cRel]
        )
    );
    env = EnvGen.kr(
        Env.perc(atk, rel, curve: [cAtk, cRel]),
        doneAction: 2
    );
    mod = SinOsc.ar(freq * mRatio, mul: freq * mRatio * iEnv);
    car = SinOsc.ar(freq * cRatio + mod) * env * amp;
    car = Pan2.ar(car, pan);
    OffsetOut.ar(0, car);
}).add;

SynthDef(\polishFab, { arg out = 0, amp = 0.2, attack = 11, release = 6, feedBack = 2, phmodFrq = 0.5, freq1 = 64, freq2 = 23, envfL1 = 0, envfL2 = 500, envfL3 = 20, envfL4 = 0, envfT1 = 0.2, envfT2 = 0.01, envfT3 = 0.12, envfCure = (-4), frqScale = 0.5, t_trig = 1, doneAction = 2;
	var sig, env, envf, num, input;
	num = 8;
	input = LocalIn.ar(2) * feedBack;
	envf = EnvGen.ar(Env([envfL1, envfL2, envfL3, envfL4], [envfT1, envfT2, envfT3], envfCure), t_trig) * frqScale;
	sig = Mix.arFill(
		num,
		{ arg i;
			var oddHarm = i * 2 + 1;
			var evenHarm = i * 2 + 2;
			SinOsc.ar(
				[freq1 * oddHarm, freq2 * evenHarm] + envf,
				Latch.kr((input * (i + 1)) * pi, Impulse.kr((oddHarm / (3 * pi)) + phmodFrq)),
				num.reciprocal
			)
			*
			EnvGen.kr(
				Env.sine(num / i)
			)
		}
	);
	env = EnvGen.kr(
		Env.perc(attack, release),
		t_trig,
		doneAction: doneAction,
		levelScale: 0.75
	);
	sig = (sig[0] + sig[1]) * env;
	LocalOut.ar(sig);
	sig = Splay.ar(sig, 1, amp);
	OffsetOut.ar(out, sig /** amp*/);
}).add;

SynthDef(\slatechre, { arg out = 0, amp = 1, attack = 0.01, release = 3, t_trig = 1, doneAction = 2;
	var env, note, snd, delaytime, damp, size, diff, feedback, localout;
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	note = Demand.kr(Impulse.kr(0) + Dust.kr(0.1), 0, Diwhite(60, 80, inf));
	delaytime = Demand.kr(Impulse.kr(0) + Dust.kr(0.3), 0, Dwhite(0.1, 0.3, inf));
	damp = Demand.kr(Impulse.kr(0) + Dust.kr(0.4), 0, Dwhite(0.2, 0.6, inf));
	size = Demand.kr(Impulse.kr(0) + Dust.kr(0.3), 0, Dwhite(2, 10, inf));
	diff = Demand.kr(Impulse.kr(0) + Dust.kr(0.2), 0, Dwhite(0.5, 1.0, inf));
	feedback = Demand.kr(Impulse.kr(0) + Dust.kr(0.4), 0, Dwhite(0.8, 1.0, inf));
	snd = SinOsc.ar(freq: [note, note+LFNoise1.kr(freq: 0.1).range(-0.25, 0.25)].midicps);
	localout = Mix.ar(3.collect({ |i|
		Pan2.ar(
			in: PitchShift.ar(in: snd, pitchRatio: i),
			pos: LFNoise1.ar(freq: TRand.ar(10.reciprocal, 1, Impulse.kr(8.reciprocal))).range(-1,1),
			level: (i+1).reciprocal
		) * -20.dbamp;
	}));
	localout = Compander.ar(in: localout, control: localout, thresh: -6.dbamp, slopeAbove: 3.reciprocal);
	LocalOut.ar(localout);
	snd = LocalIn.ar(2) * feedback;
	OffsetOut.ar(out, (localout.tanh * env) * amp);
}).add;

SynthDef(\Colleen, { arg out = 0, amp=1, pan = 0, atk=0.35, rel=2, freq=110, doneAction = 2;
	var sig, env;
	freq = 1*freq*(320/250)*PinkNoise.kr(0.05,1)*BrownNoise.kr(0.01,1)*2;
	sig = LPF.ar(CombC.ar(Decay.ar(Impulse.ar(0), 0.2, BrownNoise.ar), 4/(BrownNoise.kr(XLine.kr(10,1,0.2),freq)), 4/(PinkNoise.kr(XLine.kr(10,1,0.2),freq)), 3, 0.4),4000);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction: doneAction);
	sig = sig + PinkNoise.ar(0.1);
	sig = LPF.ar(sig, XLine.kr(100,700,rel*0.1));
	sig = (sig*env*amp)*4;
	sig = Pan2.ar(sig,pan);
	OffsetOut.ar(out, sig);
}).add;

~zeynepSynthDef = SynthDef(\zeynep, { arg out = 0, amp=1, freq=440, envL1 = 0, envL2 = 0.03, envL3 = 0.1, envL4 = 0.2, envL5 = 0, envT1=1, envT2=1, envT3=4, envT4=0.2, dur = 1, beats=1, lpf = 3200, hpf = 2000, doneAction = 2;
	var sig, env;
	sig = Resonz.ar(WhiteNoise.ar(0.5), freq, XLine.kr(0.1, 0.001, dur*beats))*50;
	env = EnvGen.kr(Env.new([envL1,envL2,envL3,envL4,envL5],[envT1,envT2,envT3,envT4],[1,-1]),doneAction: doneAction);
	sig = LPF.ar(sig, lpf);
	sig = HPF.ar(sig, hpf);
	sig = (sig*env*amp).tanh;
	OffsetOut.ar(out, [sig, sig]);
}).add;

SynthDef(\sosTom, { arg out = 0, amp = 0.6, pan = 0, drumRel = 0.4, stickRel = 0.01, drumModeAmp = 0.25, freq = 250, timbreIndex = 0.77, att = 0.005, curve = -6, doneAction = 2;

	var drumMode, drumModeEnv, stick, stickEnv, snd;

	drumModeEnv = Env.perc(
		            attackTime: att,
		            releaseTime: drumRel,
		            level: 0.5,
		            curve: curve).kr(doneAction: doneAction);

	drumMode = PMOsc.ar(
		            carfreq: Saw.ar(freq: freq * 0.9),
					modfreq: freq * 0.85,
					pmindex: timbreIndex,
					mul: drumModeEnv * 10);

	drumMode = drumMode + SinOsc.ar(freq: [freq, freq * 0.8], mul: drumModeEnv);

	drumMode = Mix.ar(drumMode) * drumModeAmp;

	stick = Crackle.ar(chaosParam: 2.01);

	stickEnv = Env.perc(attackTime: att, releaseTime: stickRel, level: 3, curve: curve).kr;

	snd = Mix.ar(drumMode + stickEnv) * amp;

	snd = LeakDC.ar(snd);

    OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\beating, { arg out = 0, amp = 0.1, pan = 0, att = 0.01, dec = 1, freq = 440, curve = -4, beatFreq = 15, doneAction = 2;

	var env, snd, oscillator1, oscillator2;

	env = Env.perc(att, dec, amp, curve).kr(doneAction: doneAction);

	oscillator1 = SinOsc.ar(freq); //Try other waveforms for the oscillators! Mix and match, collect them all!
	oscillator2 = SinOsc.ar(Line.kr(freq + beatFreq, freq, dec));

	snd = Mix([oscillator1, oscillator2]);
	snd = snd * env;

	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\blip1, {arg out = 0, amp = 0.1, pan = 0, att = 0.01, rel = 1, freq = 25, numharm = 10, doneAction = 2;
	var snd, env;
	env = Env.perc(att, rel, amp).kr(doneAction: doneAction);
	snd = Blip.ar(
		freq: freq * [1, 1.01],
		numharm: numharm,
		mul: env
	);
	snd = LeakDC.ar(snd);
	snd = Mix.ar(snd);
	snd = Pan2.ar(snd, pan);
	OffsetOut.ar(out, snd);
}).add;

SynthDef(\laserbeam, { arg out = 0, amp = 0.6, pan = 0.0, freq = 40, att = 0.01, doneAction = 2;
	var snd, freqenv, ampenv;
	// frequency envelope
	freqenv = EnvGen.ar(Env([4, 0.5, 1, 1], [att, 0.01, 1.0]));
	// amplitude envelope
	// no gate: fixed-time envelope, self-terminating.
	ampenv = EnvGen.ar(
		envelope: Env([0, 1, 0.5, 0.0], [0.02, 0.2, 0.1]),
		levelScale: amp,
		doneAction: doneAction);
	snd = LFTri.ar(freq: freq * freqenv, mul: ampenv);
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\ping_mh,{ arg out = 0, amp = 0.2, pan = 0, att = 0.001, dur = 1, curve = -4, freq = 90, rate = 4, depth = 0.03, doneAction = 2;
	var snd, lfo, env;

	lfo = LFNoise2.ar(rate).range(1 / (1 + depth), (1 + depth));

	env = Env.perc(attackTime: att, releaseTime: dur, level: amp, curve: curve).kr(doneAction: doneAction);

	snd = SinOsc.ar(freq: [freq, freq * lfo], mul: env);

	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\pulseRisset, {arg out = 0, amp = 0.1, pan = 0, att = 0.01, rel = 11, freq = 440, pulseFreq = 8;
    var partials, durs, amps, snd, env;
 	partials = [246.4, 247.4, 404.8, 406.5, 523.6, 748, 880, 1206, 1320, 1654, 1791]; // original freqs
	partials = (partials / 440) * freq; // consider 440 the 'root'
	durs = [11, 10, 7, 6, 4, 3.4, 3, 2.2, 2, 1.1, 1] / 11;
	amps = durs.linlin(1, 11, 0.2, 1);

	env = Env.perc(
		attackTime: att,
		releaseTime: durs * rel,
		level: amps
	).kr(doneAction: [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]); // only longest env gets doneAction: 2

	snd = Pulse.ar(partials) * env * amp / 11;

	snd = RLPF.ar(
		in: snd,
		freq: freq * LFPulse.ar(pulseFreq).range(2, 4),
		rq: SinOsc.ar(LFNoise2.kr(1).range(4, 9)).range(0.1, 0.3)
	);

	snd = LPF.ar(snd, 12000);
	snd = Limiter.ar(Mix.ar(snd));

	OffsetOut.ar(out, Pan2.ar(snd,pan) );
}).add;

SynthDef(\sin_pulsar, { arg out = 0, doneAction = 2;
    var a, b, c, d, e, f, f_, fund, t, lev, formantA, formantB, overlapA, overlapB;
    lev = \lev.kr(0.3);
    f = \freq.kr(440);
    f_ = f.clip(50, 1500);
    formantA = \formantA.kr(2);
    formantB = \formantB.kr(6);
    overlapA = \overlapA.kr(2);
    overlapB = \overlapB.kr(2);

    e = EnvGen.kr(
        Env.perc(
            attackTime: f_.linlin(50, 1500, 0.1, 0.02),
            releaseTime: Rand(1, 7)
        ),
        gate: \gate.kr(1)
    );

    e = e * PinkNoise.ar(1!2).range(0.1, 1).lag(0.02);

    fund = GrainSin.ar(
        numChannels: 1,
        trigger: Impulse.ar(f),
        dur: Rand(0.5, 2) * (1.05 - e.pow(1.1))
        // Rand(0.5, 2) * (0.05 + e.pow(1.1))
        * SinOsc.ar(e * 3, {Rand(0, 6.28)}.dup).range(0.87, 1.15)
        / f,
        freq: f
        * SinOsc.ar(e * 3, {Rand(0, 6.28)}.dup).range(0.9, Rand(1, 1.5))
        ,
        pan: PinkNoise.ar(0.5!2)
    );

    a = GrainSin.ar(
        numChannels: 1,
        trigger: Impulse.ar(f + Rand(-3, 3)),
        dur: overlapA * (1.05 + e.pow(1.5))
        // overlapA * (0.05 + e.pow(1.1))
        * SinOsc.ar(e * 4, {Rand(0, 6.28)}.dup).range(0.87, 1.15)
        / f,
        freq: f
        * (formantA * SinOsc.ar(e * 4, {Rand(0, 6.28)}.dup).range(0.9, 1.1))
        ,
        pan: PinkNoise.ar(0.5!2)
    );

    b = GrainSin.ar(
        numChannels: 1,
        trigger: Impulse.ar(f + Rand(-3, 3)),
        dur: overlapB * (1.05 + e.pow(2.5))
        // overlapB * (0.05 + e.pow(1.1))
        * SinOsc.ar(e * 6, {Rand(0, 6.28)}.dup).range(0.87, 1.15)
        / f,
        freq: f
        * (formantB * SinOsc.ar(e * 5, {Rand(0, 6.28)}.dup).range(0.9, Rand(1, 1.5)))
        ,
        pan: PinkNoise.ar(0.5!2)
    );

    c = Mix([
        fund * (lev * e).pow(0.7),
        a * (lev * e).pow(f_.linlin(50, 1500, 1.1, 1.5)),
        b * (lev * e).pow(f_.linlin(50, 1500, 1.5, 2.5))
    ]);

    c =LeakDC.ar(c);

    d = c;

    4.do{ arg i;
        d = AllpassC.ar(
            d,
            delaytime: LFNoise1.kr(0.2!2).range(0.01, 0.02)
        )
    } *0.5;

    d = c * Rand(0.1, 0.9) + d;

    DetectSilence.ar(d, doneAction: doneAction);
    OffsetOut.ar(out, d);

}).add;

SynthDef(\fm_pulsar, { arg out = 0, doneAction = 2;
    var a, e, f;
    var t, overlap, carfreq, modfreq, mInd, vel, vel_;

    f = \freq.kr(100);
    f = f + SinOsc.ar(LFNoise1.kr(0.3!2).range(1, 4));

    vel = \vel.kr(0.5);
    vel_ = vel.clip(0, 1.0).linlin(0, 1, 2, 0.7);

    e = EnvGen.kr(
        Env.adsr(
            \att.kr(0.025) * vel_,
            \dec.kr(0.02) * vel_,
            \sus.kr(0.7),
            \rel.kr(4),
            curve: \curve.kr(-4)
        ),
        gate: \gate.kr(1),
        doneAction: doneAction
    ) * vel;

    e = e * PinkNoise.ar(1!2).range(0.1, 1).lag(0.02);

    carfreq = f * \cf.kr(2) + LFNoise1.kr(3).range(0, 50);
    modfreq = carfreq * \mf.kr(2) + LFNoise1.kr(3).range(0, 100);

    t = Impulse.ar(f);
    mInd = e.pow(3.3) * LFNoise2.kr(5!2).range(\mIndMin.kr(0.1), \mIndMax.kr(2.3));
    overlap = 1.1 - e.pow(0.5) * LFNoise1.kr(0.3!2).range(\olapMin.kr(1), \olapMax.kr(8));
    d = overlap/f;

    a = Mix([
        SinOsc.ar(f),
        GrainFM.ar(1, t, d, carfreq, modfreq, mInd)
    ]);

    a = LeakDC.ar(a * e);
    OffsetOut.ar(out, a * \gain.kr(0.1));

}).add;

SynthDef(\pm4, {

    var numops = 4;
    var fb = LocalIn.ar(numops);

    var gate = \gate.kr(1);
    var in_freq = \freq.ar(261).lag(\glis.kr(0));
    var bend = \bend.ar(0).midiratio;
    var freqbend = in_freq * bend;
    var freq = Vibrato.ar(freqbend, \vrate.kr(6), \vdepth.kr(0.000));
    var detunehz = \detunehz.kr(0);
    var vel = \vel.kr(1);

    var car = numops.collect({arg i;
        var num = i+1;
        var ratio = ('op' ++ num ++ 'ratio').asSymbol;
        var curve = ('op' ++ num ++ 'curve').asSymbol.kr(0);
        var atk = ('op' ++ num ++ 'atk').asSymbol.kr(0.01);
        var dec = ('op' ++ num ++ 'dec').asSymbol.kr(0.01);
        var suslevel = ('op' ++ num ++ 'suslevel').asSymbol.kr(1);
        var rel = ('op' ++ num ++ 'rel').asSymbol.kr(1);
        var env = Env.adsr(
            attackTime:atk,
            decayTime:dec,
            sustainLevel:suslevel,
            releaseTime:rel,
            curve:curve
        ).kr(gate:gate);

        [freq * ratio.kr(1) + Rand(detunehz.neg, detunehz), env]
    });

    var mods = numops.collect({arg i;
        var y = i + 1;
        numops.collect({arg j;
            var x = j + 1;
            var key = ('m' ++ y ++ '_' ++ x).asSymbol;
            key.kr(0);
        });
    });

    var sig = numops.collect({arg i;
        var num = i+1;
        var freq = car[i][0].clip(20, 20000);
        var index = mods[i];
        var mod = (fb * index).sum;
        var sig = SinOsc.ar(freq, mod.mod(2pi)) * car[i][1];
        var coef = ('op' ++ num ++ 'coef').asSymbol.kr(0.5).clip(-1, 1);
        sig = OnePole.ar(sig, coef);
        sig;
    });

    sig = LeakDC.ar(sig);

    LocalOut.ar(sig);

    // set output level
    sig = sig * numops.collect({arg i;
        var num = i + 1;
        var key = ('op' ++ num).asSymbol;
        key.kr(1);
    }).normalizeSum;

    // set panning
    sig = numops.collect({arg i;
        var num = i + 1;
        var key = ('op' ++ num ++ 'pan').asSymbol;
        Pan2.ar(sig[i],    key.kr(0),    1)
    }).sum;

    sig = BLowPass.ar(
        BHiPass.ar(sig,
            \hpf.kr(20).clip(20, 18000),
            \hpfres.kr(0).linlin(0, 1, 1, 0.001)
        ),
        \lpf.kr(20000).clip(20, 20000),
        \lpfres.kr(0).linlin(0, 1, 1, 0.001)
    );

    sig = sig * AmpCompA.kr(freq) * \amp.kr(0.1) * vel;
    sig = sig.softclip;
    DetectSilence.ar(sig, doneAction: \doneAction.ir(2));

    OffsetOut.ar(\out.kr(0), sig);

}).add;

SynthDef(\sawFiltKyma, { |out = 0, amp = 0.1, freq = 440, cf = 100, wobble = 3, t_bd, t_sd, pw = 0.4, gate = 1, doneAction = 2|
    var base = Splay.ar(RLPF.ar(Pulse.ar(freq * [0.99,0.5,1.01],pw),cf.lag(0.05),0.3).madd(SinOsc.ar(wobble).range(0.5,4)).sin) * 0.5;
    var env = Linen.kr(gate, attackTime: 0.01, releaseTime: 0.5, doneAction: doneAction);
    var sig = base;
    var bd = tanh(Ringz.ar(LPF.ar(Trig.ar(t_bd,SampleDur.ir),1000),30,0.5,5).sin*2);
    var sd = tanh(Ringz.ar(LPF.ar(Trig.ar(t_sd,SampleDur.ir),1000),120,0.75,PinkNoise.ar(2!2)).sin*2);
    sd = HPF.ar(sd,60);
    sig = tanh(GVerb.ar(HPF.ar(base * env,30), 70, 11, 0.15)*0.5 + sig + bd + sd);
    OffsetOut.ar(out, sig*amp*env);
}).add;

SynthDef(\s1, {
    var freq = \freq.kr(220);
    var cutoff = \cutoff.kr(100);
    var fvel = \fvel.kr(8);
    var res = \res.kr(0.5).linlin(0, 1, 1, 0.001);
    var aeg = Env.asr.ar(doneAction:Done.freeSelf, gate:\gate.kr(1));
    var sig = RLPF.ar(Saw.ar(freq), aeg.linlin(0, 1, cutoff, cutoff * fvel), res);
    sig = sig * aeg * \amp.kr(0.3);
    sig = Splay.ar(sig);
    OffsetOut.ar(\out.kr(0), sig);
}).add;

SynthDef(\fakeRes, {
    arg  out = 0, freq = 200, peamount = 900,
    pitchAtt = 0.001, pitchDec = 0.13,
    ampAtt = 0.03, ampDec = 1.0, level = 0.5, doneAction = 2;

    var sig, sig1, sig2, ampenv, pitchenv, sig2Phase;

    pitchenv = EnvGen.ar(
        // Env([0, 1, 0], [pitchAtt, pitchDec], [0, 0])  // original
        Env([0, 1, 0], [pitchAtt, pitchDec],  \squared)
        // Env([0, 1, 0], [pitchAtt, pitchDec],  \cubed)
    );

    ampenv = EnvGen.ar(
        Env([0, 1, 0], [ampAtt, ampDec], [0, 0]),
        levelScale: level,
        doneAction: doneAction
    );

    sig1 = SinOsc.ar(
        freq,
        mul: -0.53,
        add: 0.5
    );

    sig2Phase = Sweep.ar(sig1, (freq + (pitchenv * peamount)));

    sig2 = SinOsc.ar(
        freq + (pitchenv * peamount),
        phase: 2pi * sig2Phase
    );

    // sig = (sig1 * sig2)**2;  // orig
    // sig = (sig1 * sig2).pow(2);  // same sound as orig
    sig = (sig1 * sig2).squared;  // sounds different

    sig = OnePole.ar(sig, -0.22); // added
    sig = sig * ampenv ! 2;
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\windowsync, { |out, freq = 65.40639132515, amp = 0.1,
    syncEgTop = 20, syncRatio = 2, syncDcy = 0.5, gate = 1, doneAction = 2|
    var syncEg = EnvGen.kr(Env([syncEgTop / syncRatio, 1], [syncDcy], \exp));
    var eg = EnvGen.kr(Env.adsr(0.01, 0.3, 0.6, 0.1), gate, doneAction: doneAction);
    var fundamental = LFTri.ar(freq);
    var syncFreq = freq * syncRatio * syncEg;
    // note, Phasor here is behaving like the Sweep above (retrigger behavior)
    // but Phasor loops around its range, eliminating the need for '% 1'
    var syncPhase = Phasor.ar(fundamental, syncFreq * SampleDur.ir, 0, 1, 0);
    var sig = SinOsc.ar(0, syncPhase * 2pi) * fundamental;
    OffsetOut.ar(out, (sig * (amp * eg)).dup);
}).add;

///////////////////////////////////////  Generatif

SynthDef(\lcm1, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, rate1 = 200, loRange1 = 1, rate2 = 6, loRange2 = 10, gate = 1, doneAction = 2;
    var sig, sig1, sig2, env;
    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);
    sig1 = SinOsc.ar(LFNoise2.ar(rate1, 500, 501)).range(loRange1, 100).round(1);
    sig2 = SinOsc.ar(LFNoise1.kr(rate2, 500, 501)).range(loRange2, 100).round(1);
    sig = tanh(lcm(sig1, sig2)*0.1);
    sig = sig * env;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\lcm2Gene, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, rate1 = 28, rate2 = 26, smooth1 = 0.4, smooth2 = 0.2, gate = 1, doneAction = 2;
    var sig, sig1, sig2, mod1, mod2, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    mod1 = TExpRand.kr(1, 1000, Impulse.kr(rate1));
    mod1 = Lag2.kr(mod1, smooth1);

    mod2 = TExpRand.kr(1, 1000, Dust.kr(rate2));
    mod2 = Lag2.kr(mod2, smooth2);

    sig1 = Saw.ar(mod1).range(-100,100).round(1);
    sig2 = LFCub.ar(mod2).range(-100,100).round(1);

    sig = tanh(lcm(sig1, sig2) * 0.001);

    sig = sig * env;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\gcdGene, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, sig1Frq = 0.02, sig2Frq = 1.24, dev = 0.1, mod = 30, gate = 1, doneAction = 2;
    var sig, sig1, sig2, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    sig1 = LFSaw.ar(sig1Frq) * 300 + 1;
    sig2 = LFSaw.ar(sig2Frq + [0, dev]) * 200 + 1;

    sig = SinOsc.ar(gcd(sig1, sig2) * mod + 300);

    sig = sig * env;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\gcdDmGene, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, sig1Frq = 3000, sig2Frq = 2995, mod1 = 100, mod2 = 100, dev = 25, gate = 1, doneAction = 2;
    var sig, sig1, sig2, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    sig1 = PulseCount.ar(Impulse.ar(sig1Frq)) % mod1;
    sig2 = PulseCount.ar(Impulse.ar(sig2Frq)) % mod2;

    sig = gcd(sig1, sig2 + [30, dev]);
    sig = Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3);

    sig = sig * env;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\gcdDm2Gene, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, sig1Frq = 3000, sig2Frq = 2995, mod1 = 20, mod2 = 20, dev1 = 3, dev2 = 7, gate = 1, doneAction = 2;
    var sig, sig1, sig2, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    sig1 = PulseCount.ar(TDuty.ar(Dseq((1..20), inf) + 41 * SampleDur.ir)) % mod1;
    sig2 = PulseCount.ar(TDuty.ar(Dseq((21..1), inf) + 40 * SampleDur.ir);) % mod2;

    sig = gcd(sig1, sig2 + [dev1, dev2]);
    sig = Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3);

    sig = sig * env;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\gcdDm3Gene, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, sig1Size = 10, sig2Size = 10, sig3Size = 10, add1 = 102, add2 = 101, add3 = 100, mod1 = 100, mod2 = 101, mod3 = 102, dev1 = 10, dev2 = 20, gate = 1, doneAction = 2;
    var sig, sig1, sig2, sig3, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    sig1 = TDuty.ar(Dseq([Dser(\seq1.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]), sig1Size)], inf) + add1 * SampleDur.ir);
    sig2 = TDuty.ar(Dseq([Dser(\seq2.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]), sig2Size)], inf) + add2 * SampleDur.ir);
    sig3 = TDuty.ar(Dseq([Dser(\seq3.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]), sig3Size)], inf) + add3 * SampleDur.ir);

    sig1 = PulseCount.ar(sig1) % mod1;
    sig2 = PulseCount.ar(sig2) % mod2;
    sig3 = PulseCount.ar(sig3) % mod3;

    sig = gcd(gcd(sig1 + [0, 0], sig2 + [0, dev1]), sig3 + [0, dev2]);
    sig = Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3);

    sig = sig * env;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\gcdLcmDmGene, { arg out = 0, amp = 0.1, pan = 0, spread = 0.5, atk = 0.001, rls = 0.2, sustain = 1, mul1 = 1, mul2 = 40, mulTanh = 0.0001, modu1 = 100, modu2 = 300, rate1 = 0.6, rate2 = 0.06, smooth1 = 0.4, smooth2 = 0, gate = 1, doneAction = 2;
    var mod1, mod2, sin1, sin2, sig, sig1, sig2, sig3, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    mod1 = TRand.kr(1, 300, Impulse.kr(rate1));
    mod1 = Lag2.kr(mod1, smooth1);

    mod2 = TRand.kr(1, 300, Dust.kr(rate2));
    mod2 = Lag2.kr(mod2, smooth2);

    sin1 = SinOsc.ar(mod1).range(1,100) * mul1;
    sin2 = SinOsc.ar(mod2) * mul2;

    sig1 = gcd(sin1, sin2) % modu1;
    sig2 = lcm(sin1, sin2) % modu2;

    sig = tanh([sig1 * sig2, sin1 * sin2] * mulTanh);

    sig = Splay.ar(sig, spread) * env;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\gcdDm4Gene, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, serSize = 27, start = 100, end = 0.1, rate1 = 10, mod2 = 300, mod3 = 101, dev1 = 0, dev2 = 2, add = 600, add1 = 61, mul1 = 43, gate = 1, doneAction = 2;
    var seq, envMod, src1, src2, src3, sig, sig1, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    seq = Dseq([Dser(\ser.kr(#[ 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77 ]), serSize)], inf);

    // envMod = XLine.kr(start, end, 100);

    envMod = LFTri.kr(0.005, -1).exprange(start, end);

    src1 = TDuty.ar(seq * envMod * SampleDur.ir);
    src2 = PulseCount.ar(Impulse.ar(rate1)) % mod2;
    src3 = PulseCount.ar(src1) % mod3;

    sig = gcd(src2, src3 + [0, 2]);
    sig1 = gcd(lcm(src2 + [dev1, dev2], src3),sig);

    sig = SinOsc.ar(sig * 443 + add) * 0.1;
    sig1 = SinOsc.ar(sig1 * mul1 + add1) * 0.4;

    sig = Pan2.ar(Limiter.ar(LPF.ar(HPF.ar(sig, 50) + sig1, 5000), 0.3) * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\gcdDm5Gene, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, serSize = 99, start = 10, end = 0.01, rate1 = 1, mod2 = 500, mod3 = 501, dev1 = 1, dev2 = 3, add = 400, add1 = 61, mul1 = 53, gate = 1, doneAction = 2;
    var seq, envMod, src1, src2, src3, sig, sig1, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    seq = Dseq([Dser(\ser.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99]), serSize)], inf);

    //envMod = XLine.kr(start, end, 100);

    envMod = LFTri.kr(0.005, -1).exprange(start, end);

    src1 = TDuty.ar(seq * envMod * SampleDur.ir);
    src2 = PulseCount.ar(Impulse.ar(rate1)) % mod2;
    src3 = PulseCount.ar(src1) % mod3;

    sig = gcd(src2, src3 + [0, 2]);
    sig1 = gcd(lcm(src2 + [dev1, dev2], src3),sig);

    sig = SinOsc.ar(sig * 443 + add) * 0.1;
    sig1 = SinOsc.ar(sig1 * mul1 + add1) * 0.3;

    sig = Pan2.ar(Limiter.ar(LPF.ar(HPF.ar(sig, 50) + sig1, 5000), 0.3) * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\gcdDmFbGene, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, ser1Size = 4, ser2Size = 5, add1 = 50, add2 = 50.1, mod = 50, sinFmin = 70, div = 10, sigSel = 0, fbSel = 0, gate = 1, doneAction = 2;
    var seq1, seq2, src1, src2, count1, count2, in, sinFrq, sig, sig1, sig2, sig3, sig4, sig5, fb, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    seq1 = Dseq([Dser(\ser1.kr(#[0, 1, 2, 3]), ser1Size)], inf);
    seq2 = Dseq([Dser(\ser2.kr(#[4, 3, 2, 1, 0]), ser2Size)], inf);

    src1 = TDuty.ar(seq1 + add1 * SampleDur.ir);
    src2 = TDuty.ar(seq2 + add2 * SampleDur.ir);

    count1 = PulseCount.ar(src1) % mod;
    count2 = PulseCount.ar(src2) % mod;

    in = LocalIn.ar(2);
    sig1 = gcd(count1, count2 + [0, 1]);
    sinFrq = sig1.linexp(0, mod, sinFmin, 10000);
    sig2 = SinOsc.ar(sinFrq, 0, in / 2);
    sig3 = SinOsc.ar(sinFrq * (in / div + 1));
    sig4 = SinOsc.ar(sinFrq);
    sig5 = SinOsc.ar(sinFrq) + BPF.ar(in * 0.95, LFDNoise3.ar(0.2).range(100, 10000));

    sigSel = sigSel.min(3).max(0);
    sig = Select.ar(sigSel, [sig2, sig3, sig4, sig5]);

    fbSel = fbSel.min(3).max(0);
    fb = Select.ar(fbSel, [sinFrq.reverse, in.reverse, sig * in, sig]);
    LocalOut.ar(fb);

    sig = Pan2.ar(Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3) * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\factorFun, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, mod = 0.5, gate = 1, doneAction = 2;
    var sig, env, factorfunc, scaling, gcdoutput;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    scaling = gcd(\f1.kr(#[1, 1, 1, 1]).product, \f2.kr(#[1, 1, 1, 1]).product);

    factorfunc = {|factors|
        var fprod = factors.product;

        //either 1 or factor randomly over time
        factors.collect{|f| (ToggleFF.ar(Dust.ar(LFNoise0.kr(f).range(1, mod.linexp(0, 1, 16, 440)))) * (f-1)) + 1;
        };

    };

    gcdoutput = gcd(factorfunc.(\f1.kr).product,factorfunc.(\f2.kr).product) / scaling;

    sig = SinOsc.ar(mod.linlin(0, 1, 20, 2000) * gcdoutput) * 0.3;

    sig = Pan2.ar(sig * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

/*Pdef(
    \test,
    Pbind(
        \instrument, \factorFun,
        \dur, 2,
        \f1, [#[2,3,5,10]],
        \f2, [#[2,1,6]],
        \mod, Pseq([0.2, 0.8, 1, 0.3, 0.12], inf),
        \amp, 0.5
    )
).play;

Pdef(\test).stop;*/

SynthDef(\factorFun1, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, hiRange = 0.5, pmIdx = 0.2, sigSel = 0, gate = 1, doneAction = 2;
    var sig, sig1, sig2, sig3, env, factorfunc, scaling, scaling1, gcdoutput, lcmoutput, f3, f4;
    hiRange = hiRange.min(1).max(0);
    pmIdx = pmIdx.min(1).max(0);
    sigSel = sigSel.min(2).max(0);

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    scaling = gcd(\f1.kr(#[1, 1, 1, 1, 1, 1, 1]).product, \f2.kr(#[1, 1, 1, 1, 1]).product);
    scaling1 = lcm(\f1.kr.product, \f2.kr.product);

    factorfunc = {|factors|
        var fprod = factors.product;

        //either 1 or factor randomly over time
        factors.collect{|f| (ToggleFF.ar(Dust.ar(LFNoise0.kr(f).range(1, hiRange.linexp(0, 1, 1, 440)))) * (f-1)) + 1 };

    };

    f3 = factorfunc.(\f1.kr).product;
    f4 = factorfunc.(\f2.kr).product;

    gcdoutput = gcd(f3, f4) / scaling;
    lcmoutput = lcm(f3, f4) / scaling1;

    sig1 = SinOsc.ar(pmIdx.linlin(0, 1, 20, [2000, 4001]) * [gcdoutput, lcmoutput]);
    sig2 = SinOsc.ar(([gcdoutput, lcmoutput] * 2000) + (gcdoutput * pmIdx.linexp(0, 1, 0.1, 10) * SinOsc.ar(lcmoutput))) * 0.8;
    sig3 = PMOsc.ar(lcmoutput*[5000,5001], gcdoutput*[700,703], pmIdx.linlin(0, 1, 1, 10)) * 0.74;

    sig = Select.ar(sigSel, [sig1, sig2, sig3]);
    sig = Pan2.ar(sig * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

/*Pdef(
    \test,
    Pbind(
        \instrument, \factorFun1,
        \dur, 2,
        \f1, [#[2,2,2,3,5,7,11]],
        \f2, [#[2,2,3,7,13]],
        \pmIdx, Pseq([0.2, 0.8, 1, 0.3, 0.12], inf),
        \hiRange, Pseq([0.2, 0.8, 1.5, -5], inf),
        \sigSel, 0,
        \amp, 0.1
    )
).play;*/

// need this: s.options.memSize_(16384*10);
SynthDef(\modelBits, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, mod1 = 1, mod2 = 1, gate = 1, doneAction = 2;
    var sig, sig1, sig2, count1, count2, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    count1 = PulseCount.ar(Impulse.ar(8e3 * mod1));
    count2 = PulseCount.ar(Impulse.ar(7009 * mod2));

    sig1 = HPF.ar(
        (
            ((count1 * 15) & (count1 >> 5)) |
            ((count1 * 5) & (count1 >> [3, 4])) |
            ((count1 * 2) & (count1 >> 9)) |
            ((count1 * 8) & (count1 >> 11)) |
            (((count1 * count1) & count1) | (count1 >> 3))
            - 3 % 256
        ) / 127-1 * 3
        , 20
    ) * 0.1;

    sig2 = LPF.ar(HPF.ar(gcd(count1 * count2, count2 + count1), WhiteNoise.ar()*2000 + 1000), 20);
    sig2 = sig2 * sig1;
    sig = Splay.ar(Limiter.ar(Greyhole.ar(sig1 + sig2, sig1, 0.5, sig1), 0.5).flatten);
    sig = Pan2.ar(sig * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\ulysse42, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, mod1 = 0.2, mod2 = 0.71, gate = 1, doneAction = 2;
    var sig, sig1, sig2, sig3, z1, z2, sinFrq, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    mod1 = mod1.linlin(0, 1, -10, 10);
    sig1 = LFSaw.kr(0.062).range(-10, 10);
    sig1 = sig1 + (mod2.linlin(0, 1, 0, 5) * (0..8));
    sig2 = sig1.frac;
    sig3 = 0.8 - sig2.moddif(0.5, 1);

    z1 = gcd(sig1, mod1) + sig2;
    z2 = lcm(sig1, mod1) + sig2;
    sinFrq = 120 * ([z1, z2].flop.abs + 1);

    sig = (SinOsc.ar(sinFrq) * AmpComp.kr(sinFrq) * sig3).mean;
    sig = Pan2.ar(sig * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\dannySimple, { arg out = 0, amp = 0.2, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, add1 = 0, add2 = 0, div1 = 0.03, div2 = 5, rng1Lo = (-3), rng1Hi = 2, rng2Lo = (-2), rng2Hi = 3, gate = 1, doneAction = 2;
    var sig, sig1, sig2, env, thr, frq1, frq2;

    thr = 0.03;
    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    frq1 = \freq1.kr(#[5, 6, 7, 8]);
    frq2 = \freq2.kr(#[ 3, 4, 5, 6, 7 ]);

    sig1 = SinOsc.ar(frq1 + add1 / div1).range(rng1Lo, rng1Hi);
    sig2 = SinOsc.ar(frq2 + add2 / div2).range(rng2Lo, rng2Hi);

    sig = gcd(sig1.product.round(1), sig2.round(1));
    sig = Limiter.ar(LeakDC.ar(Splay.ar(sig)), thr).clip2(thr);
    sig = Pan2.ar(sig * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\dannySimple1, { arg out = 0, amp = 0.7, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, add1 = 970, add2 = 1030, div1 = 30, div2 = 30, rng1Lo = (-4), rng1Hi = 4, rng2Lo = (-4), rng2Hi = 4, gate = 1, doneAction = 2;
    var sig, sig1, sig2, env, thr, frq1, frq2;

    thr = 0.03;
    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    frq1 = \freq1.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);
    frq2 = \freq2.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);

    sig1 = SinOsc.ar(frq1 + add1 / div1).range(rng1Lo, rng1Hi);
    sig2 = SinOsc.ar(frq2 + add2 / div2).range(rng2Lo, rng2Hi);

    sig = gcd(sig1.product.round(1), sig2.round(1));
    sig = Limiter.ar(LeakDC.ar(Splay.ar(sig)), thr).clip2(thr);
    sig = Pan2.ar(sig * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\modelAix, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, revtSel = 0, gate = 1, doneAction = 2;
    var snd, revt, revt1, revt2, revt3, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    snd = Pulse.ar(freq: LFNoise0.ar([2,3]).exprange(50,5000));
    snd = snd * LFPulse.ar(
        freq: LFNoise0.ar(1).exprange(0.5,8),
        width:0.02,
        mul: LFNoise1.ar(3).exprange(0.01,1000));
    snd = HPF.ar(snd, 50);

    // reverb time - various optons:
    revt1 = LFNoise0.ar(1).exprange(0.0001, 0.01);
    revt2 = LFTri.ar(0.0165, -1).exprange(1, 0.0001);
    revt3 = LFTri.ar(1/10, 1).range(0.01, 0.0001);

    revt = Select.ar(revtSel, [revt1, revt2, revt3, K2A.ar(0.000001)]);
    snd = Greyhole.ar(snd, revt, 0.5, revt);
    snd = Limiter.ar(snd, 0.9);
    snd = Pan2.ar(snd * env, pan, amp);
    OffsetOut.ar(out, snd);
}).add;

SynthDef(\lcmnoise, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, spread = 1, gate = 1, doneAction = 2;
    var snd, revchain, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    snd = [
        tanh(
            lcm(
                SinOsc.ar(LFNoise0.kr(LFNoise0.kr(1/10).exprange(0.1,1)).exprange(1,15000)
                ).range(-100,100).round(1),
                SinOsc.ar(LFNoise0.kr(LFNoise0.kr(1/10).exprange(0.1,1)).exprange(1,15000)
                ).range(-100,100).round(1)
            )*0.0001
        ),
        tanh(
            lcm(
                Saw.ar(LFNoise0.kr(LFNoise0.kr(1/10).exprange(0.1,1)).exprange(1,15000)
                ).range(-100,100).round(1),
                LFCub.ar(LFNoise0.kr(LFNoise0.kr(1/10).exprange(0.1,1)).exprange(1,15000)
                ).range(-100,100).round(1)
            )*0.0001
        )
    ];

    snd = BHiPass.ar(snd, 180);
    snd = snd.softclip * 0.8;
    snd = Splay.ar(snd, spread: spread);
    revchain = snd * Lag.ar(
        LFPulse.ar(
            LFNoise0.ar(1).exprange(0.01,2),
            width:0.001
        ),
        0.1
    ) * LFNoise1.ar(1).range(10,10000);

    revchain = Greyhole.ar(
        in: revchain,
        delayTime: LFNoise1.ar(1).range(0.0001,0.2),
        damp: 0.5,
        size: LFNoise1.ar(0.1).exprange(0.0001,5),
        feedback: 0.95
    );
    revchain = LeakDC.ar(revchain);
    revchain = Limiter.ar(revchain) * LFNoise1.ar([1,1]).range(0,0.9);
    snd = snd * LFNoise0.ar([0.9,0.8]).range(0,2);
    snd = snd + revchain;
    //snd = Limiter.ar(snd, 0.7);
    snd = snd.softclip;
    snd = LPF.ar(snd, LFNoise1.ar(0.1).exprange(100,20000));
    snd = Pan2.ar(snd * env, pan, amp);
    OffsetOut.ar(out, snd);
}).add;

SynthDef(\gcdFunc, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, thr = 0.1, gate = 1, doneAction = 2;
    var sig, src, gcdFunc, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    gcdFunc = { |a| (a.size > 2).if { gcd(a[0], gcdFunc.(a.drop(1))) } { gcd(a[0], a[1]) } };

    src = { SinOsc.ar([40, 51], LFDNoise3.ar(0.05).range(0, 2pi)).range(-4, 4) } ! 4;
    sig = gcdFunc.(src);
    sig = Limiter.ar(LPF.ar(LeakDC.ar(Splay.ar(sig)), 10000), thr).clip2(thr);
    sig = Pan2.ar(sig * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

/*SynthDef(\duryGene, { arg out = 0, amp = 0.1, atk = 0.001, rls = 0.2, sustain = 1, impFreq1 = 0.02, impFreq2 = 0.04, smooth1 = 4, smooth2 = 1.7, smooth3 = 0.9, gate = 1, doneAction = 2;
    var snd, rep, repCh, randNum, fac, fac1, fac2, fac3;

    rep = [4, 8, 16, 24, 32];
    repCh = TChoose.kr(Impulse.kr(impFreq1), rep);
    randNum = [

        54, 60, 66, 72, 81, 90, 96, 102,
        108, 128, 132, 144, 162, 180, 192, 204,
        216, 240, 264, 288, 324, 360, 384, 408,
        432, 480, 528, 576, 648, 720, 768, 816,
        864, 960, 1056, 1152, 1296, 1440, 1536, 1632,
        1728, 1920, 2112, 2304, 2592, 2880, 3072, 3264,
        3456, 3840, 4224, 4608, 5184, 5760, 6144, 6528,
        6912, 7680, 8448, 9216, 10368, 11520, 12288, 528

    ];
    fac = [1, 10, 100, 1000];
    fac1 = Lag2.kr(TChoose.kr(Impulse.kr(impFreq2), fac), smooth1);
    fac2 = Lag3.kr(TChoose.kr(Impulse.kr(impFreq1 * 0.76), fac), smooth2);
    fac3 = Lag2.kr(TChoose.kr(Impulse.kr(impFreq2 * 0.86), fac), smooth3);

    snd = Mix.fill(8, { arg i;
        var detune;
        var saw;
        var tri;
        var sig;
        detune = LFNoise1.kr(0.003 + Rand(0, 0.9)).range(0.1, 1 + Rand(0, 250.0)) * Rand(0, 2.0) * TChoose.kr(Impulse.kr(0), [1,-1]);
        tri = LFTri.ar(TChoose.kr(Impulse.kr(0), randNum) * ( 1 + ( SinOsc.ar(TChoose.kr(Impulse.kr(0), randNum) / fac1) * TChoose.kr(Impulse.kr(0), randNum) / fac2 )) + detune, Rand(0, 1)/*, 0.25*/);
        saw = RLPF.ar(Saw.ar(TChoose.kr(Impulse.kr(0), randNum) * 0.01 + detune, 0.75), TChoose.kr(Impulse.kr(0), randNum), Rand(0, 2));
        saw = TChoose.kr(Impulse.kr(0), [
            saw,
            saw.fold2( SinOsc.ar(TChoose.kr(Impulse.kr(0), randNum) / fac3).range(0.1, 1) ),
            saw.wrap2( SinOsc.ar(TChoose.kr(Impulse.kr(0), randNum) / fac3).range(0.1, 1) ),
            saw *  SinOsc.ar(TChoose.kr(Impulse.kr(0), randNum) / 2),
            ( saw *  SinOsc.ar(TChoose.kr(Impulse.kr(0), randNum) / fac3).range(1, 20) ).tanh / 2
        ]);
        sig = (tri + saw) * EnvGen.kr(Env.asr(rrand(4,20), 1, 1/repCh), gate, doneAction: doneAction);
        sig = Limiter.ar(sig * 1/(i + 0.1));
        sig = Pan2.ar(sig, Rand(-1, 1));
    });

    OffsetOut.ar(out, snd * amp);
}).add;*/

/*SynthDef(\west, {
	arg out, pan=0, fadeIn=0.01, fadeOut=0.01, freq = 220, pitchBendRatio = 1, glide = 0, fm1Ratio = 0.66, fm2Ratio = 3.3, fm1Amount = 0.0, fm2Amount = 0.0,
	vel = 0.7, pressure = 0, timbre = 0, waveShape = 0, waveFolds = 0, envType = 0, attack = 0.04, peak = 10000, decay = 1, amp = 1, lfoShape = 0, lfoFreq = 0.5,
	lfoToFreqAmount = 0, lfoToWaveShapeAmount = 0, lfoToWaveFoldsAmount = 0, lfoToFm1Amount = 0, lfoToFm2Amount = 0,
	lfoToAttackAmount = 0, lfoToPeakAmount = 0, lfoToDecayAmount = 0, lfoToReverbMixAmount = 0, drift = 0, dur=10, t_gate=1, gate=1, killGate=1, doneAction = 2;

	var i_nyquist = SampleRate.ir * 0.5, signal, controlLag = 0.005, i_numHarmonics = 44,
	modFreq, mod1, mod2, mod1Index, mod2Index, mod1Freq, mod2Freq, sinOsc, triOsc, additiveOsc, additivePhase,
	filterEnvVel, filterEnvLow, lpgEnvelope, lpgSignal, asrEnvelope, asrFilterFreq, asrSignal, killEnvelope, i_driftRate = 0.15, maxDecay=8;

	// Make lfos
	var lfo = Select.kr(lfoShape, [
		LFTri.kr(lfoFreq),
		LFSaw.kr(lfoFreq),
		LFPulse.kr(lfoFreq),
		LFDNoise0.kr(lfoFreq * 2)
	]);

	var lfoArray = Array.fill(9, 0);
	lfoArray[0] = (lfo * lfoToFreqAmount * 18).midiratio; // Freq ratio
	lfoArray[1] = (lfo * lfoToWaveShapeAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift); // Wave Shape
	lfoArray[2] = ((lfo * lfoToWaveFoldsAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 2; // Wave Folds
	lfoArray[3] = ((lfo * lfoToFm1Amount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 0.5; // FM1 Amount
	lfoArray[4] = ((lfo * lfoToFm2Amount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 0.5; // FM2 Amount
	lfoArray[5] = ((lfo * lfoToAttackAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 2.2; // Attack
	lfoArray[6] = (((lfo * lfoToPeakAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 24).midiratio; // Peak multiplier
	lfoArray[7] = ((lfo * lfoToDecayAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 2.2; // Decay
	lfoArray[8] = (lfo * lfoToReverbMixAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift); // Reverb Mix


	// LFO ins
	freq = (freq * lfoArray[0]).clip(0, i_nyquist);
	waveShape = (waveShape + lfoArray[1]).clip(0, 1);
	waveFolds = (waveFolds + lfoArray[2]).clip(0, 3);
	fm1Amount = (fm1Amount + lfoArray[3]).clip(0, 1);
	fm2Amount = (fm2Amount + lfoArray[4]).clip(0, 1);
	attack = (attack + lfoArray[5]).clip(0.003, 8);
	peak = (peak * lfoArray[6]).clip(100, 10000);
	decay = (decay + lfoArray[7]).clip(0.01, maxDecay);

	// Lag inputs
	freq = Lag.kr(freq * pitchBendRatio, 0.007 + glide);
	fm1Ratio = Lag.kr(fm1Ratio, controlLag);
	fm2Ratio = Lag.kr(fm2Ratio, controlLag);
	fm1Amount = Lag.kr(fm1Amount.squared, controlLag);
	fm2Amount = Lag.kr(fm2Amount.squared, controlLag);

	vel = Lag.kr(vel, controlLag);
	waveShape = Lag.kr(waveShape, controlLag);
	waveFolds = Lag.kr(waveFolds, controlLag);
	attack = Lag.kr(attack, controlLag);
	peak = Lag.kr(peak, controlLag);
	decay = Lag.kr(decay, controlLag);

	// Modulators
	mod1Index = fm1Amount * 22;
	mod1Freq = freq * fm1Ratio * LFNoise2.kr(freq: 0.1, mul: 0.001, add: 1);
	mod1 = SinOsc.ar(freq: mod1Freq, phase: 0, mul: mod1Index * mod1Freq, add: 0);
	mod2Index = fm2Amount * 12;
	mod2Freq = freq * fm2Ratio * LFNoise2.kr(freq: 0.1, mul: 0.005, add: 1);
	mod2 = SinOsc.ar(freq: mod2Freq, phase: 0, mul: mod2Index * mod2Freq, add: 0);
	modFreq = freq + mod1 + mod2;

	// Sine and triangle
	sinOsc = SinOsc.ar(freq: modFreq, phase: 0, mul: 0.5);
	triOsc = VarSaw.ar(freq: modFreq, iphase: 0, width: 0.5, mul: 0.5);

	// Additive square and saw
	additivePhase = LFSaw.ar(freq: modFreq, iphase: 1, mul: pi, add: pi);
	additiveOsc = Mix.fill(i_numHarmonics, {
		arg index;
		var harmonic, harmonicFreq, harmonicCutoff, attenuation;

		harmonic = index + 1;
		harmonicFreq = freq * harmonic;
		harmonicCutoff = i_nyquist - harmonicFreq;

		// Attenuate harmonics that will go over nyquist once FM is applied
		attenuation = Select.kr(index, [1, // Save the fundamental
			(harmonicCutoff - (harmonicFreq * 0.25) - harmonicFreq).expexp(0.000001, harmonicFreq * 0.5, 0.000001, 1)]);

		(sin(additivePhase * harmonic % 2pi) / harmonic) * attenuation * (harmonic % 2 + waveShape.linlin(0.666666, 1, 0, 1)).min(1);
	}
	);

	// Mix carriers
	signal = LinSelectX.ar(waveShape * 3, [sinOsc, triOsc, additiveOsc]);

	// Fold
	signal = Fold.ar(in: signal * (1 + (timbre * 0.5) + (waveFolds * 2)), lo: -0.5, hi: 0.5);

	// Hack away some aliasing
	signal = LPF.ar(in: signal, freq: 12000);

	// Noise
	signal = signal + PinkNoise.ar(mul: 0.003);

	// LPG
	filterEnvVel = vel.linlin(0, 1, 0.5, 1);
	filterEnvLow = (peak * filterEnvVel).min(300);

	lpgEnvelope = EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [0.003, decay], curve: [4, -20]), gate: t_gate, timeScale: dur);
	lpgSignal = RLPF.ar(in: signal, freq: lpgEnvelope.linlin(0, 1, filterEnvLow, peak * filterEnvVel), rq: 0.9);
	lpgSignal = lpgSignal * EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [0.002, decay], curve: [4, -10]), gate: t_gate, timeScale: dur);

	// ASR with 4-pole filter
	asrEnvelope = EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [attack, decay], curve: -4, releaseNode: 1), gate: gate);
	asrFilterFreq = asrEnvelope.linlin(0, 1, filterEnvLow, peak * filterEnvVel);
	asrSignal = RLPF.ar(in: signal, freq: asrFilterFreq, rq: 0.95);
	asrSignal = RLPF.ar(in: asrSignal, freq: asrFilterFreq, rq: 0.95);
	asrSignal = asrSignal * EnvGen.ar(envelope: Env.asr(attackTime: attack, sustainLevel: 1, releaseTime: decay, curve: -4), gate: gate);

	signal = Select.ar(envType, [lpgSignal, asrSignal]);

	signal = signal * vel.linlin(0, 1, 0.2, 1) ;

	// Saturation amp
	signal = tanh(signal * pressure.linlin(0, 1, 1.5, 3) * amp).softclip;

	// main Envelope
	signal = signal * EnvGen.kr(
		Env([0.0,1.0,1.0,0], [fadeIn, fadeOut], releaseNode: 2),
		gate: killGate,
		doneAction: doneAction
	);

	// Pan
	signal = Pan2.ar(signal, pan);

	OffsetOut.ar(out, signal);

}).add;*/

)