
(
Ndef(\drumy, { arg freq=200, pan=0, amp=0.1;
	var sig;
	var in = InFeedback.ar(\inbus.kr(BusDef(\sendbus2, \audio)), 2); 
	sig = in;
	//sig = sig + DelayC.ar(sig, 0.01, 0.0001 * [0.1235,1,0.86534]).mean/2;
	sig = Compander.ar(sig, in, \cpt.kr(0.4), \cpbelow.kr(1.001), \cpabove.kr(0.9), \cpclamp.kr(0.01), \cprelax.kr(0.1));
	sig = sig * \gain.kr(1);
	sig = SelectX.ar(\mix.kr(1), [in, sig]);
}).play;
);

// dub echo
// ?
(
// echo filterIn
Ndef(\echo, { arg freq=200, pan=0, amp=0.1;
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
	sig = CombL.ar(sig, 1/2/~t, 1/8/~t, 2/~t);
	sig = sig * \gain.kr(1);
	//sig = SelectX.ar(mix, [in, sig]);
	in + sig;
//}).play(BusDef(\sendbus1).index, 2);
}).play(0, 2);
);

Ndef(\verb, { arg freq=200, pan=0, amp=0.1;
	var sig;
	var in = InFeedback.ar(\inbus.kr(BusDef(\sendbus0, \audio)), 2); 
	sig =in;
	sig = FreeVerb2.ar(sig[0], sig[1], \mix.kr(0.5), \room.kr(1), \damp.kr(0.4));
	sig;
});

Ndef(\fx).put(50, \filter -> { arg in;
	var sig = in;
	
	sig = Greyhole.ar(sig, 
		\delay.kr(1/4),\damp.kr(0.1),\size.kr(1), \diff.kr(0.707) , \feedback.kr(0.8), \modDepth.kr(0.1), \modFreq.kr(2)
	);

	sig;
});



//////////////// FFT fx


(
	// it's some kind of lowpass multiband gate
Ndef(\localmax, { arg freq=200, pan=0, amp=0.1;
	var sig;
	var osig;
	sig = InFeedback.ar(\inbus.kr(BusDef(\zero, \audio)), 2); 
	osig = sig;
	sig = FFT(LocalBuf(2**10), sig);
	sig = PV_MagSquared(sig);
	sig = PV_LocalMax(sig, 22);
	sig = IFFT(sig) * 50;
	sig = sig * (-28.dbamp);
	sig = SelectX.ar(MouseX.kr(0,1), [osig, sig]);
	sig;
}).play;
);


////////////////////////

SynthDef(\filterfx, { arg out=0, amp=0.1, gate=1;
	var sig;
	var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
	var in = InFeedback.ar(\inbus.kr(BusDef(\zero, \audio)), 2); 
	sig = in;
	sig1 = LPF.ar(sig, \lpf.kr(20000));
	sig = SelectX.ar(\lpmix.kr(0), [sig, sig1]);
	sig1 = HPF.ar(sig, \hpf.kr(20));
	sig = SelectX.ar(\hpmix.kr(0), [sig, sig1]);
	sig = sig * EnvGen.ar(Env.adsr(0.01,0,1,0.01),gate,doneAction:2);
	Out.ar(out, sig);
}).add;

////////////////////////////


(
SynthDef(\fmbell, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
	freq = freq * EnvGen.kr(Env([1,1.002,0.998,1],[0.1,0.8]), 1);
	sig1 = SinOsc.ar(freq * 2.6706 + 0.13) * 2 + 1; 
	sig2 = SinOsc.ar(freq * 0.9998 * sig1);
	sig3 = SinOsc.ar(freq * 2.6629 * sig1 + 2.04);
	sig4 = LFCub.ar(freq * 0.9991 * sig1 + 2.14);
	sig5 = SinOsc.ar(freq * 2.6656 * sig1 - 2);
	sig6 = SinOsc.ar(freq * 1 * sig1 + 1.84);
	//sig = sig2 + sig3 + sig4 + sig5 + sig6;
	sig = [sig1, sig2, sig3, sig4, sig5, sig6] * DC.ar([0,0.5,0.5, 0.5,0.5,0.5]);
	//sig.debug("sig");
	//sig = sig /34;
	sig = sig * EnvGen.ar(Env.adsr(0.01,0,1,2.1,1,-1),gate,doneAction:2);
	sig = Pan2.ar(sig, pan + [ 0, -0.5, -0.5, 0.5, 0.5, 0], amp).sum;
	Out.ar(out, sig);
}).add;
);

