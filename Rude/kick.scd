(
// acid kick
// lfsaw + rlpf with dropping env in filter freq
SynthDef(\bigkick, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var env1, env2, env3, env4, env5, env6, env7, env8;
	env1 = EnvGen.ar(Env([1101,60,55],[0.001,0.1]), 1);
	sig = LFSaw.ar(freq);
	sig = RLPF.ar(sig, env1, \rq.kr(0.01));
	sig = sig / 2;
	sig = sig * EnvGen.ar(Env.adsr(0.001,0.1,0.8,0.1),gate,doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;

Pdef(\bigkick, Pbind(
	\instrument, \bigkick,
	\degree, Pseq([0],inf),
	\sustain, 0.1,
	\dur, 1,
	\amp, 0.1
)).play;
);

(
// acid kick
// very small rq variation
// add a compander to shape overblowing
SynthDef(\bigkick, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
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
	Out.ar(out, sig);
}).add;
);

(
Pdef(\bigkick, Pbind(
	\instrument, \bigkick,
	\degree, Pseq([0],inf),
	\sustain, 0.1,
	\dur, 1,
	\amp, 0.1
)).play;
);

///

// stolen from sccode
(
SynthDef (\sc303 , {  arg  out=0, freq=440, wave=0, ctf=100, res=0.2,
		sus=0, dec=1.0, env=1000, gate=1, vol=0.1;
		var  filEnv, volEnv, waves;
		volEnv =  EnvGen .ar( Env .new([10e-10, 1, 1, 10e-10], [0.01, sus, dec],  'exp' ), gate, doneAction:2)-10e-10;
		filEnv =  EnvGen .ar( Env .new([10e-10, 1, 10e-10], [0.01, dec],  'exp' ), gate)-10e-10;
		waves = [ Saw .ar(freq),  Pulse .ar(freq, 0.5)];
		Out .ar(out,  RLPF .ar(  SelectX .ar(wave, waves), ctf + (filEnv * env), res).dup * vol * volEnv);
}).add;
)

(
Pdef(\demo, Pdef(\zed, 
	Ppar([
		Pdef(\303, 
			Pbind(
				\instrument, \sc303,
				\dur, 1,
				\amp, 0.1,
			),
		),
		
	])
)).play;
)

WindowDef(\PdefEditor).front(Pdef(\303))
