(

///////////////////////////////////////  Gui

///////////////////////////////////////  Mixer Window

var channelMaster, routingSection, mixerMidiChan, pdefGuiView, pdMuteCcStart, pdMuteMidiChan;

~ccStart = 21; // start mapping midi cc from here
~ccStart = ~ccStart.max(1).min(127); // limit ccStart

mixerMidiChan = 0; // 0 for midi channel 1
mixerMidiChan = mixerMidiChan.max(0).min(15);
(mixerMidiChan).debug("mixer midi channel");

~channel = IdentityDictionary.new;

w = Window("Mixer",Rect(0, 8, 850, 725), scroll: true);
w.front;
//w.alwaysOnTop_(true);
w.view.decorator = FlowLayout(w.view.bounds, 3@3, 3@3);

////////////////////  Channel

~channelNumber.do { arg i;
	var bgColor;
	switch(i,
		2, { bgColor = ~aux1Color; },
		3, { bgColor = ~aux2Color; },
		{ bgColor = Color.white; }
	);
	~channel[\channelView] = CompositeView(w, 118@720);
	~channel[\channelView].background_(bgColor);
	~channel[\channelView].decorator_(FlowLayout(~channel[\channelView].bounds, 3@3, 3@3));

	// Channel name
	StaticText(~channel[\channelView], 118@10)
	    .string_("Channel " ++ i)
	    .stringColor_(Color.black)
	    .align_(\center);
	~channel[\channelView].decorator.nextLine;

	// lpf
	~channel[(\activeLpf ++ i).asSymbol] = false;
	~channel[(\lpfreq ++ i).asSymbol] = EZKnob(~channel[\channelView], 124@70, 'lpfreq', ControlSpec(20, 20000, step: 1, default: 20000, units: 'hz'), {
		arg lpfreq;
		currentEnvironment.at((\channel ++ i).asSymbol).set(\lpfreq, lpfreq.value);
		~channel[(\activeLpf ++ i).asSymbol] = false;
	}, margin: 39@0);
	~channel[\channelView].decorator.nextLine;

	// lpf midi map
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, threshold;
		midiControl = val.linlin(0, 127, 20, 20000);
		guiControl = ~channel[(\lpfreq ++ i).asSymbol].value;
		threshold = 500;
		if ( // soft takeover
			(~channel[(\activeLpf ++ i).asSymbol] or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
			{
				~channel[(\activeLpf ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\lpfreq, midiControl);
					~channel[(\lpfreq ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, mixerMidiChan);
	(~ccStart).debug("channel " ++ i ++ " lpfreq cc number");
	~ccStart = ~ccStart + 1;

	3.do({ arg j;
		var default;
		switch(j,
			0, { default = 8000; },
			1, { default = 1200; },
			2, { default = 80; },
			{ default = 1200; }
		);
		j = j + 1;
		// freq
		~channel[(\activeBand ++ j ++ \Freq ++ i).asSymbol] = false;
		~channel[(\band ++ j ++ \freq ++ i).asSymbol] = EZKnob(~channel[\channelView], 35@70, 'freq' ++ j, ControlSpec(20, 20000, step: 1, default: default, units: 'hz'), {
			arg freq;
			currentEnvironment.at((\channel ++ i).asSymbol).set((\band ++ j ++ \freq).asSymbol, freq.value);
			~channel[(\activeBand ++ j ++ \Freq ++ i).asSymbol] = false;
		});

		// freq midi map
		MIDIFunc.cc({ arg val, num, chan, src;
			var guiControl, midiControl, threshold;
			midiControl = val.linlin(0, 127, 20, 20000);
			guiControl = ~channel[(\band ++ j ++ \freq ++ i).asSymbol].value;
			threshold = 500;
			if ( // soft takeover
				(~channel[(\activeBand ++ j ++ \Freq ++ i).asSymbol] or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
				{
					~channel[(\activeBand ++ j ++ \Freq ++ i).asSymbol] = true;
					{
						currentEnvironment.at((\channel ++ i).asSymbol).set((\band ++ j ++ \freq).asSymbol, midiControl);
						~channel[(\band ++ j ++ \freq ++ i).asSymbol].value_(midiControl);
					}.defer;
				}
			);
		}, ~ccStart, mixerMidiChan);
		(~ccStart).debug("channel " ++ i ++ " band" ++ j ++ "freq cc number");
		~ccStart = ~ccStart + 1;

		// rq
		~channel[(\activeBand ++ j ++ \Rq ++ i).asSymbol] = false;
		~channel[(\band ++ j ++ \rq ++ i).asSymbol] = EZKnob(~channel[\channelView], 35@70, 'rq' ++ j, ControlSpec(0, 1, step: 0.01, default: 1), {
			arg rq;
			currentEnvironment.at((\channel ++ i).asSymbol).set((\band ++ j ++ \rq).asSymbol, rq.value);
			~channel[(\activeBand ++ j ++ \Rq ++ i).asSymbol] = false;
		});

		// rq midi map
		MIDIFunc.cc({ arg val, num, chan, src;
			var guiControl, midiControl, threshold;
			midiControl = val.linlin(0, 127, 0, 1);
			guiControl = ~channel[(\band ++ j ++ \rq ++ i).asSymbol].value;
			threshold = 0.1;
			if ( // soft takeover
				(~channel[(\activeBand ++ j ++ \Rq ++ i).asSymbol] or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
				{
					~channel[(\activeBand ++ j ++ \Rq ++ i).asSymbol] = true;
					{
						currentEnvironment.at((\channel ++ i).asSymbol).set((\band ++ j ++ \rq).asSymbol, midiControl);
						~channel[(\band ++ j ++ \rq ++ i).asSymbol].value_(midiControl);
					}.defer;
				}
			);
		}, ~ccStart, mixerMidiChan);
		(~ccStart).debug("channel " ++ i ++ " band" ++ j ++ "rq cc number");
		~ccStart = ~ccStart + 1;

		// db
		~channel[(\activeBand ++ j ++ \Db ++ i).asSymbol] = false;
		~channel[(\band ++ j ++ \db ++ i).asSymbol] = EZKnob(~channel[\channelView], 35@70, 'db' ++ j, ControlSpec(-60, 60, step: 1, default: 0, units: 'db'), {
			arg db;
			currentEnvironment.at((\channel ++ i).asSymbol).set((\band ++ j ++ \db).asSymbol, db.value);
			~channel[(\activeBand ++ j ++ \Db ++ i).asSymbol] = false;
		});

		// db midi map
		MIDIFunc.cc({ arg val, num, chan, src;
			var guiControl, midiControl, threshold;
			midiControl = val.linlin(0, 127, -60, 60);
			guiControl = ~channel[(\band ++ j ++ \db ++ i).asSymbol].value;
			threshold = 10;
			if ( // soft takeover
				(~channel[(\activeBand ++ j ++ \Db ++ i).asSymbol] or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
				{
					~channel[(\activeBand ++ j ++ \Db ++ i).asSymbol] = true;
					{
						currentEnvironment.at((\channel ++ i).asSymbol).set((\band ++ j ++ \db).asSymbol, midiControl);
						~channel[(\band ++ j ++ \db ++ i).asSymbol].value_(midiControl);
					}.defer;
				}
			);
		}, ~ccStart, mixerMidiChan);
		(~ccStart).debug("channel " ++ i ++ " band" ++ j ++ "db cc number");
		~ccStart = ~ccStart + 1;
	});

	// hpf
	~channel[(\activeHpf ++ i).asSymbol] = false;
	~channel[(\hpfreq ++ i).asSymbol] = EZKnob(~channel[\channelView], 120@70, 'hpfreq', ControlSpec(20, 20000, step: 1, default: 20, units: 'hz'), {
		arg hpfreq;
		currentEnvironment.at((\channel ++ i).asSymbol).set(\hpfreq, hpfreq.value);
		~channel[(\activeHpf ++ i).asSymbol] = false;
	}, margin: 39@0);
	~channel[\channelView].decorator.nextLine;

	// hpf midi map
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, threshold;
		midiControl = val.linlin(0, 127, 20, 20000);
		guiControl = ~channel[(\hpfreq ++ i).asSymbol].value;
		threshold = 500;
		if ( // soft takeover
			(~channel[(\activeHpf ++ i).asSymbol] or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
			{
				~channel[(\activeHpf ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\hpfreq, midiControl);
					~channel[(\hpfreq ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, mixerMidiChan);
	(~ccStart).debug("channel " ++ i ++ " hpfreq cc number");
	~ccStart = ~ccStart + 1;

	// aux
	2.do({ arg j;
		var color;
		switch(j,
			0, { color = ~aux1Color; },
			1, { color = ~aux2Color; },
			{ color = Color.white; }
		);
		j = j + 1;

		~channel[(\activeAux ++ j ++ i).asSymbol] = false;
		~channel[(\aux ++ j ++ i).asSymbol] = EZKnob(~channel[\channelView], 35@70, 'aux' ++ j, ControlSpec(0, 1, step: 0.01, default: 0), {
			arg aux;
			currentEnvironment.at((\channel ++ i).asSymbol).set((\auxsend ++ j).asSymbol, aux.value);
			~channel[(\activeAux ++ j ++ i).asSymbol] = false;
		})
		.setColors(background: color);

		// aux midi map
		MIDIFunc.cc({ arg val, num, chan, src;
			var guiControl, midiControl, threshold;
			midiControl = val.linlin(0, 127, 0, 1);
			guiControl = ~channel[(\aux ++ j ++ i).asSymbol].value;
			threshold = 0.1;
			if ( // soft takeover
				(~channel[(\activeAux ++ j ++ i).asSymbol] or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
				{
					~channel[(\activeAux ++ j ++ i).asSymbol] = true;
					{
						currentEnvironment.at((\channel ++ i).asSymbol).set((\auxsend ++ j).asSymbol, midiControl);
						~channel[(\aux ++ j ++ i).asSymbol].value_(midiControl);
					}.defer;
				}
			);
		}, ~ccStart, mixerMidiChan);
		(~ccStart).debug("channel " ++ i ++ " aux" ++ j ++ " cc number");
		~ccStart = ~ccStart + 1;

		if (j == 1, {
			StaticText(~channel[\channelView], 35@65)
			    .string_("Send")
	            .align_(\center);
		});
	});

	// mute
	~channel[(\mute ++ i).asSymbol] = Button(~channel[\channelView], Rect(10,110,112,35)).states_([["Mute", Color.black, Color.white],["Active", Color.white, Color.grey]]).action = {
		arg mute;
		currentEnvironment.at((\channel ++ i).asSymbol).set(\mute, mute.value.linlin(0, 1, 1, 0));
	};

	// mute midi map
	MIDIFunc.cc({ arg val, num, chan, src;
		var midiControl;
		midiControl = val.linlin(0, 127, 0, 1);
		{ ~channel[(\mute ++ i).asSymbol].valueAction_(midiControl); }.defer;
	}, ~ccStart, mixerMidiChan);
	(~ccStart).debug("channel " ++ i ++ " mute cc number");
	~ccStart = ~ccStart + 1;

	// pan
	~channel[(\activePan ++ i).asSymbol] = false;
	~channel[(\pan ++ i).asSymbol] = EZSlider(~channel[\channelView], 112@60, 'pan', ControlSpec(-1, 1, step: 0.01, default: 0), {
		arg pan;
		currentEnvironment.at((\channel ++ i).asSymbol).set(\pan, pan.value);
		~channel[(\activePan ++ i).asSymbol] = false;
	}, layout: 'vert');
	~channel[\channelView].decorator.nextLine;

	// pan midi map
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, threshold;
		midiControl = val.linlin(0, 127, -1, 1);
		guiControl = ~channel[(\pan ++ i).asSymbol].value;
		threshold = 0.1;
		if ( // soft takeover
			(~channel[(\activePan ++ i).asSymbol] or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
			{
				~channel[(\activePan ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\pan, midiControl);
					~channel[(\pan ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, mixerMidiChan);
	(~ccStart).debug("channel " ++ i ++ " pan cc number");
	~ccStart = ~ccStart + 1;

	// level
	~channel[(\activeLevel ++ i).asSymbol] = false;
	~channel[(\level ++ i).asSymbol] = EZSlider(~channel[\channelView], 110@160, 'level', ControlSpec(0, 1, step: 0.01, default: 0.5), {
		arg level;
		currentEnvironment.at((\channel ++ i).asSymbol).set(\level, level.value);
		~channel[(\activeLevel ++ i).asSymbol] = false;
	}, layout: 'vert', margin: 39@0);

	// level midi map
	MIDIFunc.cc({ arg val, num, chan, src;
		var guiControl, midiControl, threshold;
		midiControl = val.linlin(0, 127, 0, 1);
		guiControl = ~channel[(\level ++ i).asSymbol].value;
		threshold = 0.1;
		if ( // soft takeover
			(~channel[(\activeLevel ++ i).asSymbol] or: ((midiControl > (guiControl - threshold)) and: (midiControl < (guiControl + threshold)))),
			{
				~channel[(\activeLevel ++ i).asSymbol] = true;
				{
					currentEnvironment.at((\channel ++ i).asSymbol).set(\level, midiControl);
					~channel[(\level ++ i).asSymbol].value_(midiControl);
				}.defer;
			}
		);
	}, ~ccStart, mixerMidiChan);
	(~ccStart).debug("channel " ++ i ++ " level cc number");
	~ccStart = ~ccStart + 1;
};

////////////////////  Master

channelMaster = CompositeView(w, 118@720);
channelMaster.background_(Color.grey);
channelMaster.decorator_(FlowLayout(channelMaster.bounds, 3@3, 3@3));

// Channel name
StaticText(channelMaster, 118@10)
	.string_("Master")
	.stringColor_(Color.white)
	.align_(\center);
channelMaster.decorator.nextLine;

// lpf
~channel[\lpfreqMaster] = EZKnob(channelMaster, 124@70, 'lpfreq', ControlSpec(20, 20000, step: 1, default: 20000, units: 'hz'), {
	arg lpfreq;
	~master.set(\lpfreq, lpfreq.value);
}, margin: 39@0).setColors(stringColor: Color.white);
channelMaster.decorator.nextLine;

// hpf
~channel[\hpfreqMaster] = EZKnob(channelMaster, 120@70, 'hpfreq', ControlSpec(20, 20000, step: 1, default: 20, units: 'hz'), {
	arg hpfreq;
	~master.set(\hpfreq, hpfreq.value);
}, margin: 39@0).setColors(stringColor: Color.white);
channelMaster.decorator.nextLine;

// level
~channel[\levelMaster] = EZSlider(channelMaster, 110@160, 'level', ControlSpec(0, 1, step: 0.01, default: 0.5), {
	arg level;
	~master.set(\level, level.value);
}, layout: 'vert', margin: 39@0).setColors(stringColor: Color.white);

////////////////////  Routing from tidal cycles

~orbitNumber = ~dirt.orbits.size;
~routingControl = Dictionary.new;

routingSection = CompositeView(w, 236@720);
routingSection
.background_(Color.white)
.decorator_(FlowLayout(routingSection.bounds, 25@3, 25@3));

StaticText(routingSection, 236@10)
.string_("Tidal out")
.stringColor_(Color.black)
.align_(\left);
routingSection.decorator.nextLine;

~orbitNumber.do({ arg i;
	var name, busList;

	busList = Array.fill(~channelBus.size, { arg j;
		var channelName;
		channelName = ("channel" ++ j).asSymbol;
		channelName -> { { ~dirt.orbits[i].outBus_(~channelBus[j]); }.defer; };
	});

	name = ("orbit" ++ i).asSymbol;
	~routingControl.put(name, EZListView(routingSection, 70@70, name, busList, initVal: 0, initAction: true));
});

///////////////////////////////////////  Fx Window

y = Window("Fx", Rect(244, 0, 815, 415));
y.layout = VLayout();
y.front;

u = ScrollView(y, y.view.bounds);
u.canvas = View();
u.canvas.layout = VLayout();

~nodeId = Dictionary.new;

// Aux 2

~nodeId.put(~verbSynthDef.name.asString,
	~autoGui.value(u, ~verbSynthDef, ~verb, 111, 0, ~aux2Color, Dictionary.newFrom(
		List[
			"amp", ["none"],
			"drywet", ["slider", ControlSpec(-1, 1, step: 0.01, default: 1), true],
			"amount", ["slider", ControlSpec(0, 1, step: 0.01, default: 1), false]
		]
	)).asString;
);

~nodeId.put(~flangingSynthDef.name.asString,
	~autoGui.value(u, ~flangingSynthDef, ~flanging, 115, 0, ~aux2Color, Dictionary.newFrom(
		List[
			"fgfreq", ["slider", ControlSpec(0.01, 1000, step: 0.1, default: 0.1), true],
			"drywet", ["slider", ControlSpec(-1, 1, step: 0.01, default: 0.5), true]
		]
	)).asString;
);

~nodeId.put(~pitchShifterSynthDef.name.asString,
	~autoGui.value(u, ~pitchShifterSynthDef, ~pitchShifter, 118, 0, ~aux2Color, Dictionary.newFrom(
		List[
			"pitchRatio", ["slider", ControlSpec(0, 4, step: 0.01, default: 1), true],
			"drywet", ["slider", ControlSpec(-1, 1, step: 0.01, default: 0.5), true]
		]
	)).asString;
);

~nodeId.put(~quadDelaySynthDef.name.asString,
	~autoGui.value(u, ~quadDelaySynthDef, ~quadDelay, 21, 1, ~aux2Color, Dictionary.newFrom(
		List[
			"tempoClock", ["none"],
			"amp", ["none"],
			"sync1", ["button", ControlSpec(0, 1, step: 1, default: 0), true],
			"sync2", ["button", ControlSpec(0, 1, step: 1, default: 0), true],
			"sync3", ["button", ControlSpec(0, 1, step: 1, default: 0), true],
			"sync4", ["button", ControlSpec(0, 1, step: 1, default: 0), true],
			"pan1", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), false],
			"pan2", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), false],
			"pan3", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), false],
			"pan4", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), false],
			"drywet", ["slider", ControlSpec(-1, 1, step: 0.01, default: 0.4), true]
		]
	)).asString;
);

~nodeId.put(~filterBusSynthDef.name.asString,
	~autoGui.value(u, ~filterBusSynthDef, ~filterBus, 666, 666, ~aux2Color, Dictionary.newFrom(
		List[
			"drywet", ["slider", ControlSpec(-1, 1, step: 0.01, default: -1), false],
			"hpfInFreq", ["knob", ControlSpec(20, 20000, step: 1, default: 20), false],
			"eqFreq", ["knob", ControlSpec(20, 20000, step: 1, default: 3200), false],
			"eqRq", ["knob", ControlSpec(0, 1, step: 0.01, default: 1), false],
			"eqDb", ["knob", ControlSpec(-60, 60, step: 0.01, default: 0), false],
			"lpfInFreq", ["knob", ControlSpec(20, 20000, step: 1, default: 20000), false],
		]
	)).asString;
);

// Aux 1

~nodeId.put(~distoInsideOutSynthDef.name.asString,
	~autoGui.value(u, ~distoInsideOutSynthDef, ~distoInsideOut, 41, 1, ~aux1Color, Dictionary.newFrom(
		List[
			"drywet", ["slider", ControlSpec(-1, 1, step: 0.01, default: -1), true],
			"hpfInFreq", ["knob", ControlSpec(20, 20000, step: 1, default: 20), false],
			"lpfInFreq", ["knob", ControlSpec(20, 20000, step: 1, default: 20000), false],
			"level", ["knob", ControlSpec(0, 1, step: 0.01, default: 0), false]
		]
	)).asString;
);

~nodeId.put(~waveShapeSynthDef.name.asString,
	~autoGui.value(u, ~waveShapeSynthDef, ~waveShape, 39, 1, ~aux1Color, Dictionary.newFrom(
		List[
			"shaperbuf", ["none"],
			"mix", ["slider", ControlSpec(0, 1, step: 0.01, default: 0), true],
			"hpfInFreq", ["knob", ControlSpec(20, 20000, step: 1, default: 20), false],
			"lpfInFreq", ["knob", ControlSpec(20, 20000, step: 1, default: 20000), false],
			"gain", ["knob", ControlSpec(0, 100, step: 0.1, default: 29.9), true]
		]
	)).asString;
);

~nodeId.put(~distoCrossOverSynthDef.name.asString,
	~autoGui.value(u, ~distoCrossOverSynthDef, ~distoCrossOver, 43, 1, ~aux1Color, Dictionary.newFrom(
		List[
			"drywet", ["slider", ControlSpec(-1, 1, step: 0.01, default: -1), true],
			"hpfInFreq", ["knob", ControlSpec(20, 20000, step: 1, default: 20), false],
			"lpfInFreq", ["knob", ControlSpec(20, 20000, step: 1, default: 20000), false],
			"level", ["knob", ControlSpec(0, 1, step: 0.01, default: 0), false]
		]
	)).asString;
);

~nodeId.put(~noiseInjectionSynthDef.name.asString,
	~autoGui.value(u, ~noiseInjectionSynthDef, ~noiseInjection, 47, 1, ~aux1Color, Dictionary.newFrom(
		List[
			"drywet", ["slider", ControlSpec(-1, 1, step: 0.01, default: -0.6), true],
			"hpfInFreq", ["knob", ControlSpec(20, 20000, step: 1, default: 20), false],
			"eqFreq", ["knob", ControlSpec(20, 20000, step: 1, default: 20000), false],
			"eqRq", ["knob", ControlSpec(0, 1, step: 0.01, default: 0), false],
			"eqDb", ["knob", ControlSpec(-60, 60, step: 0.1, default: 0), false],
			"lpfInFreq", ["knob", ControlSpec(20, 20000, step: 1, default: 20000), false],
			"attack", ["slider", ControlSpec(0.01, 10, step: 0.01, default: 0.01), true],
			"release", ["slider", ControlSpec(0.01, 10, step: 0.01, default: 0.01), true],
			"noiseType", ["knob", ControlSpec(0, 5, step: 1, default: 0), true],
			"nType5Chaos", ["knob", ControlSpec(0, 1.99, step: 0.01, default: 1.5), false],
			"noiseLevel", ["knob", ControlSpec(0, 4, step: 0.01, default: 1), false],
			"impSource", ["knob", ControlSpec(0, 1, step: 1, default: 0), false],
			"impFreq", ["knob", ControlSpec(0, 19000, step: 1, default: 52.09), false],
			"impLevel", ["knob", ControlSpec(0, 60, step: 0.01, default: 0), false]
		]
	)).asString;
);

///////////////////////////////////////  SynthDef Window

x = Window("Synth", Rect(600, 30, 800, 725));
x.layout = VLayout();
x.front;

v = ScrollView(x, x.view.bounds);
v.canvas = View();
v.canvas.layout = VLayout();

~nodeId.put("inputSoftPop",
	~autoGui.value(v, ~inputSigSynthDef, ~inputSoftPop, 100/*cc start*/, 14/*midi channel*/, Color.new255(189, 183, 107, 240), Dictionary.newFrom(
		List[
			"gate", ["button", ControlSpec(0, 1, step: 1, default: 0), true],
			"amp", ["knob", ControlSpec(0, 1, step: 0.01, default: 0.5), true],
			"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: 0.5), true],
			"release", ["slider", ControlSpec(0, 10, step: 0.01, default: 1), true],
			"curve", ["knob", ControlSpec(-20, 20, step: 0.01, default: -4), false],
			"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), true],
			"lpfreq", ["knob", ControlSpec(20, 20000, step: 1, default: 20000), true],
			"band1freq", ["knob", ControlSpec(20, 20000, step: 1, default: 8000), true],
			"band1db", ["knob", ControlSpec(-60, 60, step: 1, default: 0), true],
			"band2freq", ["knob", ControlSpec(20, 20000, step: 1, default: 1200), true],
			"band2db", ["knob", ControlSpec(-60, 60, step: 1, default: 0), true],
			"band3freq", ["knob", ControlSpec(20, 20000, step: 1, default: 80), true],
			"band3db", ["knob", ControlSpec(-60, 60, step: 1, default: 0), true],
			"hpfreq", ["knob", ControlSpec(20, 20000, step: 1, default: 20), true]
		]
	)).asString;
);

~nodeId.put("inputMic",
	~autoGui.value(v, ~inputSigSynthDef, ~inputMic, 100, 15, Color.new255(205, 198, 115, 255), Dictionary.newFrom(
		List[
			"gate", ["button", ControlSpec(0, 1, step: 1, default: 0), true],
			"amp", ["knob", ControlSpec(0, 4, step: 0.01, default: 4), true],
			"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: 0.5), true],
			"release", ["slider", ControlSpec(0, 10, step: 0.01, default: 1), true],
			"curve", ["knob", ControlSpec(-20, 20, step: 0.01, default: -4), false],
			"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), true],
			"lpfreq", ["knob", ControlSpec(20, 20000, step: 1, default: 20000), true],
			"band1freq", ["knob", ControlSpec(20, 20000, step: 1, default: 8000), true],
			"band1db", ["knob", ControlSpec(-60, 60, step: 1, default: 0), true],
			"band2freq", ["knob", ControlSpec(20, 20000, step: 1, default: 1200), true],
			"band2db", ["knob", ControlSpec(-60, 60, step: 1, default: 0), true],
			"band3freq", ["knob", ControlSpec(20, 20000, step: 1, default: 80), true],
			"band3db", ["knob", ControlSpec(-60, 60, step: 1, default: 0), true],
			"hpfreq", ["knob", ControlSpec(20, 20000, step: 1, default: 20), true]
		]
	)).asString;
);

~nodeId.put(~samplerStereoSynthDef.name.asString,
	~autoGui.value(v, ~samplerStereoSynthDef, ~samplerStereo, 85, 0, Color.new255(205, 205, 0), Dictionary.newFrom(
		List[
			"gate", ["button", ControlSpec(0, 1, step: 1, default: 0), true],
			"amp", ["knob", ControlSpec(0, 4, step: 0.01, default: 0.23), true],
			"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), true],
			"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: 0.001), true],
			"release", ["slider", ControlSpec(0, 10, step: 0.01, default: 1), true],
			"curve", ["knob", ControlSpec(-20, 20, step: 0.01, default: -4), true],
			"buffer", ["List", Array.fill(b[\sampler_stereo].size, { arg i;
				var filePath;
				filePath = PathName.new(b[\sampler_stereo][i].path);
				filePath.fileName.asString;
			}), true],

			"rate", ["knob", ControlSpec(0.01, 24, step: 0.01, default: 0.21), true],
			"startPos", ["slider", ControlSpec(0, 1, step: 0.01, default: 0), true],
			"loop", ["button", ControlSpec(0, 1, step: 1, default: 0), false]
		]
	)).asString;
);

~nodeId.put(~sinBassSynthDef.name.asString,
	~autoGui.value(v, ~sinBassSynthDef, ~sinBass, 94, 0, Color.new255(238, 230, 133), Dictionary.newFrom(
		List[
			"pan", ["knob", ControlSpec(-1, 1, step: 0.01, default: 0), false],
			"amp", ["knob", ControlSpec(0, 10, step: 0.01, default: 1.34), true],
			"gate", ["button", ControlSpec(0, 1, step: 1, default: 0), true],
			"loopNode", ["knob", ControlSpec(0, 4, step: 1, default: 0), true],
			"attack", ["slider", ControlSpec(0, 10, step: 0.01, default: 0.2), true],
			"release", ["slider", ControlSpec(0, 10, step: 0.01, default: 4), true],
			"curve", ["knob", ControlSpec(-20, 20, step: 0.01, default: -4), true],
			"envLevel1", ["knob", ControlSpec(0, 200, step: 0.1, default: 0), true],
			"envLevel2", ["knob", ControlSpec(0, 200, step: 0.1, default: 40), true],
			"envLevel3", ["knob", ControlSpec(0, 200, step: 0.1, default: 32), true],
			"envLevel4", ["knob", ControlSpec(0, 200, step: 0.1, default: 50), true],
			"envLevel5", ["knob", ControlSpec(0, 200, step: 0.1, default: 0), true],
			"envLevel6", ["knob", ControlSpec(0, 200, step: 0.1, default: 60), true],
			"envTime1", ["knob", ControlSpec(0, 10, step: 0.01, default: 0.5), true],
			"envTime2", ["knob", ControlSpec(0, 10, step: 0.01, default: 0.3), true],
			"envTime3", ["knob", ControlSpec(0, 10, step: 0.01, default: 0.25), true],
			"envTime4", ["knob", ControlSpec(0, 10, step: 0.01, default: 1), true],
			"envTime5", ["knob", ControlSpec(0, 10, step: 0.01, default: 0.5), true]
		]
	)).asString;
);

////////////////////  Pdef Mute

pdMuteCcStart = 1;
pdMuteMidiChan = 0; // 0 for midi channel 1
pdMuteMidiChan = pdMuteMidiChan.max(0).min(15);
(pdMuteMidiChan).debug("units mute midi channel");

~mute = Dictionary.new;
~muteState = Dictionary.new;

pdefGuiView = CompositeView(bounds: (~pdefNumber * 62)@110)
.scroll(autoScrolls: true)
.minHeight_(115)
.minWidth_(780)
.background_(Color.grey);

pdefGuiView.layout = HLayout();

~pdefNumber.do({ arg i;
	var pdefNameSymbol, pdefNameString;

	pdefNameSymbol = ("unit" ++ (i + 1)).asSymbol;
	pdefNameString = pdefNameSymbol.asString;
	~muteState.put(pdefNameSymbol, 0);

	~mute.put(pdefNameString,
		Button()
		.minHeight_(60)
		.states_([
			["mute " ++ pdefNameString, Color.black, Color.white],
			["unmute " ++ pdefNameString, Color.white, Color.new255(48, 48, 48)]
		])
		.action = { arg guiControl;
			{
				if(guiControl.value > 0,
					{
						~muteState.put(pdefNameSymbol, 1);
					},
					{
						~muteState.put(pdefNameSymbol, 0);
					}
				);
			}.defer;
		}
	);

	// button midi map
	MIDIFunc.cc({ arg val, num, chan, src;
		var midiControl;
		midiControl = val.linlin(0, 127, 0, 1);
		{
			~mute.at(pdefNameString).valueAction_(midiControl);
		}.defer;
	}, pdMuteCcStart, pdMuteMidiChan);
	(pdMuteCcStart).debug(pdefNameString ++ " mute cc number");
	pdMuteCcStart = pdMuteCcStart + 1;

	pdefGuiView.layout.add(~mute.at(pdefNameString));
});

v.canvas.layout.insert(pdefGuiView);

)