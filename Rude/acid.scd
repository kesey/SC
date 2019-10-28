
// the rand find the right spot, just have to catch it
(
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
Pdef(\demo).reset;
);

(
Pdef(\demo, Pdef(\demomo,
	Ppar([
		Pmono(
			 \acidtry,
			\note, Pseq([
				0,3,5,-1,
				0,3,2,-1,
			],inf),
			\ttrig, 1,
			\dur, 1/8,
			\amp, 0.1,
		),

	])
)).play;
)


/////////////////

(
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
);


// good!
(
Pdef(\demo, Pdef(\xdemo,
	Ppar([
		Pbind(
			\instrument, \acidtry2,
			\note, Pseq([
				3,-4,2,-3,
			],inf),
			/*\ffat, ~pmodenv.(Prand([0.41,0.2,0.1,0.4]/13,inf), 8),
			\ffrel, ~pmodenv.(Pseq([0.41,0.2,0.1,0.4],inf), 8),
			\ffscale, ~pmodenv.(Pseq([700,2000,100],inf), 3),
			\lpfr, ~pmodenv.(Pseq([1,1/2,2,1/4],inf), 7),*/
			\oct, Pseq([
				1/2,1/4,3/5,7/9,4/7,
			],inf),
			\distgain, 0.4,
			\octave, 3,
			\legaot, 0.1,
			\dur, 1/8,
			\amp, 0.1,
		),
	])
)).play;
)

(
Pdef(\demo, Pdef(\xdemo,
	Ppar([
		Pbind(
			\instrument, \acidtry2,
			\note, Pseq([
				3,-4,2,-3,
			],inf),
			/*\ffat, ~pmodenv.(Prand([0.41,0.2,0.1,0.4]/13,inf), 8),
			\ffrel, ~pmodenv.(Pseq([0.41,0.2,0.1,0.4],inf), 8),
			\ffscale, ~pmodenv.(Pseq([9700,2000,100,12000,8000],inf), 3),
			\lpfr, ~pmodenv.(Pseq([1,1/2,2,1/4],inf), 7),*/
			\oct, Pseq([
				1/2,1/4,3/5,7/9,4/7,
			],inf),
			\distgain, 0.4,
			\octave, 3,
			\legaot, 0.1,
			\dur, 1/8,
			\amp, 0.1,
		),
	])
)).play;
)

(
Pdef(\demo, Pdef(\xdemo,
	Ppar([
		Pbind(
			\instrument, \acidtry2,
			\note, Pseq([
				3,-4,2,-3,
			],inf),
			\ffat, Pseq([
				0.2,0.1,
			],inf),
			\ffrel, Pseq([
				0.1,0.6,
				0.01,0.3,
			],inf),
			/*\ffscale, ~pmodenv.(Pseq([9700,2000,100,1200,8000],inf), 1/4),
			\lpfr, ~pmodenv.(Pseq([1,1/2,2,1/4],inf), 3/4),*/
			\oct, Pseq([
				Pseq([
					1/2,3/4,
				],8),
				Pseq([
					3/5,7/9,4/7,
				],inf).stutter(4),
			],inf),
			\distgain, 0.4,
			\octave, 3,
			\legaot, 0.1,
			\dur, 1/8,
			\amp, 0.1,
		),
	])
)).play;
)

(
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
);

(
Pdef(\demo, Pdef(\xdemo,
	Ppar([
		Pmono(
			 \trigacidtry2,
			\note, Pseq([
				0,2,5,1,
			],inf),
			/*\ffat, ~pmodenv.(Prand([0.41,0.2,0.1,0.4]/13,inf), 8),
			\ffrel, ~pmodenv.(Pseq([0.41,0.2,0.1,0.4],inf), 8),
			\ffscale, ~pmodenv.(Pseq([700,2000,100],inf), 3),
			\lpfr, ~pmodenv.(Pseq([1,1/2,2,1/4],inf), 7),*/
			\xtrig, 1,
			\distgain, 0.9,
			\octave, 3,
			\legaot, 0.1,
			\dur, 1/4,
			\amp, 0.1,
		),
	])
)).play;
)

