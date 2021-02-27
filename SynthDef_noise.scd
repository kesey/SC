(

///////////////////////////////////////  Noise

SynthDef(\IkedaBreath, { arg out = 0, t_trig = 0, note1 = 44, note2 = 90, amp1 = 0.5, amp2 = 0.6, lpfFreq = 103.82, hpfFreq = 2400, attack = 0.0001, decay = 0.4, release = 0.01, pan = 0, level = 1;
	var sin, lpf, hpf, sig;
	sin = SinOsc.ar(note1.midicps, 0, amp1) + SinOsc.ar(note2.midicps, 0, amp2);
	lpf = LPF.ar(sin, lpfFreq.max(1));
	hpf = HPF.ar(LPF.ar(WhiteNoise.ar(0.008), 12000), hpfFreq.max(1));
	sig = (lpf + hpf) * EnvGen.kr(Env(#[0, 1, 0.6, 0], [attack, decay, release]), t_trig, doneAction:2); // # makes a totally fixed (non-dynamic) Array and is slightly cheaper, especially where you're not going to change the Array once you make it
	OffsetOut.ar(out, Pan2.ar(sig, pan, level));
}).add;

SynthDef(\noise2,{arg out = 0,rel  = 0.01,a=4;
var env0 =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [0.01, rel], [-4, -2, -4]), doneAction:2);
var sig = CuspN.ar(
		SampleRate.ir/a,
		LFNoise2.kr([4,4],1.5,1.5),
		LFNoise2.kr([2,2],1.5,1.5),
		LFNoise2.kr([2,2],0.5,1.5),
		LFNoise2.kr([2,2],0.5,1.5);
	);
	sig = HPF.ar(sig,1000);
	sig = Limiter.ar(sig,0.4);
	sig =	[sig ,DelayL.ar(sig,0.1,100/44100)];
	//sig = PitchShift.ar(sig,0.2,1*a);
	sig = Compander.ar(sig,In.ar(0,1),0.01,1,0.01,0.01,0.1);
	sig=  sig.tanh;
	OffsetOut.ar(out,sig*env0);
}).add;

SynthDef(\noise2new,{arg out = 0, rel = 1, a = 0.2, pan = 0, del1 = 10, del2 = 20;
	var env, sig;
	env =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [0.01, rel], [-4, -2, -4]), doneAction:2);
	sig = CuspN.ar(
        SampleRate.ir/a,
        LFNoise2.kr([4,4],1.5,1.5),
        LFNoise2.kr([0.2,0.2],1.5,1.5),
        LFNoise2.kr([2,2],0.5,1.5),
        LFNoise2.kr([2,2],0.5,1.5);
    );
    sig = HPF.ar(sig,1000);
    sig = Limiter.ar(sig,0.4);
    sig = [DelayL.ar(sig,0.1,del1/44100) ,DelayL.ar(sig,0.1,del2/44100)];
    //sig = PitchShift.ar(sig,0.2,1*a);
    sig = Compander.ar(sig,In.ar(0,1),0.01,1,0.01,0.01,0.1);
    sig = sig.tanh;
    OffsetOut.ar(4, sig * env);
}).add;

SynthDef(\noise,{arg out =0,rel  = 0.25,a=4;
var env0 =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [0.01, rel], [-4, -2, -4]), doneAction:2);
var sig = LatoocarfianL.ar(
		SampleRate.ir/a,
		LFNoise2.kr([2,2],1.5,1.5),
		LFNoise2.kr([2,2],1.5,1.5),
		LFNoise2.kr([2,2],0.5,1.5),
		LFNoise2.kr([2,2],0.5,1.5);
	);
	sig = HPF.ar(sig,1000);
	sig = Limiter.ar(sig,0.4);
	sig =	[sig ,DelayL.ar(sig,0.1,100/44100)];
	//sig = PitchShift.ar(sig,0.2,1*a);
	sig = Compander.ar(sig,In.ar(0,1),0.01,1,0.01,0.01,0.1);
	sig=  sig.tanh;
	OffsetOut.ar(out,sig*env0);
}).add;

