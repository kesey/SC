(

///////////////////////////////////////  SynthDef

///////////////////////////////////////  Mixer

SynthDef(\ChannelStrip, { arg in = 0, out = 0, outAux1 = 3, outAux2 = 4, pan = 0, hpfreq = 20, band1freq = 8000, band1rq = 1, band1db = 0, band2freq = 1200, band2rq = 1, band2db = 0, band3freq = 80, band3rq = 1, band3db = 0, lpfreq = 20000, mute = 1, auxsend1 = 0, auxsend2 = 0, level = 0.5, delaytime = 0;
	var input, sig, bad;
	input = InFeedback.ar(in, 2);
	sig = BHiPass4.ar(input, Lag2.kr(hpfreq.max(20).min(20000), 0.5)); // HPF
	sig = BPeakEQ.ar(sig, Lag2.kr(band1freq.max(20).min(20000), 0.5), band1rq, band1db); // Band 1
	sig = BPeakEQ.ar(sig, Lag2.kr(band2freq.max(20).min(20000), 0.5), band2rq, band2db); // Band 2
	sig = BPeakEQ.ar(sig, Lag2.kr(band3freq.max(20).min(20000), 0.5), band3rq, band3db); // Band 3
	sig = BLowPass4.ar(sig, Lag2.kr(lpfreq.max(20).min(20000), 0.5)); // LPF
	sig = Select.ar(CheckBadValues.ar(sig, post: 2) > 0, [sig, DC.ar(0)]); // test for infinity, NaN and denormals before sending to Aux and MasterStrip
	Out.ar(outAux1, sig * auxsend1.curvelin(0, 1, 0, 1, log(10))); // Aux 1 pre fader / pre mute / post eq
	Out.ar(outAux2, sig * auxsend2.curvelin(0, 1, 0, 1, log(10))); // Aux 2 pre fader / pre mute / post eq
	sig = sig * Lag2.kr(mute, 0.1); // Mute
	sig = DelayN.ar(sig, 0.01, delaytime / 100); // Delay
	Out.ar(out, Balance2.ar(sig[0], sig[1], pan, level.curvelin(0, 1, 0, 1, log(10)))); // curvelin to have a logarithmic scale
}).add;

SynthDef(\MasterStrip, { arg in = 0, out = 0, hpfreq = 20, lpfreq = 20000, level = 0.5;
	var input, sig;
	input = In.ar(in, 2);
	sig = BHiPass4.ar(input, Lag2.kr(hpfreq.max(20).min(20000), 0.5)); // HPF
	sig = BLowPass4.ar(sig, Lag2.kr(lpfreq.max(20).min(20000), 0.5)); // LPF
	sig = sig * level.curvelin(0, 1, 0, 1, log(10));
	sig = Limiter.ar(sig);
	Out.ar(out, sig);
	// Out.ar(out+2, sig); // use it to feed external gear with signal
}).add;

///////////////////////////////////////  Fx

///////////////////////////////////////  Time

SynthDef(\phasing, { arg in = 0, out = 0, freq = 0.2, drywet = 0.5;
	var input, effect;
	input = InFeedback.ar(in, 2);
	effect = AllpassN.ar(input, 0.02, SinOsc.kr(freq, 0, 0.01, 0.01));  // max delay of 20msec
	XOut.ar(out, drywet, effect);
}).add;

SynthDef(\phasingIxi, { arg in = 0, out = 0, drywet = 0.5, freq = 0.2;
	var input, effect;
	input = InFeedback.ar(in, 2);
	effect = CombC.ar(
		input,
		4,
		LFPar.kr(0.1, 0, 1).range(0.000022675,0.01), // a circle every 10 seconds
		0
	);
	effect = input + effect;
	XOut.ar(out, drywet, effect);
}).add;

~flangingSynthDef = SynthDef(\flanging, {arg in = 0, out = 0, drywet = 0.5, fgfreq = 0.1, fdback = 0.1;
	var input, sig, effect;
	input = InFeedback.ar(in, 2);
	effect = input + LocalIn.ar(2); // add some feedback
	effect = DelayN.ar(effect, 0.02, SinOsc.kr(fgfreq, 0, 0.005, 0.005)); // max delay of 20msec
	LocalOut.ar(fdback * effect);
	sig = XFade2.ar(input, effect, drywet);
	ReplaceOut.ar(out, sig);
	//XOut.ar(out, drywet, effect);
}).add;

SynthDef(\flangerIxi, { arg in=0, out=0, drywet = 0.5, delay=0.1, depth=0.08, rate=0.06, fdbk=0.0, decay=0.0;
	var input, maxdelay, maxrate, dsig, mixed, local;
	maxdelay = 0.013;
	maxrate = 10.0;
	input = In.ar(in, 2);
	local = LocalIn.ar(2);
	dsig = AllpassL.ar( // the delay (you could use AllpassC (put 0 in decay))
		input + (local * fdbk),
		maxdelay * 2,
		LFTri.kr( // very similar to SinOsc (try to replace it) - Even use LFTri
			rate * maxrate,
			0,
			depth * maxdelay,
			delay * maxdelay),
		decay);
	mixed = input + dsig;
	LocalOut.ar(mixed);
	XOut.ar(out, drywet, mixed);
}).add;

SynthDef(\Chorus, { arg in = 0, out = 0, lpfreq = 6000, rq = 1, drywet = 0.5, level = 1;
	var input, effect, density, maxdelaytime;
	input = BPF.ar(In.ar(in, 2), lpfreq, rq);
	density = 10;
	effect = Mix.fill(density, {
		maxdelaytime = rrand(0.01,0.03);
		DelayC.ar(input, maxdelaytime, LFNoise1.kr(Rand(5,10),0.01,0.02));
	});
	XOut.ar(out, drywet, effect * level);
}).add;

SynthDef(\choruseffect, {arg in = 0, out = 0, gate = 1;
	var source = In.ar(in,2);
	var chorus;
	var env = Linen.kr(gate, 0.1, 1, 0.1, 2);

	chorus= Mix.fill(7, {

		var maxdelaytime= rrand(0.005,0.02);

		DelayC.ar(source, maxdelaytime,LFNoise1.kr(Rand(4.5,10.5),0.25*maxdelaytime,0.75*maxdelaytime) )

	});

	XOut.ar(out,env, chorus);
}).add;

SynthDef(\chorusIxi, { arg in = 10, out = 0, drywet = 0.5, predelay=0.08, speed=0.05, depth=0.1, ph_diff=0.5;
	var input, sig, modulators, numDelays = 12;
	input = In.ar(in, 2);
	modulators = Array.fill(numDelays, {arg i;
	LFPar.kr(speed * rrand(0.94, 1.06), ph_diff * i, depth, predelay);});
	sig = DelayC.ar(input, 0.5, modulators);
	sig = sig.sum; //Mix(sig);
	XOut.ar(out, drywet, sig!2);
}).add;

SynthDef(\grainin, { arg in = 0, out = 0, drywet = 0.5, amp = 0.2, time = 0.1, freq = 20;
	var sig, input;
	input = In.ar(in, 2);
	sig = GrainIn.ar(2, Dust.ar(freq), time, Mix.ar(input)*0.4);
	XOut.ar(out, drywet, sig * amp);
}).add;

SynthDef(\sagrain, { arg in = 0, out = 0, drywet = 0.5, amp = 1, panWidth = 0.5, grainDur = 0.1, grainSpeed = 10;
	var pan, granulizer, input;
	input = In.ar(in, 2);
	pan = LFNoise0.kr(grainSpeed, panWidth);
	granulizer = GrainIn.ar(2, Impulse.kr(grainSpeed), grainDur, Mix.ar(input), pan);
	XOut.ar(out, drywet, granulizer * amp);
}).add;

///////////////////////////////////////  Pitch

~pitchShifterSynthDef = SynthDef(\pitchShifter, { arg in = 0, out = 0, drywet = 0.5, pitchRatio = 1, pitchDisper = 0, timeDisper = 0;
	var input, sig, windowSize;
	windowSize = 0.2;
	input = InFeedback.ar(in, 2);
	sig = PitchShift.ar(input, windowSize, pitchRatio, pitchDisper, timeDisper.min(windowSize));
	sig = XFade2.ar(input, sig, drywet);
	ReplaceOut.ar(out, sig);
	//XOut.ar(out, drywet, sig);
}).add;

SynthDef(\vocoder_synth, {
    |
    out=0, in=2, amp=1.0, freq=440,
    atk=0.1, dcy=0.1, sus=0.7, rel=1,
    width=0.5, pan=0.0
    |
    var sig, env, chainMod, chainCarr, chain, input;
    env = EnvGen.ar(Env.perc(atk, rel), doneAction:2);
    sig = VarSaw.ar(freq, width:width);
    input = In.ar(in,1) * env;

    chainMod = FFT(LocalBuf(1024), input);
    // uncomment the line below if you want a gate-like effect
    //chainMod = PV_MagAbove(chainMod, 0.2);
    chainCarr = FFT(LocalBuf(1024), sig);
    chain  = PV_MagMul(chainCarr, chainMod);

    chain = PV_MagClip(chain, 50);

    sig = IFFT(chain);
    sig = sig * amp;

    Out.ar(out, Pan2.ar(sig, pan));
}).add;

///////////////////////////////////////  Distortion

~distoInsideOutSynthDef = SynthDef(\distoInsideOut, { arg in = 0, out = 0, drywet = -1, hpfInFreq = 20, lpfInFreq = 20000, level = 0.02;
	var input, inputFilt, effect, sig;
	input = InFeedback.ar(in, 2);
	inputFilt = LPF.ar(HPF.ar(input, hpfInFreq), lpfInFreq);
	effect = InsideOut.ar(inputFilt, level);
	sig = XFade2.ar(input, effect, drywet);
	ReplaceOut.ar(out, sig);
	//XOut.ar(out, drywet, effect);
}).add;

~distoCrossOverSynthDef = SynthDef(\distoCrossOver, { arg in = 0, out = 0, drywet = -1, hpfInFreq = 20, lpfInFreq = 20000, amp = 0.14, smooth = 0.1, level = 0.03;
	var input, inputFilt, effect, sig;
	input = InFeedback.ar(in, 2);
	inputFilt = LPF.ar(HPF.ar(input, hpfInFreq), lpfInFreq);
	effect = CrossoverDistortion.ar(inputFilt , Lag2.kr(amp.max(0.001)), Lag2.kr(smooth.max(0.01)), level);
	sig = XFade2.ar(input, effect, drywet);
	ReplaceOut.ar(out, sig);
	//XOut.ar(out, drywet, effect);
}).add;

SynthDef(\ladspaDist, { arg in = 0, out = 0, drywet = -0.5, envTime = 0.001, knee = 0;
	var input, sig;
	input = InFeedback(in, 2);
	/*envTime = MouseX.kr(1.0e-3, 0.1e-3);
	knee = MouseY.kr(0, -90).dbamp;*/
	envTime = envTime.linlin(0, 1, 1.0e-3, 0.1e-3);
	knee = knee.linlin(0, 1, 0, -90).dbamp;
	sig = DelayC.ar(input, 0.01, envTime * 0.5, EnvFollow.ar(input, 1 - (envTime * SampleRate.ir).reciprocal).max(knee).reciprocal) * 0.1;
	sig = XFade2.ar(input, sig, drywet);
	ReplaceOut.ar(out, sig);
	//XOut(out, drywet, sig);
}).add;

SynthDef(\awdistortion, {arg in = 0, out = 0, gate = 1;
	var source = In.ar(in,2);
	var env = Linen.kr(gate, 0.0, 1, 0.1, 2);
	var abs, excess,output;

	abs = source.abs;

	excess = (abs-0.1).max(0.0).min(0.9)/0.9;

	//original plus sinusoidal perturbation of amount based on absolute amplitude
	output = source+(excess*(sin(excess*2pi*5)*0.5-0.5));

	XOut.ar(out,env,output*env);

}).add;

~waveShapeSynthDef = SynthDef(\waveShape, { arg in = 0, out = 0, mix = 1, hpfInFreq = 20, lpfInFreq = 20000, gain = 1, shaperbuf;
	var input, inputFilt, sig;
	input = In.ar(in, 2);
	inputFilt = LPF.ar(HPF.ar(input, hpfInFreq), lpfInFreq);
	sig = XFade2.ar(input, Shaper.ar(shaperbuf, inputFilt * gain), mix.linlin(0,1.0,-1,1.0));
	ReplaceOut.ar(out, sig);
}).add;

SynthDef(\distoIxi, {arg in = 0, out = 0, drywet = 0.5, gain = 1;
	var fx, sig;
	sig = In.ar(in, 2);
	fx = sig.abs;
	fx = ((fx.squared + (gain*fx))/(fx.squared + ((gain-1)*fx) + 1));
	XOut.ar(out, drywet, fx);
}).add;

SynthDef(\disto1Ixi, {arg in = 0, out = 0, drywet = 0.5, pregain = 1, postgain = 2;
	var fx, sig, distortion;
	sig = In.ar(in, 2);
	distortion = ((sig * pregain).distort * postgain).distort;
	fx = Compander.ar(distortion, distortion, 1, 0, 1 ); // sustain
	XOut.ar(out, drywet, LeakDC.ar(fx + sig));
}).add;

///////////////////////////////////////  Dynamic

SynthDef(\Compression, {arg in = 0, out = 0, gain = 1.5, threshold = 0.5, ratio = 0.5, att = 0.01, rel = 0.01, makeUpGain = 1, drywet = 0.5, level = 1;
	var input, effect, sig;
	input = In.ar(in, 2);
	sig = gain * input;
	effect = CompanderD.ar(sig, threshold, 1, ratio, att, rel, makeUpGain);
	XOut.ar(out, drywet, effect * level);
}).add;

SynthDef(\Limiter, { arg in = 0, out = 0, gain = 1, level = 0.99, dur = 0.01;
	var input, effect;
	input = In.ar(in, 2);
	effect = Limiter.ar(gain * input, level, dur);
	ReplaceOut.ar(out, effect);
}).add;

SynthDef(\limiterIxi, {arg in = 0, out = 0, gain = 1.5, threshold = 0.5, att = 0.01, rel = 0.01, makeUpGain = 1, drywet = 0.5, level = 1;
	var input, effect, sig;
	input = In.ar(in, 2);
	sig = gain * input;
	effect = CompanderD.ar(sig, threshold, 1, 0.1, att, rel, makeUpGain);
	XOut.ar(out, drywet, effect * level);
}).add;

SynthDef(\sustainerIxi, {arg in = 0, out = 0, gain = 1.5, threshold = 0.5, att = 0.01, rel = 0.01, makeUpGain = 1, drywet = 0.5, level = 1;
	var input, effect, sig;
	input = In.ar(in, 2);
	sig = gain * input;
	effect = CompanderD.ar(sig, threshold, 0.7, 1, att, rel, makeUpGain);
	XOut.ar(out, drywet, effect * level);
}).add;

SynthDef(\noisegateIxi, {arg in = 0, out = 0, gain = 1.5, threshold = 0.5, att = 0.01, rel = 0.01, makeUpGain = 1, drywet = 0.5, level = 1;
	var input, effect, sig;
	input = In.ar(in, 2);
	sig = gain * input;
	effect = CompanderD.ar(sig, threshold, 10, 1, att, rel, makeUpGain);
	XOut.ar(out, drywet, effect * level);
}).add;

SynthDef(\noisegateRevIxi, {arg in = 0, out = 0, gain = 1.5, threshold = 0.5, att = 0.01, rel = 0.01, makeUpGain = 1, predelay=0.048, combdecay=3.7, allpassdecay=0.21, revVol=0.21, drywet = 0.5, level = 1;
	var input, effect, sig;
	input = In.ar(in, 2);
	sig = gain * input;
	effect = CompanderD.ar(sig, threshold, 10, 1, att, rel, makeUpGain);
	effect = DelayN.ar(effect, 0.1, predelay);
	effect = Mix.ar(Array.fill(7,{ CombL.ar(effect, 0.05, rrand(0.03, 0.05), rrand(1, 20)) }));
	6.do({ effect = AllpassN.ar(effect, 0.050, rrand(0.03, 0.05), allpassdecay) });
	XOut.ar(out, drywet, effect * level);
}).add;

SynthDef(\normalizerIxi, {arg in = 0, amp = 1, out = 0, level = 0.5, dur = 0.01, drywet = 0.5;
	var input, effect;
	input = In.ar(in, 2);
	effect = Normalizer.ar(input, level, dur);
	XOut.ar(out, drywet, effect * amp);
}).add;

SynthDef(\tremoloIxi, {arg in=0, out=0, drywet = 0.5, freq=1, strength=1;
	var fx, sig;
	sig = In.ar(in, 2);
	fx = sig * SinOsc.ar(freq, 0, strength, 0.5);
	XOut.ar(out, drywet, fx + sig);
}).add;

///////////////////////////////////////  Delay

~simpleDelaySynthDef = SynthDef(\SimpleDelay, { arg in = 0, out = 0, delaytime = 0.1;
	var input, effect;
	input = In.ar(in, 2);
	effect = DelayN.ar(input, 4, delaytime);
	//Out.ar(0, effect); // Mix with the data already present on the corresponding bus
	ReplaceOut.ar(out, effect); // overwriting previous data on the corresponding bus
}).add;

SynthDef(\delayeffect, { arg in = 0, out = 0, delTime = 0.25, decTime = 2.0, t_gate = 1, doneAction = 2;
	var source, delay, env;
	source = In.ar(in, 2);
	env = Linen.kr(t_gate, 0.1, 1, 0.1, doneAction);

	delay= CombC.ar(source, 4, delTime, decTime);

	XOut.ar(out, env, delay);
}).add;

~quadDelaySynthDef = SynthDef(\quadDelay, { arg in = 0, out = 0, drywet = 0.4, amp = 1, feedBack = 0.2;
	var input, delay, delay1, delay2, delay3, delay4, time1, time2, time3, time4, sig, tempoClock;
	input = InFeedback.ar(in, 2);
	delay = input + LocalIn.ar(2);
	tempoClock = \tempoClock.kr(TempoClock.default.tempo);

	// delay 1
	time1 = Select.kr(\sync1.kr(0), [\time1.kr(0.25), \division1.kr(0.625) / tempoClock]);
	delay1 = XFadeDelay.ar(delay, 1, time1);
	delay1 = Balance2.ar(delay1[0], delay1[1], \pan1.kr(0), \amp1.kr(1));

	// delay 2
	time2 = Select.kr(\sync2.kr(0), [\time2.kr(0.4), \division2.kr(2/8) / tempoClock]);
	delay2 = XFadeDelay.ar(delay, 1, time2);
	delay2 = Balance2.ar(delay2[0], delay2[1], \pan2.kr(0), \amp2.kr(1));

	// delay 3
	time3 = Select.kr(\sync3.kr(0), [\time3.kr(0.15), \division3.kr(3/6) / tempoClock]);
	delay3 = XFadeDelay.ar(delay, 1, time3);
	delay3 = Balance2.ar(delay3[0], delay3[1], \pan3.kr(0), \amp3.kr(1));

	// delay 4
	time4 = Select.kr(\sync4.kr(0), [\time4.kr(0.3), \division4.kr(3/4) / tempoClock]);
	delay4 = XFadeDelay.ar(delay, 1, time4);
	delay4 = Balance2.ar(delay4[0], delay4[1], \pan4.kr(0), \amp4.kr(1));

	sig =  delay1 + delay2 + delay3 + delay4;

	LocalOut.ar(sig * feedBack);
	sig = XFade2.ar(input, sig, drywet, amp);
	ReplaceOut.ar(out, sig);
}).add;

SynthDef(\syncDelay, { arg in = 0, out = 0, sync = 0/*false*/, feedBack = 0.2, drywet = 0.4, pan = 0, amp = 0.5;
    var input, delay, sig, time;
    input = In.ar(in, 2);
	delay = input + LocalIn.ar(2);

	time = Select.kr(sync, [\delaytime.kr(0.25), \division.kr(2/3) / \tempoClock.kr(TempoClock.default.tempo)]);
	delay = XFadeDelay.ar(delay, 1, time);
	delay = Balance2.ar(delay[0], delay[1], pan);

    LocalOut.ar(delay * feedBack);
	sig = XFade2.ar(input, delay, drywet, amp);
	ReplaceOut.ar(out, sig);
}).add;

SynthDef(\tapedly, { |in=0, out=0,fb=0.6, fc=5000, dlytime=0.125, wet=0.5, pan=0.0|
	var local, sig, delayed, phi, phR, phP, freq;
	var tdbh; // time delay between heads (seconds)
	local = LocalBuf(SampleRate.ir * 3, 1);
	local.clear; // clear the buffer

	tdbh = 0.125;
	phi = (2 * tdbh) / BufDur.ir(local);
	freq = 1.0 / BufDur.ir(local); // frequency to playback the buffer at rate 1
	freq = (freq * tdbh) / VarLag.kr(dlytime, 2, warp:\linear);
	phR = LFSaw.ar( freq, phi, 0.5, 0.5)*BufFrames.kr( local );
	phP = LFSaw.ar( freq, 0.0, 0.5, 0.5)*BufFrames.kr( local );

	sig = Mix.ar(In.ar(in,2));
	delayed = BufRd.ar(1, local, phP, loop:1);
	delayed = delayed.tanh;
	BufWr.ar( LPF.ar( (sig + delayed), fc, mul:fb), local, phR, loop:1);
	pan = LFNoise1.ar(5);
	Out.ar(out, Pan2.ar(delayed*wet, pan));
}).add;

///////////////////////////////////////  Reverb

SynthDef(\Reverb, {arg in = 0, out = 0, predelaytime = 0.048, decaytimec = 5, decaytimea = 1, drywet = 0.5, level = 0.2;
	var input, numc, numa, temp;
	input = In.ar(in, 2);
	numc = 4; // number of comb delays
	numa = 6; // number of allpass delays
	temp = DelayN.ar(input, 0.1, predelaytime);
	temp = Mix.fill(numc, { CombL.ar(temp, 0.1, rrand(0.01, 0.1), decaytimec) });
	numa.do({ temp = AllpassN.ar(temp, 0.051, [rrand(0.01, 0.05), rrand(0.01, 0.05)], decaytimea) });
	XOut.ar(out, drywet, temp * level);
}).add;

SynthDef(\SchroederReverb, { arg in = 0, out = 0, preDelay = 0.048, maxCombDelay = 0.1, combDecay = 15, allPassMaxDelay = 0.05, allPassDecay = 1;
	var sig, pre, delay;
	//sig = Mix.ar(Array.fill(10, { Resonz.ar(Dust.ar(0.2, 50), 200 + 3000.0.rand, 0.003)}) );
	sig = In.ar(in, 2);
	pre = DelayN.ar(sig, preDelay); // reverb predelay time
	delay = Mix.ar(Array.fill(7,{
		CombL.ar(pre, maxCombDelay, LFNoise1.kr(Rand(0, 0.1), 0.04, 0.05), combDecay);
	}));
	4.do({
		delay = AllpassN.ar(delay, allPassMaxDelay, [Rand(0, 0.05), Rand(0, 0.05)], allPassDecay);
	});
    ReplaceOut.ar(
        out,
        sig + (0.2 * delay)
    );
}).add;

~verbSynthDef = SynthDef(\verb, { arg in = 0, out = 0, drywet = 0.85, amp = 1, feedback = 0, room = 1, damp = 0.4, amount = 1;
	var sig, input;
	input = InFeedback.ar(in, 2);
	sig = input + LocalIn.ar(2);
	sig = FreeVerb2.ar(sig[0], sig[1], Lag2.kr(amount), room, damp);
	LocalOut.ar(feedback.min(0.25) * sig);
	// sig = SelectX.ar(drywet, [input, sig]);
	sig = XFade2.ar(input, sig, drywet, Lag2.kr(amp));
	ReplaceOut.ar(out, sig);
}).add;

// infinite reverb by Eli Feldsteel
SynthDef(\allreverb, { arg in = 0, out = 0, gate = 1, pan = 0, freq = 200;
	var sig;
	var input = InFeedback.ar(in, 2);
	sig = LocalIn.ar(2) * \fb.kr(0.1);
	sig = sig + input;
	15.do {
		sig = AllpassL.ar(sig, 0.06, Rand(0.001,0.06), 3);
	};
	LocalOut.ar(sig);
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,0.1),gate,doneAction:2);
	// sig = SelectX.ar(\mix.kr(0.5), [input, sig]);
	sig = XFade2.ar(input, sig, \mix.kr(0));
	ReplaceOut.ar(out, sig);
}).add;

SynthDef(\allreverbf, { arg in = 0, out=0, gate=1, pan=0, freq=200;
	var sig;
	var input = InFeedback.ar(in, 2);
	var fbsig;
	sig = LocalIn.ar(2) * \fb.kr(0.1);
	sig = sig + input;
	15.do {
		sig = AllpassL.ar(sig, 0.06, Rand(0.001,0.06), 3);
	};
	fbsig = sig;
	fbsig = LPF.ar(sig, \lpf.kr(1000));
	fbsig = HPF.ar(sig, \hpf.kr(100));
	sig = fbsig;
	LocalOut.ar(fbsig);
	sig = sig * EnvGen.ar(Env.adsr(0.4,0.1,0.8,0.1),gate,doneAction:2);
	// sig = SelectX.ar(\mix.kr(0.5), [input, sig]);
	sig = XFade2.ar(input, sig, \mix.kr(0));
	ReplaceOut.ar(out, sig);
}).add;

SynthDef(\allreverbif, { arg in = 0, out=0, gate=1, pan=0, freq=200;
	var sig;
	var input = InFeedback.ar(in, 2);
	var fbsig;
	sig =
	sig = LocalIn.ar(2) * \fb.kr(0.1);
	sig = sig + SelectX.ar(\mix.kr(0.5), [DC.ar(0), input]);
	15.do {
		sig = AllpassL.ar(sig, 0.06, Rand(0.001,0.06), 3);
	};
	fbsig = sig;
	fbsig = LPF.ar(sig, \lpf.kr(1000));
	fbsig = HPF.ar(sig, \hpf.kr(100));
	sig = fbsig;
	LocalOut.ar(fbsig);
	sig = sig * EnvGen.ar(Env.adsr(0.4,0.1,0.8,0.1),gate,doneAction:2);
	sig = sig + input;
	ReplaceOut.ar(out, sig);
}).add;

SynthDef(\reverbCraum, { arg in = 0, out = 0, gate = 1, roomsize = 100, revtime = 1, damping = 0.6, inputbw = 0.5, spread = 15, drylevel = 1, earlyreflevel = 0.7, taillevel = 0.5, maxroomsize = 300, amp = 0.5;
	var source = In.ar(in, 2);
	var reverb;
	var env = Linen.kr(gate, 0.1, 1, 0.1, 2);

	reverb = GVerb.ar(source, roomsize, revtime, damping, inputbw, spread, drylevel, earlyreflevel, taillevel, maxroomsize);
	reverb = reverb * amp ;
	XOut.ar(out,env,reverb);
//By Zé Craum
}).add;

SynthDef(\gatedreverb, {|in = 0, out =0 gate= 1 threshold= 0.1 amp=0.1|

	var a,c,z,y,input;
	var env = Linen.kr(gate, 0.1, 1, 0.1, 2);

	c = 5; // number of comb delays
	a = 4; // number of allpass delays

	input=In.ar(in,2);

	gate = if((input.mean)>threshold,input.mean,DC.ar(0)!2);

	// reverb predelay time :
	z = gate; //DelayN.ar(gate, 0.048,0.048);

	//for delaytime if want modulation-	//LFNoise1.kr(0.1.rand, 0.04, 0.05)
	y=Mix.arFill(c,{CombL.ar(z,0.1,rrand(0.01, 0.1),rrand(1.5,4))});

	// chain of 4 allpass delays on each of two channels (8 total) :
	a.do({ y = AllpassN.ar(y, 0.051, [rrand(0.01, 0.05),rrand(0.01, 0.05)], 1) });

	ReplaceOut.ar(out,Pan2.ar(y,0)*env*amp);

}).add;

SynthDef(\reverbIxi, {arg in = 10, out = 0, drywet = 0.5, predelay=0.048, combdecay=15, allpassdecay=1, revVol=0.31;
	var sig, y, z;
	sig = In.ar(in, 2);

	// predelay
	z = DelayN.ar(sig, 0.1, predelay); // max 100 ms predelay

	// 7 length modulated comb delays in parallel :
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.05, rrand(0.03, 0.05), combdecay) }));

	6.do({ y = AllpassN.ar(y, 0.050, rrand(0.03, 0.05), allpassdecay) });
	XOut.ar(out, drywet, sig + (y * revVol)); // as fxlevel is 1 then I lower the vol a bit
}).add;

