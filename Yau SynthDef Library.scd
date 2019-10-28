/************************************************************************Clap**********************************************************************/
SynthDef(\clap, {| out=0, amp = 1, pan=0, duré=1,sendChannels=0,	send=1, gate=1, q=0.1,fq=1,rnd1=0,rnd2=0,rnd3=0 |
			var env1, env2, noise1, noise2,sig;
	env1 = EnvGen.ar(\env1.kr(Env([0, 1, 0.5, 0.5, 0, 1, 0, 0.3, 0],	[0.001, 0.0013, 0, 0.01, 0, 0.001, 0, 0.03],[0, -3, 0, -3, 0, -3, 0, -4])),doneAction:2);
			noise1 = WhiteNoise.ar(env1);
			noise1 = HPF.ar(noise1, 400);
			noise1 = BPF.ar(noise1, 1000*fq, 20*q);
	env2 = EnvGen.ar(\env2.kr(Env([0, 1, 0], [0.002, 0.1], [0, -4])),gate,	doneAction:2,);
			noise2 = WhiteNoise.ar(env2);
			noise2 = HPF.ar(noise2, 2300);
			noise2 = BPF.ar(noise2, 2000*fq, 7*q, 0.7);
			sig = noise1 + noise2;
			sig = sig * 2;
			sig = sig.softclip * amp;
			OffsetOut.ar(out,sig*send);
			OffsetOut.ar(24,sig*send);
}).add;

SynthDef(\clapping, {arg out = 0,t_trig=1, amp=0.5, filterfreq=120, rq=0.1;
	var env, signal, attack,  noise, hpf1, hpf2;
	noise = WhiteNoise.ar(1)+SinOsc.ar([filterfreq/2,filterfreq/2+4 ], pi*0.5, XLine.kr(1,0.01,4));
	hpf1 = RLPF.ar(noise, 400, rq);
	hpf2 = RHPF.ar(noise,  120, rq/4);
	env = EnvGen.kr(Env.perc(0.003, 0.035));
	signal = (hpf1+hpf2) * env;
	signal = CombC.ar(signal, 0.5, 0.03, 0.031)+CombC.ar(signal, 0.5, 0.03016, 0.06);
	signal = FreeVerb.ar(signal, 0.1, 0, 0.5);
	signal = Limiter.ar(signal, 0.7, 0.01) * amp;
	Out.ar(out, Pan2.ar(signal, 0));
	DetectSilence.ar(signal, doneAction:2);
}).add;

/***********************************************************************Noise*******************************************************************/

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
	Out.ar(out,sig*env0);
}).add;

SynthDef(\noise2new,{arg out = 0,rel  = 1,a=0.2,pan=0,del1=10,del2=20;
var env0 =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [0.01, rel], [-4, -2, -4]), doneAction:2);
var sig = CuspN.ar(
        SampleRate.ir/a,
        LFNoise2.kr([4,4],1.5,1.5),
        LFNoise2.kr([0.2,0.2],1.5,1.5),
        LFNoise2.kr([2,2],0.5,1.5),
        LFNoise2.kr([2,2],0.5,1.5);
    );
    sig = HPF.ar(sig,1000);
    sig = Limiter.ar(sig,0.4);
    sig =    [DelayL.ar(sig,0.1,del1/44100) ,DelayL.ar(sig,0.1,del2/44100)];
    //sig = PitchShift.ar(sig,0.2,1*a);
    sig = Compander.ar(sig,In.ar(0,1),0.01,1,0.01,0.01,0.1);
    sig=  sig.tanh;
    Out.ar(4,sig*env0);
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
	Out.ar(out,sig*env0);
}).add;

SynthDef(\test,{arg note=16, bufoffset=0,phase=0,gate=1;
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
    Out.ar(0,sig);
}).add;

