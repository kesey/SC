(

///////////////////////////////////////  Pattern

Pdefn(\durSnapkick, Pseq([1,Pwrand([0.5, 0.75], [0.3, 0.7].normalizeSum, 1),3/2], inf)).quant_(~globalQuant);
Pdefn(\durIkedaBreath, Pseq([3/2, 0.75, 1], inf)).quant_(~globalQuant);
Pdefn(\durIkedaBass, Pseq([3/4, Rest(0.75), Pwrand([1, 0.5], [0.4, 0.6].normalizeSum, 1)], inf)).quant_(~globalQuant);
Pdefn(\durIkedaClick, Pseq([1/8, 1/4], inf)).quant_(~globalQuant);

~initPattern = Pbind( // use PbindProxy to persist live changes
	\type, \rest,
	\instrument, \default,
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			{
				~removePrev.value(synthWindowKey);
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

///////////////////// default song

~defaultPattern1 = Pbind(
	\instrument, \snapkick,
	\dur, Pdefn(\durSnapkick),
	\amp, 0.4,
	\out, ~channelBus[0]
);

~defaultPattern2 = Pbind(
	\instrument, \IkedaBreath,
	\dur, Pdefn(\durIkedaBreath),
	\level, 1,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~ikedaBreathSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"level", ["knob", ControlSpec(0, 2, step: 0.1, default: event.at(\level)), true],
					"note1", ["slider", ControlSpec(0, 127, step: 0.1, default: 44), true],
					"note2", ["slider", ControlSpec(0, 127, step: 0.1, default: 90), true],
					"lpfFreq", ["knob", ControlSpec(20, 20000, step: 0.1, default: 103.82), true],
					"hpfFreq", ["knob", ControlSpec(20, 20000, step: 0.1, default: 2400), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~defaultPattern3 = Pbind(
	\instrument, \IkedaHiNoise,
	/*\dur, Pseq([3/4, 3/24, 3/12, 3/8, 3/12, 3/24], inf)
	\timingOffset, Pseq([0, 0, 0, 0.02, 0.015, 0], inf), // add groove in beats
	\lag, Pseq([0, 0, 0, 0.02, 0.015, 0], inf), // add groove in seconds*/
	[\dur, \lag], Pseq([[3/4/*dur value*/, 0/*lag value*/], [3/24, 0], [3/12, 0], [3/8, 0.02], [3/12, 0.015], [3/24, 0]], inf), // easier to read
	\amp, 0.014,
	\pan , Pwhite(-1.0, 1.0, inf),
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~ikedaHiNoiseSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 2, step: 0.01, default: event.at(\amp)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~defaultPattern4 = Pbind(
	\instrument, \IkedaBass,
	\dur, Pdefn(\durIkedaBass),
	\amp, 0.6,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~ikedaBassSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 2, step: 0.01, default: event.at(\amp)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~defaultPattern5 = Pbind(
	\instrument, \IkedaClick,
	\dur, Pdefn(\durIkedaClick),
	\amp, Pseq([1,0.5,0.8,0.3,0.9]*6, inf),
	\pan , Pwhite(-1.0, 1.0, inf),
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~ikedaClickSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 6, step: 0.01, default: event.at(\amp)), true],
					"centerFreq", ["slider", ControlSpec(20, 20000, step: 1, default: 15000), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~defaultPattern6 = Pbind(
	\instrument, \t1kick,
	\dur, Pseq([1.25, 0.625, 2.5]/*/2*/, inf), // /2 to play twice as fast
	\amp, 0.25,
	\rel, 0,
	\pan, Pwhite(-1.0, 1.0, inf),
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);
		ccStart = ~pdefCcStart;
		midiChan = ~pdefMidiChan;

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~t1kickSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"rel", ["knob", ControlSpec(0, 28, step: 0.1, default: event.at(\rel)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 2, step: 0.1, default: event.at(\amp)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~defaultPattern7 = Pbind(
	\instrument, \kick2,
	\dur, Pseq([0.5, Pwrand([0.25, 0.5], [0.3, 0.7].normalizeSum, 1), Rest(0.5), 0.125], inf),
	\amp, 1,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kick2SynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_gate", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 6, step: 0.01, default: event.at(\amp)), true],
					"freq", ["knob", ControlSpec(20, 600, step: 0.01, default: 60), true],
					"atf", ["knob", ControlSpec(0, 200, step: 0.01, default: 80), true],
					"rel", ["knob", ControlSpec(0, 20, step: 0.01, default: 1), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~defaultPattern8 = Pbind(
	\instrument, \t1kick2,
	\dur, Pseq([1.5, 0.125, 1], inf),
	\rel, 0.2,
	\amp, 0.35,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~t1kick2SynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 6, step: 0.01, default: event.at(\amp)), true],
					"snd", ["knob", ControlSpec(0, 42, step: 0.01, default: 18), true],
					"rel", ["knob", ControlSpec(0, 20, step: 0.01, default: 0.6), true],
					"pitch", ["knob", ControlSpec(0, 12, step: 0.01, default: 0.1), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~defaultPattern9 = Pbind(
	\instrument, \prayerBell,
	\dur, 5,
	\level, 0.03,
	\freq, 378,
	\decayscale, 0.48,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~prayerBellSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"i_doneAction", ["none"],
					"freq", ["knob", ControlSpec(20, 4500, step: 1, default: event.at(\freq)), true],
					"level", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\level)), true],
					"decayscale", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\decayscale)), true],
					"lag", ["knob", ControlSpec(0, 20, step: 0.01, default: 10), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~defaultPattern10 = Pbind(
	\instrument, \samplerStereo,
	\buffer, b[\sampler_stereo][1].bufnum,
	\dur, 5,
	\amp, 2,
	\rate, 0.06,
	\startPos, 0.04,
	\attack, 2.2,
	\release, 2,
	\curve, -4,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~samplerStereoSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"buffer", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"gate", ["none"],
					"loop", ["button", ControlSpec(0, 1, step: 1, default: 0), true],
					"amp", ["knob", ControlSpec(0, 2, step: 0.1, default: event.at(\amp)), true],
					"startPos", ["slider", ControlSpec(0, 1, step: 0.01, default: event.at(\startPos)), true],
					"rate", ["knob", ControlSpec(0.01, 1, step: 0.01, default: event.at(\rate)), true],
					"release", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"curve", ["knob", ControlSpec(-20, 20, step: 0.01, default: event.at(\curve)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

///////////////////// song2

~song2Pattern1 = Pbind(
	\instrument, \kick808,
	\dur, Pseq(
		[
			Rest(0.75), 0.5, Rest(0.25), 0.75, 1, 0.25, Rest(0.5), // 0.75+ 0.5+ 0.25+ 0.75+ 1+ 0.25+ 0.5 == 4
			Rest(0.25), 0.5, 0.75, 0.75, 0.5, 0.75, 0.5 // 0.25+ 0.5+ 0.75+ 0.75+ 0.5+ 0.75+ 0.5 == 4
		],
		inf
	),
	\envL1, 0,
    \envL2, 0.94,
	\envL3, 0,
	\envT1, 0.01,
	\envT2, 0.31,
	\enfL1, 400,
	\enfL2, 742,
	\enfL3, 82,
	\enfT1, 0.001,
	\enfT2, 0.001,
	\enfT3, 0.001,
	\tu, 0.68,
	\amp, 1.48,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kick808SynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\amp)), true],
					"tu", ["knob", ControlSpec(0, 2, step: 0.01, default: event.at(\tu)), true],
					"envL1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL1)), true],
					"envL2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL2)), true],
					"envL3", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL3)), true],
					"envT1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envT1)), true],
					"envT2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envT2)), true],
					"enfL1", ["knob", ControlSpec(0, 2000, step: 1, default: event.at(\enfL1)), true],
					"enfL2", ["knob", ControlSpec(0, 2000, step: 1, default: event.at(\enfL2)), true],
					"enfL3", ["knob", ControlSpec(0, 2000, step: 1, default: event.at(\enfL3)), true],
					"enfT1", ["knob", ControlSpec(0, 1, step: 0.001, default: event.at(\enfT1)), true],
					"enfT2", ["knob", ControlSpec(0, 1, step: 0.001, default: event.at(\enfT2)), true],
					"enfT3", ["knob", ControlSpec(0, 1, step: 0.001, default: event.at(\enfT3)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

/*~song2Pattern1 = Pbind(
	\instrument, \kick808,
	\dur, Pseq([Rest(0.25), 0.5, 0.75, 0.75, 0.5, 0.5, 0.75, Rest(0.25), 0.5, 0.75, 0.75, 0.5, 0.75, 0.5], inf),
	\envL1, 0,
    \envL2, 1,
	\envL3, 0,
	\envT1, 0.09,
	\envT2, 0.29,
	\enfL1, 877,
	\enfL2, 0,
	\enfL3, 17,
	\enfT1, 0.04,
	\enfT2, 0.4,
	\enfT3, 0,
	\tu, 0.94,
	\amp, 0.9,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kick808SynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), true],
					"amp", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\amp)), true],
					"tu", ["knob", ControlSpec(0, 2, step: 0.01, default: event.at(\tu)), true],
					"envL1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL1)), true],
					"envL2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL2)), true],
					"envL3", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL3)), true],
					"envT1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envT1)), true],
					"envT2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envT2)), true],
					"enfL1", ["knob", ControlSpec(0, 2000, step: 1, default: event.at(\enfL1)), true],
					"enfL2", ["knob", ControlSpec(0, 2000, step: 1, default: event.at(\enfL2)), true],
					"enfL3", ["knob", ControlSpec(0, 2000, step: 1, default: event.at(\enfL3)), true],
					"enfT1", ["knob", ControlSpec(0, 1, step: 0.001, default: event.at(\enfT1)), true],
					"enfT2", ["knob", ControlSpec(0, 1, step: 0.001, default: event.at(\enfT2)), true],
					"enfT3", ["knob", ControlSpec(0, 1, step: 0.001, default: event.at(\enfT3)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);*/

~song2Pattern2 = Pbind(
	\instrument, \hatnew,
	\dur, Pseq([0.25, Pn(0.125, 3), 0.25, 0.25, 0.125, 0.25, 0.125, 0.25, 0.125], inf),
	                      // 0.25 +  (0.125 *3)+ 0.25 +0.25 +0.125 +0.25 +0.125 +0.25 +0.125 == 2
	\pan, Pwhite(-0.75, 0.75, inf),
	\freq, 0.44,
	\hpf, 8500,
	\rel, 0.15,
	\amp, 2.6,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~hatnewSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\amp)), true],
					"rel", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\rel)), true],
					"freq", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\freq)), true],
					"hpf", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\hpf)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song2Pattern3 = Pbind(
	\instrument, \kickmed,
	\dur, Pseq([Rest(1), 3], inf),
	\env0L2, 0.63,
	\env0L3, 0.15,
	\fratio, 1.11,
	\env1L1, 0,
	\env1L2, 37,
	\env1L3, 24,
	\env1T1, 0.3,
	\level, 0.8,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kickMedSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"dc", ["none"],
					"done", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"level", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\level)), true],
					"snd", ["knob", ControlSpec(0, 100, step: 0.1, default: 18), true],
					"atkEnv0", ["knob", ControlSpec(0, 10, step: 0.01, default: 0.01), true],
					"decEnv0", ["knob", ControlSpec(0, 10, step: 0.01, default: 0.2), true],
					"relEnv0", ["knob", ControlSpec(0, 10, step: 0.01, default: 0.26), true],
					"fratio", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\fratio)), true],
					"env0L2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\env0L2)), true],
					"env0L3", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\env0L3)), true],
					"env1L1", ["knob", ControlSpec(0, 120, step: 0.1, default: event.at(\env1L1)), true],
					"env1L2", ["knob", ControlSpec(0, 120, step: 0.1, default: event.at(\env1L2)), true],
					"env1L3", ["knob", ControlSpec(0, 120, step: 0.1, default: event.at(\env1L3)), true],
					"env1T1", ["knob", ControlSpec(0, 1, step: 1, default: event.at(\env1T1)), true],
					"curve1", ["knob", ControlSpec(-4, 4, step: 0.01, default: -4), true],
					"curve2", ["knob", ControlSpec(-4, 4, step: 0.01, default: -2), true],
					"curve3", ["knob", ControlSpec(-4, 4, step: 0.01, default: -4), true],
					"owhich2", ["slider", ControlSpec(0, 3, step: 1, default: 0), true],
					"ochoose", ["slider", ControlSpec(0, 3, step: 1, default: 0), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song2Pattern4 = Pbind(
	\instrument, \dStowell,
	\dur, 2,
	\attack, 0,
	\release, 3,
	\lpf, 370,
	\amp, 2,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~dStowellSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\amp)), true],
					"attack", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"release", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"lpf", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\lpf)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song2Pattern5 = Pbind(
	\instrument, \kikAw,
	\dur, Pseq([0.125, Rest(0.25), 1, 1.125, 0.5, Rest(1)], inf), // 0.125 +0.25+ 1 + 1.125+ 0.5+ 1 == 4
	\basefreq, 51,
	\ratio, 0.65,
	\sweeptime, 0.81,
	\envL1, 1.11,
	\envL2, 4.31,
	\envL3, 0,
	\envT1, 0.02,
	\envT2, 0.4,
	\amp, 0.4,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kikAwSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\amp)), true],
					"basefreq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\basefreq)), true],
					"ratio", ["knob", ControlSpec(0, 20, step: 0.01, default: event.at(\ratio)), true],
					"sweeptime", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\sweeptime)), true],
					"envL1", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\envL1)), true],
					"envL2", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\envL2)), true],
					"envL3", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\envL3)), true],
					"envT1", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\envT1)), true],
					"envT2", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\envT2)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song2Pattern6 = Pbind(
	\instrument, \sd,
	\dur, Pseq([2, 4, 2], inf),
	\amp, 0.12,
	\att, 0.02,
	\rel, 0.05,
	\freq, 266,
	\ffreq, 16004,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~sdSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"rel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\rel)), true],
					"att", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\att)), true],
					"freq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\freq)), true],
					"ffreq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\ffreq)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song2Pattern7 = Pbind(
	\instrument, \hat808,
	\dur, Pseq([0.125, 0.25, 0.125, 0.125, 0.25, 1, 0.125], inf),
	         // 0.125 +0.25 +0.125 +0.125 +0.25 +1 +0.125 == 2
	\amp, 0.018,
	\tu, 0.63,
	\attack, 0,
	\release, Pseq([0.01, 0.03, 0.02, 0.01, 0.02, 0.05, 0.03], inf),
	\hpf, 14776,
	\rq, 0,
	\rel, 0.92,
	\lpf, 2834,
	\pan, Pwhite(-1.0, 1.0, inf),
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~hat808SynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_gate", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 1, step: 0.001, default: event.at(\amp)), true],
					"attack", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"release", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"tu", ["knob", ControlSpec(0, 2, step: 0.01, default: event.at(\tu)), true],
					"hpf", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\hpf)), true],
					"lpf", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\lpf)), true],
					"rel", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\rel)), true],
					"rq", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\rq)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song2Pattern8 = Pbind(
	\instrument, \ping_mh,
	\dur, 8,
	\amp, 0.04,
	\freq, 417,
	\attack, 1.79,
	\pan, Pwhite(-0.5, 0.5, inf),
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~ping_mhSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"freq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\freq)), true],
					"attack", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song2Pattern9 = Pbind(
	\instrument, \tabass,
	\dur, 0.125,
	\freq, Pseq([0.0625, 0.125, 0.0625, 0.5, 1, 0.9], inf),
	\attack, 0,
	\release, Pseq([0.42, 0.2, 0.9, 0.2], inf),
	\amp, 0.12,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~tabassSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 2, step: 0.1, default: event.at(\amp)), true],
					"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"release", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"freq", ["slider", ControlSpec(0, 12, step: 0.01, default: event.at(\freq)), true]

				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song2Pattern10 = Pbind(
	\instrument, \noise2new,
	\dur, Pseq([2, 1, 1], inf),
	\att, 0.01,
	\rel, 1,
	\del1, 23.48,
	\del2, 0,
	\div, 0.02,
	\amp, 0.08,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~noise2newSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\amp)), true],
					"att", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\att)), true],
					"rel", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\rel)), true],
					"del1", ["knob", ControlSpec(0, 30, step: 0.01, default: event.at(\del1)), true],
					"del2", ["knob", ControlSpec(0, 30, step: 0.01, default: event.at(\del2)), true],
					"div", ["knob", ControlSpec(0, 30, step: 0.01, default: event.at(\div)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song2Pattern11 = Pbind(
	\instrument, \sinBass,
	\amp, 0.6,
	\dur, 2,
	\curve, 0,
	\loopNode, 0,
	\attack, 0,
	\release, 2,
	\curve, -4,
	\envLevel1, 0,
	\envLevel2, 20.3,
	\envLevel3, 64,
	\envLevel4, 20.9,
	\envLevel5, 73.5,
	\envLevel6, 56,
	\envTime1, 0.01,
	\envTime2, 0.15,
	\envTime3, 0.75,
	\envTime4, 0.52,
	\envTime5, 0.5,
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~sinBassSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), false],
					"amp", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\amp)), true],
					"gate", ["none"],
					"curve", ["knob", ControlSpec(-20, 20, step: 1, default: event.at(\curve)), true],
					"loopNode", ["knob", ControlSpec(0, 4, step: 1, default: event.at(\loopNode)), true],
					"attack", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"release", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"envLevel1", ["knob", ControlSpec(0, 80, step: 0.1, default: event.at(\envLevel1)), true],
					"envLevel2", ["knob", ControlSpec(0, 80, step: 0.1, default: event.at(\envLevel2)), true],
					"envLevel3", ["knob", ControlSpec(0, 80, step: 0.1, default: event.at(\envLevel3)), true],
					"envLevel4", ["knob", ControlSpec(0, 80, step: 0.1, default: event.at(\envLevel4)), true],
					"envLevel5", ["knob", ControlSpec(0, 80, step: 0.1, default: event.at(\envLevel5)), true],
					"envLevel6", ["knob", ControlSpec(0, 80, step: 0.1, default: event.at(\envLevel6)), true],
					"envTime1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envTime1)), true],
					"envTime2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envTime2)), true],
					"envTime3", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envTime3)), true],
					"envTime4", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envTime4)), true],
					"envTime5", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envTime5)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	}),
	\out, ~channelBus[0]
);

