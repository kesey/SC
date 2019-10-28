s.boot;

(
// init
~globalQuant = 4;
~pdefNumber = 8; // number of pdef or units

~sequencer = Dictionary.new;
t = TempoClock.default;

// Function
// return an Array of Penvir use it in Ppar to play all the units
~listUnits = { arg sequencer;
	var listUnits;
	listUnits = sequencer.size.collect({ arg i;
		sequencer.at(("unit" ++ (i + 1)).asSymbol);
	});
	listUnits;
};

// Synthdef
SynthDef(\kick808,{arg out = 0, amp = 0.5,  pan = 0, tu = 1, t_trig = 1, envL1 = 0, envL2 = 1, envL3 = 0, envT1 = 0, envT2 = 1, enfL1 = 1000, enfL2 = 20, enfL3 = 20, enfT1 = 0.001, enfT2 = 0.001, enfT3 = 0.001;
	var env = EnvGen.ar(Env([envL1,envL2,envL3],[envT1,envT2],-8), t_trig, doneAction:2);
	var enf  = EnvGen.ar(Env([enfL1,enfL2,enfL3],[enfT1,enfT2,enfT3],-4));
	var sig = SinOsc.ar(tu*(enf+40))*env;
	sig = sig + LPF.ar(SinOsc.ar(SinOsc.ar(100,0,50,100*tu),0,0.2)*env,1000);
	OffsetOut.ar(out, Pan2.ar(sig * env, pan, amp));
}).add;

SynthDef(\hatnew, {|out=0, amp=1, pan=0, freq=230, hpf=8500, rel=0.15, fxb=0, fxv=0, bbcb=0, bbcv=0, doneAction = 2|
  var pulse, sig, env, freqs;
  freqs = [freq, freq*1.4471, freq*1.617, freq*1.9265, freq*2.5028, freq*2.6637];
  pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6, mul: 1));
  sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
  env = EnvGen.kr(Env.perc(0,rel), doneAction: doneAction);
  sig =  Pan2.ar(sig*env, pan, amp);
  OffsetOut.ar(out,sig);
}).add;

SynthDef(\kickmed, { | out = 0, level = 1, pan = 0, noise = 1, done = 2, dc = 1, snd = 18, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, relEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1, env1T2, env1T3, env1T4, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase, oamp = 0.1, owhich2 = 0, ochoose = 0|
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
}).add;

