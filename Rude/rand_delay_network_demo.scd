(
SynthDef(\snapkick, { |out = 0, pan = 0, amp = 0.3|
	var body, bodyFreq, bodyAmp;
	var pop, popFreq, popAmp;
	var click, clickAmp;
	var snd;

	// body starts midrange, quickly drops down to low freqs, and trails off
	bodyFreq = EnvGen.ar(Env([261, 120, 51], [0.035, 0.08], curve: \exp));
	bodyAmp = EnvGen.ar(Env.linen(0.005, 0.1, 0.3), doneAction: 2);
	body = SinOsc.ar(bodyFreq) * bodyAmp;
	// pop sweeps over the midrange
	popFreq = XLine.kr(750, 261, 0.02);
	popAmp = EnvGen.ar(Env.linen(0.001, 0.02, 0.001)) * 0.15;
	pop = SinOsc.ar(popFreq) * popAmp;
	// click is spectrally rich, covering the high-freq range
	// you can use Formant, FM, noise, whatever
	clickAmp = EnvGen.ar(Env.perc(0.001, 0.01)) * 0.15;
	click = LPF.ar(Formant.ar(910, 4760, 2110), 3140) * clickAmp;

	snd = body + pop + click;
	snd = snd.tanh;

	Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;
)

~bus = Bus.audio(s, 2); // make an audio bus

RandDelayNetwork(\default).make(\rdn1, "5-K8CM-BKGC", ~bus); // generate new grah each time this line is run.
	// \rdn1 is the Ndef name,
	// "4--" is the seed code used to generate the graph, here 4 mean grow the graph four times. since there is no code provided, it is generated randomly

RandDelayNetwork(\default).code; // this give the code of the last generated graph, for example : "4-P404-9N9U"

Ndef(\rdn1).edit; // edit the args of the Ndef in real time. important params are fb (feedback factor), delay, delay2, distamp, fbdistamp.
	// shift and pitchmix should be 0 to produce stable sound
	// fbdistmix should be like 0.95 to let some unsatured sound in feedback


// test a kick sent to the fx
(
Pdef(\zed,
	Pbind(
		\instrument, \snapkick,
		\dur, Pseq([1,3/2], inf),
		\amp, 0.7,
		\out, ~bus
	),
).play;
Pdef(\bit,
	Pbind(
		\instrument, \IkedaBreath,
		\dur, Pseq([3/2,3/4], inf),
		\amp, 1,
		\out, ~bus
	),
).play;
Pdef(\nib,
	Pbind(
		\instrument, \IkedaHiNoise,
		\dur, Pseq([1/4,1/8,1/2], inf),
		\amp, 0.06,
		\out, ~bus
	),
).play;
Pdef(\fes,
	Pbind(
		\instrument, \IkedaBass,
		\dur, Pseq([3/4,1], inf),
		\amp, 0.8,
		\out, ~bus
	),
).play;
Pdef(\cli,
	Pbind(
		\instrument, \IkedaClick,
		\dur, Pseq([1/8,1/4], inf),
		\amp, Pseq([1,0.5,0.8,0.3,0.9]*8, inf),
		\out, ~bus
	),
).play;
);

Pdef(\nib).pause;
Pdef(\nib).resume;

Pdef(\zed).pause;
Pdef(\zed).resume;

Pdef(\cli).pause;
Pdef(\cli).resume;