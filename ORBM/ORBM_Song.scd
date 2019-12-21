(

///////////////////////////////////////  Song

~defaultSong = { // ~globalQuant = 1; // !!! change globalQuant before song !!!
	t.tempo = 60 / 60;
	{
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "startPos").valueAction_(0.07);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "rate").valueAction_(0.21);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "attack").valueAction_(10);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "release").valueAction_(2);

		~autoGuiControl.at("inputSig" ++ ~nodeId.at("inputSoftPop") ++ "attack").valueAction_(6);
		~autoGuiControl.at("inputSig" ++ ~nodeId.at("inputSoftPop") ++ "release").valueAction_(3);
	}.defer;
	~songInit.value;
	loop {
		~changePattern.value(Pdef(\unit1), ~defaultPattern1);
		~changePattern.value(Pdef(\unit6), ~defaultPattern6);
		10.0.wait;
		{ ~mute.at("unit1").valueAction_(1); }.defer; // mute unit1 & update gui
		2.0.wait;
		{ ~mute.at("unit6").valueAction_(1); }.defer;
		2.0.wait;
		{
			~mute.at("unit1").valueAction_(0);
			~mute.at("unit6").valueAction_(0);
		}.defer;
		~changePattern.value(Pdef(\unit2), ~defaultPattern2);
		10.0.wait;
		{ ~mute.at("unit1").valueAction_(1); }.defer;
		2.0.wait;
		{
			~mute.at("unit2").valueAction_(1);
			~mute.at("unit6").valueAction_(1);
		}.defer;
		2.0.wait;
		{
			~mute.at("unit1").valueAction_(0);
			~mute.at("unit2").valueAction_(0);
			~mute.at("unit6").valueAction_(0);
		}.defer;
		~changePattern.value(Pdef(\unit1), ~defaultPattern1);
		~changePattern.value(Pdef(\unit2), ~defaultPattern2);
		~changePattern.value(Pdef(\unit3), ~defaultPattern3);
		~changePattern.value(Pdef(\unit4), ~defaultPattern4);
		~changePattern.value(Pdef(\unit5), ~defaultPattern5);
		~changePattern.value(Pdef(\unit6), ~defaultPattern6);
		~changePattern.value(Pdef(\unit7), ~defaultPattern7);
		~changePattern.value(Pdef(\unit8), ~defaultPattern8);
		25.0.wait;
		{ ~mute.at("unit1").valueAction_(1); }.defer;
		1.0.wait;
		{ ~mute.at("unit7").valueAction_(1); }.defer;
		1.0.wait;
		{ ~mute.at("unit3").valueAction_(1); }.defer;
		1.0.wait;
		{ ~mute.at("unit5").valueAction_(1); }.defer;
		1.0.wait;
		{
			~mute.at("unit2").valueAction_(1);
			~mute.at("unit4").valueAction_(1);
			~mute.at("unit6").valueAction_(1);
			~mute.at("unit8").valueAction_(1);

		}.defer;
		1.0.wait;
		{
			~channel[\aux10].valueAction_(0.02); // set SynthDef & update gui
			~channel[\aux11].valueAction_(0.25);
			~mute.at("unit1").valueAction_(0);
			~mute.at("unit3").valueAction_(0);
			~mute.at("unit4").valueAction_(0);
			~mute.at("unit5").valueAction_(0);
			~mute.at("unit6").valueAction_(0);
			~mute.at("unit7").valueAction_(0);
			~mute.at("unit8").valueAction_(0);

		}.defer;
		5.0.wait;
		{
			~channel[\aux21].valueAction_(0.5);
			~channel[\aux13].valueAction_(0.2);
		}.defer;
		20.0.wait;
		{ ~mute.at("unit7").valueAction_(1); }.defer;
		5.0.wait;
		{
			~mute.at("unit3").valueAction_(1);
			~mute.at("unit7").valueAction_(0);
		}.defer;
		10.0.wait;
		{
			~mute.at("unit1").valueAction_(1);
			~mute.at("unit4").valueAction_(1);
			~channel[\aux10].valueAction_(0);
			~channel[\aux11].valueAction_(0);
			~channel[\aux22].valueAction_(0.04);
		}.defer;
		2.5.wait;
		{
			~mute.at("unit5").valueAction_(1);
			~mute.at("unit7").valueAction_(1);
			~channel[\aux13].valueAction_(0);
		}.defer;
		5.0.wait;
		{
			~mute.at("unit6").valueAction_(1);
			~mute.at("unit8").valueAction_(1);
		}.defer;
		2.5.wait;
		{
			~channel[\aux21].valueAction_(0);
			~channel[\aux22].valueAction_(0);
			~mute.at("unit1").valueAction_(0);
			~mute.at("unit2").valueAction_(0);
			~mute.at("unit3").valueAction_(0);
			~mute.at("unit4").valueAction_(0);
			~mute.at("unit5").valueAction_(0);
			~mute.at("unit6").valueAction_(0);
			~mute.at("unit7").valueAction_(0);
			~mute.at("unit8").valueAction_(0);
			~autoGuiControl.at("IkedaBreathunit2note1").valueAction_(76.9);
			~autoGuiControl.at("IkedaBreathunit2note2").valueAction_(86.9);
			~autoGuiControl.at("kick2unit7freq").valueAction_(515.69);
			~autoGuiControl.at("kick2unit7tu").valueAction_(0.55);
			~autoGuiControl.at("t1kick2unit8snd").valueAction_(17.95);
			~autoGuiControl.at("t1kick2unit8rel").valueAction_(3.68);
			~autoGuiControl.at("t1kick2unit8pitch").valueAction_(1.38);
		}.defer;
		40.0.wait;
		Pbindef(\unit7, \dur, 0.125).quant_(~globalQuant);
		8.0.wait;
		{ ~mute.at("unit7").valueAction_(1); }.defer;
		2.0.wait;
		{
			~mute.at("unit7").valueAction_(0);
			~mute.at("unit2").valueAction_(1);
		}.defer;
		8.0.wait;
		Pbindef(\unit7, \dur, Pseq([0.25, 0.75, Rest(1)], inf)).quant_(~globalQuant);
		2.0.wait;
		{
			~mute.at("unit1").valueAction_(1);
			~mute.at("unit3").valueAction_(1);
			~mute.at("unit5").valueAction_(1);
			~mute.at("unit6").valueAction_(1);
			~mute.at("unit8").valueAction_(1);
		}.defer;
		// t.sched(5, { t.tempo = 118 / 60 });
		Pbindef(\unit7, \dur, Pseq([0.125, 4.875], inf)).quant_(~globalQuant);
		~changePattern.value(Pdef(\unit2), ~defaultPattern9);
		~changePattern.value(Pdef(\unit4), ~defaultPattern10);
		{ ~mute.at("unit2").valueAction_(0); }.defer;
		20.0.wait;
		{
			~channel[\aux10].valueAction_(0.01);
			~channel[\aux21].valueAction_(0.45);
			~channel[\aux22].valueAction_(0.06);
			~channel[\aux13].valueAction_(0.05);
		}.defer;
		// Pbindef(\unit7, \dur, Pn(Pseq([Pn(0.125, 13), 0.1875, 0.0625, 0.25, 0.21875, 0.15625], 2))).quant_(~globalQuant);
		Pbindef(\unit7, \dur, Pseq([Pn(0.125, 32), 0.3125, 0.0625, 0.25, 0.21875, 0.15625], inf)).quant_(~globalQuant);
		// Pbindef(\unit7, \dur, Pseq([Pn(0.125, 30), 0.3125, 0.0625, 0.5, 0.21875, 0.15625], inf)).quant_(~globalQuant);
		38.0.wait;
		{ ~mute.at("unit7").valueAction_(1); }.defer;
		2.0.wait;
		{
			~mute.at("unit3").valueAction_(0);
			~mute.at("unit7").valueAction_(0);
			~channel[\aux13].valueAction_(0.01);
		}.defer;
		Pbindef(\unit3, \dur, 0.125, \amp, 0.015 * Pfunc({ 1 - ~muteState.at(~pdefName); })).quant_(~globalQuant);
		Pbindef(\unit7, \dur, Pn(Pconst(5, Pseq([2/6, 0.0625, 0.125, 0.25, 2/3, 1], inf)))).quant_(~globalQuant);
		20.0.wait;
		{
			~autoGuiControl.at("prayerBellunit2freq").valueAction_(838);
			~autoGuiControl.at("samplerStereounit4startPos").valueAction_(0.05);
			~autoGuiControl.at("t1kick2unit8pitch").valueAction_(0.5);
			~autoGuiControl.at("t1kick2unit8rel").valueAction_(6.71);
			~mute.at("unit8").valueAction_(0);
		}.defer;
		Pbindef(\unit8, \dur, 2.5, /*\timingOffset, 0.5*/).quant_(~globalQuant);
		20.0.wait;
		~songInit.value;
		{
			~mute.at("unit1").valueAction_(0);
			//~mute.at("unit3").valueAction_(0);
			~mute.at("unit5").valueAction_(0);
			~mute.at("unit6").valueAction_(0);
			//~mute.at("unit8").valueAction_(0);
			~channel[\aux10].valueAction_(0);
			~channel[\aux13].valueAction_(0);
			~channel[\aux21].valueAction_(0);
			~channel[\aux22].valueAction_(0);
		}.defer;
		2.0.wait;
	}
};

~song2 = { // ~globalQuant = 4; // !!! change globalQuant before song !!!
	t.tempo = 82 / 60;
	t.beatsPerBar = 4;
	{
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "buffer").valueAction_(22);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "startPos").valueAction_(0.3);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "rate").valueAction_(0.27);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "release").valueAction_(1.47);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "attack").valueAction_(2.11);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "amp").valueAction_(0.8);

		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "drywet").valueAction_(-0.84);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "attack").valueAction_(0.01);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "release").valueAction_(2.17);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "noiseType").valueAction_(0);
		~mute.at("unit7").valueAction_(1);
	}.defer;
	~songInit.value;
	loop {
		~changePattern.value(Pdef(\unit1), ~song2Pattern1);
		~changePattern.value(Pdef(\unit2), ~song2Pattern2);
		~changePattern.value(Pdef(\unit3), ~song2Pattern3);
		~changePattern.value(Pdef(\unit4), ~song2Pattern4);
		~changePattern.value(Pdef(\unit5), ~song2Pattern5);
		~changePattern.value(Pdef(\unit6), ~song2Pattern6);
		~changePattern.value(Pdef(\unit7), ~song2Pattern7);
		~changePattern.value(Pdef(\unit8), ~song2Pattern8);
		16.0.wait;
		~changePattern.value(Pdef(\unit1), ~song2Pattern10);
		~changePattern.value(Pdef(\unit2), ~song2Pattern9);
		4.0.wait;
		~changePattern.value(Pdef(\unit1), ~song2Pattern1);
		~changePattern.value(Pdef(\unit2), ~song2Pattern2);
		Pbindef(\unit1, // change key value (synchro whith changePattern)
			\amp, 0.8 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\tu, 0.75,
			\envL1, 0.62,
			\envL2, 0.01,
			\envL3, 0.69,
			\envT1, 0.44,
			\envT2, 0.17,
			\envfL1, 245,
			\envfL2, 270,
			\envfL3, 120,
			\envfT1, 0.18,
			\envfT2, 0.29,
			\envfT3, 1,
		).quant_(~globalQuant);
		~resetControlBus.value("unit1");
		8.0.wait;
		~changePattern.value(Pdef(\unit1), ~song2Pattern10);
		~changePattern.value(Pdef(\unit2), ~song2Pattern9);
		4.0.wait;
		~changePattern.value(Pdef(\unit1), ~song2Pattern1);
		~changePattern.value(Pdef(\unit2), ~song2Pattern2);
		8.0.wait;
		~changePattern.value(Pdef(\unit1), ~song2Pattern10);
		~changePattern.value(Pdef(\unit2), ~song2Pattern9);
		Pbindef(\unit6,
			\amp, 0.065 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\att, 0.26,
			\rel, 0.01,
			\ffreq, 7948
		).quant_(~globalQuant);
		~resetControlBus.value("unit6");
		Pbindef(\unit2,
			\release, Pseq([0.6, 0.3, 0.42, 0.16, 0.5, 0.42, 0.16, 0.7], inf),
			\freq, 0.01,
			\dur, Pseq([0.125, 0.125, 0.5, 0.25], inf) // 0.125+ 0.125+ 0.5+ 0.25 == 1
		).quant_(~globalQuant);
		~resetControlBus.value("unit2");
		8.0.wait;
		~changePattern.value(Pdef(\unit1), ~song2Pattern1);
		~changePattern.value(Pdef(\unit2), ~song2Pattern2);
		~changePattern.value(Pdef(\unit3), ~song2Pattern12);
		~changePattern.value(Pdef(\unit6), ~song2Pattern6);
		28.0.wait;
		~changePattern.value(Pdef(\unit1), ~song2Pattern10);
		~changePattern.value(Pdef(\unit2), ~song2Pattern9);
		4.0.wait;
		~changePattern.value(Pdef(\unit1), ~song2Pattern1);
		~changePattern.value(Pdef(\unit2), ~song2Pattern2);
		~changePattern.value(Pdef(\unit4), ~song2Pattern11);
		Pbindef(\unit6,
			\amp, 0.065 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\att, 0.26,
			\rel, 0.01,
			\ffreq, 7948
		).quant_(~globalQuant);
		~resetControlBus.value("unit6");
		Pbindef(\unit1,
			\amp, 0.8 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\tu, 0.75,
			\envL1, 0.62,
			\envL2, 0.01,
			\envL3, 0.69,
			\envT1, 0.44,
			\envT2, 0.17,
			\envfL1, 245,
			\envfL2, 270,
			\envfL3, 120,
			\envfT1, 0.18,
			\envfT2, 0.29,
			\envfT3, 1,
		).quant_(~globalQuant);
		~resetControlBus.value("unit1");
		12.0.wait;
		~changePattern.value(Pdef(\unit1), ~song2Pattern10);
		~changePattern.value(Pdef(\unit2), ~song2Pattern9);
		Pbindef(\unit2,
			\release, Pseq([0.6, 0.3, 0.42, 0.16, 0.5, 0.42, 0.16, 0.7], inf),
			\freq, 0.01,
			\dur, Pseq([0.125, 0.125, 0.5, 0.25], inf) // 0.125+ 0.125+ 0.5+ 0.25 == 1
		).quant_(~globalQuant);
		~resetControlBus.value("unit2");
		4.0.wait;
	}
};