~song2Pattern12 = Pbind(
	\instrument, \samplerStereo,
	\buffer, b[\sampler_stereo][1].bufnum,
	\dur, 4,
	\amp, 1.2,
	\rate, 0.06,
	\startPos, 0.08,
	\attack, 2.2,
	\release, 2,
	\curve, -4,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~samplerStereoSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"buffer", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"gate", ["none"],
					"loop", ["button", ControlSpec(0, 1, step: 1, default: 0), true],
					"amp", ["knob", ControlSpec(0, 2, step: 0.1, default: event.at(\amp)), true],
					"startPos", ["slider", ControlSpec(0, 1, step: 0.01, default: event.at(\startPos)), true],
					"rate", ["knob", ControlSpec(0.01, 1, step: 0.01, default: event.at(\rate)), true],
					"release", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"curve", ["knob", ControlSpec(-20, 20, step: 0.01, default: event.at(\curve)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

///////////////////// song3

~song3Pattern1 = Pbind(
	\instrument, \kickMist,
	\dur, Pseq([2.625, 1.75, Rest(0.875), 1.75], inf),
	\level, 0.12,
	\tu, 1,
	\noise, 1,
	\env0L1, 0.35,
	\env0L2, 0.29,
	\env0L3, 52,
	\env0L4, 0.26,
	\env0T1, 0.24,
	\env0T2, 0,
	\env0T3, 0,
	\env1L1, 60,
	\env1L2, 58,
	\env1L3, 29,
	\env1T1, 0,
	\env1T2, 0.04,
	\pan, 0,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kickMistSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"level", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\level)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"env0L1", ["knob", ControlSpec(0, 400, step: 0.01, default: event.at(\env0L1)), true],
					"env0L2", ["knob", ControlSpec(0, 400, step: 0.01, default: event.at(\env0L2)), true],
					"env0L3", ["knob", ControlSpec(0, 400, step: 0.01, default: event.at(\env0L3)), true],
					"env0L4", ["knob", ControlSpec(0, 400, step: 0.01, default: event.at(\env0L4)), true],
					"env0T1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\env0T1)), true],
					"env0T2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\env0T2)), true],
					"env0T3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\env0T3)), true],
					"env1L1", ["knob", ControlSpec(0, 400, step: 0.01, default: event.at(\env1L1)), true],
					"env1L2", ["knob", ControlSpec(0, 400, step: 0.01, default: event.at(\env1L2)), true],
					"env1L3", ["knob", ControlSpec(0, 400, step: 0.01, default: event.at(\env1L3)), true],
					"env1T1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\env0T1)), true],
					"env1T2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\env0T2)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song3Pattern2 = Pbind(
	\instrument, \drumkick,
	\dur, Pseq([3.5, Rest(0.875), 1.75, Rest(0.875)], inf), // 3.5+ 0.875+ 1.75+ 0.875 == 7
	\amp, 0.2,
	\attack, 1.47,
	\release, 2.47,
	\curve, 60,
	\pan, 0,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~drumkickSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_gate", ["none"],
					"doneAction", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"attack", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"release", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"curve", ["knob", ControlSpec(-200, 200, step: 0.01, default: event.at(\curve)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song3Pattern3 = Pbind(
	\instrument, \kicklaserbeam,
	\dur, Pseq([0.875, 1.75, 1.25, 0.875, 1.375, 0.875], inf), // 0.875+ 1.75+ 1.25+ 0.875+ 1.375+ 0.875 == 7
	\amp, 0.004,
	\freq, 15794,
	\att, 1.06,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kicklaserbeamSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"amp", ["knob", ControlSpec(0, 1, step: 0.001, default: event.at(\amp)), true],
					"att", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\att)), true],
					"freq", ["slider", ControlSpec(20, 20000, step: 1, default: event.at(\freq)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song3Pattern4 = Pbind(
	\instrument, \kickbass,
	\dur, 1.75,
	\level, 0.08,
	\pan, Pwhite(-1.0, 1.0, inf),
	\attack, 1.32,
	\decay, 2.63,
	\release, 1.32,
	\fratio, 0.32,
	\freq1, 34,
	\freq2, 60,
	\freq3, 56,
	\aamp1, 1,
	\aamp2, 0,
	\aamp3, 1,
	\aamp4, 1,
	\curve1, -20.09,
	\curve2, 8.86,
	\curve3, 1.36,
	\famp1, 0.16,
	\famp2, 0.71,
	\famp3, 0,
	\famp4, 0,
	\p1, 0.83,
	\oamp, 0.63,
	\owhich2, 0,
	\ochoose, 0.54,
	\filter, 177,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kickbassSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"done", ["none"],
					"level", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\level)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"decay", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\decay)), true],
					"release", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"fratio", ["slider", ControlSpec(0.01, 2, step: 0.01, default: event.at(\fratio)), true],
					"freq1", ["knob", ControlSpec(20, 120, step: 1, default: event.at(\freq1)), true],
					"freq2", ["knob", ControlSpec(20, 120, step: 1, default: event.at(\freq2)), true],
					"freq3", ["knob", ControlSpec(20, 120, step: 1, default: event.at(\freq3)), true],
					"aamp1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\aamp1)), true],
					"aamp2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\aamp2)), true],
					"aamp3", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\aamp3)), true],
					"curve1", ["knob", ControlSpec(-50, 50, step: 0.01, default: event.at(\curve1)), true],
					"curve2", ["knob", ControlSpec(-50, 50, step: 0.01, default: event.at(\curve2)), true],
					"curve3", ["knob", ControlSpec(-50, 50, step: 0.01, default: event.at(\curve3)), true],
					"famp1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\famp1)), true],
					"famp2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\famp2)), true],
					"famp3", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\famp3)), true],
					"famp4", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\famp4)), true],
					"p1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\p1)), true],
					"oamp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\oamp)), true],
					"owhich2", ["knob", ControlSpec(0, 3, step: 1, default: event.at(\owhich2)), true],
					"ochoose", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\ochoose)), true],
					"filter", ["knob", ControlSpec(150, 20000, step: 1, default: event.at(\filter)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song3Pattern5 = Pbind(
	\instrument, \IkedaBreath,
	\dur, Pseq([0.4375, 1.75, 1.3125, 1.75, 0.4375, 1.3125], inf), // 0.4375+ 1.75+ 1.3125+ 1.75 +0.4375+ 1.3125 == 7
	\level, 0.08,
	\pan, Pwhite(-0.35, 0.35, inf),
	\note1, 127,
	\note2, 47.8,
	\amp1, 0.37,
	\amp2, 0.7,
	\lpfFreq, 20000,
	\hpfFreq, 20,
	\attack, 0.17,
	\decay, 0,
	\release, 0,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~ikedaBreathSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"level", ["knob", ControlSpec(0, 2, step: 0.01, default: event.at(\level)), true],
					"note1", ["slider", ControlSpec(0, 127, step: 0.1, default: event.at(\note1)), true],
					"note2", ["slider", ControlSpec(0, 127, step: 0.1, default: event.at(\note2)), true],
					"amp1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp1)), true],
					"amp2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp2)), true],
					"lpfFreq", ["knob", ControlSpec(20, 20000, step: 0.1, default: event.at(\lpfFreq)), true],
					"hpfFreq", ["knob", ControlSpec(20, 20000, step: 0.1, default: event.at(\hpfFreq)), true],
					"attack", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"decay", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\decay)), true],
					"release", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song3Pattern6 = Pbind(
	\instrument, \cymnew,
	\dur, 0.875,
	\amp, 0.014,
	\att, 0,
	\rel, 2,
	\curve, -8,
	\tu, 6,
	\pan, Pwhite(-0.5, 0.5, inf),
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~cymnewSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"att", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\att)), true],
					"rel", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\rel)), true],
					"curve", ["knob", ControlSpec(-200, 200, step: 0.01, default: event.at(\curve)), true],
					"tu", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\tu)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song3Pattern7 = Pbind(
	\instrument, \hat808,
	\dur, Pseq([0.4375, 0.21875, Rest(0.875), 0.4375, 0.21875, 0.4375, 0.875], inf),
             // 0.4375+ 0.21875+      0.875 + 0.4375+ 0.21875+ 0.4375+ 0.875 == 3.5
	\amp, 0.002,
	\tu, 1.23,
	\attack, 0,
	\release, Pseq([0.01, 0.03, 0.02, 0.01, 0.02, 0.05, 0.03], inf),
	\hpf, 14069,
	\rq, 0,
	\rel, 0.92,
	\lpf, 2834,
	\pan, Pwhite(-1.0, 1.0, inf),
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~hat808SynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_gate", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 1, step: 0.001, default: event.at(\amp)), true],
					"attack", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"release", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"tu", ["knob", ControlSpec(0, 2, step: 0.01, default: event.at(\tu)), true],
					"hpf", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\hpf)), true],
					"lpf", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\lpf)), true],
					"rel", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\rel)), true],
					"rq", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\rq)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song3Pattern8 = Pbind(
	\instrument, \cym,
	\dur, Pwrand([3.5, 7], [0.7, 0.3].normalizeSum, inf),
	\amp, 0.05,
	\att, 0.47,
	\rel, 0.88,
	\curve, -8,
	\pan, Pwhite(-0.5, 0.5, inf),
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~cymSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"att", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\att)), true],
					"rel", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\rel)), true],
					"curve", ["knob", ControlSpec(-200, 200, step: 0.01, default: event.at(\curve)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song3Pattern9 = Pbind(
	\instrument, \harrish,
	\dur, Pseq([1.75, 3.5, 1.75], inf),
	\amp, 0.4,
	\pan, 0,
	\attack, 0.57,
	\sustain, 0,
	\release, 0,
	\curve, 5.13,
	\clipLevel, 0.006,
	\impFreq, 34,
	\impPhase, 0,
	\impLevel, 1,
	\noiseLevel, 0.3,
	\lpf, 20000,
	\eqfreq, 516,
	\eqrq, 0.16,
	\eqdb, -60,
	\hpf, 20,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~harrishSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"sustain", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\sustain)), true],
					"release", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"curve", ["knob", ControlSpec(-6, 6, step: 0.01, default: event.at(\curve)), true],
					"clipLevel", ["knob", ControlSpec(0, 6, step: 0.01, default: event.at(\clipLevel)), true],
					"impFreq", ["knob", ControlSpec(0, 10000, step: 1, default: event.at(\impFreq)), true],
					"impPhase", ["slider", ControlSpec(0, 1, step: 0.01, default: event.at(\impPhase)), true],
					"impLevel", ["knob", ControlSpec(0, 6, step: 0.01, default: event.at(\impLevel)), true],
					"noiseLevel", ["knob", ControlSpec(0, 6, step: 0.01, default: event.at(\noiseLevel)), true],
					"lpf", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\lpf)), true],
					"eqfreq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\eqfreq)), true],
					"eqrq", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\eqrq)), true],
					"eqdb", ["knob", ControlSpec(-60, 60, step: 0.01, default: event.at(\eqdb)), true],
					"hpf", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\hpf)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song3Pattern10 = Pbind(
	\instrument, \sinBass,
	\amp, 0.2,
	\dur, 3.5,
	\curve, 0,
	\loopNode, 0,
	\attack, 0,
	\release, 2,
	\curve, -4,
	\envLevel1, 0,
	\envLevel2, 64,
	\envLevel3, 20.3,
	\envLevel4, 73.5,
	\envLevel5, 20.9,
	\envLevel6, 56,
	\envTime1, 0.01,
	\envTime2, 0.15,
	\envTime3, 0.75,
	\envTime4, 0.52,
	\envTime5, 0.5,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~sinBassSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), false],
					"amp", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\amp)), true],
					"gate", ["none"],
					"curve", ["knob", ControlSpec(-20, 20, step: 1, default: event.at(\curve)), true],
					"loopNode", ["knob", ControlSpec(0, 4, step: 1, default: event.at(\loopNode)), true],
					"attack", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"release", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"envLevel1", ["knob", ControlSpec(0, 80, step: 0.1, default: event.at(\envLevel1)), true],
					"envLevel2", ["knob", ControlSpec(0, 80, step: 0.1, default: event.at(\envLevel2)), true],
					"envLevel3", ["knob", ControlSpec(0, 80, step: 0.1, default: event.at(\envLevel3)), true],
					"envLevel4", ["knob", ControlSpec(0, 80, step: 0.1, default: event.at(\envLevel4)), true],
					"envLevel5", ["knob", ControlSpec(0, 80, step: 0.1, default: event.at(\envLevel5)), true],
					"envLevel6", ["knob", ControlSpec(0, 80, step: 0.1, default: event.at(\envLevel6)), true],
					"envTime1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envTime1)), true],
					"envTime2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envTime2)), true],
					"envTime3", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envTime3)), true],
					"envTime4", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envTime4)), true],
					"envTime5", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envTime5)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song3Pattern11 = Pbind(
	\instrument, \main,
	\dur, Pseq([0.75, 1.5, 2, 1.75, 1]*2, inf), // 0.75+ 1.5+ 2+ 1.75+ 1 == 7
	\amp, 0.03,
	\att, Pseg([0.03, 0.21, 0.16, 0.13, 0.03, 0.23], [0.3, 0.03, 0.04, 0.09, 0.5], repeats: inf),
	\freq, Pseg([34, 37], [0.07], repeats: inf),
	\lev, 10,
	\sinAmp, 2,
	\sel, 0,
	\levelScale, 1.53,
	\levelBias, 0.48,
	\timeScale, 1,
	\hpf, 8000,
	\sinFreq, 30,
	\rel, 0.13,
	\revtime, 2.5,
	\room, Pseq([1.63, 16, 1.63, 10, 1.37], inf),
	\revMix, 0.3,
	\pan, 0,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~mainSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"doneAction", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), false],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"lev", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\lev)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"sinAmp", ["knob", ControlSpec(0, 5, step: 0.01, default: event.at(\sinAmp)), true],
					"levelScale", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\levelScale)), true],
					"timeScale", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\timeScale)), true],
					"hpf", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\hpf)), true],
					"sinFreq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\sinFreq)), true],
					"freq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\freq)), true],
					"sel", ["slider", ControlSpec(0, 3, step: 1, default: event.at(\sel)), true],
					"att", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\att)), true],
					"rel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\rel)), true],
					"revtime", ["slider", ControlSpec(0, 60, step: 0.1, default: event.at(\revtime)), true],
					"revMix", ["slider", ControlSpec(0, 60, step: 0.1, default: event.at(\revMix)), true],
					"room", ["knob", ControlSpec(0, 20, step: 0.01, default: event.at(\room)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song3Pattern12 = Pbind(
	\instrument, \kSpluck3,
	//\dur, Pseq([7, 7, 7, 4.5, 2.5], inf),
	\amp, 0.014,
	[\dur, \att, \midiPitch],
	Pseq([
		[7, 0.47, 53.4],
		[14, 1.37, 53.4],
		[4.5, 1.32, 53.4],
		[2.5, 0.82, Penv([41,4, 35.3], [0.5], \exponential)]
	], inf),
	\rel, 2.11,
	\art, 0.6,
	\noiseFreq, Pseq([3707, 2700, 120, 3570, 4280], inf),
	\noiseLev, 13631,
	\noiseOffset, 13963,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kSpluck3SynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"att", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\att)), true],
					"rel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\rel)), true],
					"midiPitch", ["knob", ControlSpec(0, 127, step: 0.1, default: event.at(\midiPitch)), true],
					"art", ["knob", ControlSpec(-10, 10, step: 0.1, default: event.at(\art)), true],
					"noiseFreq", ["knob", ControlSpec(0, 20000, step: 1, default: event.at(\noiseFreq)), true],
					"noiseLev", ["knob", ControlSpec(0, 20000, step: 1, default: event.at(\noiseLev)), true],
					"noiseOffset", ["knob", ControlSpec(0, 20000, step: 1, default: event.at(\noiseLev)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song3Pattern13 = Pbind(
	\instrument, \lumbricost,
	\dur, 7, //Pwrand([3.5, 7], [0.7, 0.3].normalizeSum, inf),
	\amp, 0.3,
	\attTim, 1,
	\relTim, 2.5,
	\scale, 25,
	\offset, 24.7,
	\freq, 12,
	\timescale, 10,
	\randLo, 200,
	\randHi, 2000,
	\bprq, 1,
	\pan, Pwhite(-0.2, 0.2, inf),
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~lumbricostSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_gate", ["none"],
					"doneAction", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\amp)), true],
					"attTim", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\attTim)), true],
					"relTim", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\relTim)), true],
					"scale", ["knob", ControlSpec(0, 48, step: 1, default: event.at(\scale)), true],
					"offset", ["knob", ControlSpec(0, 60, step: 0.1, default: event.at(\offset)), true],
					"freq", ["knob", ControlSpec(0, 40, step: 0.1, default: event.at(\freq)), true],
					"timescale", ["knob", ControlSpec(0, 40, step: 0.1, default: event.at(\timescale)), true],
					"randLo", ["knob", ControlSpec(0, 20000, step: 1, default: event.at(\randLo)), true],
					"randHi", ["knob", ControlSpec(0, 20000, step: 1, default: event.at(\randHi)), true],
					"bprq", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\bprq)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