~jpverbSynthDef = SynthDef(\JPverb, { arg in = 0, out = 0, drywet = (-1), amp = 1, feedback = 0, t60 = 1, damp = 0, size = 1, earlyDiff = 0.707, modDepth = 0.1, modFreq = 2, low = 1, mid = 1, high = 1, lowcut = 500, highcut = 2000;
	var sig, input;
	input = InFeedback.ar(in, 2);
	sig = input + LocalIn.ar(2);
	sig = JPverb.ar(sig, t60, damp, size, earlyDiff, modDepth, modFreq, low, mid, high, lowcut, highcut);
	LocalOut.ar(feedback.min(0.45) * sig);
	// sig = SelectX.ar(drywet, [input, sig]);
	sig = XFade2.ar(input, sig, drywet, Lag2.kr(amp));
	ReplaceOut.ar(out, sig);
}).add;

~greyHoleSynthDef = SynthDef(\greyHole, { arg in = 0, out = 0, drywet = (-1), amp = 1, delayTime = 2, damp = 0, size = 1, diff = 0.707, feedback = 0, modDepth = 0.1, modFreq = 2;
	var sig, input;
	input = InFeedback.ar(in, 2);
	sig = Greyhole.ar(input, delayTime, damp, size, diff, feedback, modDepth, modFreq);
	// sig = SelectX.ar(drywet, [input, sig]);
	sig = XFade2.ar(input, sig, drywet, Lag2.kr(amp));
	ReplaceOut.ar(out, sig);
}).add;

SynthDef(\lexicon224stereo, { arg
    out = 0,
    in = 0,
    drywet = 1,
    predelay = 0.0,
    input_diff_1 = 1,
    input_diff_2 = 1,
    bandwidth = 0.1,        // input bandwidth
    tdelscale = 1,
    decay = 0.9,    // tank decay
    decay_diff_1 = 1,
    decay_diff_2 = 1,
    damping = 0.999; // tank bandwidth


    var sigL, sigR, src, srcL, srcR, input, local;
    var input_diff = [ input_diff_1, input_diff_2 ];
    var dltimes;
    var tank0L, tank0R, tank1L, tank1R, tankdelays0, tankdelays1, outdelaysL, outdelaysR;
    var n_out_0L, n_out_0R, n_out_1L, n_out_1R, n_out_2L, n_out_2R, n_out_3L, n_out_3R, n_out_4L, n_out_4R, n_out_5L, n_out_5R, n_out_6L, n_out_6R;

    // src = SoundIn.ar([0,1]);
    // src = Impulse.ar(0.5).dup;
    src = InFeedback.ar(in, 2);
    srcL = src[0];
    srcR = src[1];

    // input = OnePole.ar(
    //     DelayC.ar(src.mean, 0.08, predelay),
    //     coef:(bandwidth - 1).abs
    // );

    input = Integrator.ar(
        DelayC.ar(src * bandwidth, 0.08, predelay),
        coef: 1 - bandwidth
    );

    // [142,107,379,277]/29761;
    dltimes = [ 0.0047713450488895, 0.0035953092974026, 0.012734787137529, 0.0093074829474816 ];


    dltimes.do { |it i|
        input = AllpassN.ar(input, it, it, decaytime: input_diff[ i.trunc(2) / 2 ]);
    };
    ///////////////////////////////////Tank///////////

    // [ 672, 4453, 1800, 3720  ]/ 27961
    tankdelays0 = [
        0.022579886428547,
        0.1496253486106 * tdelscale,
        0.060481838647895,
        0.12499579987232 * tdelscale
    ];

    // [908, 4217, 2656, 3163] / 27961
    tankdelays1 = [
        0.030509727495716,
        0.14169550754343 * tdelscale,
        0.089244313027116,
        0.10628003091294 * tdelscale
    ];

    local = LocalIn.ar(4);
    ////////////////////////// 0L //////////////////

    n_out_1L = AllpassL.ar(
        input[0] + local[1],
        0.4,
        // (tankdelays0[0] + SinOsc.ar(0.7,mul:0.00025)),
        (tankdelays0[0] + LFNoise2.ar(0.7,mul:0.00025)),
        decaytime: decay_diff_1
    );

    tank0L = DelayC.ar(
        n_out_1L,
        tankdelays0[1],
        tankdelays0[1]
    );

    // n_out_2 = OnePole.ar(tank0, 1 - damping);
    n_out_2L = Integrator.ar(tank0L * ( 1 - damping ), damping) * decay;

    n_out_3L = AllpassL.ar(
        n_out_2L,
        tankdelays0[2],
        tankdelays0[2],
        decaytime: decay_diff_2
    );

    tank0L = DelayC.ar(
        n_out_3L,
        tankdelays0[3],
        tankdelays0[3] - ControlDur.ir
    ) * decay;

    ////////////////////////////// 1L ///////////////

    n_out_4L = AllpassL.ar(
        input[0] + local[0],
        0.4,
        // (tankdelays1[0] + SinOsc.ar(0.71, mul:0.00018)),
        (tankdelays1[0] + LFNoise2.kr(0.71, mul:0.00018)),
        decaytime: decay_diff_1
    );

    tank1L = DelayC.ar(
        n_out_4L,
        tankdelays1[1],
        tankdelays1[1]
    );

    n_out_5L = Integrator.ar(tank1L * ( 1 - damping ), damping) * decay;

    n_out_6L = AllpassL.ar(
        n_out_5L,
        tankdelays1[2],
        tankdelays1[2],
        decaytime: decay_diff_2
    );

    tank1L = DelayC.ar(
        n_out_6L,
        tankdelays1[3],
        tankdelays1[3] - ControlDur.ir

    ) * decay;

    ////////////////////////// 0R //////////////////

    n_out_1R = AllpassL.ar(
        input[1] + local[2],
        0.4,
        // (tankdelays0[0] + SinOsc.ar(0.7,mul:0.00025)),
        (tankdelays0[0] + LFNoise2.ar(0.7,mul:0.00025)),
        decaytime: decay_diff_1
    );

    tank0R = DelayC.ar(
        n_out_1R,
        tankdelays0[1],
        tankdelays0[1]
    );

    // n_out_2 = OnePole.ar(tank0, 1 - damping);
    n_out_2R = Integrator.ar(tank0R * ( 1 - damping ), damping) * decay;

    n_out_3R = AllpassL.ar(
        n_out_2R,
        tankdelays0[2],
        tankdelays0[2],
        decaytime: decay_diff_2
    );

    tank0R = DelayC.ar(
        n_out_3R,
        tankdelays0[3],
        tankdelays0[3] - ControlDur.ir
    ) * decay;

    ////////////////////////////// 1R ///////////////

    n_out_4R = AllpassL.ar(
        input[1] + local[3],
        0.4,
        // (tankdelays1[0] + SinOsc.ar(0.71, mul:0.00018)),
        (tankdelays1[0] + LFNoise2.kr(0.71, mul:0.00018)),
        decaytime: decay_diff_1
    );

    tank1R = DelayC.ar(
        n_out_4R,
        tankdelays1[1],
        tankdelays1[1]
    );

    n_out_5R = Integrator.ar(tank1R * ( 1 - damping ), damping) * decay;

    n_out_6R = AllpassL.ar(
        n_out_5R,
        tankdelays1[2],
        tankdelays1[2],
        decaytime: decay_diff_2
    );

    tank1R = DelayC.ar(
        n_out_6R,
        tankdelays1[3],
        tankdelays1[3] - ControlDur.ir

    ) * decay;

    LocalOut.ar([
        tank0L * -1,
        tank1L * -1,
        tank0R * -1,
        tank1R * -1
    ]);

    // [266,  2974, 1913, 1996, 1990, 187,  1066] / 29761
    outdelaysL = [ 0.0089378717113, 0.099929437854911, 0.064278754074124, 0.067067638856221, 0.066866032727395, 0.0062833910150869, 0.035818688888142 ];

    // [353, 3627, 1228, 2673, 2111, 335, 121] / 29761
    outdelaysR = [ 0.011861160579282, 0.12187090487551, 0.041262054366453, 0.089815530392124, 0.070931756325392, 0.011256342192803, 0.0040657235979974 ];

    sigL = Mix([
        [
            Mix([
                DelayN.ar( n_out_4L, outdelaysL[0] ),
                DelayN.ar( n_out_4L, outdelaysL[1] ),
                DelayN.ar( n_out_5L, outdelaysL[2] ).neg,
                DelayN.ar( n_out_6L, outdelaysL[3] ),
                DelayN.ar( n_out_1L, outdelaysL[4] ).neg,
                DelayN.ar( n_out_2L, outdelaysL[5] ).neg,
                DelayN.ar( n_out_3L, outdelaysL[6] ).neg
            ])
            ,
            Mix([
                DelayN.ar( n_out_1L, outdelaysR[0] ),
                DelayN.ar( n_out_1L, outdelaysR[1] ),
                DelayN.ar( n_out_2L, outdelaysR[2] ).neg,
                DelayN.ar( n_out_3L, outdelaysR[3] ),
                DelayN.ar( n_out_4L, outdelaysR[4] ).neg,
                DelayN.ar( n_out_5L, outdelaysR[5] ).neg,
                DelayN.ar( n_out_6L, outdelaysR[6] ).neg
            ])
        ] * drywet,
        srcL * (1 - drywet)
    ]);

    sigR = Mix([
        [
            Mix([
                DelayN.ar( n_out_4R, outdelaysL[0] ),
                DelayN.ar( n_out_4R, outdelaysL[1] ),
                DelayN.ar( n_out_5R, outdelaysL[2] ).neg,
                DelayN.ar( n_out_6R, outdelaysL[3] ),
                DelayN.ar( n_out_1R, outdelaysL[4] ).neg,
                DelayN.ar( n_out_2R, outdelaysL[5] ).neg,
                DelayN.ar( n_out_3R, outdelaysL[6] ).neg
            ])
            ,
            Mix([
                DelayN.ar( n_out_1R, outdelaysR[0] ),
                DelayN.ar( n_out_1R, outdelaysR[1] ),
                DelayN.ar( n_out_2R, outdelaysR[2] ).neg,
                DelayN.ar( n_out_3R, outdelaysR[3] ),
                DelayN.ar( n_out_4R, outdelaysR[4] ).neg,
                DelayN.ar( n_out_5R, outdelaysR[5] ).neg,
                DelayN.ar( n_out_6R, outdelaysR[6] ).neg
            ])
        ] * drywet,
        srcR * (1 - drywet)
    ]);

    ReplaceOut.ar(out, Mix([sigL + sigR]));
}).add;

SynthDef(\revAlesisLike, { arg
    inAmp=0.8,
    scaleDelays=1,
    inDiffusion=0.05,
    feedback=0.5,
    decay_sec=0.5,
    decay1_sec=0.5,
    peakgain=0,
    rqscale=1;

    var signal, signalIn = InFeedback.ar(\in.kr(0), 2) * inAmp;
    var tank;
    var    ndelaylines = 2;
    var sr = SampleRate.ir, sz = 4;
    var src, localin;
    var  times, dtimes, b;
    var l,r;
    var earlyDiffDTimes = [], earlyDiffSize = 4;
    var apc;
    var tankIns;

    src = HPF.ar(signalIn, \inputHPF.kr(150));
    src = OnePole.ar(src, \inputLPF.kr(0.5));

    src = DelayN.ar(src, 0.1, \predelay.kr(0.0));

    times = [ 1447, 727, 613, 673, 1439, 2083, 2011, 1511, 1493, 1277, 2437, 2383, 2341, 997, 1061, 2039, 1997, 1481, 1627, 1129, 743, 983, 1091, 907, 541, 2393, 1801, 2081, 1787, 1453, 977, 2311, 691, 479, 2377, 1693, 1013, 1931, 1049, 2243, 839, 739, 1747, 601, 1823, 1123, 2467, 1297, 1613, 1361, 2207, 593, 619, 1709, 449, 937 ];

    // Keith Barr dtimes

    /*l = nil ! ( sz * 3  ) ;
    l.size.div(3).do { |i|
        i = i * 3;
        // l[i] = rrand(300,700) * 2.pow(i/3);
        // l[i+1] = rrand(300,700) * 2.pow(i/3);
        l[i] = rrand(2500,5000) / 3.pow(i/3);
        l[i+1] = rrand(2500,5000) / 3.pow(i/3);
        l[i+2] = ( l[i] + l[i+1] * rrand(0.8,1.0) ).round(1);
    };

    l = l * scaleDelays;

    r = nil ! ( sz * 3  ) ;
    r.size.div(3).do { |i|
        i = i * 3;
        // r[i] = rrand(300,700) * 2.pow(i/3);
        // r[i+1] = rrand(300,700) * 2.pow(i/3);
        r[i] = rrand(2500,5000) / 3.pow(i/3);
        r[i+1] = rrand(2500,5000) / 3.pow(i/3);
        r[i+2] = ( r[i] + r[i+1] * rrand(0.8,1.0) ).round(1);
    };

    r = r * scaleDelays;*/

    l = times.size.div(2).collect({|i| times[i*2]}) * scaleDelays;
    r = times.size.div(2).collect({|i| times[i*2 + 1]}) * scaleDelays;

    earlyDiffDTimes = { times.removeAt(times.minIndex) } ! ( earlyDiffSize * src.size );

    dtimes = Routine{(earlyDiffDTimes ++ l ++ r).do { |it| it.yield }};

    src.do { |it j|
        earlyDiffSize.do { |i|
            var dt = dtimes.next / sr;
            src[j] = AllpassN.ar(src[j], dt, dt, inDiffusion);
        };

    };

    localin = LocalIn.ar(ndelaylines);

    tankIns = [nil!src.size.div(ndelaylines), nil!src.size.div(ndelaylines)];

    tankIns.do { |it j|
        tankIns[j].do { |item i|
            tankIns[j]/*[i]*/ = src[i*2+j];
        };
    };

    tank =
    ndelaylines.collect({|j|
        var processed;

        processed = localin[j];

        sz.collect { |i|
            var dtsec;
            var dt0, dt1;
            processed = processed + tankIns[j]/*[i]*/;


            dt0 = dtimes.next / sr;
            dt1 = dtimes.next / sr;

            processed = AllpassC.ar(processed, dt0, dt0, decay_sec );
            processed = AllpassC.ar(processed, dt1, dt1, decay1_sec);

            dtsec = dtimes.next / sr;
            processed = DelayC.ar(processed, dtsec, dtsec * LFNoise2.kr(0.3).range(0.9,1));

            processed = BPeakEQ.ar(processed, \peakfreq.kr(1200).lag(0.6) * Rand(0.7,1.3), Rand(0.9,1.2) * rqscale, db:peakgain);
            processed = OnePole.ar(processed, \damping.kr(0.3) * Rand(0.8,1.1));

        }
    });

    LocalOut.ar(
        [
            tank[0].last,
            tank[1].last
        ]//.reverse
        * feedback
    );

    tank = LeakDC.ar(tank);

    signal = tank.collect({|item i|
        tank[i].collect({|it j|
            tank[i][j] * ( "level_" ++ i ++ j ).asSymbol.kr(rrand(0.5, 1))
        })
    });

    signal = signal.collect({|item| item.sum });

    ReplaceOut.ar(\out.kr(0), signal * \tail.kr(1));
}).add;

///////////////////////////////////////  Eq

~filterBusSynthDef = SynthDef(\filterBus, { arg in = 0, out = 0, drywet = -1, hpfInFreq = 20, eqFreq = 3200, eqRq = 1, eqDb = 0, lpfInFreq = 20000;
	var input, inputFilt, sig;
	input = InFeedback.ar(in, 2);
	inputFilt = LPF.ar(HPF.ar(input, Lag3.kr(hpfInFreq)), Lag3.kr(lpfInFreq));
	inputFilt = BPeakEQ.ar(inputFilt, Lag2.kr(eqFreq.max(20).min(20000), 0.5), eqRq, eqDb);
	sig = XFade2.ar(input, inputFilt, drywet);
	ReplaceOut.ar(out, sig);
	//XOut.ar(out, drywet, effect);
}).add;

///////////////////////////////////////  Kick

~snapKickSynthDef = SynthDef(\snapkick, { |out = 0, amp = 0.3, pan = 0, bdFrqL1 = 261, bdFrqL2 = 120, bdFrqL3 = 51, bdFrqT1 = 0.035, bdFrqT2 = 0.08, bdFrqC = \exp, bdAmpAtt = 0.005, bdAmpSus = 0.1, bdAmpRel = 0.3, bdAmpLev = 1, bdAmpCurve = \linear, popFrqSt = 750, popFrqEnd = 261, popFrqDur = 0.02, popAmpAtt = 0.001, popAmpSus = 0.02, popAmpRel = 0.001, popAmpLev = 0.15, clkAmpAtt = 0.001, clkAmpRel = 0.01, clkAmpLev = 0.15, clkAmpCurve = (-4), clkfFundFreq = 910, clkfFormFreq = 4760, clkfBwFreq = 2110, clkLpfFreq = 3140, doneAction = 2|
	var body, bodyFreq, bodyAmp;
	var pop, popFreq, popAmp;
	var click, clickAmp;
	var snd;

	// body starts midrange, quickly drops down to low freqs, and trails off
	bodyFreq = EnvGen.ar(Env([bdFrqL1, bdFrqL2, bdFrqL3], [bdFrqT1, bdFrqT2], bdFrqC));
	bodyAmp = EnvGen.ar(Env.linen(bdAmpAtt, bdAmpSus, bdAmpRel, bdAmpLev, bdAmpCurve), doneAction: doneAction);
	body = SinOsc.ar(bodyFreq) * bodyAmp;
	// pop sweeps over the midrange
	popFreq = XLine.kr(popFrqSt, popFrqEnd, popFrqDur);
	popAmp = EnvGen.ar(Env.linen(popAmpAtt, popAmpSus, popAmpRel, popAmpLev));
	pop = SinOsc.ar(popFreq) * popAmp;
	// click is spectrally rich, covering the high-freq range
	// you can use Formant, FM, noise, whatever
	clickAmp = EnvGen.ar(Env.perc(clkAmpAtt, clkAmpRel, clkAmpLev, clkAmpCurve));
	click = LPF.ar(Formant.ar(clkfFundFreq, clkfFormFreq, clkfBwFreq), clkLpfFreq) * clickAmp;

	snd = body + pop + click;
	snd = snd.tanh;

	OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
}).add;

~ikedaBassSynthDef = SynthDef(\IkedaBass, { arg out = 0, amp = 1, pan = 0, envL1 = 0, envL2 = 0.5, envL3 = 0.4, envL4 = 0, envT1 = 0, envT2 = 0.2, envT3 = 0.01, envCurve = (-5), freq = 0, sweep1 = 52.8, sweep2 = 740, vol1 = 2, vol2 = 0.05, t_trig = 0, doneAction = 2;
	var env, sin, sig;
	env = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), t_trig, doneAction: doneAction);
	sin = SinOsc.ar(freq, (Sweep.ar(t_trig, 2pi * [sweep1, sweep2]) + (pi/3)).wrap(-pi, pi), [vol1, vol2]).mean.tanh;
	sig = sin * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\ikedaBassBr, { arg out = 0, amp = 1, pan = 0, att = 0, dec = 0.1, sus = 0.8, rel = 0.01, curve = -5, freq = 0, harmonic = 14.015, iphase = pi/3, gate = 1, doneAction = 2;
	var env, snd;

	env = Env.adsr(
	    	attackTime: att,
	    	decayTime: dec,
	    	sustainLevel: sus,
	    	releaseTime: rel,
	    	curve: curve,
	    ).kr(gate: gate, doneAction: doneAction);

	env = env * amp.curvelin(inMin: 0, inMax: 1, outMin: 0, outMax: 1, curve: log(10));

	snd = SinOsc.ar(
		    //Any value for freq here gets added to the freq of the note (n + 0 = n)
		    freq: 0,
		    //Phase sweeps around a circle at (rate / 2pi) to make a sine wave.
		    phase: (Sweep.ar(trig: gate, rate: 2pi * [freq, freq * harmonic]) + iphase).wrap(-pi, pi),
	        mul: [1, 0.01]
	    );

	snd = Mix.ar(snd).tanh;

	snd = LeakDC.ar(snd);

	snd = snd * env;

    OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\gabberkick, { arg out = 0, amp = 0.1, attack = 0.001, release = 0.05;
    var snd, freq, high, lfo;
	freq = \freq.kr(440).min(1400) * (Env.perc(0.001, 0.08, curve: \curve.kr(-1)).ar * 48 * \bend.kr(1)).midiratio;
    snd = Saw.ar(freq);
    snd = (snd * 100).tanh + ((snd.sign - snd) * -8.dbamp);
    high = HPF.ar(snd, 300);
    lfo = SinOsc.ar(8, [0, 0.5pi]).range(0, 0.01);
    high = high.dup(2) + (DelayC.ar(high, 0.01, lfo) * -2.dbamp);
    snd = LPF.ar(snd, 100).dup(2) + high;
    snd = RLPF.ar(snd, 7000, 2);
    snd = BPeakEQ.ar(snd, \ffreq.kr(3000) * XLine.kr(1, 0.8, 0.3), 0.5, 15);
    snd = snd * Env.asr(attack, 1, release).ar(2, \gate.kr(1));
    OffsetOut.ar(out, snd * amp);
}).add;

~kickMistSynthDef = SynthDef(\kickMist, { arg out = 0, level = 1, pan = 0, tu = 1, noise = 1, env0L1 = 0.5, env0L2 = 1, env0L3 = 0.3, env0L4 = 0, env0T1 = 0.01, env0T2 = 0.5, env0T3 = 0.26, curve0_1 = (-4), curve0_2 = (-2), curve0_3 = (-4), env1L1 = 120, env1L2 = 43, env1L3 = 29, env1T1 = 0.03, env1T2 = 0.29, curve1_1 = (-4), curve1_2 = (-5), doneAction = 2;
	var env0, env1, env1m, sig;
	env0 =  EnvGen.ar(Env.new([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3], [curve0_1, curve0_2, curve0_3]), doneAction: doneAction);
	env1 = EnvGen.ar(Env.new([env1L1, env1L2, env1L3], [env1T1, env1T2], [curve1_1, curve1_2]));
	env1m = env1.midicps;
	sig = LFPulse.ar(env1m*tu, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(noise);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m*tu, 0.5, env0*4);
	sig = sig.clip2(1);
	OffsetOut.ar(out, Pan2.ar(sig, pan, level));
}).add;

