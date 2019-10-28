s.serverRunning.not.if({ s.boot });

(
SynthDef(\simpleSin, { arg out = 0, amp = 0.1, pan = 0, freq = 220, tu = 1, attack = 0.01, release = 0.1, t_gate = 1;
	var sig, env;
	env = EnvGen.kr(Env.perc(attack, release), doneAction:2);
	sig = SinOsc.ar(freq * tu, 0, env);
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;
)

(
p = Pbind(
	\instrument, \simpleSin,
	\dur, 1,
	\amp, 0.02
);

Pdef(\test1, p).play;

~controller = SimpleController(Pdef(\test1));

~controller.put(\value, { |changer, value|
	changer.debug("changer");
	value.debug("value");
	// I'd like to get the names and values of the changing keys here
	// e.g I'd like to get the new value for \tu and \attack
});
)

Pbindef(\test1, \tu, 2.0.rand, \attack, 0.89.rand).changed(\value);

~controller.removeAt(\value);