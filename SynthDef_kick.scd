(

///////////////////////////////////////  Kick

~snapKickSynthDef = SynthDef(\snapkick, { |out = 0, pan = 0, amp = 0.3|
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

	OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\IkedaBass, { arg out = 0, t_trig = 0, pan = 0, amp = 1;
	var env, sin, sig;
	env = EnvGen.ar(Env(#[0, 0.5, 0.4, 0], #[0, 0.2, 0.01], -5), t_trig, doneAction: 2);
	sin = SinOsc.ar(0, (Sweep.ar(t_trig, 2pi * [52.8, 740]) + (pi/3)).wrap(-pi, pi), #[2, 0.05]).mean.tanh;
	sig = (sin * env)!2;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\gabberkick, {
    var snd, freq, high, lfo;
    freq = \freq.kr(440) * (Env.perc(0.001, 0.08, curve: -1).ar * 48 * \bend.kr(1)).midiratio;
    snd = Saw.ar(freq);
    snd = (snd * 100).tanh + ((snd.sign - snd) * -8.dbamp);
    high = HPF.ar(snd, 300);
    lfo = SinOsc.ar(8, [0, 0.5pi]).range(0, 0.01);
    high = high.dup(2) + (DelayC.ar(high, 0.01, lfo) * -2.dbamp);
    snd = LPF.ar(snd, 100).dup(2) + high;
    snd = RLPF.ar(snd, 7000, 2);
    snd = BPeakEQ.ar(snd, \ffreq.kr(3000) * XLine.kr(1, 0.8, 0.3), 0.5, 15);
    snd = snd * Env.asr(0.001, 1, 0.05).ar(2, \gate.kr(1));
    OffsetOut.ar(\out.kr(0), snd * \amp.kr(0.1));
}).add;

SynthDef(\kick, { arg out = 0, tu = 1, amp = 1, level = 1;
	var env0, env1, env1m, sig;
	env0 =  EnvGen.ar(Env.new(#[0.5, 1, 0.3, 0], #[0.01, 0.5, 0.26], #[-4, -2, -4]), doneAction: 2);
	env1 = EnvGen.ar(Env.new(#[120, 43, 29], #[0.03, 0.29], #[-4, -5]));
	env1m = env1.midicps;
	sig = LFPulse.ar(env1m*tu, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(1);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m*tu, 0.5, env0*4);
	sig = sig * amp;
	sig = sig.clip2(1);
	OffsetOut.ar(out, Pan2.ar(sig, 0, level));
}).add;

SynthDef(\kickhi, {
	arg out=0,tu = 1;
	var env0, env1, env1m, sig;
	env0 =  EnvGen.ar(Env.new([0.5, 0.1, 0.01, 0.01,0], [0.01, 0.5, 1.26,0.1], [-4, -2, -4]), doneAction:2);
	env1 = EnvGen.ar(Env.new([122, 30, 33,28], [0.05, 0.29,1], [-4, -5]));
	env1m = env1.midicps;
	sig = LFPulse.ar(env1m*tu, 0, 0.5, 1, -0.5);
	sig = out + WhiteNoise.ar(1);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m*tu, 0.5, env0*4);
	sig = sig * 1.2;
	sig = sig.clip2(1);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\kick2,{arg out=0,gate = 1 ,freq=60,tu = 1,amp=1,atf = 80, rel =1;
	var env = EnvGen.ar(Env.perc(0,rel),gate,doneAction:2);
	var frequ = EnvGen.ar(Env([freq-30,freq,60],[0.001,0.01]));
	var sig = SinOsc.ar(frequ*tu,0,env);
	sig = LPF.ar(sig,100);
	OffsetOut.ar(out,sig * amp);
}).add;

SynthDef(\kick2new,{arg out=0,gate = 1 ,freq=60,tu = 1,amp=1,atf = 80, rel =1;
    var env = EnvGen.ar(Env.perc(0,rel),gate,doneAction:2);
    var frequ = EnvGen.ar(Env([freq+1100,freq,31.4],[0.002,0.1]));
    var sig = SinOsc.ar(frequ*tu,0,env);
    sig = BPeakEQ.ar(sig,80,1,6);
    sig = sig *0.4*(env+0.2);
    sig = BPeakEQ.ar(sig,800,10,-12);
    sig = Limiter.ar(sig,0.5);
    //Out.ar(6,[DelayL.ar(sig*(-1),0.1,SinOsc.kr(-0.1,0,0.05,0.1)),sig]);
    //sig = LPF.ar(sig,100);
    OffsetOut.ar(out,sig * amp);
}).add;

SynthDef(\kick3,{arg out=0,amp=1,gate = 1, tu = 1, rel =3,freq=60;
	var env = EnvGen.ar(Env.perc(0,rel),gate,doneAction:2);
	var frequ = EnvGen.ar(Env([130,freq,30],[0.05,rel]));
	var sig = SinOsc.ar(freq*tu,0,env);
	OffsetOut.ar(out,sig * amp);
}).add;

SynthDef(\kick3new,{arg out=0,amp=1,gate = 1, tu = 1, rel =3,freq=60;
    var env = EnvGen.ar(Env.perc(0,rel),gate,doneAction:2);
    var frequ = EnvGen.ar(Env([100,50,50],[0.005,0.1]));
    var sig = SinOsc.ar(frequ*tu,0,env);
    OffsetOut.ar(out,sig * amp);
}).add;

SynthDef(\kicknoise,{arg out=0, amp=0.5;
	var env = EnvGen.ar(Env([0,1,0],[0.01,1]),doneAction:2);
	var freq =EnvGen.ar(Env([20000,100,30],[0.005,1]));
	var sig =  SinOsc.ar(freq,0,env)+(WhiteNoise.ar(1)*env);
	OffsetOut.ar(out,sig*amp);
}).add;

SynthDef(\t1kick,{arg out=0,rel = 0.6,pitch=1 ,amp =1 ,snd;
	var enva = EnvGen.ar(Env([0.01,1,0],[0.001,rel]),doneAction:2);
	var envf = EnvGen.ar(Env([800,50],[0.005,1]));
	var sig = SinOsc.ar(envf,0,enva);
	//sig = HPF.ar(sig*enva,30);
	OffsetOut.ar(out,sig*amp);
}).add;

SynthDef(\t1kick2,{arg out = 0,snd=18,rel = 0.6,pitch=0.1 ,amp =1;
	var enva = EnvGen.ar(Env([1,1,0],[rel,0.2]),doneAction:2);
	var envf = EnvGen.ar(Env([10000,20,00,4],[0.002,0.1,1,1]));
	var sig = SinOsc.ar(envf+50*pitch,0,enva);
	//sig = PitchShift.ar(sig,0.001,pitch,0.1);
	sig = sig.distort;
	sig = HPF.ar(FreeVerb.ar(sig,1,1),100)+sig;
	OffsetOut.ar(out,sig*amp*enva);
	//Out.ar(snd,sig*amp*enva);
}).add;

SynthDef(\kickmed, { | out = 0,snd=18,level=1, pan=0, atk= 0.01,decay = 0.2,release=0.26, fratio=1.5,noise=1,done=2,freq1= 120,freq2=30,freq3=30,dc=1,aamp1=1,aamp2=1,aamp3=1,aamp4=1,curve1= (-4),curve2=(-2),curve3=(-4),famp1,famp2,famp3,famp4,p1,oamp=0.1,owhich2=0,ochoose=0|
	var env0,env1,
env1m, son, son2,son3,son4,p2;
	p2 = p1 * (-pi);
env0 = Env([aamp1,aamp2,aamp3,aamp4,0],[atk,decay,release,0.5],[curve1, curve2, curve3]);
env1 = Env([freq1,freq2,freq3],[famp1,famp2,famp3,famp4],[curve1, curve2, curve3]);
env0 = EnvGen.ar(env0, doneAction:2);
env1 = EnvGen.ar(env1);
env1m = env1.midicps;
	son = LFSaw.ar(env1m,0,oamp, 1,1.4);
	son2 = SinOsc.ar(env1m, 0, oamp, 1,1.4);
	son3 = LFPulse.ar(env1m,0, oamp, 1,1.4);
	son4 = LFTri.ar(env1m,0, oamp, 1,1.4);
son = SelectX.ar(ochoose,[son,son2,son3,son4]);
son = LeakDC.ar(son,dc,30);
son = son + WhiteNoise.ar(noise);
son = LPF.ar(son, env1m*fratio, env0);
	son = son + SelectX.ar(owhich2,[ SinOsc.ar(env1m, p1, env0), LFSaw.ar(env1m, p1, env0), LFPulse.ar(env1m, p1, env0), LFTri.ar(env1m, p1, env0)]);
son = son * 1;
son = son*level.distort;
OffsetOut.ar(out, son*level).tanh;
//OffsetOut.ar(snd, Mono(son)*level).tanh;
}).add;

SynthDef(\kick808,{arg rel = 1, tu = 1, amp = 0.5, pan = 0, t_trig = 1;
	var env = EnvGen.ar(Env([0,1,0],[0,rel],-8), t_trig, doneAction:2);
	var enf  = EnvGen.ar(Env([1000,20,20],[0.001,0.001,0.001],-4));
	var sig = SinOsc.ar(tu*(enf+40))*env;
	sig = sig + LPF.ar(SinOsc.ar(SinOsc.ar(100,0,50,100*tu),0,0.2)*env,1000);
	OffsetOut.ar(0, Pan2.ar(sig * env, pan, amp));
}).add;

SynthDef(\kick808new,{arg out=0,rel=1,tu=2,amp=0.5;
    var env = EnvGen.ar(Env([1,1,0],[0,rel],-8),doneAction:2);
    var enf  = EnvGen.ar(Env([5000,100,50],[0.0001,0.01,0.1],-4));
    var sig = SinOsc.ar(tu*(enf))*env;
    sig = sig + LPF.ar(SinOsc.ar(SinOsc.ar(10,0,50,40*tu),0,0.01)*env,100);
    sig = LeakDC.ar(sig);
    OffsetOut.ar(out,sig*env*amp);
}).add;

SynthDef(\kickbass, { | out=2, level=1, pan=0, atk= 0.01,decay = 0.2,release=0.26, fratio=1.5,noise=1,done=2,freq1= 120,freq2=30,freq3=30,dc=1,aamp1=1,aamp2=1,aamp3=1,aamp4=1,curve1= (-4),curve2=(-2),curve3=(-4),famp1,famp2,famp3,famp4,p1,oamp=0.1,owhich2=0,ochoose=0,filter=20000|
	var env0,env1,
env1m, son, son2,son3,son4,p2;

	p2 = p1 * (-pi);
env0 = Env([aamp1,aamp2,aamp3,aamp4,0.1,0],[atk,decay,release],[curve1, curve2, curve3]);
env1 = Env([freq1,freq2,freq3],[famp1,famp2,famp3,famp4],[curve1, curve2, curve3]);

env0 = EnvGen.ar(env0,SinOsc.kr(0.025) ,doneAction:done);
	env1 = EnvGen.ar(env1);
env1m = env1.midicps;

son = LFSaw.ar(env1m,0,oamp, 1,1.4);//*LFSaw.ar(100).distort;
son2 = SinOsc.ar(env1m,0, oamp, 1,1.4);
son3 = LFPulse.ar(env1m,0, oamp, 1,1.4);
son4 = LFTri.ar(env1m,0, oamp, 1,1.4);

son = SelectX.ar(ochoose,[son,son2,son3,son4]);
	son = Pan2.ar(son,pan);
son = LeakDC.ar(son,dc,30);

//son = son ;

son = LPF.ar(son+ WhiteNoise.ar(1*noise), env1m*fratio, env0);

	son = son + SelectX.ar(owhich2,[ SinOsc.ar(env1m, [p1,p2], env0), LFSaw.ar(env1m, [p1,p2], env0);, LFPulse.ar(env1m, [p1,p2], env0), LFTri.ar(env1m, [p1,p2], env0)]);
	son = LPF.ar(son,filter+SinOsc.kr(2,0.5,200));
son = son * 1;
//son = son.clip2(1);
son = son * level.distort;
son = Pan2.ar(son, pan);
OffsetOut.ar(out, son*level).tanh;
//OffsetOut.ar(32, son*level).tanh;
}).add;

SynthDef(\bigkick, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	env1 = EnvGen.ar(Env([1101,60,55],[0.001,0.1]), 1);
	sig = LFSaw.ar(freq);
	sig = RLPF.ar(sig, env1, \rq.kr(0.01));
	sig = sig / 2;
	sig = sig * EnvGen.ar(Env.adsr(0.001,0.1,0.8,0.1),gate,doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

// acid kick
// very small rq variation
// add a compander to shape overblowing
SynthDef(\bigkick1, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	env1 = EnvGen.ar(Env([0801,109,60],[0.01,0.1]), 1);
	sig = LFSaw.ar(freq);
	sig = RLPF.ar(sig, env1, \rq.kr(0.0001));
	sig = RLPF.ar(sig, env1, \rq.kr);
	sig = RLPF.ar(sig, env1, \rq.kr);
	sig = sig / 4;
	sig = Compander.ar(sig, sig, \cpt.kr(0.5), \cpbelow.kr(1.001), \cpabove.kr(0.2), \cpclamp.kr(0.01), \cprelax.kr(0.1));
	sig = sig / 4;
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,0.1),gate,doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\basicKick, {arg out = 0, amp = 0.3, sinfreq = 60, glissf = 0.9, att = 0.01, rel = 0.45, pan = 0;
	var env, snd, ramp;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	ramp = XLine.kr(
		start: sinfreq,
		end: sinfreq * glissf,
		dur: rel
	);
	snd = SinOsc.ar(freq: ramp, mul: env);
	snd = Pan2.ar(snd, pan);
	OffsetOut.ar(out, snd);

//By Nathan Ho aka Snappizz
//http://sccode.org/1-523
}).add;

SynthDef(\kick1b, {
    var snd;
    snd = DC.ar(0);
    snd = snd + (SinOsc.ar(XLine.ar(800, 400, 0.01)) * Env.perc(0.0005, 0.01).ar);
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), XLine.ar(800, 100, 0.01), 0.6) * Env.perc(0.001, 0.02).delay(0.001).ar);
    snd = snd + (SinOsc.ar(XLine.ar(172, 50, 0.01)) * Env.perc(0.0001, 0.3, 1, \lin).delay(0.005).ar(2));
    snd = snd.tanh;
    OffsetOut.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
//By Nathan Ho aka Snappizz
//http://sccode.org/1-57g
}).add;

SynthDef(\kick2b, {
    var snd;
    snd = DC.ar(0);
    snd = snd + (HPF.ar(Hasher.ar(Sweep.ar), 1320) * Env.perc(0.003, 0.03).ar * 0.5);
    snd = snd + (SinOsc.ar(XLine.ar(750, 161, 0.02)) * Env.perc(0.0005, 0.02).ar);
    snd = snd + (SinOsc.ar(XLine.ar(167, 52, 0.04)) * Env.perc(0.0005, 0.3).ar(2));
    snd = snd.tanh;
    OffsetOut.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
//By Nathan Ho aka Snappizz
//http://sccode.org/1-57g
}).add;

SynthDef(\kick3b, {
    var snd;
    snd = DC.ar(0);
    snd = snd + (SinOsc.ar(XLine.ar(1500, 800, 0.01)) * Env.perc(0.0005, 0.01, curve: \lin).ar);
    snd = snd + (BPF.ar(Impulse.ar(0) * SampleRate.ir / 48000, 6100, 1.0) * 3.dbamp);
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), 300, 0.9) * Env.perc(0.001, 0.02).ar);
    snd = snd + (SinOsc.ar(XLine.ar(472, 60, 0.045)) * Env.perc(0.0001, 0.3, curve: \lin).delay(0.005).ar(2));
    snd = snd.tanh;
    OffsetOut.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
//By Nathan Ho aka Snappizz
//http://sccode.org/1-57g
}).add;

SynthDef(\kick_808b, {arg out = 0, freq1 = 240, freq2 = 60, amp = 1, ringTime = 10, rel = 1, dist = 0.5, pan = 0;
    var snd, env;
	snd = Ringz.ar(
		in: Impulse.ar(0), // single impulse
		freq: XLine.ar(freq1, freq2, 0.1),
		decaytime: ringTime);
	env = EnvGen.ar(Env.perc(0.001, rel, amp), doneAction: 2);
	snd = (1.0 - dist) * snd + (dist * (snd.distort));
	snd = snd * env;
	OffsetOut.ar(0, Pan2.ar(snd, pan));
//
//By Bruno Ruviaro
//https://github.com/brunoruviaro/SynthDefs-for-Patterns/blob/master/kick808.scd
}).add;

SynthDef(\SOSkick,
	{ arg out = 0, freq = 50, mod_freq = 5, mod_index = 5, sustain = 0.4, amp = 0.8, beater_noise_level = 0.025;
		var pitch_contour, drum_osc, drum_lpf, drum_env;
		var beater_source, beater_hpf, beater_lpf, lpf_cutoff_contour, beater_env;
		var kick_mix;
		pitch_contour = Line.kr(freq*2, freq, 0.02);
		drum_osc = PMOsc.ar(	pitch_contour,
			mod_freq,
			mod_index/1.3,
			mul: 1,
			add: 0);
		drum_lpf = LPF.ar(in: drum_osc, freq: 1000, mul: 1, add: 0);
		drum_env = drum_lpf * EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
		beater_source = WhiteNoise.ar(beater_noise_level);
		beater_hpf = HPF.ar(in: beater_source, freq: 500, mul: 1, add: 0);
		lpf_cutoff_contour = Line.kr(6000, 500, 0.03);
		beater_lpf = LPF.ar(in: beater_hpf, freq: lpf_cutoff_contour, mul: 1, add: 0);
		beater_env = beater_lpf * EnvGen.ar(Env.perc, 1.0, doneAction: 2);
		kick_mix = Mix.new([drum_env, beater_env]) * 2 * amp;
		OffsetOut.ar(out, [kick_mix, kick_mix])
	}

	//DrumSynths SC Example - SOS Drums by Renick Bell, renick_at_gmail.com
	// recipes from Gordon Reid in his Sound on Sound articles
	// SOSkick -------
	// http://www.soundonsound.com/sos/jan02/articles/synthsecrets0102.asp
	// increase mod_freq and mod_index for interesting electronic percussion
).add;

SynthDef(\kick_electro, {
    |out = 0, pan = 0, amp = 0.3|
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

    OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
//By Nathan Ho aka Snappizz
//http://sccode.org/1-523
}).add;

SynthDef(\drum_kick, {
	arg out = 0, freq=440, gate=1, amp=0.5, source,pan = 0.0 ;
	source =
	Pan2.ar(
		SinOsc.ar(EnvGen.kr(Env.perc(0.0001, 1.5, 1, -200), gate, 1000, 45, doneAction:2), 1, 1) +
		((BPF.ar([GrayNoise.ar(6),GrayNoise.ar(6)],EnvGen.kr(Env.perc(0.001, 0.3, 1, -200), gate, 6000, 70), 1.5)).distort * Line.kr(0.3,0,0.1))
		*
		EnvGen.kr(Env.perc(0.0001, 0.09, amp, 8)),0);
	OffsetOut.ar(out, source);
}).add;

SynthDef(\kickAw, {arg out = 0, amp = 0.3, sinfreq = 70, glissf = 0.9, att = 0.01, rel = 0.45, pan = 0;
	var gliss = XLine.kr(sinfreq, sinfreq*glissf, rel);
	var snd = SinOsc.ar(gliss);
	var env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
	snd = snd * env * amp;
	snd = Limiter.ar(snd,1,0.001);
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\kick3Aw, {arg punch = 1, amp = 1;
    var freq = EnvGen.kr(Env([400, 66], [0.08], -3)),
	sig = Normalizer.ar(SinOsc.ar(freq, 0.5pi, punch).distort, 1) * amp
            * EnvGen.kr(Env([0, 1, 0.8, 0], [0.01, 0.1, 0.2]), doneAction: 2);
    OffsetOut.ar(0, sig ! 2);
}).add;

SynthDef(\kick808Aw, { arg out = 0, freq1 = 240, freq2 = 60, amp = 12, ringTime = 100, rel = 10000, dist = 1.5, pan = 0, tott, durr;
    var snd, env;
	snd = Ringz.ar(
		in: Impulse.ar(0), // single impulse
		freq: XLine.ar(freq1, freq2, 0.1),
		decaytime: ringTime);
	env = EnvGen.ar(Env.perc(0.001, rel, amp), doneAction: 2);
	snd = (1.0 - dist) * snd + (dist * (snd.distort));
	snd = snd * env;
	snd = Limiter.ar(snd, tott, durr) * 0.5 *(1/tott);
	//snd = Clip.ar(snd, -1 * tott, tott);
	//	snd = Fold.ar(snd, -1 * tott, tott);
	//	snd = Wrap.ar(snd, -1 * tott, tott);
	OffsetOut.ar(0, Pan2.ar(snd, pan));
}).add;

SynthDef(\kick_oto309, { arg out=0, amp=0.5, pan=0;
	var env0, env1, env1m, son;

	env0 =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), doneAction:2);
	env1 = EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]));
	env1m = env1.midicps;

	son = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
	son = son + WhiteNoise.ar(1);
	son = LPF.ar(son, env1m*1.5, env0);
	son = son + SinOsc.ar(env1m, 0.5, env0);

	son = son * 1.2;
	son = son.clip2(1);

	OffsetOut.ar(out, Pan2.ar(son * amp));
}).add;

SynthDef(\kikAw, { |basefreq = 50, ratio = 7, sweeptime = 0.05, preamp = 1, amp = 1, decay1 = 0.3, decay1L = 0.8, decay2 = 0.15, out|
    var fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
        env = EnvGen.kr(Env([1, decay1L, 0], [decay1, decay2], -4), doneAction: 2),
        sig = SinOsc.ar(fcurve, 0.5pi, preamp).distort * env * amp;
    OffsetOut.ar(out, sig ! 2)
}).add;

SynthDef(\kicklaserbeam, {
	arg out = 0, pan = 0.0, freq = 440, amp = 0.1, att = 0.01;
	var snd, freqenv, ampenv;
	// frequency envelope
	freqenv = EnvGen.ar(Env([4, 0.5, 1, 1], [att, 0.01, 1.0]));
	// amplitude envelope
	// no gate: fixed-time envelope, self-terminating.
	ampenv = EnvGen.ar(
		envelope: Env([0, 1, 0.5, 0.0], [0.02, 0.2, 0.1]),
		levelScale: amp,
		doneAction: 2);
	snd = LFTri.ar(freq: freq * freqenv, mul: ampenv);
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\ringkick, { arg out = 0, freq = 40, decay = 0.25, amp = 1;
	var snd;
	snd = Ringz.ar(
		in: LPF.ar(
			in: Impulse.ar(0),
			freq: 1000
		),
		freq: freq,
		decaytime: decay,
		mul: 7 * amp
	).tanh.sin*2;
	OffsetOut.ar(out, snd!2);
}).add;

SynthDef(\tweetBassLeak, { arg out = 0, t_trig = 1, amp = 1, attack = 0.01, release = 1, doneAction = 2;
	var sig, demand, env;
	demand = Demand.kr(
		t_trig,
		0,
		Drand([0, Drand((0.4, 0.5..1))],inf)
	);
	env = Decay2.kr(
		demand,
		0.01,
		0.3
	);
	sig = Saw.ar(8, env) ** 1.5;
	sig = BRF.ar(sig, demand * 20 + [45.1, 45], 0.1);
	sig = sig * EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = LeakDC.ar(sig).tanh;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\tweetKickInt, { arg out = 0, t_trig = 1, attack = 0.01, release = 2, amp = 1, doneAction = 2;
	var sig, freq, phase, env, i;
	i = Impulse.ar(_);
	freq = i.(2).lagud(0,0.4)*360;
	phase = Integrator.ar(
		Integrator.ar(
			i.(64).lag(LFNoise1.ar(2!2,2,2))*99,
			0.9
		),
		0.99
	).fold2(pi);
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = SinOsc.ar(freq, phase, env);
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef (\kickParallax) {
	arg len = 0.3, pan = 0, amp = 1, freq = 55;
	var sig, env_amp, env_freq;

	env_amp  = Env.perc (0.01, len - 0.01, amp);
	env_amp  = EnvGen.kr (env_amp, doneAction: 2);

	env_freq = Env.perc (0, 0.02, 1);
	env_freq = EnvGen.ar (env_freq);

	sig = SinOsc.ar (freq + (44100 ** env_freq), 0, env_amp);
	sig = Pan2.ar (sig, pan);

	Out.ar (0, sig);
}.add;

SynthDef(\tabass, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 2, rangeMin = 0.4, rangeMax = 0.45, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = LFTri.ar(1);
	20.do{
		sig = BAllPass.ar(sig,80,1);
		sig = ((sig+0.02)*LFNoise0.kr(1/2).range(rangeMin, rangeMax)*8).tanh;
		sig = LeakDC.ar(sig,0.995);
	};
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\mcld, { arg out = 0, amp = 1, att = 0.01, rel = 2, impFreq = 10, hpfFreq = 440, gate = 1, doneAction = 2;
	var sig, env, input;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	input = LocalIn.ar.clip2(LFPulse.kr([1,2,1/8]).sum/2)**100*100;
	sig = DynKlank.ar(
		`[input],
		Impulse.ar(impFreq)
	);
	LocalOut.ar(sig);
	sig = HPF.ar(sig, hpfFreq).clip2;
	sig = Splay.ar(sig * env, amp);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\batuhan, { arg out = 0, amp = 1, att = 0.01, rel = 5, tridDur = 0.125, decayTime = 0.3, sawFreq = 8, brfFreq1 = 45.1, brfFreq2 = 45, gate = 1, doneAction = 2;
	var sig, env, core;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	core = Duty.kr(tridDur, 0, Drand([0, Drand((0.4,0.5..1))], inf));
	sig = Decay2.kr(
		core,
		0.01,
		decayTime
	);
	sig = Saw.ar(sawFreq, sig) ** 1.5;
	sig = BRF.ar(sig, core * 20 + [brfFreq1, brfFreq2], 0.1);
	sig = LeakDC.ar(sig).tanh;
	OffsetOut.ar(out, sig * env * amp);
}).add;

SynthDef(\kicky,{
	arg out = 0, startFreq=80, endFreq=15, decay=4, lowpass=800, amp=1, noiseAmp=0.0, gain=1, dur=6;
	var sig, env, freq;
	freq = Line.kr(PinkNoise.kr(6,startFreq), PinkNoise.kr(3,endFreq), dur, 1, 0);
	env = EnvGen.kr(Env.perc(0.014, dur, 1, -5), 1, doneAction:2);
	sig = {(LPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass) * amp) ! 2};
	sig = LPF.ar(sig,BrownNoise.kr(500,1500))*0.3;
	sig = sig * gain;
	sig = sig.softclip * amp * env;
	OffsetOut.ar(out, [sig,sig]);
}).add;

SynthDef(\kickey,{
	arg out = 0, startFreq=60, endFreq=20, decay=4, lowpass=1000, amp=1, noiseAmp=0.01, gain=1, dur=0.8;
	var sig, env, freq;
	freq = XLine.kr(startFreq, endFreq, dur, 1, 0);
	env = EnvGen.kr(Env.perc(0.0014, dur, 1, -5), 1, doneAction:2);
	sig = {(LPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass) * amp) ! 2};
	sig = sig + LPF.ar((noiseAmp*BrownNoise.ar(1)),lowpass);
	sig = sig * gain;
	sig = sig.softclip * amp * env;
	OffsetOut.ar(out, [sig,sig]);
}).add;

)