~song3 = {// ~globalQuant = 7; // !!! change globalQuant before song !!!
	t.tempo = 142 / 60;
	//t.beatsPerBar = 7;
	{
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "amp").valueAction_(1);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "attack").valueAction_(2.11);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "release").valueAction_(1);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "buffer").valueAction_(2);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "rate").valueAction_(0.2);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "startPos").valueAction_(0.08);

		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "amp").valueAction_(0.4);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "attack").valueAction_(0.2);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "release").valueAction_(4);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel1").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel2").valueAction_(28);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel3").valueAction_(64);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel4").valueAction_(16);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel5").valueAction_(48.3);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel6").valueAction_(37.5);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime1").valueAction_(0.1);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime2").valueAction_(0.3);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime3").valueAction_(0.5);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime4").valueAction_(0.39);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime5").valueAction_(0.14);

		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "drywet").valueAction_(0.4);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "feedBack").valueAction_(0.2);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync1").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync2").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync3").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync4").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "amp4").valueAction_(0);

		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "drywet").valueAction_(0.7);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "pitchRatio").valueAction_(0.11);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "pitchDisper").valueAction_(0);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "timeDisper").valueAction_(0.02);

		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "drywet").valueAction_(-0.02);
		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "fgfreq").valueAction_(2);
		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "fdback").valueAction_(0.12);

		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "drywet").valueAction_(0);

		~channel.at(\level2).valueAction_(0.08);
	}.defer;
	Pdefn(\kickNoisePatt, Pseq([1.375, Rest(1.75), 1.75, 0.875, 1.25/**/, 1.375, Rest(0.875), 0.875, 1.75, Rest(0.875), 1.25], inf));
	~songInit.value;
	loop {
		~changePattern.value(Pdef(\unit1), ~song3Pattern1);
		~changePattern.value(Pdef(\unit2), ~song3Pattern2);
		~changePattern.value(Pdef(\unit3), ~song3Pattern3);
		~changePattern.value(Pdef(\unit4), ~song3Pattern4);
		~changePattern.value(Pdef(\unit5), ~song3Pattern5);
		~changePattern.value(Pdef(\unit6), ~song3Pattern6);
		~changePattern.value(Pdef(\unit7), ~song3Pattern7);
		~changePattern.value(Pdef(\unit8), ~song3Pattern8);
		56.0.wait;
		Pbindef(\unit1,
			\dur, Pseq([Rest(0.875), 2.625, Rest(1.75), 1.75/**/, Rest(0.875), 0.875, 1.75, 2.625, Rest(0.875)], inf)
		).quant_(~globalQuant);
		Pbindef(\unit2,
			\dur, Pseq([Rest(1.75), 0.875, 3.5, Rest(0.875)], inf)
		).quant_(~globalQuant);
		Pbindef(\unit3,
			\dur, Pseq([Rest(1.75), 1.75, Rest(1.25), 0.4375, Rest(1.375), 0.4375], inf), // 1.75+ 1.75+ 1.25+ 0.4375+ 1.375+ 0.4375 == 7
			\att, 0.17
		).quant_(~globalQuant);
		~resetControlBus.value("unit3att");
		~changePattern.value(Pdef(\unit6), ~song3Pattern9);
		Pbindef(\unit6,
			\attack, 0,
			\amp, 0.27 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\sustain, 0.14,
			\release, 0,
			\curve, 4.76,
			\clipLevel, 0,
			\impFreq, Pseq([15, 8, 12], inf),
			\impPhase, 0,
			\impLevel, 3.99,
			\noiseLevel, 0.3,
			\eqfreq, Pseg([765, 2242, 12875], [0.2, 0.55], \exp, inf),
			\eqrq, 0.74,
			\eqdb, -60
		).quant_(~globalQuant);
		~resetControlBus.value("unit6");
		Pbindef(\unit7,
			\dur, Pseq([0.875, Rest(0.21875), 1.75, 0.21875, 0.4375], inf), // 0.875+ 0.4375+ 0.21875+ 0.21875+ 1.75
			\release, Pseq([0.01, 0.02, 0.01, 0.02, 0.03], inf),
		).quant_(~globalQuant);
		~resetControlBus.value("unit7release");
		28.0.wait;
		~changePattern.value(Pdef(\unit1), ~song3Pattern1);
		~changePattern.value(Pdef(\unit3), ~song3Pattern3);
		~changePattern.value(Pdef(\unit6), ~song3Pattern6);
		~changePattern.value(Pdef(\unit7), ~song3Pattern7);
		28.0.wait;
		Pbindef(\unit1,
			\dur, Pseq([2.625, 1.75, Rest(0.875), 0.875, Rest(0.875)/**/, Rest(0.875), 2.625, 1.75, 0.875, Rest(0.875)], inf) // 0.875+ 0.4375+ 0.21875+ 0.21875+ 1.75
		).quant_(~globalQuant);
		Pbindef(\unit2,
			\dur, Pseq([1.75, 3.5, Rest(0.875), Rest(0.875)], inf)
		).quant_(~globalQuant);
		Pbindef(\unit3,
			\dur, Pseq([Rest(0.875), 1.75, 0.875, 1.25, Rest(0.875), 1.375/**/, Rest(0.875), 1.75, 1.25, Rest(1.75), 1.375]/2, inf), // 0.875+ 0.875+ 1.75+ 1.25+ 1.375+ 0.875 == 7
			\att, 0.17
		).quant_(~globalQuant);
		~resetControlBus.value("unit3att");
		~changePattern.value(Pdef(\unit4), ~song3Pattern9);
		Pbindef(\unit4,
			\dur, Pwrand([1.75, Rest(1.75), 3.5, Rest(3.5)], [0.3, 0.3, 0.3, 0.1].normalizeSum, inf),
			\amp, 0.3 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\attack, 1.6,
			\sustain, 0,
			\release, 0,
			\curve, 3.31,
			\clipLevel, 0.02,
			\impFreq, Pseq([8000, 34, 8000], inf),
			\impPhase, 0,
			\impLevel, Pseq([0.15, 0.75, 0.15], inf),
			\noiseLevel, 0,
			\eqfreq, 163150,
			\eqrq, 0.73,
			\eqdb, 30.99
		).quant_(~globalQuant);
		~resetControlBus.value("unit4");
		Pbindef(\unit6, \dur, Pseq([1.75, 0.875], inf)).quant_(~globalQuant);
		Pbindef(\unit7,
			\dur, Pseq([0.875, Rest(0.21875), 0.4375, 0.21875, 1.75/**/, 1.75, 0.875, Rest(0.21875), 0.21875, 0.4375], inf) // 0.875+ 0.4375+ 0.21875+ 0.21875+ 1.75
		).quant_(~globalQuant);
		28.0.wait;
		Pbindef(\unit3,
			\dur, Pseq([Rest(0.875), 0.875, Rest(0.875), 1.375, 0.875, 1.25, 0.875], inf) // 0.875+ 0.875+ 0.875+ 1.375+ 0.875+ 1.25+ 0.875 == 7
		).quant_(~globalQuant);
		Pbindef(\unit4,
			\attack, 0,
			\amp, 0.3 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\sustain, 0.14,
			\release, 0,
			\curve, 4.76,
			\clipLevel, 0,
			\impFreq, Pseq([15, 8, 12], inf),
			\impPhase, 0,
			\impLevel, 3.99,
			\noiseLevel, 0.3,
			\eqfreq, Pseg([765, 2242, 12875], [0.2, 0.55], \exp, inf),
			\eqrq, 0.74,
			\eqdb, -60
		).quant_(~globalQuant);
		~resetControlBus.value("unit4");
		Pbindef(\unit7,
			\dur, Pseq([1.75, 0.875, Rest(0.21875), 0.21875, 0.4375], inf) // 0.875+ 0.4375+ 0.21875+ 0.21875+ 1.75
		).quant_(~globalQuant);
		14.0.wait;
		Pbindef(\unit3,
			\dur, Pseq([Rest(0.875), 1.75, Rest(0.875), 1.25, Rest(0.875), 1.375]/2, inf), // 0.875+ 1.75+ 0.875+ 1.25+ 0.875+ 1.375 == 7
		).quant_(~globalQuant);
		~changePattern.value(Pdef(\unit4), ~song3Pattern9);
		Pbindef(\unit4,
			\dur, Pwrand([3.5, 7], [0.7, 0.3].normalizeSum, inf),
			\attack, 1.32,
			\sustain, 0.01,
			\release, 0.09,
			[\impFreq, \impLevel], Pseq([[15, 1.7], [8000, 0.25], [8, 1.7], [8000, 0.25], [12, 1.7], [8, 1.7]], inf),
			\impPhase, 0,
			\noiseLevel, 0.2,
			\eqfreq, 367
		).quant_(~globalQuant);
		~resetControlBus.value("unit4");
		~changePattern.value(Pdef(\unit5), ~song3Pattern11);
		Pbindef(\unit5,
			\dur, 14,
			\amp, 0.03 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\att, 5.8,
			\revMix, 0,
			\freq, 37,
			\rel, 0
		).quant_(~globalQuant);
		~resetControlBus.value("unit5");
		14.0.wait;
		~changePattern.value(Pdef(\unit1), ~song3Pattern1);
		~changePattern.value(Pdef(\unit2), ~song3Pattern2);
		~changePattern.value(Pdef(\unit3), ~song3Pattern3);
		~changePattern.value(Pdef(\unit5), ~song3Pattern11);
		~changePattern.value(Pdef(\unit6), ~song3Pattern6);
		~changePattern.value(Pdef(\unit7), ~song3Pattern7);
		56.0.wait;
		Pbindef(\unit1,
			\dur, Pseq([Rest(0.875), 2.625, 0.875, Rest(0.875), 1.75], inf) // 0.875+ 0.4375+ 0.21875+ 0.21875+ 1.75
		).quant_(~globalQuant);
		Pbindef(\unit2,
			\dur, Pseq([Rest(1.75), 3.5, 0.875, Rest(0.875)], inf)
		).quant_(~globalQuant);
		Pbindef(\unit3,
			\dur, Pseq([Rest(0.875), 0.875, 1.75, 1.25, 1.375, 0.875], inf), // 0.875+ 0.875+ 1.75+ 1.25+ 1.375+ 0.875 == 7
			\att, 0.17
		).quant_(~globalQuant);
		~resetControlBus.value("unit3att");
		~changePattern.value(Pdef(\unit6), ~song3Pattern9);
		Pbindef(\unit6,
			\dur, Pwrand([1.75, Rest(1.75), 3.5, Rest(3.5)], [0.2, 0.4, 0.3, 0.1].normalizeSum, inf),
			\attack, 0,
			\amp, 0.3 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\sustain, 0.14,
			\release, 0,
			\curve, 4.76,
			\clipLevel, 0,
			\impFreq, Pseq([15, 8, 12], inf),
			\impPhase, 0,
			\impLevel, 3.99,
			\noiseLevel, 0.3,
			\eqfreq, Pseg([765, 2242, 12875], [0.2, 0.55], \exp, inf),
			\eqrq, 0.74,
			\eqdb, -60
		).quant_(~globalQuant);
		~resetControlBus.value("unit6");
		Pbindef(\unit7,
			\dur, Pseq([0.875, Rest(0.21875), 1.75, 0.21875, 0.4375], inf), // 0.875+ 0.4375+ 0.21875+ 0.21875+ 1.75
			\release, Pseq([0.01, 0.02, 0.01, 0.02, 0.03], inf),
		).quant_(~globalQuant);
		~resetControlBus.value("unit7release");
		28.0.wait;
		~changePattern.value(Pdef(\unit2), ~song3Pattern2);
		Pbindef(\unit3,
			\dur, Pseq([1.375, Rest(0.875), 0.875, 1.75, 0.875, 1.25], inf),
			\amp, 0.005 * Pfunc({ 1 - ~muteState.at(~pdefName); })
		).quant_(~globalQuant);
		~changePattern.value(Pdef(\unit6), ~song3Pattern6);
		28.0.wait;
		~changePattern.value(Pdef(\unit1), ~initPattern);
		~changePattern.value(Pdef(\unit3), ~initPattern);
		~changePattern.value(Pdef(\unit4), ~initPattern);
		~changePattern.value(Pdef(\unit5), ~initPattern);
		~changePattern.value(Pdef(\unit6), ~initPattern);
		~changePattern.value(Pdef(\unit8), ~initPattern);
		28.0.wait;
		~changePattern.value(Pdef(\unit1), ~song3Pattern1);
		Pbindef(\unit1,
			\dur, Pseq([Rest(0.875), 2.625, 0.875, Rest(0.875), 1.75], inf) // 0.875+ 2.625+ 0.875+ 0.875+ 1.75
		).quant_(~globalQuant);
		~changePattern.value(Pdef(\unit3), ~song3Pattern3);
		Pbindef(\unit3,
			\dur, Pdefn(\kickNoisePatt),
			\att, 0.17,
			\amp, 0.005 * Pfunc({ 1 - ~muteState.at(~pdefName); })
		).quant_(~globalQuant);
		~resetControlBus.value("unit3att");
		~changePattern.value(Pdef(\unit4), ~song3Pattern10);
		~changePattern.value(Pdef(\unit5), ~song3Pattern11);
		~changePattern.value(Pdef(\unit6), ~song3Pattern9);
		Pbindef(\unit6,
			\dur, Pdefn(\kickNoisePatt),
			\amp, 0.3 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\attack, Pseq([1.32, 0.2, 1.65, 0.03], inf),
			\sustain, 0.01,
			\release, 0.09,
			\impFreq, Pseq([8000, 34, 8000], inf),
			\eqfreq, 367,
			\impLevel, Pseq([0.15, 0.75, 0.15]*1.2, inf),
			\noiseLevel, 0.2,
		).quant_(~globalQuant);
		~resetControlBus.value("unit6");
		~changePattern.value(Pdef(\unit8), ~song3Pattern8);
		56.0.wait;
		~changePattern.value(Pdef(\unit1), ~initPattern);
		~changePattern.value(Pdef(\unit2), ~initPattern);
		~changePattern.value(Pdef(\unit4), ~initPattern);
		~changePattern.value(Pdef(\unit5), ~initPattern);
		~changePattern.value(Pdef(\unit7), ~initPattern);
		~changePattern.value(Pdef(\unit8), ~initPattern);
		28.0.wait;
		~changePattern.value(Pdef(\unit3), ~initPattern);
		~changePattern.value(Pdef(\unit5), ~song3Pattern13);
		~changePattern.value(Pdef(\unit6), ~initPattern);
		28.0.wait;
		~changePattern.value(Pdef(\unit6), ~song3Pattern9);
		Pbindef(\unit6,
			\attack, 0,
			\amp, 0.3 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\sustain, 0.14,
			\release, 0,
			\curve, 4.76,
			\clipLevel, 0,
			\impFreq, Pseq([15, 8, 12], inf),
			\impPhase, 0,
			\impLevel, 3.99,
			\noiseLevel, 0.3,
			\eqfreq, Pseg([765, 2242, 12875], [0.2, 0.55], \exp, inf),
			\eqrq, 0.74,
			\eqdb, -60
		).quant_(~globalQuant);
		~resetControlBus.value("unit6");
		14.0.wait;
		~changePattern.value(Pdef(\unit1), ~song3Pattern1);
		~changePattern.value(Pdef(\unit2), ~song3Pattern2);
		~changePattern.value(Pdef(\unit3), ~song3Pattern3);
		~changePattern.value(Pdef(\unit4), ~song3Pattern4);
		~changePattern.value(Pdef(\unit6), ~song3Pattern6);
		~changePattern.value(Pdef(\unit7), ~song3Pattern7);
		~changePattern.value(Pdef(\unit8), ~song3Pattern12);
		56.0.wait;
		Pbindef(\unit3,
			\dur, Pseq([Rest(0.875), 1.75, 0.875, 1.25, Rest(0.875), 1.375]/2, inf), // 0.875+ 0.875+ 1.75+ 1.25+ 1.375+ 0.875 == 7
			\att, 0.17
		).quant_(~globalQuant);
		~resetControlBus.value("unit3att");
		~changePattern.value(Pdef(\unit4), ~song3Pattern9);
		Pbindef(\unit4,
			\dur, Pwrand([1.75, Rest(1.75), 3.5, Rest(3.5)], [0.2, 0.4, 0.3, 0.1].normalizeSum, inf),
			\attack, 0,
			\amp, 0.3 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\sustain, 0.14,
			\release, 0,
			\curve, 4.76,
			\clipLevel, 0,
			\impFreq, Pseq([15, 8, 12], inf),
			\impPhase, 0,
			\impLevel, 3.99,
			\noiseLevel, 0.3,
			\eqfreq, Pseg([765, 2242, 12875], [0.2, 0.55], \exp, inf),
			\eqrq, 0.74,
			\eqdb, -60
		).quant_(~globalQuant);
		~resetControlBus.value("unit4");
		Pbindef(\unit6, \dur, Pseq([1.75, 3.5], inf)).quant_(~globalQuant);
		Pbindef(\unit7,
			\dur, Pseq([0.875, Rest(0.21875), 1.75, 0.21875, 0.4375], inf), // 0.875+ 0.4375+ 0.21875+ 0.21875+ 1.75
			\release, Pseq([0.01, 0.02, 0.01, 0.02, 0.03], inf),
		).quant_(~globalQuant);
		~resetControlBus.value("unit7release");
		28.0.wait;
		Pbindef(\unit3,
			\dur, Pseq([1.375, Rest(0.875), 0.875, 1.75, 0.875, 1.25], inf),
			\amp, 0.005 * Pfunc({ 1 - ~muteState.at(~pdefName); })
		).quant_(~globalQuant);
		~changePattern.value(Pdef(\unit6), ~song3Pattern6);
		~changePattern.value(Pdef(\unit7), ~song3Pattern7);
		28.0.wait;
		~changePattern.value(Pdef(\unit1), ~initPattern);
		~changePattern.value(Pdef(\unit3), ~initPattern);
		~changePattern.value(Pdef(\unit4), ~initPattern);
		~changePattern.value(Pdef(\unit6), ~initPattern);
		~changePattern.value(Pdef(\unit8), ~initPattern);
		28.0.wait;
		~changePattern.value(Pdef(\unit1), ~song3Pattern1);
		Pbindef(\unit1,
			\dur, Pseq([Rest(0.875), 2.625, 0.875, Rest(0.875), 1.75], inf) // 0.875+ 2.625+ 0.875+ 0.875+ 1.75
		).quant_(~globalQuant);
		~changePattern.value(Pdef(\unit3), ~song3Pattern3);
		Pbindef(\unit3,
			\dur, Pdefn(\kickNoisePatt),
			\att, 0.17,
			\amp, 0.005 * Pfunc({ 1 - ~muteState.at(~pdefName); })
		).quant_(~globalQuant);
		~resetControlBus.value("unit3att");
		~changePattern.value(Pdef(\unit4), ~song3Pattern10);
		~changePattern.value(Pdef(\unit6), ~song3Pattern9);
		Pbindef(\unit6,
			\dur, Pdefn(\kickNoisePatt),
			\amp, 0.3 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\attack, Pseq([1.32, 0.2, 1.65, 0.03], inf),
			\sustain, 0.01,
			\release, 0.09,
			\impFreq, Pseq([8000, 34, 8000], inf),
			\eqfreq, 367,
			\impLevel, Pseq([0.15, 0.75, 0.15]*1.2, inf),
			\noiseLevel, 0.2,
		).quant_(~globalQuant);
		~resetControlBus.value("unit6");
		~changePattern.value(Pdef(\unit8), ~song3Pattern12);
		56.0.wait;
	}
};