///////////////////// song4

~song4Pattern1 = Pbind(
	\instrument, \scratchi,
	\dur, 1.25,
	\amp, 20.2,
	\spread, 0.99, // 0
	\attack, 0.01,
	\release, 2,
	\freq, 2887.1, // 632, // 629 // 610 // 603 // 440
	\pan, 0,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~scratchiSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"doneAction", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 24, step: 0.01, default: event.at(\amp)), true],
					"spread", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\spread)), true],
					"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"release", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"freq", ["knob", ControlSpec(0, 20000, step: 0.1, default: event.at(\freq)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song4Pattern2 = Pbind(
	\instrument, \rim,
	\dur, 1.25,
	\timingOffset, Pseq([0.1, 0.375], inf),
	\amp, 0.16,
	\tu, 1.56,
	\envLev1, 0.65,
	\envLev2, 0.68,
	\envLev3, 0.11,
	\envLev4, 0.38,
	\att, 0.01,
	\dec, 0.004,
	\rel, 0.1,
	\hpf, 100,
	\lpf, 11100,
	\pan, 0,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~rimSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_gate", ["none"],
					"doneAction", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"tu", ["knob", ControlSpec(0, 5, step: 0.01, default: event.at(\tu)), true],
					"envLev1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envLev1)), true],
					"envLev2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envLev2)), true],
					"envLev3", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envLev3)), true],
					"envLev4", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envLev4)), true],
					"att", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\att)), true],
					"dec", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\dec)), true],
					"rel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\rel)), true],
					"hpf", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\hpf)), true],
					"lpf", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\lpf)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song4Pattern3 = Pbind(
	\instrument, \tweetAnaBass,
	\dur, Pseq([2.5, 1.25], inf),
	\amp, 0.3,
	\attack, 0,
	\release, 1.75,
	\freq, 95,
	\ffreq, 53,
	\tu, 0.84,
	\compTresh, 0.31,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~tweetAnaBassSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_trig", ["none"],
					"doneAction", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"release", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"freq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\freq)), true],
					"ffreq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\ffreq)), true],
					"tu", ["knob", ControlSpec(0, 5, step: 0.01, default: event.at(\tu)), true],
					"compTresh", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\compTresh)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song4Pattern4 = Pbind(
	\instrument, \drumkick,
	\dur, Pseq([0.5, 0.75, 0.5, Rest(0.25), 0.5], inf),
	\amp, 0.2,
	\attack, 1.05,
	\release,0.16,
	\curve, -39.7,
	\attSinFreq, 0.01,
	\relSinFreq, 1.12,
	\curveSinFreq, -60,
	\levSin, 0.26,
	\attBpfFreq, 0.02,
	\relBpfFreq, 0.3,
	\timeScaleBpf, 1.11,
	\curveBpf, -200,
	\levBpf, 0.18,
	\levScaleBpf, 6000,
	\levBiasBpf, 21.3,
	\lineStartBpf, 0.3,
	\lineEndBpf, 0,
	\lineLevBpf, 0.15,
	\pan, 0,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~drumkickSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_gate", ["none"],
					"doneAction", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"release", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"curve", ["knob", ControlSpec(-200, 200, step: 0.1, default: event.at(\curve)), true],
					"attSinFreq", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attSinFreq)), true],
					"relSinFreq", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\relSinFreq)), true],
					"curveSinFreq", ["knob", ControlSpec(-200, 200, step: 0.1, default: event.at(\curveSinFreq)), true],
					"levSin", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\levSin)), true],
					"attBpfFreq", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attBpfFreq)), true],
					"relBpfFreq", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\relBpfFreq)), true],
					"timeScaleBpf", ["slider", ControlSpec(0.01, 10, step: 0.01, default: event.at(\timeScaleBpf)), true],
					"curveBpf", ["knob", ControlSpec(-200, 200, step: 0.1, default: event.at(\curveBpf)), true],
					"levBpf", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\levBpf)), true],
					"levScaleBpf", ["knob", ControlSpec(0, 6000, step: 1, default: event.at(\levScaleBpf)), true],
					"levBiasBpf", ["knob", ControlSpec(0.1, 120, step: 0.1, default: event.at(\levBiasBpf)), true],
					"lineStartBpf", ["slider", ControlSpec(0, 2, step: 0.01, default: event.at(\lineStartBpf)), true],
					"lineEndBpf", ["slider", ControlSpec(0, 2, step: 0.01, default: event.at(\lineEndBpf)), true],
					"lineLevBpf", ["knob", ControlSpec(0, 2, step: 0.01, default: event.at(\lineLevBpf)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song4Pattern5 = Pbind(
	\instrument, \kickhi,
	\dur, Pseq([Rest(0.375), 0.5, 0.375, Rest(0.25), 0.75, 0.25], inf),
	\amp, 0.8,
	\vcaLev1, 0.1,
	\vcaLev2, 0.26,
	\vcaLev3, 0.55,
	\vcaLev4, 0,
	\vcaLev5, 0,
	\vcaTime1, 0.02,
	\vcaTime2, 2.11,
	\vcaTime3, 1.84,
	\vcaTime4, 0.01,
	\vcaCurve1, -46.3,
	\vcaCurve2, -47.7,
	\vcaCurve3, -79.8,
	\vcfLev1, 0,
	\vcfLev2, 63.5,
	\vcfLev3, 16.2,
	\vcfLev4, 0,
	\vcfTime1, 0.02,
	\vcfTime2, 0.49,
	\vcfTime3, 0.02,
	\vcfCurve1, -8.4,
	\vcfCurve2, -85,
	\tu, 1.75,
	\pan, 0,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kickhiSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 2, step: 0.01, default: event.at(\amp)), true],
					"vcaLev1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\vcaLev1)), true],
					"vcaLev2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\vcaLev2)), true],
					"vcaLev3", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\vcaLev3)), true],
					"vcaLev4", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\vcaLev4)), true],
					"vcaLev5", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\vcaLev5)), true],
					"vcaTime1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\vcaTime1)), true],
					"vcaTime2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\vcaTime2)), true],
					"vcaTime3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\vcaTime3)), true],
					"vcaTime4", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\vcaTime4)), true],
					"vcaCurve1", ["knob", ControlSpec(-100, 100, step: 0.1, default: event.at(\vcaCurve1)), true],
					"vcaCurve2", ["knob", ControlSpec(-100, 100, step: 0.1, default: event.at(\vcaCurve2)), true],
					"vcaCurve3", ["knob", ControlSpec(-100, 100, step: 0.1, default: event.at(\vcaCurve3)), true],
					"vcfLev1", ["knob", ControlSpec(0, 127, step: 0.1, default: event.at(\vcfLev1)), true],
					"vcfLev2", ["knob", ControlSpec(0, 127, step: 0.1, default: event.at(\vcfLev2)), true],
					"vcfLev3", ["knob", ControlSpec(0, 127, step: 0.1, default: event.at(\vcfLev3)), true],
					"vcfLev4", ["knob", ControlSpec(0, 127, step: 0.1, default: event.at(\vcfLev4)), true],
					"vcfTime1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\vcfTime1)), true],
					"vcfTime2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\vcfTime2)), true],
					"vcfTime3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\vcfTime3)), true],
					"vcfCurve1", ["knob", ControlSpec(-100, 100, step: 0.1, default: event.at(\vcfCurve1)), true],
					"vcfCurve2", ["knob", ControlSpec(-100, 100, step: 0.1, default: event.at(\vcfCurve2)), true],
					"tu", ["knob", ControlSpec(0, 5, step: 0.01, default: event.at(\tu)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song4Pattern6 = Pbind(
	\instrument, \snapkick,
	\dur, Pseq([1.5, Rest(0.5), 0.25, Rest(0.25), Rest(0.25), 1.5, 0.25, Rest(0.5)], inf),
	\amp, 0.25,
	\pan, 0,
	\bdFrqL1, 261,
	\bdFrqL2, 116,
	\bdFrqL3, 64,
	\bdFrqT1, 0.035,
	\bdFrqT2, 0.08,
	\bdFrqC, \exp,
	\bdAmpAtt, 0.01,
	\bdAmpSus, 0.1,
	\bdAmpRel, 0.3,
	\bdAmpLev, 1.36,
	\bdAmpCurve, 47.4,
	\popFrqSt, 750,
	\popFrqEnd, 261,
	\popFrqDur, 0.04,
	\popAmpAtt, 1.32,
	\popAmpSus, 0.02,
	\popAmpRel, 0.14,
	\popAmpLev, 0.39,
	\clkAmpAtt, 0,
	\clkAmpRel, 0.01,
	\clkAmpLev, 0.99,
	\clkAmpCurve, -14.9,
	\clkfFundFreq, 910,
	\clkfFormFreq, 5078,
	\clkfBwFreq, 14776,
	\clkLpfFreq, 5612,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~snapKickSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"amp", ["knob", ControlSpec(0, 24, step: 0.01, default: event.at(\amp)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"bdFrqL1", ["knob", ControlSpec(20, 20000, step: 0.1, default: event.at(\bdFrqL1)), true],
					"bdFrqL2", ["knob", ControlSpec(20, 20000, step: 0.1, default: event.at(\bdFrqL2)), true],
					"bdFrqL3", ["knob", ControlSpec(20, 20000, step: 0.1, default: event.at(\bdFrqL3)), true],
					"bdFrqT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\bdFrqT1)), true],
					"bdFrqT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\bdFrqT2)), true],
					"bdFrqC", ["knob", ControlSpec(-200, 200, step: 0.1, default: event.at(\bdFrqC)), true],
					"bdAmpAtt", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\bdFrqC)), true],
					"bodyAmpAtt", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\bdAmpAtt)), true],
					"bdAmpSus", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\bdAmpSus)), true],
					"bdAmpRel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\bdAmpRel)), true],
					"bdAmpLev", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\bdAmpLev)), true],
					"bdAmpCurve", ["knob", ControlSpec(-200, 200, step: 0.1, default: event.at(\bdAmpCurve)), true],
					"popFrqSt", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\popFrqSt)), true],
					"popFrqEnd", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\popFrqEnd)), true],
					"popFrqDur", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\popFrqDur)), true],
					"popAmpAtt", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\popAmpAtt)), true],
					"popAmpSus", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\popAmpSus)), true],
					"popAmpRel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\popAmpRel)), true],
					"popAmpLev", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\popAmpLev)), true],
					"clkAmpAtt", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\clkAmpAtt)), true],
					"clkAmpRel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\clkAmpRel)), true],
					"clkAmpLev", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\clkAmpLev)), true],
					"clkAmpCurve", ["knob", ControlSpec(-200, 200, step: 0.1, default: event.at(\clkAmpCurve)), true],
					"clkfFundFreq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\clkfFundFreq)), true],
					"clkfFormFreq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\clkfFormFreq)), true],
					"clkfBwFreq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\clkfBwFreq)), true],
					"clkLpfFreq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\clkLpfFreq)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song4Pattern7 = Pbind(
	\instrument, \fabHi,
	\dur, 0.25,
	\amp, 0.02,
	\pan, Pwhite(-1.0, 1.0, inf),
	\wamp, 0.84,
	\envNatt, 0,
	\envNrel, 0.26,
	\wbpfFreq, 3182,
	\wbpfRq, 1,
	\sinFrq1, 1365,
	\sinFrq2, 12423,
	\sinPh1, 0,
	\sinPh2, 0.02,
	\sinLev1, 14.13,
	\sinLev2, 5.56,
	\envSatt, 0.24,
	\envSrel, 0.2,
	\mix, 0.6,
	\envL1, 0,
	\envL2, 1,
	\envL3, 0.94,
	\envT1, 0.04,
	\envT2, Pseq([0.02, 0.06, 0.01, 0.018, 0, 0.02, 0.06, 0.01, 0.018, 3.11], inf),
	\envT3, Pseq([0.07, 0.01, 0.07, 0.002, 0.03, 0.007], inf),
	\ffreq, 12018,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~fabHiSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_gate", ["none"],
					"doneAction", ["none"],
					"amp", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\amp)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"wamp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\wamp)), true],
					"envNatt", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envNatt)), true],
					"envNrel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envNrel)), true],
					"wbpfFreq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\wbpfFreq)), true],
					"wbpfRq", ["knob", ControlSpec(0.01, 1, step: 0.01, default: event.at(\wbpfRq)), true],
					"sinFrq1", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\sinFrq1)), true],
					"sinFrq2", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\sinFrq2)), true],
					"sinPh1", ["slider", ControlSpec(0, 1, step: 0.01, default: event.at(\sinPh1)), true],
					"sinPh2", ["slider", ControlSpec(0, 1, step: 0.01, default: event.at(\sinPh2)), true],
					"sinLev1", ["knob", ControlSpec(0, 24, step: 0.01, default: event.at(\sinLev1)), true],
					"sinLev2", ["knob", ControlSpec(0, 24, step: 0.01, default: event.at(\sinLev2)), true],
					"envSatt", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envSatt)), true],
					"envSrel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envSrel)), true],
					"mix", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\mix)), true],
					"envL1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL1)), true],
					"envL2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL2)), true],
					"envL3", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL3)), true],
					"envT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT1)), true],
					"envT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT2)), true],
					"envT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT3)), true],
					"ffreq", ["knob", ControlSpec(02, 20000, step: 1, default: event.at(\ffreq)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song4Pattern8 = Pbind(
	\instrument, \cym1,
	\dur, Pseq([Rest(0.125), 0.125, 0.25, 0.125, Rest(0.125), 0.25, 0.125, Rest(0.125), Rest(0.125), 0.25, 0.25, Rest(0.125), 0.25, Rest(0.125), 0.125], inf),
	\amp, 0.0065,
	\pan, Pwhite(-0.35, 0.35, inf),
	\envL1, 0.76,
	\envL2, 0,
	\envL3, 0.32,
	\envL4, 0.72,
	\levScale, 1,
	\envT1, 0.11,
	\envT2, 0.13,
	\envT3, 0.04,
	\envC1, -3.1,
	\envC2, 5,
	\envC3, -4,
	\tu, 0.56,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~cym1SynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"envL1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL1)), true],
					"envL2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL2)), true],
					"envL3", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL3)), true],
					"envL4", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL4)), true],
					"levScale", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\levScale)), true],
					"envT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT1)), true],
					"envT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT2)), true],
					"envT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT3)), true],
					"envT4", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT4)), true],
					"envC1", ["knob", ControlSpec(-200, 200, step: 0.1, default: event.at(\envC1)), true],
					"envC2", ["knob", ControlSpec(-200, 200, step: 0.1, default: event.at(\envC2)), true],
					"envC3", ["knob", ControlSpec(-200, 200, step: 0.1, default: event.at(\envC3)), true],
					"tu", ["knob", ControlSpec(0, 2, step: 0.01, default: event.at(\tu)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

///////////////////// song5

~song5Pattern1 = Pbind(
	\instrument, \t1kick2,
	\dur, Pseq([Pn(1.75, 6), 2.25, 1.25], inf), // 1.75 * 6 + 2.25 + 1.25
	\amp, 0.23,
	\pan, 0,
	\envaT1, 0.53, // 0,
	\envaL1, 1,
	\envaT2, 0.6,
	\envaL2, 1.85,
	\envaT3, 0.2,
	\envaL3, 0.5,
	\envaT4, 0.2,
	\envaL4, 0,
	\envaCurve, \exp,
	\envfT1, 0,
	\envfL1, 9752,
	\envfT2, 0.002,
	\envfL2, 20,
	\envfT3, 0.1,
	\envfL3, 0,
	\envfT4, 1,
	\envfL4, 4,
	\envfCurve, \exp,
	\pitch, 1.05,
	\hpfFreq, 597,
	\hpfRq, 1,
	\verbMix, 0.5,
	\verbRoom, 6.27,
	\verbTime, 4.75,
	\verbDamp, 0.65,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~t1kick2SynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"envaT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envaT1)), true],
					"envaL1", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envaL1)), true],
					"envaT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envaT2)), true],
					"envaL2", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envaL2)), true],
					"envaT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envaT3)), true],
					"envaL3", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envaL3)), true],
					"envaT4", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envaT4)), true],
					"envaL4", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envaL4)), true],
					"envaCurve", ["knob", ControlSpec(-20, 20, step: 0.01, default: event.at(\envaCurve)), true],
					"envfT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envfT1)), true],
					"envfL1", ["knob", ControlSpec(0, 19050, step: 1, default: event.at(\envfL1)), true],
					"envfT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envfT2)), true],
					"envfL2", ["knob", ControlSpec(0, 19050, step: 1, default: event.at(\envfL2)), true],
					"envfT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envfT3)), true],
					"envfL3", ["knob", ControlSpec(0, 19050, step: 1, default: event.at(\envfL3)), true],
					"envfT4", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envfT4)), true],
					"envfL4", ["knob", ControlSpec(0, 19050, step: 1, default: event.at(\envfL4)), true],
					"envfCurve", ["knob", ControlSpec(-20, 20, step: 0.01, default: event.at(\envfCurve)), true],
					"pitch", ["knob", ControlSpec(0, 3, step: 0.01, default: event.at(\pitch)), true],
					"hpfFreq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\hpfFreq)), true],
					"hpfRq", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\hpfRq)), true],
					"verbMix", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\verbMix)), true],
					"verbRoom", ["knob", ControlSpec(0, 100, step: 0.01, default: event.at(\verbRoom)), true],
					"verbTime", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\verbTime)), true],
					"verbDamp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\verbDamp)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song5Pattern2 = Pbind(
	\instrument, \jungleSnare,
	\dur, Pseq([Rest(0.55), 1, 1.5, 0.5, 1, 1.5, 0.95], inf), // 0.55 + 4 + 1.5 + 0.95 == 7
	\amp, 0.06,
	\pan, 0,
	\envL1, 1,
	\envL2, 0,
	\envL3, 1,
	\envL4, 0,
	\envT1, 0.02,
	\envT2, 0.05,
	\envT3, 0.34,
	\envCurve, \linear,
	\envfL1, 92.29,
	\envfL2, 295.44,
	\envfL3, 4962.07,
	\envfL4, 144.33, // 250,
	\envfT1, 0.03,
	\envfT2, 0,
	\envfT3, 0,
	\envfCurve, -18,
	\envnAtt, 0,
	\envnRel, 0.27,
	\envnCurve, -2.45,
	\noiseAmp, 0.08,
	\tu, 1.43,
	\kracter, 5.38,
	\hpf, 664,
	\hpfRq, 0.63,
	\lpf, 11779,
	\lpfRq, 0.5,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~jungleSnareSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"t_gate", ["none"],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"envL1", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envL1)), true],
					"envL2", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envL2)), true],
					"envL3", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envL3)), true],
					"envL4", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envL4)), true],
					"envT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT1)), true],
					"envT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT2)), true],
					"envT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT3)), true],
					"envCurve", ["knob", ControlSpec(-20, 20, step: 0.01, default: event.at(\envCurve)), true],
					"envfL1", ["knob", ControlSpec(0, 5000, step: 0.01, default: event.at(\envfL1)), true],
					"envfL2", ["knob", ControlSpec(0, 5000, step: 0.01, default: event.at(\envfL2)), true],
					"envfL3", ["knob", ControlSpec(0, 5000, step: 0.01, default: event.at(\envfL3)), true],
					"envfL4", ["knob", ControlSpec(0, 5000, step: 0.01, default: event.at(\envfL4)), true],
					"envfT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envfT1)), true],
					"envfT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envfT2)), true],
					"envfT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envfT3)), true],
					"envfCurve", ["knob", ControlSpec(-20, 20, step: 0.01, default: event.at(\envfCurve)), true],
					"envnAtt", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envnAtt)), true],
					"envnRel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envnRel)), true],
					"envnCurve", ["knob", ControlSpec(-20, 20, step: 0.01, default: event.at(\envnCurve)), true],
					"noiseAmp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\noiseAmp)), true],
					"tu", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\tu)), true],
					"kracter", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\kracter)), true],
					"hpf", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\hpf)), true],
					"hpfRq", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\hpfRq)), true],
					"lpf", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\lpf)), true],
					"lpfRq", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\lpfRq)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song5Pattern3 = Pbind(
	\instrument, \attBreath,
	\dur, Pdefn(\patt3_8_dur),
	\amp, 4.27,
	\pan, Pwhite(-0.75, 0.75),
	\attack, 0.01,
	\release, 1.84,
	\seqv1, 0,
	\seqv2, 3.31,
	\seqv3, 4,
	\seqv4, 3.77,
	\seqv5, 4.01,
	\seqFreq, Pseq([0.08/*, 0.04*/, 0.16], inf), // 0.08,
	\freqMin, 250,
	\freqMax, 800,
	\bwrMod, 0.1,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~attBreathSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"t_trig", ["none"],
					"amp", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\amp)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"release", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"seqv1", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\seqv1)), true],
					"seqv2", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\seqv2)), true],
					"seqv3", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\seqv3)), true],
					"seqv4", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\seqv4)), true],
					"seqv5", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\seqv5)), true],
					"seqFreq", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\seqFreq)), true],
					"freqMin", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\freqMin)), true],
					"freqMax", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\freqMax)), true],
					"bwrMod", ["knob", ControlSpec(0, 2, step: 0.01, default: event.at(\bwrMod)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song5Pattern4 = Pbind(
	\instrument, \kicklaserbeam,
	\dur, Pseq([1, 0.75], inf),
	\amp, 0.02,
	\pan, 0,
	\freq, 13007,
	\freqenvL1, 3.97,
	\freqenvL2, 5,
	\freqenvL3, 0,
	\freqenvL4, 2.97,
	\freqenvT1, 0.16,
	\freqenvT2, 0.07,
	\freqenvT3, 0.26,
	\ampenvL1, 1,
	\ampenvL2, 1,
	\ampenvL3, 0,
	\ampenvL4, 0.24,
	\ampenvT1, 0,
	\ampenvT2, 0.15,
	\ampenvT3, 0.79,
	\hpfFreq, 41,
	\hpfRq, 1,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kicklaserbeamSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"freq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\freq)), true],
					"freqenvL1", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\freqenvL1)), true],
					"freqenvL2", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\freqenvL2)), true],
					"freqenvL3", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\freqenvL3)), true],
					"freqenvL4", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\freqenvL4)), true],
					"freqenvT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\freqenvT1)), true],
					"freqenvT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\freqenvT2)), true],
					"freqenvT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\freqenvT3)), true],
					"ampenvL1", ["knob", ControlSpec(0, 5, step: 0.01, default: event.at(\ampenvL1)), true],
					"ampenvL2", ["knob", ControlSpec(0, 5, step: 0.01, default: event.at(\ampenvL2)), true],
					"ampenvL3", ["knob", ControlSpec(0, 5, step: 0.01, default: event.at(\ampenvL3)), true],
					"ampenvL4", ["knob", ControlSpec(0, 5, step: 0.01, default: event.at(\ampenvL4)), true],
					"ampenvT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\ampenvT1)), true],
					"ampenvT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\ampenvT2)), true],
					"ampenvT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\ampenvT3)), true],
					"fenvLev", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\fenvLev)), true],
					"hpfFreq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\hpfFreq)), true],
					"hpfRq", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\hpfRq)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song5Pattern5 = Pbind(
	\instrument, \kick808Aw,
	\dur, Pseq([Rest(0.75), 0.75, 1.75, 0.25/**/, Rest(0.75), 0.75, 2], inf), // 0.75+ 0.75+ 1.75+ 0.25 + 0.75+ 0.75+ 2 == 7
	\amp, 0.67,
	\pan, 0,
	\freqSrt, 23,
	\freqEnd, 34,
	\freqTime, 0,
	\ringTime, 52.63,
	\envpT1, 0,
	\envpL1, 0.07,
	\envpT2, 0.33,
	\envpL2, 0.55,
	\envpT3, 0.65,
	\envpL3, 0.95,
	\envpT4, 0.71,
	\envpL4, 0,
	\envpCurve, -20,
	\dist, 6.43,
	\hpfFreq, 42,
	\tott, 0.29,
	\durr, 0.01,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kick808AwSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"t_trig", ["none"],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"freqSrt", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\freqSrt)), true],
					"freqEnd", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\freqEnd)), true],
					"freqTime", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\freqTime)), true],
					"ringTime", ["slider", ControlSpec(0, 500, step: 0.01, default: event.at(\ringTime)), true],
					"envpT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envpT1)), true],
					"envpL1", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envpL1)), true],
					"envpT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envpT2)), true],
					"envpL2", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envpL2)), true],
					"envpT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envpT3)), true],
					"envpL3", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envpL3)), true],
					"envpT4", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envpT4)), true],
					"envpL4", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envpL4)), true],
					"rel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\rel)), true],
					"envpCurve", ["knob", ControlSpec(-20, 20, step: 0.1, default: event.at(\envCurve)), true],
					"dist", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\dist)), true],
					"hpfFreq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\hpfFreq)), true],
					"tott", ["knob", ControlSpec(0, 2, step: 0.01, default: event.at(\tott)), true],
					"durr", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\durr)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song5Pattern6 = Pbind(
	\instrument, \kick808new,
	\dur, Pseq([Rest(0.05), 1.7, Rest(0.1), 1.65], inf),
	\amp, 0.24,
	\pan, 0,
	\envL1, 1.33,
	\envL2, 0.99,
	\envL3, 0,
	\envT1, 0.27,
	\envT2, 2.11,
	\envCurve, -8,
	\enfL1, 14235,
	\enfL2, 100,
	\enfL3, 30,
	\enfT1, 0,
	\enfT2, 0.07,
	\enfCurve, -4,
	\tu, 2,
	\sin2Frq, 10,
	\sin2Amp, 48,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kick808newSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"envL1", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envL1)), true],
					"envL2", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envL2)), true],
					"envL3", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envL3)), true],
					"envT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT1)), true],
					"envT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT2)), true],
					"envCurve", ["knob", ControlSpec(-20, 20, step: 0.01, default: event.at(\envCurve)), true],
					"enfL1", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\enfL1)), true],
					"enfL2", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\enfL2)), true],
					"enfL3", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\enfL3)), true],
					"enfT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envfT1)), true],
					"enfT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envfT2)), true],
					"enfCurve", ["knob", ControlSpec(-20, 20, step: 0.01, default: event.at(\enfCurve)), true],
					"tu", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\tu)), true],
					"sin2Frq", ["knob", ControlSpec(1, 20000, step: 1, default: event.at(\sin2Frq)), true],
					"sin2Amp", ["knob", ControlSpec(1, 100, step: 1, default: event.at(\sin2Amp)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song5Pattern7 = Pbind(
	\instrument, \kickParallax,
	\dur, Pseq([Pn(0.125, 12), 0.25], inf), // (0.125 * 12) + 0.25 == 1.75
	\amp, Pseq([0.3, 0.25, 0.3, 0.15], inf),
	\pan, Pwhite(-1.0, 1.0),
	\envAmpAtt, 0,
	\envAmpRel, 0.01,
	\envFrqAtt, 0,
	\envFrqRel, 0.03,
	\freq, 15039,
	\kharm1, 20,
	\kharm2, 13544,
	\kharm3, 8241,
	\kharm4, 16451,
	\kamp1, 0.3,
	\kamp2, 0.05,
	\kamp3, 0.06,
	\kamp4, 0,
	\kring1, 0.18,
	\kring2, 3.16,
	\kring3, 0.06,
	\kring4, 0,
	\frqScale, 1,
	\decScale, 1,
	\resoMix, 0,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kickParallaxSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\amp)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"envAmpAtt", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envAmpAtt)), true],
					"envAmpRel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envAmpRel)), true],
					"envFrqAtt", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envFrqAtt)), true],
					"envFrqRel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envFrqRel)), true],
					"freq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\freq)), true],
					"kharm1", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\kharm1)), true],
					"kharm2", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\kharm2)), true],
					"kharm3", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\kharm3)), true],
					"kharm4", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\kharm4)), true],
					"kamp1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\kamp1)), true],
					"kamp2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\kamp2)), true],
					"kamp3", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\kamp3)), true],
					"kamp4", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\kamp4)), true],
					"kring1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\kring1)), true],
					"kring2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\kring2)), true],
					"kring3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\kring3)), true],
					"kring4", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\kring4)), true],
					"frqScale", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\frqScale)), true],
					"decScale", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\decScale)), true],
					"resoMix", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\resoMix)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song5Pattern8 = Pbind(
	\instrument, \hat909,
	\dur, Pdefn(\patt3_8_dur),
	\amp, 0.08, // 0.12,
	\pan, Pseg(Pwhite(-0.5, 0.5), Pwhite(0.1, 0.3), 'lin', inf),
	\envL1, 0,
	\envL2, 0.99,
	\envL3, 0.45, // 0.3,
	\envL4, 0, // 0.98,
	\envT1, 0.5,
	\envT2, 0.03, // 0.01,
	\envT3, 0, // 0.39,
	\envCurve, -20, // 0,
	\freq, 225, // 144,
	\hpf, 8241,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~hat909SynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"gate", ["none"],
					"amp", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\amp)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"envL1", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envL1)), true],
					"envL2", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envL2)), true],
					"envL3", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envL3)), true],
					"envL4", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envL4)), true],
					"envT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT1)), true],
					"envT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT2)), true],
					"envT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT3)), true],
					"envCurve", ["slider", ControlSpec(-20, 20, step: 0.01, default: event.at(\envCurve)), true],
					"freq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\freq)), true],
					"hpf", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\hpf)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song5Pattern9 = Pbind(
	\instrument, \tweetSynth,
	\dur, 1.75, // Pseq([1.75, 3.5, 1.75], inf),
	\amp, 0.05,
	\freq, 51,
	\rate, 8.5,
	\attack, 0.01,
	\release, 9.47,
	\thresh, 0.46,
	\ratio, 0.82,
	\revMix, 0,
	\revRoom, 0.5,
	\revDamp, 0.5,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~tweetSynthSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"t_trig", ["none"],
					"amp", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\amp)), true],
					"freq", ["knob", ControlSpec(0, 2000, step: 0.01, default: event.at(\freq)), true],
					"rate", ["knob", ControlSpec(1, 120, step: 0.1, default: event.at(\rate)), true],
					"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"release", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"thresh", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\thresh)), true],
					"ratio", ["knob", ControlSpec(0, 2, step: 0.01, default: event.at(\ratio)), true],
					"revMix", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\revMix)), true],
					"revRoom", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\revRoom)), true],
					"revDamp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\revDamp)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

