s.plotTree;

t = 128;

(
d = Dictionary.new;
d.add(\l ->
PathName("D:/Sons/808/808 BASSDRUM").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
    });
);
d.add(\m ->
PathName("D:/Sons/808/808 SNAREDRUM").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
	});
);
d.add(\h ->
PathName("D:/Sons/808/808 HIHATS").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
	});
);
)

d[\l].choose.play;

(
SynthDef.new (\sine, {
	arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0], [atk,rel], [1,-1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;

SynthDef.new(\bufplay, {
	arg buf=0, rate=1, amp=1;
	var sig;
	sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction:2);
	sig = sig * amp;
	Out.ar(0, sig);
}).add;
)

Synth.new(\bufplay, [\buf, d[\m].choose.bufnum]);

(
Pdef(
	\sinepat,
    Pbind(
		\instrument, \sine,
		\dur, Pseq([1/16], inf),
		\stretch, 60/t * 4,
		\midinote, Pseq([33], inf),
		\harmonic, Pexprand(1, 80, inf).round,
		\atk, Pwhite(2, 3, inf),
		\rel, Pwhite(5, 10.3, inf),
		\amp, Pkey(\harmonic).reciprocal * 0.3,
		\pan, Pwhite(-0.8, 0.8, inf)
    );
).play(quant:1.875);
)

(
Pdef(
	\rythmpat,
    Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 60/t * 4,
		\buf, Pseq(
			[
				Prand(d[\l], 1),
				Prand(d[\h]++d[\m]++d[\l], 7),
				Prand(d[\h], 1),
				Prand(d[\h]++d[\m]++d[\l], 7),
			], inf
		),
		\rate, Pexprand(0.8,1.25, inf),
		\amp, Pseq([0.21, Pexprand(0.005,0.2,7)], inf),
    );
).play(quant:1.875);
)

Pdef(\sinepat).stop;
Pdef(\rythmpat).stop;