~song4 = {// ~globalQuant = 5; // !!! change globalQuant before song !!!
	t.tempo = 80 / 60;
	t.beatsPerBar = 5;

	// Part

	~song4InitPart = {
		~changePattern.value(Pdef(\unit1), ~song4Pattern1);
		~changePattern.value(Pdef(\unit2), ~song4Pattern2);
		~changePattern.value(Pdef(\unit3), ~song4Pattern3);
		~changePattern.value(Pdef(\unit4), ~song4Pattern4);
		~changePattern.value(Pdef(\unit5), ~song4Pattern5);
		~changePattern.value(Pdef(\unit6), ~song4Pattern6);
		~changePattern.value(Pdef(\unit7), ~song4Pattern7);
		~changePattern.value(Pdef(\unit8), ~song4Pattern8);
		~resetAllControlBus.value;
	};

	~song4Part1 = {
		"song4 part1".postln;
		~song4InitPart.value;
		15.0.wait;
		Pbindef(\unit4, \dur, Pseq([0.5, 0.75, 0.5, Rest(0.25), 0.5/**/, 0.25, 0.75, 0.25, Rest(0.5), 0.25, 0.5], inf)).quant_(~globalQuant);
		Pbindef(\unit5, \dur, Pseq([0.5, 0.375, Rest(0.375), Rest(0.25), 0.75, 0.25], inf)).quant_(~globalQuant);
		Pbindef(\unit6, \dur, Pseq([Rest(1.5), 0.5, 0.25, Rest(0.25), Rest(0.25), 1.5, 0.25, Rest(0.5)], inf)).quant_(~globalQuant);
		5.0.wait;
	};

	~song4Part2 = {
		"song4 part2".postln;
		~song4InitPart.value;
		Pbindef(\unit2,
			\dur, 2.5,
			\timingOffset, Pseq([0, 0.2], inf)
		).quant_(~globalQuant);
		Pbindef(\unit4, \dur, Pseq([0.5, 0.75, 0.5, Rest(0.25), 0.5], inf)).quant_(~globalQuant);
		Pbindef(\unit5, \dur, Pseq([Rest(0.375), 0.5, 0.375, Rest(0.25), 0.75, 0.25], inf)).quant_(~globalQuant);
		Pbindef(\unit6, \dur, Pseq([Rest(0.05), 1.45, Rest(0.5), 0.25, Rest(0.25), Rest(0.25), 1.45, Rest(0.05), 0.25, Rest(0.5)], inf)).quant_(~globalQuant);
		Pbindef(\unit7, \dur, Pseq([0.25, 0.125, 0.125, 0.5, 0.25], inf)).quant_(~globalQuant);
		Pbindef(\unit8, \dur, Pseq([Rest(0.125), 0.125, 0.25, Rest(0.25), 0.25, 0.125, Rest(0.125), Rest(0.25), 0.25, 0.25, Rest(0.125), 0.25, Rest(0.125)], inf)).quant_(~globalQuant); // 0.125+ 0.125+ 0.25+ 0.25+ 0.25+ 0.125+ 0.125+ 0.25+ 0.25+ 0.25+ 0.125+ 0.25+ 0.125 == 2.5
		15.0.wait;
		Pbindef(\unit2, \dur, Pseq([1.25, Rest(3.75)], inf)).quant_(~globalQuant);
		Pbindef(\unit4, \dur, Pseq([0.5, 0.75, 0.5, Rest(0.25), 0.5/**/, 0.25, 0.75, 0.25, Rest(0.5), 0.25, 0.5], inf)).quant_(~globalQuant);
		Pbindef(\unit5, \dur, Pseq([0.5, 0.375, Rest(0.375), Rest(0.25), 0.75, 0.25], inf)).quant_(~globalQuant);
		Pbindef(\unit6, \dur, Pseq([Rest(1.5), 0.5, 0.25, Rest(0.25), Rest(0.25), 1.5, 0.25, Rest(0.5)], inf)).quant_(~globalQuant);
		5.0.wait;
	};

	~song4Part3 = {
		"song4 part3".postln;
		~song4InitPart.value;
		Pbindef(\unit2,
			\dur, 1.25,
			\timingOffset, Pseq([0.1, 0.375], inf),
			\amp, 0.072 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\envLev4, 1,
			\rel, 0.16
		).quant_(~globalQuant);
		~resetControlBus.value("unit2");
		Pbindef(\unit3, \freq, 672).quant_(~globalQuant);
		~resetControlBus.value("unit3freq");
		Pbindef(\unit4, \dur, Pseq([0.5, Rest(0.25), 0.75, 0.5, 0.5], inf)).quant_(~globalQuant);
		Pbindef(\unit5, \dur, Pseq([0.5, 0.375, Rest(0.375), Rest(0.25), 0.75, 0.25], inf)).quant_(~globalQuant);
		Pbindef(\unit6,
			\dur, Pseq([Rest(0.5), 2, Rest(0.25), 1.5, 0.25, Rest(0.5)], inf), // 0.5+ 2+ 0.25+ 1.5+ 0.25+ 0.5 == 5
			\bdFrqL1, 251.3,
			\bdFrqL2, 180,
			\bdFrqL3, 20,
			\bdFrqT1, 0.03,
			\bdAmpSus, 0.38,
			\popFrqEnd, 271,
			\popAmpLev, 0.7
		).quant_(~globalQuant);
		~resetControlBus.value("unit6");
		Pbindef(\unit7, \dur, Pseq([0.25, 0.125, 0.125, 0.5, 0.25], inf)).quant_(~globalQuant);
		Pbindef(\unit8, \envL2, 0.2).quant_(~globalQuant);
		~resetControlBus.value("unit8envL2");
		20.0.wait;
	};

	~song4Part4 = {
		"song4 part4".postln;
		~song4InitPart.value;
		Pbindef(\unit2,
			\dur, 2.5,
			\timingOffset, Pseq([0, 0.2], inf),
			\amp, 0.16 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\envLev4, 0.38,
			\rel, 0.1,
		).quant_(~globalQuant);
		~resetControlBus.value(#["rimunit2amp", "rimunit2envLev4", "rimunit2rel"]);
		Pbindef(\unit3,
			\amp, 0.17 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\freq, 95,
			\ffreq, 488,
			\release, 0.79
		).quant_(~globalQuant);
		~resetControlBus.value("unit3");
		Pbindef(\unit4, \dur, Pseq([Rest(0.5), 1, 1.5, 1, 1/**/, 0.5, 1, 1.5, 1, 1], inf)).quant_(~globalQuant);
		Pbindef(\unit5, \dur, Pseq([Rest(0.75), 1, 0.75, Rest(1), 1, 0.5], inf)).quant_(~globalQuant); // 0.75+ 1+ 0.75+ 1+ 1+ 0.5
		Pbindef(\unit6,
			\dur, Pseq([Rest(0.25), 1.5, 0.5, Rest(0.25)/**/, Rest(0.25), 0.5, Rest(0.25), 1.5/**/, Rest(0.25), 1.5, 0.5, Rest(0.25)/**/, Rest(0.25), 1.5, Rest(0.25), 0.5], inf),
			\bdFrqL1, 261,
			\bdFrqL2, 116,
			\bdFrqL3, 64,
			\bdFrqT1, 0.035,
			\bdAmpSus, 0.1,
			\popFrqEnd, 261,
			\popAmpLev, 0.39
		).quant_(~globalQuant);
		~resetControlBus.value("unit6");
		Pbindef(\unit7, \dur, 0.5).quant_(~globalQuant);
		Pbindef(\unit8,
			\dur, Pseq([Rest(0.25), 0.25, 0.5, 0.25, Rest(0.25), 0.5, 0.25, Rest(0.25), Rest(0.25), 0.5, 0.5, Rest(0.25), 0.5, Rest(0.25), 0.25], inf),
			\envL2, 0
		).quant_(~globalQuant);
		~resetControlBus.value("unit8envL2");
		15.0.wait;
		Pbindef(\unit2, \dur, Pseq([1.25, Rest(3.75)], inf)).quant_(~globalQuant);
		Pbindef(\unit3,
			\amp, 0.3 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\freq, 95,
			\ffreq, 53,
			\release, 1.75
		).quant_(~globalQuant);
		~resetControlBus.value("unit3");
		Pbindef(\unit4, \dur, Pseq([0.5, 0.75, 0.5, Rest(0.25), 0.5/**/, Rest(0.25), 0.75, 0.25, Rest(0.5), Rest(0.25), 0.5], inf)).quant_(~globalQuant);
		Pbindef(\unit5, \dur, Pseq([Rest(0.5), Rest(0.375), 0.375, Rest(0.25), 0.75, Rest(0.25)], inf)).quant_(~globalQuant);
		Pbindef(\unit6, \dur, Pseq([Rest(1), 0.5, Rest(1)/**/, 0.25, Rest(1.75), 0.5], inf)).quant_(~globalQuant);
		5.0.wait;
	};

	~song4Part5 = {
		"song4 part5".postln;
		~song4InitPart.value;
		Pbindef(\unit5,
			\amp, 0.64 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\vcaLev1, 0.1,
			\vcaLev2, 0.07,
			\vcaLev3, 0.43,
			\vcaLev4, 0,
			\vcaLev5, 0,
			\vcaTime1, 0.02,
			\vcaTime2, 2.11,
			\vcaTime3, 0.9,
			\vcaTime4, 0,
			\vcaCurve1, 0,
			\vcaCurve2, 0,
			\vcaCurve3, -14.5,
			\vcfLev1, 30.7,
			\vcfLev2, 50.4,
			\vcfLev3, 42.7,
			\vcfLev4, 80.4,
			\vcfTime1, 0,
			\vcfTime2, 0.1,
			\vcfTime3, 0.07,
			\vcfCurve1, 12.3,
			\vcfCurve2, -77.7,
			\tu, 0.15
		).quant_(~globalQuant);
		~resetControlBus.value("unit5");
		Pbindef(\unit6,
			\dur, Pseq([Rest(0.5), 1.5, 0.25, Rest(0.25), Rest(0.25), 1.5, 0.25, Rest(0.5)], inf),
			\popFrqEnd, 1312,
			\bdAmpAtt, 0.02
		).quant_(~globalQuant);
		~resetControlBus.value("unit3popFrqEnd");
		Pbindef(\unit8, \dur, Pseq([Rest(0.25), 0.25, 0.5, 0.25, Rest(0.25), 0.5, 0.25, Rest(0.25), Rest(0.25), 0.5, 0.5, Rest(0.25), 0.5, Rest(0.25), 0.25], inf)
		).quant_(~globalQuant);
		40.0.wait;
		Pbindef(\unit6,
			\bdFrqT2, 1.21,
			\bdFrqL3, Pseq([91, 91, 29, 6], inf),
			\bdAmpSus, 0.1,
			\popFrqEnd, 261
		).quant_(~globalQuant);
		~resetControlBus.value("unit6bd");
		20.0.wait;
		Pbindef(\unit6,
			\bdAmpAtt, 1.32,
			\popFrqEnd, 261
		).quant_(~globalQuant);
		~resetControlBus.value("unit3bdAmpAtts");
		10.0.wait;
	};

	~song4Part6 = {
		"song4 part6".postln;
		~song4InitPart.value;
		Pbindef(\unit1,
			\freq, 2982.4
		).quant_(~globalQuant);
		~resetControlBus.value("unit1freq");
		Pbindef(\unit2,
			\dur, 2.5,
			\timingOffset, Pseq([0, 0.2], inf),
			\amp, 0.16 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\envLev4, 0.38,
			\rel, 0.22,
		).quant_(~globalQuant);
		~resetControlBus.value(#["rimunit2amp", "rimunit2envLev4", "rimunit2rel"]);
		Pbindef(\unit3,
			\amp, 0.17 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\freq, 95,
			\ffreq, 488,
			\release, 0.79
		).quant_(~globalQuant);
		~resetControlBus.value("unit3");
		Pbindef(\unit4, \dur, Pseq([Rest(0.5), 1, 1.5, 1, 1/**/, 0.5, Rest(1), 1.5, 1, 1], inf)).quant_(~globalQuant);
		Pbindef(\unit5, \dur, Pseq([Rest(0.75), 1, 0.75, Rest(1), 1, 0.5], inf)).quant_(~globalQuant); // 0.75+ 1+ 0.75+ 1+ 1+ 0.5
		Pbindef(\unit6,
			\dur, Pseq([Rest(0.25), 1.5, 0.5, Rest(0.25)/**/, Rest(0.25), 2, Rest(0.25)/**/, Rest(0.25), 1.5, 0.5, Rest(0.25)/**/, Rest(0.25), 1.5, Rest(0.25), 0.5], inf),
			\bdFrqL1, 261,
			\bdFrqL2, 116,
			\bdFrqL3, 64,
			\bdFrqT1, 0.035,
			\bdAmpSus, 0.1,
			\popFrqEnd, 261,
			\popAmpLev, 0.39
		).quant_(~globalQuant);
		~resetControlBus.value("unit6");
		Pbindef(\unit7, \dur, 0.5).quant_(~globalQuant);
		Pbindef(\unit8,
			\dur, Pseq([Rest(0.25), 0.25, 0.5, 0.25, Rest(0.25), 0.5, 0.25, Rest(0.25), Rest(0.25), 0.5, 0.5, Rest(0.25), 0.5, Rest(0.25), 0.25], inf),
			\envL2, 0,
			\envT2, 0.04,
			\envT3, 0.02,
			\envC1, -41.3,
			\amp, 0.0085 * Pfunc({ 1 - ~muteState.at(~pdefName); })
		).quant_(~globalQuant);
		~resetControlBus.value(#[
			"cym1unit8envL2",
			"cym1unit8envT2",
			"cym1unit8envT3",
			"cym1unit8envC1",
			"cym1unit8amp"
		]);
		35.0.wait;
		//Pbindef(\unit2, \dur, Pseq([1.25, Rest(3.75)], inf)).quant_(~globalQuant);
		Pbindef(\unit3,
			\amp, 0.3 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\freq, 95,
			\ffreq, 53,
			\release, 1.75
		).quant_(~globalQuant);
		~resetControlBus.value("unit3");
		Pbindef(\unit4, \dur, Pseq([0.5, 1, Rest(0.25), 0.25, Rest(1), 0.5, Rest(0.5), 0.75, Rest(0.25)], inf)).quant_(~globalQuant); // 0.5+ 1.5+ 0.75+ 0.75+ 0.5+ 0.75+ 0.25 == 5
		Pbindef(\unit5, \dur, Pseq([Rest(0.5), Rest(0.375), 0.375, Rest(1), 0.25/**/, Rest(0.375), 0.5, Rest(0.375), 0.25, Rest(1)], inf)).quant_(~globalQuant); // 0.5+ 0.375+ 0.375+ 1+ 0.25+ 0.375+ 0.5+ 0.375+ 0.25+ 1 == 5
		Pbindef(\unit6, \dur, Pseq([Rest(1), 0.5, Rest(1)/**/, 0.25, Rest(1.75), 0.5], inf)).quant_(~globalQuant);
		5.0.wait;
	};

	~song4Part7 = {
		"song4 part7".postln;
		~song4InitPart.value;
		Pbindef(\unit2,
			\dur, 2.5,
			\timingOffset, Pseq([0, 0.2], inf),
			\amp, 0.16 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\envLev4, 0.38,
			\rel, 0.22,
		).quant_(~globalQuant);
		~resetControlBus.value(#["rimunit2amp", "rimunit2envLev4", "rimunit2rel"]);
		Pbindef(\unit3, \freq, 672).quant_(~globalQuant);
		~resetControlBus.value("unit3freq");
		Pbindef(\unit4, \dur, Pseq([0.5, Rest(0.25), 0.5, 0.25, Rest(0.5), 0.5], inf)).quant_(~globalQuant);
		Pbindef(\unit5, \dur, Pseq([0.5, 0.375, Rest(0.375), Rest(0.25), 0.75, 0.25], inf)).quant_(~globalQuant);
		Pbindef(\unit6,
			\dur, Pseq([Rest(0.5), 2, Rest(0.25), 1.5, 0.25, Rest(0.5)], inf), // 0.5+ 2+ 0.25+ 1.5+ 0.25+ 0.5 == 5
			\bdFrqL1, 251.3,
			\bdFrqL2, 180,
			\bdFrqL3, 20,
			\bdFrqT1, 0.03,
			\bdAmpSus, 0.38,
			\popFrqEnd, 271,
			\popAmpLev, 0.7
		).quant_(~globalQuant);
		~resetControlBus.value("unit6");
		Pbindef(\unit7, \dur, Pseq([0.25, 0.125, 0.125, 0.5, 0.25], inf)).quant_(~globalQuant);
		Pbindef(\unit8, \dur, 0.5, \envL2, 0.2).quant_(~globalQuant);
		~resetControlBus.value("unit8envL2");
		20.0.wait;
	};

	~song4Part8 = {
		"song4 part8".postln;
		~song4InitPart.value;
		Pbindef(\unit2,
			\dur, 2.5,
			\timingOffset, Pseq([0, 0.2], inf),
			\amp, 0.16 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\envLev4, 0.38,
			\rel, 0.22,
		).quant_(~globalQuant);
		~resetControlBus.value(#["rimunit2amp", "rimunit2envLev4", "rimunit2rel"]);
		Pbindef(\unit3,
			\amp, 0.17 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\freq, 95,
			\ffreq, 488,
			\release, 0.79
		).quant_(~globalQuant);
		~resetControlBus.value("unit3");
		Pbindef(\unit4, \dur, Pseq([Rest(0.5), 1, 1.5, 1, 1/**/, 0.5, 1, 1.5, 1, 1], inf)).quant_(~globalQuant);
		Pbindef(\unit5, \dur, Pseq([Rest(0.75), 1, 0.75, Rest(1), 1, 0.5], inf)).quant_(~globalQuant); // 0.75+ 1+ 0.75+ 1+ 1+ 0.5
		Pbindef(\unit6,
			\dur, Pseq([Rest(0.75), 0.5, 0.75, Rest(0.5)/**/, Rest(0.75), 0.5, Rest(0.25), 1/*, Rest(0.25), 1.5, 0.5, Rest(0.25)/**/, Rest(0.25), 1.5, Rest(0.75)*/], inf),
			\bdFrqL1, 261,
			\bdFrqL2, 116,
			\bdFrqL3, 64,
			\bdFrqT1, 0.035,
			\bdAmpSus, 0.1,
			\popFrqEnd, 261,
			\popAmpLev, 0.39
		).quant_(~globalQuant);
		~resetControlBus.value("unit6");
		Pbindef(\unit7, \dur, 0.5).quant_(~globalQuant);
		Pbindef(\unit8,
			\dur, Pseq([Rest(0.25), 0.25, 0.5, 0.25, Rest(0.25), 0.5, 0.25, Rest(0.25), Rest(0.25), 0.5, 0.5, Rest(0.25), 0.5, Rest(0.25), 0.25], inf),
			\envL2, 0,
			\envT2, 0.04,
			\envT3, 0.02,
			\envC1, -41.3,
			\amp, 0.0085 * Pfunc({ 1 - ~muteState.at(~pdefName); })
		).quant_(~globalQuant);
		~resetControlBus.value("unit8");
		35.0.wait;
		//~changePattern.value(Pdef(\unit2), ~initPattern);
		Pbindef(\unit2, \dur, Pseq([1.25, Rest(3.75)], inf)).quant_(~globalQuant);
		Pbindef(\unit3,
			\amp, 0.3 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\freq, 95,
			\ffreq, 53,
			\release, 1.75
		).quant_(~globalQuant);
		~resetControlBus.value("unit3");
		Pbindef(\unit4, \dur, Pseq([0.5, 1, Rest(0.25), 0.25, Rest(1), 0.5, Rest(0.5), 0.75, Rest(0.25)], inf)).quant_(~globalQuant); // 0.5+ 1.5+ 0.75+ 0.75+ 0.5+ 0.75+ 0.25 == 5
		Pbindef(\unit5, \dur, Pseq([Rest(0.5), Rest(0.375), 0.375, Rest(1), 0.25/**/, Rest(0.375), 0.5, Rest(0.375), 0.25, Rest(1)], inf)).quant_(~globalQuant); // 0.5+ 0.375+ 0.375+ 1+ 0.25+ 0.375+ 0.5+ 0.375+ 0.25+ 1 == 5
		Pbindef(\unit6, \dur, Pseq([Rest(1), 0.5, Rest(1)/**/, 0.25, Rest(1.75), 0.5], inf)).quant_(~globalQuant);
		5.0.wait;
	};

	// Synth + Fx Preset

	{
		// Synth

		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "amp").valueAction_(0.12);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "attack").valueAction_(0.58);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "release").valueAction_(1);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "buffer").valueAction_(8);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "rate").valueAction_(0.24);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "startPos").valueAction_(0.03);

		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "amp").valueAction_(0.66);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "curve").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "attack").valueAction_(0.2);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "release").valueAction_(4);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel1").valueAction_(8.5);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel2").valueAction_(45.8);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel3").valueAction_(25);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel4").valueAction_(47);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel5").valueAction_(17.5);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel6").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime1").valueAction_(0.39);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime2").valueAction_(0.64);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime3").valueAction_(0.73);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime4").valueAction_(0.35);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime5").valueAction_(0);

		// aux 1

		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "drywet").valueAction_(-0.58);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "attack").valueAction_(1.02);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "release").valueAction_(0.01);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "noiseType").valueAction_(0);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "noiseLevel").valueAction_(1);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "impFreq").valueAction_(34);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "impLevel").valueAction_(5.73);

		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "drywet").valueAction_(-1);
		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "amp").valueAction_(0.14);
		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "smooth").valueAction_(0.1);
		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "level").valueAction_(0.44);

		~autoGuiControl.at("distoInsideOut" ++ ~nodeId.at("distoInsideOut") ++ "drywet").valueAction_(-1);
		~autoGuiControl.at("distoInsideOut" ++ ~nodeId.at("distoInsideOut") ++ "level").valueAction_(0.02);

		~autoGuiControl.at("waveShape" ++ ~nodeId.at("waveShape") ++ "mix").valueAction_(0.1);
		~autoGuiControl.at("waveShape" ++ ~nodeId.at("waveShape") ++ "gain").valueAction_(29.9);

		// aux 2

		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "drywet").valueAction_(0.54);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "feedBack").valueAction_(0.24);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync1").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync2").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync3").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync4").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "amp4").valueAction_(0);

		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "drywet").valueAction_(0.43);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "pitchRatio").valueAction_(0.07);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "pitchDisper").valueAction_(0.01);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "timeDisper").valueAction_(0.43);

		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "drywet").valueAction_(-0.92);
		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "fgfreq").valueAction_(55.1);
		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "fdback").valueAction_(0.87);

		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "drywet").valueAction_(0.28);

		~channel.at(\level2).valueAction_(0.17);
	}.defer;

	~songInit.value;

	loop {
		~song4Part1.value;
		~song4Part2.value;
		~song4Part3.value;
		~song4Part4.value;
		~song4Part5.value;
		~song4Part4.value;
		~song4Part6.value;
		~song4Part1.value;
		~song4Part7.value;
		~song4Part8.value;
	}
};