///////////////////// song6

/*~song6Pattern1 = Pbind(
	\instrument, \tweetSynth,
	\dur, Pseq([2.5, 5, 1.25, 5, 2.5, 1.25, 2.5], inf), // 2.5+ 5+ 1.25+ 5+ 2.5+ 1.25+ 2.5
	\amp, 0.42,
	\freq, Pseq([Pn(36.5, 4), 35.5], inf),
	\rate, Pseq([91, 8.5], inf),
	\attack, 0.01,
	\release, 10,
	\sigatt, 0.01,
	\sigdec, 3.16,
	\thresh, 0.48,
	\ratio, 0.82,
	\revMix, 0.84,
	\revRoom, 0.07,
	\revDamp, 0.12,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~tweetSynthSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"t_trig", ["none"],
					"amp", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\amp)), true],
					"freq", ["knob", ControlSpec(0, 1000, step: 0.01, default: event.at(\freq)), true],
					"rate", ["knob", ControlSpec(1, 120, step: 0.1, default: event.at(\rate)), true],
					"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"release", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"sigatt", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\sigatt)), true],
					"sigdec", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\sigdec)), true],
					"thresh", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\thresh)), true],
					"ratio", ["knob", ControlSpec(0, 2, step: 0.01, default: event.at(\ratio)), true],
					"revMix", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\revMix)), true],
					"revRoom", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\revRoom)), true],
					"revDamp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\revDamp)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);*/

