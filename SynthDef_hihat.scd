(

///////////////////////////////////////  HiHat

SynthDef(\hat, { | out = 0, amp = 1 |
	var osc1, env;
	osc1 = WhiteNoise.ar;
	env = EnvGen.kr(Env.perc(0, 0.01), doneAction: 2);
	OffsetOut.ar(out, Pan2.ar(osc1, 0, env*amp));
}).add;

~ikedaHiNoiseSynthDef = SynthDef(\IkedaHiNoise, { arg out = 0, t_trig = 0, attack = 0.02, decay = 0.1, amp = 0.05, rq = 0.9, pan = 0, level = 10;
	var noise, sig;
	noise = WhiteNoise.ar(Decay2.kr(t_trig, attack, decay, amp));
	sig = BPF.ar(noise, TRand.kr(12000, 15000, t_trig), rq.max(0.001));
	DetectSilence.ar(sig, 0.001, doneAction:2);
	OffsetOut.ar(out, Pan2.ar(sig, pan, level));
}).add;

SynthDef(\IkedaClick, { arg out = 0, t_trig = 0, centerFreq = 15000, rq = 0.9, amp = 25, pan = 0, level = 1;
	var noise, sig;
 	noise = PinkNoise.ar(Decay.kr(t_trig, 0.001 * LFNoise1.kr(4).abs));
 	sig = BPF.ar(noise, centerFreq.max(1), rq, amp * LFNoise1.kr(8).range(0, 1)).fold(-1, 1);
 	DetectSilence.ar(sig, 0.0001, doneAction:2);
 	OffsetOut.ar(out, Pan2.ar(sig, pan, level));
}).add;

SynthDef(\hatY,{arg gate = 1, amp=1, out=0,rel=0.1;
	var env = EnvGen.ar(Env.perc(0,rel),gate,doneAction:2);
	var freq = EnvGen.ar(Env([12000,80,20000],[0.1,0.1]));
	var sig = PinkNoise.ar(env);
	sig = HPF.ar(sig,freq);
	sig = sig.tanh;
	OffsetOut.ar(out,sig*amp*12);
}).add;

SynthDef(\hatnew, {|out=0, freq=230, hpf=8500, rel=0.15, amp=1, fxb=0, fxv=0, bbcb=0, bbcv=0|
  var pulse, sig, env, freqs;
  freqs = [freq, freq*1.4471, freq*1.617, freq*1.9265, freq*2.5028, freq*2.6637];
  pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6, mul: 1));
  sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
  env = EnvGen.kr(Env.perc(0,rel),doneAction:2);
  sig = sig*env*amp;
    //sig =  Pan2.ar(sig*amp,0);
  OffsetOut.ar(out,sig);
}).add;

SynthDef(\hat909, {|out=0, freq=230, hpf=6500, release=0.15, amp=1, fxb=0, fxv=0, bbcb=0, bbcv=0|
  var pulse, sig, env, freqs;
  freqs = [freq, freq*1.4471, freq*1.617, freq*1.9265, freq*2.5028, freq*2.6637];
  pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6, mul: 1));
  sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
  env = EnvGen.kr(Env.perc(0,release),doneAction:2);
  sig = sig*env;
  Out.ar(out, Pan2.ar(sig*amp,0));
}).add;

SynthDef(\hat808, { arg out=0,tu=1, amp=0.1, gate=1, pan=0;
	var sig;
	var env = EnvGen.ar(Env.perc(0.01,0.1),doneAction:2);
	sig = Saw.ar((1..9)*1000.23*env*tu);
	sig = RHPF.ar(sig, \hpf.kr(5700), \rq.kr(0.5));
	sig = sig * (1+EnvGen.ar(Env.perc((-0.1),\rel.kr(0.1),-4),gate))*tu;
	sig = Ringz.ar(sig,(10..15)*1000.234,1).mean;
	sig = RHPF.ar(sig, \lpf.kr(2000)*env*tu, \rq.kr(0.5));
	OffsetOut.ar(out, sig*amp);
}).add;

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

SynthDef(\basicHiHat, {arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
	var env, snd;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = WhiteNoise.ar;
	snd = HPF.ar(in: snd, freq: ffreq, mul: env);
	Out.ar(out, Pan2.ar(snd, pan));

//By Nathan Ho aka Snappizz
//http://sccode.org/1-523
}).add;

SynthDef(\SOShats,
	{arg out = 0, freq = 6000, sustain = 0.1, amp = 0.8;
	var root_cymbal, root_cymbal_square, root_cymbal_pmosc;
	var initial_bpf_contour, initial_bpf, initial_env;
	var body_hpf, body_env;
	var cymbal_mix;

	root_cymbal_square = Pulse.ar(freq, 0.5, mul: 1);
	root_cymbal_pmosc = PMOsc.ar(root_cymbal_square,
					[freq*1.34, freq*2.405, freq*3.09, freq*1.309],
					[310/1.3, 26/0.5, 11/3.4, 0.72772],
					mul: 1,
					add: 0);
	root_cymbal = Mix.new(root_cymbal_pmosc);
	initial_bpf_contour = Line.kr(15000, 9000, 0.1);
	initial_env = EnvGen.ar(Env.perc(0.005, 0.1), 1.0);
	initial_bpf = BPF.ar(root_cymbal, initial_bpf_contour, mul:initial_env);
	body_env = EnvGen.ar(Env.perc(0.005, sustain, 1, -2), 1.0, doneAction: 2);
	body_hpf = HPF.ar(in: root_cymbal, freq: Line.kr(9000, 12000, sustain),mul: body_env, add: 0);
	cymbal_mix = Mix.new([initial_bpf, body_hpf]) * amp;
	Out.ar(out, [cymbal_mix, cymbal_mix])
	}).add;
//DrumSynths SC Example - SOS Drums by Renick Bell, renick_at_gmail.com
// recipes from Gordon Reid in his Sound on Sound articles
// SOShats -------
// http://www.soundonsound.com/sos/Jun02/articles/synthsecrets0602.asp

SynthDef(\hihat_electro, {
    |out = 0, pan = 0, amp = 0.3|
    var click, clickAmp;
    var noise, noiseAmp;
    var snd;

    // noise -> resonance -> expodec envelope
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.3, curve: -8), doneAction: 2);
    noise = Mix(BPF.ar(ClipNoise.ar, [4010, 4151], [0.15, 0.56], [1.0, 0.6])) * 0.7 * noiseAmp;

    snd = noise;

    Out.ar(out, Pan2.ar(snd, pan, amp));
//By Nathan Ho aka Snappizz
//http://sccode.org/1-523
}).add;

SynthDef(\hihatAw, {arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
	var snd = WhiteNoise.ar(amp);
	var env = Env.perc(att, rel).kr(doneAction: 2);
	snd = HPF.ar(snd * env, ffreq);
	Out.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\ikedhat,{arg out = 0, amp = 1, pan = 0, envLevel1 = 0.0, envLevel2 = 1.0, envLevel3 = 0.0, levelScale = 1, levelBias = 0, att= 0.0, rel = 0.01, timeScale = 1, hpf = 6000, t_trig = 1, doneAction = 2;
  var sig = HPF.ar(WhiteNoise.ar(1), hpf);
  var env = EnvGen.ar(Env([envLevel1, envLevel2, envLevel3], [att, rel]), t_trig, levelScale, levelBias, timeScale, doneAction);
  Out.ar(out, Pan2.ar(sig, pan, env*amp));
}).add;

)