~song5 = {// ~globalQuant = 7; // !!! change globalQuant before song !!!
	t.tempo = 76 / 60; // 54 / 60
	t.beatsPerBar = 7;
	Pdefn(\patt3_8_dur, Pseq([1, 2, 0.5, 2, 1, 0.5], inf)).quant_(~globalQuant);

	// Part

	~song5InitPart = {
		~changePattern.value(Pdef(\unit1), ~song5Pattern1);
		~changePattern.value(Pdef(\unit2), ~song5Pattern2);
		~changePattern.value(Pdef(\unit3), ~song5Pattern3);
		~changePattern.value(Pdef(\unit4), ~song5Pattern4);
		~changePattern.value(Pdef(\unit5), ~song5Pattern5);
		~changePattern.value(Pdef(\unit6), ~song5Pattern6);
		~changePattern.value(Pdef(\unit7), ~song5Pattern7);
		~changePattern.value(Pdef(\unit8), ~song5Pattern8);
		~resetAllControlBus.value;
	};

	~song5Part1 = {
		"song5 part1".postln;
		~song5InitPart.value;
		28.0.wait;
	};

	~song5Part2 = {
		"song5 part2".postln;
		~song5InitPart.value;
		Pbindef(\unit6,
			\dur, Pseq([Rest(1), 0.75, Rest(0.25), 0.56, 0.94/**/, Rest(1), 0.75, Rest(0.25), Rest(0.625), 0.875], inf), // 1+ 0.75+ 0.25+ 0.625+ 0.875
			\amp, 0.16 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
		).quant_(~globalQuant);
		~resetControlBus.value("unit6amp");
		14.0.wait;
	};

	~song5Part3 = {
		"song5 part3".postln;
		~song5InitPart.value;
		Pbindef(\unit4,
			\dur, Pseq([1, 0.75, Rest(0.75), 1], inf),
		).quant_(~globalQuant);
		Pbindef(\unit6,
			\dur, Pseq([Rest(0.05), 1.25, Rest(0.45), Rest(0.75), 1/**/, Pn(Pseq([Rest(0.05), 1.7, Rest(0.1), 1.65]), 3), inf]),
			\amp, 0.18 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
		).quant_(~globalQuant);
		~resetControlBus.value("unit6amp");
		Pbindef(\unit7,
			\dur, Pseq([0.125, 0.25, 0.125, 0.125, 0.25, 0.125, 0.125, 0.25, 0.125, 0.25], inf) // 0.125+ 0.25+ 0.125+ 0.125+ 0.25+ 0.125+ 0.125+ 0.25+ 0.125+ 0.25 == 1.75
		).quant_(~globalQuant);
		14.0.wait;
	};

	~song5Part4 = {
		"song5 part4".postln;
		~song5InitPart.value;
		Pbindef(\unit2,
			\dur, Pseq([Rest(0.55), 1, 1.5, Rest(0.5), 1, 1.5, 0.95], inf)
		).quant_(~globalQuant);
		Pbindef(\unit4,
			\dur, Pseq([1, 0.75, Rest(0.75), 1], inf)
		).quant_(~globalQuant);
		Pbindef(\unit5,
			\dur, Pseq([Rest(0.75), 0.75, Rest(1.75), 0.25/**/, Rest(0.75), 0.75, 2], inf)
		).quant_(~globalQuant);
		Pbindef(\unit7,
			\dur, Pseq([0.125, 0.125, 0.25, 0.125, Rest(0.125), 0.125], inf) // (0.125 * 5) + 0.25
		).quant_(~globalQuant);
		28.0.wait;
	};

	~song5Part5 = {
		"song5 part5".postln;
		~song5InitPart.value;
		Pbindef(\unit2,
			\dur, Pseq([Rest(0.55), 1, 1.5, Rest(0.5), 1.5, 1, Rest(0.95)], inf)
		).quant_(~globalQuant);
		Pdefn(\patt3_8_dur, Pseq([1, 0.5, Rest(2), 2, 1.5], inf)).quant_(~globalQuant);
		Pbindef(\unit3,
			\release, Pseq([0.94, 1.3, 0.24, 1.84, 0.01], inf),
			\amp, 7 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\seqv1, 0.12,
			\seqv2, 6,
			\seqv3, 0.16,
			\seqv4, 0,
			\seqv5, 0,
			\seqFreq, 0.41,
			\freqMin, 219,
	        \freqMax, 321,
			\bwrMod, 0.3
		).quant_(~globalQuant);
		~resetControlBus.value("unit3");
		Pbindef(\unit5,
			\dur, Pseq([Rest(0.75), 0.75, Rest(1.75), 0.25/**/, Rest(0.75), 1.75, 1], inf)
		).quant_(~globalQuant);
		Pbindef(\unit7,
			\dur, Pseq([0.125, 0.25, 0.125, 0.125, 0.25, 0.125, 0.125, 0.25, 0.125, 0.25], inf) // (0.125 * 2) + 0.25
		).quant_(~globalQuant);
		28.0.wait;
	};

	~song5Part6 = {
		"song5 part6".postln;
		~song5InitPart.value;
		Pbindef(\unit2,
			\dur, Pseq([Rest(0.55), 1, 1.5, Rest(0.5), 1.5, 1, Rest(0.95)], inf)
		).quant_(~globalQuant);
		Pdefn(\patt3_8_dur, Pseq([1, Rest(0.5), 2, 2, 1.5], inf)).quant_(~globalQuant);
		Pbindef(\unit3,
			\release, Pseq([0.94, 1.3, 0.24, 1.84, 0.01], inf),
			\amp, 7 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\seqv1, 0.12,
			\seqv2, 6,
			\seqv3, 0.16,
			\seqv4, 0,
			\seqv5, 0,
			\seqFreq, 0.41,
			\freqMin, 219,
	        \freqMax, 321,
			\bwrMod, 0.3
		).quant_(~globalQuant);
		~resetControlBus.value("unit3");
		Pbindef(\unit4,
			\dur, Pseq([1, 0.75, Rest(0.75), 1/**/, 1.5, Rest(1.5), 0.25, Rest(0.25)], inf),
		).quant_(~globalQuant);
		Pbindef(\unit5,
			\dur, Pseq([Rest(0.75), 0.75, 0.25, Rest(1.75)/**/, Rest(0.75), 1, 1.75], inf),
			\freqTime, 0.49,
			\ringTime, 223.68,
		).quant_(~globalQuant);
		~resetControlBus.value(#["kick808Awunit5freqTime", "kick808Awunit5ringTime"]);
		Pbindef(\unit7,
			\dur, Pseq([0.125, 0.125, 0.25, 0.125, Rest(0.125), 0.125], inf) // 0.125+ 0.25+ 0.125+ 0.125+ 0.25+ 0.125+ 0.125+ 0.25+ 0.125+ 0.25 == 1.75
		).quant_(~globalQuant);
		14.0.wait;
	};

	~song5Part7 = {
		"song5 part7".postln;
		~song5InitPart.value;
		Pbindef(\unit1,
			\dur, Pseq([Pn(3.5, 3), 2.25, 1.25], inf), // 1.75 * 6 + 2.25 + 1.25
		).quant_(~globalQuant);
		Pbindef(\unit2,
			\dur, Pseq([Rest(0.55), 1, 1.5, Rest(0.5), 1.5, 1, Rest(0.95)], inf)
		).quant_(~globalQuant);
		Pdefn(\patt3_8_dur, Pseq([1, Rest(0.5), 2, 2, 1.5], inf)).quant_(~globalQuant);
		Pbindef(\unit3,
			\release, Pseq([0.94, 1.3, 0.24, 1.84, 0.01], inf),
			\amp, 7 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
			\seqv1, 0.12,
			\seqv2, 6,
			\seqv3, 0.16,
			\seqv4, 0,
			\seqv5, 0,
			\seqFreq, 0.41,
			\freqMin, 219,
	        \freqMax, 321,
			\bwrMod, 0.3
		).quant_(~globalQuant);
		~resetControlBus.value("unit3");
		Pbindef(\unit4,
			\dur, Pseq([1, 0.75, Rest(0.75), 1/**/, 1.5, Rest(1.5), 0.25, Rest(0.25)], inf),
		).quant_(~globalQuant);
		~changePattern.value(Pdef(\unit5), ~song5Pattern9);
		14.0.wait;
	};

	~song5Part8 = {
		"song5 part8".postln;
		~song5InitPart.value;
		Pbindef(\unit2,
			\dur, Pseq([Rest(0.55), 1, 1.5, Rest(0.5), 1.5, 1, Rest(0.95)], inf)
		).quant_(~globalQuant);
		Pbindef(\unit4,
			\dur, Pseq([1, 0.75, Rest(0.75), 1/**/, 1.5, Rest(1.5), 0.25, Rest(0.25)], inf),
		).quant_(~globalQuant);
		Pbindef(\unit5,
			\dur, Pseq([Rest(0.75), 0.75, 0.25, Rest(1.75)/**/, Rest(0.75), 1, 1.75], inf),
			\freqTime, 0.49,
			\ringTime, 223.68,
		).quant_(~globalQuant);
		~resetControlBus.value(#["kick808Awunit5freqTime", "kick808Awunit5ringTime"]);
		7.0.wait;
		~changePattern.value(Pdef(\unit5), ~song5Pattern9);
		Pbindef(\unit7,
			\dur, Pseq([0.125, 0.25, 0.125, 0.125, 0.25, 0.125, 0.125, 0.25, 0.125, 0.25], inf) // (0.125 * 2) + 0.25
		).quant_(~globalQuant);
		7.0.wait;
	};

	// Synth + Fx Preset

	{
		// Synth

		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "amp").valueAction_(0.14);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "attack").valueAction_(0.58);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "release").valueAction_(1);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "buffer").valueAction_(15);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "rate").valueAction_(0.41);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "startPos").valueAction_(0.03);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "loop").valueAction_(0);

		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "amp").valueAction_(0.55);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "curve").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "loopNode").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "attack").valueAction_(0.2);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "release").valueAction_(4);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel1").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel2").valueAction_(49.5);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel3").valueAction_(64);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel4").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel5").valueAction_(64);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel6").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime1").valueAction_(0.86);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime2").valueAction_(1.1);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime3").valueAction_(0.71);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime4").valueAction_(0.63);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime5").valueAction_(0.23);

		// aux 1

		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "drywet").valueAction_(-0.58);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "attack").valueAction_(1.02);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "release").valueAction_(0.01);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "noiseType").valueAction_(0);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "noiseLevel").valueAction_(1);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "impFreq").valueAction_(34);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "impLevel").valueAction_(5.26);

		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "drywet").valueAction_(-1);
		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "amp").valueAction_(0.14);
		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "smooth").valueAction_(0.1);
		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "level").valueAction_(0.44);

		~autoGuiControl.at("distoInsideOut" ++ ~nodeId.at("distoInsideOut") ++ "drywet").valueAction_(-1);
		~autoGuiControl.at("distoInsideOut" ++ ~nodeId.at("distoInsideOut") ++ "level").valueAction_(0.02);

		~autoGuiControl.at("waveShape" ++ ~nodeId.at("waveShape") ++ "mix").valueAction_(0.21);
		~autoGuiControl.at("waveShape" ++ ~nodeId.at("waveShape") ++ "gain").valueAction_(29.9);

		// aux 2

		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "drywet").valueAction_(0.54);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "feedBack").valueAction_(0.24);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync1").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync2").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync3").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync4").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "amp3").valueAction_(0);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "amp4").valueAction_(0);

		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "drywet").valueAction_(0.95);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "pitchRatio").valueAction_(1.01);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "pitchDisper").valueAction_(0.37);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "timeDisper").valueAction_(0.43);

		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "drywet").valueAction_(0.43);
		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "fgfreq").valueAction_(0);
		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "fdback").valueAction_(0.36);

		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "drywet").valueAction_(0);
		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "feedback").valueAction_(0);
		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "room").valueAction_(1);
		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "damp").valueAction_(0.02);
		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "amount").valueAction_(1);

		~channel.at(\level2).valueAction_(0.17);
	}.defer;

	~songInit.value;

	loop {
		~song5Part1.value;
		~song5Part2.value;
		~song5Part3.value;
		~song5Part4.value;
		~song5Part5.value;
		~song5Part6.value;
		~song5Part7.value;
		~song5Part8.value;
	}
};