(
Pdef(\demo, Pdef(\xdemo,
	Ppar([
		Pmono(
			 \trigacidtry2,
			\note, Pseq([
				0,2,5,1,
			],inf),
			/*\wave, ~pmodenv.(Prand([0.41,1,0.1,0.8],inf), 8),
			\ffat, ~pmodenv.(Prand([0.41,0.2,0.1,0.4]/13,inf), 8),
			\ffrel, ~pmodenv.(Pseq([0.41,0.2,0.1,0.4],inf), 8),
			\ffscale, ~pmodenv.(Pseq([10000,700,2000,100],inf), 3),
			\lpfr, ~pmodenv.(Pseq([1,1/2,2,1/4],inf), 7),*/
			\oct, Pseq([
				0.1,0.5,0.7,
			],inf),
			\xtrig, 1,
			//\rq, ~pmodenv.(Pseq([0.1,0.02,0.31],inf), 2.9),
			\distgain, 0.9,
			\octave, 4,
			\legaot, 0.1,
			\dur, 1/4,
			\amp, 0.2,
		),
	])
)).play;
)

(
Pdef(\demo, Pdef(\xdemo,
	Ppar([
		Pmono(
			 \trigacidtry2,
			\note, Pseq([
				0,2,5,1,
			],inf),
			/*\wave, ~pmodenv.(Prand([0.41,1,0.1,0.8],inf), 8),
			\ffat, ~pmodenv.(Prand([0.41,0.2,0.1,0.4]/13,inf), 8),*/
			\ffrel, Pseq([
				0.01,0.5,
			],inf),
			\ffscale, Pseq([
				10000,3000,
			],inf),
			//\lpfr, ~pmodenv.(Pseq([1,1/2,2,1/4],inf), 7),
			\oct, Pseq([
				0.1,0.5,0.7,
			],inf),
			\xtrig, 1,
			//\rq, ~pmodenv.(Pseq([0.1,0.02,0.31],inf), 2.9),
			\distgain, 0.9,
			\octave, 4,
			\legaot, 0.1,
			\dur, 1/4,
			\amp, 0.2,
		),
	])
)).play;
)

(
Pdef(\demo, Pdef(\xdemo,
	Ppar([
		Pmono(
			 \trigacidtry2,
			\note, Pseq([
				0,0,0,0,
				1,0,0,0,
			],inf),
			\wave, Pseq([
				0,
			],inf),
			\ffat, Pseq([
				0.04, 0.04, 0.4,
				0.04, 0.04, 0.4,
				 0.04, 0.4,
			].rotate(1),inf),
			\ffrel, Pseq([
				0.07,
				0.07,
				0.47,
			],inf),
			\ffscale, Pseq([
				100,300,
				100,300,
				7000,9000,
			],inf),
			\lpfr, Pseq([
				2,
			],inf),
			\oct, Pseq([
				0.1,0.5,0.1,
			],inf),
			\xtrig, 1,
			\rq, Pseq([
				0.1,0.2,
				0.1,0.2,
				0.1,0.2,
				0.01,0.2,
			],inf),
			\distgain, 0.9,
			\octave, 4,
			\legaot, 0.1,
			\dur, 1/8,
			\amp, 0.2,
		),
	])
)).play;
)


(
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
Pdef(\demo).reset;
);

(
Pdef(\demo, Pdef(\xdemo,
	Ppar([
		Pmono(
			 \trigacidtry3,
			\note, Pseq([
				0,0,0,0,
				1,4,4,4,
				0,0,0,0,
				0,2,2,2,
				0,0,1,0,
				0,1,0,3,
			],inf),
			\wave, Pseq([
				1,0.5,0.1,0.9
			],inf).stutter(4),
			\fmamp, Pseq([
				0,0,0,0,
				0,0.01,0.1,0.2,
			],inf),
			\fmf, Pseq([
				1, 1, 1, 1,
				1, 1000,2000,5000,
			],inf),
			\width, Pseq([
				0.1,0.4,0.9,
			],inf),
			\ffat, Pseq([
				0.02,
			].rotate(1),inf),
			\ffrel, Pseq([
				0.17,
				0.47,
			],inf).stutter(8),
			\ffscale, Pseq([
				700,9000,
				400,12000,
				7000,9000,
				4000,12000,
			],inf),
			\lpfr, Pseq([
				2,
			],inf),
			\oct, Pseq([
				0.1,0.5,0.1,
			],inf),
			\xtrig, 1,
			\rq, Pseq([
				0.1,0.2,
				0.1,0.2,
				0.1,0.2,
				0.12,0.2,
			],inf),
			\rq2, Pseq([
				0.1,0.2,
				0.1/2,0.2,
				0.12,0.2,
				0.1,0.2,
				0.1,0.2,
			],inf),
			\distgain, 0.9,
			\octave, 4,
			\legaot, 0.1,
			\dur, 1/8,
			\amp, 0.2,
		),
	])
)).play;
)