~song6Pattern1 = Pbind(
	\instrument, \complexosc,
	\dur, Pdefn(\patt1_6_dur),
	\amp, 0.02,
	\feedBack, 0.42,
	\envL1, 2,
	\envL2, 0,
	\envL3, 0,
	\envL4, 0.99,
	\envT1, 0.64,
	\envT2, 0.52,
	\envT3, 0.19,
	\envCurve, -7.35,
	\freq1, 1,
	\fm1, 5000,
	\pm1, 8.94,
	\amp1, 0.8,
	\ring1, 3.62,
	\offset1, Pseq([0, -6.2, 0.23, 7], inf),
	\freq2, Pseq([32.09, 12.3], inf),
	\fm2, 0,
	\pm2, 0.8,
	\amp2, 0.27,
	\ring2, Pseq([0.1, 0.03, 0.07, 0, 0.01], inf),
	\offset2, -1.96,
	\fold, 0.9,
	\wrap, 0.82,
	\switch, 2,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~complexoscSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"t_trig", ["none"],
					"amp", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\amp)), true],
					"feedBack", ["slider", ControlSpec(0, 2, step: 0.01, default: event.at(\feedBack)), true],
					"envL1", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envL1)), true],
					"envL2", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envL2)), true],
					"envL3", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envL3)), true],
					"envL4", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\envL4)), true],
					"envT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT1)), true],
					"envT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT2)), true],
					"envT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT3)), true],
					"envCurve", ["slider", ControlSpec(-20, 20, step: 0.01, default: event.at(\envCurve)), true],
					"freq1", ["knob", ControlSpec(0, 20000, step: 1, default: event.at(\freq1)), true],
					"fm1", ["knob", ControlSpec(0, 10000, step: 1, default: event.at(\fm1)), true],
					"pm1", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\pm1)), true],
					"amp1", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\amp1)), true],
					"ring1", ["knob", ControlSpec(0, 20, step: 0.01, default: event.at(\ring1)), true],
					"offset1", ["knob", ControlSpec(-4, 4, step: 0.01, default: event.at(\offset1)), true],
					"freq2", ["knob", ControlSpec(0, 1000, step: 0.01, default: event.at(\freq2)), true],
					"fm2", ["knob", ControlSpec(0, 100, step: 0.01, default: event.at(\fm2)), true],
					"pm2", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\pm2)), true],
					"amp2", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\amp2)), true],
					"ring2", ["knob", ControlSpec(0, 20, step: 0.01, default: event.at(\ring2)), true],
					"offset2", ["knob", ControlSpec(-4, 4, step: 0.01, default: event.at(\offset2)), true],
					"fold", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\fold)), true],
					"warp", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\warp)), true],
					"switch", ["knob", ControlSpec(0, 3, step: 1, default: event.at(\switch)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song6Pattern2 = Pbind(
	\instrument, \fabHi1,
	\dur, Pseq([Rest(1.25), 0.75, 1.75, Rest(0.25), 1], inf), // 1.25+ 0.75+ 1.75+ 0.25 +1 == 5
	\amp, 0.1,
	\pan, 0,
	\wamp, 1,
	\envNatt, 0.01,
	\envNrel, 0.36,
	\wbpfFreq, 10010,
	\wbpfRq, 1,
	\sinFrq1, 469,
	\sinFrq2, 133,
	\sinPh1, 0,
	\sinPh2, 0.21,
	\sinLev1, 2.67,
	\sinLev2, 6.54,
	\envSatt, 0,
	\envSrel, 0.47,
	\mix, -0.3,
	\envL1, 0,
	\envL2, 1,
	\envL3, 1,
	\envL4, 0,
	\envT1, 0,
	\envT2, 0.01,
	\envT3, 0,
	\ffreq, 2,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~fabHi1SynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_gate", ["none"],
					"doneAction", ["none"],
					"amp", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\amp)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"wamp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\wamp)), true],
					"envNatt", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envNatt)), true],
					"envNrel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envNrel)), true],
					"wbpfFreq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\wbpfFreq)), true],
					"wbpfRq", ["knob", ControlSpec(0.01, 1, step: 0.01, default: event.at(\wbpfRq)), true],
					"sinFrq1", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\sinFrq1)), true],
					"sinFrq2", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\sinFrq2)), true],
					"sinPh1", ["slider", ControlSpec(0, 1, step: 0.01, default: event.at(\sinPh1)), true],
					"sinPh2", ["slider", ControlSpec(0, 1, step: 0.01, default: event.at(\sinPh2)), true],
					"sinLev1", ["knob", ControlSpec(0, 24, step: 0.01, default: event.at(\sinLev1)), true],
					"sinLev2", ["knob", ControlSpec(0, 24, step: 0.01, default: event.at(\sinLev2)), true],
					"envSatt", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envSatt)), true],
					"envSrel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envSrel)), true],
					"mix", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\mix)), true],
					"envL1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL1)), true],
					"envL2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL2)), true],
					"envL3", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL3)), true],
					"envL4", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL4)), true],
					"envT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT1)), true],
					"envT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT2)), true],
					"envT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT3)), true],
					"ffreq", ["knob", ControlSpec(02, 20000, step: 1, default: event.at(\ffreq)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song6Pattern3 = Pbind(
	\instrument, \tweetFogAttack,
	\dur, Pseq([2.5, 5, 2.5], inf),
	\amp, 0.24,
	\attack, 0.01,
	\release, 2.5,
	\sigatt, 0,
	\sigdec, 2.11, // Pseq([2.11, 5, 2.11], inf),
	\feedBack, Pseq([0.04, 0.04, 0.025], inf),
	\freq, Pseq([1.42, 1.03, 0.91], inf),
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~tweetFogAttackSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"t_trig", ["none"],
					"amp", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\amp)), true],
					"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"release", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"sigatt", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\sigatt)), true],
					"sigdec", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\sigdec)), true],
					"feedBack", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\feedBack)), true],
					"freq", ["knob", ControlSpec(0, 1000, step: 0.01, default: event.at(\freq)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song6Pattern4 = Pbind(
	\instrument, \IkedaBass,
	\dur, Pseq([Rest(0.5), 1, 0.25, Rest(1), 0.75, 1, Rest(0.5)/**/, 1, Rest(1), 0.75, 1, 0.75, 0.5], inf), // 0.5+ 1+ 0.25+ 1+ 0.75+ 1+ 0.5+ 1+ 1+ 0.75+ 1+ 0.75+ 0.5 == 10
	\amp, 2.18,
	\pan, 0,
	\envL1, 0,
	\envL2, 0.25,
	\envL3, 0.4,
	\envL4, 0,
	\envT1, 0,
	\envT2, 0.21,
	\envT3, 0.08,
	\envCurve, -5,
	\freq, 0,
	\sweep1, 32.1,
	\sweep2, 168.3,
	\vol1, 2,
	\vol2, 0.09,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~ikedaBassSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"t_trig", ["none"],
					"amp", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\amp)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"envL1", ["knob", ControlSpec(0, 5, step: 0.01, default: event.at(\envL1)), true],
					"envL2", ["knob", ControlSpec(0, 5, step: 0.01, default: event.at(\envL2)), true],
					"envL3", ["knob", ControlSpec(0, 5, step: 0.01, default: event.at(\envL3)), true],
					"envL4", ["knob", ControlSpec(0, 5, step: 0.01, default: event.at(\envL4)), true],
					"envT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT1)), true],
					"envT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT2)), true],
					"envT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT3)), true],
					"envCurve", ["knob", ControlSpec(-20, 20, step: 0.01, default: event.at(\envCurve)), true],
					"freq", ["knob", ControlSpec(0, 1000, step: 0.01, default: event.at(\freq)), true],
					"sweep1", ["knob", ControlSpec(0.01, 10000, step: 0.1, default: event.at(\sweep1)), true],
					"sweep2", ["knob", ControlSpec(0.01, 10000, step: 0.1, default: event.at(\sweep2)), true],
					"vol1", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\vol1)), true],
					"vol2", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\vol2)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song6Pattern5 = Pbind(
	\instrument, \kickMist,
	\dur, Pseq([Rest(0.25), 0.5, 1, Rest(1.25), 1.25, Rest(0.75)/**/, Rest(0.25), 0.75, 0.75, Rest(1.25), 1.25, Rest(0.75)], inf), // 0.25+ 0.5+ 1+ 1.25+ 1.25+ 0.75+ 0.25+ 0.75+ 0.75+ 1.25+ 1.25+ 0.75 == 10
	\level, 0.1,
	\tu, 0.8,
	\noise, 1,
	\env0L1, 0,
	\env0L2, 14,
	\env0L3, 0.29,
	\env0L4, 0,
	\env0T1, 0,
	\env0T2, 0.15,
	\env0T3, 5.26,
	\env1L1, 158.71, // 150.84,
	\env1L2, 0,
	\env1L3, 26.93,
	\env1T1, 0,
	\env1T2, 0,
	\pan, 0,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kickMistSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"level", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\level)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"tu", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\tu)), true],
					"env0L1", ["knob", ControlSpec(0, 400, step: 0.01, default: event.at(\env0L1)), true],
					"env0L2", ["knob", ControlSpec(0, 400, step: 0.01, default: event.at(\env0L2)), true],
					"env0L3", ["knob", ControlSpec(0, 400, step: 0.01, default: event.at(\env0L3)), true],
					"env0L4", ["knob", ControlSpec(0, 400, step: 0.01, default: event.at(\env0L4)), true],
					"env0T1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\env0T1)), true],
					"env0T2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\env0T2)), true],
					"env0T3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\env0T3)), true],
					"env1L1", ["knob", ControlSpec(0, 400, step: 0.01, default: event.at(\env1L1)), true],
					"env1L2", ["knob", ControlSpec(0, 400, step: 0.01, default: event.at(\env1L2)), true],
					"env1L3", ["knob", ControlSpec(0, 400, step: 0.01, default: event.at(\env1L3)), true],
					"env1T1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\env0T1)), true],
					"env1T2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\env0T2)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song6Pattern6 = Pbind(
	\instrument, \kick2new,
	\dur, Pdefn(\patt1_6_dur), // 0.125+ 0.25+ 0.125+ 0.25+ 0.5 == 1.25 // 1.25*4 == 5
	\amp, 2.5,
	\pan, 0,
	\att, 0,
	\rel, 1,
	\envfT1, 0.002,
	\envfT2, 0.1,
	\freq, 60,
	\tu, 1.33,
	\bpeqf1, 3081,
	\bpeqrq1, 0.71,
	\bpeqamp1, -54,
	\bpeqf2, 800,
	\bpeqrq2, 10,
	\bpeqamp2, -12,
	\hpff, 81,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~kick2newSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"t_gate", ["none"],
					"amp", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\amp)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"att", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\att)), true],
					"rel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\rel)), true],
					"envfT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envfT1)), true],
					"envfT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envfT2)), true],
					"freq", ["knob", ControlSpec(0, 20000, step: 1, default: event.at(\freq)), true],
					"tu", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\tu)), true],
					"bpeqf1", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\bpeqf1)), true],
					"bpeqrq1", ["knob", ControlSpec(0, 20, step: 0.01, default: event.at(\bpeqrq1)), true],
					"bpeqamp1", ["knob", ControlSpec(-60, 60, step: 0.01, default: event.at(\bpeqamp1)), true],
					"bpeqf2", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\bpeqf2)), true],
					"bpeqrq2", ["knob", ControlSpec(0, 20, step: 0.01, default: event.at(\bpeqrq2)), true],
					"bpeqamp2", ["knob", ControlSpec(-60, 60, step: 0.01, default: event.at(\bpeqamp2)), true],
					"hpff", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\hpff)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song6Pattern7 = Pbind(
	\instrument, \fabHi1,
	\dur, Pseq([0.125, 0.25, Rest(0.125), 0.125, Rest(0.25), 0.125, Pn(0.125, 6), 0.125, Rest(0.25), 0.125, 0.25], inf), // 0.125+ 0.25+      0.125+  0.125+      0.25+  0.125+  (0.125 * 6)+ 0.125+      0.25+  0.125+ 0.25 == 2.5
	\amp, Pseq([0.02, 0.015, 0.01, 0.005, 0.01, 0.02, 0.005, 0.015, 0.005, 0.01]+0.015, inf),
	\pan, Pwhite(-1.0, 1.0, inf),
	\wamp, 1,
	\envNatt, 0,
	\envNrel, 1.05,
	\wbpfFreq, 6255,
	\wbpfRq, 0.04,
	\sinFrq1, 266,
	\sinFrq2, 13353,
	\sinPh1, 0,
	\sinPh2, 0,
	\sinLev1, 5.56,
	\sinLev2, 15.25,
	\envSatt, 0,
	\envSrel, 0.07,
	\mix, -0.11,
	\envL1, 0,
	\envL2, 1,
	\envL3, 1,
	\envL4, 0,
	\envT1, Pseq([0.01, 0], inf),
	\envT2, 0,
	\envT3, 0,
	\ffreq, 1600,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~fabHi1SynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"t_gate", ["none"],
					"doneAction", ["none"],
					"amp", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\amp)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"wamp", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\wamp)), true],
					"envNatt", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envNatt)), true],
					"envNrel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envNrel)), true],
					"wbpfFreq", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\wbpfFreq)), true],
					"wbpfRq", ["knob", ControlSpec(0.01, 1, step: 0.01, default: event.at(\wbpfRq)), true],
					"sinFrq1", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\sinFrq1)), true],
					"sinFrq2", ["knob", ControlSpec(20, 20000, step: 1, default: event.at(\sinFrq2)), true],
					"sinPh1", ["slider", ControlSpec(0, 1, step: 0.01, default: event.at(\sinPh1)), true],
					"sinPh2", ["slider", ControlSpec(0, 1, step: 0.01, default: event.at(\sinPh2)), true],
					"sinLev1", ["knob", ControlSpec(0, 24, step: 0.01, default: event.at(\sinLev1)), true],
					"sinLev2", ["knob", ControlSpec(0, 24, step: 0.01, default: event.at(\sinLev2)), true],
					"envSatt", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envSatt)), true],
					"envSrel", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envSrel)), true],
					"mix", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\mix)), true],
					"envL1", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL1)), true],
					"envL2", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL2)), true],
					"envL3", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL3)), true],
					"envL4", ["knob", ControlSpec(0, 1, step: 0.01, default: event.at(\envL4)), true],
					"envT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT1)), true],
					"envT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT2)), true],
					"envT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT3)), true],
					"ffreq", ["knob", ControlSpec(02, 20000, step: 1, default: event.at(\ffreq)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~song6Pattern8 = Pbind(
	\instrument, \cymbalicMcld,
	\dur, Pseq([0.5, 0.25, 0.125, 0.75, 0.125, 0.5, 0.25], inf), // 0.5+ 0.25+ 0.125+ 0.75+ 0.125+ 0.5+ 0.25 == 2.5
	\amp, 0.0085,
	\attLowf, 0.06,
	\relLowf, 1.58,
	\lowNoiseLev, 0.23,
	\attHif, 0.18,
	\relHif, 0.02,
	\hiNoiseLev, 0.33,
	\attHi, 0.03,
	\relHi, 0.23,
	\hiLev, 0,
	\attTh, 0,
	\relTh, Pseq([2.89, 2.89, 0.24, 2.89, 0.04], inf),
	\freq1, 460,
	\freq2, 540,
	\freq3, 13807,
	\freq4, 476,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~cymbalicMcldSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"t_trig", ["none"],
					"amp", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\amp)), true],
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: event.at(\pan)), true],
					"attLowf", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attLowf)), true],
					"relLowf", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\relLowf)), true],
					"lowNoiseLev", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\lowNoiseLev)), true],
					"attHif", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attHif)), true],
					"relHif", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\relHif)), true],
					"hiNoiseLev", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\hiNoiseLev)), true],
					"attHi", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attHi)), true],
					"relHi", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\relHi)), true],
					"hiLev", ["knob", ControlSpec(0, 4, step: 0.01, default: event.at(\hiLev)), true],
					"attTh", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attTh)), true],
					"relTh", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\relTh)), true],
					"freq1", ["knob", ControlSpec(02, 20000, step: 1, default: event.at(\freq1)), true],
					"freq2", ["knob", ControlSpec(02, 20000, step: 1, default: event.at(\freq2)), true],
					"freq3", ["knob", ControlSpec(02, 20000, step: 1, default: event.at(\freq3)), true],
					"freq4", ["knob", ControlSpec(02, 20000, step: 1, default: event.at(\freq4)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

/*~song6Pattern9 = Pbind(
	\instrument, \talters,
	\dur, Pseq([2.5, 5, 2.5], inf),
	\amp, 0.03,
	\attack, 0.01,
	\release, 9,
	\feedBack, 1.5,
	\freq, 18,
	\freqL1, 0.15,
	\freqL2, 3.21,
	\freqL3, 5,
	\freqL4, 2.5,
	\freqT1, 0.07,
	\freqT2, 0.76,
	\freqT3, 0.02,
	\freqCurve, -8.91,
	\decDens, 0.37,
	\decTimeFreq, 0.1,
	\decamp, 894,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~taltersSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"t_trig", ["none"],
					"amp", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\amp)), true],
					"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"release", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"feedBack", ["knob", ControlSpec(0.01, 10, step: 0.01, default: event.at(\feedBack)), true],
					"freq", ["knob", ControlSpec(0, 20000, step: 1, default: event.at(\freq)), true],
					"freqL1", ["knob", ControlSpec(0, 1000, step: 0.01, default: event.at(\freqL1)), true],
					"freqL2", ["knob", ControlSpec(0, 1000, step: 0.01, default: event.at(\freqL2)), true],
					"freqL3", ["knob", ControlSpec(0, 1000, step: 0.01, default: event.at(\freqL3)), true],
					"freqL4", ["knob", ControlSpec(0, 1000, step: 0.01, default: event.at(\freqL4)), true],
					"freqT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\freqT1)), true],
					"freqT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\freqT2)), true],
					"freqT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\freqT3)), true],
					"freqCurve", ["knob", ControlSpec(-20, 20, step: 0.01, default: event.at(\freqCurve)), true],
					"decDens", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\decDens)), true],
					"decTimeFreq", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\decTimeFreq)), true],
					"decamp", ["slider", ControlSpec(0, 2000, step: 0.1, default: event.at(\decamp)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);*/

/*~song6Pattern9 = Pbind(
	\instrument, \talters1,
	\dur, Pseq([2.5, 5, 2.5], inf),
	\amp, 0.12,
	\attack, 0.01,
	\release, 9,
	\feedBack, 2.01,
	\envL1, 0,
	\envL2, 0,
	\envL3, 25.96,
	\envL4, 7.27,
	\envT1, 0.49,
	\envT2, 0.79,
	\envT3, 0.53,
	\envCurve, -8.03,
	\decDens, 10,
	\decTimeFreq, 10,
	\decamp, 894,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~talters1SynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"t_trig", ["none"],
					"amp", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\amp)), true],
					"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\attack)), true],
					"release", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"feedBack", ["knob", ControlSpec(0.01, 10, step: 0.01, default: event.at(\feedBack)), true],
					"envL1", ["knob", ControlSpec(0, 20000, step: 0.1, default: event.at(\envL1)), true],
					"envL2", ["knob", ControlSpec(0, 20000, step: 0.1, default: event.at(\envL2)), true],
					"envL3", ["knob", ControlSpec(0, 20000, step: 0.1, default: event.at(\envL3)), true],
					"envL4", ["knob", ControlSpec(0, 20000, step: 0.1, default: event.at(\envL4)), true],
					"envT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT1)), true],
					"envT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT2)), true],
					"envT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envT3)), true],
					"envCurve", ["knob", ControlSpec(-20, 20, step: 0.01, default: event.at(\envCurve)), true],
					"decDens", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\decDens)), true],
					"decTimeFreq", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\decTimeFreq)), true],
					"decamp", ["slider", ControlSpec(0, 2000, step: 0.1, default: event.at(\decamp)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);*/

~song6Pattern9 = Pbind(
	\instrument, \polishFab,
	\dur, 5, // Pseq([2.5, 5, 2.5], inf),
	\amp, 0.36,
	\attack, 11,
	\release, 6,
	\feedBack, 88.9,
	\phmodFrq, 0.2,
	\freq1, 50,
	\freq2, 23,
	\envfL1, 0,
	\envfL2, 3,
	\envfL3, 2,
	\envfL4, 11,
	\envfT1, 0.2,
	\envfT2, 0.26,
	\envfT3, 0.12,
	\envfCure, -4,
	\frqScale, 12.26,
	\out, ~channelBus[1],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~polishFabSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"doneAction", ["none"],
					"t_trig", ["none"],
					"amp", ["knob", ControlSpec(0, 10, step: 0.01, default: event.at(\amp)), true],
					"attack", ["slider", ControlSpec(0, 20, step: 0.01, default: event.at(\attack)), true],
					"release", ["slider", ControlSpec(0, 20, step: 0.01, default: event.at(\release)), true],
					"feedBack", ["knob", ControlSpec(0.01, 100, step: 0.1, default: event.at(\feedBack)), true],
					"phmodFrq", ["knob", ControlSpec(0, 250, step: 0.1, default: event.at(\phmodFrq)), true],
					"freq1", ["knob", ControlSpec(0, 20000, step: 1, default: event.at(\freq1)), true],
					"freq2", ["knob", ControlSpec(0, 20000, step: 1, default: event.at(\freq2)), true],
					"envfL1", ["knob", ControlSpec(0, 20000, step: 1, default: event.at(\envfL1)), true],
					"envfL2", ["knob", ControlSpec(0, 20000, step: 1, default: event.at(\envfL2)), true],
					"envfL3", ["knob", ControlSpec(0, 20000, step: 1, default: event.at(\envfL3)), true],
					"envfL4", ["knob", ControlSpec(0, 20000, step: 1, default: event.at(\envfL4)), true],
					"envfT1", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envfT1)), true],
					"envfT2", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envfT2)), true],
					"envfT3", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\envfT3)), true],
					"envfCure", ["knob", ControlSpec(-20, 20, step: 0.01, default: event.at(\envfCure)), true],
					"frqScale", ["knob", ControlSpec(0, 2000, step: 0.01, default: event.at(\frqScale)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

///////////////////// test pattern

~pattern1 = Pbind(
	\instrument, \samplerStereo,
	\dur, Pdefn(\durSnapkick),
	\amp, 0.7,
	\out, ~channelBus[0],
	\function, Pfunc({ arg event;
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~samplerStereoSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), true],
					"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: 0), true],
					"gate", ["none"],
					"loop", ["button", ControlSpec(0, 1, step: 1, default: 0), true],
					"amp", ["knob", ControlSpec(0, 2, step: 0.1, default: event.at(\amp)), true],
					"startPos", ["slider", ControlSpec(0, 1, step: 0.01, default: event.at(\startPos)), true],
					"rate", ["knob", ControlSpec(0.01, 1, step: 0.01, default: event.at(\rate)), true],
					"release", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\release)), true],
					"curve", ["knob", ControlSpec(-20, 20, step: 0.01, default: event.at(\curve)), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	})
);

