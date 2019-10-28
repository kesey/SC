s.plotTree;

(
d = Dictionary.new;
d.add(\l ->
PathName("D:/Sons/Battery 3 artist Kit sounds/Dobie Kit Samples").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
    });
);
d.add(\m ->
PathName("D:/Sons/Battery 3 artist Kit sounds/Fiasco Kit Samples").entries.collect({
arg sf;
Buffer.read(s, sf.fullPath);
});
);
d.add(\h ->
PathName("D:/Sons/Battery 3 artist Kit sounds/Pete Davis Kit Samples").entries.collect({
arg sf;
Buffer.read(s, sf.fullPath);
});
);
)

d[\h ].choose.play;

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
	sig = PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate, doneAction:2);
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
		\dur, Pwhite(0.05, 0.5, inf),
		\midinote, Pseq([33], inf).trace,
		\harmonic, Pexprand(1, 80, inf).round,
		\atk, Pwhite(2, 3, inf),
		\rel, Pwhite(5, 10.3, inf),
		\amp, Pkey(\harmonic).reciprocal * 0.3,
		\pan, Pwhite(-0.8, 0.8, inf)
    );
).play;
)

(
Pdef(
	\rythmpat,
    Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 60/128 * 4,
		\buf, Pxrand(d[\l]++d[\m]++d[\h], inf),
		\rate, 1,
		\amp, 0.5,
    );
).play;
)