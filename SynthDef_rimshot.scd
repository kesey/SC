(

///////////////////////////////////////  Rimshot

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
	OffsetOut.ar(out, sig*amp);
}).add;

SynthDef(\rimnew, { arg out=0,tu=1, amp=0.01, pan=0,gate=1,rel=1;
    var sig;
    var env = EnvGen.ar(Env.perc(0.0001,rel),doneAction:2);
var frequ = EnvGen.ar(Env([1500,500,210.4],[0.001,0.01]));
    sig = SinOsc.ar(tu*frequ)*env;
    sig = Ringz.ar(sig,(30..35)*10.234*tu,1).mean;
    //sig = Pan2.ar(sig*env, pan, amp);
    OffsetOut.ar(out, sig*env*amp*0.005);
}).add;

SynthDef(\rim808, { arg out=0,tu=1, amp=0.01, pan=0,gate=1,rel=1;
	var sig;
	var env = EnvGen.ar(Env.perc(0.001,rel),doneAction:2);
	sig = SinOsc.ar(tu*400)*env;
	sig = Ringz.ar(sig,(30..35)*10.234*tu,1).mean;
	//sig = Pan2.ar(sig*env, pan, amp);
	OffsetOut.ar(out, sig*env*amp);
}).add;

)