~kickhiSynthDef = SynthDef(\kickhi, { arg out = 0, amp = 1, pan = 0, vcaLev1 = 0.5, vcaLev2 = 0.1, vcaLev3 = 0.01, vcaLev4 = 0.01, vcaLev5 = 0, vcaTime1 = 0.01, vcaTime2 = 0.5, vcaTime3 = 1.26, vcaTime4 = 0.1, vcaCurve1 = (-4), vcaCurve2 = (-2), vcaCurve3 = (-4), vcfLev1 = 122, vcfLev2 = 30, vcfLev3 = 33, vcfLev4 = 28, vcfTime1 = 0.05, vcfTime2 = 0.29, vcfTime3 = 1, vcfCurve1 = (-4), vcfCurve2 = (-5), tu = 1, doneAction = 2;
	var env0, env1, env1m, sig;
	env0 =  EnvGen.ar(Env.new([vcaLev1, vcaLev2, vcaLev3, vcaLev4, vcaLev5], [vcaTime1, vcaTime2, vcaTime3, vcaTime4], [vcaCurve1, vcaCurve2, vcaCurve3]), doneAction: doneAction);
	env1 = EnvGen.ar(Env.new([vcfLev1, vcfLev2, vcfLev3, vcfLev4], [vcfTime1, vcfTime2, vcfTime3], [vcfCurve1, vcfCurve2]));
	env1m = env1.midicps;
	sig = LFPulse.ar(env1m*tu, 0, 0.5, 1, -0.5);
	sig = out + WhiteNoise.ar(1);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m*tu, 0.5, env0*4);
	sig = sig * 1.2;
	sig = sig.clip2(1);
	sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

~kick2SynthDef = SynthDef(\kick2,{arg out = 0, t_gate = 1, freq = 60, tu = 1, amp = 1, atf = 80, rel =1, pan = 1;
	var env = EnvGen.ar(Env.perc(0,rel),t_gate,doneAction:2);
	var frequ = EnvGen.ar(Env([freq-30,freq,60],[0.001,0.01]));
	var sig = SinOsc.ar(frequ*tu,0,env);
	sig = Pan2.ar(LPF.ar(sig,100), pan, amp);
	OffsetOut.ar(out, sig);
}).add;

~kick2newSynthDef = SynthDef(\kick2new,{arg out = 0, amp = 1, pan = 0, att = 0, rel = 1, envfT1 = 0.002, envfT2 = 0.1, freq = 60, tu = 1, bpeqf1 = 80, bpeqrq1 = 1, bpeqamp1 = 6, bpeqf2 = 800, bpeqrq2 = 10, bpeqamp2 = (-12), hpff = 20000, t_gate = 1, doneAction = 2;
    var env = EnvGen.ar(Env.perc(att, rel), t_gate, doneAction: doneAction);
    var frequ = EnvGen.ar(Env([freq+1100, freq, 31.4],[envfT1, envfT2]));
    var sig = SinOsc.ar(frequ*tu, 0, env);
    sig = BPeakEQ.ar(sig, bpeqf1, bpeqrq1, bpeqamp1);
    sig = sig *0.4*(env+0.2);
    sig = BPeakEQ.ar(sig, bpeqf2, bpeqrq2, bpeqamp2);
    //sig = Limiter.ar(sig,0.5);
    //Out.ar(6,[DelayL.ar(sig*(-1),0.1,SinOsc.kr(-0.1,0,0.05,0.1)),sig]);
	sig = HPF.ar(sig, hpff);
	sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\kick3,{arg out = 0, amp = 0.5, pan = 0, tu = 1, att = 0, rel = 3, freq = 60, t_gate = 1, doneAction = 2;
	var env = EnvGen.ar(Env.perc(att, rel), t_gate, doneAction: doneAction);
	var frequ = EnvGen.ar(Env([130,freq,30],[0.05,rel]));
	var sig = SinOsc.ar(freq*tu,0,env);
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\kick3new,{arg out = 0, amp = 0.5, t_gate = 1, tu = 1, rel = 3, freq = 60, pan = 0;
    var env = EnvGen.ar(Env.perc(0,rel), t_gate, doneAction:2);
    var frequ = EnvGen.ar(Env([100,50,50],[0.005,0.1]));
    var sig = SinOsc.ar(freq*tu,0,env);
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\kicknoise,{arg out = 0, amp = 0.5, pan = 0;
	var env = EnvGen.ar(Env([0,1,0],[0.01, 0.1]), doneAction: 2);
	var freq =EnvGen.ar(Env([20000,100,30],[0.005,1]));
	var sig =  SinOsc.ar(freq,0,env)+(WhiteNoise.ar(1)*env);
	sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

~t1kickSynthDef = SynthDef(\t1kick, {arg out = 0, amp = 0.5, pan = 0, rel = 0, doneAction = 2;
	var enva, envf, sig;
	enva = EnvGen.ar(Env([0.01,1,0],[0.001, rel]), doneAction: doneAction);
	envf = EnvGen.ar(Env([800,50],[0.005,1]));
	sig = SinOsc.ar(envf,0,enva);
	sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

~t1kick2SynthDef = SynthDef(\t1kick2, {arg out = 0, amp = 0.5, pan = 0, envaT1 = 0, envaL1 = 1, envaT2 = 0.6, envaL2 = 1, envaT3 = 0.2, envaL3 = 0.5, envaT4 = 0.2, envaL4 = 0, envaCurve = \exp, envfT1 = 0, envfL1 = 10000, envfT2 = 0.002, envfL2 = 20, envfT3 = 0.1, envfL3 = 0, envfT4 = 1, envfL4 = 4, envfCurve = \exp, pitch = 0.1, hpfFreq = 1200, hpfRq = 1, verbMix = 1, verbRoom = 1, verbDamp = 0.5, doneAction = 2;
	var revSig;
	var enva = EnvGen.kr(Env.pairs([[envaT1, envaL1], [envaT2, envaL2], [envaT3, envaL3], [envaT4, envaL4]], envaCurve), doneAction: doneAction);
	//var envf = EnvGen.kr(Env([10000,20,00,4],[0.002,0.1,1,1]));
	var envf = EnvGen.kr(Env.pairs([[envfT1, envfL1], [envfT2, envfL2], [envfT3, envfL3], [envfT4, envfL4]], envfCurve), doneAction: doneAction);
	var sig = SinOsc.ar(envf+50*pitch, 0, enva);
	//sig = PitchShift.ar(sig,0.001,pitch,0.1);
	sig = BHiPass4.ar(sig.distort, hpfFreq, hpfRq);
	revSig = FreeVerb.ar(sig, verbMix, verbRoom.max(0.01), verbDamp);
	//revSig = GVerb.ar(sig, 12, verbTime, verbDamp); // don't change room there's a bug in Gverb
	sig = SelectX.ar(verbMix, [sig, revSig]);
	sig = Pan2.ar(sig, pan, amp*enva);
	OffsetOut.ar(out, sig);
}).add;

~kickMedSynthDef = SynthDef(\kickmed, { | out = 0, level = 0.5, pan = 0, noise = 1, done = 2, dc = 1, snd = 18, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, relEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1, env1T2, env1T3, env1T4, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase, oamp = 0.1, owhich2 = 0, ochoose = 0|
	var env0,env1,
env1m, son, son2,son3,son4,p2;
	p2 = phase * (-pi);
env0 = Env([env0L1,env0L2,env0L3,env0L4,0],[atkEnv0,decEnv0,relEnv0,0.5],[curve1, curve2, curve3]);
env1 = Env([env1L1,env1L2,env1L3],[env1T1,env1T2,env1T3,env1T4],[curve1, curve2, curve3]);
env0 = EnvGen.ar(env0, doneAction:done);
env1 = EnvGen.ar(env1);
env1m = env1.midicps;
	son = LFSaw.ar(env1m,0,oamp, 1,1.4);
	son2 = SinOsc.ar(env1m, 0, oamp, 1,1.4);
	son3 = LFPulse.ar(env1m,0, oamp, 1,1.4);
	son4 = LFTri.ar(env1m,0, oamp, 1,1.4);
son = SelectX.ar(ochoose,[son,son2,son3,son4]);
son = LeakDC.ar(son,dc,30);
son = son + WhiteNoise.ar(noise);
	son = LPF.ar(son, env1m*fratio.max(0.01), env0);
	son = son + SelectX.ar(owhich2,[ SinOsc.ar(env1m, phase, env0), LFSaw.ar(env1m, phase, env0), LFPulse.ar(env1m, phase, env0), LFTri.ar(env1m, phase, env0)]);
	son = son*level.distort;
	son = Pan2.ar(son, pan);
OffsetOut.ar(out, son*level).tanh;
//OffsetOut.ar(snd, Mono(son)*level).tanh;
}).add;

~kick808SynthDef = SynthDef(\kick808,{arg out = 0, amp = 0.5,  pan = 0, tu = 1, t_trig = 1, envL1 = 0, envL2 = 1, envL3 = 0, envT1 = 0, envT2 = 1, enfL1 = 1000, enfL2 = 20, enfL3 = 20, enfT1 = 0.001, enfT2 = 0.001, enfT3 = 0.001;
	var env = EnvGen.ar(Env([envL1,envL2,envL3],[envT1,envT2],-8), t_trig, doneAction:2);
	var enf  = EnvGen.ar(Env([enfL1,enfL2,enfL3],[enfT1,enfT2,enfT3],-4));
	var sig = SinOsc.ar(tu*(enf+40))*env;
	sig = sig + LPF.ar(SinOsc.ar(SinOsc.ar(100,0,50,100*tu),0,0.2)*env,1000);
	OffsetOut.ar(out, Pan2.ar(sig * env, pan, amp));
}).add;

~kick808newSynthDef = SynthDef(\kick808new, { arg out = 0, amp = 0.5, pan = 0, envL1 = 1, envL2 = 1, envL3 = 0, envT1 = 0, envT2 = 1, envCurve = (-8), enfL1 = 5000, enfL2 = 100, enfL3 = 50, enfT1 = 0.0001, enfT2 = 0.01, enfCurve = (-4), tu = 2, sin2Frq = 10, sin2Amp = 50, doneAction = 2;
    var env = EnvGen.ar(Env([envL1, envL2, envL3],[envT1, envT2], -8), doneAction: doneAction);
    var enf  = EnvGen.ar(Env([enfL1, enfL2, enfL3],[enfT1, enfT2, 0.1], enfCurve));
    var sig = SinOsc.ar(tu*(enf))*env;
    sig = sig + LPF.ar(SinOsc.ar(SinOsc.ar(sin2Frq, 0, sin2Amp, 40*tu), 0, 0.01) * env, 100);
    sig = LeakDC.ar(sig);
	sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out,sig*env);
}).add;

~kick808AwSynthDef = SynthDef(\kick808Aw, {arg out = 0, amp = 12, pan = 0, freqSrt = 240, freqEnd = 60, freqTime = 0.1, ringTime = 100, envpT1 = 0, envpL1 = 0, envpT2 = 0.2, envpL2 = 1, envpT3 = 0.4, envpL3 = 0.2, envpT4 = 0.4, envpL4 = 0, envpCurve = \exp, dist = 1.5, hpfFreq = 30, tott = 1, durr = 0.01, t_trig = 1, doneAction = 2;
    var snd, env;
	tott = tott.max(0.01);
	snd = Ringz.ar(
		in: Impulse.ar(0), // single impulse
		freq: XLine.ar(freqSrt, freqEnd, freqTime),
		decaytime: ringTime
	);
	env = EnvGen.ar(Env.pairs([[envpT1, envpL1], [envpT2, envpL2], [envpT3, envpL3], [envpT4, envpL4]], envpCurve), t_trig, doneAction: doneAction);
	snd = (1.0 - dist) * snd + (dist * (snd.distort));
	snd = snd * env;
	snd = HPF.ar(snd, hpfFreq);
	snd = Limiter.ar(snd, tott, durr.max(0.01)) * 0.5 *(1/tott);
	//snd = Clip.ar(snd, -1 * tott, tott);
	//snd = Fold.ar(snd, -1 * tott, tott);
	//snd = Wrap.ar(snd, -1 * tott, tott);
	OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\kick808Br, {arg out = 0, amp = 1, pan = 0, att = 0.001, rel = 1, freq1 = 240, freq2 = 60, ringTime = 10, dist = 0.5, doneAction = 2;
	var snd, env;
	snd = Ringz.ar(
		in: Impulse.ar(0), // single impulse
		freq: XLine.ar(freq1, freq2, 0.1),
		decaytime: ringTime);
	env = Env.perc(att, rel, amp).kr(doneAction: doneAction);
	snd = (1.0 - dist) * snd + (dist * (snd.distort));
	snd = snd * env;
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

~kikAwSynthDef = SynthDef(\kikAw, { |out = 0, amp = 0.5, basefreq = 50, ratio = 7, sweeptime = 0.05, envL1 = 1, envL2 = 0.8, envL3 = 0, envT1 = 0.3, envT2 = 0.15|
    var fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
	env = EnvGen.kr(Env([envL1, envL2, envL3], [envT1, envT2], -4), doneAction: 2),
	sig = SinOsc.ar(fcurve, 0.5pi, env).distort * amp;
    OffsetOut.ar(out, sig ! 2)
}).add;

~kickbassSynthDef = SynthDef(\kickbass, { | out = 0, level = 0.5, pan = 0, attack = 0.01, decay = 0.2, release = 0.26, fratio = 1.5, noise = 1, freq1 = 120, freq2 = 30, freq3 = 30, dc = 1, aamp1 = 1, aamp2 = 1, aamp3 = 1, aamp4 = 1, curve1 = (-4), curve2 = (-2), curve3 = (-4), famp1, famp2, famp3, famp4, p1, oamp = 0.1, owhich2 = 0, ochoose = 0, filter = 20000, done = 2 |
	var env0,env1,
env1m, son, son2,son3,son4,p2;

	p2 = p1 * (-pi);
env0 = Env([aamp1,aamp2,aamp3,aamp4,0.1,0],[attack,decay,release],[curve1, curve2, curve3]);
env1 = Env([freq1,freq2,freq3],[famp1,famp2,famp3,famp4],[curve1, curve2, curve3]);

env0 = EnvGen.ar(env0,SinOsc.kr(0.025) ,doneAction: done);
	env1 = EnvGen.ar(env1);
env1m = env1.midicps;

son = LFSaw.ar(env1m,0,oamp, 1,1.4);//*LFSaw.ar(100).distort;
son2 = SinOsc.ar(env1m,0, oamp, 1,1.4);
son3 = LFPulse.ar(env1m,0, oamp, 1,1.4);
son4 = LFTri.ar(env1m,0, oamp, 1,1.4);

son = SelectX.ar(ochoose,[son,son2,son3,son4]);
	son = Pan2.ar(son,pan);
son = LeakDC.ar(son,dc,30);

	son = LPF.ar(son+ WhiteNoise.ar(1*noise), env1m*fratio.max(0.01), env0);

	son = son + SelectX.ar(owhich2,[ SinOsc.ar(env1m, [p1,p2], env0), LFSaw.ar(env1m, [p1,p2], env0), LFPulse.ar(env1m, [p1,p2], env0), LFTri.ar(env1m, [p1,p2], env0)]);
	son = LPF.ar(son,filter.max(150)+SinOsc.kr(2,0.5,200));
son = son * 1;
//son = son.clip2(1);
son = son * level.distort;
son = Pan2.ar(son, pan, level);
OffsetOut.ar(out, son).tanh;
}).add;

~drumkickSynthDef = SynthDef(\drumkick, { arg out = 0, amp = 0.5, pan = 0.0, attack = 0.0001, release = 0.09, curve = 8, attSinFreq = 0.0001, relSinFreq = 1.5, curveSinFreq = (-200), levSin = 1, attBpfFreq = 0.001, relBpfFreq = 0.3, timeScaleBpf = 1.5, curveBpf =(-200), levBpf = 1, levScaleBpf = 6000, levBiasBpf = 70, lineStartBpf = 0.3, lineEndBpf = 0, lineLevBpf = 0.1, t_gate = 1, doneAction = 2;
	var source;

	source = SinOsc.ar(EnvGen.kr(Env.perc(attSinFreq, relSinFreq, levSin, curveSinFreq), t_gate, 1000, 45), 1, 1) +
	((BPF.ar([GrayNoise.ar(6),GrayNoise.ar(6)], EnvGen.kr(Env.perc(attBpfFreq, relBpfFreq, levBpf, curveBpf), t_gate, levScaleBpf, levBiasBpf.max(0.1)), timeScaleBpf.max(0.01))).distort * Line.kr(lineStartBpf, lineEndBpf, lineLevBpf)) * EnvGen.kr(Env.perc(attack, release, curve: curve), t_gate, doneAction: doneAction);

	OffsetOut.ar(out, Pan2.ar(source, pan, amp));
}).add;

SynthDef(\kickAw, {arg out = 0, amp = 0.5, pan = 0, att = 0.01, rel = 0.45, sinfreq = 70, glissf = 0.9, doneAction = 2;
	var gliss = XLine.kr(sinfreq, sinfreq*glissf, rel);
	var snd = SinOsc.ar(gliss);
	var env = EnvGen.kr(Env.perc(att, rel), doneAction: doneAction);
	snd = snd * env * amp;
	snd = Limiter.ar(snd,1,0.001);
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

~kick3AwSynthDef = SynthDef(\kick3Aw, {arg out = 0, amp = 0.5, pan = 0, envL1 = 0, envL2 = 1, envL3 = 0.8, envL4 = 0, attack = 0.01, decay = 0.1, release = 0.2, punch = 1, envfLev1 = 400, envfLev2 = 66, enfTime = 0.08, envfCurve = -3, doneAction = 2;
	var freq, env, sig;
    freq = EnvGen.kr(Env([envfLev1, envfLev2], [enfTime], envfCurve));
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [attack, decay, release]), doneAction: doneAction);
	sig = Normalizer.ar(SinOsc.ar(freq, 0.5pi, punch).distort, 1) * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

~kicklaserbeamSynthDef = SynthDef(\kicklaserbeam, { arg out = 0, amp = 0.1, pan = 0.0, freq = 440, freqenvL1 = 4, freqenvL2 = 0.5, freqenvL3 = 1, freqenvL4 = 1, freqenvT1 = 0.01, freqenvT2= 0.01, freqenvT3= 1.0, ampenvL1 = 0, ampenvL2 = 1, ampenvL3 = 0.5, ampenvL4 = 0.0, ampenvT1 = 0.02, ampenvT2 = 0.2, ampenvT3 = 0.1, hpfFreq = 50, hpfRq = 1, doneAction = 2;
	var snd, freqenv, ampenv;
	// frequency envelope
	freqenv = EnvGen.ar(Env([freqenvL1, freqenvL2, freqenvL3, freqenvL4], [freqenvT1, freqenvT2, freqenvT3]));
	// amplitude envelope
	// no gate: fixed-time envelope, self-terminating.
	ampenv = EnvGen.ar(
		envelope: Env([ampenvL1, ampenvL2, ampenvL3, ampenvL4], [ampenvT1, ampenvT2, ampenvT3]),
		levelScale: amp,
		doneAction: doneAction);
	snd = LFTri.ar(freq * freqenv, 0, ampenv);
	snd = BHiPass4.ar(snd, hpfFreq, hpfRq);
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\tweetBassLeak, { arg out = 0, amp = 0.2, attack = 0.01, release = 1, att = 0.01, dec = 0.4, freq = 2, rq = 0.1, t_trig = 1, doneAction = 2;
	var sig, demand, env, globenv;
	demand = Demand.kr(
		t_trig,
		0,
		Drand([0.8, 1], inf)
	);
	env = Decay2.kr(
		demand,
		att,
		dec
	);
	sig = Saw.ar(freq, env) ** 1.5;
	sig = BRF.ar(sig, demand * 20 + [45.1, 45], rq);
	//globenv = EnvGen.kr(Env.linen(attack, 1, release), doneAction: doneAction);
	globenv = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = sig * globenv;
	sig = LeakDC.ar(sig).tanh;
	OffsetOut.ar(out, sig * amp);
}).add;

~tweetKickIntSynthDef = SynthDef(\tweetKickInt, { arg out = 0, amp = 1, attack = 0.01, release = 2, impfreq = 2, phRate = 64, lagFreq = 2, inAmt = 99, coef1 = 0.9, coef2 = 0.99, doneAction = 2;
	var sig, freq, phase, env, i;
	i = Impulse.ar(_);
	freq = i.(impfreq).lagud(0,0.4)*360;
	phase = Integrator.ar(
		Integrator.ar(
			i.(phRate).lag(LFNoise1.ar(lagFreq!2,2,2)) * inAmt,
			coef1
		),
		coef2
	).fold2(pi);
	env = EnvGen.kr(Env.linen(attack, 1, release), doneAction: doneAction);
	sig = SinOsc.ar(freq, phase, env);
	OffsetOut.ar(out, sig * amp);
}).add;

~kickParallaxSynthDef = SynthDef(\kickParallax, { arg out = 0, amp = 1, pan = 0, envAmpAtt = 0.01, envAmpRel = 0.3, envFrqAtt = 0, envFrqRel = 0.02, freq = 55, kharm1 = 1, kharm2 = 2, kharm3 = 3, kharm4 = 4, kamp1 = 0.05, kamp2 = 0.05, kamp3 = 0.05, kamp4 = 0.05, kring1 = 1, kring2 = 1, kring3 = 1, kring4 = 1, frqScale = 1, decScale = 1, resoMix = 0.5, doneAction = 2;
	var sig, env_amp, env_freq, kharm, kamp, kring, reso;

	env_amp  = Env.perc (envAmpAtt, envAmpRel - 0.01, amp);
	env_amp  = EnvGen.kr (env_amp, doneAction: doneAction);

	env_freq = Env.perc (envFrqAtt, envFrqRel, 1);
	env_freq = EnvGen.ar (env_freq);

	sig = SinOsc.ar (freq + (44100 ** env_freq), 0, env_amp);

	// harmonics
	kharm = [kharm1, kharm2, kharm3, kharm4];
    // amplitudes
	kamp = [kamp1, kamp2, kamp3, kamp4];
    // ring times
	kring = [kring1, kring2, kring3, kring4];

    //reso = Klank.ar(`[kharm, kamp, kring], sig, frqScale, decScale);
	reso = DynKlank.ar(`[kharm, kamp, kring], sig, frqScale, decScale);
	sig = SelectX.ar(resoMix, [sig, reso]);
	sig = Pan2.ar (sig, pan);

	OffsetOut.ar (out, sig);
}).add;

SynthDef(\kickParallax1, { arg out = 0, amp = 1, pan = 0, envAmpAtt = 0.01, envAmpRel = 0.3, envFrqAtt = 0, envFrqRel = 0.02, freq = 55, doneAction = 2;
	var sig, env_amp, env_freq;

	env_amp  = Env.perc (envAmpAtt, envAmpRel - 0.01, amp);
	env_amp  = EnvGen.kr (env_amp, doneAction: doneAction);

	env_freq = Env.perc (envFrqAtt, envFrqRel, 1);
	env_freq = EnvGen.ar (env_freq);

	sig = SinOsc.ar (freq * env_freq, 0, env_amp);
	sig = Pan2.ar (sig, pan);

	OffsetOut.ar (out, sig);
}).add;

~tabassSynthDef = SynthDef(\tabass, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 2, freq = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = LFTri.ar(freq);
	20.do{
		sig = BAllPass.ar(sig,80,1);
		sig = ((sig+0.02)*LFNoise0.kr(1/2)*6).tanh;
		sig = LeakDC.ar(sig,0.995);
	};
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\mcld, { arg out = 0, amp = 1, att = 0.01, rel = 2, impFreq = 10, hpfFreq = 440, gate = 1, doneAction = 2;
	var sig, env, input;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	input = LocalIn.ar.clip2(LFPulse.kr([1,2,1/8]).sum/2)**100*100;
	sig = DynKlank.ar(
		`[input],
		Impulse.ar(impFreq)
	);
	LocalOut.ar(sig);
	sig = HPF.ar(sig, hpfFreq).clip2;
	sig = Splay.ar(sig * env, amp);
	OffsetOut.ar(out, sig);
}).add;

~batuhanSynthDef = SynthDef(\batuhan, { arg out = 0, amp = 0.2, att = 0.01, rel = 5, eSawDec = 0.6, eSinL1 = 0, eSinL2 = 1, eSinL3 = 0, eSinL4 = 0.32, eSinT1 = 0.24, eSinT2 = 0.02, eSinT3 = 0.12, eSinC1 = (-4), eSinC2 = (-4), eSinC3 = (-4), sinFreq = 33, sawMix = 1, sawFreq = 8, bpfFreq = 162, bpfRq = 1, bpfMix = 0, brfFreq1 = 45.1, brfFreq2 = 45, brfRq = 1, doneAction = 2;
	var sig, env, trig, envSaw, envSin;
	trig = Impulse.kr(0);
	env = Linen.kr(trig, att, 1, rel, doneAction);
	envSaw = Decay2.kr(
		trig,
		0.01,
		eSawDec
	);
	envSin = EnvGen.kr(Env.new([eSinL1, eSinL2, eSinL3, eSinL4], [eSinT1, eSinT2, eSinT3], [eSinC1, eSinC2, eSinC3]), trig);
	sig = ((Saw.ar(sawFreq, envSaw) ** 1.5) * sawMix) + (SinOsc.ar(sinFreq, 0, envSin) * (1 - sawMix));
	sig = (sig * (1 - bpfMix)) + (BPF.ar(sig, bpfFreq, bpfRq.max(0.01)) * bpfMix);
	sig = BRF.ar(sig, trig * 20 + [brfFreq1, brfFreq2], brfRq.max(0.01));
	sig = Splay.ar(sig, levelComp: false);
	sig = LeakDC.ar(sig).tanh;
	sig = HPF.ar(sig, 28);
	//sig = (sig[0] + sig[1])!2; // mono
	OffsetOut.ar(out, sig * env * amp);
}).add;

SynthDef(\kicky,{ arg out = 0, amp=1, startFreq=80, endFreq=15, length=6, decay=4, lowpass=800, noiseAmp=0.0, gain=1, doneAction = 2;
	var sig, env, freq;
	freq = Line.kr(PinkNoise.kr(6,startFreq), PinkNoise.kr(3,endFreq), length, 1, 0);
	env = EnvGen.kr(Env.perc(0.014, length, 1, -5), 1, doneAction: doneAction);
	sig = {(LPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass) * amp) ! 2};
	sig = LPF.ar(sig,BrownNoise.kr(500,1500))*0.3;
	sig = sig * gain;
	sig = sig.softclip * amp * env;
	OffsetOut.ar(out, [sig,sig]);
}).add;

SynthDef(\kickey,{ arg out = 0, amp = 1, att = 0.0014, rel = 0.8, curve = (-5), startFreq = 60, endFreq = 10, linedur = 0.8, decay = 0.8, lowpass = 500, rq = 1, gain = 1, smoothLo = (-1), smoothHi = 1, foldRange = 1, smoothAmount = 0.5, doneAction = 2;
	var sig, env, freq;
	freq = XLine.kr(startFreq, endFreq, linedur, 1, 0);
	env = EnvGen.kr(Env.perc(att, rel, 1, curve), 1, doneAction: doneAction);
	sig = {(RLPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass, rq)) ! 2};
	sig = sig * gain;
	//sig = sig.softclip * amp * env;
	sig = SmoothFoldS.ar(sig, smoothLo, smoothHi, foldRange, smoothAmount) * amp * env;
	OffsetOut.ar(out, [sig,sig]);
}).add;

SynthDef(\kickBoomy, { arg out = 0, amp=1, atk = 0.0014, rel=0.4, curve = (-5), frq1 = 180, frq2 = 330, frq3 = 175, frq4 = 224, gain=1.1, doneAction = 2;
	var env, sig;
	env = EnvGen.kr(Env.perc(atk, rel, 1, curve), 1, doneAction: doneAction);
	sig = (SinOsc.ar(frq1/4) + SinOsc.ar(frq2/4) + LFTri.ar(frq3/4) + LFTri.ar(frq4/4) + BrownNoise.ar(0.1)) * env * amp;
	sig = LPF.ar(sig, 500);
	sig = sig + HPF.ar(EnvGen.ar(Env.perc(0.001,0.001,0.5)),500);
	sig = sig * gain;
	sig = sig.softclip * 1;
	OffsetOut.ar(out, [sig,sig]);
}).add;

SynthDef(\kick_oto309, { arg out=0, amp=0.5, pan=0, env0L1 = 0.5, env0L2 = 1, env0L3 = 0.5, env0L4 = 0, env0T1 = 0.005, env0T2 = 0.06, env0T3 = 0.26, env0Crv1 = (-4), env0Crv2 = (-2), env0Crv3 = (-4), env1L1 = 110, env1L2 = 59, env1L3 = 29, env1T1 = 0.005, env1T2 = 0.29, env1Crv1 = (-4), env1Crv2 = (-5), doneAction = 2;
	var env0, env1, env1m, son;

	env0 =  EnvGen.ar(Env.new([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3], [env0Crv1, env0Crv2, env0Crv3]), doneAction: doneAction);
	env1 = EnvGen.ar(Env.new([env1L1, env1L2, env1L3], [env1T1, env1T2], [env1Crv1, env1Crv2]));
	env1m = env1.midicps;

	son = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
	son = son + WhiteNoise.ar(1);
	son = LPF.ar(son, env1m*1.5, env0);
	son = son + SinOsc.ar(env1m, 0.5, env0);

	son = son * 1.2;
	son = son.clip2(1);

	OffsetOut.ar(out, Pan2.ar(son * amp));
}).add;

~kick_oto309BrSynthDef = SynthDef(\kick_oto309Br, { arg out = 0, amp = 0.5, pan = 0, envpL1 = 110, envpL2 = 59, envpL3 = 29, envpT1 = 0.01, envpT2 = 0.2, envL1 = 0.5, envL2 = 1, envL3 = 0.5, envL4 = 0, envT1 = 0.005, envT2 = 0.058, envT3 = 0.261, curve = -4,
	//Other Controls:
	filterHarmonic = 1.5, preamp = 1.25, pulseAmp = 0.5, noiseAmp = 1, sineAmp = 1,
	doneAction = 2;
	var env, envp, snd;

	env = Env.new(levels: [envL1, envL2, envL3, envL4], times: [envT1, envT2, envT3], curve: [curve, curve/2, curve]).kr(doneAction: doneAction);
	envp = Env.new(levels: [envpL1, envpL2, envpL3], times: [envpT1, envpT2], curve: [curve, curve * 1.25]).kr.midicps;

	snd = LFPulse.ar(freq: envp).range(-1 * pulseAmp, pulseAmp);
	snd = snd + WhiteNoise.ar(mul: noiseAmp);
	snd = LPF.ar(in: snd, freq: envp * filterHarmonic, mul: env);
	snd = snd + SinOsc.ar(freq: envp, phase: 0.5, mul: env * sineAmp);

	snd = Mix.ar(snd) * preamp;
	snd = snd.clip2(1) * amp;

	OffsetOut.ar(out, Pan2.ar(snd));
}).add;

~kickBlocksSynthDef = SynthDef(\kickBlocks, { arg out = 0, amp = 0.4, pan = 0, curve = -4,
	//tone1 arguments
	t1freq = 400, t1harmonic = 2, t1glide = 0.01,
	t1att = 0.0005, t1rel = 0.01, t1curve = -4, t1del = 0, t1amp = 1,
	//tone2 arguments
	t2freq = 50, t2harmonic = 3.44, t2glide = 0.01,
	t2att = 0.0001, t2rel = 0.3, t2curve = \lin, t2del = 0.005, t2amp = 1,
	//hit1 arguments
	h1freq = 100, h1harmonic = 8, h1glide = 0.01, h1rq = 0.6,
	h1att = 0.001, h1rel = 0.02, h1curve = -4, h1del = 0.001, h1amp = 1,
	//hit2 arguments
	h2freq = 1320, h2harmonic = 1, h2glide = 0,
	h2att = 0.003, h2rel = 0.03, h2curve = -4, h2del = 0, h2amp = 0.5,
	//click arguments
	cfreq = 6100, crq = 1, camp = 1.41,
	doneAction = 2;

    var env, snd, noise, tone1, tone2, hit1, hit2, click;

	env = EnvGen.kr(Env.linen(0.01, 1, 6), doneAction: doneAction);
	noise = Hasher.ar(Sweep.ar); //deterministic white noise

    tone1 = SinOsc.ar(
		freq: XLine.ar(start: t1freq * t1harmonic, end: t1freq, dur: t1glide),
		mul: Env.perc(attackTime: t1att, releaseTime: t1rel, level: t1amp, curve: t1curve).delay(t1del).ar);

	tone2 = SinOsc.ar(
		freq: XLine.ar(start: t2freq * t2harmonic, end: t2freq, dur: t2glide),
		mul: Env.perc(attackTime: t2att, releaseTime: t2rel, level: t2amp, curve: t2curve).delay(t2del).ar);

    hit1 = BPF.ar(
		in: noise,
		freq: XLine.ar(start: h1freq * h1harmonic, end: h1freq, dur: h1glide),
		rq: h1rq,
		mul: Env.perc(attackTime: h1att, releaseTime: h1rel, level: h1amp, curve: h1curve).delay(h1del).ar);

	hit2 = HPF.ar(
		in: noise,
		freq: XLine.ar(start: h2freq * h2harmonic, end: h2freq, dur: h2glide),
		mul: Env.perc(attackTime: h2att, releaseTime: h2rel, level: h2amp, curve: h2curve).delay(h2del).ar);

	click = BPF.ar(
		in: Impulse.ar(0) * SampleRate.ir / 44100,
		freq:  cfreq,
		rq: crq,
		mul: camp);

	snd = Mix.ar(tone1 + tone2 + hit1 + hit2 + click).tanh * amp;

	//DetectSilence.ar(in: snd, doneAction: doneAction);

	OffsetOut.ar(out, Pan2.ar(snd * env, pan));
}).add;

~ringkickSynthDef = SynthDef(\ringkick, { arg out = 0, amp = 0.2, attack = 0.01, decay = 0.25, lpfFreq = 1000, freq = 40, envfL1 = 34, envfL2 = 20, envfL3 = 0.1, envfL4 = 20, envfL5 = 0, envfT1 = 0.2, envfT2 = 1, envfT3 = 0.9, envfT4 = 0.14, curve = (-4), envfAmt = 0, lfnFrq = 230, lfnAmt = 100, ringAmp = 0.04, sawFreq = 0, sawPh = pi, sawDecDiv = 1, sawAmp = 0, sinFreq = 18000, sinFb = 1.2, sinDecDiv = 16, sinAmp = 0.5, doneAction = 2;
	var snd, env, trig, envf, mod;
	mod = LFNoise2.kr(lfnFrq, lfnAmt).range(1, lfnAmt);
	env = EnvGen.kr(Env.linen(attack, 1, decay), doneAction: doneAction);
	envf = EnvGen.kr(Env([envfL1, envfL2, envfL3, envfL4, envfL5], [envfT1, envfT2, envfT3, envfT4], [curve, curve/2, curve]), levelScale: envfAmt * mod);
	trig = Impulse.ar(0);
	snd = Ringz.ar(
		in: LPF.ar(
			in: trig,
			freq: lpfFreq
		),
		freq: freq * envf.range(1, envfAmt), /*+ (freq * envf)*/
		decaytime: decay,
		mul: 7 * ringAmp
	).tanh.sin*2;

	snd = snd + SawDPW.ar(sawFreq, sawPh, Decay.ar(trig, decay / sawDecDiv) * sawAmp);

	snd = snd + SinOscFB.ar(sinFreq * envf.range(1, envfAmt), sinFb, Decay.ar(trig, decay / sinDecDiv) * sinAmp);

	snd = (snd * env) ! 2;
	OffsetOut.ar(out, snd * amp);
}).add;

~kickRingzSynthDef = SynthDef(\kickRingz, { arg out = 0, amp = 1, pan = 0, envL1 = 0.1, envL2 = 1.2, envL3 = 3, envL4 = 2.1, envL5 = 0.1, envT1 = 0.1, envT2 = 0.2, envT3 = 0, envT4 = 0.1, curve = (-4), envpL1 = 0.1, envpL2 = 1.2, envpL3 = 3, envpL4 = 2.1, envpT1 = 0.1, envpT2 = 0, envpT3 = 1.2, curvep = (-4), freq = 40, decay = 0.25, ffreq = 1000, doneAction = 2;
	var snd, env, envp;

	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4], [curve, curve/2, curve]), doneAction: doneAction);
	envp = EnvGen.kr(Env([envpL1, envpL2, envpL3, envpL4], [envpT1, envpT2, envpT3], [curvep, curvep*1.25, curvep].midicps));
	snd = Ringz.ar(
		    in: LPF.ar(in: Impulse.ar(0), freq: ffreq),
		    freq: freq * envp,
		    decaytime: decay,
		    mul: amp
	);

	snd = snd.tanh.sin * 2 * env;

	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\kick_chirp, { arg out = 0, amp = 0.1, pan = 0, curve = -20, att = 0.001, rel = 0.5, maxFreq = 500, doneAction = 2;
    var env, snd;

	env = Env.perc(attackTime: att, releaseTime: rel, curve: curve).exprange(0, maxFreq).kr(doneAction: doneAction);

    snd = SinOsc.ar(freq: env, mul: amp);
    snd = LeakDC.ar(snd);

	OffsetOut.ar(out, Pan2.ar(snd, pan))
}).add;

~kick_electroSynthDef = SynthDef(\kick_electro, { arg out = 0, amp = 0.3, pan = 0, att = 0.01, rel = 0.3, envbfL1 = 261, envbfL2 = 120, envbfL3 = 51, envbfRel = 0.003, envbfC = (-4), envbaL1 = 0, envbaL2 = 1, envbaL3 = 0.1, envbaL4 = 0.8, envbaL5 = 0, envbaT1 = 0.2, envbaT2 = 0.1, envbaT3 = 0.03, envbaT4 = 0.2, envbaC1 = (-4), envbaC2 = (-4), envbaC3 = (-4), envbAmp = 1, pfSt = 750, pfEnd = 261, pfDur = 0.02, envpaL1 = 0, envpaL2 = 0.4, envpaL3 = 1, envpaL4 = 0.02, envpaL5 = 0, envpaT1 = 0.1, envpaT2 = 0.4, envpaT3 = 0.03, envpaT4 = 0.2, envpaC1 = (-4), envpaC2 = (-4), envpaC3 = (-4), envpAmp = 1, envcaAtt = 0, envcaRel = 0.2, envcAmp = 1, cFundFreq = 910, cFormFreq = 4760, cBwFreq = 2110, lpfFreq = 3140, doneAction = 2;
    var env, body, bodyFreq, bodyAmp, pop, popFreq, popAmp, click, clickAmp, snd;

	env = EnvGen.kr(Env.linen(att, 1, rel), doneAction: doneAction);

    // body starts midrange, quickly drops down to low freqs, and trails off
    bodyFreq = Env.new(
		    levels: [envbfL1, envbfL2, envbfL3],
		    times: [envbfRel / 8.57, envbfRel / 3.75],
		    curve: envbfC
	).kr;

	bodyAmp = Env.new(
		[envbaL1, envbaL2, envbaL3, envbaL4, envbaL5],
		[envbaT1, envbaT2, envbaT3, envbaT4],
		[envbaC1, envbaC2, envbaC3]
	).kr(levelScale: envbAmp);

    body = SinOsc.ar(freq: bodyFreq, mul: bodyAmp);

    // pop sweeps over the midrange
    popFreq = XLine.kr(start: pfSt, end: pfEnd, dur: pfDur);

	popAmp = Env.new(
		[envpaL1, envpaL2, envpaL3, envpaL4, envpaL5],
		[envpaT1, envpaT2, envpaT3, envpaT4],
		[envpaC1, envpaC2, envpaC3]
	).kr(levelScale: envpAmp);

    pop = SinOsc.ar(freq: popFreq, mul: popAmp);

    // click is spectrally rich, covering the high-freq range
    // you can use Formant, FM, noise, whatever
	clickAmp = Env.perc(
		attackTime: envcaAtt,
		releaseTime: envcaRel,
		level: envcAmp
	).kr;

	click = LPF.ar(
		in: Formant.ar(fundfreq: cFundFreq, formfreq: cFormFreq, bwfreq: cBwFreq, mul: clickAmp),
		freq: lpfFreq
	);

	//Putting it all together:
	snd = Mix.ar([body, pop, click]);
    snd = snd.tanh * env;

    OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\kik3Br, { arg out = 0, amp = 1, pan = 0, freq = 66, att = 0.01, dec = 0.1, decaylevel = 0.8, rel = 0.3, envCurve = -4, sweeptime = 0.08, sweepCurve = \exp, harmonic = 6, preamp = 3;
	var snd, env, fenv;

	env = Env.new(levels: [0, amp, decaylevel * amp, 0], times: [att, dec, rel], curve: envCurve).kr(doneAction: 2);

	fenv = Env.new(levels: [freq * harmonic, freq], times: [sweeptime], curve: sweepCurve).kr;

	snd = SinOsc.ar(freq: fenv, mul: preamp).distort;

    snd = Normalizer.ar(in: snd, level: env);

	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

~sosKickSynthDef = SynthDef(\sosKick, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 1, subamp = 1, drumAmp = 1, beaterAmp = 0.02, clickAmp = 1,
	// sub controls
	startsubfreq = 60, endsubfreq = 32, linesubdur = 0.08, subdecay = 0.2, sublowpass = 500,
	// drum controls
	drumFreq = 50, drumHarmonic = 2, drumSweep = 0.02, drumAtt = 0.005, drumRel = 0.4, curve = (-4),
	drumFilter = 1000, modIndex = 6.5, modFreq = 5,
	// beater controls
	beaterFreq = 500, beaterHarmonic = 12, beaterSweep = 0.03, noiseMod = 500, beaterL1 = 0, beaterL2 = 1, beaterL3 = 2.4, beaterL4 = 0, beaterT1 = 0.01, beaterT2 = 0.3, beaterT3 = 0.08,
	// click controls
	clkffreq = 500, clkres = 0,
	t_trig = 1, doneAction = 2;

	var subfreq, sub, drumEnv, drumContour, drum, beaterContour, beaterEnv, beater, snd, click, envClick;

	subfreq = XLine.kr(startsubfreq, endsubfreq, linesubdur, 1, 0);

	sub = LPF.ar(Ringz.ar(Impulse.ar(0), subfreq, subdecay), sublowpass) * subamp;

	drumEnv = Env.perc(attackTime: drumAtt, releaseTime: drumRel, curve: curve).kr;

	sub = sub * drumEnv;

	drumContour = Line.kr(start: drumFreq * drumHarmonic, end: drumFreq, dur: drumSweep);

	drum = PMOsc.ar(
		carfreq: drumContour,
		modfreq: modFreq,
		pmindex: modIndex,
		mul: drumAmp
	);

	drum = LPF.ar(in: drum, freq: Lag2.kr(drumFilter), mul: drumEnv);

	beaterEnv = Env([beaterL1, beaterL2, beaterL3, beaterL4], [beaterT1, beaterT2, beaterT3]).kr;

	beaterContour = Line.kr(start: (beaterFreq * beaterHarmonic).min(20000), end: beaterFreq, dur: beaterSweep);

	beater = HPF.ar(in: WhiteNoise.ar(LFNoise0.kr(noiseMod)), freq: beaterFreq);

	beater = LPF.ar(in: beater, freq: beaterContour, mul: beaterEnv) * beaterAmp;

	envClick = EnvGen.kr(Env.step([700, 0], [0.0007, 0.1]), t_trig, 0.002);
	click = Hasher.ar(Sweep.ar(t_trig, 0.000001)) * envClick;
	click = MoogLadder.ar(click, clkffreq, clkres) * EnvGen.kr(Env.perc(0.0001, 0.00001), t_trig, clickAmp);

	snd = Mix.ar(sub + drum + beater + click) * amp;

	snd = snd * EnvGen.kr(Env.asr(att, 1, rel), t_trig, doneAction: doneAction);
    //DetectSilence.ar(in: snd, doneAction: doneAction);

    OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

~technokickSynthDef = SynthDef(\technokick, {
	| out=0, amp=0.5, attack = 0.01, release = 6, freq=51.913087197493, rel=0.28571428571429, click=0.008, spread=0.1, damp=0.6, gate=1, doneAction = 2 |
	var sig, env, env1, aEnv, env2, wEnv, vEnv, low, high, dry, verb, verbHi, verbLo;
	// env.ar is really good for this since thie envelopes are so short
	env = EnvGen.kr(Env.linen(attack, 1, release), doneAction: doneAction);
	env1 = EnvGen.ar(Env.adsr(0,0.1,0,0, curve: -4, bias: 1)); // initial attack
	env2 = EnvGen.ar(Env.adsr(0,click,0,0,32, bias:1)); // click adder
	aEnv = EnvGen.kr(Env.perc(0.005, rel/1.75, curve: 2)); // amplitude
	wEnv = EnvGen.ar(Env.adsr(0,0.01,0,0, curve: -4));

	vEnv = EnvGen.kr(Env.adsr(rel, rel/2, 1, 0.01, curve: 3), gate); // for reverb
	// separate signals for extra processing
	low  = SinOsc.ar(freq * env1 * env2);
	high = WhiteNoise.ar() * wEnv * 0.6;
	high = BBandPass.ar(high, 1000, 2);
	dry = Mix.new([low, high]) * aEnv;
	dry = CrossoverDistortion.ar(dry * 0.3, 0.9, 1);
	// dry = dry * 0.25;
	// equalizer
	dry = BPeakEQ.ar(dry, 5500, db: 10);
	dry = BPeakEQ.ar(dry, 360, db: -12, rq: 2);
	dry = BLowShelf.ar(dry, 300, db: 6).distort;
	// compression
	dry = Compander.ar(dry, dry, thresh: 0.5,
		slopeBelow: 1.75, slopeAbove: 0.75,
		clampTime: 0.002, relaxTime: 0.1, mul: 5);
	// finalize dry signal
	dry = Pan2.ar(dry * aEnv);
	// create reverb signal
	// verb = FreeVerb2.ar(dry[0],dry[1],mix: 1,room: 1, damp: 1).distort * vEnv;
	verb = GVerb.ar(dry, roomsize: 10, revtime: 5,
		damping: damp, drylevel: 0, earlyreflevel: 0.5, taillevel: 1,
		maxroomsize: 100, mul: 1) ;
	// Sum the double stereo output into a single stereo one
	verb = verb.sum;
	// eq

	verb = BLowPass.ar(verb, 400+freq,2);

	// Reduce stereo spread, and balance audio to be level no matter the spread (more or less)
	verbHi = BHiPass.ar(verb, 200);
	verbHi = Balance2.ar(verbHi[0] + (verbHi[1] * spread), // left
		verbHi[1] + (verbHi[0] * spread), level: 0.5 + (1-spread)); // right
	// Keep low frequencies in mono
	verbLo = BLowPass.ar(verb, 200);
	verbLo = Balance2.ar(verbLo[0] + verbLo[1], verbLo[1] + verbLo[0], level: 0.5);
	verb = verbHi + verbLo;
	verb = Compander.ar(verb,verb, thresh: 0.5,
		slopeBelow: 1.75, slopeAbove: 0.75,
		clampTime: 0.002, relaxTime: 0.1, mul: 0.25) * vEnv;
	// finalize signals
	sig = dry + verb;
	sig = Compander.ar(sig,sig, thresh: 0.5,
		slopeBelow: 0.59, slopeAbove: 1,
		clampTime: 0.002, relaxTime: 0.1, mul: 1)!2;
	OffsetOut.ar(out, sig * env * amp);
}).add;

SynthDef(\rc808Kick, {
    arg out = 0, pan = 0, decay = 30, amp = 2, gate = 0, tone = 56, doneAction = 2;
    var fenv, env, trienv, sig, sub, punch, pfenv;
    env = EnvGen.kr(Env.new([0.11, 1, 0], [0, decay], -225), doneAction:2);
    trienv = EnvGen.kr(Env.new([0.11, 0.6, 0], [0, decay], -230), doneAction:0);
    fenv = Env([tone*7, tone*1.35, tone], [0.05, 0.6], -14).kr;
    pfenv = Env([tone*7, tone*1.35, tone], [0.03, 0.6], -10).kr;
    sig = SinOsc.ar(fenv, pi/2) * env;
    sub = LFTri.ar(fenv, pi/2) * trienv * 0.05;
    punch = SinOsc.ar(pfenv, pi/2) * env * 2;
    punch = HPF.ar(punch, 350);
    sig = (sig + sub + punch) * 2.5;
    sig = Limiter.ar(sig, 0.5) * amp;
    sig = Pan2.ar(sig, pan);
    OffsetOut.ar(out, sig);
}).add;

///////////////////////////////////////  Snare

~sdSynthDef = SynthDef(\sd, { | out = 0, amp = 1, att = 0, rel = 0.05, freq = 200, ffreq = 12000 |
	var osc1, osc2, env;
	osc1 = WhiteNoise.ar;
	osc2 = FSinOsc.ar(freq);
	env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
	OffsetOut.ar(out, Pan2.ar(LPF.ar(Mix([osc1, osc2]), ffreq), 0, env*amp));
}).add;

SynthDef(\snare, { arg out=0, amp=0.1, pan = 0, tu=1, t_gate=1, freq=200, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env.perc(0.01,0.1));
	var enf = EnvGen.ar(Env([600,1057,230],[0.01,0.01],-4));
	sig = SinOsc.ar(tu*enf+127,0,0.5)*env;
	sig = WhiteNoise.ar+sig;
	sig = RHPF.ar(sig, \hpf.kr(170)*tu, \rq.kr(0.5));
	sig = sig + Mix.ar(BPF.ar(sig,[327,430],[0.5,0.5])*0.1);
	sig = RLPF.ar(sig, \lpf.kr(15100)*tu, \rq.kr(0.5));
	sig = sig * EnvGen.ar(Env.perc(0.01,\rel.kr(0.1),-4),t_gate,doneAction: doneAction);
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

~snarenewSynthDef = SynthDef(\snarenew, { arg out = 0, amp = 0.1, pan = 0, tu = 1, envpL1 = 110, envpL2 = 59, envpL3 = 29, envpT1 = 0.01, envpT2 = 0.2, curvep = (-4), envL1 = 0.5, envL2 = 1, envL3 = 0.5, envL4 = 0, envT1 = 0.005, envT2 = 0.058, envT3 = 0.261, curve = (-4), mixNoise = 0.5, hpf = 80, rqhpf = 0.8, freq1bpf = 527, freq2bpf = 530, rq1bpf = 0.5, rq2bpf = 0.5, lpf = 100, rqlpf = 0.8, mixBpf = 0.1, doneAction = 2;
    var sig, env, envp;
    /*var env = EnvGen.ar(Env.perc(0,0.8));
    var enf = EnvGen.ar(Env([16000,57,15000,11188.8],[0.001,0.001,0.0001],-4));*/
	env = Env.new(levels: [envL1, envL2, envL3, envL4], times: [envT1, envT2, envT3], curve: [curve, curve/2, curve]).kr(doneAction: doneAction);
	envp = Env.new(levels: [envpL1, envpL2, envpL3], times: [envpT1, envpT2], curve: [curvep, curvep * 1.25]).kr.midicps;
    sig = SinOsc.ar(tu*envp,0,0.5)*env;
	sig = ((PinkNoise.ar*env) * mixNoise) + (sig * (1 - mixNoise));
    sig = RHPF.ar(sig, hpf*tu, rqhpf);
	sig = (Mix.ar(BPF.ar(sig,[freq1bpf, freq2bpf],[rq1bpf, rq2bpf])) * mixBpf) + (sig * (1 - mixBpf));
    sig = RLPF.ar(sig, lpf, rqlpf);
    // sig = sig * EnvGen.ar(Env.perc(0,\rel.kr(1),4,-8),t_gate, doneAction: doneAction);
    //sig = DelayL.ar(sig,0.05,0.001)+sig;
    //sig = DelayL.ar(sig,0.05,0.01)+sig;
    //sig = DelayL.ar(sig,0.1,0.1)+sig;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\snare2,{arg t_trig = 1, amp=1, out=0, pan = 0;
	var env = EnvGen.ar(Env.perc(0.001,0.2),t_trig,doneAction:2);
	var freq = EnvGen.ar(Env([12000,100,12000],[0.01,0.01]));
	var sig = WhiteNoise.ar(env);
	sig = LPF.ar(sig,freq);
	sig = sig.tanh;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp) );
}).add;

SynthDef(\snare2new, { arg out = 0, amp = 0.1,  pan = 0, tu = 1, t_gate = 1, envAtt = 0.1, envRel = 0.1, enfL1= 1600, enfL2 = 177, enfL3 = 190, enfT1 = 0.01, enfT2 = 0.1;
    var sig;
    var env = EnvGen.ar(Env.perc(envAtt,envRel));
    var enf = EnvGen.ar(Env([enfL1,enfL2,enfL3],[enfT1,enfT2],-4));
    var sig2 = BrownNoise.ar(1);
    sig = SinOsc.ar(tu*enf+27,0,0.1)*env;
    sig = WhiteNoise.ar(0.6)+sig+(LPF.ar(sig2,250,0.5)*env);
//    sig = RHPF.ar(sig, \hpf.kr(100)*tu, \rq.kr(1));
//    sig = sig + Mix.ar(BPF.ar(sig,[1207,4300],[0.5,0.5])*0.1);
    //sig = RLPF.ar(sig, \lpf.kr(11000)*tu, \rq.kr(1));
    //sig = CombL.ar(sig,0.2,0.1);
    sig = BRF.ar(sig,450,0.3);
    sig = HPF.ar(sig,250);
    sig = sig * EnvGen.ar(Env.perc(0.02,\rel.kr(0.4),-4),t_gate,doneAction:2);
    //sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

~jungleSnareSynthDef = SynthDef(\jungleSnare, { arg out = 0, amp = 0.1, pan = 0, envL1 = 1, envL2 = 0, envL3 = 1, envL4 = 0, envT1 = 0, envT2 = 0.004, envT3 = 0.05, envCurve = \linear, envfL1 = 1600, envfL2 = 5600, envfL3 = 800, envfL4 = 250, envfT1 = 0.001, envfT2 = 0.001, envfT3 = 0.001, envfCurve = (-4), envnAtt = 0.01, envnRel = 1, envnCurve = -4, noiseAmp = 1, tu = 1, kracter = 10, t_gate = 1, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), t_gate, doneAction: doneAction);
	var envf = EnvGen.ar(Env([envfL1, envfL2, envfL3, envfL4],[envfT1, envfT2, envfT3], envfCurve));
	var envn = EnvGen.ar(Env.perc(envnAtt, envnRel), 1, envnCurve);
	sig = SinOsc.ar(tu*envf+107,0,0.5)*env;
	sig = (WhiteNoise.ar(envn) * noiseAmp) + sig;
	sig = RHPF.ar(sig, \hpf.kr(100)*tu, \hpfRq.kr(1));
	sig = sig + Mix.ar(BPF.ar(sig,[327,430],[0.5,0.5])*0.1)+ (WhiteNoise.ar(envn)+BrownNoise.ar(envn/8) * noiseAmp);
	sig = RLPF.ar(sig, \lpf.kr(11100)*tu, \lpfRq.kr(0.5));
	sig =( Ringz.ar(WhiteNoise.ar,Mix.ar([envf,envf*0.9,envf*0.8]),1,0.01*env) +RLPF.ar(BrownNoise.ar(envn) * noiseAmp,envf*4,1,1)+sig )*envn ;
	sig = CompanderD.ar(sig*kracter,0.8,0.3,0.5,0.001,0.2,env);
	sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\t5snare, { arg out=0, amp=0.3, pan=0, tu=1, freq=200, t_gate=1, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env.perc(0.01,1));
	var enf = EnvGen.ar(Env([600,177,230],[0.01,0.1],-4));
	//sig = SinOsc.ar(tu*enf+1207,0,0.5)*env;
	sig = WhiteNoise.ar;
	sig = FreeVerb.ar(sig,0.5,1);
	sig = RHPF.ar(sig, \hpf.kr(180)*tu, \hpfRq.kr(0.5));
	sig = sig + Mix.ar(BPF.ar(sig,[127,430],[0.5,0.5])*0.1);
	sig = RLPF.ar(sig, \lpf.kr(12100)*tu, \lpfRq.kr(0.5));
	sig = sig * EnvGen.ar(Env.perc(0,\rel.kr(1),-4),t_gate,doneAction: doneAction);
	sig = sig*amp;
	sig = CompanderD.ar(sig,1,1,0.1,0.01,0.4);
	sig = FreeVerb.ar(sig,1,1)+sig;
	sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\snare808, { arg out=0,tu=1, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var env = EnvGen.ar(Env.perc(0.01,1));
	var enf = EnvGen.ar(Env([600,177,230],[0.01,0.01],-4));
	sig = SinOsc.ar(tu*enf+127,0,0.5)*env;
	sig = WhiteNoise.ar+sig;
	sig = RHPF.ar(sig, \hpf.kr(170)*tu, \rq.kr(0.5));
	sig = sig + Mix.ar(BPF.ar(sig,[127,430],[0.5,0.5])*0.1);
	sig = RLPF.ar(sig, \lpf.kr(11100)*tu, \rq.kr(0.5));
	sig = sig * EnvGen.ar(Env.perc(0.01,\rel.kr(0.1),-4),gate,doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

~snaremedSynthDef = SynthDef(\snaremed, { | out = 0, level = 1, pan = 0, noise = 1, dc = 1, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, relEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1 = 0.1, env1T2 = 0.2, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase = 0, oamp = 0.1, owhich2 = 0, ochoose = 0, doneAction = 2|
	var env0,env1,
	env1m, son, son2,son3,son4,p2;
	p2 = phase * (-pi);
	env0 = Env([env0L1,env0L2,env0L3,env0L4,0],[atkEnv0,decEnv0,relEnv0],[curve1, curve2, curve3]);
	env1 = Env([env1L1,env1L2,env1L3],[env1T1,env1T2],[curve1, curve2, curve3]);

	env0 = EnvGen.ar(env0, doneAction: doneAction);
	env1 = EnvGen.ar(env1);
	env1m = env1.midicps;
	son = LFSaw.ar(env1m,0,oamp, 1,1.4);//*LFSaw.ar(100).distort;
	son2 = SinOsc.ar(env1m,0, oamp, 1,1.4);
	son3 = LFPulse.ar(env1m,0, oamp, 1,1.4);
	son4 = LFTri.ar(env1m,0, oamp, 1,1.4);

	son = SelectX.ar(ochoose,[son,son2,son3,son4]);
	son = LeakDC.ar(son,dc,30);
	son = son ;
	son = HPF.ar(son, 100, env0);
	son = son + SelectX.ar(owhich2,[ SinOsc.ar(env1m, phase, env0), LFSaw.ar(env1m, phase, env0), LFPulse.ar(env1m, phase, env0), LFTri.ar(env1m, phase, env0)]);
	son =  HPF.ar(son +BrownNoise.ar(env0/2*noise)+WhiteNoise.ar(env0*noise),fratio);
	//son = son.clip2(1);

	son = Limiter.ar(son,1);
	son = son * level.distort;

	OffsetOut.ar(out, Pan2.ar(son, pan, level)).tanh;
	//OffsetOut.ar(snd, son*level).tanh;
}).add;

SynthDef(\snareAw, {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
	var snd1 = WhiteNoise.ar(amp);
	var snd2 = SinOsc.ar(sinfreq,0,amp);
	var env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
	var sum = HPF.ar(snd1, ffreq) + snd2;
	OffsetOut.ar(out, Pan2.ar(sum * env, pan));
}).add;

SynthDef(\snarey,{ arg out = 0, amp=0.25, attack = 0.001, release = 0.3, freq=120, gain=0.5, doneAction = 2;
	var env, sig, snare;
	env = EnvGen.kr(Env.perc(attack, release, 1, -9), 1, doneAction: doneAction);
	sig = {(SinOsc.ar(freq) - WhiteNoise.ar(0.5, 0.5))!2};
	sig = sig * gain;
	sig = sig.softclip * amp * env;
	OffsetOut.ar(out, [sig,sig]);
}).add;

SynthDef(\snary,{ arg out = 0, amp=0.75, att = 0.001, rel = 0.1, curve = (-5), freq=120, gain=1, doneAction = 2;
	var env, sig, snare;
	env = EnvGen.kr(Env.perc(att, rel, 1, curve), 1, doneAction: doneAction);
	sig = (SinOsc.ar(freq) - WhiteNoise.ar(0.5, 0.5)) * env * amp;
	sig = sig * gain * 0.4;
	sig = sig.softclip * amp;
	OffsetOut.ar(out, [sig,sig]);
}).add;

SynthDef(\kraftySnare, { arg out = 0, amp = 1, pan = 0, freq = 6000, rq = 3, att = 0.01, dec = 0.2, curve = -6, doneAction = 2;
	var snd, env;

	env = Env.perc(attackTime: att, releaseTime: dec, curve: curve).kr(doneAction: doneAction);

	snd = PinkNoise.ar(amp);

	snd = BPF.ar(snd, freq, rq, env);

	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\neuroSnare, { arg out = 0, amp = 0.1, pan = 0, freq = 160, curve = -4, preamp = 1.4,
	//Click Controls
	clickatt = 0.001, clicksus = 0.01, clickrel = 0.001, clickamp = 1, hipass = 300, lopass = 8000,
	//Body Controls
	bodyatt = 0.04, bodyrel = 0.2, bodyamp = 2,
	//Rattle Controls
	rattlehold = 0.01, rattleatt = 0.05, rattlerel = 0.2, rattleamp = 0.7, rattlefreq = 4000, rq = 0.5, rattlepeak = 3,
	//Sweep Controls
	sweepatt = 0.001, sweeprel = 0.02, sweepamp = 1, sweepstart = 3000, sweepend = 1500,
	doneAction = 2;

    var snd, click, cEnv, body, bEnvFreq, bEnvAmp, rattle, rEnv, sweep, sEnvFreq, sEnvAmp;

    // a percussive click to give it some attack
	cEnv = Env.linen(
		            attackTime: 0.001,
		            sustainTime: 0.01,
		            releaseTime: 0.001,
			        level: clickamp
	            ).ar;

	click = Hasher.ar(Sweep.ar);

	click = HPF.ar(in: click, freq: hipass);

    click = LPF.ar(in: click, freq: lopass);

	click = click * cEnv;

    // sine sweep body
	bEnvFreq = Env.new(
			        levels: [2.5, 1.225, 1],
			        times: [bodyatt, bodyrel],
			        curve: \exp
	            ).ar;

	bEnvAmp = Env.perc(
		            attackTime: bodyatt,
		            releaseTime: bodyrel,
		            level: bodyamp,
		            curve: curve
	            ).ar;

	body = SinOsc.ar(freq: freq * bEnvFreq, mul: bEnvAmp);

	body = body.tanh;

    // sound of snare coils rattling
	rEnv = Env.perc(
			        attackTime: rattleatt,
			        releaseTime: rattlerel,
			        level: rattleamp,
			        curve: curve
	            ).delay(rattlehold).ar;

	rattle = Hasher.ar(Sweep.ar);

	rattle = BPeakEQ.ar(in: rattle, freq: rattlefreq, rq: rq, db: rattlepeak);

	rattle = HPF.ar(in: rattle, freq: hipass);

	rattle = rattle * rEnv;

    // another sound sweep to improve the attack, optional
	sEnvFreq = XLine.kr(
		    	    start: sweepstart,
		    	    end: sweepend,
		    	    dur: sweeprel / 2
	            );

	sEnvAmp = Env.perc(
			        attackTime: sweepatt,
			        releaseTime: sweeprel,
			        level: sweepamp,
			        curve: curve
	            ).ar;

	sweep = SinOsc.ar(freq: sEnvFreq, mul: sEnvAmp);

    // distortion helps glue everything together and acts as a compressor
	snd = Mix.ar(click + body + rattle + sweep);

	snd = (snd * preamp).tanh * amp;

	DetectSilence.ar(in: snd, doneAction: doneAction);

	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\snare909, { arg out = 0, amp = 0.5, pan = 0, freq = 85, att = 0.0005, curve = -2, toneRel = 0.075, toneAmp = 0.25, noiseRel = 0.4, noiseAmp = 0.2, nyquist = 2200, lpFreq = 7040, hpFreq = 523, doneAction = 2;
	var relTimes, env, tone, noise, snd;

	relTimes = ([1, 0.733] * toneRel) ++ ([1, 0.708] * noiseRel);

	env = Env.perc(attackTime: att, releaseTime: relTimes, level: amp, curve: curve).kr;

	tone = LFTri.ar(freq: [1, 1.78] * freq, mul: toneAmp);

	noise = Latch.ar(WhiteNoise.ar, Impulse.ar(nyquist * 2));

	noise = LPF.ar(in: noise, freq: lpFreq, mul: noiseAmp);

	snd = tone ++ [noise, HPF.ar(in: noise, freq: hpFreq)];

	snd = Mix.ar(snd * env);

	DetectSilence.ar(in: snd, doneAction: doneAction);

    OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\snareElectro, { arg out = 0, amp = 0.4, pan = 0, att = 0.001, rel = 0.15, curve = -4, popfreq = 160, sweep = 0.01, noisefreq = 810, rq = 1.6, blend = 0.41, doneAction = 2;
    var pop, popEnv, popSweep, noise, noiseEnv, snd;

    // pop makes a click coming from very high frequencies
    // slowing down a little and stopping in mid-to-low
    popSweep = Env.new(levels: [20.4, 2.6, 1] * popfreq, times: [sweep / 2, sweep], curve: \exp).ar;

    popEnv = Env.perc(attackTime: att, releaseTime: 0.73 * rel, level: blend, curve: curve).kr;

	pop = SinOsc.ar(freq: popSweep, mul: popEnv);

    // bandpass-filtered white noise
    noiseEnv = Env.perc(attackTime: att, releaseTime: rel, level: 1 - blend, curve: curve).kr(doneAction: doneAction);

	noise = BPF.ar(in: WhiteNoise.ar, freq: noisefreq, rq: rq, mul: noiseEnv);

    snd = Mix.ar(pop + noise) * amp;

    OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

~snareSteinSynthDef = SynthDef(\snareStein, { arg out = 0, amp = 1, pan = 0, att = 0.0005, curve = -4, tonerel = 0.075, noiserel = 0.2,
	//Other Controls, blend ranges from 0 to 1.
	noisetop = 7040, noisebottom = 523, noiseamp = 0.2, tonelo = 185, tonehi = 330, toneamp = 0.5, blend = 0.2,
	doneAction = 2;

    var env, tone, noise, snd;

	env = EnvGen.kr(Env.linen(0.01, 1, 2), doneAction: doneAction);
	//Sines for the frequency of the drum:
    tone = SinOsc.ar(freq: [tonelo, tonehi]);

	tone = tone * Env.perc(
		                attackTime: att,
		                releaseTime: [tonerel, 0.73 * tonerel],
		                level: toneamp,
		                curve: curve
	                ).kr;

	//Noise for the rattling of the snares: (original used WhiteNoise alone)
	noise = PinkNoise.ar(noiseamp * (1 - blend)) + WhiteNoise.ar(noiseamp * blend);

	noise = LPF.ar(in: noise, freq: noisetop);

	snd = noise * Env.perc(
		                attackTime: att,
		                releaseTime: noiserel,
		                curve: curve
	                ).kr;

	snd = snd +	HPF.ar(
		            in: noise,
		            freq: noisebottom,
		            mul: Env.perc(
			                    attackTime: att,
			                    releaseTime: 0.915 * noiserel,
			                    curve: curve
			                ).kr
	            );

	//Mix it all together:
	snd = Mix.ar(snd + tone) * amp * env;

	//DetectSilence.ar(in: snd, doneAction: doneAction);

    OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\sosSnare, { arg out = 0, amp = 0.8, pan = 0, att = 0.005, rel = 0.1, curve = -4, freq = 405,
	//drumMode Controls
	drumModeAmp = 0.25, timbreIndex = 0.385, modHarmonic = 0.452,
	//snares controls
	snareAmp = 40, nyquist = 1700, snareRez = 1000, ffreq = 2000, rq = 0.1, bwr = 1,
	doneAction = 2;

	var env, drumMode, drumModeEnv, snares, snareEnv, snd;

	env = EnvGen.kr(Env.linen(0.01, 1, 2), doneAction: doneAction);
	drumModeEnv = Env.perc(attackTime: att, releaseTime: rel, level: 0.5, curve: curve).kr;

	drumMode = SinOsc.ar(freq: freq * 0.53, mul: drumModeEnv);

	drumMode = drumMode + SinOsc.ar(freq: freq, mul: drumModeEnv);

	drumMode = drumMode + PMOsc.ar(
		            carfreq: Saw.ar(freq * 0.85),
					modfreq: freq * modHarmonic,
					pmindex: timbreIndex,
					mul: drumModeEnv * 10);

	drumMode = Mix.ar(drumMode) * drumModeAmp;

	snareEnv = Env.perc(attackTime: att, releaseTime: rel, curve: curve).kr;

	snares = Latch.ar(WhiteNoise.ar(0.1), Impulse.ar(nyquist * 2));

	snares = BRF.ar(in: snares, freq: 4 * ffreq, mul: 0.5, rq: rq);

	snares = BRF.ar(in: snares, freq: 2.5 * ffreq, mul: 0.5, rq: rq);

	snares = BRF.ar(in: snares, freq: 1.8 * ffreq, mul: 0.5, rq: rq);

	snares = BRF.ar(in: snares, freq: ffreq, mul: snareEnv, rq: rq);

	snares = Resonz.ar(in: snares, freq: snareRez, bwr: bwr, mul: snareAmp) ;

	snd = Mix.new(drumMode + snares) * env * amp;

	//DetectSilence.ar(in: snd, doneAction: doneAction);

    OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\squareDrum, {
    arg
    // Standard values
    out = 0, freq = 180, amp = 0.6, pan = 0,
    // Stick Controls
    att = 0.001, dec = 0.01,
    // Head Controls
    headAmp = 0.5, decCoef = 0.175, ampSlope = 3, rel = 0.2,
    // Snares Controls (thresh goes from 0 to 1)
    snaresAmp = 0.65, followAtt = 0.005, followRel = 0.075, thresh = 0.25,
    snareGate = 0.6, rq = 0.5,
	doneAction = 2;

    var freqarray, amparray, decarray, stick, head, snares, snd;

    // Setting up arrays for Klank
    freqarray = Array.fill(8, {
        arg i = 1;
        (
            Array.fill((i + 1), {
                arg j;
                (j + 1).pow(2)
            }) +
            (i + 1).pow(2)
        ).sqrt

    });
    freqarray = freqarray.flatten/(2.sqrt);

    amparray = Array.fill(36, {
        arg i;
        if (freqarray[i] > 20000)
            { 0 }
            {
                (ampSlope * (freqarray[i]).log2).dbamp
            }
    });
    amparray = amparray/amparray.max;

    decarray = Array.fill(36, {
        arg i;
        exp(-1 * i * decCoef)
    });
    decarray = decarray/decarray[0];

    // Drumstick
    stick = Decay2.ar(
        in: Impulse.ar(0),
        attackTime: att,
        decayTime: dec,
        mul: 0.005); // This keeps the volume at a sane level

    // Drum Head
    head = Klank.ar(
        specificationsArrayRef:
            Ref.new([freqarray, amparray, decarray]),
        input: stick,
        freqscale: freq,
        decayscale: rel);

    // Snares
    snares = PinkNoise.ar(
        Amplitude.ar(
            in: head,
            attackTime: followAtt,
            releaseTime: followRel));
    snares = CompanderD.ar(
        in: snares,
        thresh: thresh,
        slopeBelow: 1 + snareGate.clip(0, inf));
    snares = BRF.ar(
        in: snares,
        freq: freqarray[1..6],
        rq: rq);

    //Output Stuff
    snd = (head * headAmp) + (snares * snaresAmp);
    snd = Mix.ar(snd * amp);
    snd = Limiter.ar(snd);

    DetectSilence.ar(in: snd, doneAction: doneAction);

    OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

///////////////////////////////////////  HiHat

SynthDef(\hat, { | out = 0, amp = 1 |
	var osc1, env;
	osc1 = WhiteNoise.ar(amp);
	env = EnvGen.kr(Env.perc(0, 0.01), doneAction: 2);
	OffsetOut.ar(out, Pan2.ar(osc1, 0, env));
}).add;

~hatenSynthDef = SynthDef(\haten, { arg out = 0, amp = 1, pan = 0, envL1 = 0, envL2 = 3, envL3 = 0, envL4 = 5, envT1 = 0, envT2 = 0.2, randFreq = 1, randAmt = 0.5, envT3 = 0.9, envT4 = 0.03, mixNoise = 0.5, sinFreq = 200, mixSaw = 0.5, sawFreq = 0, hpfreq = 400, hprq = 0.2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.step([envL1, envL2, envL3, envL4], [envT1, envT2 * LFNoise2.ar(randFreq, randAmt), envT3, envT4]), doneAction: 2);
	sig = (WhiteNoise.ar(amp) * mixNoise) + (FSinOsc.ar(sinFreq) * (1 - mixNoise));
	sig = (LFSaw.ar(sawFreq) * mixSaw) + (sig * (1 - mixSaw));
	sig = RHPF.ar(sig, hpfreq, hprq);
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

~haten1SynthDef = SynthDef(\haten1, { arg out = 0, amp = 1, pan = 0, envL1 = 0, envL2 = 3, envL3 = 0, envL4 = 5, envL5 = 0, envT1 = 0, envT2 = 0.2, randFreq = 1, randAmt = 0.5, envT3 = 0.9, envT4 = 0.03, curve = (-4), mixNoise = 0.5, sinFreq = 142, sinAmp = 0.2, fsinFreq = 200, fsinAmp = 0, mixSaw = 0.5, sawFreq = 0, hpfreq = 400, hprq = 0.2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2 * LFNoise2.ar(randFreq, randAmt), envT3, envT4], curve), doneAction: 2);
	sig = (WhiteNoise.ar(1) * mixNoise) + ((SinOsc.ar(sinFreq, 0, sinAmp) + FSinOsc.ar(fsinFreq, 0, fsinAmp)) * (1 - mixNoise));
	sig = (VarSaw.ar(sawFreq) * mixSaw) + (sig * (1 - mixSaw));
	sig = RHPF.ar(sig, hpfreq, hprq);
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

~ikedaHiNoiseSynthDef = SynthDef(\IkedaHiNoise, { arg out = 0, level = 10, pan = 0, attack = 0.02, decay = 0.1, rq = 0.9, amp = 0.05, t_trig = 0, doneAction = 2;
	var noise, sig;
	noise = WhiteNoise.ar(Decay2.kr(t_trig, attack, decay, amp));
	sig = BPF.ar(noise, TRand.kr(12000, 15000, t_trig), rq.max(0.001));
	DetectSilence.ar(sig, 0.0001, doneAction: doneAction);
	OffsetOut.ar(out, Pan2.ar(sig, pan, level));
}).add;

~ikedaClickSynthDef = SynthDef(\IkedaClick, { arg out = 0, level = 1, pan = 0, t_trig = 0, centerFreq = 15000, rq = 0.9, modamp = 25, doneAction = 2;
	var noise, sig;
 	noise = PinkNoise.ar(Decay.kr(t_trig, 0.001 * LFNoise1.kr(4).abs));
	sig = BPF.ar(noise, centerFreq.max(1), rq.max(0.01), modamp * LFNoise1.kr(8).range(0, 1)).fold(-1, 1);
 	DetectSilence.ar(sig, 0.0001, doneAction: doneAction);
 	OffsetOut.ar(out, Pan2.ar(sig, pan, level));
}).add;

SynthDef(\hatY,{arg t_gate = 1, pan = 0, amp = 1, out = 0, rel = 0.1, doneAction = 2;
	var env = EnvGen.ar(Env.perc(0,rel), t_gate, doneAction: doneAction);
	var freq = EnvGen.ar(Env([12000,80,20000],[0.1,0.1]));
	var sig = PinkNoise.ar(env);
	sig = HPF.ar(sig,freq);
	sig = Pan2.ar(sig.tanh, pan, amp);
	OffsetOut.ar(out,sig*12);
}).add;

~hatnewSynthDef = SynthDef(\hatnew, {|out=0, amp=1, pan=0, freq=230, hpf=8500, rel=0.15, fxb=0, fxv=0, bbcb=0, bbcv=0, doneAction = 2|
  var pulse, sig, env, freqs;
  freqs = [freq, freq*1.4471, freq*1.617, freq*1.9265, freq*2.5028, freq*2.6637];
  pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6, mul: 1));
  sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
  env = EnvGen.kr(Env.perc(0,rel), doneAction: doneAction);
  sig =  Pan2.ar(sig*env, pan, amp);
  OffsetOut.ar(out,sig);
}).add;

~hat909SynthDef = SynthDef(\hat909, {|out=0, amp=1, pan=0, envL1 = 0, envL2 = 0.98, envL3 = 0.12, envL4 = 0.9, envT1 = 0.2, envT2 = 0.01, envT3 = 0.32, envCurve = (-4), freq=230, hpf=6500, doneAction = 2|
	var pulse, sig, env, freqs;
	freqs = [freq, freq*1.4471, freq*1.617, freq*1.9265, freq*2.5028, freq*2.6637];
	pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6));
	sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
	// env = EnvGen.kr(Env.perc(0,release),doneAction:2);
	env = Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve).kr(doneAction: doneAction);
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

~hat808SynthDef = SynthDef(\hat808, { arg out = 0, amp = 0.1, pan = 0, tu = 1, t_gate = 1, attack = 0.01, release = 0.1;
	var sig;
	var env = EnvGen.ar(Env.perc(attack, release),doneAction:2);
	sig = Saw.ar((1..9)*1000.23*env*tu);
	sig = RHPF.ar(sig, \hpf.kr(5700), \rq.kr(0.5));
	sig = sig * (1+EnvGen.ar(Env.perc((-0.1),\rel.kr(0.1),-4),t_gate))*tu;
	sig = Ringz.ar(sig,(10..15)*1000.234,1).mean;
	sig = RHPF.ar(sig, \lpf.kr(2000)*env*tu, \rq.kr(0.5));
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\hihatAw, {arg out = 0, amp = 0.5, pan = 0, att = 0.01, rel = 0.2, ffreq = 6000, doneAction = 2;
	var snd = WhiteNoise.ar(amp);
	var env = Env.perc(att, rel).kr(doneAction: doneAction);
	snd = HPF.ar(snd * env, ffreq);
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\hihatElectro, { arg out = 0, pan = 0, amp = 0.3, att = 0.001, rel = 0.3, curve = -8, filterFreq = 4010, rq = 0.56, doneAction = 2;
	var env, snd;

	// noise -> resonance -> exponential dec envelope
	env = Env.perc(attackTime: att, releaseTime: rel, curve: curve).kr(doneAction: doneAction);

	snd = ClipNoise.ar(amp);
	snd = BPF.ar(
		in: snd,
		freq: [1, 1.035] * filterFreq,
		rq: [0.27, 1] * rq,
		mul: [1.0, 0.6]
	);
	snd = Mix(snd) * env;

	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\ikedhat,{arg out = 0, amp = 1, pan = 0, envLevel1 = 0.0, envLevel2 = 1.0, envLevel3 = 0.0, levelScale = 1, levelBias = 0, att= 0.0, rel = 0.01, timeScale = 1, hpf = 6000, t_trig = 1, doneAction = 2;
	var sig = HPF.ar(WhiteNoise.ar(1), hpf);
	var env = EnvGen.ar(Env([envLevel1, envLevel2, envLevel3], [att, rel]), t_trig, levelScale, levelBias, timeScale, doneAction);
	OffsetOut.ar(out, Pan2.ar(sig, pan, env*amp));
}).add;

~fabHiSynthDef = SynthDef(\fabHi, {arg out = 0, amp = 0.2, pan = 0, wamp = 0.5, envNatt = 0.001, envNrel = 0.2, wbpfFreq = 2800, wbpfRq = 1, sinFrq1 = 2120, sinFrq2 = 12423, sinPh1 = 0, sinPh2 = 0.02, sinLev1 = 1, sinLev2 = 1, envSatt = 0.001, envSrel = 0.2, mix = 0.5, envL1 = 0, envL2 = 1, envL3 = 0.75, envT1 = 0.1, envT2 = 0.02, envT3 = 0.2, ffreq = 6000, t_gate = 1, doneAction = 2;
	var noise, sin1, sin2, sig, env, envNoise, envSin;
	envNoise = EnvGen.kr(Env.perc(envNatt, envNrel), t_gate);
	envSin = EnvGen.kr(Env.perc(envSatt, envSrel), t_gate);
	noise = BPF.ar(WhiteNoise.ar(wamp) * envNoise, wbpfFreq, wbpfRq.max(0.01));
	sin1 = SinOsc.ar(sinFrq1, sinPh1, sinLev1);
	sin2 = SinOsc.ar(sinFrq2, sinPh2, sinLev2);
	sig = XFade2.ar(noise, Mix.ar([sin1, sin2]) * envSin, mix);
env = Env.step([envL1, envL2, envL3], [envT1, envT2, envT3]).kr(doneAction: doneAction);
sig = HPF.ar(sig * env, ffreq);
OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

~fabHi1SynthDef = SynthDef(\fabHi1, {arg out = 0, amp = 0.2, pan = 0, wamp = 0.5, envNatt = 0.001, envNrel = 0.2, wbpfFreq = 2800, wbpfRq = 1, sinFrq1 = 2120, sinFrq2 = 12423, sinPh1 = 0, sinPh2 = 0.02, sinLev1 = 1, sinLev2 = 1, envSatt = 0.001, envSrel = 0.2, mix = 0.5, envL1 = 0, envL2 = 1, envL3 = 0.75, envL4 = 0, envT1 = 0.1, envT2 = 0.02, envT3 = 0.2, ffreq = 6000, t_gate = 1, doneAction = 2;
	var noise, sin1, sin2, sig, env, envNoise, envSin, delay;
	envNoise = EnvGen.kr(Env.perc(envNatt, envNrel), t_gate);
	envSin = EnvGen.kr(Env.perc(envSatt, envSrel), t_gate);
	noise = BPF.ar(WhiteNoise.ar(wamp) * envNoise, wbpfFreq, wbpfRq.max(0.01));
	sin1 = SinOsc.ar(sinFrq1, sinPh1, sinLev1);
	sin2 = SinOsc.ar(sinFrq2, sinPh2, sinLev2);
	sig = XFade2.ar(noise, Mix.ar([sin1, sin2]) * envSin, mix);
	env = Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3]).kr(doneAction: doneAction);
	sig = HPF.ar(sig * env, ffreq);
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

~metroSynthDef = SynthDef(\metro, {arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 2, impFreq=1, theta = 0.5, rho = 0.8, filterfreq=1000, rq=1.0, doneAction = 2;
	var env, signal, b1, b2;
	env = EnvGen.kr(Env.linen(att, 1, rel), doneAction: doneAction);
	b1 = 2.0 * rho * cos(theta);
	b2 = rho.squared.neg;
	signal = SOS.ar(Impulse.ar(impFreq, 0, env), 1.0, 0.0, 0.0, b1, b2);
	signal = RHPF.ar(signal, filterfreq, rq);
	OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
}).add;

SynthDef(\haty,{ arg out = 0, att = 0.001, rel = 0.1, curve = (-4), amp = 0.75, doneAction = 2;
	var env, sig;
	env = EnvGen.kr(Env.perc(att, rel, 1, curve), 1, doneAction: doneAction);
	sig = HPF.ar((WhiteNoise.ar(0.5, 0.5) * env * amp), 4000);
	OffsetOut.ar(out, [sig,sig]);
}).add;

~haty48SynthDef = SynthDef(\haty48,{ arg out = 0, amp = 0.75, pan = 0, att = 0.001, rel = 2.89, curve = (-4), envaL1 = 0.1, envaL2 = 1, envaL3 = 0.2, envaL4 = 2, envaL5 = 0, envaT1 = 0.2, envaT2 = 1.6, envaT3 = 0.24, envaT4 = 0.05, envaCrv = (-4), envpL1 = 230, envpL2 = 421, envpL3 = 312, envpL4 = 201, envpT1 = 0.02, envpT2 = 0.21, envpT3 = 0.01, envpT4 = 0.45, envpCrv = (-4), modFreq = 46, modAmt = 0, sinfAdd = 0.2, sinPhase = 0, sinpAdd = pi, rf1Freq = 39, rf1Rq = 0.25, rf2Freq = 39.2, rf2Rq = 0.65, hpfFreq = 4000, doneAction = 2;
	var mod, env, enva, envp, sig;
	env = EnvGen.kr(Env.linen(att, rel, rel/2, 1, curve), 1, doneAction: doneAction);
	enva = EnvGen.kr(Env([envaL1, envaL2, envaL3, envaL4, envaL5], [envaT1, envaT2, envaT3, envaT4], [envaCrv, envaCrv / 2, envaCrv.neg]));
	envp = EnvGen.kr(Env.circle([envpL1, envpL2, envpL3, envpL4], [envpT1, envpT2, envpT3, envpT4], [envpCrv, envpCrv * 2 , envpCrv.neg, envpCrv / 2]));
	mod = LFNoise0.ar(modFreq * envp.range(0.1, 4), modAmt * enva).range(1, modAmt);
	sig = SinOsc.ar([envp, envp + sinfAdd], [sinPhase, (sinPhase + sinpAdd)]);
	sig = Resonz.ar(sig, [rf1Freq, rf2Freq] * mod, [rf1Rq, rf2Rq], enva);
	sig = HPF.ar(sig, hpfFreq);
	sig = (sig[0] + sig[1]) * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\sosHats, { arg out = 0, amp = 0.8, pan = 0, freq = 6000, curve = -4, rootIndex = 238.5, rq = 1,
	// Initial envelopes
	initAtt = 0.005, initRel = 0.1, initAmp = 1, initStart = 15000, initEnd = 9000,
	// Body envelopes
	bodyAtt = 0.005, bodyRel = 0.1, bodyAmp = 1, bodyStart = 9000, bodyEnd = 12000,
	// General envelope
	envAtt = 0.01, envRel = 1, envCurve = (-4),
	doneAction = 2;

	var root, initialEnv, initialSweep, initial, bodyEnv, bodySweep, body, snd;

	root = Pulse.ar(freq: freq, width: 0.5, mul: 1);

	root = PMOsc.ar(
		carfreq: root,
		modfreq: freq * [1.34, 2.405, 3.09, 1.309],
		pmindex: rootIndex * [1, 0.22, 0.014, 0.0038]
	);

	root = Mix.new(root);

	initialEnv = Env.perc(attackTime: initAtt, releaseTime: initRel, curve: curve).kr;

	initialSweep = Line.kr(start: initStart, end: initEnd, dur: initRel);

	initial = BPF.ar(in: root, freq: initialSweep, rq: rq, mul: initialEnv * initAmp);

	bodyEnv = Env.perc(attackTime: bodyAtt, releaseTime: bodyRel, curve: curve / 2).kr;

	bodySweep = Line.kr(start: bodyStart, end: bodyEnd, dur: bodyRel);

	body = HPF.ar(in: root, freq: bodySweep, mul: bodyEnv * bodyAmp);

	snd = Mix.ar([initial, body]) * amp;

	snd = snd * EnvGen.kr(Env.perc(envAtt, envRel, curve: envCurve), doneAction: doneAction);
    // DetectSilence.ar(in: snd, doneAction: doneAction);

    OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\tick2, {
    var sig, env, rq = \rq.kr(0.1);
    env = Env.perc(\atk.kr(0), \rel.kr(0.05)).ar(2);
    sig = Impulse.ar(0);
    sig = sig * 0.5;
    sig = RHPF.ar(sig, \freq.kr(1000), rq) * env;
    sig = Pan2.ar(sig, \pan.kr(0)) * \amp.kr(1.0);
    OffsetOut.ar(\out.kr(0), sig);
}).add;

///////////////////////////////////////  Cymbal

~cymSynthDef = SynthDef(\cym, { arg out=0, amp=0.5, pan=0, att=0, rel=1, curve=(-8), tu=1, doneAction=2;
	var sig;
	var env = EnvGen.ar(Env.perc(att,rel,1,curve),doneAction: doneAction);
	var freqs = geom(100, 50, 1.3434)*10.234567*Lag3.kr(tu);
	sig = WhiteNoise.ar;
	sig = Ringz.ar(sig,freqs).mean;
	sig = Pan2.ar(sig*env, pan, amp);
	OffsetOut.ar(out, sig * amp);
}).add;

~cym1SynthDef = SynthDef(\cym1, { arg out=0, amp=0.2, pan=0, envL1 = 0, envL2 = 1, envL3 = 0.3, envL4 = 0, levScale = 1, envT1 = 0.1, envT2 = 0.02, envT3= 0.01, envC1 = (-8), envC2 = 4, envC3 = (-4), tu=1, doneAction=2;
	var sig;
	var env = EnvGen.ar(Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], [envC1, envC2, envC3]), levelScale: levScale, doneAction: doneAction);
	var freqs = geom(100, 50, 1.3434)*10.234567*Lag3.kr(tu, 10);
	sig = WhiteNoise.ar;
	sig = Ringz.ar(sig,freqs).mean;
	sig = Pan2.ar(sig*env, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

~cymnewSynthDef = SynthDef(\cymnew, { arg out = 0, amp = 0.2, pan = 0, att = 0, rel = 4, curve = (-8), tu = 6, t_trig = 1, doneAction = 2;
    var sig;
    var env = EnvGen.ar(Env.perc(att,rel,1,curve), t_trig, doneAction: doneAction);
	var freqs = geom(99,40,pi/3)*10.234567*tu;
	sig = WhiteNoise.ar(0.2);
    sig = Ringz.ar(sig,freqs,1).mean;

    sig = Pan2.ar(sig*env, pan);
    OffsetOut.ar(out, sig * amp);
}).add;

~cymnew1SynthDef = SynthDef(\cymnew1, { arg out = 0, amp = 0.2, pan = 0, envL1 = 0, envL2 = 1, envL3 = 0.4, envL4 = 0, envT1 = 0.12, envT2 = 0.02, envT3 = 0.23, curve = (-8), tu = 6, t_trig = 1, doneAction = 2;
    var sig;
	var env = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], curve), t_trig, doneAction: doneAction);
	var freqs = geom(99,40,pi/3)*10.234567*tu;
	sig = WhiteNoise.ar(0.2);
    sig = Ringz.ar(sig,freqs,1).mean;

    sig = Pan2.ar(sig*env, pan);
    OffsetOut.ar(out, sig * amp);
}).add;

~cymbalicMcldSynthDef = SynthDef(\cymbalicMcld, { |out=0, amp=0.1, pan=0, attLowf = 0.5, relLowf = 5, lowNoiseLev = 0.1, attHif = 1, relHif = 3, hiNoiseLev = 0.1, attHi = 1, relHi = 2, hiLev = 0.25, attTh = 0.001, relTh = 0.001, freq1 = 627, freq2 = 2961, freq3 = 7824, freq4 = 476, t_trig = 1, doneAction = 2|
	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack, sig;

	locutoffenv = EnvGen.kr(Env.perc(attLowf, relLowf), t_trig, doneAction: doneAction) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(lowNoiseLev), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.kr(Env.perc(attHif, relHif), t_trig, doneAction: doneAction) * 10000);
	hidriver = HPF.ar(WhiteNoise.ar(hiNoiseLev), hicutoffenv);
	hidriver = hidriver * EnvGen.kr(Env.perc(attHi, relHi, hiLev));

	thwack = EnvGen.kr(Env.perc(attTh,relTh), t_trig, doneAction: doneAction);

	// This bit will regenerate new freqs every time you evaluate the SynthDef!
	//freqs  = {exprand(300, 20000)}.dup(100);

	freqs = [freq1, freq2, freq3, freq4] /** LFNoise2.kr(0.002, 0.5, 0.5)*/;

	res = Ringz.ar(
		lodriver + hidriver + thwack,
		freqs
	).mean;
	sig = (res * 1) + (lodriver * 2) + thwack;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

~cymbal808ryanSynthDef = SynthDef(\cymbal808ryan, {
	arg out=0, amp=0.1, baseFreq = 300, penvL1 = 1.0, penvL2 = 0.6, ptime = 250, pcurve = (-0.5), pulsew = 0.55, rlpfFrq = 7000, rlpfRq = 0.6, rhpfFrq = 6800, rhpfRq = 1.5, envL1 = 0, envL2 = 1, envL3 = 0.4, envL4 = 0, envL5 = 0, envT1 = 2, envT2 = 250, envT3 = 50, envT4 = 500, envC1 = 0, envC2 = (-0.5), envC3 = 0, envC4 = (-50), doneAction = 2;
	var freqs = [baseFreq, baseFreq*1.3420, baseFreq*1.2312, baseFreq*1.6532, baseFreq*1.9523, baseFreq*2.1523];
	//var freqs = [78.6, 140.44, 123.87, 219.4, 787.5, 531.3];
	//var freqs = [205.35, 254.29, 294.03, 304.41, 369.64, 522.71];
	//var freqs = [205.35, 304.41, 369.64, 522.71, 540.54, 812.21];
	var signal, pulseEnv;

	pulseEnv = EnvGen.kr(Env.new([penvL1, penvL2], [ptime], [pcurve]), timeScale:(1/1000));
	signal = Mix.new(LFPulse.ar(freqs * 4.09));
	signal = (BinaryOpUGen('==', signal, 6.0) * 0.6) + (BinaryOpUGen('==', signal, 2.0) * 0.2) + (BinaryOpUGen('==', signal, 1.0) * 0.9); // XOR
	signal = (signal * pulseEnv) + (Mix.new(LFPulse.ar(freqs, width: pulsew)) * 0.9);
	signal = RLPF.ar(signal, rlpfFrq, rlpfRq);
 	signal = RHPF.ar(signal, rhpfFrq, rhpfRq);
	signal = signal * EnvGen.kr(Env.new([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4], [envC1, envC2, envC3, envC4]), timeScale:(1/1000), doneAction: doneAction);
	signal = [signal, DelayN.ar(signal, 0.005, 0.005)];
	OffsetOut.ar(out, signal*4*amp);
}).add;

SynthDef(\cymbal808, { arg out = 0, amp = 0.1, pan = 0, att = 0.002, dec = 0.25, rel = 0.05, freqMultiplier = 4.09, decLevel = 0.4, reverb = 0.33, size = 0.5, damp = 0.5, doneAction = 2;
	var snda, sndb, snd, env, pulseEnv, freqs;

	freqs = [205.35, 304.41, 369.64, 522.71, 540.54, 812.21];

	env = Env.new(
		levels: [0, 1, decLevel, 0],
		times: [att, dec, rel],
		curve: [0, -0.5, 0]
	).kr;

	pulseEnv = Env.new(
		levels: [1.0, 0.6],
		times: dec,
		curve: -0.5
	).kr;

	snd = Mix.ar(LFPulse.ar(freq: freqs * freqMultiplier));

	snd = (BinaryOpUGen('==', snd, 6.0) * 0.6) + (BinaryOpUGen('==', snd, 2.0) * 0.2) + (BinaryOpUGen('==', snd, 1.0) * 0.9);

	snd = (snd * pulseEnv) + Mix.ar(LFPulse.ar(freq: freqs, width: 0.55, mul: 0.9));

	snd = RLPF.ar(in: snd, freq: 7000, rq: 0.6);
 	snd = RHPF.ar(in: snd, freq: 6800, rq: 1.5);
	snd = RHPF.ar(in: snd, freq: 6800, rq: 1.5);
	snd = RHPF.ar(in: snd, freq: 1200, rq: 1.5);

	snd = snd + FreeVerb.ar(in: snd, mix: reverb, room: size, damp: damp);
	snd = Mix.ar(snd);
	snd = snd * env * amp;

	DetectSilence.ar(in: snd, doneAction: doneAction);

	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

///////////////////////////////////////  Clap

SynthDef(\clap, {| out=0, amp = 1, pan=0, q=0.1, fq=1, rnd1=0, rnd2=0, rnd3=0, t_gate=1, doneAction=2 |
	var env1, env2, noise1, noise2, sig;
	env1 = EnvGen.ar(\env1.kr(Env([0, 1, 0.5, 0.5, 0, 1, 0, 0.3, 0],	[0.001, 0.0013, 0, 0.01, 0, 0.001, 0, 0.03],[0, -3, 0, -3, 0, -3, 0, -4])),doneAction:2);
	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 400);
	noise1 = BPF.ar(noise1, 1000*fq, 20*q);
	env2 = EnvGen.ar(\env2.kr(Env([0, 1, 0], [0.002, 0.1], [0, -4])), t_gate, doneAction: doneAction);
	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 2300);
	noise2 = BPF.ar(noise2, 2000*fq, 7*q, 0.7);
	sig = noise1 + noise2;
	sig = sig * 2;
	sig = Pan2.ar(sig.softclip, pan, amp);
	OffsetOut.ar(out,sig);
}).add;

~clappingSynthDef = SynthDef(\clapping, {arg out = 0, amp=0.5, pan = 0, attack = 0.01, release = 1, att = 0.003, rel = 0.035, noiseAmp = 1, filterfreq=120, rq=0.1, sinAmpStart = 1, sinAmpEnd = 0.01, sinAmpDur = 4, lpfFreq = 400, hpfFreq = 120, delMix = 1, delTimeL = 0.03, delDecL = 0.031, delTimeR = 0.03016, delDecR = 0.06, t_trig=1, doneAction=2;
	var env, signal, noise, hpf1, hpf2, fx;
	noise = WhiteNoise.ar(noiseAmp)+SinOsc.ar([filterfreq/2,filterfreq/6 ], pi*0.5, XLine.kr(sinAmpStart, sinAmpEnd, sinAmpDur));
	hpf1 = RLPF.ar(noise, lpfFreq, rq);
	hpf2 = RHPF.ar(noise,  hpfFreq, rq/4);
	env = EnvGen.kr(Env.perc(att, rel));
	signal = (hpf1+hpf2) * env;
	fx = CombC.ar(signal, 0.5, delTimeL, delDecL)+CombC.ar(signal, 0.5, delTimeR, delDecR);
	// signal = FreeVerb.ar(signal, 0.1, 0, 0.5);
	// signal = Limiter.ar(signal, 0.7, 0.01) * amp;
	signal = (signal * (1 - delMix)) + (fx * delMix) ;
	signal = signal * EnvGen.kr(Env.linen(attack, 1, release), doneAction: doneAction);
	// DetectSilence.ar(signal, doneAction: doneAction);
	OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
}).add;

SynthDef(\clap_oto309, {
	arg out=0, amp = 0.1, pan=0;
	var env1, env2, son, noise1, noise2;

	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.3], [0, -4]), doneAction:2);

	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 600);
	noise1 = BPF.ar(noise1, 2000, 3);

	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

	son = noise1 + noise2;
	son = son * 2;
	son = son.softclip * amp;

	OffsetOut.ar(out, Pan2.ar(son, pan));
}).add;

SynthDef(\oneclap_thor, {arg out=0, amp=0.1,  pan=0, filterfreq=1000, rq=0.1, attackTime = 0.003, releaseTime = 0.035, doneAction = 2;
var env, signal, attack, noise, hpf1, hpf2;
	noise = WhiteNoise.ar(1)+SinOsc.ar([filterfreq/2,filterfreq/2+4 ], pi*0.5, XLine.kr(1,0.01,4));
	noise = PinkNoise.ar(1)+SinOsc.ar([(filterfreq)*XLine.kr(1,0.01,3), (filterfreq+4)*XLine.kr(1,0.01,3) ], pi*0.5, XLine.kr(1,0.01,4));
	hpf1 = RLPF.ar(noise, filterfreq, rq);
	hpf2 = RHPF.ar(noise, filterfreq/2, rq/4);
	env = EnvGen.kr(Env.perc(attackTime, releaseTime), doneAction: doneAction);
	signal = (hpf1+hpf2) * env;
	signal = CombC.ar(signal, 0.5, 0.03, 0.031)+CombC.ar(signal, 0.5, 0.03016, 0.06);
	//signal = Decay2.ar(signal, 0.5);
	signal = FreeVerb.ar(signal, 0.23, 0.15, 0.2);
	//DetectSilence.ar(signal, doneAction:2);
	OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
}).add;

~oneclapThorBrSynthDef = SynthDef(\oneclapThorBr, { arg out = 0, amp = 0.1, pan = 0, attack = 0.01, release = 1, att = 0.003, rel = 0.00035, tone = 0.4, noiseAmp = 1, freq = 100, rq = 0.1,
	//Other Controls
	echohz1 = 33.333, echohz2 = 33.156, curve = -4, decay = 0.06, shelfFreq = 7000, rs = 0.5, db = -3,
	// Controls Ranging from 0 to 1
	size = 0.15, mix = 0.23, damp = 0.5,
	doneAction = 2;

	var env, snd, noise1, noise2, hpf1, hpf2, delay1, delay2;

	noise1 = (GrayNoise.ar(1 - tone) + WhiteNoise.ar(tone)) * noiseAmp;

	noise1 = noise1 + SinOsc.ar(freq: [freq / 2, freq / 2 + 4 ]);

	noise2 = PinkNoise.ar(noiseAmp);

	noise2 = noise2 + SinOsc.ar(freq: [freq, (freq * 1.04)] * XLine.kr(start: 1, end: 0.01, dur: 3));

	hpf1 = RLPF.ar(in: noise1, freq: freq, rq: rq);

	hpf2 = RHPF.ar(in: noise1, freq: freq/2, rq: rq/4);

	env = Env.perc(attackTime: att, releaseTime: rel, curve: curve).kr;

	snd = Mix.ar(hpf1 + hpf2) * env;

	delay1 = CombN.ar(in: snd, maxdelaytime: 1.1/echohz1, delaytime: 1/echohz1, decaytime: decay / 2);

	delay2 = CombN.ar(in: snd, maxdelaytime: 1.1/echohz2, delaytime: 1/echohz2, decaytime: decay);

	snd = FreeVerb.ar(in: Mix.ar(delay1 + delay2), mix: mix, room: size, damp: damp, mul: amp);

	snd = BHiShelf.ar(in: snd, freq: shelfFreq, rs: rs, db: db);

	snd = snd * EnvGen.kr(Env.linen(attack, 1, release), doneAction: doneAction);
	// DetectSilence.ar(snd, doneAction: doneAction);

	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\clapy, { arg out = 0, amp = 0.5, att = 0.02, rel = 0.3, curve1 = 0, curve2 = (-4), hpf1 = 600, hpf2 = 1000, bpf1 = 2000, bpf2 = 1200, gain = 1.5, doneAction = 2;
	var env1, env2, sig, noise1, noise2;
	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [att, rel], [curve1, curve2]), doneAction: doneAction);
	noise1 = BPF.ar(HPF.ar(GrayNoise.ar(env1), hpf1), bpf1, 3);
	noise2 = BPF.ar(HPF.ar(GrayNoise.ar(env2), hpf2), bpf2, 0.7, 0.7);
	sig = noise1 + noise2;
	sig = sig * gain;
	sig = 0.4 * sig.softclip * amp;
	OffsetOut.ar(out, [sig,sig]);
}).add;

SynthDef(\clapGray, { arg out = 0, amp = 0.1, pan = 0, att = 0.001, rel = 0.25, curve = -4, spreadRate = 75, minDelay = 0.025, maxDelay = 0.05, decay = 0.15, rq = 0.4, blend = 0.7, reverb = 0.1, size = 0.25, damp = 1, doneAction = 2;
	var env1, env2, snd, noise1, noise2, spread;

	//Multiple Shorter Claps
	spread = LFNoise1.kr(spreadRate).range(minDelay, maxDelay);

	env1 = Env.perc(attackTime: att / 10, releaseTime: rel / 8, curve: [0, curve]).kr;
	env1 = CombC.ar(in: env1, maxdelaytime: maxDelay, delaytime: spread, decaytime: decay);

	noise1 = GrayNoise.ar(env1); //Play with frequencies here:
	noise1 = RHPF.ar(in: noise1, freq: 1000, rq: rq);
	noise1 = BPF.ar(in: noise1, freq: 2000, rq: 3);

	//One Longer Clap
	env2 = Env.perc(attackTime: att, releaseTime: rel, curve: [0, curve]).kr;

	noise2 = GrayNoise.ar(env2); //Play with frequencies here:
	noise2 = RHPF.ar(in: noise2, freq: 1200, rq: rq);
	noise2 = BPF.ar(in: noise2, freq: 1400, rq: 0.7);

	//Mixing and light Reverb
	snd = Mix.ar((blend * noise1) + ((1 - blend) * noise2));
	snd = (snd * 2).softclip;
	snd = FreeVerb.ar(in: snd, mix: reverb, room: size, damp: damp, mul: amp);

	DetectSilence.ar(in: snd, doneAction: doneAction);

	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

///////////////////////////////////////  Noise

~ikedaBreathSynthDef = SynthDef(\IkedaBreath, { arg out = 0, level = 1, pan = 0, attack = 0.0001, decay = 0.4, release = 0.01, note1 = 44, note2 = 90, amp1 = 0.5, amp2 = 0.6, lpfFreq = 103.82, hpfFreq = 2400, t_trig = 0, doneAction = 2;
	var sin, lpf, hpf, sig;
	sin = SinOsc.ar(note1.midicps, 0, amp1) + SinOsc.ar(note2.midicps, 0, amp2);
	lpf = LPF.ar(sin, lpfFreq.max(1));
	hpf = HPF.ar(LPF.ar(WhiteNoise.ar(0.008), 12000), hpfFreq.max(1));
	sig = (lpf + hpf) * EnvGen.kr(Env(#[0, 1, 0.6, 0], [attack, decay, release]), t_trig, doneAction: doneAction); // # makes a totally fixed (non-dynamic) Array and is slightly cheaper, especially where you're not going to change the Array once you make it
	OffsetOut.ar(out, Pan2.ar(sig, pan, level));
}).add;

SynthDef(\noise2,{arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 0.01, a = 4;
var env0 =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [att, rel], [-4, -2, -4]), doneAction:2);
var sig = CuspN.ar(
		SampleRate.ir/a,
		LFNoise2.kr([4,4],1.5,1.5),
		LFNoise2.kr([2,2],1.5,1.5),
		LFNoise2.kr([2,2],0.5,1.5),
		LFNoise2.kr([2,2],0.5,1.5);
	);
	sig = HPF.ar(sig,1000);
	sig = Limiter.ar(sig,0.4);
	sig =	[sig ,DelayL.ar(sig,0.1,100/44100)];
	//sig = PitchShift.ar(sig,0.2,1*a);
	sig = Compander.ar(sig,In.ar(0,1),0.01,1,0.01,0.01,0.1);
	sig =  Pan2.ar(sig.tanh, pan, amp);
	OffsetOut.ar(out,sig*env0);
}).add;

~noise2newSynthDef = SynthDef(\noise2new,{arg out = 0, amp = 1, pan = 0, levelScale = 1, att = 0.01, rel = 1, curve1 = -4, curve2 = -2, curve3 = -4, coeff = 0.2, avar = 1, bvar = 1, xi = 0.5, hpf = 1000, del1 = 10, del2 = 20, doneAction = 2;
	var env, sig;
	env =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [att, rel], [curve1, curve2, curve3]), levelScale: levelScale, doneAction: doneAction);
	sig = CuspN.ar(
        SampleRate.ir/coeff,
        LFNoise2.kr([4,4],1.5,1.5) * avar,
        LFNoise2.kr([0.2,0.2],1.5,1.5) * bvar,
        LFNoise2.kr([2,2],0.5,1.5) * xi,
        LFNoise2.kr([2,2],0.5,1.5);
    );
    sig = HPF.ar(sig,hpf);
    sig = Limiter.ar(sig,0.4);
    sig = [DelayL.ar(sig,0.1,del1/44100) ,DelayL.ar(sig,0.1,del2/44100)];
    //sig = PitchShift.ar(sig,0.2,1*coeff);
    sig = Compander.ar(sig,In.ar(out,1),0.01,1,0.01,0.01,0.1);
    sig = sig.tanh;
	sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig * env);
}).add;

SynthDef(\noise,{arg out = 0, amp = 1, pan = 0, att = 0.01, rel  = 0.25, curve1 = -4, curve2 = -2, curve3 = -4, coeff = 4, avar = 3, bvar = -3, cvar = 0.5, dvar = 1.5, xi = 0.5, yi = 0.5, hpf = 1000, doneAction = 2;
var env0 =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [att, rel], [curve1, curve2, curve3]), doneAction: doneAction);
var sig = LatoocarfianL.ar(
		SampleRate.ir/coeff,
		avar.max(-3).min(3),
		bvar.max(-3).min(3),
		cvar.max(0.5).min(1.5),
		dvar.max(0.5).min(1.5),
		xi,
		yi
	);
	sig = HPF.ar(sig,hpf);
	sig = Limiter.ar(sig,0.4);
	sig =	[sig, DelayL.ar(sig,0.1,100/44100)];
	//sig = PitchShift.ar(sig,0.2,1*coeff);
	//sig = Compander.ar(sig,In.ar(0,1),0.01,1,0.01,0.01,0.1);
	sig=  sig.tanh*env0;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

~newNoise48SynthDef = SynthDef(\newNoise48,{arg out = 0, amp = 1, pan = 0, env0L1 = 0.1, env0L2 = 1, env0L3 = 0.3, env0L4 = 0, env0T1 = 0.01, env0T2 = 0.2, env0T3 = 0.25, env0T4 = 0.25, offset = 0, timeScale = 1, coeff = 4, avar = 3, bvar = -3, cvar = 0.5, dvar = 1.5, xi = 0.5, yi = 0.5, hpf = 1000, t_trig = 1, doneAction = 2;
var env0 =  EnvGen.ar(Env.step([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3, env0T4], offset), t_trig, timeScale: timeScale, doneAction: doneAction);
var sig = LatoocarfianL.ar(
		SampleRate.ir/coeff,
		avar.max(-3).min(3),
		bvar.max(-3).min(3),
		cvar.max(0.5).min(1.5),
		dvar.max(0.5).min(1.5),
		xi,
		yi
	);
	sig = HPF.ar(sig,hpf);
	sig = Limiter.ar(sig,0.4);
	sig =	[sig, DelayL.ar(sig,0.1,100/44100)];
	//sig = PitchShift.ar(sig,0.2,1*coeff);
	//sig = Compander.ar(sig,In.ar(0,1),0.01,1,0.01,0.01,0.1);
	sig=  sig.tanh*env0;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

/*SynthDef(\cosc, { arg out = 0, t_trig = 1, amp = 1, pan = 0, freq = 512, doneAction = 2;
    var env = EnvGen.ar(Env.adsr(0.5,1,1,0), t_trig, doneAction: doneAction);
    var sig = COsc.ar(80,[freq,freq+0.5], 1, 0.1);
    sig  = sig + COsc.ar(80,[freq,freq+0.5]*2, 1, 0.1);
    sig = FreeVerb.ar(sig*env,1);
    sig = LeakDC.ar(sig);
    OffsetOut.ar(0,sig*amp);
}).add;*/

~noiseInjectionSynthDef = SynthDef(\noiseInjection, { arg in = 0, out = 0, drywet = -0.6, hpfInFreq = 20, eqFreq = 20000, eqRq = 1, eqDb = 0, lpfInFreq = 20000, attack = 0.01, release = 0.01, noiseType = 0, nType5Chaos = 1.5, noiseLevel = 1, impSource = 0, impFreq = 52.9, impLevel = 0;
	var input, inputFilt, sig, inputAmp, imp;
	input = InFeedback.ar(in, 2);
	inputFilt = LPF.ar(HPF.ar(input, hpfInFreq), lpfInFreq);
	// inputFilt = BRF.ar(inputFilt, brfInFreq, Lag2.kr(brfInRq.max(0.01)));
	inputFilt = BPeakEQ.ar(inputFilt, Lag2.kr(eqFreq.max(20).min(20000), 0.5), eqRq, eqDb);
	inputFilt = inputFilt * (inputFilt > 0.002); // Threshold
	inputAmp = Amplitude.kr(inputFilt, attack, release);
	noiseType = noiseType.max(0).min(5);
	sig = Select.ar(noiseType, [
		WhiteNoise.ar(inputAmp),
		BrownNoise.ar(inputAmp),
		GrayNoise.ar(inputAmp),
		PinkNoise.ar(inputAmp),
		ClipNoise.ar(inputAmp),
		Crackle.ar(nType5Chaos, inputAmp)
	]);
	imp = Select.ar(impSource, [
		Impulse.ar(impFreq, 0, inputAmp),
		Dust.ar(impFreq, inputAmp)
	]);
	sig = (sig * noiseLevel) + (imp * impLevel);
	sig = XFade2.ar(input, sig, drywet);
	ReplaceOut.ar(out, sig);
	//XOut.ar(out, drywet, sig);
}).add;

~noiseSinInjectionSynthDef = SynthDef(\noiseSinInjection, { arg in = 0, out = 0, drywet = -0.6, attack = 0.01, release = 0.01, hpfFreqGate = 20, lpfFreqGate = 20000, sinGateTrh = 0.08, envFrqL1 = 20, envFrqL2 = 80, envFrqL3 = 49.2, envFrqL4 = 60, envFrqL5 = 0, envFrqT1 = 0.1, envFrqT2 = 0.2, envFrqT3 = 0.2, envFrqT4 = 0.23, envFrqC1 = (-4), envFrqC2 = (-4), envFrqC3 = (-4), envFrqC4 = (-4), sinAtt = 0.02, sinRel = 1.4, sinCurve = (-4), sinLevelPre = 0, noiseType = 0, nType5Chaos = 1.5, noiseLevel = 1, sinLevelPost = 0, impSource = 0, impFreq = 52.9, impLevel = 0, doneAction = 0;
	var input, inputAmp, sinGate, freqEnv, env, sin, noise, imp, sig;
	input = InFeedback.ar(in, 2);
	inputAmp = Amplitude.ar(input, attack, release);
	sinGate = LPF.ar(HPF.ar(inputAmp, hpfFreqGate), lpfFreqGate) * 5 > sinGateTrh;

	freqEnv = EnvGen.kr(Env([envFrqL1, envFrqL2, envFrqL3, envFrqL4, envFrqL5], [envFrqT1, envFrqT2, envFrqT3, envFrqT4], [envFrqC1, envFrqC2, envFrqC3, envFrqC4]), sinGate);
	env = EnvGen.kr(Env.asr(sinAtt, 1, sinRel, sinCurve), sinGate, doneAction: doneAction);
	sin = SinOsc.ar(freqEnv, 0, env);
	sin = BHiPass4.ar(sin, 20, 1, env);

	inputAmp = inputAmp + (sin * sinLevelPre);

	noiseType = noiseType.max(0).min(5);
	noise = Select.ar(noiseType, [
		WhiteNoise.ar(inputAmp),
		BrownNoise.ar(inputAmp),
		GrayNoise.ar(inputAmp),
		PinkNoise.ar(inputAmp),
		ClipNoise.ar(inputAmp),
		Crackle.ar(nType5Chaos, inputAmp)
	]);

	imp = Select.ar(impSource, [
		Impulse.ar(impFreq, 0, inputAmp),
		Dust.ar(impFreq, inputAmp)
	]);

	sig = (sin * sinLevelPost) + (noise * noiseLevel) + (imp * impLevel);
	sig = XFade2.ar(input, sig, drywet);
	ReplaceOut.ar(out, sig);
	//XOut.ar(out, drywet, sig);
}).add;

SynthDef(\jilet, { arg out=0, amp=0.20, pan = 0, att = 0.005, dec = 0.01, sus = 1.1, rel = 0.01, envOffset=0.5, freq=4, endReflection=1.5, jetReflection=0.5, jetRatio=10.72, noiseGain=0.35, vibFreq=5.925, vibGain=0.02, gate=1, doneAction = 2;

	var adsr = (envOffset*0.2) + EnvGen.ar(Env.adsr(att, dec, sus, rel), gate, doneAction: doneAction);
	var noise = WhiteNoise.ar(noiseGain.max(0.1));
	var vibrato = SinOsc.ar(vibFreq, 0, vibGain);

	var delay = (freq.min(340)*0.66666).reciprocal;
	var lastOut = LocalIn.ar(1);
	var breathPressure = adsr*Mix([1.0, noise, vibrato]);
	var filter = LeakDC.ar(OnePole.ar(lastOut.neg, 0.7));
	var pressureDiff = breathPressure - (jetReflection*filter);
	var jetDelay = DelayL.ar(pressureDiff, 0.025, delay*jetRatio);
	var jet = (jetDelay * (jetDelay.squared - 1.0)).clip2(1.0);
	var boreDelay = DelayL.ar(jet + (endReflection*filter), 0.05, delay);
	LocalOut.ar(boreDelay);
	boreDelay = Pan2.ar(boreDelay, pan, amp);
	OffsetOut.ar(out, 0.3*boreDelay);
}).add;

SynthDef(\pitchednoise, { arg out = 0, amp=0.1, pan=0.0, attack=0.01, release=10, freq=440, bandwidth=100, doneAction=2;
	var source, filter, env;
	// env = EnvGen.ar(Env([0,1,1,0],[attack, sustain, decay]), doneAction: doneAction);
	env = EnvGen.ar(Env.linen(attack, 1, release), doneAction: doneAction);
	source = WhiteNoise.ar;
	filter = BPF.ar(source*env*2*amp,freq,bandwidth/freq);
	OffsetOut.ar(out, Pan2.ar(filter,pan));
}).add;

SynthDef(\plastickystrings, { | out= 0 freq = 440 amp = 0.1 gate=1 lforate = 5900 lfowidth= 0.01 cutoff= 12000 rq=0.5 pan=0.0, doneAction=2 |
	var lfo, saw, filter, env;
	lfo = LFTri.ar(lforate,Rand(0,2.0));
	saw = Saw.ar(freq*(1.0+(lfowidth*lfo)),0.5);
	//filter = BBandPass.ar(saw,freq,4);
	filter = BHiPass.ar(saw,freq,rq); 	//or using cutoff
	env = EnvGen.ar(Env.adsr(0.4,0.0,1.0,1.0),gate,doneAction: doneAction);
	OffsetOut.ar(out,Pan2.ar(filter*env, pan, amp));
}).add;

~resSynthDef = SynthDef(\res, { | out = 0, amp = 1, pan = 0, att = 0, rel = 0.7, freqSin = 52, ampSin = 1, freqSaw = 22, ampSaw = 1, oscMix = 0.5, freqClc = 7302, harmClc = 200, ampClc = 0.5, maxL = 1, t1Clc = 0.001, t2Clc = 0.03, t3Clc = 0.01, gFreq = 12, damp = 0, fric = 0.001, doneAction = 2|
	var aEnv, osc, sig, flt, clic;
	aEnv = EnvGen.kr(Env.perc(att, rel), doneAction: doneAction);
	osc = Mix([SinOsc.ar(freqSin, 0, ampSin), Saw.ar(freqSaw, ampSaw)]) * aEnv;
	clic = Blip.ar(freqClc, harmClc, ampClc) * EnvGen.kr(Env.step([0, maxL, 0], [t1Clc, t2Clc, t3Clc]));
	sig = (osc * oscMix) + (clic * (1 - oscMix));
	sig = sig + Ball.ar(sig, LFNoise1.kr(gFreq, 0.5, 0.5), damp, fric) * aEnv;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

/*~resSynthDef = SynthDef(\res, { | out = 0, amp = 1, pan = 0, att = 0, rel = 0.7, freqSaw = 40, freqPls = 62, wPls = 0.5, rlpfRq = 0.1, lfnFreq = 0.3, lfnMul = 1000, lfnAdd = 1500, t_gate = 1, doneAction = 2|
	var aEnv, osc, flt, fltBus;
	aEnv = EnvGen.kr(Env.perc(att, rel), t_gate, doneAction: doneAction);
	fltBus = Bus.control(s, 1);
	osc = Mix([Saw.ar(freqSaw), Pulse.ar(freqPls, wPls)]);
	flt = RLPF.ar(osc, In.kr(fltBus, 1), rlpfRq, aEnv);
	ReplaceOut.kr(fltBus, LFNoise1.kr(lfnFreq, lfnMul, lfnAdd));

	OffsetOut.ar(out, Pan2.ar(flt, pan, amp));
}).add;*/

~mutantFricSynthDef = SynthDef(\mutantFric, { arg out = 0, amp = 1, attack = 0.01, release = 1, spec1 = 0.00001, spec2 = 0.03, noiseFreq = 3, sigFreq = 50, spring = 0.414, damp = 0.313, beltmass = 1, source = 0, hpfFreq = 50, gate = 1, doneAction = 2;
	var friction, sig;
	friction = Array.fill(5, {
		[spec1.max(0.00001), spec2.max(0.03)].asSpec.map(LFNoise2.kr(noiseFreq))
	});
	sig = Select.ar(source, [
		LFTri.ar(sigFreq),
		LFPar.ar(sigFreq),
		LFCub.ar(sigFreq),
		LFSaw.ar(sigFreq),
		LFDNoise3.ar(sigFreq),
		LFDNoise0.ar(sigFreq)
	]);
	sig = Friction.ar(sig, friction, Lag2.kr(spring), damp, friction*30000, beltmass);
	sig = HPF.ar(sig, hpfFreq);
	sig = sig * EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	OffsetOut.ar(out, Splay.ar(sig * amp));
}).add;

~tweetSynthSynthDef = SynthDef(\tweetSynth, { arg out = 0, amp = 1, freq = 25, rate = 8, attack = 0.01, release = 10, sigatt = 0.01, sigdec = 3.16, thresh = 0.5, ratio = 1, revMix = 0, revRoom = 0.5, revDamp = 0.5, t_trig = 1, doneAction = 2;
	var sig, demand, env, sigenv;
	demand = Demand.kr(
		t_trig,
		0,
		Drand(freq, inf)
	);
	sig = (
		BHiPass.ar(
			LFNoise1.ar(rate) ** 3,
			[demand, demand + 0.2].midicps,
			demand / 2e3,
			67 - demand
		)
	).tanh;
	sigenv = EnvGen.kr(Env.asr(sigatt, 1, sigdec), t_trig);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	sig = sig * sigenv * env;
	sig = Compander.ar(sig, sig, thresh.max(0.01), 1, ratio);
	sig = FreeVerb2.ar(sig[0], sig[1], Lag2.kr(revMix), revRoom, revDamp);
	OffsetOut.ar(out, sig * amp);
}).add;

~tweetFogAttackSynthDef = SynthDef(\tweetFogAttack, { arg out = 0, amp = 1, attack = 0.01, release = 10, sigatt = 0.01, sigdec = 3.16, feedBack = 0.2, freq = 0.8, t_trig = 1, doneAction = 2;
	var sig, env, coef, sigenv;
	sig = Pulse.ar(freq*(pi/[1,2.57]),[0.54,0.46]);
	coef = (1-LocalIn.ar(2)).fold(0,[0.9,0.85]);
	sig = LeakDC.ar(Integrator.ar(sig, coef).wrap2(pi).sin);
	LocalOut.ar(sig * feedBack);
	sigenv = EnvGen.kr(Env.asr(sigatt, 1, sigdec), t_trig);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	sig = (sig.mean!2) * sigenv * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\tweetErosion, { arg out = 0, amp = 0.3, attack = 0.01, release = 10, feedBack = 1, t_trig = 1, doneAction = 2;
	var sig, env, input, div, envIndex, xyc;
	input = LocalIn.ar(2).range(0,0.9)+0.1;
	div = LagUD.ar(input, 0, 0.2);
	sig = PinkNoise.ar(1!2);
	sig = tanh(500 * (sig**(8/div)));
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	LocalOut.ar(sig * feedBack);
	sig = Splay.ar(sig,1-input);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\harshTexture, { arg out = 0, amp = 1, attack = 0.01, release = 10, impFreq = 2, delTimeMod = 0.5, t_trig = 1, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	sig = Impulse.ar(impFreq).lag(0.3)!2;
	5.do {
		sig = LeakDC.ar(
			AllpassC.ar(
				sig,
				1,
				LFNoise0.ar(delTimeMod).range(1e-5,0.2),
				-0.15,
				LFNoise0.ar(delTimeMod).range(1,3)
			)
		).tanh;
	};
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\ultraHiSummer, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 10, curve = (-4), blpFreq1 = 16e3, blpFreq2 = 16150, seqRate = 0.2, seqVal1 = 70, seqVal2 = 30, seqVal3 = 0, t_trig = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release, curve: curve), t_trig, doneAction: doneAction);
	sig = Blip.ar(
		[blpFreq1, blpFreq2],
		2,
		LFSaw.ar(
			Duty.ar(
				LFNoise0.ar(seqRate,4,6),
				0,
				Dseq([seqVal1, seqVal2, seqVal3], inf)
			)
		).clip(0, 1)
	);
	sig = (sig[0] + sig[1]) * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\ambiantPic, { arg out = 0, amp = 0.3, attack = 0.01, release = 10, lfnFreq = 22, lfnAmp = 5, lfnOffset = 9, ampDst1 = 4, ampDst2 = 2, durDst1 = 0.5, durDst2 = 1, adPar1 = 1/9, adPar2 = 1/4, ddPar1 = 1/2, ddPar2 = 1/8, delTime1 = 0.13, delTime2 = 0.1, decTime = 0.2, t_trig = 1, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	sig = LFNoise2.kr(lfnFreq, lfnAmp, lfnOffset);
	sig = CombC.ar(
		Splay.ar(
			Gendy3.ar(
				[ampDst1, ampDst2],
				[durDst1, durDst2] * decTime,
				[adPar1, adPar2]*sig,
				[ddPar1, ddPar2]*sig,
				(9,49..199)
			)
		),
		5,
		[delTime1, delTime2],
		[sig/2,sig/2.1] * decTime
	);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

~attBreathSynthDef = SynthDef(\attBreath, { arg out = 0, amp = 1, attack = 0.01, release = 2, seqv1 = 1, seqv2 = 1, seqv3 = 4, seqv4 = 2, seqv5 = 2, seqFreq = 0.2, freqMin = 250, freqMax = 800, bwrMod = 0.5, t_trig = 1, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	sig = TDuty.kr(Dseq([seqv1, seqv2, seqv3, seqv4, seqv5] * seqFreq, inf));
	sig = Resonz.ar(
		Crackle.ar(sig.range(0.6, 1.6))!2,
		Demand.kr(sig, 0, Dseq([freqMin, freqMax], inf)),
		Demand.kr(sig, 0, Dwhite(0.01,0.5, inf)) * bwrMod
	);
	sig = sig * env;
	//sig = Compander.ar(sig, sig, 0.4, 1, 1/3);
	OffsetOut.ar(out, sig * amp);
}).add;

~attWindSynthDef = SynthDef(\attWind, { arg out = 0, amp = 1, attack = 0.01, release = 2, seq1 = 1, seq2 = 1, seq3 = 4, seq4 = 2, seq5 = 2, seqDiv = 8, freq1 = 250, freq2 = 8000, bwrLo = 0.01, bwrHi = 0.5, t_trig = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = TDuty.kr(Dseq([seq1, seq2, seq3, seq4, seq5] / seqDiv, inf));
	sig = Resonz.ar(
		WhiteNoise.ar!2,
		Demand.kr(sig, 0, Dseq([freq1, freq2], inf)),
		Demand.kr(sig, 0, Dwhite(bwrLo, bwrHi, inf))
	);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

~dStowellSynthDef = SynthDef(\dStowell, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 2, freq = 6/3, width = 1/5, lpf = 20000, t_trig = 1, doneAction = 2;
	var sig, env, spec, input;
	spec = `[{exprand(100,1000)}.dup(50)];
	input = Saw.ar(
		LFPulse.kr(freq,0,width).range(3,3000),
		0.0005
	);
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = Klank.ar(spec, input);
	sig = LPF.ar(sig, lpf);
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\henon, { arg out = 0, amp = 0.1, pan = 0, freq = 440, a = 1.3, b = 0.3, x0 = 0.30501993062401, x1 = 0.20938865431933, atk = 0.01, sus = 1, rel = 1, ts = 1, t_trig = 1, doneAction = 2;
	var sig,env;
	sig = HenonN.ar(freq,a,b,x0,x1,amp);
	env = EnvGen.ar(Env.linen(atk,sus,rel),t_trig,1,0,ts,doneAction);
	sig = LeakDC.ar(sig);
	sig = sig*env;
	OffsetOut.ar(out,Pan2.ar(sig,pan));
}).add;

~harrishSynthDef = SynthDef(\harrish, {| out = 0, amp = 0.2, pan = 0, attack = 0, sustain = 0.2, release = 0.1, curve = 0, clipLevel = 0.006, impFreq = 0, impPhase = 0, impLevel = 1, noiseLevel = 0.3, lpf = 20000, eqfreq = 4000, eqrq = 1, eqdb = 0, hpf = 20,  doneAction = 2|
	var env = EnvGen.ar(Env.linen(attack, sustain, release, curve: curve), doneAction: doneAction);
	var snd = (ClipNoise.ar(clipLevel) + Impulse.ar(impFreq, impPhase, impLevel) + BrownNoise.ar(noiseLevel)) * env;
	snd = LPF.ar(snd, lpf);
	snd = BPeakEQ.ar(snd, Lag2.kr(eqfreq.max(20).min(20000), 0.5), eqrq, eqdb);
	snd = HPF.ar(snd, hpf);
	OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
}).add;

~kSpluck3SynthDef = SynthDef(\kSpluck3, { arg out = 0, amp = 0.2, att = 0, rel = 0.01, midiPitch = 24, art = -3, noiseFreq = 1, noiseLev = 13000, noiseOffset = 14010, mix = 0.5, doneAction = 2;
	var burstEnv;
	var sig, delayTime;
	delayTime = [midiPitch, midiPitch + 12].midicps.reciprocal;
	burstEnv = EnvGen.kr(Env.perc(att, rel));
	sig = PinkNoise.ar([burstEnv, burstEnv]); //Noise burst
	sig = CombL.ar(sig, delayTime, delayTime, art, add: sig); //Echo chamber
	sig = XFade2.ar(sig, RLPF.ar(sig, LFNoise1.kr(noiseFreq, noiseLev, noiseOffset), 0.1), mix, amp); //Filter ADSR GELSIN BURAYA
	DetectSilence.ar(sig, doneAction: doneAction);
	OffsetOut.ar(out, sig);
}).add;

~lumbricostSynthDef = SynthDef(\lumbricost, {arg out = 0, amp = 0.2, pan = 0, attTim= 1, relTim=2.5, scale= 6, offset = 40, freq = 10, timescale = 10, widthmod = 0.4, width = 0.2, abc = 0, randLo = 0, randHi = 20000, bprq = 1, t_gate = 1, doneAction = 2;
	var generation =
	Pulse.ar(SinOsc.kr(5/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(30/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(7/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(7/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(9/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(2/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(10/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(5/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(3/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(9/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(2/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(40/freq),widthmod,width,timescale), mul: 0.1);
	var env = generation * EnvGen.kr(Env.perc(attackTime:attTim,releaseTime: relTim), t_gate, doneAction: doneAction);
	var env1 = LeakDC.ar(env);
	var sig = env1 * amp;
	sig = BPF.ar(sig, Rand(randLo-100, randHi+100), bprq);
	OffsetOut.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef(\tirgo, { arg out = 0, amp = 1, att = 0.01, rel = 5, blipFreqMod = 2, blipHarmo = 400, brfFreq = 150, brfRq = 2, gate = 1, doneAction = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	noise = PinkNoise.ar(1!2);
	rainStep = noise + Blip.ar(noise + blipFreqMod, blipHarmo);
	rainStep = BRF.ar(
		rainStep,
		brfFreq,
		brfRq,
		0.1
	);
	thunder = LPF.ar(FreeVerb2.ar(*LPF.ar(noise + 0.2 * Dust.ar(0.1), 60) ++ [1, 1, 0.2, 1e4]).tanh, 2000);
	sig = rainStep + thunder;
	OffsetOut.ar(out, sig * env * amp);
}).add;

SynthDef(\lmcd, { arg out = 0, amp = 1, att = 0.01, rel = 5, trigDur = 0.1, lfCubTu = 1, hpfFreq = 440, gate = 1, doneAction = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	sig = Duty.kr(trigDur, 0, Dseq(fib(32).wrap(20, 55).midicps, inf));
	sig = LFCub.ar([-1, sig, sig / 3, -2] * lfCubTu);
	sig = LeakDC.ar(sig) * 9;
	sig = HPF.ar(sig, hpfFreq).clip2 / 9;
	sig = Splay.ar(sig);
	OffsetOut.ar(out, sig * env * amp);
}).add;

~plouxSynthDef = SynthDef(\ploux, { arg out = 0, amp = 0.1, pan = 0, att = 0.1, dec = 0.1, sus = 0.8, rel = 0.1, feedBack = 0, fbPost = 0, dustfreq = 2, dustdecay = 0.7, freq = 200, fmfreq = 100, folAtt = 0.01, folDec = 0.2, sinMix = 1, a = 1, b = 3, c = 0.5, d = 0.5, xi = 0.5, yi = 0.5, t_trig = 1, doneAction = 2;
    var sig, dust, input, inMod, envFol, freqMod;
	input = LocalIn.ar(2);
	inMod = input * feedBack;
    dust = Dust.ar(dustfreq);
    dust = Decay.ar(dust, dustdecay);
	freqMod = SinOsc.ar(fmfreq * dust) * inMod + 1;
    sig = SinOsc.ar(freq * freqMod);
	envFol = Amplitude.kr(sig, folAtt, folDec);
	sig = (sig * sinMix) + (RHPF.ar(LatoocarfianN.ar(freqMod.range(2000, 22050), a, b, c, d, xi, yi, LFNoise0.kr(dust)), input.range(20, 20000)) * (1 - sinMix));
    sig = sig * EnvGen.kr(Env.adsr(att, dec, sus, rel), t_trig, doneAction: doneAction);
	LocalOut.ar(sig * fbPost);
	sig = sig.tanh;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}, [\kr ! 22, \tr, \ir].flat).add;

~complexoscSynthDef = SynthDef(\complexosc, { arg out = 0, amp = 1, feedBack = 1, envL1 = 0, envL2 = 2.2, envL3 = 0.12, envL4 = 0, envT1 = 0.01, envT2 = 0.24, envT3 = 0.12, envCurve = (-4), freq1 = 40, fm1 = 0.1, pm1 = 0, amp1 = 1, ring1 = 1, offset1 = 0, freq2 = 0.5, fm2 = 0.1, pm2 = 0, amp2 = 1, ring2 = 1, offset2 = 0, fold = 0.8, wrap = 0.9, switch = 2, t_trig = 1, doneAction = 2;
    var osc1, osc2, fbk, outlet, folded, wrapped, env, sigenv;
    fbk = LocalIn.ar(2) * feedBack;
	//env = Linen.kr(t_trig, attack, 1, release, doneAction);
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), t_trig, doneAction: doneAction);
    osc1 = SinOsc.ar(freq1 + (fbk[1].range(1,1000) * fm1), 0 + (fbk[1].range(-pi,pi) * pm1), amp1 + (fbk[1] * ring1), offset1);
    osc2 = SinOsc.ar(freq2 + (fbk[0].range(1,1000) * fm2), 0 + (fbk[1].range(-pi,pi) * pm2), amp2 + (fbk[0] * ring2), offset2);
    LocalOut.ar([osc1, osc2]);
    folded = Fold.ar(osc1 ! 2, fold.neg, fold);
    wrapped = Wrap.ar(osc1 ! 2, wrap.neg, wrap);
    outlet = LeakDC.ar(Select.ar(switch, [osc1!2, osc2!2, folded, wrapped]));
    OffsetOut.ar(out, outlet * env * amp);
}, [\kr ! 11, \ar ! 14, \kr, \tr, \ir].flat).add;

~benjolisSynthDef = SynthDef(\benjolis,{ |out = 0, amp = 0.1, fadeTime = 0.01, freq1= 40, freq2=4, scaler=1, rungler1=0.16, rungler2=0.0, runglerFilt=9, loop=0, filtFreq=40, rq=0.82, gain=1, filterType=0, outSignal=6, doneAction = 2|
	var osc1, osc2, tri1, tri2, sh0, sh1, sh2, sh3, sh4, sh5, sh6, sh7, sh8=1, rungler, pwm, filt, output;
	var sr;
	var osc2freq, buf, bufR;

	bufR = LocalIn.ar(2,0);
	rungler = bufR.at(0);
	buf = bufR.at(1);

	sr = SampleDur.ir;
	//sr = ControlDur.ir;
	tri1 = LFTri.ar((rungler*rungler1)+freq1);
	tri2 = LFTri.ar((rungler*rungler2)+freq2);
	osc1 = PulseDPW.ar((rungler*rungler1)+freq1);
	osc2 = PulseDPW.ar((rungler*rungler2)+freq2);

	//pwm = tri1 > tri2;
	pwm = BinaryOpUGen('>', (tri1 + tri2),(0));

	osc1 = ((buf*loop)+(osc1* (loop* -1 +1)));
	sh0 = BinaryOpUGen('>', osc1, 0.5);
	sh0 = BinaryOpUGen('==', (sh8 > sh0), (sh8 < sh0));
	sh0 = (sh0 * -1) + 1;

	sh1 = DelayN.ar(Latch.ar(sh0,osc2),0.01,sr);
	sh2 = DelayN.ar(Latch.ar(sh1,osc2),0.01,sr*2);
	sh3 = DelayN.ar(Latch.ar(sh2,osc2),0.01,sr*3);
	sh4 = DelayN.ar(Latch.ar(sh3,osc2),0.01,sr*4);
	sh5 = DelayN.ar(Latch.ar(sh4,osc2),0.01,sr*5);
	sh6 = DelayN.ar(Latch.ar(sh5,osc2),0.01,sr*6);
	sh7 = DelayN.ar(Latch.ar(sh6,osc2),0.01,sr*7);
	sh8 = DelayN.ar(Latch.ar(sh7,osc2),0.01,sr*8);

	//rungler = ((sh6/8)+(sh7/4)+(sh8/2)); //original circuit
	//rungler = ((sh5/16)+(sh6/8)+(sh7/4)+(sh8/2));

	rungler = ((sh1/2.pow(8))+(sh2/2.pow(7))+(sh3/2.pow(6))+(sh4/2.pow(5))+(sh5/2.pow(4))+(sh6/2.pow(3))+(sh7/2.pow(2))+(sh8/2.pow(1)));

	buf = rungler;
	rungler = (rungler * scaler.linlin(0,1,0,127));
	rungler = rungler.midicps;

	LocalOut.ar([rungler,buf]);



	filt = Select.ar(filterType, [
		RLPF.ar(pwm,(rungler*runglerFilt)+filtFreq,rq/** -1 +1*/,gain),
		//BMoog.ar(pwm,(rungler*runglerFilt)+filtFreq,rq,0,gain),
		RHPF.ar(pwm,(rungler*runglerFilt)+filtFreq,rq/** -1 +1*/,gain),
		SVF.ar(pwm,(rungler*runglerFilt)+filtFreq,rq,1,0,0,0,0,gain),
		DFM1.ar(pwm,(rungler*runglerFilt)+filtFreq,rq,gain,1)
	]);


	output = SelectX.ar(outSignal, [
		tri1, osc1, tri2, osc2, pwm, sh0, filt

	]);
	output = LeakDC.ar(output * amp ! 2);
	OffsetOut.ar(out, output * EnvGate(fadeTime: fadeTime, doneAction: doneAction));
}).add;

~bytebeatsSynthDef = SynthDef(\bytebeats, { arg out = 0, amp = 0.2, envL1 = 0, envL2 = 1, envL3 = 0.2, envL4 = 3.2, envL5 = 0, envT1 = 0.12, envT2 = 0.02, envT3 = 0, envT4 = 0.2, curve1 = (-4), curve2 = (-4), curve3 = (-4), curve4 = (-4), counterFreq = 1, counterMul = 3.5, counterAdd = 3.5, srDiv = 6, freq = 232, doneAction = 2;
	//var sr = SampleRate.ir/6; //fix sample rate
	var counter, env;
	var sr = SampleRate.ir/srDiv; //variable sample rate
	//var freq = 10;
	var n = 16; //bit resolution
	var t= Phasor.ar(1,freq*((2**n)/sr),0,((2**n)-1)); //creating a raising value from 0 to 2**n
	//t = t & (2**(n-1)); // few tests
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4], [curve1, curve2, curve3, curve4]), doneAction: doneAction);
	//equations: try one at the time
	t = t * 4;
	//counter = LFSaw.ar(0.5,0,3.5,3.5); // browse the equations
	counter = LFDNoise0.ar(counterFreq, counterMul, counterAdd);
	//counter.poll;
	t = SelectX.ar(counter,[

	t*(((t>>12)|(t>>8))&(63&(t>>4))),
	t*(((t>>9)|(t>>13))&(25&(t>>6))),
	t*(((t>>5)|(t>>8)) & 63),
	t*(((t>>11)&(t>>8))&(123&(t>>3))),
	t*(t>>8*((t>>15)|(t>>8))&(20|(t>>19)*5>>t|(t>>3))),
	t*(t>>((t>>9)|(t>>8))&(63&(t>>4))),
	(t>>7|t|t>>6)*10+4*(t&t>>13|t>>6)
	]);

	t = t % (2**(n));// avoiding number beyond 2**(bit resolution)
	t = t*(0.5**(n-1)) - 1;//scaling to -1, 1

	t = LeakDC.ar((t * amp).dup);
	OffsetOut.ar(out, t * env);
}).add;

~feedbackOscSynthDef = SynthDef(\feedbackOsc, {|out=0, amp = 0.2, attack=0.01, release=1, mFrq= 313, mFB= 1, freq= 100, fB= 1, width= 0, mul= 500, ffreq=1000, rq=1, gate = 1, doneAction = 2|
	var w= [0, width*2pi];
	var buf= LocalBuf(1).clear;
	var buf2= LocalBuf(1, 2).clear;
	var osc= sin(LFSaw.ar(mFrq).range(0, 2pi)+(Dbufrd(buf)*mFB));
	var snd= Duty.ar(SampleDur.ir, 0, Dbufwr(osc, buf));
	var osc2= sin(LFSaw.ar(freq+(snd*mul)).range(0, 2pi)+(Dbufrd(buf2)*fB)+w);
	var snd2= Duty.ar(SampleDur.ir, 0, Dbufwr(osc2, buf2));
	//var filter= RLPF.ar(snd2, ffreq, rq);
	var filter = DFM1.ar(snd2, ffreq, rq);
	var env = EnvGen.ar(Env.asr(attack, 1, release),gate,doneAction: doneAction);
	OffsetOut.ar(out,filter * amp * env/*EnvGate(gate: gate, doneAction: doneAction)*/);
}).add;

SynthDef(\salledutemps, { arg out = 0, amp = 1, attack = 1, release = 4, tu = 1, dur = 9, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = {DynKlank.ar(`[((55/2)+ (tu * (Demand.kr(Impulse.kr(0), 0, Diwhite(0, 6))*2*(55/24))))*(2**(0..8))],Crackle.ar(2,0.005))*LFGauss.ar(dur,0.7,0,1)}!5;
	sig = sig * env;
	sig = Splay.ar(sig);
	OffsetOut.ar(out, sig * amp);
}).add;

~salledutemps1SynthDef = SynthDef(\salledutemps1, { arg out = 0, amp = 1, attack = 1, release = 4, tu = 1, myst = 55, dur = 9, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = {DynKlank.ar(`[((myst/2)+ (tu + (tu * (Demand.kr(Impulse.kr(0), 0, Diwhite(0, 6))*2*(myst/24)))))*(2**(0..8))],Crackle.ar(2, 0.005))*LFGauss.ar(dur,0.7,0,1)}!5;
	sig = sig * env;
	sig = Splay.ar(sig);
	OffsetOut.ar(out, sig * amp);
}).add;

~cormanSynthDef = SynthDef(\corman, { arg out = 0, amp = 1, attack = 1, release = 10, tu = 1, dur = 9, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = {DynKlank.ar(`[(tu * Demand.kr(Impulse.kr(0), 0, Diwhite(0, 98)))*(1..9)],Crackle.ar(2,0.01))*LFGauss.ar(dur,0.7,0,1)}!2;
	sig = sig * env;
	sig = Splay.ar(sig);
	OffsetOut.ar(out, sig * amp);
}).add;

~corman1SynthDef = SynthDef(\corman1, { arg out = 0, amp = 1, attack = 1, release = 10, tu = 1, dur = 9, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = {DynKlank.ar(`[(tu + (tu * Demand.kr(Impulse.kr(0), 0, Diwhite(0, 98))))*(1..9)],Crackle.ar(2,0.01))*LFGauss.ar(dur,0.7,0,1)}!2;
	sig = sig * env;
	sig = Splay.ar(sig);
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef.new(\Shai, { arg out = 0, amp=0.1, freq=440, atk=1, rel=8, doneAction = 2;
	var sig, env;
	sig = Mix.new(
		Array.fill(32, { SinOsc.ar(freq + Line.kr(1536.0.rand,freq*1.5,8), 0, 0.05) })
	);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction: doneAction);
	sig = sig*env*amp;
	OffsetOut.ar(out, [sig, sig]);
}).add;

SynthDef.new(\Colleen3, { arg out = 0, amp=1, pan = 0, freq=110, atk=0.01, rel=2, lpf = 4000, lpfmin = 500, lpfmax = 16000, hpfmin = 1, hpfmax = 2000, doneAction = 2;
	var sig, env;
	freq = freq*(565/250)*PinkNoise.kr(0.01,1)*BrownNoise.kr(0.00,1)*0.36;
	sig = LPF.ar(CombC.ar(Decay.ar(Impulse.ar(0), 0.2, BrownNoise.ar), 4/(BrownNoise.kr(XLine.kr(10,1,0.2),freq)), 4/(PinkNoise.kr(XLine.kr(10,1,0.2),freq)), 3, 0.4),lpf);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction: doneAction);
	env = env**2;
	sig = sig + PinkNoise.ar(0.1);
	sig = LPF.ar(sig, XLine.kr(lpfmin,lpfmax,rel/6));
	sig = HPF.ar(sig, XLine.kr(hpfmin,hpfmax,rel/6));
	sig = (sig*env*amp)*0.7;
	sig = Pan2.ar(sig,pan);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\combs, { arg out = 0, amp = 0.1, pan = 0, att = 0.01, dec = 0.1, sus = 0.7, rel = 0.5, freq = 440, rate = 6, depth = 0.2, regen = -3, sweep = 16, rq = 0.5, harmonic = 1.5, gate = 1, doneAction = 2;

	var max, min, vibrato, snd, env, filterenv;

	//Setting some values for the filters:
	max = ((1 + depth) / freq);
	min = (1 / (freq * (1 + depth)));
	vibrato = LFNoise1.ar(rate).range(min, max);

	//Amplitude and filter cutoff envelopes
	env = Env.adsr(att, dec, sus, rel).kr(gate: gate, doneAction: doneAction);
	filterenv = Env.perc(att, rel).kr;
	filterenv = ((filterenv * sweep) + 1) * freq;

	//The core noise:
	snd = BrownNoise.ar(1);
	snd = CombL.ar(snd, max, vibrato, regen);
	snd = CombN.ar(snd, harmonic / freq, harmonic / freq, regen, env);

	//More filters and output stuff:
	snd = RHPF.ar(snd, freq * 4, rq);
	snd = RLPF.ar(snd, filterenv, rq, amp);
	snd = Limiter.ar(snd, amp);
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\werkit, { arg out = 0, amp = 0.1, pan = 0.0, att = 0.01, dec = 0, sus = 1, rel = 1, freq = 440, rq = 0.1, gate = 1,doneAction = 2;

	var source, filter, env, snd, delayEnv;
	source = WhiteNoise.ar;
	filter = BLowPass4.ar(source, freq, rq) * 0.3;
	env = EnvGen.ar(
		envelope: Env.adsr(att, dec, sus, rel, amp),
		gate: gate,
		doneAction: 2);
	snd = (0.7 * filter + (0.3 * filter.distort)) * env;
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef(\werkit2, { arg out = 0, amp = 0.1, att = 0.01, dec = 0, sus = 1, rel = 0.1, freq = 440, rq = 0.1, gate = 1, doneAction = 2;

	var source, filter, env, snd;
	source = LFSaw.ar(Array.fill(16, { Rand(100, 200) }));
	filter = BLowPass4.ar(source, freq, rq) * 0.1;
	env = EnvGen.ar(
		envelope: Env.adsr(att, dec, sus, rel, amp),
		gate: gate,
		doneAction: doneAction);
	snd = (0.7 * filter + (0.3 * filter.distort)) * env;
	snd = HPF.ar(snd, 100);
	snd = Splay.ar(snd);
	OffsetOut.ar(out, snd);
}).add;

~impnSynthDef = SynthDef(\impn,{ arg out = 0, amp=0.75, pan = 0, att = 0.001, rel = 0.1, curve = (-5), impRate = 10, kfreq = 1, kdec = 1, tu = 1, freq = 10327, bwr = 1, delTime = 0.25, decTime = 1, doneAction = 2;
	var env, sig;
	env = EnvGen.kr(Env.linen(att, 1, rel, 1, curve), doneAction: doneAction);
	sig = Impulse.ar(impRate);
	sig = DynKlank.ar(
		Ref.new([
			[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421] * tu,   // harmonics
			[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]     // ring times
		]),
		sig,
		kfreq,
		decayscale: kdec
	);
	sig = Resonz.ar(sig, freq, bwr);
	sig = CombL.ar(sig, 6, delTime, decTime);
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

/*SynthDef(\dobsonFfitch, { |out, freq = 50, freqFactor = 1.01, a = -0.4, b = 0.6, c = 0.2,
    d = 0.75, l = 32, limitType = 1, amp = 0.2|
    var src, sig;
    src = Saw.ar([1, freqFactor] * freq);
    sig = Fb1.ar({ |in, out|
        var x = (a * out[1]) + (b * out[2]) + (d * Select.kr(l, out).squared) + in[0] - c;
        Select.kr(limitType, [x.tanh, x.softclip, x.distort])
        },
        in: src, outSize: 2, outDepth: 50,
        blockSize: s.options.blockSize,
        blockFactor: 64 / s.options.blockSize
    ) * amp;
    // cut off some high frequencies
    Out.ar(0, LPF.ar(sig, 15000))
}).add;*/

SynthDef(\LiljedMyst, { arg out = 0, amp = 0.6, attack = 0.01, release = 4, pNoiseFreq = 5e-3, hpfFreq = 10, modDur = 9, lfnFreq = 0.05, ringFreq = 55, ringDec = 0.2, revSize = 70, revTime = 99, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	sig = HPF.ar(PinkNoise.ar(pNoiseFreq), hpfFreq) * Line.kr(0, 1, modDur);
	sig = GVerb.ar(
		({ |i|
			Ringz.ar(
				sig * LFNoise1.kr(lfnFreq + 0.1.rand),
				ringFreq * i + 60,
				ringDec
			)
		}!44).sum,
		revSize,
		revTime
	).tanh;
	sig = sig * env * amp;
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\LiljedRain, { arg out = 0, amp = 0.6, attack = 0.01, release = 2, nFrqR = 0.08, lfnFrqR1 = 0.3, lfnFrqR2 = 0.2, lpfR = 7000, hpfR = 400, revSizeR = 250, revTimeR = 100, revDampR = 0.25, dryLevR = 0.3, modDurR = 10, lfnFrqT1 = 3, lfnFrqT2 = 2, hpfT = 20, revSizeT = 270, revTimeT = 30, revDampT = 0.7, dryLevT = 0.5, modDurT = 30, gate = 1, doneAction = 2;
	var sig, env, rain, thunder;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);

	rain = PinkNoise.ar(nFrqR + LFNoise1.kr(lfnFrqR1, 0.02));
	rain = rain + LPF.ar(Dust2.ar(LFNoise1.kr(lfnFrqR2).range(40, 50)), lpfR);
	rain = tanh(
		3 * GVerb.ar(
			HPF.ar(
				rain,
				hpfR
			),
			revSizeR,
			revTimeR,
			revDampR,
			drylevel: dryLevR
		) * Line.kr(0, 1, modDurR)
	);

	thunder = 10 * HPF.ar(PinkNoise.ar(LFNoise1.kr(lfnFrqT1).clip(0, 1) * LFNoise1.kr(lfnFrqT2).clip(0, 1) ** 1.8), hpfT);
	thunder = GVerb.ar(
		LPF.ar(
			thunder,
			LFNoise1.kr(1).exprange(100, 2500)
		).tanh,
		revSizeT,
		revTimeT,
		revDampT,
		drylevel: dryLevT
	) * Line.kr(0, 0.7, modDurT);

	sig = (rain + thunder) * env * amp;
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\lcm2, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, mod1 = 3.09431, mod2 = 54.0487, gate = 1, doneAction = 2;
    var sig, sig1, sig2, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    mod1 = mod1.min(1000).max(1);
    mod2 = mod2.min(1000).max(1);

    sig1 = Saw.ar(mod1).range(-100,100).round(1);
    sig2 = LFCub.ar(mod2).range(-100,100).round(1);

    sig = tanh(lcm(sig1, sig2) * 0.001);

    sig = sig * env;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

/*SynthDef(\danScar, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.2, sustain = 1.5, curve = 4, sinFreq = 30, noiseFreq = 1, lpfFreq = 15000, doneAction = 2;
	var sig, globalEnv, inSig, lfo;

	globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);

	inSig = SinOsc.ar(sinFreq + [0, 0.1]);
	lfo = LFDNoise1.kr(noiseFreq).linexp(-1, 1, 0.5, 1);

	sig = LPF.ar(
		Fb1.ar(
			{ |in, out| in[0] - (out[1] % lfo) },
			inSig, 2, blockSize: s.options.blockSize
		),
		lpfFreq
	) * amp;

	sig = Pan2.ar(sig, pan);

	OffsetOut.ar(out, sig * globalEnv);
}).add;

SynthDef(\danScar1, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.2, sustain = 1.5, curve = 4, sinFreq = 30, noiseFreq = 1, lpfFreq = 15000, doneAction = 2;
	var sig, globalEnv, inSig, lfo;

	globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);

	inSig = SinOsc.ar(sinFreq + [0, 0.1]);
	lfo = LFDNoise1.ar(noiseFreq).linexp(-1, 1, 0.5, 1);

	sig = LPF.ar(
		Fb1.ar(
			// in[0][0] is the current stereo sample of inSig
			// in[0][1] is the current mono sample of lfo
			{ |in, out| in[0][0] - (out[1] % in[0][1]) },
			[inSig, lfo], 2, blockSize: s.options.blockSize
		),
		lpfFreq
	) * amp;

	sig = Pan2.ar(sig, pan);

	OffsetOut.ar(out, sig * globalEnv);
}).add;

SynthDef(\danScar2, { arg out = 0, amp = 0.1, attack = 0, release = 1.2, sustain = 1.5, curve = 4, triFreq = 60, noiseFreq = 0.5, doneAction = 2;
	var sig, globalEnv, inSig, lfo;

	globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);

	inSig = LFTri.ar(triFreq);
	lfo = { LFDNoise3.ar(0.5).linexp(-1, 1, 0.1, 150) } ! 2;

	sig = Fb1.ar(
		// in[0][0] is the current stereo sample of inSig
		// in[0][1] is the current mono sample of lfo
		{ |in, out| in[0][0] - (out[1] % in[0][1]) },
		[inSig, lfo], 2, blockSize: s.options.blockSize
	) * amp;

	OffsetOut.ar(out, sig * globalEnv);
}).add;*/

SynthDef(\natwich, { arg out = 0, amp = 0.3, pan = 0, attack = 0, release = 1.2, sustain = 1.5, curve = 4, modFreq = 0.4, modAmount = 0.8, sawFreq = 2100, rlpfFreq = 4000, rlpfRq = 0.1, doneAction = 2;
    var snd, fb, sig, globalEnv, mod1, mod2;

    globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);

    mod1 = LFDNoise3.kr(modFreq, modAmount).range(0.1, 1.5);
    mod2 = LFDNoise0.kr(modFreq, modAmount).range(0.1, 1.5);

    fb = LocalIn.ar(1);
    snd = Saw.ar(sawFreq * mod1 * (fb * 48).midiratio);
    snd = RLPF.ar(snd, rlpfFreq * mod2 * (48 * (1 - fb)).midiratio, rlpfRq);
    snd = (snd * 3).fold2;
    sig = snd;
    snd = Amplitude.ar(ToggleFF.ar(PulseDivider.ar(snd, 3 * (1 + (100 * fb)))), 0.03, 0.3);
    LocalOut.ar(snd);
    snd = Pan2.ar(sig, pan) * amp * globalEnv;
    snd = Sanitize.ar(snd);
    snd = snd + (NHHall.ar(snd, 3) * -10.dbamp);

    OffsetOut.ar(out, snd);
}).add;

///////////////////////////////////////  Sampler

~samplerStereoSynthDef = SynthDef(\samplerStereo,{ arg out = 0, gate = 1, amp = 1, pan = 0, attack = 0.001, release = 1, curve = (-4), buffer = 0, rate = 1, startPos = 0, loop = 0, doneAction = 2;
	var sig, env;
	sig = PlayBuf.ar(2, buffer, BufRateScale.kr(buffer) * rate, gate, BufFrames.kr(buffer)*startPos, loop, doneAction);
	env = EnvGen.kr(Env.asr(attack, 1, release, curve), gate /*- Done.kr(sig)*/, 1, doneAction: doneAction);
	sig = sig * env;
	sig = Balance2.ar(sig[0], sig[1], pan, amp/*.curvelin(0, 1, 0, 1, log(10))*/);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\samplerMono,{ arg out = 0, gate = 1, amp = 1, pan = 0, attack = 0.001, release = 1, curve = (-4), buffer = 0, rate = 1, startPos = 0, loop = 0, doneAction = 2;
	var sig, env;
	sig = PlayBuf.ar(1, buffer, BufRateScale.kr(buffer) * rate, gate, BufFrames.kr(buffer)*startPos, loop, doneAction);
	env = EnvGen.kr(Env.asr(attack, 1, release, curve), gate - Done.kr(sig), 1, doneAction: doneAction);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp.curvelin(0, 1, 0, 1, log(10)));
	OffsetOut.ar(out, sig);
}).add;

~paulstretchMonoSynthDef = SynthDef(\paulstretchMono, { |out = 0, gate = 1, amp = 1, pan = 0, attack = 1.19, release = 2, curve = (-4), buffer, envBufnum, channel = 0, rate = 1, stretch = 50, window = 0.25, doneAction = 2|
    // Paulstretch for SuperCollider
    // Based on the Paul's Extreme Sound Stretch algorithm by Nasca Octavian PAUL
    // https://github.com/paulnasca/paulstretch_python/blob/master/paulstretch_steps.png
    //
    // By Jean-Philippe Drecourt
    // http://drecourt.com
    // April 2020
    //
    // Arguments:
    // out: output bus (stereo output)
    // buffer: the sound buffer. Must be Mono. (Use 2 instances with Buffer.readChannel for stereo)
    // envBufnum: The grain envelope buffer created as follows:
    //// envBuf = Buffer.alloc(s, s.sampleRate, 1);
    //// envSignal = Signal.newClear(s.sampleRate).waveFill({|x| (1 - x.pow(2)).pow(1.25)}, -1.0, 1.0);
    //// envBuf.loadCollection(envSignal);
    // pan: Equal power panning, useful for stereo use.
    // stretch: stretch factor (modulatable)
    // window: the suggested grain size, will be resized to closest fft window size
    // amp: amplification
    var rateScale, trigPeriod, sig, envVca, env, delayTimeEnv, chain, trig, pos, fftSize;

	envVca = EnvGen.kr(Env.asr(attack, 1, release, curve), gate, doneAction: doneAction);
	rateScale = BufRateScale.kr(buffer);
    // Calculating fft buffer size according to suggested window size
    fftSize = 2**floor(log2(window*SampleRate.ir));
    // Grain parameters
    // The grain is the exact length of the FFT window
    trigPeriod = fftSize/SampleRate.ir;
    trig = Impulse.ar(1/trigPeriod);
    pos = Demand.ar(trig, 0, demandUGens: Dseries(0, trigPeriod/stretch));
    // Extraction of 2 consecutive grains
    // Both grains need to be treated together for superposition afterwards
	sig = [GrainBuf.ar(1, trig, trigPeriod, buffer, rate * rateScale, pos, envbufnum: envBufnum),
        GrainBuf.ar(1, trig, trigPeriod, buffer, rate * rateScale, pos + (trigPeriod/(2*stretch)), envbufnum: envBufnum)]*amp;
    // FFT magic
    sig = sig.collect({ |item, i|
        chain = FFT(LocalBuf(fftSize), item, hop: 1.0, wintype: -1);
        // PV_Diffuser is only active if its trigger is 1
        // And it needs to be reset for each grain to get the smooth envelope
        chain = PV_Diffuser(chain, 1 - trig);
        item = IFFT(chain, wintype: -1);
    });
    // Reapply the grain envelope because the FFT phase randomization removes it
    env = PlayBuf.ar(1, envBufnum, 1/(trigPeriod), loop:1);
    delayTimeEnv = (fftSize - BlockSize.ir) / SampleRate.ir; // fix by Sam Pluta
    env = DelayN.ar(env, delayTimeEnv, delayTimeEnv); // fix by Sam Pluta
    sig = sig * env;
    // Delay second grain by half a grain length for superposition
    sig[1] = DelayC.ar(sig[1], trigPeriod/2, trigPeriod/2);
    // Panned output
	sig = Mix.new(sig) * envVca;
    OffsetOut.ar(out, Pan2.ar(sig, pan));
}).add;

// \paulstretchMono example:

/*{
    var envBuf, envSignal, buffer;
    buffer = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
	// buffer = Buffer.readChannel(s, b[\sampler_stereo][15].path, channels: [0]);
    // The grain envelope
    envBuf = Buffer.alloc(s, s.sampleRate, 1);
    envSignal = Signal.newClear(s.sampleRate).waveFill({|x| (1 - x.pow(2)).pow(1.25)}, -1.0, 1.0);
    envBuf.loadCollection(envSignal);
    s.sync();
    // Runs indefinitely
	Synth(\paulstretchMono, [\bufnum, buffer.bufnum, \envBufnum, envBuf.bufnum]);
}.fork;*/

///////////////////////////////////////  Input

~inputSigSynthDef = SynthDef(\inputSig, { arg out = 0, in = 0, gate = 1, amp = 0.5, pan = 0, attack = 0.5, release = 1, curve = (-4), delaytime = 0, lpfreq = 20000, band1freq = 8000, band1rq = 1, band1db = 0, band2freq = 1200, band2rq = 1, band2db = 0, band3freq = 80, band3rq = 1, band3db = 0, hpfreq = 20, doneAction = 2;
	var input, sig;
	input = SoundIn.ar(in);
	sig = BHiPass4.ar(input, Lag2.kr(hpfreq.max(20).min(20000), 0.5)); // HPF
	sig = BPeakEQ.ar(sig, Lag2.kr(band1freq.max(20).min(20000), 0.5), band1rq, band1db); // Band 1
	sig = BPeakEQ.ar(sig, Lag2.kr(band2freq.max(20).min(20000), 0.5), band2rq, band2db); // Band 2
	sig = BPeakEQ.ar(sig, Lag2.kr(band3freq.max(20).min(20000), 0.5), band3rq, band3db); // Band 3
	sig = BLowPass4.ar(sig, Lag2.kr(lpfreq.max(20).min(20000), 0.5)); // LPF
	sig = sig * EnvGen.kr(Env.asr(attack, 1, release, curve), gate, gate, doneAction: doneAction);
	sig = DelayN.ar(sig, 1, delaytime);
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\pitchTrackSynthIxi, {arg in = 0, out = 0, att = 0.51, dec = 0.52, sus = 1, rel = 0.51, curve = (-4);
	var sig, env, input, amp, freq, hasFreq;

	// the audio input
	// input = SoundIn.ar([in, in+1]);
	input = InFeedback.ar(in, 2);
	amp = Amplitude.kr(in, 0.25, 0.25);

	// the pitch variable and the hasFreq (Pitch.kr returns a list like this [freq, hasFreq])
	# freq, hasFreq = Pitch.kr(input, ampThreshold: 0.2, median: 7);

	// when the hasFreq is true (pitch is found) we generate a ADSR envelope that is open until
	// the hasFreq is false again or the amplitude is below the ampThreshold of the Pitch.
	env = EnvGen.ar(Env.adsr(att, dec, sus, rel, 1, curve), gate: hasFreq);

	// we plug the envolope to the volume argument of the Sine
	sig = SinOsc.ar(freq, 0, env * amp) ! 2;
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\pitcherIxi,{ arg out = 0, in = 0, threshold = 0.5, lpf = 2000;
	var input, amp, freq, hasFreq, sig, gate;

	// input = SoundIn.ar([in, in + 1]);
	input = InFeedback.ar(in, 2);

	// using a LowPassFilter to remove high harmonics
	input = LPF.ar(Mix.new(input), lpf);
	amp = Amplitude.kr(input, 0.25, 0.25);

	// # freq, hasFreq = Pitch.kr(input, ampThreshold: 0.1, median: 7);
	# freq, hasFreq = Tartini.kr(input); // Tartini performs better than Pitch

	gate = Lag.kr(amp > threshold, 0.01);

	// sig = VarSaw.ar(freq, 0, 0.2, amp*hasFreq*gate);

	// 3 sines (octave lower, pitch and octave higher mixed into one signal
	sig = Mix.new(SinOsc.ar(freq * [0.5,1,2], 0, 0.2 * amp*hasFreq*gate));
	6.do({
		sig = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], 2)
	});
	OffsetOut.ar(out, sig);
}).add;

///////////////////////////////////////  Sequence

SynthDef(\virgo, { arg out = 0, amp = 0.2, attack = 0.01, release = 1, feedback = 7.5, freq1 = 32, freq2 = 33, delaytime = 2, decaytime = 40, t_gate = 1, doneAction = 2;
	var sig, input, modFreq;
	input = LocalIn.ar(2) * feedback;
	sig = input + Saw.ar([freq1, freq2], amp);
	modFreq = 2 ** LFNoise0.kr(4/3, 4) * 300;
	sig = BPF.ar(sig, modFreq, 0.1).distort;
	sig = CombN.ar(sig, 1, delaytime, decaytime);
	LocalOut.ar(sig);
	sig = sig * EnvGen.kr(Env.asr(attack, releaseTime: release), t_gate, doneAction: doneAction);
	OffsetOut.ar(out, sig);
}).add;

~scratchiSynthDef = SynthDef(\scratchi, { arg out = 0, amp = 1, spread = 0, attack = 0.01, release = 2, freq = 0.5, t_trig = 1, doneAction = 2;
	var sig, env, waveForm, trig;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	waveForm = SinOsc.ar(freq,[0,1],3,1);
	trig = Impulse.ar([waveForm+0.2,waveForm]);
	sig = FreeVerb.ar(Decay.ar(trig,waveForm,MoogFF.ar(SinOsc.ar(([waveForm.asin])*50),400)).softclip/2);
	sig = sig * env;
	OffsetOut.ar(out, Splay.ar(sig, spread, amp));
}).add;

SynthDef(\seqPure, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = Splay.ar({|i|
		RLPF.ar(0.6**i*40*Impulse.ar(2**i/32,1/2),4**LFNoise0.kr(1/16)*300,5e-3).sin;
	}!8);
	2.do{
		sig = FreeVerb2.ar(*sig++[0.1,1,1]);
	};
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\seqModul, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env, buffer;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	buffer = LocalBuf(1e5,2).clear;
	sig = BufRd.ar(2,buffer,Phasor.ar(0,1,0,1e5))*0.6;
	BufWr.ar(Blip.ar([1,1.01],10)/5+sig,buffer,LFNoise1.ar(0.2)+1*5e4);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\nathanielVirgo, { arg out = 0, amp = 1, feedBack = 7.5, sawFreq1 = 32, sawFreq2 = 33, sawAmp = 0.2, bpff = 2, bpffModSpeed = 1.33, bpffModAmt = 4, delayTime = 2, decayTime = 40, gate = 1, doneAction = 2;
	var sig, env;
	env = Linen.kr(gate, 0.01, 1, 20, doneAction);
	sig = LocalIn.ar(2) * feedBack + Saw.ar(
		[sawFreq1, sawFreq2],
		sawAmp
	) * env;
	sig = BPF.ar(
		sig,
		bpff ** LFNoise0.kr(bpffModSpeed, bpffModAmt) * 300,
		0.1
	).distort;
	sig = CombN.ar(sig, 2, delayTime, decayTime);
	LocalOut.ar(sig);
	OffsetOut.ar(out, sig * amp);
}).add;

~taltersSynthDef = SynthDef(\talters, { arg out = 0, amp = 1, attack = 0.01, release = 10, feedBack = 1, freq = 66, freqL1 = 0, freqL2 = 2, freqL3 = 4, freqL4 = 16, freqT1 = 0.01, freqT2 = 0.2, freqT3 = 0.12, freqCurve = (-4), decDens = 0.25, decTimeFreq = 0.1, decamp = 999, t_trig = 1, doneAction = 2;
	var sig, env, input, freqenv;
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	input = LocalIn.ar(2) * feedBack;
	freqenv = EnvGen.ar(Env([freqL1, freqL2, freqL3, freqL4], [freqT1, freqT2, freqT3], freqCurve), t_trig);
	sig = ({
		|k|
		({
			|i|
			y = SinOsc;
			y.ar(
				(i*k*k) + freq * freqenv,
				y.ar(i*k**i/[{4.rand}, {5.rand}]) * Decay.kr(Dust.kr(decDens**i), (y.ar(decTimeFreq)+1*k+i) * input, k*decamp))
		}!3).product;
	}!4).sum;
	LocalOut.ar(sig);
	OffsetOut.ar(out, sig * env * amp);
}).add;

~talters1SynthDef = SynthDef(\talters1, { arg out = 0, amp = 1, attack = 0.01, release = 10, feedBack = 1, envL1 = 0, envL2 = 2, envL3 = 4, envL4 = 16, envT1 = 0.01, envT2 = 0.2, envT3 = 0.12, envCurve = (-4), decDens = 0.25, decTimeFreq = 0.1, decamp = 999, t_trig = 1, doneAction = 2;
	var sig, env, input, modenv, harmk, ampk, ringk;
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	input = LocalIn.ar(2) * feedBack;
	modenv = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), t_trig);
	sig = ({
		|k|
		({
			|i|
			y = SinOsc;
			y.ar(
				(i*k*k) * modenv,
				y.ar(i*k**i/[modenv, (i*k)+modenv]) * Decay.kr(Dust.kr(decDens - input), (y.ar(decTimeFreq)+1*k+i) * modenv, k*decamp))
		}!3).product;
	}!4).sum;
	LocalOut.ar(sig);
	OffsetOut.ar(out, sig * env * amp);
}).add;

SynthDef(\bozkurt, { arg out = 0, amp = 1, att = 0.01, rel = 10, impFreq = 0.25, freq1 = 4, freq2 = 6, delTime = 0.3, decTime = 50, feedBack = 1, gate = 1, doneAction = 2;
	var sig, env, input, ctrl;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	input = LocalIn.ar(2).tanh * feedBack;
	ctrl = Latch.kr(input[0].abs, Impulse.kr(impFreq));
	sig = Blip.ar([freq1, freq2], 100 * ctrl + 50, 0.9);
	sig = CombC.ar(
		sig,
		1,
		ctrl * delTime,
		decTime * input
	);
	LocalOut.ar(sig);
	sig = Splay.ar(sig * env, amp);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\padovan, { arg out = 0, amp = 1, tridDur = 1, freq = 165, roomSize = 9, gate = 1, doneAction = 2;
	var sig, env, input, mod, grainTr, sinMod;
	env = Linen.kr(gate, 0.1, 1, 5, doneAction);
	sig = SinOsc;
	mod = Trig.ar(
		Saw.ar(freq),
		tridDur
	);
	grainTr = sig.ar(mod * freq);
	sinMod = sig.ar(mod);
	sig = GrainIn.ar(2, grainTr, grainTr / 2, sinMod, mod * sinMod, -1, mul: env);
	sig = GVerb.ar(sig, roomSize, mul: amp);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\nozkurt, { arg out = 0, amp = 1, att = 0.01, rel = 5, sinFreq = 55, impMin = 0.0002, impMax = 0.7, impFreq = 8, gate = 1, doneAction = 2;
	var sig, env, delayTime;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	sig = SinOsc.ar(sinFreq).tanh;
	delayTime = TExpRand.ar(impMin, impMax, Impulse.ar(impFreq)).round([2e-3, 4e-3]);
	sig = AllpassC.ar(sig, 1, delayTime, 2);
	OffsetOut.ar(out, sig * env * amp);
}).add;

SynthDef(\LiljedDrumSeq, { arg out = 0, amp = 1/*, pan = 0*/, attack = 0.0001, release = 4, sawFrq = 4, plcTrigRate = 1, plcDelay = 1, plcDecay = 0.85714285714286, pCntTrigRate = 12, pCntResetRate = 5, krpsLpfFrq = 2500, krpsHpfFrq = 750, kickLpfFrq = 3000, kickHpfFrq = 40, ringFrq = 60, ringDec = 0.8, gate = 1, doneAction = 2;
	var sig, env, imp, krps, kick;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	imp = Impulse.ar(_); // * gate;

	krps = Pluck.ar(
		Saw.ar(sawFrq),
		imp.(plcTrigRate),
		1,
		plcDelay,
		plcDecay,
		SinOsc.ar(
			PulseCount.ar(
				imp.(pCntTrigRate),
				imp.(pCntResetRate)
			).cos%[3,4]*20
		),
		2.5
	).sin;

	krps = krps + LPF.ar(
		HPF.ar(
			FreeVerb.ar(
				krps.mean,
				1,
				0.999,
				0.2
			)*0.3,
			krpsHpfFrq
		) * Line.kr(0,1,16),
		krpsLpfFrq
	);

	kick = HPF.ar(
		Ringz.ar(
			LPF.ar(
				Impulse.ar(
					[0.5,1]!2,
					[1/6,0]
				).sum,
				kickLpfFrq
			),
			ringFrq,
			ringDec,
			3
		).sin * 3,
		kickHpfFrq
	).tanh.madd(0.6);

	sig = krps + kick;
	sig = sig * env * amp;
	// sig = Mix.ar(sig) * env;

	OffsetOut.ar(out, sig/*Pan2.ar(sig, pan, amp)*/);
}).add;

SynthDef(\LiljedKickSeq, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 2, trgChance1 = 0.5, trgChance2 = 0.3, trgChance3 = 0.9, trgRate1 = 4, trgRate2 = 12, trgRate3 = 6, rFreq1 = 45, rFreq2 = 50, rDec1 = 0.6, rDec2 = 0.1, rDec3 = 1, rDec4 = 0.3, rAmp1 = 9, rAmp2 = 2, rAmp3 = 3, rAmp4 = 1, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	sig = Ringz.ar(
		CoinGate.ar(
			[trgChance1, trgChance2, trgChance3],
			Impulse.ar([trgRate1, trgRate2, trgRate3])
		),
		[rFreq1, rFreq2],
		[rDec1, rDec2, rDec3, rDec4],
		[rAmp1, rAmp2, rAmp3, rAmp4]
	).sin.sum.tanh;
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\LiljedMetalic, { arg out = 0, amp = 0.05, pan = 0, attack = 0.01, release = 2, rTrgRate = 1, rFreq1 = 40, rFreq2 = 200, rFreq3 = 234, rFreq4 = 889, rDec = 0.7, revSize = 5, revTime = 2, revDamp = 0.7, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);

	sig = Ringz.ar(
		Impulse.ar(rTrgRate),
		[rFreq1, rFreq2, rFreq3, rFreq4],
		rDec
	).sum*2;

	sig = GVerb.ar(
		sin(sig),
		revSize,
		revTime,
		revDamp
	);

	sig = Mix.ar(sig) * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\LiljedMetalic1, { arg out = 0, amp = 0.05, pan = 0, attack = 0.01, release = 2, rTrgRate = 1, rFreq1 = 40, rFreq2 = 200, rFreq3 = 234, rFreq4 = 889, rFreq5 = 1320, rFreq6 = 150, rDec = 0.7, revSize = 5, revTime = 2, revDamp = 0.7, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);

	sig = Ringz.ar(
		Impulse.ar(rTrgRate),
		[rFreq1, rFreq2, rFreq3, rFreq4, rFreq5, rFreq6],
		rDec
	).sum;

	sig = GVerb.ar(
		sin(sig),
		revSize,
		revTime,
		revDamp
	)/2;

	sig = Mix.ar(sig) * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\LiljedSoftRytm, { arg out = 0, amp = 0.6, pan = 0, attack = 0.01, release = 2, impSigRate = 8, sawFreq = 3, impRevRate = 4, impRevPh = 0.5, blipFreq = 4.9, blipHarm = 7, blipAmp = 0.4, revSize = 1, revTime = 1, gate = 1, doneAction = 2;
	var sig, env, imp, rev;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	imp = Impulse;
	sig = imp.kr(impSigRate).lag * Crackle.ar(LFSaw.kr(sawFreq).abs.lag * 1.8);
	rev = GVerb.ar(
		imp.kr(impRevRate, impRevPh).lag * Blip.ar(blipFreq, blipHarm, blipAmp),
		revSize,
		revTime
	) * 5;
	sig = sig + rev;
	sig = Mix.ar(sig * env);
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

///////////////////////////////////////  Rimshot

~rimSynthDef = SynthDef(\rim, { arg out = 0, amp = 0.2, pan = 0, tu = 1, envLev1 = 1, envLev2 = 0, envLev3 = 1, envLev4 = 0,  att = 0, dec = 0.004, rel = 0.1, t_gate = 1, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env([envLev1, envLev2, envLev3, envLev4], [att, dec, rel]), t_gate, doneAction: doneAction);
	var enf = EnvGen.ar(Env([1600,5600,800,250],[0.001,0.001,0.001],-4));
	var enf2 = EnvGen.ar(Env([1000,1600,700,200],[0.001,0.001,0.06,0.01],-4));
	sig = SinOsc.ar(tu*400)*env;
	sig =  WhiteNoise.ar(env)+sig;
	sig = RHPF.ar(sig, \hpf.kr(100)*tu, \hpfRq.kr(1))+sig;
	sig = sig + Mix.ar(BPF.ar(sig,[327,430],[0.5,0.5])*0.1)+WhiteNoise.ar(env)+BrownNoise.ar(env/8);
	sig = RLPF.ar(sig, \lpf.kr(11100)*tu, \lpfRq.kr(0.5))+sig;
	sig =( Ringz.ar(WhiteNoise.ar,Mix.ar([enf2,enf*0.9,enf2*0.8]),1,0.01*env) +RLPF.ar(BrownNoise.ar(env),enf*4,1,1)+sig )*env ;
	sig = Pan2.ar(sig*env, pan, amp);
		sig = CompanderD.ar(sig*4,0.8,0.3,0.5,0.001,0.2,env);
	OffsetOut.ar(out, sig*amp);
}).add;

SynthDef(\rimnew, { arg out=0, amp=0.01, pan=0, tu=1, att = 0.0001, rel=1, freqTime1 = 0.001, freqTime2 = 0.01, t_gate=1, doneAction=2;
    var sig;
    var env = EnvGen.ar(Env.perc(att, rel), t_gate, doneAction: doneAction);
var frequ = EnvGen.ar(Env([1500,500,210.4],[freqTime1, freqTime2]));
    sig = SinOsc.ar(tu*frequ)*env;
    sig = Ringz.ar(sig,(30..35)*10.234*tu,1).mean;
    sig = Pan2.ar(sig*env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\rim808, { arg out=0, amp=0.01, pan=0, att = 0.001, rel=1, tu=1, tuf=1, t_gate=1, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env.perc(att, rel), t_gate, doneAction: doneAction);
	sig = SinOsc.ar(tu*400)*env;
	sig = Ringz.ar(sig,(30..35)*10.234*tuf,1).mean;
	sig = Pan2.ar(sig*env, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

)