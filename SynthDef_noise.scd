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

)