~song6 = {// ~globalQuant = 5; // !!! change globalQuant before song !!!
	t.tempo = 68 / 60;
	t.beatsPerBar = 5;

	// Part

	~song6InitPart = {
		~changePattern.value(Pdef(\unit1), ~song6Pattern1);
		~changePattern.value(Pdef(\unit2), ~song6Pattern2);
		~changePattern.value(Pdef(\unit3), ~song6Pattern3);
		~changePattern.value(Pdef(\unit4), ~song6Pattern4);
		~changePattern.value(Pdef(\unit5), ~song6Pattern5);
		~changePattern.value(Pdef(\unit6), ~song6Pattern6);
		~changePattern.value(Pdef(\unit7), ~song6Pattern7);
		~changePattern.value(Pdef(\unit8), ~song6Pattern8);
		Pdefn(\patt1_6_dur, Pseq([0.125, 0.25, 0.125, 0.25, 0.5/**/, 0.125, 0.25, 0.5, 0.125, 0.25/**/, 0.125, 0.25, 0.125, 0.5, 0.25/**/, 0.125, 0.5, 0.25, 0.125, 0.25], inf)).quant_(~globalQuant);
		~resetAllControlBus.value;
	};

	~song6Part1 = {
		"song6 part1".postln;
		~song6InitPart.value;
		40.0.wait;
	};

	~song6Part2 = {
		"song6 part2".postln;
		~song6InitPart.value;
		Pdefn(\patt1_6_dur, Pseq([0.125, 0.5, 0.25, 0.25, Rest(0.125)/**/, 0.375, 0.25, 0.25, 0.125, 0.25/**/, 0.125, 0.5, Rest(0.25), 0.25, 0.125/**/, 0.375, 0.25, 0.25, 0.125, 0.25], inf)).quant_(~globalQuant);
		Pbindef(\unit4, \dur, Pseq([Rest(0.5), 1, 0.25, Rest(1), 0.75, 1, Rest(0.5)/**/, 1, Rest(1), 0.75, 1, Rest(0.75), 0.5], inf)).quant_(~globalQuant);
		20.0.wait;
	};

	~song6Part3 = {
		"song6 part3".postln;
		~song6InitPart.value;
		Pbindef(\unit1,
			\envL3, 0.33,
	        \amp1, 0.49,
			\ring1, 1.25,
			\feedBack, 0.68
		).quant_(~globalQuant);
		~resetControlBus.value("unit1");
		Pbindef(\unit2, \dur,  Pseq([Rest(1), 1, Rest(1.25), 1.5, Rest(0.25)/**/, Rest(1.5), 0.5, Rest(1.25), 1.5, Rest(0.25)], inf),
		).quant_(~globalQuant);
		Pbindef(\unit4, \dur, Pseq([Rest(0.5), 1, 0.25, Rest(1), 0.75, 1, Rest(0.5)/**/, 1, Rest(1), Rest(0.75), 1, 0.75, 0.5], inf)).quant_(~globalQuant);
		20.0.wait;
	};

	~song6Part4 = {
		"song6 part4".postln;
		~song6InitPart.value;
		Pbindef(\unit1,
			\envL3, 0.33,
	        \amp1, 0.49,
			\ring1, 1.25,
			\feedBack, 0.68
		).quant_(~globalQuant);
		~resetControlBus.value("unit1");
		Pdefn(\patt1_6_dur, Pseq([0.125, 0.5, 0.25, 0.25, Rest(0.125)/**/, 0.375, 0.25, 0.25, 0.125, 0.25/**/, 0.125, 0.5, Rest(0.25), 0.25, 0.125/**/, 0.375, 0.25, 0.25, 0.125, 0.25], inf)).quant_(~globalQuant);
		Pbindef(\unit2, \dur,  Pseq([Rest(1), 1, Rest(1.25), 1.5, Rest(0.25)/**/, Rest(1.5), 0.5, Rest(1.25), 1.5, Rest(0.25)], inf),
		).quant_(~globalQuant);
		~changePattern.value(Pdef(\unit3), ~song6Pattern9);
		40.0.wait;
	};

	~song6Part5 = {
		"song6 part5".postln;
		~song6InitPart.value;
		Pbindef(\unit1,
			\freq2, 83.36,
	        \offset1, -2.18,
			\ring1, 1.25,
			\feedBack, 0.6
		).quant_(~globalQuant);
		~resetControlBus.value("unit1");
		Pdefn(\patt1_6_dur, Pseq([0.125, 0.5, 0.25, Rest(0.375)/**/, 0.375, 0.25, Rest(0.375), 0.25]*2, inf)).quant_(~globalQuant);
		Pbindef(\unit2, \dur,  Pseq([Rest(1.5), 0.5, Rest(1.25), 1.5, Rest(0.25)/**/, Rest(1.5), 0.5, Rest(1.25), 1.5, Rest(0.25)], inf),
		).quant_(~globalQuant);
		~changePattern.value(Pdef(\unit3), ~song6Pattern9);
		Pbindef(\unit4, \dur, Pseq([Rest(0.5), 1, Rest(1.25), 0.75, 1, Rest(0.5)/**/, 1, Rest(1), Rest(0.75), 1, 0.75, 0.5], inf)).quant_(~globalQuant);
		Pbindef(\unit8, \dur, Pseq([0.5, 0.25, 0.125, 0.75, 0.5, 0.125, 0.25], inf)).quant_(~globalQuant);
		20.0.wait;
	};

	~song6Part6 = {
		"song6 part6".postln;
		~song6InitPart.value;
		Pbindef(\unit1,
			\freq2, 83.36,
	        \offset1, -2.18,
			\ring1, 1.25,
			\feedBack, 0.6
		).quant_(~globalQuant);
		~resetControlBus.value("unit1");
		Pdefn(\patt1_6_dur, Pseq([Rest(0.125), 0.5, Rest(0.25), 0.375/**/, 0.375, 0.25, Rest(0.375), 0.25]*2, inf)).quant_(~globalQuant); // 0.125+ 0.5+ 0.25+ 0.375+ 0.375+ 0.25+ 0.375
		Pbindef(\unit2, \dur,  Pseq([Rest(1), 1, Rest(1.25), 1.5, Rest(0.25)/**/, Rest(1.5), 0.5, Rest(1.25), 1.5, Rest(0.25)], inf),
		).quant_(~globalQuant);
		~changePattern.value(Pdef(\unit3), ~song6Pattern9);
		Pbindef(\unit4, \dur, Pseq([Rest(0.5), 1, Rest(2), 1, Rest(0.5)/*, 1, Rest(1), Rest(0.75), 1, 0.75, 0.5*/], inf)).quant_(~globalQuant);
		~changePattern.value(Pdef(\unit5), ~song6Pattern11);
		/*Pbindef(\unit5, \dur, Pseq([Rest(0.25), 0.5, 1.25, Rest(1.25), 1.25, Rest(0.75)/**/, 0.25, Rest(1.25), Rest(1.5), 1, Rest(0.75)], inf)).quant_(~globalQuant); // 0.25+ 0.75+ 1+ 1.25+ 1.25+ 0.75+ 0.25+ 1.25+ 1.5+ 1+ 0.75*/
		Pbindef(\unit7, \dur, Pseq([Rest(0.125), 0.25, Pn(0.125, 4), Rest(0.25), 0.125, 0.125, Rest(0.25), 0.125, 0.25, Pn(0.125, 4)], inf)).quant_(~globalQuant); // 0.125+0.25+ (0.125 *4)+ 0.25+ 0.125+ 0.125+ 0.25+ 0.125+ 0.25+ (0.125* 4)
		Pbindef(\unit8, \dur, Pseq([0.5, 0.25, Rest(0.125), 0.75, Rest(0.5), 0.125, 0.25], inf)).quant_(~globalQuant);
		40.0.wait;
	};

	~song6Part7 = {
		"song6 part7".postln;
		~song6InitPart.value;
		Pbindef(\unit1,
			\freq2, 0,
	        \offset1, -1.09,
			\offset2, 0.35,
			\fm2, 7.63,
			\ring1, 0.17,
			\feedBack, 0.74,
			\amp, 0.02 * Pfunc({ 1 - ~muteState.at(~pdefName); })
		).quant_(~globalQuant);
		~resetControlBus.value("unit1");
		Pdefn(\patt1_6_dur, Pseq([0.25, 0.125, 0.125, 0.25, 0.125, 0.25, 0.125/**/, 0.125, 0.5, 0.25, 0.375/**/, 0.375, 0.25, 0.375, 0.25/**/, 0.125, 0.5, 0.25, 0.375], inf)).quant_(~globalQuant);
		Pbindef(\unit2, \dur,  Pseq([Rest(1.5), 0.5, Rest(1.25), 1.5, Rest(0.25)/**/, Rest(1.5), 0.5, Rest(1.25), 1.5, Rest(0.25)], inf),
		).quant_(~globalQuant);
		~changePattern.value(Pdef(\unit3), ~song6Pattern9);
		Pbindef(\unit4, \dur, Pseq([Rest(0.5), 1, Rest(1.25), 0.75, 1, Rest(0.5)/**/, 1, Rest(1), Rest(0.75), 1, 0.75, 0.5], inf)).quant_(~globalQuant);
		~changePattern.value(Pdef(\unit5), ~song6Pattern11);
		Pbindef(\unit5, \dur, 5).quant_(~globalQuant);
		/*Pbindef(\unit5, \dur, Pseq([Rest(0.25), 0.5, 1.25, Rest(1.25), 1.25, Rest(0.75)/**/, 0.25, Rest(1.25), Rest(1.5), 1, Rest(0.75)], inf)).quant_(~globalQuant); // 0.25+ 0.75+ 1+ 1.25+ 1.25+ 0.75+ 0.25+ 1.25+ 1.5+ 1+ 0.75*/
		Pbindef(\unit7, \dur, Pseq([Rest(0.125), 0.25, Pn(0.125, 4), Rest(0.25), 0.125, 0.125, Rest(0.25), 0.125, 0.25, Pn(0.125, 4)]*2, inf)).quant_(~globalQuant);
		Pbindef(\unit8, \dur, Pseq([0.5, 0.25, Rest(0.125), 0.75, Rest(0.5), 0.125, 0.25], inf)).quant_(~globalQuant);
		20.0.wait;
	};

	~song6Part8 = {
		"song6 part8".postln;
		~song6InitPart.value;
		Pbindef(\unit1,
			\freq2, 0,
	        \offset1, -1.04, // -0.93,
			\offset2, 0.08, // 0.35,
			\pm1, 9.12,
			\fm2, 0.19,
			\ring1, 1.25,
			\feedBack, 0.81, // 0.9,
			\amp, 0.021 * Pfunc({ 1 - ~muteState.at(~pdefName); })
		).quant_(~globalQuant);
		~resetControlBus.value("unit1");
		Pdefn(\patt1_6_dur, Pseq([0.125, 0.5, Rest(0.25), 0.25, Rest(0.125)/**/, 0.375, 0.25, 0.25, 0.125, Rest(0.25)], inf)).quant_(~globalQuant);
		~changePattern.value(Pdef(\unit3), ~song6Pattern9);
		Pbindef(\unit4, \dur, Pseq([Rest(0.5), 1, Rest(1.25), 0.75, 1, Rest(0.5)/**/, 1, Rest(1), Rest(0.75), 1, 0.75, 0.5], inf)).quant_(~globalQuant);
		Pbindef(\unit5, \dur, Pseq([Rest(0.25), 0.5, 1.25, Rest(1.25), 1.25, Rest(0.75)/**/, 0.25, Rest(1.25), Rest(1.5), 1, Rest(0.75)], inf)).quant_(~globalQuant);
		Pbindef(\unit8, \dur, Pseq([0.5, Rest(0.25), 0.125, 0.75, Rest(0.5), 0.125, 0.25], inf)).quant_(~globalQuant);
		40.0.wait;
	};

	// Synth + Fx Preset

	{
		// Synth

		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "amp").valueAction_(0.09);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "attack").valueAction_(2.89);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "release").valueAction_(3.16);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "curve").valueAction_(-4);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "buffer").valueAction_(49);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "rate").valueAction_(0.87);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "startPos").valueAction_(0.05);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "loop").valueAction_(0);

		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "amp").valueAction_(0.4);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "loopNode").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "attack").valueAction_(0.2);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "release").valueAction_(4);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "curve").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel1").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel2").valueAction_(66);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel3").valueAction_(66);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel4").valueAction_(42.5);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel5").valueAction_(65.7);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel6").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime1").valueAction_(0.35);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime2").valueAction_(0.66);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime3").valueAction_(0.24);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime4").valueAction_(0.41);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime5").valueAction_(0.19);

		// aux 1

		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "drywet").valueAction_(-0.78);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "attack").valueAction_(0.04);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "release").valueAction_(0.67);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "noiseType").valueAction_(0);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "noiseLevel").valueAction_(0.31);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "impFreq").valueAction_(34);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "impLevel").valueAction_(4.99);

		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "drywet").valueAction_(-1);
		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "amp").valueAction_(0.14);
		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "smooth").valueAction_(0.1);
		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "level").valueAction_(0.44);

		~autoGuiControl.at("distoInsideOut" ++ ~nodeId.at("distoInsideOut") ++ "drywet").valueAction_(-1);
		~autoGuiControl.at("distoInsideOut" ++ ~nodeId.at("distoInsideOut") ++ "level").valueAction_(0.02);

		~autoGuiControl.at("waveShape" ++ ~nodeId.at("waveShape") ++ "mix").valueAction_(0.66);
		~autoGuiControl.at("waveShape" ++ ~nodeId.at("waveShape") ++ "gain").valueAction_(29.9);

		// aux 2

		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "drywet").valueAction_(0.54);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "feedBack").valueAction_(0.24);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync1").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync2").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync3").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync4").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "amp3").valueAction_(0);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "amp4").valueAction_(0);

		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "drywet").valueAction_(1);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "pitchRatio").valueAction_(0.28);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "pitchDisper").valueAction_(0.37);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "timeDisper").valueAction_(0.43);

		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "drywet").valueAction_(0.43);
		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "fgfreq").valueAction_(118.1);
		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "fdback").valueAction_(0.17);

		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "drywet").valueAction_(0);
		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "feedback").valueAction_(0.41);
		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "room").valueAction_(0.8);
		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "damp").valueAction_(0.84);
		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "amount").valueAction_(1);

		~channel.at(\level2).valueAction_(0.17);
	}.defer;

	~songInit.value;

	loop {
		~song6Part1.value;
		~song6Part2.value;
		~song6Part3.value;
		~song6Part4.value;
		~song6Part5.value;
		~song6Part6.value;
		~song6Part7.value;
		~song6Part8.value;
	}
};

