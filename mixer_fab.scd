/************************************************************************Mixer*******************************************************************/
(
~aux1 = Bus.audio(s, 2);
~aux2 = Bus.audio(s, 2);

SynthDef(\ChannelStrip, { arg in = 0, out = 0, pan = 0, hpfreq = 20, band1freq = 80, band1rq = 1, band1db = 0, band2freq = 1200, band2rq = 1, band2db = 0, band3freq = 8000, band3rq = 1, band3db = 0, lpfreq = 20000, auxsend1 = 0, auxsend2 = 0, level = 0.5;
	var input, sig;
	input = InFeedback.ar(in, 2);
	sig = BHiPass.ar(input, hpfreq.max(20).min(20000)); // HPF
	sig = BPeakEQ.ar(sig, band1freq.max(20).min(20000), band1rq, band1db); // Band 1
	sig = BPeakEQ.ar(sig, band2freq.max(20).min(20000), band2rq, band2db); // Band 2
	sig = BPeakEQ.ar(sig, band3freq.max(20).min(20000), band3rq, band3db); // Band 3
	sig = BLowPass.ar(sig, lpfreq.max(20).min(20000)); // LPF
	Out.ar(~aux1, sig * auxsend1); //aux 1 pre fader / post eq
	Out.ar(~aux2, sig * auxsend2); //aux 2 pre fader / post eq
	Out.ar(out, Balance2.ar(sig[0], sig[1], pan, level.curvelin(0, 1, 0, 1, log(10)))); // curvelin(blabla) to have a logarithmic scale
}).add;

SynthDef(\MasterStrip, { arg in = 0, out = 0, hpfreq = 20, lpfreq = 20000, level = 0.5;
	var input, sig;
	input = In.ar(in, 2);
	sig = BHiPass.ar(input, hpfreq.max(20).min(20000)); // HPF
	sig = BLowPass.ar(sig, lpfreq.max(20).min(20000)); // LPF
	Out.ar(out, sig * level.curvelin(0, 1, 0, 1, log(10)));
}).add;

/**********************************************************************Sounds & Fx***************************************************************/

SynthDef(\IkedaClick, { arg out = 0, t_trig = 0, centerFreq = 15000, rq = 0.9, amp = 25, pan = 0, level = 1;
	var env, noise, sig;
	env = EnvGen.ar(Env.perc(0.001, 0.00001 * LFNoise1.kr(4).abs, 1, -4), t_trig, doneAction: 2);
	noise = PinkNoise.ar(env);
	sig = BPF.ar(noise, centerFreq.max(1), rq, amp).fold(-1, 1);
	Out.ar(out, Pan2.ar(sig, pan, level.curvelin(0, 1, 0, 1, log(10))));
}).add;

SynthDef(\IkedaBass, { arg out = 0, t_trig = 0, pan = 0, level = 1;
	var env, sin, sig;
	env = EnvGen.ar(Env(#[0, 0.5, 0.4, 0], #[0, 0.2, 0.01], -5), t_trig, doneAction: 2);
	sin = SinOsc.ar(0, (Sweep.ar(t_trig, 2pi * [52.8, 740]) + (pi/3)).wrap(-pi, pi), #[2, 0.05]).mean.tanh;
	sig = sin * env;
	Out.ar(out, Pan2.ar(sig, pan, level.curvelin(0, 1, 0, 1, log(10))));
}).add;

SynthDef(\Reverb, {arg in = 0, out = 0, predelaytime = 0.048, decaytimec = 5, decaytimea = 1, drywet = 0.5, level = 0.2;
	var input, numc, numa, temp;
	input = In.ar(in, 2);
	numc = 4; // number of comb delays
	numa = 6; // number of allpass delays
	temp = DelayN.ar(input, 0.1, predelaytime);
	temp = Mix.fill(numc, { CombL.ar(temp, 0.1, rrand(0.01, 0.1), decaytimec) });
	numa.do({ temp = AllpassN.ar(temp, 0.051, [rrand(0.01, 0.05), rrand(0.01, 0.05)], decaytimea) });
	XOut.ar(out, drywet, temp * level.curvelin(0, 1, 0, 1, log(10)));
}).add;

SynthDef(\SimpleDelay, { arg in = 0, out = 0, delaytime = 0.1;
	var input, effect;
	input = In.ar(in, 2);
	effect = DelayN.ar(input, 1, delaytime);
	ReplaceOut.ar(out, effect); // overwriting previous data on the corresponding bus
}).add;
)
/**********************************************************************Routing*******************************************************************/
(
var channel1, channel2, channel3, channel4, masterBus;

channel1 = Bus.audio(s, 2);
channel2 = Bus.audio(s, 2);
channel3 = Bus.audio(s, 2);
channel4 = Bus.audio(s, 2);
masterBus = Bus.audio(s, 2);

n = 180; // Tempo in beat per minutes
TempoClock.default.tempo = n/60; // TempoClock in beat per seconds
t = TempoClock(n*2/60); // Another TempoClock twice as fast as the TempoClock default

Pdefn(\dur1, Pseq(#[1,0.5], inf));
Pdefn(\amp1, Pseq(#[5,3.15], inf));
Pdefn(\dur2, Pseq(#[2,0.75,2], inf));

Pdef(\Click,
	Pbind(
		\instrument, \IkedaClick,
		\amp, Pdefn(\amp1).dbamp, // 0.2.coin; // probability of true: 20%
		\dur, Pdefn(\dur1), // Pwrand(#[2,1,\rest,2,1], #[1,3,2,2,3].normalizeSum, inf); // chooses values according to a list of probabilities/weights
		\out, channel1
	)
).play(); // use the TempoClock default
Pdef(\Bass,
	Pbind(
		\instrument, \IkedaBass,
		\level, 6,
		\dur, Pdefn(\dur2), // Pif(0.1.loop.coin, Pseq([Rest(), 7], inf), Pseries(0, 1, inf))
		\out, channel2
	)
).play();
~reverb = Synth(\Reverb, [\in, ~aux1, \out, channel3]);
~simpleDelay = Synth(\SimpleDelay, [\in, ~aux2, \out, channel4]);

~channel1 = Synth(\ChannelStrip, [\in, channel1, \out, masterBus]);
~channel2 = Synth(\ChannelStrip, [\in, channel2, \out, masterBus]);
~channel3 = Synth(\ChannelStrip, [\in, channel3, \out, masterBus]);
~channel4 = Synth(\ChannelStrip, [\in, channel4, \out, masterBus]);
~masterBus = Synth(\MasterStrip, [\in, masterBus], addAction: 'addToTail');
)

// Mixer actions
// Channel 1 = Click
~channel1.set(\auxsend1, 0.5); // aux 1 => Reverb
~channel1.set(\auxsend1, 0);

~channel1.set(\auxsend2, 0.6); // aux 2 => Delay
~channel1.set(\auxsend2, 0);

// Channel 2 = Bass
~channel2.set(\auxsend1, 0.7); // aux 1 => Reverb
~channel2.set(\auxsend1, 0);

~channel2.set(\auxsend2, 0.4); // aux 2 => Delay
~channel2.set(\auxsend2, 0);

// Channel 3 = Reverb
~channel3.set(\auxsend1, 0.05); // aux 1 => Reverb
~channel3.set(\auxsend1, 0);

~channel3.set(\auxsend2, 0.5); // aux 2 => Delay
~channel3.set(\auxsend2, 0);

// Channel 4 = Delay
~channel4.set(\auxsend1, 0.5); // aux 1 => Reverb
~channel4.set(\auxsend1, 0);

~channel4.set(\auxsend2, 1); // aux 2 => Delay
~channel4.set(\auxsend2, 0);

// Master
~masterBus.set(\hpfreq, 20, \lpfreq, 200);
~masterBus.set(\hpfreq, 20, \lpfreq, 20000);

Pdef(\Click).play;
Pdef(\Click).stop;
Pdef(\Bass).play;
Pdef(\Bass).stop;
Pbindef(\Click,\dur,Pseq(#[0.5, 0.5, 0.5, 0.85], inf),\amp,3.dbamp);

/************************************************************************GUI*********************************************************************/

(
var channel, hpfreq, band1freq, band1rq, band1db, band2freq, band2rq, band2db, band3freq, band3rq, band3db, lpfreq;
w = Window("Mixer",Rect(0, 0, 800, 600));
w.front;
w.alwaysOnTop_(true);
w.view.decorator = FlowLayout(w.view.bounds, 3@3, 3@3);
channel = CompositeView(w, 100@400).background_(Color.white);
channel.decorator_(FlowLayout(channel.bounds, 32@3, 3@3));
hpfreq = EZKnob(channel, 50@60, 'hpf', ControlSpec(20, 20000, step: 1, default: 20, unit: 'hz'), { arg hpfreq; ~channel1.set(\hpfreq, hpfreq.value); }, labelWidth: 50, unitWidth: 60);
band1freq = EZKnob(channel, 50@60, 'band1freq', ControlSpec(20, 20000, step: 1, default: 80, unit: 'hz'), { arg band1freq; ~channel1.set(\band1freq, band1freq.value); }, labelWidth: 50, unitWidth: 40);
band1rq = EZKnob(channel, 30@70, 'band1rq', ControlSpec(0, 1, step: 0.01, default: 1), { arg band1rq; ~channel1.set(\band1rq, band1rq.value); });
band1db = EZKnob(channel, 30@70, 'band1db', ControlSpec(0, 1, step: 0.01, default: 0, unit: 'db'), { arg band1rq; ~channel1.set(\band1rq, band1rq.value); });
)