(
SynthDef(\chorus, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var in = InFeedback.ar(\inbus.kr(BusDef(\zero, \audio)), 2); 
	sig = LocalIn.ar(2) * \fb.kr(0.4);
	sig = sig + in;
	sig = DelayC.ar(sig, \maxdelay.ir(0.2), \delay.kr(0.0101) * ((0..7)/7 - 0.5 * \diff.kr(0.4001) + 1) * ( SinOsc.kr(\modfreq.kr(8.1)) * \modamp.kr(0.48) + 1 )).mean;
	//sig = LPF.ar(sig, \dif.kr(7500));
	LocalOut.ar(sig);

	sig = LPF.ar(sig, \lpf.kr(15000));
	sig = HPF.ar(sig, \hpf.kr(50));
	sig = SelectX.ar(\mix.kr(0.5), [in, sig]);
	sig = sig * EnvGen.ar(\adsr.kr( Env.adsr(0.01,0.1,0.8,0.1) ),gate,doneAction:2);
	Out.ar(out, sig);
}).add;
//Pdef(\demo).reset;
);

Pdef(\demo).clear

(
Pdef(\demo, Pdef(\demotreb, 
	Ppar([
		Pbind(
			\instrument, \fmbell,
			\note, Pseq([
				2,9,5,-4,
			],inf),
			\octave, 4,
			\sustain, 0.1,
			\dur, 1,
			\out, BusDef(\fx1, \audio),
			\amp, 0.1,
		),
		Pmono(\chorus,
			\inbus, BusDef(\fx1, \audio),
			\freq, 200,
			\dur, 1,
			\amp, 0.1,
		),
	])
)).play;
)

////////////////////////////////////


// not working :(
(
SynthDef(\stutter, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, delay=0.1, mix=0, maxdelay=2;
	var sig;
	var in = InFeedback.ar(\inbus.kr(BusDef(\zero, \audio)), 2); 
	var runtrig = Trig.kr(mix, delay);
	var bufnum = LocalBuf(SampleRate.ir*maxdelay,2);
	sig = SelectX.ar( mix, [DC.ar(0), in] );
	sig = CombC.ar(sig, maxdelay, delay, 0);
	sig = RecordBuf.ar(sig, bufnum, offset:0, recLevel:1, preLevel:0, run:mix, loop:1, trigger: mix);
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * 1, Impulse.kr(1/delay), startPos: (0*BufFrames.kr(bufnum)), doneAction:0, loop: 1);
	sig = SelectX.ar( ToggleFF.kr(runtrig), [in, sig] );
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,0.1),gate,doneAction:2);
	Out.ar(out, sig);
}).add;



Pdef(\demo, Pdef(\plop, 
	Ppar([
		Pbind(
			\instrument, \default,
			\freq, Pwhite(100.0,1000),
			\dur, 1/8,
			\amp, 0.1,
			\out, BusDef(\fx1, \audio),
		),
		Pmono(\stutter,
			\inbus, BusDef(\fx1, \audio),
			\mix, Pseq([
					0,0,0,0, 1,1,1,0,
			],inf),
			\delay, 1/~t,
			\freq, 200,
			\dur, 1/8,
			\amp, 0.1,
		),
	])
)).play;
)

/////////////////////////////////////////

~buf = Buffer.alloc(s, s.sampleRate * 5);