/*SynthDef(\test,{arg note=16, bufoffset=0,phase=0,gate=1;
    var env = EnvGen.ar(Env.adsr(1,1,1,1),gate,doneAction:2);
    var detune = VarSaw.ar(t.tempo/8,bufoffset,phase,20,20);
    var freq = (note *(432.cpsmidi/69)).midicps;
    var sig =
    SinOsc.ar([freq,freq+0.5]+(detune),phase+0.4)+
    LFTri.ar([freq,freq+0.5]+(detune),phase+0.3)+
    LFTri.ar([freq,freq+0.5]+(detune),phase+0.2)+
    LFTri.ar([freq,freq+0.5]+(detune),phase+0.1);
//    x = MouseX.kr(0,7);
    sig =Compander.ar(sig,In.ar(6,1)+In.ar(7,1),-22.dbamp,1,0.6,0.3,1,1);
    //sig =   VOsc.ar(bufoffset+x, [freq,freq], 0, 1)+sig;
   //  sig = (sig/7);//;
    //sig = FreeVerb.ar(sig,0.5,0.5)+sig;
    sig =  HPF.ar(sig,200)*env;
    sig =     LeakDC.ar(sig*0.5);
    OffsetOut.ar(0,sig);
}).add;*/

SynthDef(\cosc,{arg gate = 1, amp=1, out=0,rel=0.1,pan=0,freq=512;
    var env2 = EnvGen.ar(Env.adsr(0.5,1,1,0),gate,doneAction:2);
    var env = EnvGen.ar(Env.adsr(0.5,1,1,0),gate);
    var sig = COsc.ar(80,[freq,freq+0.5], 1, 0.1);
    sig  = sig + COsc.ar(80,[freq,freq+0.5]*2, 1, 0.1);
    sig = FreeVerb.ar(sig*env,1);
    sig = LeakDC.ar(sig);
    OffsetOut.ar(0,sig*amp);
}).add;

SynthDef(\noiseInjection, { arg in = 0, out = 0, attack = 0.01, release = 0.01, noiseType = 0, amp = 0.5;
	var input, sig, inputAmp;
	input = In.ar(in, 2);
	inputAmp = Amplitude.kr(input, attack, release);
	noiseType = noiseType.max(0).min(4);
	sig = Select.ar(noiseType, [WhiteNoise.ar(inputAmp), BrownNoise.ar(inputAmp), GrayNoise.ar(inputAmp), PinkNoise.ar(inputAmp), ClipNoise.ar(inputAmp)]);
	Out.ar(out, sig * amp);
}).add;

SynthDef(\jilet, { arg out=0, gate=1, freq=4, amp=0.5, endReflection=1.5, jetReflection=0.5, jetRatio=10.72, noiseGain=0.35, vibFreq=5.925, vibGain=0.02, outputGain=0.20;

	var adsr = (amp*0.2) + EnvGen.ar(Env.adsr(0.005, 0.01, 1.1, 0.01), gate, doneAction: 2);
	var noise = WhiteNoise.ar(noiseGain);
	var vibrato = SinOsc.ar(vibFreq, 0, vibGain);

	var delay = (freq*0.66666).reciprocal;
	var lastOut = LocalIn.ar(1);
	var breathPressure = adsr*Mix([1.0, noise, vibrato]);
	var filter = LeakDC.ar(OnePole.ar(lastOut.neg, 0.7));
	var pressureDiff = breathPressure - (jetReflection*filter);
	var jetDelay = DelayL.ar(pressureDiff, 0.025, delay*jetRatio);
	var jet = (jetDelay * (jetDelay.squared - 1.0)).clip2(1.0);
	var boreDelay = DelayL.ar(jet + (endReflection*filter), 0.05, delay);
	LocalOut.ar(boreDelay);
	Out.ar(out, 0.3*boreDelay*outputGain);
}).add;

SynthDef(\pitchednoise, {arg freq=440, amp=0.1,attack=0.01, sustain=0.1, decay=0.01,pan=0.0, bandwidth=100;
var source, filter, env;

env= EnvGen.ar(Env([0,1,1,0],[attack, sustain, decay]), doneAction:2);

source= WhiteNoise.ar;

filter= BPF.ar(source*env*2*amp,freq,bandwidth/freq);

OffsetOut.ar(0,Pan2.ar(filter,pan))
}).add;