SynthDef(\cosc,{arg gate = 1, amp=1, out=0,rel=0.1,pan=0,freq=512;
    var env2 = EnvGen.ar(Env.adsr(0.5,1,1,0),gate,doneAction:2);
    var env = EnvGen.ar(Env.adsr(0.5,1,1,0),gate);
    var sig = COsc.ar(80,[freq,freq+0.5], 1, 0.1);
    sig  = sig + COsc.ar(80,[freq,freq+0.5]*2, 1, 0.1);
    sig = FreeVerb.ar(sig*env,1);
    sig =     LeakDC.ar(sig);
    Out.ar(0,sig*amp);
}).add;

/*******************************************************************Cymbal**********************************************************************/

SynthDef(\cym, { arg out=0,tu=1, amp=0.5, pan=0,rel=1;
	var sig;
	var env = EnvGen.ar(Env.perc(0,rel,1,-8),doneAction:2);
	var
	freqs= geom(100,50,1.3434)*10.234567*tu;
	sig = WhiteNoise.ar;
	sig = Ringz.ar(sig,freqs,1).mean;
	sig = Pan2.ar(sig*env, pan, amp);
	Out.ar(out, sig*amp);
}).add;

SynthDef(\cymnew, { arg out=0,tu=6, amp=0.5, pos=0,rel=4;
    var sig;
    var env = EnvGen.ar(Env.perc(0,rel,1,-8),doneAction:2);
    var
    freqs= geom(99,40,pi/3)*10.234567*tu;
    sig = WhiteNoise.ar;
    sig = Ringz.ar(sig,freqs,1).mean;
    sig = sig *env;

    //sig = Pan2.ar(sig*env, pos, amp);
    Out.ar(out, sig*amp*0.2);
}).add;

/******************************************************************HiHats***********************************************************************/

SynthDef(\hat,{arg gate = 1, amp=1, out=0,rel=0.1;
	var env = EnvGen.ar(Env.perc(0,rel),gate,doneAction:2);
	var freq = EnvGen.ar(Env([12000,80,20000],[0.1,0.1]));
	var sig = PinkNoise.ar(env);
	sig = HPF.ar(sig,freq);
	sig = sig.tanh;
	Out.ar(out,sig*amp*12);
}).add;

SynthDef(\hatnew, {|out=0, freq=230, hpf=8500, rel=0.15, amp=1, fxb=0, fxv=0, bbcb=0, bbcv=0|
  var pulse, sig, env, freqs;
  freqs = [freq, freq*1.4471, freq*1.617, freq*1.9265, freq*2.5028, freq*2.6637];
  pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6, mul: 1));
  sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
  env = EnvGen.kr(Env.perc(0,rel),doneAction:2);
  sig = sig*env*amp;
    //sig =  Pan2.ar(sig*amp,0);
  Out.ar(out,sig);
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
	Out.ar(out, sig*amp);
}).add;

/******************************************************************Kick************************************************************************/

// MONO KICKS

SynthDef("kick", {
	arg out=0,tu = 1,amp=1;
	var env0, env1, env1m, sig;
	env0 =  EnvGen.ar(Env.new([0.5, 1, 0.3, 0], [0.01, 0.5, 0.26], [-4, -2, -4]), doneAction:2);
	env1 = EnvGen.ar(Env.new([120, 43, 29], [0.03, 0.29], [-4, -5]));
	env1m = env1.midicps;
	sig = LFPulse.ar(env1m*tu, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(1);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m*tu, 0.5, env0*4);
	sig = sig * amp;
	sig = sig.clip2(1);
	Out.ar(out, sig);
}).send(s);



SynthDef("kickhi", {
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
	Out.ar(out, sig);
}).send(s);



SynthDef(\kick2,{arg out=0,gate = 1 ,freq=60,tu = 1,amp=1,atf = 80, rel =1;
	var env = EnvGen.ar(Env.perc(0,rel),gate,doneAction:2);
	var frequ = EnvGen.ar(Env([freq-30,freq,60],[0.001,0.01]));
	var sig = SinOsc.ar(frequ*tu,0,env);
	sig = LPF.ar(sig,100);
	Out.ar(out,sig * amp);
}).add;