~song7 = {// ~globalQuant = 7; // !!! change globalQuant before song !!!
	t.tempo = 118 / 60;
	t.beatsPerBar = 7;

	// Part

	~song7InitPart = {
		~changePattern.value(Pdef(\unit1), ~song7Pattern1);
		~changePattern.value(Pdef(\unit2), ~song7Pattern2);
		~changePattern.value(Pdef(\unit3), ~song7Pattern3);
		~changePattern.value(Pdef(\unit4), ~song7Pattern4);
		~changePattern.value(Pdef(\unit5), ~song7Pattern5);
		~changePattern.value(Pdef(\unit6), ~song7Pattern6);
		~changePattern.value(Pdef(\unit7), ~song7Pattern7);
		~changePattern.value(Pdef(\unit8), ~song7Pattern8);
		Pdefn(\patt1_4_dur, Pseq([1, 1.25, 2, 1.25, 1.5], inf)).quant_(~globalQuant);
		~resetAllControlBus.value;
	};

	~song7Part1 = {
		"song7 part1".postln;
		~song7InitPart.value;
		28.0.wait;
	};

	~song7Part2 = {
		"song7 part2".postln;
		~song7InitPart.value;
		Pdefn(\patt1_4_dur, Pseq([1.75, 0.5, 2, 1.25, 1.5/**/, 1, 1.25, 2, 1.25, 1.5], inf)).quant_(~globalQuant);
		Pbindef(\unit2, \dur, Pseq([Pn(Pseq([Rest(0.75), 1, Rest(1.25), 0.5]), 3)/**/, Rest(0.75), 1.75, 0.5, Rest(0.5)], inf)).quant_(~globalQuant);
		14.0.wait;
	};

	~song7Part3 = {
		"song7 part3".postln;
		~song7InitPart.value;
		Pdefn(\patt1_4_dur, Pseq([1.75, 0.5, 2, 1.25, 1.5/**/, 0.5, 1.75, 2, 1.25, 1.5], inf)).quant_(~globalQuant);
		Pbindef(\unit2, \dur, Pseq([Rest(0.75), 1, Rest(1.25), 0.5, /**/Rest(0.75), 1, Rest(0.5), 1.25], inf)).quant_(~globalQuant);
		14.0.wait;
	};

	~song7Part4 = {
		"song7 part4".postln;
		~song7InitPart.value;
		Pbindef(\unit6, \dur, Pseq([0.875, 3.5, Rest(0.875), 1.75/**/, Rest(0.875), 2.625, 1.5, 0.25, Rest(1.75)], inf)).quant_(~globalQuant);
		28.0.wait;
	};

	~song7Part5 = {
		"song7 part5".postln;
		~song7InitPart.value;
		Pbindef(\unit1,
			\decEnv0, 0.1,
			\relEnv0, 0.03,
			\owhich2, 3
		).quant_(~globalQuant);
		~resetControlBus.value("unit1");
		Pdefn(\patt1_4_dur, Pseq([1.75, 0.5, 2, 1.25, 1.5/**/, 1, 1.25, 2, 1.25, 1.5], inf)).quant_(~globalQuant);
		Pbindef(\unit2,
			\dur, Pseq([Pn(Pseq([Rest(0.75), 1, Rest(1.25), 0.5]), 3)/**/, Rest(0.75), 1.75, 0.5, Rest(0.5)]/2, inf),
			\h1glide, 0.33,
			\h1rq, 0.4,
			\h1curve, -1.08,
			\amp, 0.22 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
		).quant_(~globalQuant);
		~resetControlBus.value("unit2");
		Pbindef(\unit5, \levBiasBpf, 57.4).quant_(~globalQuant);
		~resetControlBus.value("unit5levBiasBpf");
		Pbindef(\unit7, \dur, 1).quant_(~globalQuant);
		56.0.wait;
	};

	~song7Part6 = {
		"song7 part6".postln;
		~song7InitPart.value;
		Pbindef(\unit1,
			\env1L2, Pseq([220, 43]-0.03, inf),
			\decEnv0, Pwhite(0.1, 0.83),
			\relEnv0, Pseq([0.02, 0.79, 0.46, 0.2], inf),
			\owhich2, 3
		).quant_(~globalQuant);
		~resetControlBus.value("unit1");
		Pbindef(\unit5, \levBiasBpf, 57.4).quant_(~globalQuant);
		~resetControlBus.value("unit5levBiasBpf");
		Pbindef(\unit6, \dur, Pseq([0.875, 3.5, Rest(0.875), 1.75/**/, Rest(0.875), 2.625, 1.5, 0.25, Rest(1.75)], inf)).quant_(~globalQuant);
		Pbindef(\unit8,
			\dur, Pseq([Rest(0.21875), 0.109375, 0.21875, Rest(0.109375), 0.21875/**/, Rest(0.109375), 0.21875, Rest(0.21875), 0.109375, Rest(0.21875)]*2, inf)
		).quant_(~globalQuant);
		28.0.wait;
	};

	~song7Part7 = {
		"song7 part7".postln;
		~song7InitPart.value;
		Pbindef(\unit1,
			\env1L2, Pseq([220, 43]-0.03, inf),
			\decEnv0, Pwhite(0.1, 0.3),
			\relEnv0, Pseq([0.02, 0.46, 0.2, 0.79], inf),
			\owhich2, 3
		).quant_(~globalQuant);
		~resetControlBus.value("unit1");
		Pbindef(\unit2,
			\dur, Pseq([Pn(Pseq([Rest(0.75), 1, Rest(1.25), 0.5]), 3)/**/, Rest(0.75), 1.75, 0.5, Rest(0.5)], inf),
			\t2freq, 228.9,
			\t2rel, 0.22,
			\t2amp, 0.5,
			\h1freq, 2246.8,
			\h1harmonic, 118,
			\h1rq, 0.1,
			\h1rel, 0.03,
			\h1curve, -8.15,
			\amp, 0.22 * Pfunc({ 1 - ~muteState.at(~pdefName); }),
		).quant_(~globalQuant);
		~resetControlBus.value("unit2");
		Pbindef(\unit4,
			\phRate, Pseq([665.4, 331], inf),
			\inAmt, 0.9,
			\coef2, Pseq([0.99, 0.98, 0.97, 0.99, 0.97], inf)
		).quant_(~globalQuant);
		~resetControlBus.value(#["tweetKickIntunit4phRate", "tweetKickIntunit4inAmt", "tweetKickIntunit4coef2"]);
		Pbindef(\unit6, \dur, Pseq([0.875, 3.5, Rest(0.875), 1.75/**/, Rest(0.875), 2.625, 1.5, 0.25, Rest(1.75)], inf)).quant_(~globalQuant);
		Pbindef(\unit7, \dur, 1).quant_(~globalQuant);
		Pbindef(\unit8,
			\dur, Pseq([Rest(0.21875), 0.109375, 0.21875, Rest(0.109375), 0.21875/**/, Rest(0.109375), 0.21875, Rest(0.21875), 0.109375, Rest(0.21875)]*2, inf)
		).quant_(~globalQuant);
		56.0.wait;
	};

	~song7Part8 = {
		"song7 part8".postln;
		~song7InitPart.value;
		Pbindef(\unit1,
			\env1L2, Pseq([220, 43]-0.03, inf),
			\decEnv0, Pwhite(0.1, 0.3),
			\relEnv0, Pseq([0.02, 0.46, 0.2, 0.79], inf),
			\owhich2, 3
		).quant_(~globalQuant);
		~resetControlBus.value("unit1");
		Pdefn(\patt1_4_dur, Pseq([1.75, 0.5, 2, 1.25, 1.5/**/, 0.5, 1.75, 2, 1.25, 1.5], inf)).quant_(~globalQuant);
		Pbindef(\unit2,
			\dur, Pseq([Rest(0.75), 1, Rest(1.25), 0.5, /**/Rest(0.75), 1, Rest(0.5), 1.25], inf),
			\t2freq, 228.9,
			\t2rel, 0.22,
			\t2amp, 0.5,
			\h1freq, 2246.8,
			\h1harmonic, 118,
			\h1rq, 0.1,
			\h1rel, 0.03,
			\h1curve, -8.15,
			\amp, 0.22 * Pfunc({ 1 - ~muteState.at(~pdefName); })
		).quant_(~globalQuant);
		~resetControlBus.value("unit2");
		Pbindef(\unit4,
			\phRate, Pseq([665.4, 331], inf),
			\inAmt, 0.9,
			\coef2, Pseq([0.99, 0.98, 0.97, 0.99, 0.97], inf)
		).quant_(~globalQuant);
		~resetControlBus.value(#["tweetKickIntunit4phRate", "tweetKickIntunit4inAmt", "tweetKickIntunit4coef2"]);
		Pbindef(\unit5, \levBiasBpf, 57.4).quant_(~globalQuant);
		~resetControlBus.value("unit5levBiasBpf");
		Pbindef(\unit7, \dur, Pseq([Pn(0.5, 4), Pn(1, 5)], inf)).quant_(~globalQuant);
		56.0.wait;
	};

	// Synth + Fx Preset

	{
		// Synth

		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "amp").valueAction_(0.08);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "attack").valueAction_(0.11);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "release").valueAction_(3.16);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "curve").valueAction_(-4);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "buffer").valueAction_(59);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "rate").valueAction_(1);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "startPos").valueAction_(0);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "loop").valueAction_(0);

		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "amp").valueAction_(0.8);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "loopNode").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "attack").valueAction_(0.2);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "release").valueAction_(4);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "curve").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel1").valueAction_(80);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel2").valueAction_(20.9);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel3").valueAction_(66);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel4").valueAction_(40);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel5").valueAction_(40);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel6").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime1").valueAction_(0.01);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime2").valueAction_(0.75);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime3").valueAction_(0.01);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime4").valueAction_(0.91);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime5").valueAction_(0.19);

		// aux 1

		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "drywet").valueAction_(-0.79);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "attack").valueAction_(0.04);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "release").valueAction_(0.67);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "noiseType").valueAction_(0);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "nType5Chaos").valueAction_(1.49);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "noiseLevel").valueAction_(1.15);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "impSource").valueAction_(0);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "impFreq").valueAction_(34);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "impLevel").valueAction_(3.76);

		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "drywet").valueAction_(-1);
		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "amp").valueAction_(0.14);
		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "smooth").valueAction_(0.1);
		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "level").valueAction_(0.44);

		~autoGuiControl.at("distoInsideOut" ++ ~nodeId.at("distoInsideOut") ++ "drywet").valueAction_(-1);
		~autoGuiControl.at("distoInsideOut" ++ ~nodeId.at("distoInsideOut") ++ "level").valueAction_(0.02);

		~autoGuiControl.at("waveShape" ++ ~nodeId.at("waveShape") ++ "mix").valueAction_(0.24);
		~autoGuiControl.at("waveShape" ++ ~nodeId.at("waveShape") ++ "gain").valueAction_(32.3);

		// aux 2

		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "drywet").valueAction_(-1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "feedBack").valueAction_(0.5);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync1").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync2").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync3").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync4").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "amp3").valueAction_(0);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "amp4").valueAction_(0);

		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "drywet").valueAction_(1);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "pitchRatio").valueAction_(2.14);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "pitchDisper").valueAction_(0.53);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "timeDisper").valueAction_(1);

		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "drywet").valueAction_(0.15);
		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "fgfreq").valueAction_(0);
		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "fdback").valueAction_(0.69);

		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "drywet").valueAction_(-1);
		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "feedback").valueAction_(0.38);
		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "room").valueAction_(0.81);
		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "damp").valueAction_(0.75);
		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "amount").valueAction_(1);

		~channel.at(\level2).valueAction_(0.17);
	}.defer;

	~songInit.value;

	loop {
		~song7Part1.value;
		~song7Part2.value;
		~song7Part3.value;
		~song7Part4.value;
		~song7Part5.value;
		~song7Part6.value;
		~song7Part7.value;
		~song7Part8.value;
	}
};



