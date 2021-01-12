(

///////////////////////////////////////  Sampler

~samplerStereoSynthDef = SynthDef(\samplerStereo,{ arg out = 0, buffer = 0, rate = 1, startPos = 0, loop = 0, attack = 0.001, release = 1, pan = 0, amp = 1, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, gate, doneAction: doneAction);
	sig = PlayBuf.ar(2, buffer, BufRateScale.kr(buffer) * rate, gate, BufFrames.kr(buffer)*startPos, loop, doneAction) * env;
	sig = Balance2.ar(sig[0], sig[1], pan, amp.curvelin(0, 1, 0, 1, log(10)));
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\samplerMono,{ arg out = 0, buffer = 0, rate = 1, startPos = 0, loop = 0, attack = 0.001, release = 1, pan = 0, amp = 1, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, gate, doneAction: doneAction);
	sig = PlayBuf.ar(1, buffer, BufRateScale.kr(buffer) * rate, gate, BufFrames.kr(buffer)*startPos, loop, doneAction) * env;
	sig = Pan2.ar(sig, pan, amp.curvelin(0, 1, 0, 1, log(10)));
	OffsetOut.ar(out, sig);
}).add;

SynthDef(\playerbeat, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, bufnum, speed=1, pos=0, doneAction=2, loop=0, trigger=1;
	// pos in seconds
	var sig;
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * speed, trigger, startPos: (pos*BufSampleRate.kr(bufnum)), doneAction:doneAction, loop: loop);
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.001,0,1,0.01)),gate,doneAction:doneAction);
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig * \gain.kr(1));
}).add;

SynthDef(\recorder, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, bufnum;
	var sig;
	sig = InFeedback.ar(\inbus.kr(0), 2);
	sig.poll;
	RecordBuf.ar(sig, bufnum, offset:0, recLevel:1, preLevel:\prelevel.kr(0), run:1, loop:0, trigger:1, doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;

SynthDef(\playersec_looper, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, bufnum, speed=1, pos=0, doneAction=2, loop=0;
	// pos in seconds
	var sig;
	var trigger = Impulse.kr(\trigfreq.kr(0));
	sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * speed, trigger, startPos: (pos*BufSampleRate.kr(bufnum)), doneAction:doneAction, loop: loop);
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.001,0,1,0.01)),gate,doneAction:doneAction);
	sig = Pan2.ar(sig, pan, 1).sum;
	Out.ar(out, sig * \gain.kr(1));
}).add;

SynthDef(\simplegran, { arg out=0, mix=0.5, gain=1, gate=1, mbufnum=0, pitch_stretch=1, pos=0, gdur=0.1, pan;
	var sig;
	var clk;
	var phase;
	clk = Impulse.ar(\gfreq.kr(40));
	//phase = Phasor.ar(1, 1,0,BufDur.kr(bufnum)) + pos;
	phase = pos;
	sig = TGrains.ar(2, clk, mbufnum, pitch_stretch, phase % BufDur.kr(mbufnum), gdur, pan, 1);
	sig = sig * EnvGen.ar(\asr.kr(Env.asr(0.01,1,0.01)),gate,doneAction:2);
	sig = sig * gain;
	Out.ar(out, sig);
}).add;

SynthDef(\doublegran, { arg out=0, mix=0.5, gain=1, gate=1, mbufnum=0, pitch_stretch=1, pos=0, gdur=0.1, pan;
	var sig;
	var clk;
	var phase;
	clk = Impulse.ar(\gfreq.kr(40));
	//phase = Phasor.ar(1, 1,0,BufDur.kr(bufnum)) + pos;
	phase = pos;
	sig = TGrains.ar(2, clk, mbufnum, pitch_stretch, phase + [0,\dephase.kr(0)] % BufDur.kr(mbufnum), gdur, pan, 1);
	sig = sig.mean * 0.6;
	sig.debug("sig");
	sig = sig * EnvGen.ar(\asr.kr(Env.asr(0.01,1,0.01)),gate,doneAction:2);
	sig = sig * gain;
	Out.ar(out, sig);
}).add;