(
Ndef(\demo,{
    var trig, freq;
    var dry, snd, phase, iois;
    var cumulDelay;
    var decayFactor, lpfCutoff, numEchoes, ioiScale, ioiDecayFactor;

    // play with these!
    decayFactor = 0.75;
    lpfCutoff = 500;
    numEchoes = 16;
    ioiScale = 0.8;
    ioiDecayFactor = 0.75;

    // example input -- you can substitute other stuff here
    trig = Dust.ar(1);
    dry = Pulse.ar(100 * TIRand.ar(1, 12, trig));
    dry = dry * Decay2.ar(trig, 0.01, 0.2);

    phase = DelTapWr.ar(~buf, dry);
    iois = Array.geom(numEchoes, ioiScale, ioiDecayFactor);
    cumulDelay = iois.sum;
    (cumulDelay > ~buf.duration).if {
        Error("use a larger buffer").throw;
    };
    snd = Silent.ar;
    iois.reverse.do { |ioi|
        snd = (snd + DelTapRd.ar(~buf, phase, cumulDelay, interp: 4)) * decayFactor;
        // one-pole lowpass -- LPF was too aggressive
        snd = OnePole.ar(snd, lpfCutoff / SampleRate.ir);
        cumulDelay = cumulDelay - ioi;
    };
    snd = snd + dry;
    
    snd * 0.1!2;
}).play;

// contributors so far: Nathan Ho
)



(
	// with series instead of geom
Ndef(\demo, {
    var trig, freq;
    var dry, snd, phase, iois;
    var cumulDelay;
    var decayFactor, lpfCutoff, numEchoes, ioiScale, ioiDecayFactor;

    // play with these!
    decayFactor = 0.75;
    lpfCutoff = 5000;
    numEchoes = 16;
    ioiScale = 1;
    ioiDecayFactor = 0.75;

    // example input -- you can substitute other stuff here
    trig = Impulse.ar(4);
    dry = Pulse.ar(100 * TIRand.ar(1, 12, trig));
    dry = dry * Decay2.ar(trig, 0.01, 0.2);

    phase = DelTapWr.ar(~buf, dry);
    iois = Array.series(numEchoes, ioiScale, ioiDecayFactor).reciprocal.debug("a");
    cumulDelay = iois.sum;
    (cumulDelay > ~buf.duration).if {
        Error("use a larger buffer").throw;
    };
    snd = Silent.ar;
    iois.reverse.do { |ioi|
        snd = (snd + DelTapRd.ar(~buf, phase, cumulDelay, interp: 4)) * decayFactor;
        // one-pole lowpass -- LPF was too aggressive
        snd = OnePole.ar(snd, lpfCutoff / SampleRate.ir);
        cumulDelay = cumulDelay - ioi;
    };
    snd = snd + dry;
    
    snd * 0.1!2;
}).play;

// contributors so far: Nathan Ho
)


/////////////////////

// Source audio: simple sweep
{ Pulse.ar(XLine.kr(100, 1000, 5)) * 0.1!2 }.play;

// All you need is a varying delay.
// In this example, an 0.2s delay is switched on every other 0.2s. So every 0.2s of audio is repeated once.
(
{
    var snd = Pulse.ar(XLine.kr(100, 1000, 5));
    snd = DelayC.ar(snd, 0.2, LFPulse.ar((0.2 * 2).reciprocal) * 0.2);
    snd * 0.1!2;
}.play;
)

// More general version using Stepper instead of LFPulse. You can control the length of the repeat and the number of repeats.
(
{ |fragmentlength = 0.2, numrepeats = 3|
    var trig, reset, del, snd;
    snd = Pulse.ar(XLine.kr(100, 1000, 5));
    trig = Impulse.ar(fragmentlength.reciprocal);
    reset = Impulse.ar(0); // if we don't do this the stepper will start at 1...
    del = Stepper.ar(trig, reset, 0, numrepeats - 1) * fragmentlength;
    snd = DelayC.ar(snd, 10, del);
    snd * 0.1!2;
}.play(args: [\fragmentlength, 0.1, \numrepeats, 24]);
)

// With some enhancements, we can allow the reset counter to be out of sync.
(
{ |holdlength = 0.5, fragmentlength = 0.2|
    var reset, phase, fragment, del, snd;
    snd = Pulse.ar(XLine.kr(100, 1000, 5));

    reset = Impulse.ar(holdlength.reciprocal);
    phase = Sweep.ar(reset);
    // this is the easiest way to make an Impulse resettable? seriously?
    fragment = { |ph| (ph - Delay1.ar(ph)) < 0 + Impulse.ar(0) }.value(phase / fragmentlength % 1);
    del = Latch.ar(phase, fragment);
    snd = DelayC.ar(snd, 10, del);
    snd * 0.1!2;
}.play;
)