~song8 = {// ~globalQuant = 9; // !!! change globalQuant before song !!!
	t.tempo = 212 / 60;
	t.beatsPerBar = 9;

	// Part

	~song8InitPart = {
		~changePattern.value(Pdef(\unit1), ~song8Pattern1);
		~changePattern.value(Pdef(\unit2), ~song8Pattern2);
		~changePattern.value(Pdef(\unit3), ~song8Pattern3);
		~changePattern.value(Pdef(\unit4), ~song8Pattern4);
		~changePattern.value(Pdef(\unit5), ~song8Pattern5);
		~changePattern.value(Pdef(\unit6), ~song8Pattern6);
		~changePattern.value(Pdef(\unit7), ~song8Pattern7);
		~changePattern.value(Pdef(\unit8), ~song8Pattern8);
		Pdefn(\patt1_5_dur, Pseq([Rest(0.5), 1.75, 0.125, Rest(1.125), 1], inf)).quant_(~globalQuant);
		Pdefn(\patt3_4_dur, Pseq([1, 1.5, 3, 0.5, Rest(3)/**/, 1, 1.5, 3, 0.5, Rest(1), 2/**/, 1, 1.5, 3, 0.5, Rest(3)/**/, 1, 1.5, 3, 0.5, Rest(1.125), 1.875], inf)).quant_(~globalQuant);
		~resetAllControlBus.value;
	};

	~song8Part1 = {
		"song8 part1".postln;
		~song8InitPart.value;
		36.0.wait;
	};

	~song8Part2 = {
		"song8 part2".postln;
	    ~song8InitPart.value;
	    Pdefn(\patt1_5_dur, Pseq([Rest(0.5), 1.75, 0.125, Rest(1.125), 1/**/, Rest(0.5), 1.75, Rest(0.75), 0.5, 1/**/, Rest(0.5), 1.75, 0.125, Rest(1.125), 1/**/, Rest(0.5), 1.75, 1.125, Rest(1.125)], inf)).quant_(~globalQuant);
	    Pdefn(\patt3_4_dur, Pseq([1, 1.5, 3, 0.5, Rest(3)/**/, 1, 1.5, 3, 0.5, Rest(1), 2], inf)).quant_(~globalQuant);
		18.0.wait;
	};

	~song8Part3 = {
		"song8 part3".postln;
		~song8InitPart.value;
		Pdefn(\patt1_5_dur, Pseq([Rest(0.5), 1.75, 0.125, Rest(1.125), 1/**/, Rest(0.5), 1.75, Rest(0.75), 0.5, 1/**/, Rest(0.5), 1.75, 0.125, Rest(1.125), 1/**/, Rest(0.5), 1.75, 1.125, Rest(1.125)], inf)).quant_(~globalQuant);
		Pbindef(\unit2,
			\dur, Pseq([Rest(0.5), 2, Rest(2), 0.5, Rest(2), 2], inf)
		).quant_(~globalQuant);
		36.0.wait;
	};

	~song8Part4 = {
		"song8 part4".postln;
		~song8InitPart.value;
		Pbindef(\unit2,
			\dur, Pseq([Rest(0.5), 2, Rest(2), 0.5, Rest(2), 2], inf),
			\delTimeL, Pseq([0, 0.15, 0, 0.3, 0.15, 0.3], inf)
		).quant_(~globalQuant);
		~resetControlBus.value("unit2delTimeL");
		Pdefn(\patt3_4_dur, Pseq([1, 1.5, 3, 0.5, Rest(3)/**/, 1, 1.5, 3, 0.5, Rest(1), 2], inf)).quant_(~globalQuant);
		Pbindef(\unit8,
			\dur, Pseq([0.25, 0.5, 0.25, 0.5, 0.5, 0.25/**/, 0.25, 0.5, 0.5, 0.25, 0.5, 0.25], inf)
		).quant_(~globalQuant);
		36.0.wait;
	};

	// Synth + Fx Preset

	{
		// Synth

		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "amp").valueAction_(0.1);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "attack").valueAction_(0.11);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "release").valueAction_(6.05);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "curve").valueAction_(-4);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "buffer").valueAction_(62);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "rate").valueAction_(1);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "startPos").valueAction_(0);
		~autoGuiControl.at("samplerStereo" ++ ~nodeId.at("samplerStereo") ++ "loop").valueAction_(0);

		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "amp").valueAction_(0.91);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "loopNode").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "attack").valueAction_(0.2);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "release").valueAction_(4);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "curve").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel1").valueAction_(20);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel2").valueAction_(44.2);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel3").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel4").valueAction_(40);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel5").valueAction_(40);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envLevel6").valueAction_(0);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime1").valueAction_(0.42);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime2").valueAction_(0.44);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime3").valueAction_(0.32);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime4").valueAction_(0.64);
		~autoGuiControl.at("sinBass" ++ ~nodeId.at("sinBass") ++ "envTime5").valueAction_(1.56);

		// aux 1

		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "drywet").valueAction_(-0.8);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "attack").valueAction_(0.04);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "release").valueAction_(0.67);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "noiseType").valueAction_(3);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "nType5Chaos").valueAction_(0.48);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "noiseLevel").valueAction_(1.15);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "impSource").valueAction_(0);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "impFreq").valueAction_(34);
		~autoGuiControl.at("noiseInjection" ++ ~nodeId.at("noiseInjection") ++ "impLevel").valueAction_(4);

		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "drywet").valueAction_(-1);
		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "amp").valueAction_(0.14);
		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "smooth").valueAction_(0.1);
		~autoGuiControl.at("distoCrossOver" ++ ~nodeId.at("distoCrossOver") ++ "level").valueAction_(0.44);

		~autoGuiControl.at("distoInsideOut" ++ ~nodeId.at("distoInsideOut") ++ "drywet").valueAction_(-1);
		~autoGuiControl.at("distoInsideOut" ++ ~nodeId.at("distoInsideOut") ++ "level").valueAction_(0.02);

		~autoGuiControl.at("waveShape" ++ ~nodeId.at("waveShape") ++ "mix").valueAction_(0.24);
		~autoGuiControl.at("waveShape" ++ ~nodeId.at("waveShape") ++ "gain").valueAction_(32.3);

		// aux 2

		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "drywet").valueAction_(0.28);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "feedBack").valueAction_(0.46);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync1").valueAction_(0);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync2").valueAction_(0);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync3").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "sync4").valueAction_(1);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "amp3").valueAction_(0);
		~autoGuiControl.at("quadDelay" ++ ~nodeId.at("quadDelay") ++ "amp4").valueAction_(0);

		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "drywet").valueAction_(1);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "pitchRatio").valueAction_(0);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "pitchDisper").valueAction_(0);
		~autoGuiControl.at("pitchShifter" ++ ~nodeId.at("pitchShifter") ++ "timeDisper").valueAction_(1);

		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "drywet").valueAction_(-0.15);
		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "fgfreq").valueAction_(126);
		~autoGuiControl.at("flanging" ++ ~nodeId.at("flanging") ++ "fdback").valueAction_(0.9);

		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "drywet").valueAction_(-1);
		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "feedback").valueAction_(0.33);
		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "room").valueAction_(0.81);
		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "damp").valueAction_(0.69);
		~autoGuiControl.at("verb" ++ ~nodeId.at("verb") ++ "amount").valueAction_(1);

		~channel.at(\level2).valueAction_(0.07);
	}.defer;

	~songInit.value;

	loop {
		~song8Part1.value;
		~song8Part2.value;
		~song8Part3.value;
		~song8Part4.value;
		/*~song8Part5.value;
		~song8Part6.value;
		~song8Part7.value;
		~song8Part8.value;*/
	}
};

)