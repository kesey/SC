(

///////////////////////////////////////  Routing

var mixGroup, synthGroup, fxGroup, aux1Group, aux2Group, masterBus;

mixGroup = Group.new(s, \addToTail);
synthGroup = Group.new(mixGroup, \addBefore);
fxGroup = Group.new(mixGroup);
aux1Group = Group.new(fxGroup);
aux2Group = Group.new(aux1Group, \addAfter);

masterBus = Bus.audio(s, 2);
~master = Synth(\MasterStrip, [\in, masterBus], mixGroup, addAction: 'addToTail');

~channelNumber = 4; // number of channels
~channelNumber = ~channelNumber.max(1).min(16); // limit number of channels

~channelBus = Array.newClear(~channelNumber);

~channelNumber.do {
	arg i;
	~channelBus[i] = Bus.audio(s, 2);
	currentEnvironment.put((\channel ++ i).asSymbol, Synth(\ChannelStrip, [\in, ~channelBus[i], \out, masterBus], mixGroup));
};

// Permanent Synth
s.bind { ~inputMic = Synth(\inputSig, [\in, 0, \out, ~channelBus[1], \amp, 4, \gate, 0, \doneAction, 0], synthGroup) }; // s.bind consider server latency
s.bind { ~inputSoftPop = Synth(\inputSig, [\in, 2, \out, ~channelBus[1], \amp, 0.5, \gate, 0, \doneAction, 0], synthGroup) };
s.bind { ~samplerStereo = Synth(\samplerStereo, [\out, ~channelBus[1], \gate, 0, \buffer, b[\sampler_stereo][15].bufnum, \amp, 0.23, \doneAction, 0], synthGroup) };
s.bind { ~sinBass = Synth(\sinBass, [\out, ~channelBus[0], \amp, 1.34, \gate, 0, \doneAction, 0], synthGroup) };

// Fx
~aux1Bus = Bus.audio(s, 2);
~aux2Bus = Bus.audio(s, 2);

// Aux 1
s.bind { ~noiseInjection = Synth(\noiseInjection, [\in, ~aux1, \out, ~aux1Bus], aux1Group, addAction: 'addToHead'); };
s.bind { ~distoCrossOver = Synth(\distoCrossOver, [\in, ~aux1Bus, \out, ~aux1Bus], ~noiseInjection, addAction: 'addAfter'); };
s.bind { ~distoInsideOut = Synth(\distoInsideOut, [\in, ~aux1Bus, \out, ~aux1Bus], ~distoCrossOver, addAction: 'addAfter'); };
s.bind {
	h = Buffer.alloc(s, 1024, 1);
	h.cheby([1, 0.5, 1, 0.125]); // fill buffer with wavetable to use the waveShape SynthDef
	~waveShape = Synth(\waveShape, [\in, ~aux1Bus, \out, ~channelBus[2], \shaperbuf, h, \gain, 29.96, \mix, 0], ~distoInsideOut, addAction: 'addAfter');
};

// Aux 2
~quadDelay = Synth(\quadDelay, [\in, ~aux2, \out, ~aux2Bus], aux2Group, addAction: 'addToHead');
~updateTempo.value(~quadDelay, t); // use it to keep sync when tempo change
s.bind { ~pitchShifter = Synth(\pitchShifter, [\in, ~aux2Bus, \out, ~aux2Bus], ~quadDelay, addAction: 'addAfter'); };
s.bind { ~flanging = Synth(\flanging, [\in, ~aux2Bus, \out, ~aux2Bus], ~pitchShifter, addAction: 'addAfter'); };
s.bind { ~verb = Synth(\verb, [\in, ~aux2Bus, \out, ~channelBus[3], \amp, 0.75], aux2Group, addAction: 'addToTail') };

// s.meter; // level meter

)