SynthDef(\dStowell, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 2, freq = 6/3, width = 1/5, lpf = 20000, doneAction = 2;
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

SynthDef(\kikAw, { |out = 0, amp = 1, basefreq = 50, ratio = 7, sweeptime = 0.05, envL1 = 1, envL2 = 0.8, envL3 = 0, envT1 = 0.3, envT2 = 0.15|
    var fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
	env = EnvGen.kr(Env([envL1, envL2, envL3], [envT1, envT2], -4), doneAction: 2),
	sig = SinOsc.ar(fcurve, 0.5pi, env).distort * amp;
    OffsetOut.ar(out, sig ! 2)
}).add;

SynthDef(\sd, { | out = 0, amp = 1, att = 0, rel = 0.05, freq = 200, ffreq = 12000 |
	var osc1, osc2, env;
	osc1 = WhiteNoise.ar;
	osc2 = FSinOsc.ar(freq);
	env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
	OffsetOut.ar(out, Pan2.ar(LPF.ar(Mix([osc1, osc2]), ffreq), 0, env*amp));
}).add;

SynthDef(\hat808, { arg out = 0, amp = 0.1, pan = 0, tu = 1, t_gate = 1, attack = 0.01, release = 0.1;
	var sig;
	var env = EnvGen.ar(Env.perc(attack, release),doneAction:2);
	sig = Saw.ar((1..9)*1000.23*env*tu);
	sig = RHPF.ar(sig, \hpf.kr(5700), \rq.kr(0.5));
	sig = sig * (1+EnvGen.ar(Env.perc((-0.1),\rel.kr(0.1),-4),t_gate))*tu;
	sig = Ringz.ar(sig,(10..15)*1000.234,1).mean;
	sig = RHPF.ar(sig, \lpf.kr(2000)*env*tu, \rq.kr(0.5));
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\ping_mh,{arg out=0, amp=0.2, pan=0, freq=440, dur=0.1, attack=0.001;
    var sig, freq2;
    freq=freq*rrand(1,1.01);
    freq2=freq*rrand(1,1.01);
	e=EnvGen.ar(Env.perc(attack,dur.max(0.01),curve:-4),doneAction:2);
    sig=SinOsc.ar([freq,freq2],0,amp*e);
    sig=Pan2.ar(sig,pan);
    OffsetOut.ar(out,sig)
}).add;

SynthDef(\tabass, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 2, freq = 1, doneAction = 2;
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

SynthDef(\noise2new,{arg out = 0, amp = 1, att = 0.01, rel = 1, div = 0.2, pan = 0, del1 = 10, del2 = 20;
	var env, sig;
	env =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [att, rel], [-4, -2, -4]), doneAction:2);
	sig = CuspN.ar(
        SampleRate.ir/div,
        LFNoise2.kr([4,4],1.5,1.5),
        LFNoise2.kr([0.2,0.2],1.5,1.5),
        LFNoise2.kr([2,2],0.5,1.5),
        LFNoise2.kr([2,2],0.5,1.5);
    );
    sig = HPF.ar(sig,1000);
    sig = Limiter.ar(sig,0.4);
    sig = [DelayL.ar(sig,0.1,del1/44100) ,DelayL.ar(sig,0.1,del2/44100)];
    //sig = PitchShift.ar(sig,0.2,1*a);
    sig = Compander.ar(sig,In.ar(0,1),0.01,1,0.01,0.01,0.1);
    sig = sig.tanh;
	sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig * env);
}).add;

SynthDef(\sinBass, { arg out = 0, gate = 1, amp = 1, pan = 0, curve = 0, loopNode = nil, attack = 0.2, release = 4, envLevel1 = 0, envLevel2 = 40, envLevel3 = 32, envLevel4 = 50, envLevel5 = 0, envLevel6 = 60, envTime1 = 0.5, envTime2 = 0.3, envTime3 = 0.25, envTime4 = 1, envTime5 = 0.5, doneAction = 2;
	var freqEnv, env, sig;
	freqEnv = EnvGen.kr(Env([envLevel1, envLevel2, envLevel3, envLevel4, envLevel5, envLevel6], [envTime1, envTime2, envTime3, envTime4, envTime5], curve), gate);
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	sig = HPF.ar(SinOsc.ar(freqEnv, mul: env), 20);
	OffsetOut.ar(out, Pan2.ar(sig, pan, Lag.kr(amp, 0.5)));
}).add;

//Pattern
~song2Pattern1 = Pbind(
	\instrument, \kick808,
	\dur, Pseq(
		[
			Rest(0.75), 0.5, Rest(0.25), 0.75, 1, 0.25, Rest(0.5), // 0.75+ 0.5+ 0.25+ 0.75+ 1+ 0.25+ 0.5 == 4
			Rest(0.25), 0.5, 0.75, 0.75, 0.5, 0.75, 0.5 // 0.25+ 0.5+ 0.75+ 0.75+ 0.5+ 0.75+ 0.5 == 4
		],
		inf
	),
	\envL1, 0,
    \envL2, 0.94,
	\envL3, 0,
	\envT1, 0.01,
	\envT2, 0.31,
	\enfL1, 400,
	\enfL2, 742,
	\enfL3, 82,
	\enfT1, 0.001,
	\enfT2, 0.001,
	\enfT3, 0.001,
	\tu, 0.68,
	\amp, 1.48
);

~song2Pattern2 = Pbind(
	\instrument, \hatnew,
	\dur, Pseq([0.25, Pn(0.125, 3), 0.25, 0.25, 0.125, 0.25, 0.125, 0.25, 0.125], inf),
	                      // 0.25 +  (0.125 *3)+ 0.25 +0.25 +0.125 +0.25 +0.125 +0.25 +0.125 == 2
	\pan, Pwhite(-0.75, 0.75, inf),
	\freq, 0.44,
	\hpf, 8500,
	\rel, 0.15,
	\amp, 2.6
);