SynthDef(\kick2new,{arg out=0,gate = 1 ,freq=60,tu = 1,amp=1,atf = 80, rel =1;
    var env = EnvGen.ar(Env.perc(0,rel),gate,doneAction:2);
    var frequ = EnvGen.ar(Env([freq+1100,freq,31.4],[0.002,0.1]));
    var sig = SinOsc.ar(frequ*tu,0,env);
    sig = BPeakEQ.ar(sig,80,1,6);
    sig = sig *0.4*(env+0.2);
    sig = BPeakEQ.ar(sig,800,10,-12);
    sig = Limiter.ar(sig,0.5);
    Out.ar(6,[DelayL.ar(sig*(-1),0.1,SinOsc.kr(-0.1,0,0.05,0.1)),sig]);
    //sig = LPF.ar(sig,100);
    Out.ar(out,sig * amp);
}).add;

SynthDef(\kick3,{arg out=0,amp=1,gate = 1, tu = 1, rel =3,freq=60;
	var env = EnvGen.ar(Env.perc(0,rel),gate,doneAction:2);
	var frequ = EnvGen.ar(Env([130,freq,30],[0.05,rel]));
	var sig = SinOsc.ar(freq*tu,0,env);
	Out.ar(out,sig * amp);
}).add;

SynthDef(\kick3new,{arg out=0,amp=1,gate = 1, tu = 1, rel =3,freq=60;
    var env = EnvGen.ar(Env.perc(0,rel),gate,doneAction:2);
    var frequ = EnvGen.ar(Env([100,50,50],[0.005,0.1]));
    var sig = SinOsc.ar(frequ*tu,0,env);
    Out.ar(out,sig * amp);
}).add;

SynthDef(\kicknoise,{arg out=0, amp=0.5;
	var env = EnvGen.ar(Env([0,1,0],[0.01,1]),doneAction:2);
	var freq =EnvGen.ar(Env([20000,100,30],[0.005,1]));
	var sig =  SinOsc.ar(freq,0,env)+(WhiteNoise.ar(1)*env);
	Out.ar(out,sig*amp);
}).add;



SynthDef(\t1kick,{arg out=0,rel = 0.6,pitch=1 ,amp =1 ,snd;
	var enva = EnvGen.ar(Env([0.01,1,0],[0.001,rel]),doneAction:2);
	var envf = EnvGen.ar(Env([800,50],[0.005,1]));
	var sig = SinOsc.ar(envf,0,enva);
	//sig = HPF.ar(sig*enva,30);
	Out.ar(out,sig*amp);
}).add;


SynthDef(\t1kick2,{arg out = 0,snd=18,rel = 0.6,pitch=0.1 ,amp =1;
	var enva = EnvGen.ar(Env([1,1,0],[rel,0.2]),doneAction:2);
	var envf = EnvGen.ar(Env([10000,20,00,4],[0.002,0.1,1,1]));
	var sig = SinOsc.ar(envf+50*pitch,0,enva);
	//sig = PitchShift.ar(sig,0.001,pitch,0.1);
	sig = sig.distort;
	sig = HPF.ar(FreeVerb.ar(sig,1,1),100)+sig;
	Out.ar(out,sig*amp*enva);
	//Out.ar(snd,sig*amp*enva);
}).add;


// STEREO KICKS

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


SynthDef(\kick808,{arg rel=1,tu=1,amp=0.5;
	var env = EnvGen.ar(Env([0,1,0],[0,rel],-8),doneAction:2);
	var enf  = EnvGen.ar(Env([1000,20,20],[0.001,0.001,0.001],-4));
	var sig = SinOsc.ar(tu*(enf+40))*env;
	sig = sig + LPF.ar(SinOsc.ar(SinOsc.ar(100,0,50,100*tu),0,0.2)*env,1000);
	Out.ar(0,sig*env*amp);
}).add;