SynthDef(\plastickystrings,{|out= 0 freq = 440 amp = 0.1 gate=1 lforate = 5900 lfowidth= 0.01 cutoff= 12000 rq=0.5 pan=0.0|

	var lfo, saw, filter, env;

	lfo = LFTri.ar(lforate,Rand(0,2.0));

	saw = Saw.ar(freq*(1.0+(lfowidth*lfo)),0.5);

	//filter = BBandPass.ar(saw,freq,4);
	filter = BHiPass.ar(saw,freq,rq); 	//or using cutoff

	env = EnvGen.ar(Env.adsr(0.4,0.0,1.0,1.0),gate,doneAction:2);

	OffsetOut.ar(out,Pan2.ar(filter*env,pan amp));

}).add;

SynthDef(\res, { | out=0 gate=1 freq=40 fltBus pan=0|
	var aEnv, osc, flt;
	aEnv = EnvGen.kr(Env.perc(0, 0.7), gate, doneAction: 2);
	osc = Mix([Saw.ar(freq), Pulse.ar(freq / 2, 0.5)]);
	flt = RLPF.ar(osc, In.kr(fltBus, 1), 0.1, aEnv);
	ReplaceOut.kr(fltBus, LFNoise1.kr(0.3, 1000, 1500));

	OffsetOut.ar(out, Pan2.ar(flt, pan));
}).add;

SynthDef(\mutantFric, { arg out = 0, amp = 1, spec1 = 0.00001, spec2 = 0.03, noiseFreq = 3, gate = 1, attack = 0.01, release = 1, doneAction = 2;
	var friction, sig;
	friction = Array.fill(5, {
		[spec1, spec2].asSpec.map(LFNoise2.kr(noiseFreq))
	});
	sig = Friction.ar(LFTri.ar(50), friction: friction, mass: friction*30000);
	sig = sig * EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	OffsetOut.ar(out, Splay.ar(sig * amp));
}).add;