~song2Pattern3 = Pbind(
	\instrument, \kickmed,
	\dur, Pseq([Rest(1), 3], inf),
	\env0L2, 0.63,
	\env0L3, 0.15,
	\fratio, 1.11,
	\env1L1, 0,
	\env1L2, 37,
	\env1L3, 24,
	\env1T1, 0.3,
	\level, 0.8
);

~song2Pattern4 = Pbind(
	\instrument, \dStowell,
	\dur, 2,
	\attack, 0,
	\release, 3,
	\lpf, 370,
	\amp, 2
);

~song2Pattern5 = Pbind(
	\instrument, \kikAw,
	\dur, Pseq([0.125, Rest(0.25), 1, 1.125, 0.5, Rest(1)], inf), // 0.125 +0.25+ 1 + 1.125+ 0.5+ 1 == 4
	\basefreq, 51,
	\ratio, 0.65,
	\sweeptime, 0.81,
	\envL1, 1.11,
	\envL2, 4.31,
	\envL3, 0,
	\envT1, 0.02,
	\envT2, 0.4,
	\amp, 0.4
);

~song2Pattern6 = Pbind(
	\instrument, \sd,
	\dur, Pseq([2, 4, 2], inf),
	\amp, 0.12,
	\att, 0.02,
	\rel, 0.05,
	\freq, 266,
	\ffreq, 16004
);

~song2Pattern7 = Pbind(
	\instrument, \hat808,
	\dur, Pseq([0.125, 0.25, 0.125, 0.125, 0.25, 1, 0.125], inf),
	         // 0.125 +0.25 +0.125 +0.125 +0.25 +1 +0.125 == 2
	\amp, 0.018,
	\tu, 0.63,
	\attack, 0,
	\release, Pseq([0.01, 0.03, 0.02, 0.01, 0.02, 0.05, 0.03], inf),
	\hpf, 14776,
	\rq, 0,
	\rel, 0.92,
	\lpf, 2834,
	\pan, Pwhite(-1, 1, inf)
);

~song2Pattern8 = Pbind(
	\instrument, \ping_mh,
	\dur, 8,
	\amp, 0.04,
	\freq, 417,
	\attack, 1.79,
	\pan, Pwhite(-0.5, 0.5, inf)
);

~song2Pattern9 = Pbind(
	\instrument, \tabass,
	\dur, 0.125,
	\freq, Pseq([0.0625, 0.125, 0.0625, 0.5, 1, 0.9], inf),
	\attack, 0,
	\release, Pseq([0.42, 0.2, 0.9, 0.2], inf),
	\amp, 0.12
);

~song2Pattern10 = Pbind(
	\instrument, \noise2new,
	\dur, Pseq([2, 1, 1], inf),
	\att, 0.01,
	\rel, 1,
	\del1, 23.48,
	\del2, 0,
	\div, 0.02,
	\amp, 0.08
);

~song2Pattern11 = Pbind(
	\instrument, \sinBass,
	\amp, 0.6,
	\dur, 2,
	\curve, 0,
	\loopNode, 0,
	\attack, 0,
	\release, 2,
	\envLevel1, 0,
	\envLevel2, 20.3,
	\envLevel3, 64,
	\envLevel4, 20.9,
	\envLevel5, 73.5,
	\envLevel6, 56,
	\envTime1, 0.01,
	\envTime2, 0.15,
	\envTime3, 0.75,
	\envTime4, 0.52,
	\envTime5, 0.5
);

// Sequencer

~pdefNumber.do({ // sequencer creation with pdefNumber of units
	arg i;
	var name;
	name = ("unit" ++ (i + 1)).asSymbol;
	~sequencer.put(name,
		Penvir(
			(pdefName: name, pdefPrevInstr: nil, pdefCcStart: 21, pdefMidiChan: i),
			Pdef(name).quant_(~globalQuant);
		)
	);
});

p = Ppar(~listUnits.value(~sequencer), inf); // all units in parallel