SynthDef(\kick808new,{arg out=0,rel=1,tu=2,amp=0.5;
    var env = EnvGen.ar(Env([1,1,0],[0,rel],-8),doneAction:2);
    var enf  = EnvGen.ar(Env([5000,100,50],[0.0001,0.01,0.1],-4));
    var sig = SinOsc.ar(tu*(enf))*env;
    sig = sig + LPF.ar(SinOsc.ar(SinOsc.ar(10,0,50,40*tu),0,0.01)*env,100);
    sig = LeakDC.ar(sig);
    Out.ar(out,sig*env*amp);
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
OffsetOut.ar(32, son*level).tanh;

},

).add;

/********************************************************************MeloPerc*****************************************************************/

SynthDef(\cow, { arg out=0,tu=1, amp=0.5, pan=0,gate=1,rel=1;
	var sig;
	var env = EnvGen.ar(Env.adsr(0.001,0.01,0.1,rel),gate,doneAction:2);
	sig = LFPulse.ar(550*tu)+LFPulse.ar(tu*400*(env+250));
	sig = Ringz.ar(sig,(30..35)*10.234*tu,1).mean;
	//sig = Pan2.ar(sig*env, pan, amp);
	Out.ar(out, sig*amp*env);
}).add;


//STEREO



SynthDef(\notes,{arg out=0,freq = 69,gate = 1,tu = 1,amp=0.5;
	var env = EnvGen.ar(Env.perc(0.01,0.1),gate,doneAction:2);
	var sig = WhiteNoise.ar(env);
	sig = CombL.ar(sig,0.2,(freq+(432.cpsmidi-69)).midicps/SampleRate.ir,1)+sig;
	sig = CombL.ar(sig,0.2,(freq+(432.cpsmidi-69)).midicps/SampleRate.ir,0.2)+sig;
	sig = sig *env *0.5;
	sig = CompanderD.ar(sig*2,0.5,1,0.5);
	Out.ar(out,sig*amp);
}).add;


SynthDef(\notes2,{arg out=0,gate =1,notes=68,at = 0.01,sus=0.4,snd=18;
	var env = EnvGen.ar(Env.adsr(at,1,sus,1.4),gate,doneAction:2);
	//var env = EnvGen.ar(Env.perc(0.01,1),gate,doneAction:2);
	var note = (notes+(432.cpsmidi-69)).midicps;
	var sig = Mix.ar(SinOsc.ar([note,note*2,note/2]));
	sig = Splay.ar(sig*0.1);
	Out.ar(out,sig*env*0.5);
	//Out.ar(snd,sig*env);
}).add;

SynthDef(\sinus,{arg out=0, freq=100,gate =1,release=0.1,lfo=1,amp=0.5;
	var env  = EnvGen.ar(Env.perc(0,release),gate,doneAction:2);
	var sig = SinOsc.ar(freq.midicps+(432-69.midicps)*SinOsc.kr(lfo),0,env);
	sig = HPF.ar(sig,100);
	sig = CompanderD.ar(sig,0.3,0.3,1.5,0.0001,0.01);
	Out.ar(out,sig*amp);
}).add;

/********************************************************************RimShot*****************************************************************/

SynthDef(\rim, { arg out=0,tu=1, amp=0.2, pan=0,gate=1,rel=1;
	var sig;
	var env = EnvGen.ar(Env([1,0,1,0],[0,0.004,0.2]),gate,doneAction:2);
		var enf = EnvGen.ar(Env([1600,5600,800,250],[0.001,0.001,0.001],-4));
	var enf2 = EnvGen.ar(Env([1000,1600,700,200],[0.001,0.001,0.06,0.01],-4));
	sig = SinOsc.ar(tu*400)*env;
	sig =  WhiteNoise.ar(env)+sig;
	sig = RHPF.ar(sig, \hpf.kr(100)*tu, \rq2.kr(1))+sig;
	sig = sig + Mix.ar(BPF.ar(sig,[327,430],[0.5,0.5])*0.1)+WhiteNoise.ar(env)+BrownNoise.ar(env/8);
	sig = RLPF.ar(sig, \lpf.kr(11100)*tu, \rq.kr(0.5))+sig;
	sig =( Ringz.ar(WhiteNoise.ar,Mix.ar([enf2,enf*0.9,enf2*0.8]),1,0.01*env) +RLPF.ar(BrownNoise.ar(env),enf*4,1,1)+sig )*env ;
	sig = Pan2.ar(sig*env, pan, amp);
		sig = CompanderD.ar(sig*4,0.8,0.3,0.5,0.001,0.2,env);
	Out.ar(out, sig*amp);
}).add;

