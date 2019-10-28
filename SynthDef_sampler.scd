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