(

///////////////////////////////////////  Snare

SynthDef(\sd, { | out = 0, amp = 1 |
	var osc1, osc2, env;
	osc1 = WhiteNoise.ar;
	osc2 = FSinOsc.ar(200);
	env = EnvGen.kr(Env.perc(0, 0.05), doneAction: 2);
	OffsetOut.ar(out, Pan2.ar(LPF.ar(Mix([osc1, osc2]), 12000), 0, env*amp));
}).add;

SynthDef(\snare, { arg out=0,tu=1, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var env = EnvGen.ar(Env.perc(0.01,0.1));
	var enf = EnvGen.ar(Env([600,1057,230],[0.01,0.01],-4));
	sig = SinOsc.ar(tu*enf+127,0,0.5)*env;
	sig = WhiteNoise.ar+sig;
	sig = RHPF.ar(sig, \hpf.kr(170)*tu, \rq.kr(0.5));
	sig = sig + Mix.ar(BPF.ar(sig,[327,430],[0.5,0.5])*0.1);
	sig = RLPF.ar(sig, \lpf.kr(15100)*tu, \rq.kr(0.5));
	sig = sig * EnvGen.ar(Env.perc(0.01,\rel.kr(0.1),-4),gate,doneAction:2);
	OffsetOut.ar(out, sig*amp);
}).add;

SynthDef(\snarenew, { arg out=0,tu=1, amp=0.1, gate=1, pan=0, freq=200;
    var sig;
    var env = EnvGen.ar(Env.perc(0,0.8));
    var enf = EnvGen.ar(Env([16000,57,15000,11188.8],[0.001,0.001,0.0001],-4));
    sig = SinOsc.ar(tu*enf,0,0.5)*env;
    sig = (PinkNoise.ar*env)+sig;
    sig = RHPF.ar(sig, \hpf.kr(80)*tu, \rq.kr(0.8));
    sig = sig + Mix.ar(BPF.ar(sig,[527,530],[0.5,0.5])*0.1);
    sig = RHPF.ar(sig, \lpf.kr(100), \rq.kr(0.8));
    sig = sig * EnvGen.ar(Env.perc(0,\rel.kr(1),4,-8),gate,doneAction:2);
    //sig = DelayL.ar(sig,0.05,0.001)+sig;
    //sig = DelayL.ar(sig,0.05,0.01)+sig;
    //sig = DelayL.ar(sig,0.1,0.1)+sig;
    OffsetOut.ar(out, sig*amp);
}).add;

SynthDef(\snare2,{arg gate = 1, amp=1, out=0;
	var env = EnvGen.ar(Env.perc(0.001,0.2),gate,doneAction:2);
	var freq = EnvGen.ar(Env([12000,100,12000],[0.01,0.01]));
	var sig = WhiteNoise.ar(env);
	sig = LPF.ar(sig,freq);
	sig = sig.tanh;
	OffsetOut.ar(out,sig );
}).add;

SynthDef(\snare2new, { arg out=0,tu=1, amp=0.1, gate=1, pan=0, freq=200;
    var sig;
    var env = EnvGen.ar(Env.perc(0.1,0.1));
    var enf = EnvGen.ar(Env([1600,177,190],[0.01,0.1],-4));
    var sig2 = BrownNoise.ar(1);
    sig = SinOsc.ar(tu*enf+27,0,0.1)*env;
    sig = WhiteNoise.ar(0.6)+sig+(LPF.ar(sig2,250,0.5)*env);
//    sig = RHPF.ar(sig, \hpf.kr(100)*tu, \rq.kr(1));
//    sig = sig + Mix.ar(BPF.ar(sig,[1207,4300],[0.5,0.5])*0.1);
    //sig = RLPF.ar(sig, \lpf.kr(11000)*tu, \rq.kr(1));
    //sig = CombL.ar(sig,0.2,0.1);
    sig = BRF.ar(sig,450,0.3);
    sig = HPF.ar(sig,250);
    sig = sig * EnvGen.ar(Env.perc(0.02,\rel.kr(0.4),-4),gate,doneAction:2);
    //sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig*amp);
}).add;

SynthDef(\jungleSnare, { arg out=0,tu=1, amp=0.1, gate=1, pan=0, freq=200,kracter = 10;
	var sig;
	var env = EnvGen.ar(Env([1,0,1,0],[0,0.004,0.05]),gate,doneAction:2);
	var enf = EnvGen.ar(Env([1600,5600,800,250],[0.001,0.001,0.001],-4));
	var enf2 = EnvGen.ar(Env([1000,1600,700,200],[0.001,0.001,0.06,0.01],-4));
	sig = SinOsc.ar(tu*enf+107,0,0.5)*env;
	sig =  WhiteNoise.ar(env)+sig;
	sig = RHPF.ar(sig, \hpf.kr(100)*tu, \rq2.kr(1))+sig;
	sig = sig + Mix.ar(BPF.ar(sig,[327,430],[0.5,0.5])*0.1)+WhiteNoise.ar(env)+BrownNoise.ar(env/8);
	sig = RLPF.ar(sig, \lpf.kr(11100)*tu, \rq.kr(0.5))+sig;
	sig =( Ringz.ar(WhiteNoise.ar,Mix.ar([enf2,enf*0.9,enf2*0.8]),1,0.01*env) +RLPF.ar(BrownNoise.ar(env),enf*4,1,1)+sig )*env ;
	sig = HPF.ar(sig,350);
	sig = CompanderD.ar(sig*kracter,0.8,0.3,0.5,0.001,0.2,env);
	OffsetOut.ar(out, sig*amp);
}).add;

SynthDef(\t5snare, { arg out=0,tu=1, amp=0.3, gate=1, pan=0, freq=200,snd;
	var sig;
	var env = EnvGen.ar(Env.perc(0.01,1));
	var enf = EnvGen.ar(Env([600,177,230],[0.01,0.1],-4));
	//sig = SinOsc.ar(tu*enf+1207,0,0.5)*env;
	sig = WhiteNoise.ar;
	sig = FreeVerb.ar(sig,0.5,1);
	sig = RHPF.ar(sig, \hpf.kr(180)*tu, \rq.kr(0.5));
	sig = sig + Mix.ar(BPF.ar(sig,[127,430],[0.5,0.5])*0.1);
	sig = RLPF.ar(sig, \lpf.kr(12100)*tu, \rq.kr(0.5));
	sig = sig * EnvGen.ar(Env.perc(0,\rel.kr(1),-4),gate,doneAction:2);
	sig = sig*amp;
	sig = CompanderD.ar(sig,1,1,0.1,0.01,0.4);
	sig = FreeVerb.ar(sig,1,1)+sig;
	OffsetOut.ar(out, sig*amp);
	//Out.ar(snd, sig);
}).add;

SynthDef(\snare808, { arg out=0,tu=1, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var env = EnvGen.ar(Env.perc(0.01,1));
	var enf = EnvGen.ar(Env([600,177,230],[0.01,0.01],-4));
	sig = SinOsc.ar(tu*enf+127,0,0.5)*env;
	sig = WhiteNoise.ar+sig;
	sig = RHPF.ar(sig, \hpf.kr(170)*tu, \rq.kr(0.5));
	sig = sig + Mix.ar(BPF.ar(sig,[127,430],[0.5,0.5])*0.1);
	sig = RLPF.ar(sig, \lpf.kr(11100)*tu, \rq.kr(0.5));
	sig = sig * EnvGen.ar(Env.perc(0.01,\rel.kr(0.1),-4),gate,doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\snaremed, { | out = 0,level=1, pan=0, atk= 0.01,decay = 0.2,release=0.26, fratio=1.5,noise=1,done=2,freq1= 120,freq2=30,freq3=30,dc=1,aamp1=1,aamp2=1,aamp3=1,aamp4=1,curve1= (-4),curve2=(-2),curve3=(-4),famp1,famp2,famp3,famp4,p1,oamp=0.1,owhich2=0,ochoose=0,snd =20|
	var env0,env1,
env1m, son, son2,son3,son4,p2;
	p2 = p1 * (-pi);
env0 = Env([aamp1,aamp2,aamp3,aamp4,0],[atk,decay,release],[curve1, curve2, curve3]);
env1 = Env([freq1,freq2,freq3],[famp1,famp2,famp3,famp4],[curve1, curve2, curve3]);

env0 = EnvGen.ar(env0, doneAction:2);
env1 = EnvGen.ar(env1);
	env1m = env1.midicps;
son = LFSaw.ar(env1m,0,oamp, 1,1.4);//*LFSaw.ar(100).distort;
son2 = SinOsc.ar(env1m,0, oamp, 1,1.4);
son3 = LFPulse.ar(env1m,0, oamp, 1,1.4);
son4 = LFTri.ar(env1m,0, oamp, 1,1.4);

son = SelectX.ar(ochoose,[son,son2,son3,son4]);
son = LeakDC.ar(son,dc,30);
son = son ;
son = HPF.ar(son, 100, env0);
	son = son + SelectX.ar(owhich2,[ SinOsc.ar(env1m, p1, env0), LFSaw.ar(env1m, p1, env0), LFPulse.ar(env1m, p1, env0), LFTri.ar(env1m, p1, env0)]);
	son =  HPF.ar(son +BrownNoise.ar(env0/2*noise)+WhiteNoise.ar(env0*noise),fratio);
//son = son.clip2(1);

	son = Limiter.ar(son,1);
	son = son * level.distort;

OffsetOut.ar(out, son*level).tanh;
//OffsetOut.ar(snd, son*level).tanh;
},
).add;

SynthDef(\snarehi, {| out = 0,level=1, pan=0, atk= 0.01,decay = 0.2,release=0.26, fratio=1.5,noise=1,done=2,freq1= 120,freq2=30,freq3=30,dc=1,aamp1=1,aamp2=1,aamp3=1,aamp4=1,curve1= (-4),curve2=(-2),curve3=(-4),famp1,famp2,famp3,famp4,p1,oamp=0.1,owhich2=0,ochoose=0|
	var env0, env1,son,son1, son2,son3,son4;
	var p2  = p1 * (-pi);

env0 = Env([aamp1,aamp2,aamp3,aamp4,0],[atk,decay,release],[curve1, curve2, curve3]);
env1 = Env([freq1,freq2,freq3],[famp1,famp2,famp3,famp4],[curve1, curve2, curve3]);

	env0 = EnvGen.ar(env0,doneAction:2);
	env1 = EnvGen.ar(env1).midicps;
	//son = WhiteNoise.ar(env0*noise)+HPF.ar(BrownNoise.ar(env0*noise),1000);
	son = SelectX.ar(owhich2,[WhiteNoise.ar(env0*noise),PinkNoise.ar(env0*noise),BrownNoise.ar(env0*noise)]);
son1 = LFSaw.ar(env1,0,oamp );//*LFSaw.ar(100).distort;
son2 = SinOsc.ar(env1,0, oamp);
son3 = LFPulse.ar(env1,0, oamp);
son4 = LFTri.ar(env1,0, oamp);

//son1 = SelectX.ar(ochoose,[son1,son2,son3,son4]);
	son = son + son* SinOsc.ar(env1,[p1,p2])+SinOsc.ar(env1,[p2,p1],oamp)+SinOsc.ar(env1+20,[p1+0.5,p2],oamp);
	    // son = CombN.ar(son,0.02,fratio,2,1);

	son = Pan2.ar(son);
	//	son = LeakDC.ar(son,dc,30);
	/*son= Compander.ar(son, son,
		thresh: 0.6,
		slopeBelow: 0,
		slopeAbove: 0.4,
		clampTime: 0.1,
		relaxTime: 0.001
	);*/
	OffsetOut.ar(out,son*env0*level);
	//Out.ar(14,son*env0*level);

	}
).add;

//Rudy
SynthDef(\snarer, { arg out=0,tu=1, amp=0.1, t_gate=1, pan=0, freq=200;
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
	sig[1] = sig[1]* EnvGen.ar(Env.perc(0.01,0.01,-4),t_gate,doneAction:0);
	sig = sig.mean;

	sig = sig * EnvGen.ar(Env.perc(0.01,\rel.kr(0.1)*2,-4),t_gate,doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;

SynthDef(\snare808r, { arg out=0,tu=1, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var env = EnvGen.ar(Env.perc(0.01,1));
	var enf = EnvGen.ar(Env([600,177,230],[0.01,0.01],-4));
	sig = SinOsc.ar(tu*enf+127,0,0.5)*env;
	sig = WhiteNoise.ar+sig;
	sig = RHPF.ar(sig, \hpf.kr(170)*tu, \rq.kr(0.5));
	sig = sig + Mix.ar(BPF.ar(sig,[127,430],[0.5,0.5])*0.1);
	sig = RLPF.ar(sig, \lpf.kr(11100)*tu, \rq.kr(0.5));
	sig = sig * EnvGen.ar(Env.perc(0.01,\rel.kr(0.1),-4),gate,doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;

SynthDef(\snapsnare, { |out = 0, pan = 0, amp = 0.3|
    var pop, popAmp, popFreq;
    var noise, noiseAmp;
    var snd;

    // pop makes a click coming from very high frequencies
    // slowing down a little and stopping in mid-to-low
    popFreq = EnvGen.ar(Env([3261, 410, 160], [0.005, 0.01], curve: \exp));
    popAmp = EnvGen.ar(Env.perc(0.001, 0.11)) * 0.7;
    pop = SinOsc.ar(popFreq) * popAmp;
    // bandpass-filtered white noise
    noiseAmp = EnvGen.ar(Env.perc(0.001, \rel.kr(0.15)), doneAction: 2);
    noise = BPF.ar(WhiteNoise.ar, 810, 1.6) * noiseAmp;

    snd = (pop + noise) * 1.3;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;


SynthDef(\zsnare, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
	var click=0, osc=0, snare=0;
	click = WhiteNoise.ar;
	click = click * EnvGen.kr(Env([0,1,0],[0.001,0.004]), 1) * 1;

	osc = SinOsc.ar( EnvGen.kr(Env([400,150,151],[0.01,0.08]), 1) );
	osc = osc * EnvGen.kr(Env([0,1,0],[0.001,0.20], -4), 1);
	osc = osc * 2;
	osc = HPF.ar(osc, 180);

	snare = WhiteNoise.ar;
	snare = LPF.ar(snare, EnvGen.ar(Env([14700,4852,3451],[0.01,0.1]), 1));
	snare = HPF.ar(snare, EnvGen.ar(Env([9700,4452,3451],[0.01,0.1]), 1));
	snare = snare * EnvGen.kr(Env([0,1,0],[0.001,0.18], -2), 1);

	sig = click + osc + snare;

	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,0.4),gate,doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;

SynthDef(\neurosnare, {
    var snd;
    // a percussive click to give it some attack
    snd = LPF.ar(HPF.ar(WhiteNoise.ar, 300), 8000) * Env.linen(0.001, 0.01, 0.001).ar;
    // sine sweep body. very important!
    snd = snd + (SinOsc.ar(Env([400, 196, 160], [0.04, 0.2], \exp).ar) * Env.perc(0.04, 0.2).ar * 6.dbamp).tanh;
    // sound of snare coils rattling
    snd = snd + (HPF.ar(BPeakEQ.ar(WhiteNoise.ar, 4000, 0.5, 3), 300) * Env.perc(0.05, 0.2).delay(0.01).ar(2) * -3.dbamp);
    // another sound sweep to improve the attack, optional
    snd = snd + (SinOsc.ar(XLine.kr(3000, 1500, 0.01)) * Env.perc(0.001, 0.02).ar);
    // distortion helps glue everything together and acts as a compressor
    snd = (snd * 1.4).tanh;
    snd = Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1));
    Out.ar(\out.kr(0), snd);
}).add;

SynthDef(\snaretuned, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
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

	// tonal component
	sig2 = SinOsc.ar([180, 330]*1.2).sum;
	sig3 = LFTri.ar(111);
	sig3 = FreqShift.ar(sig3, [175, 224]*1.3).sum;
	sig4 = sig2 + sig3 / 48;

	sig = sig + sig4 / 1.2;
	sig = HPF.ar(sig, env2);


	sig = sig * EnvGen.kr(\adsr.kr(Env.adsr(0.001,0.1,0.8,0.4,1,-6)), gate, doneAction:2);
	sig = Pan2.ar(sig, pan, amp).sum;
	Out.ar(out, sig);
}).add;

// nord modular 909 implementation
SynthDef(\snare909, { arg out=0, amp=0.1, t_gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3;
	var lfo1, lfo2;

	lfo1 = LFTri.ar(330 * EnvGen.ar(Env([8,1 + Rand(0.0,0.4),1],[0.00001,1.8]), t_gate) * [1,1.1,1.2]).sum;
	lfo1 = lfo1 * EnvGen.ar(Env.perc(0.0005, 0.0255), t_gate);
	lfo2 = LFTri.ar(185);
	lfo2 = lfo2 * EnvGen.ar(Env.perc(0.0001, 0.0475), t_gate);

	sig = WhiteNoise.ar(WhiteNoise.ar);
	sig = BRF.ar(sig, [100,200,300,400]+42*0.8).mean;
	sig = LPF.ar(sig, 7040 * [1,1.1,0.2] * EnvGen.kr(Env([1,[0.5+Rand(0.0,0.2),0.1+Rand(0.0,0.2)]],[0.01]), t_gate)) * [0.4,0.7,1];

	sig1 = sig * EnvGen.ar(Env.perc(0.005, 0.320+Rand(0.0,0.1)), t_gate, doneAction:2);

	sig2 = HPF.ar(sig, 523);
	sig2 = BRF.ar(sig2, [100,200,300,400]+12*2.0).mean;
	sig2 = sig2 * EnvGen.ar(Env.perc(0.005, 0.183), t_gate);
	sig2 = (sig2*\dist.kr(30)).tanh;

	sig = ( sig1 * 0.7 ) + ( sig2 * 0.4 ) + lfo1 + lfo2;
	sig = sig * 1/2;
	sig = Pan2.ar(sig, pan, amp).flop;
	Out.ar(out, sig);
}).add;

SynthDef(\snare909d,{ |out=0,mul=1,velocity=1|
	var excitation, membrane;

	excitation = LPF.ar(WhiteNoise.ar(1), 7040, 1) * (0.1 + velocity);
	membrane = (
		/* Two simple enveloped oscillators represent the loudest resonances of the drum membranes */
		(LFTri.ar(330,0,1) * EnvGen.ar(Env.perc(0.0005,0.055),doneAction:0) * 0.25)
		+(LFTri.ar(185,0,1) * EnvGen.ar(Env.perc(0.0005,0.075),doneAction:0) * 0.25)

		/* Filtered white noise represents the snare */
		+(excitation * EnvGen.ar(Env.perc(0.0005,0.4),doneAction:2) * 0.2)
		+(HPF.ar(excitation, 523, 1) * EnvGen.ar(Env.perc(0.0005,0.283),doneAction:0) * 0.2)

	) * mul;
	Out.ar(out, membrane!2)
}).add;

SynthDef(\basicSnare, {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
	var env, snd1, snd2, sum;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd1 = HPF.ar(
		in: WhiteNoise.ar,
		freq: ffreq,
		mul: env
	);
	snd2 = SinOsc.ar(freq: sinfreq, mul: env);
	sum = snd1 + snd2;
	Out.ar(out, Pan2.ar(sum, pan));

//By Nathan Ho aka Snappizz
//http://sccode.org/1-523
}).add;

SynthDef(\SOSsnare,
	{arg out = 0, sustain = 0.1, drum_mode_level = 0.25,
	snare_level = 40, snare_tightness = 1000,
	freq = 405, amp = 0.8;
	var drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix, drum_mode_env;
	var snare_noise, snare_brf_1, snare_brf_2, snare_brf_3, snare_brf_4, snare_reson;
	var snare_env;
	var snare_drum_mix;

	drum_mode_env = EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
	drum_mode_sin_1 = SinOsc.ar(freq*0.53, 0, drum_mode_env * 0.5);
	drum_mode_sin_2 = SinOsc.ar(freq, 0, drum_mode_env * 0.5);
	drum_mode_pmosc = PMOsc.ar(	Saw.ar(freq*0.85),
					184,
					0.5/1.3,
					mul: drum_mode_env*5,
					add: 0);
	drum_mode_mix = Mix.new([drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc]) * drum_mode_level;

// choose either noise source below
//	snare_noise = Crackle.ar(2.01, 1);
	snare_noise = LFNoise0.ar(20000, 0.1);
	snare_env = EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
	snare_brf_1 = BRF.ar(in: snare_noise, freq: 8000, mul: 0.5, rq: 0.1);
	snare_brf_2 = BRF.ar(in: snare_brf_1, freq: 5000, mul: 0.5, rq: 0.1);
	snare_brf_3 = BRF.ar(in: snare_brf_2, freq: 3600, mul: 0.5, rq: 0.1);
	snare_brf_4 = BRF.ar(in: snare_brf_3, freq: 2000, mul: snare_env, rq: 0.0001);
	snare_reson = Resonz.ar(snare_brf_4, snare_tightness, mul: snare_level) ;
	snare_drum_mix = Mix.new([drum_mode_mix, snare_reson]) * 5 * amp;
	Out.ar(out, [snare_drum_mix, snare_drum_mix])
	}
).add;
//DrumSynths SC Example - SOS Drums by Renick Bell, renick_at_gmail.com
// recipes from Gordon Reid in his Sound on Sound articles
// SOSsnare -------
// http://www.soundonsound.com/sos/Mar02/articles/synthsecrets0302.asp

SynthDef(\snare_electro, {
    |out = 0, pan = 0, amp = 0.3|
    var pop, popAmp, popFreq;
    var noise, noiseAmp;
    var snd;

    // pop makes a click coming from very high frequencies
    // slowing down a little and stopping in mid-to-low
    popFreq = EnvGen.ar(Env([3261, 410, 160], [0.005, 0.01], curve: \exp));
    popAmp = EnvGen.ar(Env.perc(0.001, 0.11)) * 0.7;
    pop = SinOsc.ar(popFreq) * popAmp;
    // bandpass-filtered white noise
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.15), doneAction: 2);
    noise = BPF.ar(WhiteNoise.ar, 810, 1.6) * noiseAmp;

    snd = (pop + noise) * 1.3;

    Out.ar(out, Pan2.ar(snd, pan, amp));
//By Nathan Ho aka Snappizz
//http://sccode.org/1-523
}).add;

SynthDef(\snareAw, {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
	var snd1 = WhiteNoise.ar(amp);
	var snd2 = SinOsc.ar(sinfreq,0,amp);
	var env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
	var sum = HPF.ar(snd1 * env, ffreq)+(snd2*env);
	Out.ar(out, Pan2.ar(sum, pan));
}).add;

SynthDef(\snarey,{
	arg out = 0, amp=0.75, freq=120, gain=0.5, dur=0.3;
	var env, sig, snare;
	env = EnvGen.kr(Env.perc(0.001, dur, 1, -9), 1, doneAction:2);
	sig = {(SinOsc.ar(freq) - WhiteNoise.ar(0.5, 0.5))!2};
	sig = sig * gain;
	sig = sig.softclip * amp * env;
	OffsetOut.ar(out, [sig,sig]);
}).add;

)