SynthDef(\rimnew, { arg out=0,tu=1, amp=0.01, pan=0,gate=1,rel=1;
    var sig;
    var env = EnvGen.ar(Env.perc(0.0001,rel),doneAction:2);
var frequ = EnvGen.ar(Env([1500,500,210.4],[0.001,0.01]));
    sig = SinOsc.ar(tu*frequ)*env;
    sig = Ringz.ar(sig,(30..35)*10.234*tu,1).mean;
    //sig = Pan2.ar(sig*env, pan, amp);
    Out.ar(out, sig*env*amp*0.005);
}).add;

SynthDef(\rim808, { arg out=0,tu=1, amp=0.01, pan=0,gate=1,rel=1;
	var sig;
	var env = EnvGen.ar(Env.perc(0.001,rel),doneAction:2);
	sig = SinOsc.ar(tu*400)*env;
	sig = Ringz.ar(sig,(30..35)*10.234*tu,1).mean;
	//sig = Pan2.ar(sig*env, pan, amp);
	Out.ar(out, sig*env*amp);
}).add;

/********************************************************************Snare*****************************************************************/

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
	Out.ar(out, sig*amp);
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
    Out.ar(out, sig*amp);
}).add;

SynthDef(\snare2,{arg gate = 1, amp=1, out=0;
	var env = EnvGen.ar(Env.perc(0.001,0.2),gate,doneAction:2);
	var freq = EnvGen.ar(Env([12000,100,12000],[0.01,0.01]));
	var sig = WhiteNoise.ar(env);
	sig = LPF.ar(sig,freq);
	sig = sig.tanh;
	Out.ar(out,sig );
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
    Out.ar(out, sig*amp);
}).add;

SynthDef(\junglesnare, { arg out=0,tu=1, amp=0.1, gate=1, pan=0, freq=200,kracter = 10;
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
	Out.ar(out, sig*amp);
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
	Out.ar(out, sig*amp);
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
	Out.ar(out, sig);
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
	Out.ar(out,son*env0*level);
	Out.ar(14,son*env0*level);

	}
).add;

/********************************************************************Bass*****************************************************************/

SynthDef(\bass1,{arg gate = 1, amp=1, out=0,rel=0.1,pan=0,tu=1;
    var env = EnvGen.ar(Env.adsr(0,8,1,4),gate,doneAction:2);
    var freq = EnvGen.ar(\freqenv.kr(Env([50,40],[0.1,0.3,0.3])));
    var sig = SyncSaw.ar(freq*tu,20);
    sig = BRF.ar(sig,432,1);
    sig = HPF.ar(sig,300);
    sig =sig.distort;
    Out.ar(out,sig*amp*env);
}).add;


SynthDef(\bass3,{arg gate = 1, amp=1, out=0,rel=0.1,pan=0,tu=1.54;
    var env = EnvGen.ar(Env.adsr(0,4,1,0.1),gate,doneAction:2);
    var freq = EnvGen.ar(Env([14000,50,30],[0.001,0.1,0.1]));
    var sig = LFPar.ar([tu,tu+1],SinOsc.kr([2,1]))+LFPar.ar(tu,SinOsc.kr([1,2]));
    sig = Splay.ar(sig,SinOsc.kr(0.1),1,SinOsc.kr(pan));
    Out.ar(out,sig*amp*env);
}).add;


SynthDef(\bass,{arg out=0,gate = 1 ,dis = 0.5,freq=60,tu = 1,amp=1,atf = 80, rel =1;
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
    Out.ar(out,sig * amp);
}).add;