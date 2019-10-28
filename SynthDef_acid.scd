(

///////////////////////////////////////  Acid

SynthDef(\acidtry, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	var ttrig = \ttrig.tr(1);
	env2 = SinOsc.kr(1/18,mul:0.2,add:1);
	env1 = EnvGen.kr(Env([1.2,1.24 * env2,0.91],[0.01,0.1]), ttrig);
	sig = LFSaw.ar(freq * [1,1.01,1.001,1/2,2]);
	sig = RLPF.ar(sig, \lpfr.kr(1.1) * SinOsc.kr(1/16,mul:0.2,add:1) * [1,1.01,1.001,2,1/2] * freq * env1, \rq.kr(0.01)* SinOsc.kr(1/16,mul:0.2,add:1));
	sig = sig / 1;
	sig = sig * EnvGen.kr(\adsr.kr(Env.adsr(0.1,0.1,0.8,0.1)), gate, doneAction:2);
	sig = Pan2.ar(sig, pan, amp).mean;
	Out.ar(out, sig);
}).add;

SynthDef(\acidtry2, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var ffenv = EnvGen.kr(Env([0,1,0],[\ffat.kr(0.05),\ffrel.kr(0.1)], 1, 1,1), gate, levelScale:\ffscale.kr(700));
	freq = freq * [1/2,1,2,];
	sig = SelectX.ar(\wave.kr(0.9),[ Saw.ar(freq),Pulse.ar(freq) ]);
	sig = SelectX.ar(\oct.kr(0.1)*2, sig);
	sig = RLPF.ar(sig, \lpfr.kr(1.1) * freq + ffenv, \rq.kr(0.1), mul:\distgain.kr(0.5)).distort;
	sig = sig * EnvGen.kr(\adsr.kr(Env.adsr(0.01,0.1,0.8,0.4,1,-1)), gate, doneAction:2);
	pan = [-0.1,0.1];
	sig = Pan2.ar(sig, pan, amp).mean;
	Out.ar(out, sig);
}).add;

SynthDef(\trigacidtry2, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var ffenv = EnvGen.kr(Env([0,1,0],[\ffat.kr(0.05),\ffrel.kr(0.1)], 1, 1,1), \xtrig.tr(1), levelScale:\ffscale.kr(700));
	freq = freq * [1/2,1,2,];
	sig = SelectX.ar(\wave.kr(0.9),[ Saw.ar(freq),Pulse.ar(freq) ]);
	sig = SelectX.ar(\oct.kr(0.1)*2, sig);
	sig = RLPF.ar(sig, \lpfr.kr(1.1) * freq + ffenv, \rq.kr(0.1), mul:\distgain.kr(0.5)).distort;
	sig = sig * EnvGen.kr(\adsr.kr(Env.adsr(0.01,0.1,0.8,0.4,1,-1)), gate, doneAction:2);
	pan = [-0.1,0.1];
	sig = Pan2.ar(sig, pan, amp).mean;
	Out.ar(out, sig);
}).add;

SynthDef(\trigacidtry3, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var ffenv = EnvGen.kr(Env([0,1,0],[\ffat.kr(0.05),\ffrel.kr(0.1)], 1, 1,1), \xtrig.tr(1), levelScale:\ffscale.kr(700));
	freq = freq * [1/2,1,2,1.01];
	freq = freq * ( SinOsc.ar( \fmf.kr(8000) ) * \fmamp.kr(0.1) + 1 );
	sig = SelectX.ar(\wave.kr(0.9),[ Saw.ar(freq),Pulse.ar(freq, \width.kr(0.5)) ]);
	sig = SelectX.ar(\oct.kr(0.1)*3, sig);
	sig = RLPF.ar(sig, \lpfr.kr(1.1) * freq + ffenv, \rq.kr(0.1), mul:\distgain.kr(0.5));
	sig = RLPF.ar(sig, \lpfr2.kr(1.1) * freq.lag(\lag2.kr(0.13)) + ffenv.lag(\lag2.kr), \rq2.kr(0.5), mul:\distgain.kr(0.5)).distort;
	sig = sig * EnvGen.kr(\adsr.kr(Env.adsr(0.01,0.1,0.8,0.4,1,-1)), gate, doneAction:2);
	pan = [-0.1,0.1];
	sig = Pan2.ar(sig, pan, amp).mean;
	Out.ar(out, sig);
}).add;

)