// Many stutter plugins let you play back the audio at a different rate.
// This is a little trickier. Speeding up 2x not as easy as adding a Sweep.ar(fragment) because otherwise you get negative delays.
// So you have to add in an extra delay equal to fragmentlength.
(
{ |holdlength = 0.5, fragmentlength = 0.2, rate = 0.5|
    var reset, phase, fragment, del, snd;
    snd = Pulse.ar(XLine.kr(100, 1000, 5));
    reset = Impulse.ar(holdlength.reciprocal);
    phase = Sweep.ar(reset);
    fragment = { |ph| (ph - Delay1.ar(ph)) < 0 + Impulse.ar(0) }.value(phase / fragmentlength % 1);
    del = Latch.ar(phase, fragment) + ((fragmentlength - Sweep.ar(fragment)) * (rate - 1));
    snd = DelayC.ar(snd, 10, del);
    snd * 0.1!2;
}.play;
)

(
~stutter = { |snd, reset, fragmentlength, rate = 1.0, maxdelay = 10|
    var phase, fragment, del;
    phase = Sweep.ar(reset);
    fragment = { |ph| (ph - Delay1.ar(ph)) < 0 + Impulse.ar(0) }.value(phase / fragmentlength % 1);
    del = Latch.ar(phase, fragment) + ((fragmentlength - Sweep.ar(fragment)) * (rate - 1));
    DelayC.ar(snd, maxdelay, del);
};
)

/*
// put this into your extensions dir to install as a pseudo-ugen
Stutter {
    *ar { |in, reset, length, rate = 1.0, maxdelay = 10|
        var phase, fragment, del;
        phase = Sweep.ar(reset);
        fragment = { |ph| (ph - Delay1.ar(ph)) < 0 + Impulse.ar(0) }.value(phase / length % 1);
        del = Latch.ar(phase, fragment) + ((length - Sweep.ar(fragment)) * (rate - 1));
        ^DelayC.ar(in, maxdelay, del);
    }
}
*/




// Next examples use this buffer
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");


// audio-rate stutter inspired by DestroyFX
(
{
    var snd, holdperiod, multiplier;
    snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop: 1);
    holdperiod = MouseY.kr(0.01, 1.0, 1);
    multiplier = MouseX.kr(1, 20);
    snd = ~stutter.(snd, Impulse.ar(holdperiod.reciprocal), holdperiod / multiplier);
    snd * 0.3!2;
}.play;
)

// feedback loop inspired by Glitchmachines
(
{
    var in, loop, out;
    in = PlayBuf.ar(1, b, BufRateScale.kr(b), loop: 1);
	out = (in!2*0.6) + DelayC.ar(LocalIn.ar(2), 0.3, [0.11, 0.13], 0.95);
    loop = out;
    loop = ~stutter.(loop, Impulse.kr([3.4, 5.5]), [0.1, 0.03], [0.8, 1.3]);
    loop = LPF.ar(loop, 5000);
	LocalOut.ar(loop.reverse);
    out * 0.3;
}.play;
)
)

// sequencing with Pmono
(
SynthDef(\stuttertest, {
    |out = 0, buf, t_reset = 0, fragmentlength = 0.1, amp = 0.1|
    var snd;
    snd = PlayBuf.ar(1, buf, BufRateScale.kr(buf), loop: 1);
    snd = ~stutter.(snd, t_reset, fragmentlength);
    Out.ar(out, snd * amp!2);
}).add;
)
(
Pmono(\stuttertest,
    \buf, b,
    \amp, 0.3,
    \reset, 1,
    \dur, 0.1,
    \fragmentlength, Pseq([0.01, 0.03, 0.07, 0.05, 0.06], inf)
).play;
)

// grab audio on onsets
// live performers like this because they can control the effect easily
(
{
    var snd, reset;
    snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop: 1);
    reset = Onsets.kr(FFT(LocalBuf(512), snd), 0.5);
    snd = ~stutter.(snd, reset, 0.05);
    snd = DelayC.ar(snd, 0.2, 0.2);
    snd!2 * 0.3;
}.play;
)