SynthDef(\tweetFogAttack, { arg out = 0, t_trig = 1, feedBack = 0.2, attack = 0.01, release = 2, amp = 1, doneAction;
	var sig, env, coef;
	sig = Pulse.ar(pi/[1,2.57],[0.54,0.46]);
	coef = (1-LocalIn.ar(2)).fold(0,[0.9,0.85]);
	sig = LeakDC.ar(Integrator.ar(sig, coef).wrap2(pi).sin);
	LocalOut.ar(sig);
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = (sig.mean!2) * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\tweetErosion, { arg out = 0, t_trig = 1, attack = 0.01, release = 2, feedBack = 1, amp = 1, doneAction = 2;
	var sig, env, input, div;
	input = LocalIn.ar(2).range(0,0.9)+0.1;
	div = LagUD.ar(input, 0, 0.2);
	sig = PinkNoise.ar(1!2);
	sig = tanh(500*(sig**(8/div)));
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	LocalOut.ar(sig * feedBack);
	sig = Splay.ar(sig,1-input);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\harshTexture, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = Impulse.ar(8).lag(0.3)!2;
	10.do {
		sig = LeakDC.ar(
			AllpassC.ar(
				sig,
				1,
				LFNoise0.ar(8).range(1e-5,0.2),
				-0.15,
				LFNoise0.ar(8).range(1,3)
			)
		).tanh;
	};
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\ultraHiSummer, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = Blip.ar(
		[16e3,16150],
		2,
		LFTri.ar(
			Duty.ar(
				LFNoise0.ar(0.2,4,6),
				0,
				Dseq([70,30,0],inf)
			)
		).clip(0,1)
	);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\ambiantPic, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = LFNoise2.kr(22,5,9);
	sig = CombC.ar(
		Splay.ar(
			Gendy3.ar(
				[4,2],
				[0.5,1],
				[1/9,1/4]*sig,
				[1/2,1/8]*sig,
				(9,49..199)
			)
		),
		5,
		[0.13,0.1],
		[sig/2,sig/2.1]
	);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\attBreath, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = TDuty.kr(Dseq([1,1,4,2,2]/8,inf));
	sig = Resonz.ar(
		Crackle.ar!2,
		Demand.kr(sig,0,Dseq([250,8e3],inf)),
		Demand.kr(sig,0,Dwhite(0.01,0.5,inf))
	);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\attWind, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = TDuty.kr(Dseq([1,1,4,2,2]/8,inf));
	sig = Resonz.ar(
		WhiteNoise.ar!2,
		Demand.kr(sig,0,Dseq([250,8e3],inf)),
		Demand.kr(sig,0,Dwhite(0.01,0.5,inf))
	);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\tweetWindy, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env, i, x;
	i = SinOsc;
	x = {exprand(0.1,0.01)};
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = Splay.ar({[PinkNoise,BrownNoise,GrayNoise].choose.ar*i.ar(i.ar(0.01).range(x,x))}!9);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\dStowell, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 2, freq = 6/3, width = 1/5, doneAction = 2;
	var sig, env, spec, input;
	spec = `[{exprand(100,1000)}.dup(50)];
	input = Saw.ar(
		LFPulse.kr(freq,0,width).range(3,3000),
		0.0005
	);
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = Klank.ar(spec, input);
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\seqModul, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env, buffer;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	buffer = LocalBuf(1e5,2).clear;
	sig = BufRd.ar(2,buffer,Phasor.ar(0,1,0,1e5))*0.6;
	BufWr.ar(Blip.ar([1,1.01],10)/5+sig,buffer,LFNoise1.ar(0.2)+1*5e4);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\harrish, {| out = 0, amp = 0.2, pan = 0, attack = 0, sustain = 0.2, release = 0.1, curve = 0, clipLevel = 0.006, impFreq = 0, impPhase = 0, impLevel = 1, noiseLevel = 0.3, lpf = 20000, eqfreq = 4000, eqrq = 1, eqdb = 0, hpf = 20,  doneAction = 2|
	var env = EnvGen.ar(Env.linen(attack, sustain, release, curve: curve), doneAction: doneAction);
	var snd = (ClipNoise.ar(clipLevel) + Impulse.ar(impFreq, impPhase, impLevel) + BrownNoise.ar(noiseLevel)) * env;
	snd = LPF.ar(snd, lpf);
	snd = BPeakEQ.ar(snd, Lag2.kr(eqfreq.max(20).min(20000), 0.5), eqrq, eqdb);
	snd = HPF.ar(snd, hpf);
	OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\KSpluck3, { arg out = 0, att = 0, dec = 0.01, midiPitch, art, noiseFreq = 1, doneAction = 2;
	var burstEnv;
	var sig, delayTime;
	delayTime = [midiPitch, midiPitch + 12].midicps.reciprocal;
	burstEnv = EnvGen.kr(Env.perc(att, dec));
	sig = PinkNoise.ar([burstEnv, burstEnv]); //Noise burst
	sig = CombL.ar(sig, delayTime, delayTime,
		art, add: sig); //Echo chamber
	sig = RLPF.ar(sig, LFNoise1.kr(noiseFreq, 13000, 14010), 0.1); //Filter ADSR GELSIN BURAYA
	DetectSilence.ar(sig, doneAction: doneAction);
	OffsetOut.ar(out, sig*0.8)
}).add;

SynthDef(\lmcd, { arg out = 0, amp = 1, att = 0.01, rel = 5, trigDur = 0.1, lfCubTu = 1, hpfFreq = 440, gate = 1, doneAction = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	sig = Duty.kr(trigDur, 0, Dseq(fib(32).wrap(20, 55).midicps, inf));
	sig = LFCub.ar([-1, sig, sig / 3, -2] * lfCubTu);
	sig = LeakDC.ar(sig) * 9;
	sig = HPF.ar(sig, hpfFreq).clip2 / 9;
	sig = Splay.ar(sig);
	OffsetOut.ar(out, sig * env * amp);
}).add;

SynthDef(\ploux, { arg out = 0, amp = 0.1, pan = 0, att = 0.1, dec = 0.1, sus = 0.8, rel = 0.1, dustfreq = 2, dustdecay = 0.7, freq = 200, fmfreq = 100, t_trig = 1, doneAction = 2;
    var sig, dust;
    dust = Dust.ar(dustfreq);
    dust = Decay.ar(dust, dustdecay);
    sig = SinOsc.ar(freq * ( SinOsc.ar(fmfreq * dust) * 1 + 1 ));
    sig = sig * EnvGen.kr(Env.adsr(att, dec, sus, rel), t_trig, doneAction: doneAction);
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}, [\kr ! 11, \tr, \ir].flatten).add;

SynthDef(\complexosc, { arg out = 0, amp = 1, feedBack = 1, envL1 = 0, envL2 = 2.2, envL3 = 0.12, envL4 = 0, envT1 = 0.01, envT2 = 0.24, envT3 = 0.12, envCurve = (-4), freq1 = 40, fm1 = 0.1, pm1 = 0, amp1 = 1, ring1 = 1, offset1 = 0, freq2 = 0.5, fm2 = 0.1, pm2 = 0, amp2 = 1, ring2 = 1, offset2 = 0, fold = 0.8, wrap = 0.9, switch = 2, t_trig = 1, doneAction = 2;
    var osc1, osc2, fbk, outlet, folded, wrapped, env, sigenv;
    fbk = LocalIn.ar(2) * feedBack;
	//env = Linen.kr(t_trig, attack, 1, release, doneAction);
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), t_trig, doneAction: doneAction);
    osc1 = SinOsc.ar(freq1 + (fbk[1].range(1,1000) * fm1), 0 + (fbk[1].range(-pi,pi) * pm1), envT3 + amp1 + (fbk[1] * ring1), offset1);
    osc2 = SinOsc.ar(freq2 + (fbk[0].range(1,1000) * fm2), 0 + (fbk[1].range(-pi,pi) * pm2), amp2 + (fbk[0] * ring2), offset2);
    LocalOut.ar([osc1, osc2]);
    folded = Fold.ar(osc1 ! 2, fold.neg, fold);
    wrapped = Wrap.ar(osc1 ! 2, wrap.neg, wrap);
    outlet = LeakDC.ar(Select.ar(switch, [osc1!2, osc2!2, folded, wrapped]));
    OffsetOut.ar(out, outlet * env * amp);
}, [\kr ! 11, \ar ! 14, \kr, \tr, \ir].flatten).add;

SynthDef(\benjolis,{ |out = 0, amp = 1, fadeTime, 0.01, freq1= 40, freq2=4, scale=1, rungler1=0.16, rungler2=0.0, runglerFilt=9, loop=0, filtFreq=40, q=0.82, gain=1, filterType=0, outSignal=6, doneAction = 2|
	var osc1, osc2, tri1, tri2, sh0, sh1, sh2, sh3, sh4, sh5, sh6, sh7, sh8=1, rungler, pwm, filt, output;
	var sr;
	var osc2freq, buf, bufR;

	bufR = LocalIn.ar(2,0);
	rungler = bufR.at(0);
	buf = bufR.at(1);

	sr = SampleDur.ir;
	//sr = ControlDur.ir;
	tri1 = LFTri.ar((rungler*rungler1)+freq1);
	tri2 = LFTri.ar((rungler*rungler2)+freq2);
	osc1 = PulseDPW.ar((rungler*rungler1)+freq1);
	osc2 = PulseDPW.ar((rungler*rungler2)+freq2);

	//pwm = tri1 > tri2;
	pwm = BinaryOpUGen('>', (tri1 + tri2),(0));

	osc1 = ((buf*loop)+(osc1* (loop* -1 +1)));
	sh0 = BinaryOpUGen('>', osc1, 0.5);
	sh0 = BinaryOpUGen('==', (sh8 > sh0), (sh8 < sh0));
	sh0 = (sh0 * -1) + 1;

	sh1 = DelayN.ar(Latch.ar(sh0,osc2),0.01,sr);
	sh2 = DelayN.ar(Latch.ar(sh1,osc2),0.01,sr*2);
	sh3 = DelayN.ar(Latch.ar(sh2,osc2),0.01,sr*3);
	sh4 = DelayN.ar(Latch.ar(sh3,osc2),0.01,sr*4);
	sh5 = DelayN.ar(Latch.ar(sh4,osc2),0.01,sr*5);
	sh6 = DelayN.ar(Latch.ar(sh5,osc2),0.01,sr*6);
	sh7 = DelayN.ar(Latch.ar(sh6,osc2),0.01,sr*7);
	sh8 = DelayN.ar(Latch.ar(sh7,osc2),0.01,sr*8);

	//rungler = ((sh6/8)+(sh7/4)+(sh8/2)); //original circuit
	//rungler = ((sh5/16)+(sh6/8)+(sh7/4)+(sh8/2));

	rungler = ((sh1/2.pow(8))+(sh2/2.pow(7))+(sh3/2.pow(6))+(sh4/2.pow(5))+(sh5/2.pow(4))+(sh6/2.pow(3))+(sh7/2.pow(2))+(sh8/2.pow(1)));

	buf = rungler;
	rungler = (rungler * scale.linlin(0,1,0,127));
	rungler = rungler.midicps;

	LocalOut.ar([rungler,buf]);



	filt = Select.ar(filterType, [
		RLPF.ar(pwm,(rungler*runglerFilt)+filtFreq,q* -1 +1,gain),
		//BMoog.ar(pwm,(rungler*runglerFilt)+filtFreq,q,0,gain),
		RHPF.ar(pwm,(rungler*runglerFilt)+filtFreq,q* -1 +1,gain),
		SVF.ar(pwm,(rungler*runglerFilt)+filtFreq,q,1,0,0,0,0,gain),
		DFM1.ar(pwm,(rungler*runglerFilt)+filtFreq,q,gain,1)
	]);


	output = SelectX.ar(outSignal, [
		tri1, osc1, tri2, osc2, pwm, sh0, filt

	]);
	output = LeakDC.ar(output * amp ! 2);
	OffsetOut.ar(out, output * EnvGate(fadeTime: fadeTime, doneAction: doneAction));
}).add;

SynthDef(\bytebeats, { arg out = 0, amp = 1, fadeTime = 0.01, srDiv = 6, freq = 232, doneAction = 2;
	//var sr = SampleRate.ir/6; //fix sample rate
	var counter;
	var sr = SampleRate.ir/srDiv; //variable sample rate
	//var freq = 10;
	var n = 16; //bit resolution
	var t= Phasor.ar(1,freq*((2**n)/sr),0,((2**n)-1)); //creating a raising value from 0 to 2**n
	//t = t & (2**(n-1)); // few tests
	//equations: try one at the time
	t = t * 4;
	counter = LFSaw.ar(0.5,0,3.5,3.5); // browse the equations
	//counter = LFDNoise0.ar(MouseY.kr(1,0.1),3.5,3.5);
	//counter.poll;
	t = Select.ar(counter,[

	t*(((t>>12)|(t>>8))&(63&(t>>4))),
	t*(((t>>9)|(t>>13))&(25&(t>>6))),
	t*(((t>>5)|(t>>8)) & 63),
	t*(((t>>11)&(t>>8))&(123&(t>>3))),
	t*(t>>8*((t>>15)|(t>>8))&(20|(t>>19)*5>>t|(t>>3))),
	t*(t>>((t>>9)|(t>>8))&(63&(t>>4))),
	(t>>7|t|t>>6)*10+4*(t&t>>13|t>>6)
	]);

	t = t % (2**(n));// avoiding number beyond 2**(bit resolution)
	t = t*(0.5**(n-1)) - 1;//scaling to -1, 1

	t = LeakDC.ar((t * amp).dup);
	OffsetOut.ar(out, t * EnvGate(fadeTime: fadeTime, doneAction: doneAction));
}).add;

SynthDef(\feedbackOsc, {|out=0, amp = 1, mFrq= 313, mFB= 1, freq= 100, fB= 1, width= 0, mul= 500, ffreq=1000, rq=1, attack=0.01, sustain=1, release=1, gate = 1, doneAction = 2|
	var w= [0, width*2pi];
	var buf= LocalBuf(1).clear;
	var buf2= LocalBuf(1, 2).clear;
	var osc= sin(LFSaw.ar(mFrq).range(0, 2pi)+(Dbufrd(buf)*mFB));
	var snd= Duty.ar(SampleDur.ir, 0, Dbufwr(osc, buf));
	var osc2= sin(LFSaw.ar(freq+(snd*mul)).range(0, 2pi)+(Dbufrd(buf2)*fB)+w);
	var snd2= Duty.ar(SampleDur.ir, 0, Dbufwr(osc2, buf2));
	//var filter= RLPF.ar(snd2, ffreq, rq);
	var filter = DFM1.ar(snd2, ffreq, rq);
	//var env = EnvGen.ar(Env.asr(attack,sustain,release),gate,doneAction:2);
	OffsetOut.ar(out,filter * amp * EnvGate(gate: gate, doneAction: doneAction));
}).add;

SynthDef(\salledutemps, { arg out = 0, amp = 1, tu = 1, dur = 9, attack = 1, release = 4, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = {DynKlank.ar(`[((55/2)+ (tu * (Demand.kr(Impulse.kr(0), 0, Diwhite(0, 6))*2*(55/24))))*(2**(0..8))],Crackle.ar(2,0.005))*LFGauss.ar(dur,0.7,0,1)}!5;
	sig = sig * env;
	sig = Splay.ar(sig);
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\salledutemps1, { arg out = 0, amp = 1, tu = 1, dur = 9, myst = 55, attack = 1, release = 4, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = {DynKlank.ar(`[((myst/2)+ (tu + (tu * (Demand.kr(Impulse.kr(0), 0, Diwhite(0, 6))*2*(myst/24)))))*(2**(0..8))],Crackle.ar(2, 0.005))*LFGauss.ar(dur,0.7,0,1)}!5;
	sig = sig * env;
	sig = Splay.ar(sig);
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\corman, { arg out = 0, amp = 1, tu = 1, dur = 9, attack = 1, release = 10, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = {DynKlank.ar(`[(tu * Demand.kr(Impulse.kr(0), 0, Diwhite(0, 98)))*(1..9)],Crackle.ar(2,0.01))*LFGauss.ar(dur,0.7,0,1)}!2;
	sig = sig * env;
	sig = Splay.ar(sig);
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\corman1, { arg out = 0, amp = 1, tu = 1, dur = 9, attack = 1, release = 10, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = {DynKlank.ar(`[(tu + (tu * Demand.kr(Impulse.kr(0), 0, Diwhite(0, 98))))*(1..9)],Crackle.ar(2,0.01))*LFGauss.ar(dur,0.7,0,1)}!2;
	sig = sig * env;
	sig = Splay.ar(sig);
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\werkit, { arg out = 0, amp = 0.1, pan = 0.0, att = 0.01, dec = 0, sus = 1, rel = 1, freq = 440, rq = 0.1, gate = 1,doneAction = 2;

	var source, filter, env, snd, delayEnv;
	source = WhiteNoise.ar;
	filter = BLowPass4.ar(source, freq, rq) * 0.3;
	env = EnvGen.ar(
		envelope: Env.adsr(att, dec, sus, rel, amp),
		gate: gate,
		doneAction: 2);
	snd = (0.7 * filter + (0.3 * filter.distort)) * env;
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\werkit2, { arg out = 0, amp = 0.1, att = 0.01, dec = 0, sus = 1, rel = 0.1, freq = 440, rq = 0.1, gate = 1, doneAction = 2;

	var source, filter, env, snd;
	source = LFSaw.ar(Array.fill(16, { Rand(100, 200) }));
	filter = BLowPass4.ar(source, freq, rq) * 0.1;
	env = EnvGen.ar(
		envelope: Env.adsr(att, dec, sus, rel, amp),
		gate: gate,
		doneAction: doneAction);
	snd = (0.7 * filter + (0.3 * filter.distort)) * env;
	snd = HPF.ar(snd, 100);
	snd = Splay.ar(snd);
	OffsetOut.ar(out, snd);
}).add;

SynthDef(\dobsonFfitch, { |out, freq = 50, freqFactor = 1.01, a = -0.4, b = 0.6, c = 0.2,
    d = 0.75, l = 32, limitType = 1, amp = 0.2|
    var src, sig;
    src = Saw.ar([1, freqFactor] * freq);
    sig = Fb1.ar({ |in, out|
        var x = (a * out[1]) + (b * out[2]) + (d * Select.kr(l, out).squared) + in[0] - c;
        Select.kr(limitType, [x.tanh, x.softclip, x.distort])
        },
        in: src, outSize: 2, outDepth: 50,
        blockSize: s.options.blockSize,
        blockFactor: 64 / s.options.blockSize
    ) * amp;
    // cut off some high frequencies
    Out.ar(0, LPF.ar(sig, 15000))
}).add;

SynthDef(\lcm2, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, mod1 = 3.09431, mod2 = 54.0487, gate = 1, doneAction = 2;
    var sig, sig1, sig2, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    mod1 = mod1.min(1000).max(1);
    mod2 = mod2.min(1000).max(1);

    sig1 = Saw.ar(mod1).range(-100,100).round(1);
    sig2 = LFCub.ar(mod2).range(-100,100).round(1);

    sig = tanh(lcm(sig1, sig2) * 0.001);

    sig = sig * env;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\danScar, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.2, sustain = 1.5, curve = 4, sinFreq = 30, noiseFreq = 1, lpfFreq = 15000, doneAction = 2;
    var sig, globalEnv, inSig, lfo;

    globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);

    inSig = SinOsc.ar(sinFreq + [0, 0.1]);
    lfo = LFDNoise1.kr(noiseFreq).linexp(-1, 1, 0.5, 1);

    sig = LPF.ar(
        Fb1.ar(
            { |in, out| in[0] - (out[1] % lfo) },
            inSig, 2, blockSize: s.options.blockSize
        ),
        lpfFreq
    ) * amp;

    sig = Pan2.ar(sig, pan);

    OffsetOut.ar(out, sig * globalEnv);
}).add;

SynthDef(\danScar1, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.2, sustain = 1.5, curve = 4, sinFreq = 30, noiseFreq = 1, lpfFreq = 15000, doneAction = 2;
    var sig, globalEnv, inSig, lfo;

    globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);

    inSig = SinOsc.ar(sinFreq + [0, 0.1]);
    lfo = LFDNoise1.ar(noiseFreq).linexp(-1, 1, 0.5, 1);

    sig = LPF.ar(
         Fb1.ar(
            // in[0][0] is the current stereo sample of inSig
            // in[0][1] is the current mono sample of lfo
            { |in, out| in[0][0] - (out[1] % in[0][1]) },
            [inSig, lfo], 2, blockSize: s.options.blockSize
        ),
        lpfFreq
    ) * amp;

    sig = Pan2.ar(sig, pan);

    OffsetOut.ar(out, sig * globalEnv);
}).add;

SynthDef(\danScar2, { arg out = 0, amp = 0.1, attack = 0, release = 1.2, sustain = 1.5, curve = 4, triFreq = 60, noiseFreq = 0.5, doneAction = 2;
    var sig, globalEnv, inSig, lfo;

    globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);

    inSig = LFTri.ar(triFreq);
    lfo = { LFDNoise3.ar(0.5).linexp(-1, 1, 0.1, 150) } ! 2;

    sig = Fb1.ar(
        // in[0][0] is the current stereo sample of inSig
        // in[0][1] is the current mono sample of lfo
        { |in, out| in[0][0] - (out[1] % in[0][1]) },
        [inSig, lfo], 2, blockSize: s.options.blockSize
    ) * amp;

    OffsetOut.ar(out, sig * globalEnv);
}).add;

SynthDef(\natwich, { arg out = 0, amp = 0.3, pan = 0, attack = 0, release = 1.2, sustain = 1.5, curve = 4, modFreq = 0.4, modAmount = 0.8, sawFreq = 2100, rlpfFreq = 4000, rlpfRq = 0.1, doneAction = 2;
    var snd, fb, sig, globalEnv, mod1, mod2;

    globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);

    mod1 = LFDNoise3.kr(modFreq, modAmount).range(0.1, 1.5);
    mod2 = LFDNoise0.kr(modFreq, modAmount).range(0.1, 1.5);

    fb = LocalIn.ar(1);
    snd = Saw.ar(sawFreq * mod1 * (fb * 48).midiratio);
    snd = RLPF.ar(snd, rlpfFreq * mod2 * (48 * (1 - fb)).midiratio, rlpfRq);
    snd = (snd * 3).fold2;
    sig = snd;
    snd = Amplitude.ar(ToggleFF.ar(PulseDivider.ar(snd, 3 * (1 + (100 * fb)))), 0.03, 0.3);
    LocalOut.ar(snd);
    snd = Pan2.ar(sig, pan) * amp * globalEnv;
    snd = Sanitize.ar(snd);
    snd = snd + (NHHall.ar(snd, 3) * -10.dbamp);

    OffsetOut.ar(out, snd);
}).add;

)