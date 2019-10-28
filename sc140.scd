{
	LocalOut.ar(
		a = CombN.ar(
			BPF.ar(
				LocalIn.ar(2) * 7.5 + Saw.ar(
					[32,33],
					0.2
				),
				2 ** LFNoise0.kr(4/3, 4) * 300,
				0.1
			).distort,
			2,
			2,
			40
		)
	);
	a;
}.play;

(
SynthDef(\nVirgo, { arg out = 0, amp = 1, att = 0.01, rel = 20,feedBack = 7.5, sawFreq1 = 32, sawFreq2 = 33, sawAmp = 0.2, bpff = 2, bpffModSpeed = 1.33, bpffModAmt = 4, delayTime = 2, decayTime = 40, gate = 1, doneAction = 2;
	var sig, env;
	env = Linen.kr(gate, att, 1, rel, doneAction);
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
)

(
Pbind(
	\instrument, \nVirgo,
	\amp, 0.2,
	\dur, 20
).play;
)

play{
	(
		{
			|k|({|i|
				y = SinOsc;
				y.ar(i*k*k, y.ar(i*k**i/[4,5]) * Decay.kr(Dust.kr(1/4**i), y.ar(0.1)+1*k+i, k*999))
			}!4).product
		}!8
	).sum
}

(
SynthDef(\talters, { arg out = 0, amp = 1, gate = 1, doneAction = 2;
	var sig, env;
	env = Linen.kr(gate, 0.01, 1, 10, doneAction);
	sig = ({
		|k|
		({
			|i|
			y = SinOsc;
			y.ar(i*k*k, y.ar(i*k**i/[{4.rand}, {5.rand}]) * Decay.kr(Dust.kr(1/4**i), y.ar(0.1)+1*k+i, k*999))
		}!4).product
	}!8).sum;
	OffsetOut.ar(out, sig * env * amp);
}).add;
)

(
Pbind(
	\instrument, \talters,
	\amp, 0.2,
	\dur, 20
).play;
)

play{
	f = LocalIn.ar(2).tanh;
	k = Latch.kr(f[0].abs, Impulse.kr({0.25.rand}));
	LocalOut.ar(CombC.ar(Blip.ar([4,6], 100 * k + 50, 0.9), 1, k * 0.3, 50 * f));
	f;
}//44.1kHz

(
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
)

(
Pbind(
	\instrument, \bozkurt,
	\amp, 0.2,
	\dur, 20,
	\feedBack, 1.5,
	\delTime, Pseq([0.3, 0.2, 0.5, 0.01], inf),
	\impFreq, Pseq([0.125, 0.25, 0.125, 0.5], inf)
).play;
)

{
	LocalOut.ar(
		a = DynKlank.ar(
			`[LocalIn.ar.clip2(LFPulse.kr([1,2,1/8]).sum/2)**100*100],
			Impulse.ar(10)
		)
	);
	HPF.ar(a).clip2;
}.play;//

(
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
)

(
Pbind(
	\instrument, \mcld,
	\amp, 0.2,
	\dur, 5,
	\impFreq, Pseq([25, 50, 10], inf)
).play;
)


//Rohrhuber eclecticity

Ndef(\x, {
	SinOsc.ar(
		BrownNoise.ar(30!2, 200),
		Ndef(\x).ar * LFNoise1.kr(1!2,1,1)
	)
}).play;

( // new
SynthDef(\rohrhuber, { arg out = 0, amp = 1, lfnFreq1 = 2, lfnFreq2 = 62, att = 0.01, rel = 2, gate = 1, doneAction = 2;
	var sig, env;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	Ndef(\x, {
		SinOsc.ar(
			BrownNoise.ar(30 ! 2, 200),
			Ndef(\x).ar * LFNoise1.kr([17, 4], 1, 1)
		)
	});
	sig = Ndef(\x) * LFNoise0.kr([lfnFreq1, lfnFreq2]) * env * amp;
	OffsetOut.ar(out, sig);
}).add;
)

(
Pbind(
	\instrument, \rohrhuber,
	\amp, 0.2,
	\dur, 5
).play;
)

// Padovan
play{
	x = 165;
	b = SinOsc;
	p = Trig.ar(
		Saw.ar(x),
		1
	);
	y = b.ar(p * x);
	z = b.ar(p);
	(GVerb.ar(
		GrainIn.ar(2, y, y / 2, z, p * z, -1),
		9
	)) / 9;
};

(
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
)

p = Synth(\padovan);
p.set(\gate, 0);

(
Pbind(
	\instrument, \padovan,
	\amp, 0.2,
	\dur, 10
).play;
)

//Batuhan
(
play{
	LeakDC.ar(
		BRF.ar(
			Saw.ar(
				8,
				Decay2.kr(
					x = Duty.kr(1/8, 0, Drand([0, Drand((0.4,0.5..1))], inf)),
					0.01,
					0.3
				)
			) ** 1.5,
			x * 20 + [45.1, 45],
			0.1
		)
	).tanh;
}
)

(
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
)

p = Synth(\batuhan);
p.set(\gate, 0);

(
Pbind(
	\instrument, \batuhan,
	\dur, 10
).play;
)

// lirgo new
Ndef('x', {
	x = Ndef('x').ar + 0.01;
	a = BPF.ar(x, 6 ** Latch.ar(x, Dust.ar(x)) * 150, 0.2).sin;
	9.do{
		a = AllpassN.ar(a, 0.2, {0.2.rand}!2, 9)
	};
	a + a.mean;
}).play;

(
SynthDef(\lirgo, { arg out = 0, amp = 1, att = 0.01, rel = 5, gate = 1, doneAction = 2;
	var sig, env, bpf;

	env = Linen.kr(gate, att, 1, rel, doneAction);
	sig = Ndef('x', {
		sig = Ndef('x').ar + 0.01;
		bpf = BPF.ar(sig, 6 ** Latch.ar(sig, Dust.ar(sig)) * 150, 0.2).sin;
		4.do{
			bpf = AllpassN.ar(bpf, 0.2, {0.2.rand}!2, 9)
		};
		bpf + bpf.mean;
	});
	OffsetOut.ar(out, sig * env * amp * 0.1);
}).add;
)

p = Synth(\lirgo);
p.set(\gate, 0);

(
Pbind(
	\instrument, \lirgo,
	\dur, 10,
	\amp, 2
).play;
)


// nozkurt
play{
	AllpassC.ar(
		SinOsc.ar(55).tanh,
		0.4,
		TExpRand.ar(2e-4, 0.4,Impulse.ar(8)).round([2e-3,4e-3]),
		2
	)
};

(
SynthDef(\nozkurt, { arg out = 0, amp = 1, att = 0.01, rel = 5, sinFreq = 55, impMin = 0.0002, impMax = 0.7, impFreq = 8, gate = 1, doneAction = 2;
	var sig, env, delayTime;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	sig = SinOsc.ar(sinFreq).tanh;
	delayTime = TExpRand.ar(impMin, impMax, Impulse.ar(impFreq)).round([2e-3, 4e-3]);
	sig = AllpassC.ar(sig, 1, delayTime, 2);
	OffsetOut.ar(out, sig * env * amp);
}).add;
)

p = Synth(\nozkurt);
p.set(\gate, 0);

(
Pbind(
	\instrument, \nozkurt,
	\dur, 10,
	\impFreq, 4
).play;
)

// tirgo
(
play{
	p = PinkNoise.ar(1!2);
	BRF.ar(
		p + Blip.ar(p + 2, 400),
		150,
		2,
		0.1
	) + LPF.ar(FreeVerb2.ar(*LPF.ar(p + 0.2*Dust.ar(0.1), 60) ++ [1, 1, 0.2, 1e4]).tanh, 2000);
};
)

(
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
)

p = Synth(\tirgo);
p.set(\gate, 0);

(
Pbind(
	\instrument, \tirgo,
	\dur, 10,
	\impFreq, 4
).play;
)

// LMCD
(
play{
	a = Duty.kr(0.1, 0, Dseq(fib(32).wrap(20, 55).midicps, inf));
	HPF.ar(LeakDC.ar(Splay.ar(LFCub.ar([-1, a, a / 3, -2]))) * 9).clip2 / 9;
};
)

(
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
)

p = Synth(\lmcd);
p.set(\gate, 0);

(
Pbind(
	\instrument, \lmcd,
	\dur, 40,
	\trigDur, 0.1,
	\lfCubTu, 0.05
).play;
)

// LDMC
{a=[0.02,0.1,1,2,3,4]; k=LFPar.kr(a+0.5).sum; f=Latch.kr(k,Impulse.kr(a)); Splay.ar(SinOsc.ar(f*100+300)/5)}.play;

// nalle
{13.do{|i|k="SuperCollider"[i].ascii;20.do{|u|{MoogFF.ar(Saw.ar((k/4).midicps)*EnvGen.ar(Env.perc),u+k*9,k/30)}.play;(k*0.001).wait}}}.fork;

play{VarSaw.ar((Hasher.ar(Latch.ar(SinOsc.ar((1..4)!2),Impulse.ar([5/2,5])))*300+300).round(60),0,LFNoise2.ar(2,1/3,1/2))/5}