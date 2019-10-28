/************************************************************************Mixer*******************************************************************/
(
/*this.executeFile(PathName(thisProcess.nowExecutingPath).parentPath ++ "SetUp.scd");
this.executeFile(PathName(thisProcess.nowExecutingPath).parentPath ++ "SynthDef.scd");*/

~aux1 = Bus.audio(s, 2);
~aux2 = Bus.audio(s, 2);

~channelStrip = SynthDef(\ChannelStrip, { arg in = 0, out = 0, pan = 0, hpfreq = 20, band1freq = 80, band1rq = 1, band1db = 0, band2freq = 1200, band2rq = 1, band2db = 0, band3freq = 8000, band3rq = 1, band3db = 0, lpfreq = 20000, mute = 1, auxsend1 = 0, auxsend2 = 0, level = 0.5;
	var input, sig;
	input = InFeedback.ar(in, 2);
	sig = BHiPass.ar(input, Lag2.kr(hpfreq.max(20).min(20000), 0.5)); // HPF
	sig = BPeakEQ.ar(sig, Lag2.kr(band1freq.max(20).min(20000), 0.5), band1rq, band1db); // Band 1
	sig = BPeakEQ.ar(sig, Lag2.kr(band2freq.max(20).min(20000), 0.5), band2rq, band2db); // Band 2
	sig = BPeakEQ.ar(sig, Lag2.kr(band3freq.max(20).min(20000), 0.5), band3rq, band3db); // Band 3
	sig = BLowPass.ar(sig, Lag2.kr(lpfreq.max(20).min(20000), 0.5)); // LPF
	Out.ar(~aux1, sig * auxsend1); // Aux 1 pre fader / pre mute / post eq
	Out.ar(~aux2, sig * auxsend2); // Aux 2 pre fader / pre mute / post eq
	sig = sig * mute; // Mute
	Out.ar(out, Balance2.ar(sig[0], sig[1], pan, level.curvelin(0, 1, 0, 1, log(10)))); // curvelin(blabla) to have a logarithmic scale
}).add;
//~channelStrip.allControlNames.size.postln;

SynthDef(\MasterStrip, { arg in = 0, out = 0, hpfreq = 20, lpfreq = 20000, level = 0.5;
	var input, sig;
	input = In.ar(in, 2);
	sig = BHiPass.ar(input, Lag2.kr(hpfreq.max(20).min(20000), 0.5)); // HPF
	sig = BLowPass.ar(sig, Lag2.kr(lpfreq.max(20).min(20000), 0.5)); // LPF
	Out.ar(out, sig * level.curvelin(0, 1, 0, 1, log(10)));
}).add;

/**********************************************************************Sounds & Fx***************************************************************/

SynthDef(\IkedaClick, { arg out = 0, t_trig = 0, centerFreq = 15000, rq = 0.9, amp = 25, pan = 0, level = 1;
	var noise, sig;
 	noise = PinkNoise.ar(Decay.kr(t_trig, 0.001 * LFNoise1.kr(4).abs));
 	sig = BPF.ar(noise, centerFreq.max(1), rq, amp * LFNoise1.kr(8).range(0, 1)).fold(-1, 1);
 	DetectSilence.ar(sig, 0.001, doneAction:2);
 	OffsetOut.ar(out, Pan2.ar(sig, pan, level)); // OffsetOut write a signal to a bus with sample accurate timing
}).add;

SynthDef(\IkedaBass, { arg out = 0, t_trig = 0, pan = 0, level = 1;
	var env, sin, sig;
	env = EnvGen.ar(Env(#[0, 0.5, 0.4, 0], #[0, 0.2, 0.01], -5), t_trig, doneAction: 2);
	sin = SinOsc.ar(0, (Sweep.ar(t_trig, 2pi * [52.8, 740]) + (pi/3)).wrap(-pi, pi), #[2, 0.05]).mean.tanh;
	sig = sin * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, level.curvelin(0, 1, 0, 1, log(10))));
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
~master = Synth(\MasterStrip, [\in, masterBus], addAction: 'addToTail');

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
		\dur, Pdefn(\dur1), // Pwrand(#[2,1,\rest,2,Rest()], #[1,3,2,2,3].normalizeSum, inf); // chooses values according to a list of probabilities/weights
		\out, channel[0]
	)
).play(); // use the TempoClock default, if .play(t) use the TempoClock twice as fast as the TempoClock default

Pdef(\Bass,
	Pbind(
		\instrument, \IkedaBass,
		\level, 6,
		\dur, Pdefn(\dur2), // Pif(0.1.loop.coin, Pseq([Rest(), 7], inf), Pseries(0, 1, inf))
		\out, channel[1]
	)
).play();

~reverb = s.bind { Synth(\Reverb, [\in, ~aux1, \out, channel[2]], ~master, 'addBefore') }; // s.bind consider server latency
~simpleDelay = s.bind { Synth(\SimpleDelay, [\in, ~aux2, \out, channel[3]], ~master, 'addBefore') };
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
~master.set(\hpfreq, 20, \lpfreq, 200);
~master.set(\hpfreq, 20, \lpfreq, 20000, \level, 1);

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

w = Window("Mixer",Rect(0, 0, 850, 725), scroll: true);
w.front;
//w.alwaysOnTop_(true);
w.view.decorator = FlowLayout(w.view.bounds, 3@3, 3@3);

~channelNumber.do {
	arg i;
	channel[\channelView] = CompositeView(w, 118@720);
	channel[\channelView].background_(Color.white);
	channel[\channelView].decorator_(FlowLayout(channel[\channelView].bounds, 3@3, 3@3));

	// Channel name
	StaticText(channel[\channelView], 100@10)
	    .string_("Channel " ++ i)
	    .stringColor_(Color.black)
	    .align_(\center);
	channel[\channelView].decorator.nextLine;

	// hpf
	channel[(\activeHpf ++ i).asSymbol] = false;
	channel[(\hpfreq ++ i).asSymbol] = EZKnob(channel[\channelView], 112@70, 'hpfreq', ControlSpec(20, 20000, step: 1, default: 20, units: 'hz'), { arg hpfreq; currentEnvironment.at((\channel ++ i).asSymbol).set(\hpfreq, hpfreq.value); channel[(\activeHpf ++ i).asSymbol] = false; }, margin: 39@0);
	channel[\channelView].decorator.nextLine;

	// hpf midi map
	~ccStart = ~ccStart + 1;
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, treshold;
		midiControl = val.linlin(0, 127, 20, 20000);
		guiControl = channel[(\hpfreq ++ i).asSymbol].value;
		treshold = 500;
		if ( // soft takeover
			(channel[(\activeHpf ++ i).asSymbol] or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
			{
				channel[(\activeHpf ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\hpfreq, midiControl);
					channel[(\hpfreq ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, 0);
	(~ccStart).debug("Channel " ++ i ++ " hpfreq cc number");

	// band 1 freq
	channel[(\activeBand1Freq ++ i).asSymbol] = false;
	channel[(\band1freq ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'freq1', ControlSpec(20, 20000, step: 1, default: 80, units: 'hz'), { arg band1freq; currentEnvironment.at((\channel ++ i).asSymbol).set(\band1freq, band1freq.value); channel[(\activeBand1Freq ++ i).asSymbol] = false; });

	// band 1 freq midi map
	~ccStart = ~ccStart + 1;
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, treshold;
		midiControl = val.linlin(0, 127, 20, 20000);
		guiControl = channel[(\band1freq ++ i).asSymbol].value;
		treshold = 500;
		if ( // soft takeover
			(channel[(\activeBand1Freq ++ i).asSymbol] or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
			{
				channel[(\activeBand1Freq ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\band1freq, midiControl);
					channel[(\band1freq ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, 0);
	(~ccStart).debug("Channel " ++ i ++ " band1freq cc number");

	// band 1 rq
	channel[(\activeBand1Rq ++ i).asSymbol] = false;
	channel[(\band1rq ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'rq1', ControlSpec(0, 1, step: 0.01, default: 1), { arg band1rq; currentEnvironment.at((\channel ++ i).asSymbol).set(\band1rq, band1rq.value); channel[(\activeBand1Rq ++ i).asSymbol] = false; });

	// band 1 rq midi map
	~ccStart = ~ccStart + 1;
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, treshold;
		midiControl = val.linlin(0, 127, 0, 1);
		guiControl = channel[(\band1rq ++ i).asSymbol].value;
		treshold = 0.1;
		if ( // soft takeover
			(channel[(\activeBand1Rq ++ i).asSymbol] or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
			{
				channel[(\activeBand1Rq ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\band1rq, midiControl);
					channel[(\band1rq ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, 0);
	(~ccStart).debug("Channel " ++ i ++ " band1rq cc number");

	// band 1 db
	channel[(\activeBand1Db ++ i).asSymbol] = false;
	channel[(\band1db ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'db1', ControlSpec(0, 60, step: 1, default: 0, units: 'db'), { arg band1db; currentEnvironment.at((\channel ++ i).asSymbol).set(\band1db, band1db.value); channel[(\activeBand1Db ++ i).asSymbol] = false; });

	// band 1 db midi map
	~ccStart = ~ccStart + 1;
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, treshold;
		midiControl = val.linlin(0, 127, 0, 60);
		guiControl = channel[(\band1db ++ i).asSymbol].value;
		treshold = 10;
		if ( // soft takeover
			(channel[(\activeBand1Db ++ i).asSymbol] or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
			{
				channel[(\activeBand1Db ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\band1db, midiControl);
					channel[(\band1db ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, 0);
	(~ccStart).debug("Channel " ++ i ++ " band1db cc number");

	// band 2 freq
	channel[(\activeBand2Freq ++ i).asSymbol] = false;
	channel[(\band2freq ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'freq2', ControlSpec(20, 20000, step: 1, default: 1200, units: 'hz'), { arg band2freq; currentEnvironment.at((\channel ++ i).asSymbol).set(\band2freq, band2freq.value); channel[(\activeBand2Freq ++ i).asSymbol] = false; });

	// band 2 freq midi map
	~ccStart = ~ccStart + 1;
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, treshold;
		midiControl = val.linlin(0, 127, 20, 20000);
		guiControl = channel[(\band2freq ++ i).asSymbol].value;
		treshold = 500;
		if ( // soft takeover
			(channel[(\activeBand2Freq ++ i).asSymbol] or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
			{
				channel[(\activeBand2Freq ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\band2freq, midiControl);
					channel[(\band2freq ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, 0);
	(~ccStart).debug("Channel " ++ i ++ " band2freq cc number");

	// band 2 rq
	channel[(\activeBand2Rq ++ i).asSymbol] = false;
	channel[(\band2rq ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'rq2', ControlSpec(0, 1, step: 0.01, default: 1), { arg band2rq; currentEnvironment.at((\channel ++ i).asSymbol).set(\band2rq, band2rq.value); channel[(\activeBand2Rq ++ i).asSymbol] = false; });

	// band 2 rq midi map
	~ccStart = ~ccStart + 1;
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, treshold;
		midiControl = val.linlin(0, 127, 0, 1);
		guiControl = channel[(\band2rq ++ i).asSymbol].value;
		treshold = 0.1;
		if ( // soft takeover
			(channel[(\activeBand2Rq ++ i).asSymbol] or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
			{
				channel[(\activeBand2Rq ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\band2rq, midiControl);
					channel[(\band2rq ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, 0);
	(~ccStart).debug("Channel " ++ i ++ " band2rq cc number");

	// band 2 db
	channel[(\activeBand2Db ++ i).asSymbol] = false;
	channel[(\band2db ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'db2', ControlSpec(0, 60, step: 1, default: 0, units: 'db'), { arg band2db; currentEnvironment.at((\channel ++ i).asSymbol).set(\band2db, band2db.value); channel[(\activeBand2Db ++ i).asSymbol] = false; });

	// band 2 db midi map
	~ccStart = ~ccStart + 1;
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, treshold;
		midiControl = val.linlin(0, 127, 0, 60);
		guiControl = channel[(\band2db ++ i).asSymbol].value;
		treshold = 10;
		if ( // soft takeover
			(channel[(\activeBand2Db ++ i).asSymbol] or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
			{
				channel[(\activeBand2Db ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\band2db, midiControl);
					channel[(\band2db ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, 0);
	(~ccStart).debug("Channel " ++ i ++ " band2db cc number");

	// band 3 freq
	channel[(\activeBand3Freq ++ i).asSymbol] = false;
	channel[(\band3freq ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'freq3', ControlSpec(20, 20000, step: 1, default: 8000, units: 'hz'), { arg band3freq; currentEnvironment.at((\channel ++ i).asSymbol).set(\band3freq, band3freq.value); channel[(\activeBand3Freq ++ i).asSymbol] = false; });

	// band 3 freq midi map
	~ccStart = ~ccStart + 1;
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, treshold;
		midiControl = val.linlin(0, 127, 20, 20000);
		guiControl = channel[(\band3freq ++ i).asSymbol].value;
		treshold = 500;
		if ( // soft takeover
			(channel[(\activeBand3Freq ++ i).asSymbol] or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
			{
				channel[(\activeBand3Freq ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\band3freq, midiControl);
					channel[(\band3freq ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, 0);
	(~ccStart).debug("Channel " ++ i ++ " band3freq cc number");

	// band 3 rq
	channel[(\activeBand3Rq ++ i).asSymbol] = false;
	channel[(\band3rq ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'rq3', ControlSpec(0, 1, step: 0.01, default: 1), { arg band3rq; currentEnvironment.at((\channel ++ i).asSymbol).set(\band3rq, band3rq.value); channel[(\activeBand3Rq ++ i).asSymbol] = false; });

	// band 3 rq midi map
	~ccStart = ~ccStart + 1;
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, treshold;
		midiControl = val.linlin(0, 127, 0, 1);
		guiControl = channel[(\band3rq ++ i).asSymbol].value;
		treshold = 0.1;
		if ( // soft takeover
			(channel[(\activeBand3Rq ++ i).asSymbol] or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
			{
				channel[(\activeBand3Rq ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\band3rq, midiControl);
					channel[(\band3rq ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, 0);
	(~ccStart).debug("Channel " ++ i ++ " band3rq cc number");

	// band 3 db
	channel[(\activeBand3Db ++ i).asSymbol] = false;
	channel[(\band3db ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'db3', ControlSpec(0, 60, step: 1, default: 0, units: 'db'), { arg band3db; currentEnvironment.at((\channel ++ i).asSymbol).set(\band3db, band3db.value); channel[(\activeBand3Db ++ i).asSymbol] = false; });

	// band 3 db midi map
	~ccStart = ~ccStart + 1;
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, treshold;
		midiControl = val.linlin(0, 127, 0, 60);
		guiControl = channel[(\band3db ++ i).asSymbol].value;
		treshold = 10;
		if ( // soft takeover
			(channel[(\activeBand3Db ++ i).asSymbol] or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
			{
				channel[(\activeBand3Db ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\band3db, midiControl);
					channel[(\band3db ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, 0);
	(~ccStart).debug("Channel " ++ i ++ " band3db cc number");

	// lpf
	channel[(\activeLpf ++ i).asSymbol] = false;
	channel[(\lpfreq ++ i).asSymbol] = EZKnob(channel[\channelView], 112@70, 'lpfreq', ControlSpec(20, 20000, step: 1, default: 20000, units: 'hz'), { arg lpfreq; currentEnvironment.at((\channel ++ i).asSymbol).set(\lpfreq, lpfreq.value); channel[(\activeLpf ++ i).asSymbol] = false; }, margin: 39@0);
	channel[\channelView].decorator.nextLine;

	// lpf midi map
	~ccStart = ~ccStart + 1;
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, treshold;
		midiControl = val.linlin(0, 127, 20, 20000);
		guiControl = channel[(\lpfreq ++ i).asSymbol].value;
		treshold = 500;
		if ( // soft takeover
			(channel[(\activeLpf ++ i).asSymbol] or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
			{
				channel[(\activeLpf ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\lpfreq, midiControl);
					channel[(\lpfreq ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, 0);
	(~ccStart).debug("Channel " ++ i ++ " lpfreq cc number");

	// aux 1
	channel[(\activeAux1 ++ i).asSymbol] = false;
	channel[(\aux1 ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'aux1', ControlSpec(0, 1, step: 0.01, default: 0), { arg aux1; currentEnvironment.at((\channel ++ i).asSymbol).set(\auxsend1, aux1.value); channel[(\activeAux1 ++ i).asSymbol] = false; });

	// aux 1 midi map
	~ccStart = ~ccStart + 1;
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, treshold;
		midiControl = val.linlin(0, 127, 0, 1);
		guiControl = channel[(\aux1 ++ i).asSymbol].value;
		treshold = 0.1;
		if ( // soft takeover
			(channel[(\activeAux1 ++ i).asSymbol] or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
			{
				channel[(\activeAux1 ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\auxsend1, midiControl);
					channel[(\aux1 ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, 0);
	(~ccStart).debug("Channel " ++ i ++ " aux1 cc number");

	StaticText(channel[\channelView], 35@65)
	    .string_("Send")
	    .align_(\center);

	// aux 2
	channel[(\activeAux2 ++ i).asSymbol] = false;
	channel[(\aux2 ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'aux2', ControlSpec(0, 1, step: 0.01, default: 0), { arg aux2; currentEnvironment.at((\channel ++ i).asSymbol).set(\auxsend2, aux2.value); channel[(\activeAux2 ++ i).asSymbol] = false; });

	// aux 2 midi map
	~ccStart = ~ccStart + 1;
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, treshold;
		midiControl = val.linlin(0, 127, 0, 1);
		guiControl = channel[(\aux2 ++ i).asSymbol].value;
		treshold = 0.1;
		if ( // soft takeover
			(channel[(\activeAux2 ++ i).asSymbol] or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
			{
				channel[(\activeAux2 ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\auxsend2, midiControl);
					channel[(\aux2 ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, 0);
	(~ccStart).debug("Channel " ++ i ++ " aux2 cc number");

	// mute
	channel[(\mute ++ i).asSymbol] = Button(channel[\channelView], Rect(10,110,112,35)).states_([["Mute", Color.black, Color.white],["Active", Color.white, Color.grey]]).action = { arg mute; currentEnvironment.at((\channel ++ i).asSymbol).set(\mute, mute.value.linlin(0, 1, 1, 0)); };

	// mute midi map
	~ccStart = ~ccStart + 1;
	MIDIFunc.cc({ arg val, num, chan, src;
		var midiControl;
		midiControl = val.linlin(0, 127, 0, 1);
		{ channel[(\mute ++ i).asSymbol].valueAction_(midiControl); }.defer;
	}, ~ccStart, 0);
	(~ccStart).debug("Channel " ++ i ++ " mute cc number");

	// pan
	channel[(\activePan ++ i).asSymbol] = false;
	channel[(\pan ++ i).asSymbol] = EZSlider(channel[\channelView], 112@60, 'pan', ControlSpec(-1, 1, step: 0.01, default: 0), { arg pan; currentEnvironment.at((\channel ++ i).asSymbol).set(\pan, pan.value); channel[(\activePan ++ i).asSymbol] = false; }, layout: 'vert');
	channel[\channelView].decorator.nextLine;

	// pan midi map
	~ccStart = ~ccStart + 1;
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, treshold;
		midiControl = val.linlin(0, 127, -1, 1);
		guiControl = channel[(\pan ++ i).asSymbol].value;
		treshold = 0.1;
		if ( // soft takeover
			(channel[(\activePan ++ i).asSymbol] or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
			{
				channel[(\activePan ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\pan, midiControl);
					channel[(\pan ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, 0);
	(~ccStart).debug("Channel " ++ i ++ " pan cc number");

	// level
	channel[(\activeLevel ++ i).asSymbol] = false;
	channel[(\level ++ i).asSymbol] = EZSlider(channel[\channelView], 112@160, 'level', ControlSpec(0, 1, step: 0.01, default: 0.5), { arg level; currentEnvironment.at((\channel ++ i).asSymbol).set(\level, level.value); channel[(\activeLevel ++ i).asSymbol] = false; }, layout: 'vert', margin: 39@0);

	// level midi map
	~ccStart = ~ccStart + 1;
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, treshold;
		midiControl = val.linlin(0, 127, 0, 1);
		guiControl = channel[(\level ++ i).asSymbol].value;
		treshold = 0.1;
		if ( // soft takeover
			(channel[(\activeLevel ++ i).asSymbol] or: ((midiControl > (guiControl - treshold)) and: (midiControl < (guiControl + treshold)))),
			{
				channel[(\activeLevel ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\level, midiControl);
					channel[(\level ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, 0);
	(~ccStart).debug("Channel " ++ i ++ " level cc number");
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
channel[\hpfreqMaster] = EZKnob(channelMaster, 112@70, 'hpfreq', ControlSpec(20, 20000, step: 1, default: 20, units: 'hz'), { arg hpfreq; ~master.set(\hpfreq, hpfreq.value); }, margin: 39@0).setColors(stringColor: Color.white);
	channelMaster.decorator.nextLine;

// lpf
channel[\lpfreqMaster] = EZKnob(channelMaster, 112@70, 'lpfreq', ControlSpec(20, 20000, step: 1, default: 20000, units: 'hz'), { arg lpfreq; ~master.set(\lpfreq, lpfreq.value); }, margin: 39@0).setColors(stringColor: Color.white);
	channelMaster.decorator.nextLine;

// level
channel[\levelMaster] = EZSlider(channelMaster, 112@160, 'level', ControlSpec(0, 1, step: 0.01, default: 0.5), { arg level; ~master.set(\level, level.value); }, layout: 'vert', margin: 39@0).setColors(stringColor: Color.white);
)