~pattern2 = Pbind(
	\instrument, \sinBass,
	\amp, 1.84,
	\dur, 1.5,//Pdefn(\durSnapkick),
	\function, Pfunc({ arg event; // Pif ? or Pn(Plazy, inf)
		var currentInstr, synthWindowKey, instance, ccStart, midiChan;
		currentInstr = event.at(\instrument);

		if (currentInstr != ~pdefPrevInstr, {
			synthWindowKey = (~pdefPrevInstr ++ ~pdefName).asString;
			instance = ~pdefName.asSymbol;
			ccStart = ~pdefCcStart.asInt;
			midiChan = ~pdefMidiChan.asInt;
			{
				~removePrev.value(synthWindowKey);
				~autoGui.value(v, ~sinBassSynthDef, instance, ccStart, midiChan, Color.white, Dictionary.newFrom(List[
					"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), false],
					"amp", ["slider", ControlSpec(0, 10, step: 0.01, default: event.at(\amp)), true],
					"gate", ["none"],
					"curve", ["knob", ControlSpec(-20, 20, step: 1, default: 0), true],
					"loopNode", ["knob", ControlSpec(0, 4, step: 1, default: 0), true],
					"attack", ["knob", ControlSpec(0, 10, step: 0.01, default: 0.2), true],
					"release", ["knob", ControlSpec(0, 10, step: 0.01, default: 4), true],
					"envLevel1", ["knob", ControlSpec(0, 80, step: 0.1, default: 0), true],
					"envLevel2", ["knob", ControlSpec(0, 80, step: 0.1, default: 40), true],
					"envLevel3", ["knob", ControlSpec(0, 80, step: 0.1, default: 32), true],
					"envLevel4", ["knob", ControlSpec(0, 80, step: 0.1, default: 50), true],
					"envLevel5", ["knob", ControlSpec(0, 80, step: 0.1, default: 0), true],
					"envLevel6", ["knob", ControlSpec(0, 80, step: 0.1, default: 60), true],
					"envTime1", ["knob", ControlSpec(0, 1, step: 0.01, default: 0.5), true],
					"envTime2", ["knob", ControlSpec(0, 1, step: 0.01, default: 0.3), true],
					"envTime3", ["knob", ControlSpec(0, 1, step: 0.01, default: 0.25), true],
					"envTime4", ["knob", ControlSpec(0, 1, step: 0.01, default: 1), true],
					"envTime5", ["knob", ControlSpec(0, 1, step: 0.01, default: 0.5), true]
				]));
			}.defer;
			~pdefPrevInstr = currentInstr;
		});
		0;
	}),
	\out, ~channelBus[0]
);

)
