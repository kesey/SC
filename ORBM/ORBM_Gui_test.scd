(

///////////////////////////////////////  Mixer Gui

var channel, channelMaster, ccStart,
arguments, synthCcStart, synthWindow, button, knob, active;

~ccStart = 21; // start mapping midi cc from here
~ccStart = ~ccStart.max(0).min(127); // limit ccStart

~ccStart = ~ccStart - 1;
channel = IdentityDictionary.new;

w = Window("Mixer",Rect(0, 0, 850, 725), scroll: true);
w.front;
//w.alwaysOnTop_(true);
w.view.decorator = FlowLayout(w.view.bounds, 3@3, 3@3);

///////////////////////////////////////  Channel

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
	channel[(\hpfreq ++ i).asSymbol] = EZKnob(channel[\channelView], 120@70, 'hpfreq', ControlSpec(20, 20000, step: 1, default: 20, units: 'hz'), { arg hpfreq; currentEnvironment.at((\channel ++ i).asSymbol).set(\hpfreq, hpfreq.value); channel[(\activeHpf ++ i).asSymbol] = false; }, margin: 39@0);
	channel[\channelView].decorator.nextLine;

	~midiCcMap = { arg ccNum = 0, guiControl = 0, active = false, threshold = 0.1, instance = nil, parameter = "amp", min = 0, max = 1;
		var instanceName;

		if (instance.isString.not, {
			instanceName = instance.defName.asString;
		}, {
			instanceName = instance;
		});

		MIDIFunc.cc({ arg val, num, chan, src;
			var guiValue, midiControl;

			midiControl = val.linlin(0, 127, min, max);
			guiValue = guiControl.value;

			if ( // soft takeover
				(active or: ((midiControl > (guiValue - threshold)) and: (midiControl < (guiValue + threshold)))),
				{
					active = true;
					if (instance.isString.not, {
						{
						    instance.set(parameter.asSymbol, midiControl);
						    guiControl.value_(midiControl);
						}.defer;
					}; {
						{ guiControl.valueAction_(midiControl); }.defer;
					});
				}
			);
		}, ccNum, 0);
		(ccNum).debug(instanceName ++ " " ++ parameter ++ " cc number");
	};

	("Channel " ++ i).postln;
	~ccStart = ~ccStart + 1;
	~midiCcMap.value(~ccStart, channel[(\hpfreq ++ i).asSymbol], channel[(\activeHpf ++ i).asSymbol], 500, currentEnvironment.at((\channel ++ i).asSymbol), "hpfreq", 20, 20000);

	3.do({
		arg j;
		var default;
		switch(j,
			0, { default = 80 },
			1, { default = 1200 },
			2, { default = 8000 },
			{ default = 1200; }
		);
		j = j + 1;
		// freq
		channel[(\activeBand ++ j ++ \Freq ++ i).asSymbol] = false;
		channel[(\band ++ j ++ \freq ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'freq' ++ j, ControlSpec(20, 20000, step: 1, default: default, units: 'hz'), { arg freq; currentEnvironment.at((\channel ++ i).asSymbol).set((\band ++ j ++ \freq).asSymbol, freq.value); channel[(\activeBand ++ j ++ \Freq ++ i).asSymbol] = false; });

		// freq midi map
		~ccStart = ~ccStart + 1;
		~midiCcMap.value(~ccStart, channel[(\band ++ j ++ \freq ++ i).asSymbol], channel[(\activeBand ++ j ++ \Freq ++ i).asSymbol], 500, currentEnvironment.at((\channel ++ i).asSymbol), "band" ++ j ++ "freq", 20, 20000);

		// rq
		channel[(\activeBand ++ j ++ \Rq ++ i).asSymbol] = false;
		channel[(\band ++ j ++ \rq ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'rq' ++ j, ControlSpec(0, 1, step: 0.01, default: 1), { arg rq; currentEnvironment.at((\channel ++ i).asSymbol).set((\band ++ j ++ \rq).asSymbol, rq.value); channel[(\activeBand ++ j ++ \Rq ++ i).asSymbol] = false; });

		// rq midi map
		~ccStart = ~ccStart + 1;
		~midiCcMap.value(~ccStart, channel[(\band ++ j ++ \rq ++ i).asSymbol], channel[(\activeBand ++ j ++ \Rq ++ i).asSymbol], 0.1, currentEnvironment.at((\channel ++ i).asSymbol), "band" ++ j ++ "rq", 20, 20000);

		// db
		channel[(\activeBand ++ j ++ \Db ++ i).asSymbol] = false;
		channel[(\band ++ j ++ \db ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'db' ++ j, ControlSpec(0, 60, step: 1, default: 0, units: 'db'), { arg db; currentEnvironment.at((\channel ++ i).asSymbol).set((\band ++ j ++ \db).asSymbol, db.value); channel[(\activeBand ++ j ++ \Db ++ i).asSymbol] = false; });

		// db midi map
		~ccStart = ~ccStart + 1;
		~midiCcMap.value(~ccStart, channel[(\band ++ j ++ \db ++ i).asSymbol], channel[(\activeBand ++ j ++ \Db ++ i).asSymbol], 10, currentEnvironment.at((\channel ++ i).asSymbol), "band" ++ j ++ "db", 0, 60);
	});

	// lpf
	channel[(\activeLpf ++ i).asSymbol] = false;
	channel[(\lpfreq ++ i).asSymbol] = EZKnob(channel[\channelView], 124@70, 'lpfreq', ControlSpec(20, 20000, step: 1, default: 20000, units: 'hz'), { arg lpfreq; currentEnvironment.at((\channel ++ i).asSymbol).set(\lpfreq, lpfreq.value); channel[(\activeLpf ++ i).asSymbol] = false; }, margin: 39@0);
	channel[\channelView].decorator.nextLine;

	// lpf midi map
	~ccStart = ~ccStart + 1;
	~midiCcMap.value(~ccStart, channel[(\lpfreq ++ i).asSymbol], channel[(\activeLpf ++ i).asSymbol], 500, currentEnvironment.at((\channel ++ i).asSymbol), "lpfreq", 20, 20000);

	2.do({
		arg j;
		j = j + 1;
		// aux
		channel[(\activeAux ++ j ++ i).asSymbol] = false;
		channel[(\aux ++ j ++ i).asSymbol] = EZKnob(channel[\channelView], 35@70, 'aux' ++ j, ControlSpec(0, 1, step: 0.01, default: 0), { arg aux; currentEnvironment.at((\channel ++ i).asSymbol).set((\auxsend ++ j).asSymbol, aux.value); channel[(\activeAux ++ j ++ i).asSymbol] = false; });

		// aux midi map
		~ccStart = ~ccStart + 1;
		~midiCcMap.value(~ccStart, channel[(\aux ++ j ++ i).asSymbol], channel[(\activeAux ++ j ++ i).asSymbol], 0.1, currentEnvironment.at((\channel ++ i).asSymbol), "auxsend" ++ j , 0, 1);

		if (j == 1, {
			StaticText(channel[\channelView], 35@65)
			    .string_("Send")
	            .align_(\center);
		});
	});

	// mute
	channel[(\mute ++ i).asSymbol] = Button(channel[\channelView], Rect(10,110,112,35)).states_([["Mute", Color.black, Color.white],["Active", Color.white, Color.grey]]).action = { arg mute; currentEnvironment.at((\channel ++ i).asSymbol).set(\mute, mute.value.linlin(0, 1, 1, 0)); };

	// mute midi map
	~ccStart = ~ccStart + 1;
	~midiCcMap.value(~ccStart, channel[(\mute ++ i).asSymbol], true, 0.1, "channelStrip", "mute", 0, 1);

	// pan
	channel[(\activePan ++ i).asSymbol] = false;
	channel[(\pan ++ i).asSymbol] = EZSlider(channel[\channelView], 112@60, 'pan', ControlSpec(-1, 1, step: 0.01, default: 0), { arg pan; currentEnvironment.at((\channel ++ i).asSymbol).set(\pan, pan.value); channel[(\activePan ++ i).asSymbol] = false; }, layout: 'vert');
	channel[\channelView].decorator.nextLine;

	// pan midi map
	~ccStart = ~ccStart + 1;
	~midiCcMap.value(~ccStart, channel[(\pan ++ i).asSymbol], channel[(\activePan ++ i).asSymbol], 0.1, currentEnvironment.at((\channel ++ i).asSymbol), "pan", -1, 1);

	// level
	channel[(\activeLevel ++ i).asSymbol] = false;
	channel[(\level ++ i).asSymbol] = EZSlider(channel[\channelView], 110@160, 'level', ControlSpec(0, 1, step: 0.01, default: 0.5), { arg level; currentEnvironment.at((\channel ++ i).asSymbol).set(\level, level.value); channel[(\activeLevel ++ i).asSymbol] = false; }, layout: 'vert', margin: 39@0);

	// level midi map
	~ccStart = ~ccStart + 1;
	~midiCcMap.value(~ccStart, channel[(\level ++ i).asSymbol], channel[(\activeLevel ++ i).asSymbol], 0.1, currentEnvironment.at((\channel ++ i).asSymbol), "level", 0, 1);

};

///////////////////////////////////////  Master Channel

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
channel[\hpfreqMaster] = EZKnob(channelMaster, 120@70, 'hpfreq', ControlSpec(20, 20000, step: 1, default: 20, units: 'hz'), { arg hpfreq; ~master.set(\hpfreq, hpfreq.value); }, margin: 39@0).setColors(stringColor: Color.white);
	channelMaster.decorator.nextLine;

// lpf
channel[\lpfreqMaster] = EZKnob(channelMaster, 124@70, 'lpfreq', ControlSpec(20, 20000, step: 1, default: 20000, units: 'hz'), { arg lpfreq; ~master.set(\lpfreq, lpfreq.value); }, margin: 39@0).setColors(stringColor: Color.white);
	channelMaster.decorator.nextLine;

// level
channel[\levelMaster] = EZSlider(channelMaster, 110@160, 'level', ControlSpec(0, 1, step: 0.01, default: 0.5), { arg level; ~master.set(\level, level.value); }, layout: 'vert', margin: 39@0).setColors(stringColor: Color.white);

///////////////////////////////////////  SynthDef Gui

x = Window("SynthDef",Rect(0, 0, 850, 725), scroll: true);
x.front;
x.view.decorator = FlowLayout(x.view.bounds, 3@3, 3@3);

~autoGui = { arg parentWindow, synthDef, instance, ccStart = 10, backGroundColor = Color.white, threshold = 0.1, specDict = Dictionary.new;
var arguments, synthWindow, button, knob, active, controlSpec, midiMap;

	arguments = synthDef.allControlNames;
	specDict.put("default", [ControlSpec(0, 1, step: 0.01, default: 0), true]);

	synthWindow = CompositeView(parentWindow, (arguments.size * 62)@(110));
	synthWindow.background_(backGroundColor);
	synthWindow.decorator_(FlowLayout(synthWindow.bounds, 3@3, 6@3));

	// SynthDef name
	StaticText(synthWindow, 100@26)
        .string_(synthDef.name)
        .stringColor_(Color.black)
        .align_(\center);
	synthWindow.decorator.nextLine;

	button = Dictionary.new;
	knob = Dictionary.new;
	active = Dictionary.new;

	ccStart = ccStart - 1;

	arguments.do({
		arg control, i;
		var caseFind;
		caseFind = false;

		if (specDict.includesKey(control.name.asString),
			{
				controlSpec = specDict.at(control.name.asString)[0].value;
				midiMap = specDict.at(control.name.asString)[1].value;
			},
			{
				controlSpec = specDict.at("default")[0].value;
				midiMap = specDict.at("default")[1].value;
			}
		);

		case
		{ "trigger trig gate t_trig t_gate loop mute start stop on off".contains(control.name.asString) } // in these cases create button
		{
			// button creation
			button.put(("button" ++ i).asString , Button(synthWindow, Rect(10,110,40,25)).states_([[control.name.asString, Color.black, Color.white],["stop", Color.white, Color.grey]]).action = { arg guiControl; instance.set(control.name.asSymbol, guiControl.value); });

			if (midiMap, { // button midi map
				ccStart = ccStart + 1;
				~midiCcMap.value(ccStart, button.at(("button" ++ i).asString), true, 0.1, instance.defName.asString, control.name.asString, 0, 1);
			});

			caseFind = true;
		}
		{ "out in".contains(control.name.asString) }
		{
			caseFind = true;
		}
		{ caseFind.not } // default case create knob
		{
			// knob creation
			active.put(("knob" ++ i ++ "Active").asString, false);
			knob.put(("knob" ++ i).asString, EZKnob(synthWindow, 60@70, control.name.asString, controlSpec, { arg guiControl; instance.set(control.name.asSymbol, guiControl.value); active.put(("knob" ++ i ++ "Active").asString, false); }));

			if (midiMap, { // knob midi map
				ccStart = ccStart + 1;
				~midiCcMap.value(ccStart, knob.at(("knob" ++ i).asString), active.at(("knob" ++ i ++ "Active").asString), threshold, instance.defName.asString, control.name.asString, knob.at(("knob" ++ i).asString).controlSpec.minval, knob.at(("knob" ++ i).asString).controlSpec.maxval);
			});
		};
	});
};

~autoGui.value(x, ~samplerStereoSynthDef, ~samplerStereo, 9, Color.green, 0.1, Dictionary.newFrom(["pan", [ControlSpec(-1, 1, step: 0.01, default: 0), false], "attack", [ControlSpec(0, 10, step: 0.01, default: 0), false], "buffer", [ControlSpec(0, 20, step: 1, default: 0), false]]));

)