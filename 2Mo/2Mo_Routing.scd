(

///////////////////////////////////////  Routing

var mixGroup, synthGroup, fxGroup, aux1Group, aux2Group, permanentSynthDa;
permanentSynthDa = 0; // doneAction

mixGroup = Group.new(s, \addToTail);
synthGroup = Group.new(mixGroup, \addBefore);
fxGroup = Group.new(mixGroup);
aux1Group = Group.new(fxGroup);
aux2Group = Group.new(aux1Group, \addAfter);

~aux1 = Bus.audio(s, 2);
~aux2 = Bus.audio(s, 2);

~masterBus = Bus.audio(s, 2);
~master = Synth(\MasterStrip, [\in, ~masterBus], mixGroup, addAction: 'addToTail');

~channelNumber = 4; // number of mixer channels
~channelNumber = ~channelNumber.max(1).min(16); // limit number of mixer channels

~channelBus = Array.newClear(~channelNumber);

~channelNumber.do {
	arg i;
	~channelBus[i] = Bus.audio(s, 2);
	currentEnvironment.put((\channel ++ i).asSymbol, Synth(\ChannelStrip, [\in, ~channelBus[i], \outAux1, ~aux1, \outAux2, ~aux2, \out, ~masterBus], mixGroup));
};

// Permanent Synth
s.bind { ~inputMic = Synth(\inputSig, [\in, 0, \out, ~channelBus[1], \amp, 1, \gate, 0, \doneAction, permanentSynthDa], synthGroup) }; // s.bind consider server latency
s.bind { ~inputSoftPop = Synth(\inputSig, [\in, 2, \out, ~channelBus[1], \amp, 1, \gate, 0, \doneAction, permanentSynthDa], synthGroup) };
s.bind {
	var envBuf, envSignal;
	// The grain envelope
	envBuf = Buffer.alloc(s, s.sampleRate, 1);
	s.sync;
	envSignal = Signal.newClear(s.sampleRate).waveFill({|x| (1 - x.pow(2)).pow(1.25)}, -1.0, 1.0);
	envBuf.loadCollection(envSignal);
	s.sync;

	~paulstretch = Synth(\paulstretchMono, [\out, ~channelBus[1], \gate, 0, \buffer, Buffer.readChannel(s, b[\sampler_stereo][15].path, channels: [0]).bufnum, \envBufnum, envBuf.bufnum, \amp, 0.23, \doneAction, permanentSynthDa], synthGroup);
};
s.bind { ~samplerStereo = Synth(\samplerStereo, [\out, ~channelBus[1], \gate, 0, \buffer, b[\sampler_stereo][15].bufnum, \amp, 0.23, \doneAction, permanentSynthDa], synthGroup) };
s.bind { ~sinBass = Synth(\sinBass, [\out, ~channelBus[0], \amp, 1.34, \gate, 0, \doneAction, permanentSynthDa], synthGroup) };

// Permanent Fx

// Aux 1
s.bind { ~noiseInjection = Synth(\noiseInjection, [\in, ~aux1, \out, ~aux1], aux1Group, addAction: 'addToHead'); };
s.bind { ~distoCrossOver = Synth(\distoCrossOver, [\in, ~aux1, \out, ~aux1], ~noiseInjection, addAction: 'addAfter'); };
s.bind {
	h = Buffer.alloc(s, 1024, 1);
	s.sync;
	h.cheby([1, 0.5, 1, 0.125]); // fill buffer with wavetable to use the waveShape SynthDef
	s.sync;
	~waveShape = Synth(\waveShape, [\in, ~aux1, \out, ~aux1, \shaperbuf, h, \gain, 29.96, \mix, 0], ~distoCrossOver, addAction: 'addAfter');
};
s.bind { ~distoInsideOut = Synth(\distoInsideOut, [\in, ~aux1, \out, ~channelBus[2]], ~waveShape, addAction: 'addAfter'); };

// Aux 2
s.bind { ~filterBus = Synth(\filterBus, [\in, ~aux2, \out, ~aux2], aux2Group, addAction: 'addToHead'); };
s.bind { ~quadDelay = Synth(\quadDelay, [\in, ~aux2, \out, ~aux2], ~filterBus, addAction: 'addAfter');
	~updateTempo.value(~quadDelay, t); // use it to keep sync when tempo change
};
s.bind { ~pitchShifter = Synth(\pitchShifter, [\in, ~aux2, \out, ~aux2], ~quadDelay, addAction: 'addAfter'); };
s.bind { ~flanging = Synth(\flanging, [\in, ~aux2, \out, ~aux2], ~pitchShifter, addAction: 'addAfter'); };
s.bind { ~greyhole = Synth(\greyHole, [\in, ~aux2, \out, ~aux2], ~flanging, addAction: 'addAfter'); };
/*s.bind { ~verb = Synth(\verb, [\in, ~aux2, \out, ~channelBus[3], \amp, 0.75], aux2Group, addAction: 'addToTail'); };*/
s.bind { ~jpverb = Synth(\JPverb, [\in, ~aux2, \out, ~channelBus[3], \amp, 0.75], aux2Group, addAction: 'addToTail'); };

// s.meter.window.alwaysOnTop_(true); // level meter

)