/************************************************************************Mixer*******************************************************************/
(
/*this.executeFile(PathName(thisProcess.nowExecutingPath).parentPath ++ "SetUp.scd");
this.executeFile(PathName(thisProcess.nowExecutingPath).parentPath ++ "SynthDef.scd");*/

~aux1 = Bus.audio(s, 2);
~aux2 = Bus.audio(s, 2);

~channelStripArg = SynthDef(\ChannelStrip, { arg in = 0, out = 0, pan = 0, hpfreq = 20, band1freq = 80, band1rq = 1, band1db = 0, band2freq = 1200, band2rq = 1, band2db = 0, band3freq = 8000, band3rq = 1, band3db = 0, lpfreq = 20000, auxsend1 = 0, auxsend2 = 0, level = 0.5;
	var input, sig;
	input = InFeedback.ar(in, 2);
	sig = BHiPass.ar(input, Lag2.kr(hpfreq.max(20).min(20000), 0.5)); // HPF
	sig = BPeakEQ.ar(sig, Lag2.kr(band1freq.max(20).min(20000), 0.5), band1rq, band1db); // Band 1
	sig = BPeakEQ.ar(sig, Lag2.kr(band2freq.max(20).min(20000), 0.5), band2rq, band2db); // Band 2
	sig = BPeakEQ.ar(sig, Lag2.kr(band3freq.max(20).min(20000), 0.5), band3rq, band3db); // Band 3
	sig = BLowPass.ar(sig, Lag2.kr(lpfreq.max(20).min(20000), 0.5)); // LPF
	Out.ar(~aux1, sig * auxsend1); //aux 1 pre fader / post eq
	Out.ar(~aux2, sig * auxsend2); //aux 2 pre fader / post eq
	Out.ar(out, Balance2.ar(sig[0], sig[1], pan, level.curvelin(0, 1, 0, 1, log(10)))); // curvelin(blabla) to have a logarithmic scale
}).add.allControlNames;
//~channelStripArg.size.postln;

SynthDef(\MasterStrip, { arg in = 0, out = 0, hpfreq = 20, lpfreq = 20000, level = 0.5;
	var input, sig;
	input = In.ar(in, 2);
	sig = BHiPass.ar(input, Lag2.kr(hpfreq.max(20).min(20000), 0.5)); // HPF
	sig = BLowPass.ar(sig, Lag2.kr(lpfreq.max(20).min(20000), 0.5)); // LPF
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
var channel, masterBus;

masterBus = Bus.audio(s, 2);
~masterBus = Synth(\MasterStrip, [\in, masterBus], addAction: 'addToTail');

~channelNumber = 4; // number of channels
channel = Array.newClear(~channelNumber);
~channelNumber.do {
	arg i;
	channel[i] = Bus.audio(s, 2);
	currentEnvironment.put((\channel ++ i).asSymbol, Synth(\ChannelStrip, [\in, channel[i], \out, masterBus]));
};

n = 180; // Tempo in beat per minutes
TempoClock.default.tempo = n / 60; // TempoClock in beat per seconds
t = TempoClock((n * 2) / 60); // Another TempoClock twice as fast as the TempoClock default

Pdefn(\dur1, Pseq(#[1,0.5], inf));
Pdefn(\amp1, Pseq(#[5,3.15], inf));
Pdefn(\dur2, Pseq(#[2,0.75,2], inf));

Pdef(\Click,
	Pbind(
		\instrument, \IkedaClick,
		\amp, Pdefn(\amp1).dbamp, // 0.2.coin; // probability of true: 20%
		\dur, Pdefn(\dur1), // Pwrand(#[2,1,\rest,2,1], #[1,3,2,2,3].normalizeSum, inf); // chooses values according to a list of probabilities/weights
		\out, channel[0]
	)
).play(); // use the TempoClock default if .play(t) use the TempoClock twice as fast as the TempoClock default

Pdef(\Bass,
	Pbind(
		\instrument, \IkedaBass,
		\level, 6,
		\dur, Pdefn(\dur2), // Pif(0.1.loop.coin, Pseq([Rest(), 7], inf), Pseries(0, 1, inf))
		\out, channel[1]
	)
).play();

~reverb = Synth(\Reverb, [\in, ~aux1, \out, channel[2]], ~masterBus, 'addBefore');
~simpleDelay = Synth(\SimpleDelay, [\in, ~aux2, \out, channel[3]], ~masterBus, 'addBefore');
)

// Mixer actions
// Channel 0 = Click
~channel0.set(\auxsend1, 0.8, \level, 1); // aux 1 => Reverb
~channel0.set(\auxsend1, 0);
~channel0.set(\band3freq, 900, \band3rq, 0.2, \band3db, 0);

~channel0.set(\auxsend2, 0.9); // aux 2 => Delay
~channel0.set(\auxsend2, 0);

// Channel 1 = Bass
~channel1.set(\auxsend1, 0.7, \level, 1); // aux 1 => Reverb
~channel1.set(\auxsend1, 0);

~channel1.set(\auxsend2, 0.4); // aux 2 => Delay
~channel1.set(\auxsend2, 0);

// Channel 2 = Reverb
~channel2.set(\auxsend1, 0.5); // aux 1 => Reverb
~channel2.set(\auxsend1, 0);

~channel2.set(\auxsend2, 0.5); // aux 2 => Delay
~channel2.set(\auxsend2, 0);

// Channel 3 = Delay
~channel3.set(\auxsend1, 0.7); // aux 1 => Reverb
~channel3.set(\auxsend1, 0);

~channel3.set(\auxsend2, 0.9); // aux 2 => Delay
~channel3.set(\auxsend2, 0);

// Master
~masterBus.set(\hpfreq, 20, \lpfreq, 200);
~masterBus.set(\hpfreq, 20, \lpfreq, 20000, \level, 1);

Pdef(\Click).play;
Pdef(\Click).stop;
Pdef(\Bass).play;
Pdef(\Bass).stop;
Pbindef(\Click,\dur,Pseq(#[0.5, 0.5, 0.5, 0.85], inf),\amp,3.dbamp);
// Pbindef(\Click,\instrument, \IkedaBass);

/************************************************************************GUI*********************************************************************/

MIDIClient.init; // post a list of available devices
MIDIIn.connectAll; // connect to all attached input sources
// this.executeFile(PathName(thisProcess.nowExecutingPath).parentPath ++ "GUI.scd");
(
var channel, channelMaster, ccStart;

~ccStart = 21; // start mapping midi cc from here
~ccStart = ~ccStart - 1;
channel = IdentityDictionary.new;

w = Window("Mixer",Rect(0, 0, 800, 690), scroll: true);
w.front;
//w.alwaysOnTop_(true);
w.view.decorator = FlowLayout(w.view.bounds, 3@3, 3@3);

~channelNumber.do {
	arg i;
	channel[\channelView] = CompositeView(w, 118@685);
	channel[\channelView].background_(Color.white);
	channel[\channelView].decorator_(FlowLayout(channel[\channelView].bounds, 3@3, 3@3));

	// Channel name
	StaticText(channel[\channelView], 100@10)
	    .string_("Channel " ++ i)
	    .stringColor_(Color.black)
	    .align_(\center);
	channel[\channelView].decorator.nextLine;

	// hpf
	channel[(\hpfreq ++ i).asSymbol] = EZKnob(channel[\channelView], 112@70, 'hpfreq', ControlSpec(20, 20000, step: 1, default: 20, units: 'hz'), { arg hpfreq; currentEnvironment.at((\channel ++ i).asSymbol).set(\hpfreq, hpfreq.value); }, margin: 39@0);
	channel[\channelView].decorator.nextLine;

	// hpf midi map
	~ccStart = ~ccStart + 1;
	channel[(\activeSoftTakeOver ++ i).asSymbol] = false;
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, treshold;
		midiControl = val.linlin(0, 127, 20, 20000);
		guiControl = knob.value;
		treshold = 500;
		if ( // soft takeover
			(channel[(\activeSoftTakeOver ++ i).asSymbol] or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
			{
				channel[(\activeSoftTakeOver ++ i).asSymbol] = true;
				{ knob.valueAction_(midiControl); }.defer;
			}
		);
	}, ~ccStart, 0, 0);
	(~ccStart).debug("Channel " ++ i ++ " hpfreq cc number");

	// band 1
	channel[(\band1freq ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'freq1', ControlSpec(20, 20000, step: 1, default: 80, units: 'hz'), { arg band1freq; currentEnvironment.at((\channel ++ i).asSymbol).set(\band1freq, band1freq.value); });

	channel[(\band1rq ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'rq1', ControlSpec(0, 1, step: 0.01, default: 1), { arg band1rq; currentEnvironment.at((\channel ++ i).asSymbol).set(\band1rq, band1rq.value); });

	channel[(\band1db ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'db1', ControlSpec(0, 60, step: 1, default: 0, units: 'db'), { arg band1db; currentEnvironment.at((\channel ++ i).asSymbol).set(\band1db, band1db.value); });

	// band 2
	channel[(\band2freq ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'freq2', ControlSpec(20, 20000, step: 1, default: 1200, units: 'hz'), { arg band2freq; currentEnvironment.at((\channel ++ i).asSymbol).set(\band2freq, band2freq.value); });

	channel[(\band2rq ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'rq2', ControlSpec(0, 1, step: 0.01, default: 1), { arg band2rq; currentEnvironment.at((\channel ++ i).asSymbol).set(\band2rq, band2rq.value); });

	channel[(\band2db ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'db2', ControlSpec(0, 60, step: 1, default: 0, units: 'db'), { arg band2db; currentEnvironment.at((\channel ++ i).asSymbol).set(\band2db, band2db.value); });

	// band 3
	channel[(\band3freq ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'freq3', ControlSpec(20, 20000, step: 1, default: 8000, units: 'hz'), { arg band3freq; currentEnvironment.at((\channel ++ i).asSymbol).set(\band3freq, band3freq.value); });

	channel[(\band3rq ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'rq3', ControlSpec(0, 1, step: 0.01, default: 1), { arg band3rq; currentEnvironment.at((\channel ++ i).asSymbol).set(\band3rq, band3rq.value); });

	channel[(\band3db ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'db3', ControlSpec(0, 60, step: 1, default: 0, units: 'db'), { arg band3db; currentEnvironment.at((\channel ++ i).asSymbol).set(\band3db, band3db.value); });

	// lpf
	channel[(\lpfreq ++ i).asSymbol] = EZKnob(channel[\channelView], 112@70, 'lpfreq', ControlSpec(20, 20000, step: 1, default: 20000, units: 'hz'), { arg lpfreq; currentEnvironment.at((\channel ++ i).asSymbol).set(\lpfreq, lpfreq.value); }, margin: 39@0);
	channel[\channelView].decorator.nextLine;

	// aux 1
	channel[(\aux1 ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'aux1', ControlSpec(0, 1, step: 0.01, default: 0), { arg aux1; currentEnvironment.at((\channel ++ i).asSymbol).set(\auxsend1, aux1.value); });

	StaticText(channel[\channelView], 35@65)
	    .string_("Send")
	    .align_(\center);

	// aux 2
	channel[(\aux2 ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'aux2', ControlSpec(0, 1, step: 0.01, default: 0), { arg aux2; currentEnvironment.at((\channel ++ i).asSymbol).set(\auxsend2, aux2.value); });

	// pan
	channel[(\pan ++ i).asSymbol] = EZSlider(channel[\channelView], 112@60, 'pan', ControlSpec(-1, 1, step: 0.01, default: 0), { arg pan; currentEnvironment.at((\channel ++ i).asSymbol).set(\pan, pan.value); }, layout: 'vert');
	channel[\channelView].decorator.nextLine;

	// level
	channel[(\level ++ i).asSymbol] = EZSlider(channel[\channelView], 112@160, 'level', ControlSpec(0, 1, step: 0.01, default: 0.5), { arg level; currentEnvironment.at((\channel ++ i).asSymbol).set(\level, level.value); }, layout: 'vert', margin: 39@0);
};

channelMaster = CompositeView(w, 118@350);
channelMaster.background_(Color.grey);
channelMaster.decorator_(FlowLayout(channelMaster.bounds, 3@3, 3@3));

// Channel name
StaticText(channelMaster, 100@10)
	.string_("Master")
	.stringColor_(Color.white)
	.align_(\center);
channelMaster.decorator.nextLine;

// hpf
channel[\hpfreqMaster] = EZKnob(channelMaster, 112@70, 'hpfreq', ControlSpec(20, 20000, step: 1, default: 20, units: 'hz'), { arg hpfreq; ~masterBus.set(\hpfreq, hpfreq.value); }, margin: 39@0).setColors(stringColor: Color.white);
	channelMaster.decorator.nextLine;

// lpf
channel[\lpfreqMaster] = EZKnob(channelMaster, 112@70, 'lpfreq', ControlSpec(20, 20000, step: 1, default: 20000, units: 'hz'), { arg lpfreq; ~masterBus.set(\lpfreq, lpfreq.value); }, margin: 39@0).setColors(stringColor: Color.white);
	channelMaster.decorator.nextLine;

// level
channel[\levelMaster] = EZSlider(channelMaster, 112@160, 'level', ControlSpec(0, 1, step: 0.01, default: 0.5), { arg level; ~masterBus.set(\level, level.value); }, layout: 'vert', margin: 39@0).setColors(stringColor: Color.white);
)