// "scrambler" -- randomly samples from recent audio
// even simpler than stutter, a favorite effect of mine
(
{
    var snd;
    snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop: 1);
    snd = DelayC.ar(snd, 1.0, LFNoise0.ar(13).range(0.0, 1.0));
    snd!2 * 0.3;
}.play;
)

///////////// adapted


(
SynthDef(\stutter, { arg out = 0, time= 0.1, mix=0, rate=1;
	var stutter = { arg sig, reset, time, rate = 1.0, maxdelay = 10;
		var phase, fragment, del;
		phase = Sweep.ar(reset);
		fragment = { |ph| (ph - Delay1.ar(ph)) < 0 + Impulse.ar(0) }.value(phase / time % 1);
		del = Latch.ar(phase, fragment) + ((time - Sweep.ar(fragment)) * (rate - 1));
		DelayC.ar(sig, maxdelay, del);
	};
	var sig;
	var in = InFeedback.ar(\inbus.kr(BusDef(\zero, \audio)), 2); 
	var reset;
	reset = Changed.kr(mix);
	sig = in;
	sig = stutter.(sig, reset, time, rate, \maxdelay.ir(10));
	sig = SelectX.ar(mix, [in, sig]);
	sig = sig * \gain.kr(1);
	Out.ar(out, sig);
}).add;
)

(
Pmono(\stutter,
	\inbus, BusDef(\sendbus2, \audio),
	\mix, Pseq([
		0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
		0,0,0,0, 0,0,0,0, 1,1,1,1, 0,1,1,1,
		0,1,1,1, 1,1,1,1, 0,1,1,1, 0,1,1,1,
		0,0,0,0, 0,0,0,0, 0,1,1,1, 0,0,0,0,
	],1),
	\rate, 1,
	\time, 1/Pseq([
		8,1,1,1, 8,8,4,4, 8,1,1,1, 8,8,4,4,
		1,1,1,1, 1,1,1,1, 16,8,1,1, 16,16,32,32,

	],inf)/~t,
	\dur, 1/16,
	\amp, 0.1,
).play;
)

////////////////////////////////
// infinite reverb by Eli Feldsteel

(
SynthDef(\allreverb, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	var in = InFeedback.ar(\inbus.kr(BusDef(\zero, \audio)), 2); 
	sig = LocalIn.ar(2) * \fb.kr(0.1);
	sig = sig + in;
	15.do {
		sig = AllpassL.ar(sig, 0.06, Rand(0.001,0.06), 3);
	};
	LocalOut.ar(sig);
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.1,0.8,0.1),gate,doneAction:2);
	sig = SelectX.ar(\mix.kr(0.5), [in, sig]);
	Out.ar(out, sig);
}).add;
)

	(
	SynthDef(\allreverbf, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
		var sig;
		var in = InFeedback.ar(\inbus.kr(BusDef(\zero, \audio)), 2); 
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
		Out.ar(out, sig);
	}).add;

	SynthDef(\allreverbif, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
		var sig;
		var in = InFeedback.ar(\inbus.kr(BusDef(\zero, \audio)), 2); 
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
		Out.ar(out, sig);
	}).add;
	)


////////// nice stutter


(
Pdef(\part, Pdef(\zed, 
	Ppar([
		Pbind(
			\instrument, \default,
			\note, Pseq([
				0,0,0,-1,
			],inf),
			\octave, 3,
			\dur, 1/4,
			\amp, 0.1,
			\out, BusDef(\stut, \audio),
		),
		Pmono(\fx_stutter,
			\inbus, BusDef(\stut, \audio),
			\addAction, \addToTail,
			\lag, 0.0005,
			\mix, Pseq([
				0,1,1,1, 0,1,0,1,
			],inf),
			\rate, Pseg(Pseq([0.7,1,2],inf),1.8),
			\time, 1/16/~t,
			\time, Pstep(Pseq([1/4,1/8,1/16]/2,inf),1/4)/~t,
			\dur, Pser([1/8],inf),
			\amp, 0.1,
		),
	])
)).play;
)
