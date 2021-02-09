(

///////////////////////////////////////  Mixer

SynthDef(\ChannelStrip, { arg in = 0, out = 0, pan = 0, hpfreq = 20, band1freq = 80, band1rq = 1, band1db = 0, band2freq = 1200, band2rq = 1, band2db = 0, band3freq = 8000, band3rq = 1, band3db = 0, lpfreq = 20000, mute = 1, auxsend1 = 0, auxsend2 = 0, level = 0.5;
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

SynthDef(\MasterStrip, { arg in = 0, out = 0, hpfreq = 20, lpfreq = 20000, level = 0.5;
	var input, sig;
	input = In.ar(in, 2);
	sig = BHiPass.ar(input, Lag2.kr(hpfreq.max(20).min(20000), 0.5)); // HPF
	sig = BLowPass.ar(sig, Lag2.kr(lpfreq.max(20).min(20000), 0.5)); // LPF
	sig = sig * level.curvelin(0, 1, 0, 1, log(10));
	sig = Limiter.ar(sig);
	Out.ar(out, sig);
	Out.ar(out+2, sig);
}).add;

///////////////////////////////////////  Fx

///////////////////////////////////////  Pitch

SynthDef(\pitchShifter, { arg in = 0, out = 0, drywet = 0.5, pitchRatio = 1, pitchDisper = 0, timeDisper = 0;
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

SynthDef(\DistoInsideOut, { arg in = 0, out = 0, drywet = 0.5, level = 1;
	var input, effect;
	input = In.ar(in, 2);
	effect = InsideOut.ar(input);
	XOut.ar(out, drywet, effect * level);
}).add;

SynthDef(\DistoCrossOver, { arg in = 0, out = 0, amp = 0.5, smooth = 0.5, drywet = 0.5, level = 1;
	var input, effect;
	input = In.ar(in, 2);
	effect = CrossoverDistortion.ar(input , amp, smooth);
	XOut.ar(out, drywet, effect * level);
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

SynthDef(\distortion, { arg out = 0, gain = 41.97, envtime = 4, mix = 1, outputlevel = 1, shaperbuf;
	var input = In.ar(out, 2) * gain;
	ReplaceOut.ar(out, XFade2.ar(input, Shaper.ar(shaperbuf, input), mix.linlin(0,1.0,-1,1.0)));
}).add;

SynthDef(\waveShape, { arg in = 0, out = 0, mix = 1, gain = 1, shaperbuf;
	var input = In.ar(in, 2);
	var sig = XFade2.ar(input, Shaper.ar(shaperbuf, input * gain), mix.linlin(0,1.0,-1,1.0));
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

///////////////////////////////////////  Time

SynthDef(\Phasing, { arg in = 0, out = 0, freq = 0.2, drywet = 0.5, level = 1;
	var input, effect;
	input = In.ar(in, 2);
	effect = AllpassN.ar(input, 0.02, SinOsc.kr(freq, 0, 0.01, 0.01));  // max delay of 20msec
	XOut.ar(out, drywet, effect * level);
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

SynthDef(\Flanging, {arg in = 0, out = 0, flangefreq = 0.1, fdback = 0.1, drywet = 0.5, level = 1;
	var input, effect;
	input = In.ar(0, 2);
	input = input + LocalIn.ar(2); // add some feedback
	effect = DelayN.ar(input, 0.02, SinOsc.kr(flangefreq, 0, 0.005, 0.005)); // max delay of 20msec
	LocalOut.ar(fdback * effect);
	XOut.ar(out, drywet, effect * level);
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

SynthDef(\chorus, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var in = InFeedback.ar(\inbus.kr(0), 2);
	sig = LocalIn.ar(2) * \fb.kr(0.4);
	sig = sig + in;
	sig = DelayC.ar(sig, \maxdelay.ir(0.2), \delay.kr(0.0101) * ((0..7)/7 - 0.5 * \diff.kr(0.4001) + 1) * ( SinOsc.kr(\modfreq.kr(8.1)) * \modamp.kr(0.48) + 1 )).mean;
	//sig = LPF.ar(sig, \dif.kr(7500));
	LocalOut.ar(sig);

	sig = LPF.ar(sig, \lpf.kr(15000));
	sig = HPF.ar(sig, \hpf.kr(50));
	sig = SelectX.ar(\mix.kr(0.5), [in, sig]);
	sig = sig * EnvGen.ar(\adsr.kr( Env.adsr(0.01,0.1,0.8,0.1) ),gate,doneAction:2);
	ReplaceOut.ar(out, sig);
}).add;

SynthDef(\Chorus1, { arg in = 0, out = 0, lpfreq = 6000, rq = 1, drywet = 0.5, level = 1;
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

SynthDef(\choruscompresseffect, {|out =0 gate= 1|
	var source = In.ar(out,2);
	var chorus;
	var env = Linen.kr(gate, 0.1, 1, 0.1, 2);

	chorus= Splay.ar(Array.fill(4,{
		var maxdelaytime= rrand(0.005,0.02);

		DelayC.ar(source[0], maxdelaytime,LFNoise1.kr(Rand(0.1,0.6),0.25*maxdelaytime,0.75*maxdelaytime) )
	}));

	chorus = Compander.ar(4*(source + chorus),source,0.4,1,4);

	XOut.ar(out,env,chorus);

//From Steal This Sound SC Example
//By Nick Collins
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

///////////////////////////////////////  Delay

SynthDef(\delayeffect, { arg in = 0, out = 0, gate = 1;
	var source = In.ar(in,2);
	var delay;
	var env = Linen.kr(gate, 0.1, 1, 0.1, 2);

	delay= CombC.ar(source,0.25,0.25,2.0);

	XOut.ar(out,env, delay);

}).add;

SynthDef(\SimpleDelay, { arg in = 0, out = 0, delaytime = 0.1;
	var input, effect;
	input = In.ar(in, 2);
	effect = DelayN.ar(input, 1, delaytime);
	//Out.ar(0, effect); // Mix with the data already present on the corresponding bus
	ReplaceOut.ar(out, effect); // overwriting previous data on the corresponding bus
}).add;

SynthDef(\quadDelay, { arg in = 0, out = 0, delayamp1 = 1, delaypan1 = 0, sync1 = 0, delayamp2 = 1,  delaypan2 = 0, sync2 = 0, delayamp3 = 1, delaypan3 = 0, sync3 = 0, delayamp4 = 1, delaypan4 = 0, sync4 = 0, feedBack = 0.2, dryWet = 0.4, amp = 0.5;
	var input, delay, delay1, delay2, delay3, delay4, time1, time2, time3, time4, sig, tempoClock;
	input = In.ar(in, 2);
	delay = input + LocalIn.ar(2);
	tempoClock = \tempoClock.kr(TempoClock.default.tempo);

	// delay 1
	time1 = Select.kr(sync1, [\delaytime1.kr(0.25), \division1.kr(2/3) / tempoClock]);
	delay1 = XFadeDelay.ar(delay, 1, time1);
	delay1 = Balance2.ar(delay1[0], delay1[1], delaypan1, delayamp1);

	// delay 2
	time2 = Select.kr(sync2, [\delaytime2.kr(0.4), \division2.kr(2/8) / tempoClock]);
	delay2 = XFadeDelay.ar(delay, 1, time2);
	delay2 = Balance2.ar(delay2[0], delay2[1], delaypan2, delayamp2);

	// delay 3
	time3 = Select.kr(sync3, [\delaytime3.kr(0.15), \division3.kr(3/6) / tempoClock]);
	delay3 = XFadeDelay.ar(delay, 1, time3);
	delay3 = Balance2.ar(delay3[0], delay3[1], delaypan3, delayamp3);

	// delay 4
	time4 = Select.kr(sync4, [\delaytime4.kr(0.3), \division4.kr(3/4) / tempoClock]);
	delay4 = XFadeDelay.ar(delay, 1, time4);
	delay4 = Balance2.ar(delay4[0], delay4[1], delaypan4, delayamp4);

	sig = delay1 + delay2 + delay3 + delay4;

	LocalOut.ar(sig * feedBack);
	sig = XFade2.ar(input, sig, dryWet, amp);
	ReplaceOut.ar(out, sig);
}).add;

SynthDef(\syncDelay, { arg in = 0, out = 0, sync = 0/*false*/, feedBack = 0.2, dryWet = 0.4, pan = 0, amp = 0.5;
    var input, delay, sig, time;
    input = In.ar(in, 2);
	delay = input + LocalIn.ar(2);

	time = Select.kr(sync, [\delaytime.kr(0.25), \division.kr(2/3) / \tempoClock.kr(TempoClock.default.tempo)]);
	delay = XFadeDelay.ar(delay, 1, time);
	delay = Balance2.ar(delay[0], delay[1], pan);

    LocalOut.ar(delay * feedBack);
	sig = XFade2.ar(input, delay, dryWet, amp);
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

SynthDef(\echo, { arg freq=200, pan=0, amp=0.1;
	var sig;
	var in = InFeedback.ar(\inbus.kr(BusDef(\sendbus1, \audio)), 2);
	var mix;
	sig = in;
	//sig = sig + DelayC.ar(sig, 0.01, 0.0001 * [0.1235,1,0.86534]).mean/2;
	//sig = Compander.ar(sig, in, \cpt.kr(0.4), \cpbelow.kr(1.001), \cpabove.kr(0.9), \cpclamp.kr(0.01), \cprelax.kr(0.1));
	mix = Duty.kr(1/8/~t, 0, Dseq([
		0,1,0,0, 0,0,0,0,
		0,0,0,0, 0,0,0,0,
		0,0,0,0, 0,0,1,0,
		0,0,0,0, 0,0,0,0,
	],inf));
	sig = SelectX.ar(mix, [DC.ar(0), in]);
	sig = CombL.ar(sig, 1/4, 1/8, 1);
	sig = sig * \gain.kr(1);
	//sig = SelectX.ar(mix, [in, sig]);
	sig = in + sig;
	ReplaceOut.ar(\outbus.kr(0), sig);
}).add;

SynthDef(\drumy, { arg freq=200, pan=0, amp=0.1;
	var sig;
	var in = InFeedback.ar(\inbus.kr(0), 2);
	sig = in;
	//sig = sig + DelayC.ar(sig, 0.01, 0.0001 * [0.1235,1,0.86534]).mean/2;
	sig = Compander.ar(sig, in, \cpt.kr(0.4), \cpbelow.kr(1.001), \cpabove.kr(0.9), \cpclamp.kr(0.01), \cprelax.kr(0.1));
	sig = sig * \gain.kr(1);
	sig = SelectX.ar(\mix.kr(1), [in, sig]);
	ReplaceOut.ar(\outbus.kr(0), sig);
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

///////////////////////////////////////  Stutter

~stutter = { |snd, reset, fragmentlength, rate = 1.0, maxdelay = 10|
    var phase, fragment, del;
    phase = Sweep.ar(reset);
    fragment = { |ph| (ph - Delay1.ar(ph)) < 0 + Impulse.ar(0) }.value(phase / fragmentlength % 1);
    del = Latch.ar(phase, fragment) + ((fragmentlength - Sweep.ar(fragment)) * (rate - 1));
    DelayC.ar(snd, maxdelay, del);
};

// audio-rate stutter inspired by DestroyFX
SynthDef(\stutter, { arg out = 0, in = 0, amp = 0.3, drywet = 0.5, holdperiod = 1 /* 0.01 to 1 */ , multiplier = 20 // 1 to 20;
    var sig;
    sig = In.ar(in, 2);
    sig = ~stutter.(sig, Impulse.ar(holdperiod.reciprocal), holdperiod / multiplier);
    sig = sig * 0.3!2;
	//Out.ar(out, sig);
	XOut.ar(\outbus.kr(0), drywet, sig * amp);
}).add;

// feedback loop inspired by Glitchmachines
SynthDef(\fbStutter, { arg inbus = 0, outbus = 0, amp = 0.3, drywet = 0.5,;
    var in, loop, out;
    in = In.ar(inbus, 2);
	out = (in!2*0.6) + DelayC.ar(LocalIn.ar(2), 0.3, [0.11, 0.13], 0.95);
    loop = out;
    loop = ~stutter.(loop, Impulse.kr([3.4, 5.5]), [0.1, 0.03], [0.8, 1.3]);
    loop = LPF.ar(loop, 5000);
	LocalOut.ar(loop.reverse);
    out = out * 0.3;
	//Out.ar(outbus, out);
	XOut.ar(\outbus.kr(0), drywet, sig * amp);
}).add;

SynthDef(\stuttertest, {
    |out = 0, buf, t_reset = 0, fragmentlength = 0.1, amp = 0.3, drywet = 0.5, amp = 0.1|
    var snd;
    snd = PlayBuf.ar(1, buf, BufRateScale.kr(buf), loop: 1);
    snd = ~stutter.(snd, t_reset, fragmentlength);
    //Out.ar(out, snd * amp!2);
	XOut.ar(\outbus.kr(0), drywet, sig * amp);
}).add;

//allInOne
SynthDef(\rdStutter, { arg out = 0, time= 0.1, mix=0, rate=1;
	var stutter = { arg sig, reset, time, rate = 1.0, maxdelay = 10;
		var phase, fragment, del;
		phase = Sweep.ar(reset);
		fragment = { |ph| (ph - Delay1.ar(ph)) < 0 + Impulse.ar(0) }.value(phase / time % 1);
		del = Latch.ar(phase, fragment) + ((time - Sweep.ar(fragment)) * (rate - 1));
		DelayC.ar(sig, maxdelay, del);
	};
	var sig;
	var in = InFeedback.ar(\inbus.kr(0), 2);
	var reset;
	reset = Changed.kr(mix);
	sig = in;
	sig = stutter.(sig, reset, time, rate, \maxdelay.ir(10));
	sig = SelectX.ar(mix, [in, sig]);
	sig = sig * \gain.kr(1);
	ReplaceOut.ar(out, sig);
}).add;

// "scrambler" -- randomly samples from recent audio
SynthDef(\scrambler, { arg in = 0, out = 0, amp = 0.3, drywet = 0.5,;
    var sig;
    sig = In.ar(inbus, 2);
    sig = DelayC.ar(sig, 1.0, LFNoise0.ar(13).range(0.0, 1.0));
    sig = sig!2 * 0.3;
	//Out.ar(out, sig);
	XOut.ar(\outbus.kr(0), drywet, sig * amp);
}).add;

///////////////////////////////////////  Reverb

// infinite reverb by Eli Feldsteel
SynthDef(\allreverb, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var in = InFeedback.ar(\inbus.kr(0), 2);
	sig = LocalIn.ar(2) * \fb.kr(0.1);
	sig = sig + in;
	15.do {
		sig = AllpassL.ar(sig, 0.06, Rand(0.001,0.06), 3);
	};
	LocalOut.ar(sig);
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,0.1),gate,doneAction:2);
	sig = SelectX.ar(\mix.kr(0.5), [in, sig]);
	ReplaceOut.ar(out, sig);
}).add;

SynthDef(\allreverbf, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var in = InFeedback.ar(\inbus.kr(0), 2);
	var fbsig;
	sig = LocalIn.ar(2) * \fb.kr(0.1);
	sig = sig + in;
	15.do {
		sig = AllpassL.ar(sig, 0.06, Rand(0.001,0.06), 3);
	};
	fbsig = sig;
	fbsig = LPF.ar(sig, \lpf.kr(1000));
	fbsig = HPF.ar(sig, \hpf.kr(100));
	sig = fbsig;
	LocalOut.ar(fbsig);
	sig = sig * EnvGen.ar(Env.adsr(0.4,0.1,0.8,0.1),gate,doneAction:2);
	sig = SelectX.ar(\mix.kr(0.5), [in, sig]);
	ReplaceOut.ar(out, sig);
}).add;

SynthDef(\allreverbif, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var in = InFeedback.ar(\inbus.kr(0), 2);
	var fbsig;
	sig =
	sig = LocalIn.ar(2) * \fb.kr(0.1);
	sig = sig + SelectX.ar(\mix.kr(0.5), [DC.ar(0), in]);
	15.do {
		sig = AllpassL.ar(sig, 0.06, Rand(0.001,0.06), 3);
	};
	fbsig = sig;
	fbsig = LPF.ar(sig, \lpf.kr(1000));
	fbsig = HPF.ar(sig, \hpf.kr(100));
	sig = fbsig;
	LocalOut.ar(fbsig);
	sig = sig * EnvGen.ar(Env.adsr(0.4,0.1,0.8,0.1),gate,doneAction:2);
	sig = sig + in;
	ReplaceOut.ar(out, sig);
}).add;

SynthDef(\reverbCraum, {
	arg out = 0, gate = 1, roomsize = 100, revtime = 1, damping = 0.6, inputbw = 0.5, spread = 15, drylevel = 1, earlyreflevel = 0.7, taillevel = 0.5, maxroomsize = 300, amp = 0.5;
	var source = In.ar(out,8);
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

SynthDef(\verb, { arg freq=200, pan=0, amp=0.1, drywet = 0.5;
	var sig, in;
	in = InFeedback.ar(\inbus.kr(0), 2);
	sig = in;
	sig = FreeVerb2.ar(sig[0], sig[1], \mix.kr(0.5), \room.kr(1), \damp.kr(0.4));
	//Out.ar(\outbus.kr(0), sig);
	XOut.ar(\outbus.kr(0), drywet, sig * amp);
}).add;

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

SynthDef(\JPverb, { arg in = 0, out = 0, drywet = 0.85, amp = 1, feedback = 0, t60 = 1, damp = 0, size = 1, earlyDiff = 0.707, modDepth = 0.1, modFreq = 2, low = 1, mid = 1, high = 1, lowcut = 500, highcut = 2000;
	var sig, input;
	input = InFeedback.ar(in, 2);
	sig = input + LocalIn.ar(2);
	sig = JPverb.ar(sig, t60, damp, size, earlyDiff, modDepth, modFreq, low, mid, high, lowcut, highcut);
	LocalOut.ar(feedback.min(0.25) * sig);
	// sig = SelectX.ar(drywet, [input, sig]);
	sig = XFade2.ar(input, sig, drywet, Lag2.kr(amp));
	ReplaceOut.ar(out, sig);
}).add;

SynthDef(\greyHole, { arg in = 0, out = 0, drywet = 0.85, amp = 1, delayTime = 2, damp = 0, size = 1, diff = 0.707, feedback = 0.9, modDepth = 0.1, modFreq = 2;
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

SynthDef(\filterBus, { arg in = 0, out = 0, drywet = -1, hpfInFreq = 20, eqFreq = 3200, eqRq = 1, eqDb = 0, lpfInFreq = 20000;
	var input, inputFilt, sig;
	input = InFeedback.ar(in, 2);
	inputFilt = LPF.ar(HPF.ar(input, Lag3.kr(hpfInFreq)), Lag3.kr(lpfInFreq));
	inputFilt = BPeakEQ.ar(inputFilt, Lag2.kr(eqFreq.max(20).min(20000), 0.5), eqRq, eqDb);
	sig = XFade2.ar(input, inputFilt, drywet);
	ReplaceOut.ar(out, sig);
	//XOut.ar(out, drywet, effect);
}).add;

)