// Song
~song2 = {
	t.tempo = 82 / 60;
	~globalQuant = 4;
	loop {
		Pdef(\unit1, ~song2Pattern1).quant_(~globalQuant);
		Pdef(\unit2, ~song2Pattern2).quant_(~globalQuant);
		Pdef(\unit3, ~song2Pattern3).quant_(~globalQuant);
		Pdef(\unit4, ~song2Pattern4).quant_(~globalQuant);
		Pdef(\unit5, ~song2Pattern5).quant_(~globalQuant);
		Pdef(\unit6, ~song2Pattern6).quant_(~globalQuant);
		Pdef(\unit7, ~song2Pattern7).quant_(~globalQuant);
		Pdef(\unit8, ~song2Pattern8).quant_(~globalQuant);
		16.0.wait;
		Pdef(\unit1, ~song2Pattern10).quant_(~globalQuant);
		Pdef(\unit2, ~song2Pattern9).quant_(~globalQuant);
		4.0.wait;
		Pdef(\unit1, ~song2Pattern1).quant_(~globalQuant);
		Pdef(\unit2, ~song2Pattern2).quant_(~globalQuant);
		8.0.wait;
		Pdef(\unit1, ~song2Pattern10).quant_(~globalQuant);
		Pdef(\unit2, ~song2Pattern9).quant_(~globalQuant);
		4.0.wait;
		Pdef(\unit1, ~song2Pattern1).quant_(~globalQuant);
		Pdef(\unit2, ~song2Pattern2).quant_(~globalQuant);
		8.0.wait;
		Pdef(\unit1, ~song2Pattern10).quant_(~globalQuant);
		Pdef(\unit2, ~song2Pattern9).quant_(~globalQuant);
		Pbindef(\unit6,
			\amp, 0.065,
			\att, 0.26,
			\rel, 0.01,
			\ffreq, 7948
		).quant_(~globalQuant);
		Pbindef(\unit2,
			\release, Pseq([0.6, 0.3, 0.42, 0.16, 0.5, 0.42, 0.16, 0.7], inf),
			\freq, 0.01,
			\dur, Pseq([0.125, 0.125, 0.5, 0.25], inf) // 0.125+ 0.125+ 0.5+ 0.25 == 1
		).quant_(~globalQuant);
		8.0.wait;
		Pdef(\unit1, ~song2Pattern1).quant_(~globalQuant);
		Pdef(\unit2, ~song2Pattern2).quant_(~globalQuant);
		Pdef(\unit6, ~song2Pattern6).quant_(~globalQuant);
		28.0.wait;
		Pdef(\unit1, ~song2Pattern10).quant_(~globalQuant);
		Pdef(\unit2, ~song2Pattern9).quant_(~globalQuant);
		4.0.wait;
		Pdef(\unit1, ~song2Pattern1).quant_(~globalQuant);
		Pdef(\unit2, ~song2Pattern2).quant_(~globalQuant);
		Pdef(\unit4, ~song2Pattern11).quant_(~globalQuant);
		Pbindef(\unit6,
			\amp, 0.065,
			\att, 0.26,
			\rel, 0.01,
			\ffreq, 7948
		).quant_(~globalQuant);
		12.0.wait;
		Pdef(\unit1, ~song2Pattern10).quant_(~globalQuant);
		Pdef(\unit2, ~song2Pattern9).quant_(~globalQuant);
		Pbindef(\unit2,
			\release, Pseq([0.6, 0.3, 0.42, 0.16, 0.5, 0.42, 0.16, 0.7], inf),
			\freq, 0.01,
			\dur, Pseq([0.125, 0.125, 0.5, 0.25], inf) // 0.125+ 0.125+ 0.5+ 0.25 == 1
		).quant_(~globalQuant);
		4.0.wait;
	}
};

)

( // Play
Tdef(\song, ~song2).play(t, true, ~globalQuant);
if (~sequencerTransport.isPlaying.not, { ~sequencerTransport = p.play(t, quant: ~globalQuant); });
)

( // Stop
Tdef(\song).stop;
~sequencerTransport.stop;
)

( // Reset
Tdef(\song).reset;
~sequencerTransport.reset;
)