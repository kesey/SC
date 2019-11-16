(

///////////////////////////////////////  SynthDef

~aux1 = Bus.audio(s, 2);
~aux2 = Bus.audio(s, 2);

///////////////////////////////////////  Mixer

SynthDef(\ChannelStrip, { arg in = 0, out = 0, pan = 0, hpfreq = 20, band1freq = 8000, band1rq = 1, band1db = 0, band2freq = 1200, band2rq = 1, band2db = 0, band3freq = 80, band3rq = 1, band3db = 0, lpfreq = 20000, mute = 1, auxsend1 = 0, auxsend2 = 0, level = 0.5;
	var input, sig;
	input = InFeedback.ar(in, 2);
	sig = BHiPass4.ar(input, Lag2.kr(hpfreq.max(20).min(20000), 0.5)); // HPF
	sig = BPeakEQ.ar(sig, Lag2.kr(band1freq.max(20).min(20000), 0.5), band1rq, band1db); // Band 1
	sig = BPeakEQ.ar(sig, Lag2.kr(band2freq.max(20).min(20000), 0.5), band2rq, band2db); // Band 2
	sig = BPeakEQ.ar(sig, Lag2.kr(band3freq.max(20).min(20000), 0.5), band3rq, band3db); // Band 3
	sig = BLowPass4.ar(sig, Lag2.kr(lpfreq.max(20).min(20000), 0.5)); // LPF
	Out.ar(~aux1, sig * auxsend1); // Aux 1 pre fader / pre mute / post eq
	Out.ar(~aux2, sig * auxsend2); // Aux 2 pre fader / pre mute / post eq
	sig = sig * Lag2.kr(mute, 0.2); // Mute
	Out.ar(out, Balance2.ar(sig[0], sig[1], pan, level.curvelin(0, 1, 0, 1, log(10)))); // curvelin(blabla) to have a logarithmic scale
}).add;

SynthDef(\MasterStrip, { arg in = 0, out = 0, hpfreq = 20, lpfreq = 20000, level = 0.5;
	var input, sig;
	input = In.ar(in, 2);
	sig = BHiPass4.ar(input, Lag2.kr(hpfreq.max(20).min(20000), 0.5)); // HPF
	sig = BLowPass4.ar(sig, Lag2.kr(lpfreq.max(20).min(20000), 0.5)); // LPF
	sig = sig * level.curvelin(0, 1, 0, 1, log(10));
	sig = Limiter.ar(sig);
	Out.ar(out, sig);
	Out.ar(out+2, sig); // use it to feed external gear with signal
}).add;

///////////////////////////////////////  Fx

///////////////////////////////////////  Time

SynthDef(\phasing, { arg in = 0, out = 0, freq = 0.2, drywet = 0.5;
	var input, effect;
	input = InFeedback.ar(in, 2);
	effect = AllpassN.ar(input, 0.02, SinOsc.kr(freq, 0, 0.01, 0.01));  // max delay of 20msec
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

///////////////////////////////////////  Distortion

~distoInsideOutSynthDef = SynthDef(\distoInsideOut, { arg in = 0, out = 0, drywet = -0.5, level = 0.02;
	var input, effect, sig;
	input = InFeedback.ar(in, 2);
	effect = InsideOut.ar(input, level);
	sig = XFade2.ar(input, effect, drywet);
	ReplaceOut.ar(out, sig);
	//XOut.ar(out, drywet, effect);
}).add;

~distoCrossOverSynthDef = SynthDef(\distoCrossOver, { arg in = 0, out = 0, drywet = -0.05, amp = 0.14, smooth = 0.1, level = 0.4;
	var input, effect, sig;
	input = InFeedback.ar(in, 2);
	effect = CrossoverDistortion.ar(input , Lag2.kr(amp.max(0.001)), Lag2.kr(smooth.max(0.01)), level);
	sig = XFade2.ar(input, effect, drywet);
	ReplaceOut.ar(out, sig);
	//XOut.ar(out, drywet, effect);
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

~waveShapeSynthDef = SynthDef(\waveShape, { arg in = 0, out = 0, mix = 1, gain = 1, shaperbuf;
	var input = In.ar(in, 2);
	var sig = XFade2.ar(input, Shaper.ar(shaperbuf, input * gain), mix.linlin(0,1.0,-1,1.0));
	ReplaceOut.ar(out, sig);
}).add;

///////////////////////////////////////  Dynamic

SynthDef(\Compression, {arg in = 0, out = 0, gain = 1.5, threshold = 0.5, drywet = 0.5, level = 1;
	var input, effect;
	input = In.ar(in, 2);
	effect = CompanderD.ar(gain * input, threshold, 1, 0.5);
	XOut.ar(out, drywet, effect * level);
}).add;

SynthDef(\Limiter, { arg in = 0, out = 0, gain = 1, level = 0.99, dur = 0.01;
	var input, effect;
	input = In.ar(in, 2);
	effect = Limiter.ar(gain * input, level, dur);
	ReplaceOut.ar(out, effect);
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
	time1 = Select.kr(\sync1.kr(0), [\time1.kr(0.25), \division1.kr(2/3) / tempoClock]);
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

~kickMistSynthDef = SynthDef(\kickMist, { arg out = 0, level = 1, tu = 1, noise = 1, env0L1 = 0.5, env0L2 = 1, env0L3 = 0.3, env0L4 = 0, env0T1 = 0.01, env0T2 = 0.5, env0T3 = 0.26, env1L1 = 120, env1L2 = 43, env1L3 = 29, env1T1 = 0.03, env1T2 = 0.29, doneAction = 2;
	var env0, env1, env1m, sig;
	env0 =  EnvGen.ar(Env.new([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3], #[-4, -2, -4]), doneAction: doneAction);
	env1 = EnvGen.ar(Env.new([env1L1, env1L2, env1L3], [env1T1, env1T2], #[-4, -5]));
	env1m = env1.midicps;
	sig = LFPulse.ar(env1m*tu, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(noise);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m*tu, 0.5, env0*4);
	sig = sig.clip2(1);
	OffsetOut.ar(out, Pan2.ar(sig, 0, level));
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

SynthDef(\t1kick, {arg out = 0, amp = 0.5, pan = 0, rel = 0, doneAction = 2;
	var enva, envf, sig;
	enva = EnvGen.ar(Env([0.01,1,0],[0.001, rel]), doneAction: doneAction);
	envf = EnvGen.ar(Env([800,50],[0.005,1]));
	sig = SinOsc.ar(envf,0,enva);
	sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

~t1kick2SynthDef = SynthDef(\t1kick2, {arg out = 0, amp = 0.5, pan = 0, envaT1 = 0, envaL1 = 1, envaT2 = 0.6, envaL2 = 1, envaT3 = 0.2, envaL3 = 0.5, envaT4 = 0.2, envaL4 = 0, envaCurve = \exp, envfT1 = 0, envfL1 = 10000, envfT2 = 0.002, envfL2 = 20, envfT3 = 0.1, envfL3 = 0, envfT4 = 1, envfL4 = 4, envfCurve = \exp, pitch = 0.1, hpfFreq = 1200, hpfRq = 1, verbMix = 1, verbRoom = 1, verbTime = 3, verbDamp = 0.5, doneAction = 2;
	var revSig;
	var enva = EnvGen.kr(Env.pairs([[envaT1, envaL1], [envaT2, envaL2], [envaT3, envaL3], [envaT4, envaL4]], envaCurve), doneAction: doneAction);
	//var envf = EnvGen.kr(Env([10000,20,00,4],[0.002,0.1,1,1]));
	var envf = EnvGen.kr(Env.pairs([[envfT1, envfL1], [envfT2, envfL2], [envfT3, envfL3], [envfT4, envfL4]], envfCurve), doneAction: doneAction);
	var sig = SinOsc.ar(envf+50*pitch, 0, enva);
	//sig = PitchShift.ar(sig,0.001,pitch,0.1);
	sig = BHiPass4.ar(sig.distort, hpfFreq, hpfRq);
	//sig = FreeVerb.ar(sig, verbMix, verbRoom.max(0.01), verbDamp);
	revSig = GVerb.ar(sig, Lag3.kr(verbRoom).max(0.01), verbTime, verbDamp);
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

SynthDef(\kick3Aw, {arg out = 0, amp = 1, pan = 0, attack = 0.01, decay = 0.1, release = 0.2, punch = 1, envfLev1 = 400, envfLev2 = 66, enfTime = 0.08, envfCurve = -3, doneAction = 2;
	var freq, env, sig;
    freq = EnvGen.kr(Env([envfLev1, envfLev2], [enfTime], envfCurve));
	env = EnvGen.kr(Env([0, 1, 0.8, 0], [attack, decay, release]), doneAction: doneAction);
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

SynthDef(\ringkick, { arg out = 0, freq = 40, decay = 0.25, amp = 1;
	var snd;
	snd = Ringz.ar(
		in: LPF.ar(
			in: Impulse.ar(0),
			freq: 1000
		),
		freq: freq,
		decaytime: decay,
		mul: 7 * amp
	).tanh.sin*2;
	OffsetOut.ar(out, snd!2);
}).add;

SynthDef(\tweetBassLeak, { arg out = 0, amp = 1, attack = 0.01, release = 1, freq = 8, t_trig = 1, doneAction = 2;
	var sig, demand, env, globenv;
	demand = Demand.kr(
		t_trig,
		0,
		Drand([0, Drand((0.4, 0.5..1))],inf)
	);
	env = Decay2.kr(
		demand,
		0.01,
		0.3
	);
	sig = Saw.ar(freq, env) ** 1.5;
	sig = BRF.ar(sig, demand * 20 + [45.1, 45], 0.1);
	globenv = EnvGen.kr(Env.linen(attack, 1, release), doneAction: doneAction);
	//globenv = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
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

SynthDef(\batuhan, { arg out = 0, amp = 1, att = 0.01, rel = 5, tridDur = 0.125, decayTime = 0.3, sawFreq = 8, brfFreq1 = 45.1, brfFreq2 = 45, gate = 1, doneAction = 2;
	var sig, env, core;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	core = Duty.kr(tridDur, 0, Drand([0, Drand((0.4,0.5..1))], inf));
	sig = Decay2.kr(
		core,
		0.01,
		decayTime
	);
	sig = Saw.ar(sawFreq, sig) ** 1.5;
	sig = BRF.ar(sig, core * 20 + [brfFreq1, brfFreq2], 0.1);
	sig = LeakDC.ar(sig).tanh;
	OffsetOut.ar(out, sig * env * amp);
}).add;

SynthDef(\kicky,{ arg out = 0, startFreq=80, endFreq=15, decay=4, lowpass=800, amp=1, noiseAmp=0.0, gain=1, dur=6, doneAction = 2;
	var sig, env, freq;
	freq = Line.kr(PinkNoise.kr(6,startFreq), PinkNoise.kr(3,endFreq), dur, 1, 0);
	env = EnvGen.kr(Env.perc(0.014, dur, 1, -5), 1, doneAction: doneAction);
	sig = {(LPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass) * amp) ! 2};
	sig = LPF.ar(sig,BrownNoise.kr(500,1500))*0.3;
	sig = sig * gain;
	sig = sig.softclip * amp * env;
	OffsetOut.ar(out, [sig,sig]);
}).add;

SynthDef(\kickey,{ arg out = 0, att = 0.0014, rel = 0.8, curve = (-5), startFreq=60, endFreq=10, decay=0.8, lowpass=500, amp=1, noiseAmp=0.00, gain=1, linedur=0.8, doneAction = 2;
	var sig, env, freq;
	freq = XLine.kr(startFreq, endFreq, linedur, 1, 0);
	env = EnvGen.kr(Env.perc(att, rel, 1, curve), 1, doneAction: doneAction);
	sig = {(LPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass) * amp) ! 2};
	sig = sig + LPF.ar((noiseAmp*BrownNoise.ar(1)),lowpass);
	sig = sig * gain;
	sig = sig.softclip * amp * env;
	Out.ar(out, [sig,sig]);
}).add;

SynthDef(\kickBoomy, { arg out = 0, amp=1, atk = 0.0014, rel=0.4, curve = (-5), frq1 = 180, frq2 = 330, frq3 = 175, frq4 = 224, gain=1.1, doneAction = 2;
	var env, sig;
	env = EnvGen.kr(Env.perc(atk, rel, 1, curve), 1, doneAction: doneAction);
	sig = (SinOsc.ar(frq1/4) + SinOsc.ar(frq2/4) + LFTri.ar(frq3/4) + LFTri.ar(frq4/4) + BrownNoise.ar(0.1)) * env * amp;
	sig = LPF.ar(sig, 500);
	sig = sig + HPF.ar(EnvGen.ar(Env.perc(0.001,0.001,0.5)),500);
	sig = sig * gain;
	sig = sig.softclip * 1;
	Out.ar(out, [sig,sig]);
}).add;

~kick_oto309SynthDef = SynthDef(\kick_oto309, { arg out=0, amp=0.5, pan=0, env0L1 = 0.5, env0L2 = 1, env0L3 = 0.5, env0L4 = 0, env0T1 = 0.005, env0T2 = 0.06, env0T3 = 0.26, env0Crv1 = (-4), env0Crv2 = (-2), env0Crv3 = (-4), env1L1 = 110, env1L2 = 59, env1L3 = 29, env1T1 = 0.005, env1T2 = 0.29, env1Crv1 = (-4), env1Crv2 = (-5), doneAction = 2;
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

	Out.ar(out, Pan2.ar(son * amp));
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

SynthDef(\snarenew, { arg out=0,tu=1, amp=0.1, t_gate=1, pan=0, freq=200;
    var sig;
    var env = EnvGen.ar(Env.perc(0,0.8));
    var enf = EnvGen.ar(Env([16000,57,15000,11188.8],[0.001,0.001,0.0001],-4));
    sig = SinOsc.ar(tu*enf,0,0.5)*env;
    sig = (PinkNoise.ar*env)+sig;
    sig = RHPF.ar(sig, \hpf.kr(80)*tu, \rq.kr(0.8));
    sig = sig + Mix.ar(BPF.ar(sig,[527,530],[0.5,0.5])*0.1);
    sig = RHPF.ar(sig, \lpf.kr(100), \rq.kr(0.8));
    sig = sig * EnvGen.ar(Env.perc(0,\rel.kr(1),4,-8),t_gate,doneAction:2);
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

SynthDef(\snaremed, { | out = 0, level = 1, pan = 0, noise = 1, done = 2, dc = 1, snd = 20, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, relEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1, env1T2, env1T3, env1T4, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase, oamp = 0.1, owhich2 = 0, ochoose = 0|
	var env0,env1,
env1m, son, son2,son3,son4,p2;
	p2 = phase * (-pi);
env0 = Env([env0L1,env0L2,env0L3,env0L4,0],[atkEnv0,decEnv0,relEnv0],[curve1, curve2, curve3]);
	env1 = Env([env1L1,env1L2,env1L3],[env1T1,env1T2,env1T3,env1T4],[curve1, curve2, curve3]);

env0 = EnvGen.ar(env0, doneAction: done);
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
},
).add;

SynthDef(\snareAw, {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
	var snd1 = WhiteNoise.ar(amp);
	var snd2 = SinOsc.ar(sinfreq,0,amp);
	var env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
	var sum = HPF.ar(snd1 * env, ffreq)+(snd2*env);
	OffsetOut.ar(out, Pan2.ar(sum, pan));
}).add;

SynthDef(\snarey,{ arg out = 0, amp=0.75, attack = 0.001, release = 0.3, freq=120, gain=0.5, doneAction = 2;
	var env, sig, snare;
	env = EnvGen.kr(Env.perc(attack, release, 1, -9), 1, doneAction: doneAction);
	sig = {(SinOsc.ar(freq) - WhiteNoise.ar(0.5, 0.5))!2};
	sig = sig * gain;
	sig = sig.softclip * amp * env;
	Out.ar(out, [sig,sig]);
}).add;

SynthDef(\snary,{ arg out = 0, amp=0.75, att = 0.001, rel = 0.1, curve = (-5), freq=120, gain=1, doneAction = 2;
	var env, sig, snare;
	env = EnvGen.kr(Env.perc(att, rel, 1, curve), 1, doneAction: doneAction);
	sig = (SinOsc.ar(freq) - WhiteNoise.ar(0.5, 0.5)) * env * amp;
	sig = sig * gain * 0.4;
	sig = sig.softclip * amp;
	Out.ar(out, [sig,sig]);
}).add;

///////////////////////////////////////  HiHat

SynthDef(\hat, { | out = 0, amp = 1 |
	var osc1, env;
	osc1 = WhiteNoise.ar(amp);
	env = EnvGen.kr(Env.perc(0, 0.01), doneAction: 2);
	OffsetOut.ar(out, Pan2.ar(osc1, 0, env));
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
	Out.ar(out, Pan2.ar(signal, pan, amp));
}).add;

SynthDef(\haty,{ arg out = 0, att = 0.001, rel = 0.1, curve = (-4), amp = 0.75, doneAction = 2;
	var env, sig;
	env = EnvGen.kr(Env.perc(att, rel, 1, curve), 1, doneAction: doneAction);
	sig = HPF.ar((WhiteNoise.ar(0.5, 0.5) * env * amp), 4000);
	Out.ar(out, [sig,sig]);
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

~cym1SynthDef = SynthDef(\cym1, { arg out=0, amp=0.5, pan=0, envL1 = 0, envL2 = 1, envL3 = 0.3, envL4 = 0, levScale = 1, envT1 = 0.1, envT2 = 0.02, envT3= 0.01, envC1 = (-8), envC2 = 4, envC3 = (-4), tu=1, doneAction=2;
	var sig;
	var env = EnvGen.ar(Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], [envC1, envC2, envC3]), levelScale: levScale, doneAction: doneAction);
	var freqs = geom(100, 50, 1.3434)*10.234567*Lag3.kr(tu, 10);
	sig = WhiteNoise.ar;
	sig = Ringz.ar(sig,freqs).mean;
	sig = Pan2.ar(sig*env, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

~cymnewSynthDef = SynthDef(\cymnew, { arg out = 0, amp = 0.5, pan = 0, att = 0, rel = 4, curve = (-8), tu = 6, pos = 0, t_trig = 1, doneAction = 2;
    var sig;
    var env = EnvGen.ar(Env.perc(att,rel,1,curve), t_trig, doneAction: doneAction);
    var
    freqs= geom(99,40,pi/3)*10.234567*tu;
    sig = WhiteNoise.ar;
    sig = Ringz.ar(sig,freqs,1).mean;

    sig = Pan2.ar(sig*env, pan, amp);
    OffsetOut.ar(out, sig * 0.2);
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

SynthDef(\clapping, {arg out = 0, pan = 0, amp=0.5, filterfreq=120, rq=0.1, t_trig=1, doneAction=2;
	var env, signal, attack,  noise, hpf1, hpf2;
	noise = WhiteNoise.ar(1)+SinOsc.ar([filterfreq/2,filterfreq/2+4 ], pi*0.5, XLine.kr(1,0.01,4));
	hpf1 = RLPF.ar(noise, 400, rq);
	hpf2 = RHPF.ar(noise,  120, rq/4);
	env = EnvGen.kr(Env.perc(0.003, 0.035));
	signal = (hpf1+hpf2) * env;
	signal = CombC.ar(signal, 0.5, 0.03, 0.031)+CombC.ar(signal, 0.5, 0.03016, 0.06);
	signal = FreeVerb.ar(signal, 0.1, 0, 0.5);
	signal = Limiter.ar(signal, 0.7, 0.01) * amp;
	DetectSilence.ar(signal, doneAction: doneAction);
	OffsetOut.ar(out, Pan2.ar(signal, pan));
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

SynthDef(\clapy, { arg out = 0, amp = 0.5, att = 0.02, rel = 0.3, curve1 = 0, curve2 = (-4), hpf1 = 600, hpf2 = 1000, bpf1 = 2000, bpf2 = 1200, gain = 1.5, doneAction = 2;
	var env1, env2, sig, noise1, noise2;
	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [att, rel], [curve1, curve2]), doneAction: doneAction);
	noise1 = BPF.ar(HPF.ar(GrayNoise.ar(env1), hpf1), bpf1, 3);
	noise2 = BPF.ar(HPF.ar(GrayNoise.ar(env2), hpf2), bpf2, 0.7, 0.7);
	sig = noise1 + noise2;
	sig = sig * gain;
	sig = 0.4 * sig.softclip * amp;
	Out.ar(out, [sig,sig]);
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

/*SynthDef(\cosc, { arg out = 0, t_trig = 1, amp = 1, pan = 0, freq = 512, doneAction = 2;
    var env = EnvGen.ar(Env.adsr(0.5,1,1,0), t_trig, doneAction: doneAction);
    var sig = COsc.ar(80,[freq,freq+0.5], 1, 0.1);
    sig  = sig + COsc.ar(80,[freq,freq+0.5]*2, 1, 0.1);
    sig = FreeVerb.ar(sig*env,1);
    sig = LeakDC.ar(sig);
    OffsetOut.ar(0,sig*amp);
}).add;*/

~noiseInjectionSynthDef = SynthDef(\noiseInjection, { arg in = 0, out = 0, drywet = -0.6, attack = 0.01, release = 0.01, noiseType = 0, nType5Chaos = 1.5, noiseLevel = 1, impSource = 0, impFreq = 52.9, impLevel = 0;
	var input, sig, inputAmp, imp;
	input = InFeedback.ar(in, 2);
	inputAmp = Amplitude.kr(input, attack, release);
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

SynthDef(\res, { | out=0 pan=0 freq=40 fltBus t_gate=1 doneAction=2|
	var aEnv, osc, flt;
	aEnv = EnvGen.kr(Env.perc(0, 0.7), t_gate, doneAction: doneAction);
	osc = Mix([Saw.ar(freq), Pulse.ar(freq / 2, 0.5)]);
	flt = RLPF.ar(osc, In.kr(fltBus, 1), 0.1, aEnv);
	ReplaceOut.kr(fltBus, LFNoise1.kr(0.3, 1000, 1500));

	OffsetOut.ar(out, Pan2.ar(flt, pan));
}).add;

SynthDef(\mutantFric, { arg out = 0, amp = 1, spec1 = 0.00001, spec2 = 0.03, noiseFreq = 3, attack = 0.01, release = 1, gate = 1, doneAction = 2;
	var friction, sig;
	friction = Array.fill(5, {
		[spec1.max(0.00001), spec2.max(0.03)].asSpec.map(LFNoise2.kr(noiseFreq))
	});
	sig = Friction.ar(LFTri.ar(50), friction: friction, mass: friction*30000);
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

SynthDef(\tweetErosion, { arg out = 0, amp = 1, attack = 0.01, release = 10, feedBack = 1, t_trig = 1, doneAction = 2;
	var sig, env, input, div;
	input = LocalIn.ar(2).range(0,0.9)+0.1;
	div = LagUD.ar(input, 0, 0.2);
	sig = PinkNoise.ar(1!2);
	sig = tanh(500*(sig**(8/div)));
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	LocalOut.ar(sig * feedBack);
	sig = Splay.ar(sig,1-input);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\harshTexture, { arg out = 0, amp = 1, impFreq = 2, delTimeMod = 2, attack = 0.01, release = 10, t_trig = 1, doneAction = 2;
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

SynthDef(\ultraHiSummer, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 10, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = Blip.ar(
		[16e3,16150],
		2,
		LFTri.ar(
			Duty.ar(
				LFNoise0.ar(0.2,4,6),
				0,
				Dseq([70,30,0],inf)
			)
		).clip(0,1)
	);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\ambiantPic, { arg out = 0, amp = 1, lfnFreq = 22, attack = 0.01, release = 10, delTime1 = 0.13, delTime2 = 0.1, decTime = 0.2, t_trig = 1, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	sig = LFNoise2.kr(lfnFreq, 5, 9);
	sig = CombC.ar(
		Splay.ar(
			Gendy3.ar(
				[4,2],
				[0.5,1] * decTime,
				[1/9,1/4]*sig,
				[1/2,1/8]*sig,
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

SynthDef(\attWind, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = TDuty.kr(Dseq([1,1,4,2,2]/8,inf));
	sig = Resonz.ar(
		WhiteNoise.ar!2,
		Demand.kr(sig,0,Dseq([250,8e3],inf)),
		Demand.kr(sig,0,Dwhite(0.01,0.5,inf))
	);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

~dStowellSynthDef = SynthDef(\dStowell, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 2, freq = 6/3, width = 1/5, lpf = 20000, doneAction = 2;
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

SynthDef(\henon, { arg out = 0, amp = 0.3, pan = 0, freq = 440, a = 1.3, b = 0.3, x0 = 0.30501993062401, x1 = 0.20938865431933, atk = 0.01, sus = 1, rel = 1, ts = 1, t_trig = 1, doneAction = 2;
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

SynthDef(\ploux, { arg out = 0, amp = 0.1, pan = 0, att = 0.1, dec = 0.1, sus = 0.8, rel = 0.1, dustfreq = 2, dustdecay = 0.7, freq = 200, fmfreq = 100, t_trig = 1, doneAction = 2;
    var sig, dust;
    dust = Dust.ar(dustfreq);
    dust = Decay.ar(dust, dustdecay);
    sig = SinOsc.ar(freq * ( SinOsc.ar(fmfreq * dust) * 1 + 1 ));
    sig = sig * EnvGen.kr(Env.adsr(att, dec, sus, rel), t_trig, doneAction: doneAction);
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}, [\kr ! 11, \tr, \ir].flat).add;

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
	Out.ar(out, [sig, sig]);
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
	Out.ar(out, sig);
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

///////////////////////////////////////  Input

~inputSigSynthDef = SynthDef(\inputSig, { arg out = 0, in = 0, gate = 1, amp = 0.5, pan = 0, attack = 0.5, release = 1, curve = (-4), delaytime = 0, lpfreq = 20000, band1freq = 8000, band1rq = 1, band1db = 0, band2freq = 1200, band2rq = 1, band2db = 0, band3freq = 80, band3rq = 1, band3db = 0, hpfreq = 20, doneAction = 2;
	var input, sig;
	input = SoundIn.ar(in);
	sig = BHiPass.ar(input, Lag2.kr(hpfreq.max(20).min(20000), 0.5)); // HPF
	sig = BPeakEQ.ar(sig, Lag2.kr(band1freq.max(20).min(20000), 0.5), band1rq, band1db); // Band 1
	sig = BPeakEQ.ar(sig, Lag2.kr(band2freq.max(20).min(20000), 0.5), band2rq, band2db); // Band 2
	sig = BPeakEQ.ar(sig, Lag2.kr(band3freq.max(20).min(20000), 0.5), band3rq, band3db); // Band 3
	sig = BLowPass.ar(sig, Lag2.kr(lpfreq.max(20).min(20000), 0.5)); // LPF
	sig = sig * EnvGen.kr(Env.asr(attack, 1, release, curve), gate, gate, doneAction: doneAction);
	sig = DelayL.ar(sig, 1, delaytime);
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

///////////////////////////////////////  Tonal

SynthDef(\cow, { arg out=0, amp=0.5, pan=0, att = 0.001, rel=1, tu=1, gate=1, doneAction=2;
	var sig;
	var env = EnvGen.ar(Env.asr(att,1,rel), gate, doneAction: doneAction);
	sig = LFPulse.ar(550*tu)+LFPulse.ar(tu*400*(env+250));
	sig = Ringz.ar(sig,(30..35)*10.234*tu,1).mean;
	sig = Pan2.ar(sig*env, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\notes,{arg out = 0, amp = 0.5, pan = 0, att = 0.01, rel = 0.1, freq = 69, tu = 1, t_gate = 1, doneAction = 2;
	var env = EnvGen.ar(Env.perc(att, rel), t_gate, doneAction: doneAction);
	var sig = WhiteNoise.ar(env);
	sig = CombL.ar(sig,0.2,(freq+(432.cpsmidi-69)).midicps/SampleRate.ir,1)+sig;
	sig = CombL.ar(sig,0.2,(freq+(432.cpsmidi-69)).midicps/SampleRate.ir,0.2)+sig;
	sig = sig *env *0.5;
	sig = CompanderD.ar(sig*2,0.5,1,0.5);
	sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\notes2,{arg out=0,gate =1,notes=68,at = 0.01,sus=0.4,snd=18;
	var env = EnvGen.ar(Env.adsr(at,1,sus,1.4),gate,doneAction:2);
	//var env = EnvGen.ar(Env.perc(0.01,1),gate,doneAction:2);
	var note = (notes+(432.cpsmidi-69)).midicps;
	var sig = Mix.ar(SinOsc.ar([note,note*2,note/2]));
	sig = Splay.ar(sig*0.1);
	OffsetOut.ar(out,sig*env*0.5);
	//Out.ar(snd,sig*env);
}).add;

SynthDef(\sinus,{arg out = 0, amp = 0.5, pan = 0, freq = 100, t_gate = 1, attack = 0, release = 0.1, lfo = 1, doneAction = 2;
	var env  = EnvGen.ar(Env.perc(attack,  release), t_gate, doneAction: doneAction);
	var sig = SinOsc.ar(freq+(432-69.midicps)*SinOsc.kr(lfo),0,env);
	sig = HPF.ar(sig,100);
	sig = CompanderD.ar(sig,0.3,0.3,1.5,0.0001,0.01);
	sig = Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, sig);
}).add;

~prayerBellSynthDef = SynthDef(\prayerBell, { |out = 0, t_trig = 1, amp = 0.5, pan = 0, sing_switch = 0, freq = 2434, decayscale = 1, lag = 10, level = 0.08, i_doneAction = 2|
	var sig, input, first, freqscale, mallet, sing;
	freq = freq.max(20).min(5000);
	freqscale = freq / 2434;
	decayscale = decayscale.min(1);
	freqscale = Lag3.kr(freqscale, lag);
	decayscale = Lag3.kr(decayscale, lag);

	mallet = LPF.ar(Trig.ar(t_trig, SampleDur.ir)!2, 10000 * freqscale);
	sing = LPF.ar(
		LPF.ar(
			{
				PinkNoise.ar * Integrator.kr(sing_switch * 0.001, 0.999).linexp(0, 1, 0.01, 1) * amp
			} ! 2,
			2434 * freqscale
		) + Dust.ar(0.1), 10000 * freqscale
	) * LFNoise1.kr(0.5).range(-45, -30).dbamp;
	input = mallet + (sing_switch.clip(0, 1) * sing);


	sig = DynKlank.ar(`[
		[
			(first = LFNoise1.kr(0.5).range(2424, 2444)) + Line.kr(20, 0, 0.5),
			first + LFNoise1.kr(0.5).range(1,3),
			LFNoise1.kr(1.5).range(5435, 5440) - Line.kr(35, 0, 1),
			LFNoise1.kr(1.5).range(5480, 5485) - Line.kr(10, 0, 0.5),
			LFNoise1.kr(2).range(8435, 8445) + Line.kr(15, 0, 0.05),
			LFNoise1.kr(2).range(8665, 8670),
			LFNoise1.kr(2).range(8704, 8709),
			LFNoise1.kr(2).range(8807, 8817),
			LFNoise1.kr(2).range(9570, 9607),
			LFNoise1.kr(2).range(10567, 10572) - Line.kr(20, 0, 0.05),
			LFNoise1.kr(2).range(10627, 10636) + Line.kr(35, 0, 0.05),
			LFNoise1.kr(2).range(14689, 14697) - Line.kr(10, 0, 0.05)
		],
		[
			LFNoise1.kr(1).range(-10, -5).dbamp,
			LFNoise1.kr(1).range(-20, -10).dbamp,
			LFNoise1.kr(1).range(-12, -6).dbamp,
			LFNoise1.kr(1).range(-12, -6).dbamp,
			-20.dbamp,
			-20.dbamp,
			-20.dbamp,
			-25.dbamp,
			-10.dbamp,
			-20.dbamp,
			-20.dbamp,
			-25.dbamp
		],
		[
			20 * freqscale.pow(0.2),
			20 * freqscale.pow(0.2),
			5,
			5,
			0.6,
			0.5,
			0.3,
			0.25,
			0.4,
			0.5,
			0.4,
			0.6
		] * freqscale.reciprocal.pow(0.5)
	], input, freqscale, 0, decayscale);
	DetectSilence.ar(sig, doneAction: i_doneAction);
	sig = Pan2.ar(sig, pan, level);
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\waveguideFlute, { arg out = 0, amp = 2, scl = 0.2, freq = 440, ipress = 0.9, ibreath = 0.09, ifeedbk1 = 0.4, ifeedbk2 = 0.4, dur = 1;

	var kenv1, kenv2, kenvibr, kvibr, sr, cr, block;
	var poly, signalOut, ifqc;
	var aflow1, asum1, asum2, afqc, atemp1, ax, apoly, asum3, avalue, atemp2, aflute1;
	var fdbckArray;

	sr = SampleRate.ir;
	cr = ControlRate.ir;
	block = cr.reciprocal;

	ifqc = freq;

	// noise envelope
	kenv1 = EnvGen.kr(Env.new(
		[ 0.0, 1.1 * ipress, ipress, ipress, 0.0 ], [ 0.06, 0.2, dur - 0.46, 0.2 ], 'linear' )
	);
	// overall envelope
	kenv2 = EnvGen.kr(Env.new(
		[ 0.0, amp, amp, 0.0 ], [ 0.1, dur - 0.02, 0.1 ], 'linear' ), doneAction: 2
	);
	// vibrato envelope
	kenvibr = EnvGen.kr(Env.new( [ 0.0, 0.0, 1, 1, 0.0 ], [ 0.5, 0.5, dur - 1.5, 0.5 ], 'linear') );

	// create air flow and vibrato
	aflow1 = LFClipNoise.ar( sr, kenv1 );
	kvibr = SinOsc.ar( 5, 0, 0.1 * kenvibr );

	asum1 = ( ibreath * aflow1 ) + kenv1 + kvibr;
	afqc = ifqc.reciprocal - ( asum1/20000 ) - ( 9/sr ) + ( ifqc/12000000 ) - block;

	fdbckArray = LocalIn.ar( 1 );

	aflute1 = fdbckArray;
	asum2 = asum1 + ( aflute1 * ifeedbk1 );

	//ax = DelayL.ar( asum2, ifqc.reciprocal * 0.5, afqc * 0.5 );
	ax = DelayC.ar( asum2, ifqc.reciprocal - block * 0.5, afqc * 0.5 - ( asum1/ifqc/cr ) + 0.001 );

	apoly = ax - ( ax.cubed );
	asum3 = apoly + ( aflute1 * ifeedbk2 );
	avalue = LPF.ar( asum3, 2000 );

	aflute1 = DelayC.ar( avalue, ifqc.reciprocal - block, afqc );

	fdbckArray = [ aflute1 ];

	LocalOut.ar( fdbckArray );

	signalOut = avalue;

	OffsetOut.ar(out, [ signalOut * kenv2, signalOut * kenv2 ] );

}).add;

SynthDef(\justwannahavefun,{|out= 0 amp = 0.1 pan=(-0.1) freq = 440 ringTime=10.0 |

	var impulse, filter, env;

  	impulse = Impulse.ar(0);

	filter = Ringz.ar(impulse,(freq.cpsmidi + (Rand(0.2,1.2)*SinOsc.kr(Rand(10,50)))).midicps,ringTime);

	env = EnvGen.ar(Env([0.0,1.0,1.0,0.0],[0.001,0.04,0.04]),doneAction:2);

	OffsetOut.ar(out,Pan2.ar((filter.softclip(0.9))*env*amp,pan));

}).add;

SynthDef(\marimba1, { arg out = 0, freq = 440, amp = 0.4;
	var snd, env;
	env = Env.linen(0.015, 1, 0.5, amp).kr(doneAction: 2);
	snd = BPF.ar(Saw.ar(0), freq, 0.02);
	snd = BLowShelf.ar(snd, 220, 0.81, 6);
	snd = snd * env;
	OffsetOut.ar(out, Splay.ar(snd));
}).add;

SynthDef(\noisyTone, { arg out = 0, freq = 440, amp = 0.2, pan = 0.5;
	var snd, env;
	env = Env.perc(0.02, 0.1).kr(doneAction: 2);
	snd = Mix(LFPulse.ar(
		freq: freq * [1, 5/2],
		iphase: 0.0,
		width: 0.5,
		mul: amp));
	snd = snd * env ;
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

~ping_mhSynthDef = SynthDef(\ping_mh,{arg out=0, amp=0.2, pan=0, freq=440, dur=0.1, attack=0.001;
    var sig, freq2;
    freq=freq*rrand(1,1.01);
    freq2=freq*rrand(1,1.01);
	e=EnvGen.ar(Env.perc(attack,dur.max(0.01),curve:-4),doneAction:2);
    sig=SinOsc.ar([freq,freq2],0,amp*e);
    sig=Pan2.ar(sig,pan);
    OffsetOut.ar(out,sig)
}).add;

SynthDef(\plucking, {arg amp = 0.1, freq = 440, decay = 5, coef = 0.1;
var env, snd;
env = EnvGen.kr(Env.linen(0, decay, 0), doneAction: 2);
snd = Pluck.ar(
        in: WhiteNoise.ar(amp),
        trig: Impulse.kr(0),

        maxdelaytime: 0.1,
        delaytime: freq.reciprocal,
        decaytime: decay,
        coef: coef);
    OffsetOut.ar(0, [snd, snd]);
}).add;

SynthDef(\pwmbling,{|out= 0 freq = 440 amp = 0.1 gate=1 lforate = 4.85 lfowidth= 0.5 cutoff= 12000 rq=0.25 pan = 0.0|

	var lfo, pulse, filter, env;
	var basefreq =  ((freq.cpsmidi)+[0,12.12]).midicps;

	lfo = LFTri.kr(lforate*[1,1.01],Rand(0,2.0)!2);

	pulse = Pulse.ar(basefreq,lfo*lfowidth+0.5);

	env = EnvGen.ar(Env.adsr(0.0,1.0,0.2,1.5),gate,doneAction:2);

	filter = RLPF.ar(pulse,(cutoff*(env.squared))+100,rq);

	OffsetOut.ar(out,Pan2.ar(Mix(filter)*env*amp,pan));

}).add;

SynthDef(\ressquares,{|out= 0 freq = 440 amp = 0.1 gate=1 cutoff=8000 rq=0.8 pan=(-0.1)|

	var pulse, filter, env;

	//2 cents detune for second oscillator
	pulse = Mix(Pulse.ar( ((freq.cpsmidi)+[0,0.02]).midicps, 0.5))*0.5;

	filter =  BLowPass.ar(pulse,100+cutoff,rq);

	env = EnvGen.ar(Env.adsr(0.002,0.1,1.0,0.2),gate,doneAction:2);

	OffsetOut.ar(out,Pan2.ar(filter*env*amp,pan));

}).add;

SynthDef(\glauk, { arg out = 0, amp = 1, attack = 0.01, release = 2, gate = 1, doneAction = 2;
	var sig, env;
	// env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = Splay.ar(
		SinOsc.ar(
			Array.fill(50,{\freq.asSpec.map(LFNoise2.kr(0.001))})
		)
	);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\scinty, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 10, doneAction = 2;
	var sig, env;
	// env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	sig = Splay.ar(
		Array.fill(15,{Ringz.ar(Dust.ar(Rand(1,10)), Rand(50,9000).round(100), 2)},
			1,
			0.5,
			0
		)
	);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

SynthDef(\bublybub, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 10, x = 165, doneAction = 2;
	var sig, env, waveForm, freq, dur, input;
	// env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	waveForm = SinOsc;
	freq = Trig.ar(Saw.ar(x),1);
	dur = waveForm.ar(freq * x);
	input = waveForm.ar(freq);
	sig = GVerb.ar(GrainIn.ar(2,dur,dur/2,input,freq*input,-1),9);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

~chdegaulleaboutSynthDef = SynthDef(\chdegaulleabout, { arg out = 0, amp = 1, pan = 0, freq = 0.01, attack = 0.01, release = 10, t_trig = 1, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	sig = SinOsc.ar(LFNoise1.kr(freq).exprange(100,{exprand(300,10000)}!120)).mean;
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\t2001, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 10, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	sig = PinkNoise.ar(1);
	20.do{
		sig = BBandStop.ar(sig, LFNoise1.kr(0.05.rand).exprange(40,15000), exprand(0.1,2));
	};
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\claudTweet, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 10, doneAction = 2;
	var sig, env, x;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	sig = LFTri.ar(
		Duty.ar(Dseq([3,1]/12,inf),
			0,
			Dseq(
				x = (3..6);
				allTuples(x/.t x).flat*[100,200,400]++0
			)
		)
	);
	sig = GVerb.ar(sig, 25, 5)/5;
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;

~ambitekSynthDef = SynthDef(\ambitek, { arg out = 0, amp = 1, attack = 0.01, release = 10, envSL1 = 0, envSL2 = 0.72, envSL3 = 0.16, envSL4 = 0, envST1 = 0.2, envST2 = 0.6, envST3 = 0.8, envSCurve = (-4), sawFreq = 50, delTime = 0.1, delDecay = 2, brfRq = 2, t_trig = 1, doneAction = 2;
	var sig, env, envS;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	envS = EnvGen.kr(Env([envSL1, envSL2, envSL3, envSL4], [envST1, envST2, envST3], envSCurve));
	sig = Saw.ar(sawFreq * envS);
	2.do{|i|
		var f = 2 ** (8 - i);
		sig = BRF.ar(
			AllpassN.ar(sig, 1, Lag2.kr(delTime, 0.2) / (12 - i), delDecay),
			Lag2.ar(80 ** TRand.ar(0, 1, Impulse.ar(f / 32, 1/2)).lag(1 / f) * 80, 0.5),
			brfRq
		);
	};
	sig = sig * env;
	OffsetOut.ar(out, sig!2 * amp);
}).add;

~mainSynthDef = SynthDef(\main,{arg out = 0, amp = 0.5, pan = 0, lev = 10, freq = 50, wnoiseAmp = 1, sinAmp = 1, sinFreq = 30, sel = 0, envLevel1 = 0.0, envLevel2 = 1.0, envLevel3 = 0.0, levelScale = 1, levelBias = 0, att = 0.0, rel = 0.1, timeScale = 1, noiseAmp = 1, hpf = 8000, revtime = 3, room = 10, damp = 0.5, revMix = 0, t_trig = 1, doneAction = 2;
	var revSig;
	var fmod = SinOsc.ar(freq/60, 0, freq/60);
	var sig = [
		SinOsc.ar([freq, freq + 600] + fmod, 0, [lev, 0.005]).mean.tanh,
		HPF.ar(WhiteNoise.ar(wnoiseAmp), hpf),
		SinOsc.ar(sinFreq, 0, sinAmp),
		VarSaw.ar(freq/40, mul: lev * 10000)
	];
	var env = EnvGen.kr(Env.new([envLevel1, envLevel2, envLevel3], [att, rel]), t_trig, levelScale, levelBias, timeScale, doneAction);
	sig = (Select.ar(sel, sig) * env).fold(-1, 1) * 0.7 + SinOsc.ar(40, 0, 0.3) * (1 + HPF.ar(WhiteNoise.ar(0.02 * noiseAmp), hpf));
	revSig = GVerb.ar(sig, Lag3.kr(room).max(0.01), revtime, damp);
	sig = SelectX.ar(revMix, [sig, revSig]);
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\flash, { arg out = 0, amp = 0.3, fund = 400, decay = 4, filter = 1, doneAction = 2;
	var sig;
	sig = Mix.ar( Array.fill(7,
		{
			arg counter;
			var partial;
			partial = counter + 1;
			SinOsc.ar(fund*partial) * EnvGen.kr(Env.linen(0, 0, decay), levelScale: 1/(partial*filter)
			) * max(0, LFNoise1.kr(rrand(5.0, 12.0)));
		}
	)
	);
	sig = Pan2.ar(sig, Rand(-1.0, 1.0), amp);
	DetectSilence.ar(sig, doneAction: doneAction);
	OffsetOut.ar(out, sig)
}).add;

SynthDef(\elifm, { arg freq = 500, mRatio = 1, cRatio = 1, index = 1, iScale = 5, amp = 0.2, atk = 0.01, rel = 3, cAtk = 4, cRel = (-4), pan = 0;
    var car, mod, env, iEnv;
    iEnv = EnvGen.kr(
        Env.new(
            [index, index * iScale, index],
            [atk, rel],
            [cAtk, cRel]
        )
    );
    env = EnvGen.kr(
        Env.perc(atk, rel, curve: [cAtk, cRel]),
        doneAction: 2
    );
    mod = SinOsc.ar(freq * mRatio, mul: freq * mRatio * iEnv);
    car = SinOsc.ar(freq * cRatio + mod) * env * amp;
    car = Pan2.ar(car, pan);
    OffsetOut.ar(0, car);
}).add;

~polishFabSynthDef = SynthDef(\polishFab, { arg out = 0, amp = 0.2, attack = 11, release = 6, feedBack = 2, phmodFrq = 0.5, freq1 = 64, freq2 = 23, envfL1 = 0, envfL2 = 500, envfL3 = 20, envfL4 = 0, envfT1 = 0.2, envfT2 = 0.01, envfT3 = 0.12, envfCure = (-4), frqScale = 0.5, t_trig = 1, doneAction = 2;
	var sig, env, envf, num, input;
	num = 8;
	input = LocalIn.ar(2) * feedBack;
	envf = EnvGen.ar(Env([envfL1, envfL2, envfL3, envfL4], [envfT1, envfT2, envfT3], envfCure), t_trig) * frqScale;
	sig = Mix.arFill(
		num,
		{ arg i;
			var oddHarm = i * 2 + 1;
			var evenHarm = i * 2 + 2;
			SinOsc.ar(
				[freq1 * oddHarm, freq2 * evenHarm] + envf,
				Latch.kr((input * (i + 1)) * pi, Impulse.kr((oddHarm / (3 * pi)) + phmodFrq)),
				num.reciprocal
			)
			*
			EnvGen.kr(
				Env.sine(num / i)
			)
		}
	);
	env = EnvGen.kr(
		Env.perc(attack, release),
		t_trig,
		doneAction: doneAction,
		levelScale: 0.75
	);
	sig = (sig[0] + sig[1]) * env;
	LocalOut.ar(sig);
	sig = Splay.ar(sig, 1, amp);
	OffsetOut.ar(out, sig /** amp*/);
}).add;

SynthDef(\slatechre, { arg out = 0, amp = 1, attack = 0.01, release = 5, t_trig, doneAction = 2;
	var env, note, snd, delaytime, damp, size, diff, feedback, localout;
	env = Linen.kr(t_trig, attack, 1, release, doneAction);
	note = Demand.kr(Impulse.kr(0) + Dust.kr(0.1), 0, Diwhite(60, 80, inf));
	delaytime = Demand.kr(Impulse.kr(0) + Dust.kr(0.3), 0, Dwhite(0.1, 0.3, inf));
	damp = Demand.kr(Impulse.kr(0) + Dust.kr(0.4), 0, Dwhite(0.2, 0.6, inf));
	size = Demand.kr(Impulse.kr(0) + Dust.kr(0.3), 0, Dwhite(2, 10, inf));
	diff = Demand.kr(Impulse.kr(0) + Dust.kr(0.2), 0, Dwhite(0.5, 1.0, inf));
	feedback = Demand.kr(Impulse.kr(0) + Dust.kr(0.4), 0, Dwhite(0.8, 1.0, inf));
	snd = SinOsc.ar(freq: [note, note+LFNoise1.kr(freq: 0.1).range(-0.25, 0.25)].midicps);
	localout = Mix.ar(5.collect({ |i|
		Pan2.ar(
			in: Greyhole.ar(in: PitchShift.ar(in: snd, pitchRatio: i), delayTime: delaytime, damp: damp, size: size, diff: diff, feedback: feedback, modDepth: 0.1, modFreq: 5),
			pos: LFNoise1.ar(freq: TRand.ar(10.reciprocal, 1, Impulse.kr(8.reciprocal))).range(-1,1),
			level: (i+1).reciprocal
		) * -20.dbamp;
	}));
	localout = Compander.ar(in: localout, control: localout, thresh: -6.dbamp, slopeAbove: 3.reciprocal);
	LocalOut.ar(localout);
	snd = LocalIn.ar(2);
	OffsetOut.ar(out, (snd.tanh * env) * amp);
}).add;

SynthDef.new(\Colleen, { arg out = 0, amp=1, pan = 0, atk=0.35, rel=2, freq=110, doneAction = 2;
	var sig, env;
	freq = 1*freq*(320/250)*PinkNoise.kr(0.05,1)*BrownNoise.kr(0.01,1)*2;
	sig = LPF.ar(CombC.ar(Decay.ar(Impulse.ar(0), 0.2, BrownNoise.ar), 4/(BrownNoise.kr(XLine.kr(10,1,0.2),freq)), 4/(PinkNoise.kr(XLine.kr(10,1,0.2),freq)), 3, 0.4),4000);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction: doneAction);
	sig = sig + PinkNoise.ar(0.1);
	sig = LPF.ar(sig, XLine.kr(100,700,rel*0.1));
	sig = (sig*env*amp)*4;
	sig = Pan2.ar(sig,pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\Zeynep, { arg out = 0, freq=440, envL1 = 0, envL2 = 0.03, envL3 = 0.1, envL4 = 0.2, envL5 = 0, atk=1, rel=4, amp=1, dur=0.2, beats=1, doneAction = 2;
	var sig, env;
	sig = Resonz.ar(WhiteNoise.ar(0.5), freq, XLine.kr(0.1, 0.001, dur*beats))*50;
	env = EnvGen.kr(Env.new([envL1,envL2,envL3,envL4,envL5],[atk,atk,dur,rel],[1,-1]),doneAction: doneAction);
	sig = (sig*env*amp).tanh;
	Out.ar(out, [sig, sig]);
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

///////////////////////////////////////  Bass

SynthDef(\bass1,{arg out = 0, amp = 1, pan = 0, att = 0, dec = 8, sus = 1, rel = 4, tu = 1, gate = 1, doneAction = 2;
    var env = EnvGen.ar(Env.adsr(att, dec, sus, rel), gate, doneAction: doneAction);
    var freq = EnvGen.ar(\freqenv.kr(Env([50, 40],[0.1, 0.3, 0.3])));
    var sig = SyncSaw.ar(freq*tu,20);
    sig = BRF.ar(sig,432,1);
    sig = HPF.ar(sig,300);
	sig = Pan2.ar(sig.distort, pan, amp) * env;
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\bass3,{arg gate = 1, amp=1, out=0,rel=0.1,pan=0,tu=1.54;
    var env = EnvGen.ar(Env.adsr(0,4,1,0.1),gate,doneAction:2);
    var freq = EnvGen.ar(Env([14000,50,30],[0.001,0.1,0.1]));
    var sig = LFPar.ar([tu,tu+1],SinOsc.kr([2,1]))+LFPar.ar(tu,SinOsc.kr([1,2]));
    sig = Splay.ar(sig,SinOsc.kr(0.1),1,SinOsc.kr(pan));
    OffsetOut.ar(out,sig*amp*env);
}).add;

SynthDef(\bass,{arg out=0, gate = 1 ,dis = 0.5,freq=60,tu = 1,amp=1,atf = 80, rel =1;
    var env = EnvGen.ar(Env.adsr(0.05,0,1,rel),gate,doneAction:2);
    var frequ = EnvGen.ar(Env([freq+1000,freq-100],[0.05,0.1]));
    var sig = LFSaw.ar(LFSaw.ar(frequ-100,0,frequ-200,frequ*tu),0,env);
    sig = CrossoverDistortion.ar(sig,dis,0.05)+sig;
    sig = DelayL.ar(sig,0.05,0.001)+sig;
    sig = DelayL.ar(sig,0.05,0.001)+sig;
    sig = DelayL.ar(sig,0.05,0.01)+sig;
    sig = BPeakEQ.ar(sig,80,1,6);
    sig = sig *0.4*(env);
    //sig = LPF.ar(sig,100);
    sig = Compander.ar(sig,In.ar(0,1),0.05,1,0.1,0.01,0.1);
    OffsetOut.ar(out,sig * amp);
}).add;

~sinBassSynthDef = SynthDef(\sinBass, { arg out = 0, gate = 1, amp = 1, pan = 0, loopNode = nil, attack = 0.2, release = 4, curve = (-4), envLevel1 = 0, envLevel2 = 40, envLevel3 = 32, envLevel4 = 50, envLevel5 = 0, envLevel6 = 60, envTime1 = 0.5, envTime2 = 0.3, envTime3 = 0.25, envTime4 = 1, envTime5 = 0.5, doneAction = 2;
	var freqEnv, env, sig;
	freqEnv = EnvGen.kr(Env([envLevel1, envLevel2, envLevel3, envLevel4, envLevel5, envLevel6], [envTime1, envTime2, envTime3, envTime4, envTime5], curve), gate);
	env = EnvGen.kr(Env.asr(attack, 1, release, curve), gate, doneAction: doneAction);
	sig = HPF.ar(SinOsc.ar(freqEnv, mul: env), 20);
	OffsetOut.ar(out, Pan2.ar(sig, pan, Lag.kr(amp, 0.5)));
}).add;

SynthDef(\moogbasstone2,{ arg out = 0, freq = 440, amp = 0.1, gate = 1, attackTime = 0.2, fenvamount = 0.5, cutoff =  1000, gain = 2.0, pan = 0.0;

	var osc, filter, env, filterenv;

	//alternative: richer source
	osc = Mix(Pulse.ar(freq.lag(0.05)*[1.0,1.001,2.0],Rand(0.45,0.5)!3,0.33));

	filterenv = EnvGen.ar(Env.adsr(attackTime,0.0,1.0,0.2),gate,doneAction:2);
	filter =  MoogFF.ar(osc,cutoff*(1.0+(fenvamount*filterenv)),gain);

	env = EnvGen.ar(Env.adsr(0.001,0.3,0.9,0.2),gate,doneAction:2);

	OffsetOut.ar(out,Pan2.ar((0.7*filter+(0.3*filter.distort))*env*amp,pan));

}).add;

~tweetAnaBassSynthDef = SynthDef(\tweetAnaBass, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 2, freq = 60, ffreq = 60, tu = 9, compTresh = 0.5, t_trig = 1, doneAction = 2;
	var sig, env, bw;
	bw = LFNoise0.ar(_);
	sig = max(
		max(bw.(4),l=bw.(6)),
		SinOsc.ar(freq * ceil(l*tu).lag(0.1))*0.7
	);
	sig = tanh(
		BBandPass.ar(sig, ffreq, bw.(1).abs/2)*700*l.lag(1)
	);
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = sig * env;
	sig = Compander.ar(sig, sig, compTresh, 1, 1/8, 0.002);
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

)