SynthDef(\paulstretchMono, { |out = 0, amp = 1, pan = 0, atk = 0.001, rls = 0.12, curve = (-4), bufnum, envBufnum, stretch = 50, window = 0.25, gate = 1, doneAction = 2|
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
    // bufnum: the sound buffer. Must be Mono. (Use 2 instances with Buffer.readChannel for stereo)
    // envBufnum: The grain envelope buffer created as follows:
    //// envBuf = Buffer.alloc(s, s.sampleRate, 1);
    //// envSignal = Signal.newClear(s.sampleRate).waveFill({|x| (1 - x.pow(2)).pow(1.25)}, -1.0, 1.0);
    //// envBuf.loadCollection(envSignal);
    // pan: Equal power panning, useful for stereo use.
    // stretch: stretch factor (modulatable)
    // window: the suggested grain size, will be resized to closest fft window size
    // amp: amplification
    var trigPeriod, sig, envVca, env, delayTimeEnv, chain, trig, pos, fftSize;

	envVca = EnvGen.kr(Env.asr(atk, 1, rls, curve), gate, doneAction: doneAction);
    // Calculating fft buffer size according to suggested window size
    fftSize = 2**floor(log2(window*SampleRate.ir));
    // Grain parameters
    // The grain is the exact length of the FFT window
    trigPeriod = fftSize/SampleRate.ir;
    trig = Impulse.ar(1/trigPeriod);
    pos = Demand.ar(trig, 0, demandUGens: Dseries(0, trigPeriod/stretch));
    // Extraction of 2 consecutive grains
    // Both grains need to be treated together for superposition afterwards
    sig = [GrainBuf.ar(1, trig, trigPeriod, bufnum, 1, pos, envbufnum: envBufnum),
        GrainBuf.ar(1, trig, trigPeriod, bufnum, 1, pos + (trigPeriod/(2*stretch)), envbufnum: envBufnum)]*amp;
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
    // delayTimeEnv = (fftSize - BlockSize.ir) / SampleRate.ir; // fix by Sam Pluta
    // env = DelayN.ar(env, delayTimeEnv, delayTimeEnv); // fix by Sam Pluta
    sig = sig * env;
    // Delay second grain by half a grain length for superposition
    sig[1] = DelayC.ar(sig[1], trigPeriod/2, trigPeriod/2);
    // Panned output
	sig = Mix.new(sig) * envVca;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

/* \paulstretchMono example:

{
    var envBuf, envSignal, buffer;
    buffer = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
    // The grain envelope
    envBuf = Buffer.alloc(s, s.sampleRate, 1);
    envSignal = Signal.newClear(s.sampleRate).waveFill({|x| (1 - x.pow(2)).pow(1.25)}, -1.0, 1.0);
    envBuf.loadCollection(envSignal);
    s.sync();
    // Runs indefinitely
    Synth(\paulstretchMono, [\bufnum, buffer.bufnum, \envBufnum, envBuf.bufnum]);
}.fork;*/

///////////////////////////////////////  Input

SynthDef(\inputSig, { arg out = 0, in = 0, pan = 0, hpfreq = 20, band1freq = 80, band1rq = 1, band1db = 0, band2freq = 1200, band2rq = 1, band2db = 0, band3freq = 8000, band3rq = 1, band3db = 0, lpfreq = 20000, gate = 1, amp = 0.5, attack = 0.5, release = 1, doneAction = 2;
	var input, sig;
	input = SoundIn.ar(in);
	sig = BHiPass.ar(input, Lag2.kr(hpfreq.max(20).min(20000), 0.5)); // HPF
	sig = BPeakEQ.ar(sig, Lag2.kr(band1freq.max(20).min(20000), 0.5), band1rq, band1db); // Band 1
	sig = BPeakEQ.ar(sig, Lag2.kr(band2freq.max(20).min(20000), 0.5), band2rq, band2db); // Band 2
	sig = BPeakEQ.ar(sig, Lag2.kr(band3freq.max(20).min(20000), 0.5), band3rq, band3db); // Band 3
	sig = BLowPass.ar(sig, Lag2.kr(lpfreq.max(20).min(20000), 0.5)); // LPF
	sig = sig * EnvGen.kr(Env.asr(attack, releaseTime: release), gate, gate, doneAction: doneAction);
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

)