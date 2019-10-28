s.boot;

(
s.options.device = "Built-in Microph";
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;
s.options.memSize = 2.pow(20);
s.reboot;
s.meter;
)

(
SynthDef.new(\mic, {
	arg in = 0, out = 0, amp = 1;
	var sig;
	sig = SoundIn.ar(in!2) * amp;
	Out.ar(out, sig);
}).add;

SynthDef.new(\delay, {
	arg in = 0, out = 0, amp = 1, mix = -0.5, decay = 3, delHz = 0.25, delMin = 0.1, delMax = 0.4;
	var sig, delay;
	sig = In.ar(in, 2);
	delay = CombL.ar(
		sig,
		0.5,
		SinOsc.kr([delHz,delHz*0.9]).exprange(delMin,delMax),
		decay
	);
	sig = XFade2.ar(sig, delay, mix) * amp;
	Out.ar(out, sig);
}).add;
)

~delBus = Bus.audio(s, 2);

(
~micGrp = Group.new;
~delGrp = Group.after(~micGrp);

~micSynthDirect = Synth(\mic, [\in, 0, \out, 0], ~micGrp);
~micSynthEffect = Synth(\mic, [\in, 0, \out, ~delBus], ~micGrp);
6.do({
	Synth(\delay, [
		\in, ~delBus,
		\out, 0,
		\mix, 1,
		\amp, 1/6,
		\delHz, exprand(0.02,0.08),
		\delMin, exprand(0.05,0.1),
		\delMax, exprand(0.101,0.2),
		\decay, rrand(3.0,6.0),
	], ~delGrp);
})
)

s.freeAll;