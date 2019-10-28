play{
	t = [0,3,5,7,10,12]+30;
	a = Demand.kr(
		Impulse.kr(8),
		0,
		Drand(t+24++t,inf)
	);
	(
		BHiPass.ar(
			LFNoise1.ar(8)**3,
			[a,a+0.2].midicps,
			a/2e3,67-a
		)
	).tanh;
}

(
SynthDef(\mutantFric, { arg out = 0, amp = 1, spec1 = 0.00001, spec2 = 0.03, noiseFreq = 3, gate = 1, attack = 0.01, release = 1, doneAction = 2;
	var friction, sig;
	friction = Array.fill(5, {
		[spec1, spec2].asSpec.map(LFNoise2.kr(noiseFreq))
	});
	sig = Friction.ar(LFTri.ar(50), friction: friction, mass: friction*30000);
	sig = sig * EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	OffsetOut.ar(out, Splay.ar(sig * amp));
}).add;

SynthDef(\tweetSynth, { arg out = 0, amp = 1, freq = 25, t_trig = 1, attack = 0.01, release = 1;
	var sig, demand;
	demand = Demand.kr(
		t_trig,
		0,
		Drand(freq,inf)
	);
	sig = (
		BHiPass.ar(
			LFNoise1.ar(8) ** 3,
			[demand, demand + 0.2].midicps,
			demand / 2e3, 67 - demand
		)
	).tanh;
	sig = sig * EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: 2);
	OffsetOut.ar(out, sig * amp);
}).add;
)

Synth(\tweetSynth, [\t_trig, 1]);
Synth(\tweetSynth, [\t_trig, 0]);

Synth(\mutantFric, [\gate, 1]);
Synth(\mutantFric, [\gate, 0]);

Pbind(
	\instrument, \tweetSynth,
	\dur, 4,
	\amp, 1,
	\freq, 25
).play;

play{
	LeakDC.ar(
		BRF.ar(
			Saw.ar(
				8,
				Decay2.kr(
					x = Duty.kr(
						1/8,
						0,
						Drand([0, Drand((0.4, 0.5..1))],inf)
					),
					0.01,
					0.3
				)
			) ** 1.5,
			x * 20 + [45.1, 45],
			0.1
		)
	).tanh;
};//#sc

(

SynthDef(\tweetBassLeak, { arg out = 0, t_trig = 1, amp = 1, attack = 0.01, release = 1, doneAction = 2;
	var sig, demand, env;
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
	sig = Saw.ar(8, env) ** 1.5;
	sig = BRF.ar(sig, demand * 20 + [45.1, 45], 0.1);
	sig = sig * EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = LeakDC.ar(sig).tanh;
	OffsetOut.ar(out, sig * amp);
}).add;

)

Synth(\tweetBassLeak, [\t_trig, 1]);
Synth(\tweetBassLeak, [\t_trig, 0]);

Pbind(
	\instrument, \tweetBassLeak,
	\dur, 4,
	\amp, 1,
	\sustain, Pseq([4, 1, 2, 4], inf)
).play;

play{
	i = Impulse.ar(_);
	SinOsc.ar(
		i.(2).lagud(0,0.4)*360,
		Integrator.ar(
			Integrator.ar(
				i.(64).lag(LFNoise1.ar(2!2,2,2))*99,
				0.9

			),
			0.99
		).fold2(pi)
	)
};

(
SynthDef(\tweetKickInt, { arg out = 0, t_trig = 1, attack = 0.01, release = 2, amp = 1, doneAction = 2;
	var sig, freq, phase, env, i;
	i = Impulse.ar(_);
	freq = i.(2).lagud(0,0.4)*360;
	phase = Integrator.ar(
		Integrator.ar(
			i.(64).lag(LFNoise1.ar(2!2,2,2))*99,
			0.9
		),
		0.99
	).fold2(pi);
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = SinOsc.ar(freq, phase, env);
	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Pbind(
	\instrument, \tweetKickInt,
	\dur, 1,
	\amp, 1,
	\sustain, Pseq([4, 1, 2, 4], inf)
).play;
)

play{
	LocalOut.ar(
		k = LeakDC.ar(
			Integrator.ar(
				Pulse.ar(pi/[1,2.57],[0.54,0.46]),
				(1-LocalIn.ar(2)).fold(0,[0.9,0.85])
			).wrap2(pi).sin
		)
	);
	k.mean!2;
};

(
SynthDef(\tweetFogAttack, { arg out = 0, t_trig = 1, feedBack = 0.2, attack = 0.01, release = 2, amp = 1, doneAction;
	var sig, env, coef;
	sig = Pulse.ar(pi/[1,2.57],[0.54,0.46]);
	coef = (1-LocalIn.ar(2)).fold(0,[0.9,0.85]);
	sig = LeakDC.ar(Integrator.ar(sig, coef).wrap2(pi).sin);
	LocalOut.ar(sig);
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = (sig.mean!2) * env;
	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Pbind(
	\instrument, \tweetFogAttack,
	\dur, 1,
	\amp, 1,
	\sustain, Pseq([4, 1, 2, 4], inf)
).play;
)

{
	n = LFNoise0.ar(_);
	f=[60,61];
	tanh(
		BBandPass.ar(
			max(
				max(n.(4),l=n.(6)),
				SinOsc.ar(f*ceil(l*9).lag(0.1))*0.7
			),
			f,
			n.(1).abs/2
		)*700*l.lag(1)
	)
}.play;

(
SynthDef(\tweetAnaBass, { arg out = 0, t_trig = 1, freq = 60, attack = 0.01, release = 2, amp = 1, pan = 0, doneAction = 2;
	var sig, env, bw;
	bw = LFNoise0.ar(_);
	sig = max(
		max(bw.(4),l=bw.(6)),
		SinOsc.ar(freq * ceil(l*9).lag(0.1))*0.7
	);
	sig = tanh(
		BBandPass.ar(sig, freq, bw.(1).abs/2)*700*l.lag(1)
	);
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;
)

(
Pbind(
	\instrument, \tweetAnaBass,
	\dur, 1,
	\amp, 1,
	\sustain, Pseq([4, 1, 2, 4], inf),
	\freq, [60, 61]
).play;
)

(
play{LocalOut.ar(k = tanh(500*(PinkNoise.ar(1!2)**(8/(LagUD.ar(
							y=LocalIn.ar(2).range(0,0.9)+0.1,
							0,
							0.2
						)
					)
				)
			)
		)
	);
	Splay.ar(k,1-y);
};
)

// you have to test and copy
(
SynthDef(\tweetErosion, { arg out = 0, t_trig = 1, attack = 0.01, release = 2, feedBack = 1, amp = 1, doneAction = 2;
	var sig, env, input, div;
	input = LocalIn.ar(2).range(0,0.9)+0.1;
	div = LagUD.ar(input, 0, 0.2);
	sig = PinkNoise.ar(1!2);
	sig = tanh(500*(sig**(8/div)));
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	LocalOut.ar(sig * feedBack);
	sig = Splay.ar(sig,1-input);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Pbind(
	\instrument, \tweetErosion,
	\dur, 4,
	\amp, 2,
	\sustain, Pseq([4, 1, 2, 4], inf)
).play;
)



play{
	i = Impulse.ar(8).lag(0.3)!2;
	10.do {
		i = LeakDC.ar(
			AllpassC.ar(
				i,
				1,
				LFNoise0.ar(8).range(1e-5,0.2),
				-0.15,
				LFNoise0.ar(8).range(1,3)
			)
		).tanh;
	};
	i;
};

(
SynthDef(\harshTexture, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = Impulse.ar(8).lag(0.3)!2;
	10.do {
		sig = LeakDC.ar(
			AllpassC.ar(
				sig,
				1,
				LFNoise0.ar(8).range(1e-5,0.2),
				-0.15,
				LFNoise0.ar(8).range(1,3)
			)
		).tanh;
	};
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Pbind(
	\instrument, \harshTexture,
	\dur, 4,
	\amp, 2,
	\sustain, Pseq([4, 1, 2, 4], inf)
).play;
)

play{
	Blip.ar(
		[16e3,16150],
		2,
		LFTri.ar(
			Duty.ar(
				LFNoise0.ar(
					0.2,
					4,
					6

				),
				0,
				Dseq([70,30,0],inf))).clip(0,1)
	);
};//#supercollider_summer


(
SynthDef(\ultraHiSummer, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
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
)

(
Pbind(
	\instrument, \ultraHiSummer,
	\dur, 4,
	\amp, 2,
	\sustain, Pseq([4, 1, 2, 4], inf)
).play;
)


{SinOsc.ar(65.41,0,(SinOsc.kr(0.5, 0,0.5)))+SinOsc.ar(130.81,0,(SinOsc.kr(10,0,0.5)))+SinOsc.ar(523.25,0,(SinOsc.kr(0.05,0,0.05)))}.play;//b


play{a=LFNoise0;b=FBSineC.ar(a.kr(4,2e4,2e4),a.kr(10,16,17),1,1.005,0.7)!2;Latch.ar(b,Impulse.ar(a.kr(0.5,5e3,4e3)))*a.kr(5,0.4,0.5)}// #sc
play{RLPF.ar(Latch.ar(SinOsc.ar([100,100.5])!2,Impulse.ar(Duty.kr(Dseq([2,1]/4,inf),0,Drand((67,67.2..70),inf)))),800)} // #sc _dubsteppy_
play{CombN.ar(Splay.ar(Pulse.ar(Gendy3.kr([1,2,4,6])+LFNoise0.ar(4,6,Gendy3.kr(5,freq:[10,99])))*Gendy2.ar([0,1],maxfreq:[55,99])),3,0.4,2)}
play{x=LFDNoise3;Blip.ar(x.kr(1,[400,100],500),x.kr([1,2],6,5))*Gendy3.ar(1,1,1,1,x.kr(1,99,91),1,0.1)*x.ar(0.5,0.5,0.5)}// #sc
t=("come out to show them "!999).join;Speech.init(2);[98,99].do{|r,i|Speech.setSpeechVoice(i,3).setSpeechRate(i,r).channels[i].speak(t)};
t=("it's gonna rain "!999).join;Speech.init(2);[98,99].do{|r,i|Speech.setSpeechVoice(i,3).setSpeechRate(i,r).channels[i].speak(t)};// #sc sr
a=UGen.subclasses;fork{loop{u=a.choose;try{play{u.ar*EnvGen.ar(Env.perc(0.1,1),doneAction:2)!2}};1.wait}}//#sc #supercollider !!!NOT SAFE!!!
f=_.speak;fork{loop{f.("hi scott");2.wait;Speech.channels[0].voice_(20.rand)}} // #sc #supercollider // now with tag
f={|i,o,d|play{Saw.ar(XLine.kr(i,o,d,1,0,2))!2*EnvGen.kr(Env.sine(d))}};fork{loop{t=rrand(1e3,9e3);f.(t,t/4,rrand(0.1,1));9.rand.wait}}//#sc
play{a=[1,1.01,2,2.02,3.5,4.01,5.501];SinOsc.ar(Duty.kr(0.2,0,Dseq([10,11,0,12.2,0,0,10,0]+39,inf).midicps)*(a++(a*2))).sum!2/2}//DAF #sc
play{SinOsc.ar(Duty.kr(0.2,0,Dseq([0,5,0,15,0,12,0,0,12,0,12,0,12,10,0,12]+47,inf).midicps)*[1,1.01,2,2.02,3.5,4.01,5.501]).sum!2}// DAF #sc
b=Buffer.read(s,"*/*v".pathMatch@0);play{x=SinOsc;ring4(ar(TGrains,2,kr(Impulse,ar(x,[1,3],0,10,[9,20])),b,1,ar(x,1/9),0.01),ar(x,1e3))*9}
b=Buffer.read(s,"*/*v".pathMatch[0]);play{TGrains.ar(2,Impulse.kr([9,19]*LFNoise0.kr(2,1,1)),b,LFNoise0.kr(1,(1..4),2),0,1/10).sum*10}//#sc
play{var cpm=60;SinOsc.ar(700)!2*ToggleFF.ar(TDuty.ar(Dseq([1,1,1,1,1,2, 2,1,2,1,2,2, 1,1,1,1,1,3]/1e3*(6e3/cpm),inf)))} // S.O.S @ #sc
play{SinOsc.ar(Latch.ar(SinOsc.ar(1.75,0,1e2,2e2),Impulse.ar((1,1.1..2)*2)).lag(0.1)/2*(1,1.25..8)).sum**3!2}// #supercollider (last one)
play{ SinOsc.ar(Latch.ar(SinOsc.ar(1.75,0,1e2,2e2),Impulse.ar([1,1.0001])).lag(0.1)*(1,1.25..8)).sum**3!2 } // #supercollider
play{Splay.ar(SinOsc.ar(Latch.ar(SinOsc.ar(1.3,0,4e2,5e2),Impulse.ar([1,1.0001])*[1,2,3,4]).lag(0.05)))} // #supercollider (nicer)

play{SinOsc.ar(Latch.ar(SinOsc.ar(1.3,0,4e2,5e2),Impulse.ar([1,1.0001])).lag(0.05))} // #supercollider /* simple but hypnotizing */

play{
	x = LFNoise2.kr(22,5,9);
	CombC.ar(
		Splay.ar(
			Gendy3.ar(
				[4,2],
				[0.5,1],
				[1/9,1/4]*x,
				[1/2,1/8]*x,
				(9,49..199)
			)
		),
		5,
		[0.13,0.1],
		[x/2,x/2.1]
	)
}; // #sc

(
SynthDef(\ambiantPic, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = LFNoise2.kr(22,5,9);
	sig = CombC.ar(
		Splay.ar(
			Gendy3.ar(
				[4,2],
				[0.5,1],
				[1/9,1/4]*sig,
				[1/2,1/8]*sig,
				(9,49..199)
			)
		),
		5,
		[0.13,0.1],
		[sig/2,sig/2.1]
	);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Pbind(
	\instrument, \ambiantPic,
	\dur, 4,
	\amp, 2,
	\release, 10
).play;
)

{x=TRand.kr(30,XLine.kr(2e4,30,99,1,1,2),Impulse.kr((1..9))).cpsmidi.round.midicps;Splay.ar(SinOsc.ar(x))*AmpComp.kr(x,10)}.play // #sc
fork{loop{d=rrand(1,9);play{f=200.rand+60;Splay.ar(SinOsc.ar(XLine.kr(f,(f,f+1..f+f),d,1,0,2),0,0.1))};d.wait}}//cpu expense #supercollider
play{RLPF.ar(Demand.ar(Impulse.ar(20000),0,Dxrand([Dseq((1,0.005..0)),Dseq([1]++(0!555)),Dseq((0!999))],inf)),Line.kr(100,3000,80),0.1)!2}
play{SinOsc.ar(Latch.ar(LFSaw.ar(0.3,1,100,300).cpsmidi.round.midicps*[1,2],Impulse.ar(4)))} // tonal scales #supercollider
play{a=(1,0.97..0.005);GVerb.ar(Decay2.ar(TDuty.ar(Dseq(a++(a/2)++(a/4)++(a/8))),XLine.kr(0.05,0.001,15),0.1,0.05)*9,4,1)}//#supercollider

play{
	t = TDuty.kr(Dseq([1,1,4,2,2]/8,inf));
	Resonz.ar(
		Crackle.ar!2,
		Demand.kr(t,0,Dseq([250,8e3],inf)),
		Demand.kr(t,0,Dwhite(0.01,0.5,inf))
	)
};

(
SynthDef(\attBreath, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = TDuty.kr(Dseq([1,1,4,2,2]/8,inf));
	sig = Resonz.ar(
		Crackle.ar!2,
		Demand.kr(sig,0,Dseq([250,8e3],inf)),
		Demand.kr(sig,0,Dwhite(0.01,0.5,inf))
	);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Pbind(
	\instrument, \attBreath,
	\dur, 4,
	\amp, 2,
	\release, 10
).play;
)

play{
	t = TDuty.kr(Dseq([1,1,4,2,2]/8,inf));
	Resonz.ar(
		WhiteNoise.ar!2,
		Demand.kr(t,0,Dseq([250,8e3],inf)),
		Demand.kr(t,0,Dwhite(0.01,0.5,inf))
	)
}

(
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
)

(
Pbind(
	\instrument, \attWind,
	\dur, 4,
	\amp, 2,
	\release, 10
).play;
)

play{t=Impulse.ar((1,1.3..4)/2).sum;Decay2.ar(t,0.05,0.2,Splay.ar(SinOsc.ar(Demand.ar(t,0,Drand((120,180..800),inf)))*ToggleFF.ar(t)))}
play{t=Impulse.ar((1,1.3..4)/2).sum;Decay2.ar(t,0.001,0.2,Splay.ar(SinOsc.ar(Demand.ar(t,0,Drand((120,145..400),inf)))*ToggleFF.ar(t)+t))}
play{BPF.ar(SoundIn.ar(0),Array.geom(16,120,1.5),0.005,2).sum.dup} // kind of EZ resonator / vocoder for the mic #supercollider
play{FreeVerb.ar(CombC.ar(SoundIn.ar(0).softclip,1,1/120,1),0.4,1,1).dup}//easy hall/resonator fx for my lap steel guitar #supercollider
play{SinOsc.ar(Latch.ar(SinOsc.kr(0.75).range(0,12).round.midiratio*[200,400*SinOsc.kr(0.01).range(1,4)],TDuty.kr(Dseq([1,2]/8,inf))))} //ye
play{t=TDuty.kr(Drand(([1,2,3]/8),inf));SinOsc.ar(Demand.kr(t,0,Drand((50,53..71).midicps,inf))*[1,1.5]*LFPulse.kr(0.5).range(1,2)).dup}

{
	Splay.ar(
		SinOsc.ar(
			Array.fill(100,{\freq.asSpec.map(LFNoise2.kr(0.001))})
		)
	)
}.play;

(
SynthDef(\glauk, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = Splay.ar(
		SinOsc.ar(
			Array.fill(100,{\freq.asSpec.map(LFNoise2.kr(0.001))})
		)
	);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Pbind(
	\instrument, \glauk,
	\dur, 4,
	\amp, 2,
	\release, 10
).play;
)

{
	x = Array.fill(3,{Array.fill(50,{[40,150].asSpec.map(LFNoise2.kr(0.01))})});
	Splay.ar(SinOsc.ar(x[0]+SinOsc.ar(x[1],0,x[2]-39)));
}.play;

(
SynthDef(\lust, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env, ctrl;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	ctrl = Array.fill(3,{Array.fill(50,{[40,150].asSpec.map(LFNoise2.kr(0.01))})});
	sig = Splay.ar(SinOsc.ar(ctrl[0]+SinOsc.ar(ctrl[1],0,ctrl[2]-39)));
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Pbind(
	\instrument, \lust,
	\dur, 4,
	\amp, 2,
	\release, 10
).play;
)

{Out.ar([0,1],e=Trig.ar(Dust.ar(10));e=TRand.kr(100,10000,e);e=SinOsc.ar(e).round(SinOsc.ar(Line.kr(0,100,30))))}.play; // #supercollider :D

play{
	Splay.ar(
		Array.fill(15,{Ringz.ar(Dust.ar(Rand(1,10)), Rand(50,9000).round(100), 2)},
			1,
			0.5,
			0
		)
	)
} // #supercollider tweets = good idea!!!

(
SynthDef(\scinty, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
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
)

(
Pbind(
	\instrument, \scinty,
	\dur, 4,
	\amp, 0.2,
	\release, 10
).play;
)

{120.do{z=1e3;x={rrand(0.1,5)}!8;{{Klank.ar(`[x*z,x/60,2],LFNoise2.ar)*EnvGen.kr(Env.sine(2),doneAction:2)}!2}.play;1.wait;}}.fork

play{
	x = 165;
	b = SinOsc;
	p = Trig.ar(Saw.ar(x),1);
	y = b.ar(p * x);
	z = b.ar(p);
	(GVerb.ar(GrainIn.ar(2,y,y/2,z,p*z,-1),9))/9;
}//basso gettato #SuperCollider

(
SynthDef(\bublybub, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, x = 165, doneAction = 2;
	var sig, env, waveForm, freq, dur, input;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	waveForm = SinOsc;
	freq = Trig.ar(Saw.ar(x),1);
	dur = waveForm.ar(freq * x);
	input = waveForm.ar(freq);
	sig = GVerb.ar(GrainIn.ar(2,dur,dur/2,input,freq*input,-1),9);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Pbind(
	\instrument, \bublybub,
	\dur, 4,
	\amp, 0.2,
	\release, 10,
	\x, 165
).play;
)

{
	var r = SinOsc.ar(1/2,[0,1],3,1),
	s = Impulse.ar([r+0.2,r]);
	FreeVerb.ar(Decay.ar(s,r,MoogFF.ar(SinOsc.ar(([r.asin])*50),400)).softclip/2)
}.play;

(
SynthDef(\scratchi, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env, waveForm, trig;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	waveForm = SinOsc.ar(1/2,[0,1],3,1);
	trig = Impulse.ar([waveForm+0.2,waveForm]);
	sig = FreeVerb.ar(Decay.ar(trig,waveForm,MoogFF.ar(SinOsc.ar(([waveForm.asin])*50),400)).softclip/2);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Pbind(
	\instrument, \scratchi,
	\dur, 4,
	\amp, 1,
	\release, 10
).play;
)


/*eclecticity*/ Ndef(\x, { SinOsc.ar(BrownNoise.ar(30!2, 200), Ndef(\x).ar * LFNoise1.kr(1!2,1,1)) }).play;
{SinOsc.ar(XLine.kr(0.001,1,120).range(100,{exprand(300,10000)}!120)).mean}.play;//chdegaulle

{
	(SinOsc.ar(LFNoise1.kr(0.01).exprange(100,{exprand(300,10000)}!120)).mean)!2
}.play;//chdegaulleabout

(
SynthDef(\chdegaulleabout, { arg out = 0, amp = 1, pan =0, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = SinOsc.ar(LFNoise1.kr(0.01).exprange(100,{exprand(300,10000)}!120)).mean;
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;
)

(
Pbind(
	\instrument, \chdegaulleabout,
	\dur, 4,
	\amp, 1,
	\release, 10
).play;
)

var f={rrand(0.2, 2.0)}; {Splay.ar(SinOsc.ar(SinOsc.ar(0.02 * (f!8)).sum.round(f!8) * (f!8+1) * 100)) * 0.1}.play;//stairs #supercollider

var f={rrand(1, 2.1)}; {Splay.ar(SinOsc.ar(SinOsc.ar(0.02 * (f!8)).sum.round(f!8) * (f!8+1) + 1 * 100)) * 0.1}.play;//stairs #supercollider

(
SynthDef(\stairs, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env, freq;
	freq = {rrand(1, 2.1)};
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = Splay.ar(SinOsc.ar(SinOsc.ar(0.02 * (freq!8)).sum.round(freq!8) * (freq!8+1) + 1 * 100)) * 0.1;
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Pbind(
	\instrument, \stairs,
	\dur, 4,
	\amp, 1,
	\release, 10
).play;
)

{{PinkNoise.ar*LFSaw.ar(0-Duty.kr(1,0, Dseq((2**(0,1..5) ++ [3,3]).scramble,inf)),1).range(0,1).squared.squared}.dup}.play// #supercollider

{t=HPZ1.kr(LFNoise0.kr(4));{Pulse.ar((t*10000+0.0001).lag(0, 0.1))}.dup+(SinOsc.ar([220, 330])*Integrator.kr(t))*0.1}.play;// #supercollider

{
	{
		Klank.ar(
			`[{exprand(100,1000)}.dup(50)],
			Saw.ar(MouseX.kr(3, LFPulse.kr(6/3,0,1/5).range(3,3000),1),0.0005)
		)
	}.dup

}.play;// #supercollider

(
SynthDef(\tweetCheul, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env, freq;
	freq = {rrand(1, 2.1)};
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = Klank.ar(
			`[{exprand(100,1000)}.dup(50)],
			Saw.ar(MouseX.kr(3, LFPulse.kr(6/3,0,1/5).range(3,3000),1),0.0005)
	);
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;
)

(
Pbind(
	\instrument, \tweetCheul,
	\dur, 4,
	\amp, 1,
	\release, 10
).play;
)

Pbind(\type,\set,\id,{|freq|Saw.ar(freq+[0,1])/10}.play.nodeID,\midinote,Pseq("supercollider!!!".ascii,inf),\dur,1/4).play//#supercollider

{LocalOut.ar(a=DynKlank.ar(`[LocalIn.ar.clip2(LFPulse.kr([1,2,1/8]).sum/2)**100*100],Impulse.ar(10)));HPF.ar(a).clip2!2}.play//#supercollider

i=LFPulse;k=[100,1];{i.ar(i.kr(5).lag(0.1).linexp(0,1,50,Duty.kr(0.1,0,Dseq([k,Dxrand(11.fib,28)],inf).midicps)))/9}.play;// #supercollider

i=SinOsc;x={exprand(0.1,0.01)};{Splay.ar({[PinkNoise,BrownNoise,GrayNoise].choose.ar*i.ar(i.ar(0.01).range(x,x))}!9)}.play// #supercollider

(
SynthDef(\tweetWindy, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env, i, x;
	i = SinOsc;
	x = {exprand(0.1,0.01)};
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = Splay.ar({[PinkNoise,BrownNoise,GrayNoise].choose.ar*i.ar(i.ar(0.01).range(x,x))}!9);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Pbind(
	\instrument, \tweetWindy,
	\dur, 4,
	\amp, 1,
	\release, 10
).play;
)

{
	{
		Klank.ar(
			`[{exprand(100,1000)}.dup(50)],
			Saw.ar(
				LFPulse.kr(6/3,0,1/5).range(3,3000),
				0.0005
			)
		)
	}.dup

}.play;// #supercollider

(
SynthDef(\dStowell, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 2, freq = 6/3, width = 1/5, doneAction = 2;
	var sig, env, spec, input;
	spec = `[{exprand(100,1000)}.dup(50)];
	input = Saw.ar(
		LFPulse.kr(freq,0,width).range(3,3000),
		0.0005
	);
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = Klank.ar(spec, input);
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;
)

(
Pbind(
	\instrument, \dStowell,
	\dur, 4,
	\amp, 4,
	\release, 10
).play;
)


{
	a = PinkNoise.ar(1!2);
	20.do{
		a = BBandStop.ar(a, LFNoise1.kr(0.05.rand).exprange(40,15000), exprand(0.1,2));
	};
	LPF.ar(a,1e5);
}.play; // #supercollider

(
SynthDef(\2001, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 2, freq = 6/3, width = 1/5, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = PinkNoise.ar(1);
	20.do{
		sig = BBandStop.ar(sig, LFNoise1.kr(0.05.rand).exprange(40,15000), exprand(0.1,2));
	};
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;
)

(
Pbind(
	\instrument, \2001,
	\dur, 4,
	\amp, 4,
	\release, 10
).play;
)

{
	a = LFTri.ar(1);
	20.do{
		a = BAllPass.ar(a,80,1);
		a = ((a+0.02)*LFNoise0.kr(1/2)*8).tanh;
		a = LeakDC.ar(a,0.995);
	};
	a * 0.1!2;
}.play// #supercollider

(
SynthDef(\tabass, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = LFTri.ar(1);
	20.do{
		sig = BAllPass.ar(sig,80,1);
		sig = ((sig+0.02)*LFNoise0.kr(1/2)*6).tanh;
		sig = LeakDC.ar(sig,0.995);
	};
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;
)

(
Pbind(
	\instrument, \tabass,
	\dur, 0.125,
	\amp, 1,
	\release, 0.7
).play;
)

p={|f,a=1|LFPulse.ar(f)*a*[1,1.01]};{p.(p.(100-p.(1/16,20))+p.(2,1+p.(1/4))-0.5*200)+p.(100-p.(1/8,20),p.(8))*0.1}.play// #supercollider

f = 0;
Routine({
	inf.do{ |i|
		f = i / 12 + f % [4, 3];
		{
			Formant.ar(2**f*100,2**(i%8*f*0.2)*100,100)*Line.kr(0.1,0,1)
		}.play;
		0.25.wait;
	}
}).play;

{
	LocalOut.ar(
		a = CombN.ar(
			BPF.ar(
				LocalIn.ar(2) * 7.5 + Saw.ar([32,33],0.2),
				2**LFNoise0.kr(4/3,4)*300,
				0.1
			).distort,2,2,40
		)
	);
	a;
}.play; // #supercollider

(
SynthDef(\seqTwit, { arg out = 0, amp = 1, pan = 0, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env, input;
	input = LocalIn.ar(2) * 7.5 + Saw.ar([32,33],0.2);
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = CombN.ar(
		BPF.ar(
			input,
			2**LFNoise0.kr(4/3,4)*300,
			0.1
		).distort,
		2,
		2,
		40
	);
	LocalOut.ar(sig);
	sig = sig * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
}).add;
)

(
Pbind(
	\instrument, \seqTwit,
	\dur, 4,
	\amp, 1,
	\release, 10
).play;
)


x=LFPulse;d={|l,h,f,p,n|sum({Ringz.ar(x.ar(f,p,0.01),exprand(l,h).round(n),0.6)}!40)};{d.(30,150,2,[0,0.3],[1,x.kr(1/8)*10+40])*3e-4!2}.play;

n={|r,f,d=1|2**LFNoise0.kr(1!d,r)*f};{p=n.(4,1e3);CombN.ar(Ringz.ar(LFPulse.ar(1,0,0.01),n.(2,p,80),0.6).sum,8/5,8/5,60)*4e-4!2}.play;

n = { |r,f,n=0,d=1|
	round(r**LFNoise0.ar([4,1,8,2]!d)*f,n)
};
play{
	Splay.ar(
		d=n.(3,0.6);
		Ringz.ar(d*0.01,n.(2,n.(20,400),40,20),d).mean.tanh
	)
}

(
SynthDef(\seqClic, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env, n, d;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	n = { |r,f,n=0,d=1|
		round(r**LFNoise0.ar([4, 1, 8, 2] ! d)*f,n);
	};
	d = n.(3, 0.6);
	sig = Splay.ar(
		Ringz.ar(d, 0.01, n.(2, n.(20, 400), 40, 20), d).mean.tanh
	);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Pbind(
	\instrument, \seqClic,
	\dur, 4,
	\amp, 1,
	\release, 10
).play;
)

x=0;Pbind(*[type:\set,id:{|freq=10|LFTri.ar(freq.lag(0.1))!2}.play.nodeID,freq:Pfunc{x=x+32%355;x%12+1*40},dur:1/6]).play; // #supercollider

x=0;Pbind(*[type:\set,id:{|freq=10|f=freq;LPF.ar(Saw.ar(f),f.lag(1)*3)!2}.play.nodeID,freq:Pfunc{x=x+32%35;x%12+1*40},dur:1/6]).play

play{p=PinkNoise.ar(1!2);BRF.ar(p+Blip.ar(p+2,400),150,2,0.1)+LPF.ar(FreeVerb2.ar(*LPF.ar(p+0.2*Dust.ar(0.1),60)++[1,1,0.2,1e4]).tanh,2000)}

Ndef('x', {
	Normalizer.ar(
		FreqShift.ar(Rotate2.ar(*Ndef('x').ar++1/8).tanh,20*[-3,0.995])+Dust.ar(1!2,0.005),1,0.5
	)
}).play// #supercollider

Ndef(\x,{DelayN.ar(BRF.ar(Saw.ar(20!2)*0.01+Rotate2.ar(*(Ndef(\x).ar*2).tanh++0.1),20**LFNoise1.kr(0.6)*500,1),1,1)}).play; // bruitisme

b=Buffer.read(s,"sounds/a11wlk01.wav");play{t=Impulse.kr(5);PlayBuf.ar(1,b,1,t,Demand.kr(t,0,Dseq(1e3*[103,41,162,15,141,52,124,190],4)))!2} // bruitisme

Ndef('x',{x=(Ndef('x').ar*1.8).tanh;BPF.ar(x+[0.01,0.1],12**Latch.ar(x.mean,Impulse.ar(3)).lag(0.1)*200)})// tin whistle #supercollider
Ndef('x',{x=Ndef('x').ar+0.01;a=BPF.ar(x,6**Latch.ar(x,Dust.ar(x))*200,0.1).sin;9.do{a=AllpassN.ar(a,0.2,{0.2.rand}!2,9)};a+a.mean}).play;

f=g=0;Routine({loop{g=g+1e-3;f=f+g%1;play{l=Line.kr(1,0,3,doneAction:2);h=2**f*100;e=Pluck.ar(CuspL.ar,1,i=1/h,i,2,0.3)!2};0.15.wait}}).play;

a=1@2;f=1;w=Window().front.drawHook_({900.do{Pen.line(a*200,(a=(a*(f=f+2e-6)).y.cos+1@a.x)*200)};Pen.stroke});AppClock.play{w.refresh;0.01}

p={|f,a=5|GVerb.ar(LFPulse.ar(f)*a)+f};play{tanh(HPF.ar(p.(99-p.(1/2,20)*(1+p.(2,1/5))+p.(4+p.(1/2)),0.5),80,XLine.kr(4e-4,1/8,61,1,0,2)))}

n={|r,f,n=0,d=1|round(r**LFNoise0.ar([4,1,8,2]!d)*f,n)};play{Splay.ar(d=n.(3,0.6);Ringz.ar(d*0.01,n.(2,n.(20,400),40,20),d).mean.tanh)}

x=0;Pbind(*[type:\set,id:{|freq=10|LFTri.ar(freq.lag(0.1))!2}.play.nodeID,freq:Pfunc{x=x+32%355;x%12+1*40},dur:1/6]).play// #supercollider
play{p=PinkNoise.ar(1!2);BRF.ar(p+Blip.ar(p+2,400),150,2,0.1)+LPF.ar(FreeVerb2.ar(*LPF.ar(p+0.2*Dust.ar(0.1),60)++[1,1,0.2,1e4]).tanh,2000)}
Ndef('x',{Normalizer.ar(FreqShift.ar(Rotate2.ar(*Ndef('x').ar++1/8).tanh,20*[-3,0.995])+Dust.ar(1!2,0.005),1,0.5)}).play// #supercollider
b=Buffer.read(s,"sounds/a11wlk01.wav");play{t=Impulse.kr(5);PlayBuf.ar(1,b,1,t,Demand.kr(t,0,Dseq(1e3*[103,41,162,15,141,52,124,190],4)))!2}
b=Buffer.read(s,"sounds/a11wlk01.wav");play{t=Impulse.kr(6);BufGrain.ar(t,0.3,b,1,Demand.kr(t,0,Dseq([26,8,11,42,44,3,5,37,4,32,45]/50,4)))}
Ndef('x',{x=Ndef('x').ar+0.01;a=BPF.ar(x,6**Latch.ar(x,Dust.ar(x))*200,0.1).sin;9.do{a=AllpassN.ar(a,0.2,{0.2.rand}!2,9)};a+a.mean}).play;
a=1@2;f=1;w=Window().front.drawHook_({900.do{Pen.line(a*200,(a=(a*(f=f+2e-6)).y.cos+1@a.x)*200)};Pen.stroke});AppClock.play{w.refresh;0.01}
Ndef(\,{LPF.ar(x=DelayN.ar(LeakDC.ar(Ndef(\).ar,1-2e-6)*0.99,1,0.01)+Dust.ar(0.5!2);x+(Trig1.ar(x<(x.mean.lag(30)),4e-3)*0.05),800)}).play
Ndef(\,{x=DelayL.ar(n=Ndef(\);n.ar,2,LFNoise0.kr(0.03*_!20)+1)+Blip.ar(0.5);LeakDC.ar(LPF.ar(x+x.mean*0.15,4e3)).sin});play{Splay.ar(n.ar)}
play{w=LFSaw;a=w.ar(-3,1)+1/2;f=Sweep.ar(0,3).floor;f=(f**3+f%8+4)*(f%3+3)%49*3;CombN.ar(RLPF.ar(w.ar(f)*a,f**a*30,0.3).tanh,5/6,5/6,6)!2}
play{PitchShift.ar(CombN.ar(Formant.ar(101,4**LFNoise1.kr(0.5)*450,200),1,0.5,99),1,Duty.kr(4,0,Dseq([[6,8,10],[6,7.2,7]]/8,inf))).sum/25!2}
Ndef(\,{x=DelayN.ar(LeakDC.ar(Ndef(\).ar),1,z=1e-2);LPF.ar(Trig1.ar(Amplitude.kr(x,5,120)*1.5+x+z-Dust.ar(2),4e-3)*0.1+x*0.99,1200)}).play;

play{
	b = LocalBuf(1e5,2).clear;
	x = BufRd.ar(2,b,Phasor.ar(0,1,0,1e5))*0.6;
	BufWr.ar(Blip.ar([1,1.01],10)/5+x,b,LFNoise1.ar(0.2)+1*5e4);
	x;
}; // #sc

(
SynthDef(\seqModul, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env, buffer;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	buffer = LocalBuf(1e5,2).clear;
	sig = BufRd.ar(2,buffer,Phasor.ar(0,1,0,1e5))*0.6;
	BufWr.ar(Blip.ar([1,1.01],10)/5+sig,buffer,LFNoise1.ar(0.2)+1*5e4);
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Pbind(
	\instrument, \seqModul,
	\dur, 4,
	\amp, 3,
	\release, 10
).play;
)

play{b=LocalBuf(4e5,2).clear;BufCombL.ar(b,LeakDC.ar(BufRd.ar(2,b,LFNoise1.ar(0.25)+1*2e5)*0.98)+Blip.ar(2!2,10),2,20)/10}// #supercollider
play{b=LocalBuf(4e5,2).clear;BufCombL.ar(b,LeakDC.ar(LPF.ar(PlayBuf.ar(2,b,16/15,0,0,1),300))+Blip.ar([20,21],1),2,40)/20}// #supercollider
play{b=LocalBuf(2*SampleRate.ir,2);BufCombL.ar(b,LeakDC.ar(RLPF.ar(Limiter.ar(PlayBuf.ar(2,b,0.4,0,0,1),0.5)+Dust.ar(0.1),5e3,0.03)),1,10)};

play{
	x = Splay.ar({|i|
		RLPF.ar(0.6**i*40*Impulse.ar(2**i/32,1/2),4**LFNoise0.kr(1/16)*300,5e-3).sin;
	}!8);

	x;
};

(
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
)

(
Pbind(
	\instrument, \seqPure,
	\dur, 4,
	\amp, 1,
	\release, 10
).play;
)

play{
	x = Saw.ar([50,50.1]);
	8.do{|i|
		f = 2 ** (8 - i);
		x = BRF.ar(
			AllpassN.ar(x,1,0.1/(12-i),2),
			80 ** TRand.ar(0,1,Impulse.ar(f/32,1/2)).lag(1/f)*80,
			2
		);
	};
	x
}

(
SynthDef(\ambitek, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = Saw.ar([50,50.1]);
	4.do{|i|
		var f = 2 ** (8 - i);
		sig = BRF.ar(
			AllpassN.ar(sig,1,0.1/(12-i),2),
			80 ** TRand.ar(0,1,Impulse.ar(f/32,1/2)).lag(1/f) * 80,
			2
		);
	};
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;
)

(
Pbind(
	\instrument, \ambitek,
	\dur, 4,
	\amp, 1,
	\release, 10
).play;
)

play{
	GVerb.ar(
		LFTri.ar(
			Duty.ar(Dseq([3,1]/12,inf),
			0,
			Dseq(
					x=(3..6);
					allTuples(x/.t x).flat*[100,200,400]++0
				)
			)
		),
		25,
		5
	)/5;
} // #supercollider

(
SynthDef(\claudTweet, { arg out = 0, amp = 1, t_trig = 1, attack = 0.01, release = 2, doneAction = 2;
	var sig, env, x;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
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
)

(
Pbind(
	\instrument, \claudTweet,
	\dur, 4,
	\amp, 0.5,
	\release, 10
).play;
)

play{Splay.ar({|i|f=1.9**i/128;BPF.ar(PinkNoise.ar(1!2),4**LFNoise2.kr(1.2**i/16)*300,0.15)*(5**LFNoise2.ar(f)/(i+8)*20)}!15)};

p=Impulse;play{mean({|i|Pluck.ar(LFSaw.ar([102,101]),x=p.ar(1,i/10)+p.ar(0),1,1/Latch.ar(1.015**Sweep.ar(0,1)*64%1+1*200,x),4,0.2)}!10)}

play{
	GVerb.ar(
		(
			{|k|
				({|i|
					x = Impulse.kr(0.5 ** i / k);
					y = SinOsc;y.ar(i, y.ar(i + k ** i) / Decay.kr(x, [i, i + 1], k))} ! 6).sum;
			}!16
		).sum,
		1
	)/512;
}//#supercollider

( // too big
SynthDef(\sleep, { arg out = 0, amp = 1, attack = 0.01, release = 2, roomSize = 1, impFreq = 0.5, t_trig = 1, doneAction = 2;
	var sig, env, x;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), t_trig, doneAction: doneAction);
	sig = GVerb.ar(
		(
			{|k|
				({|i|
					x = Impulse.kr(impFreq ** i / k);
					y = SinOsc;y.ar(i, y.ar(i + k ** i) / Decay.kr(x, [i, i + 1], k))} ! 3).sum;
			} ! 8
		).sum,
		roomSize
	) / 512;
	sig = sig * env;
	OffsetOut.ar(out, sig * amp);
}).add;
)

(
SynthDef(\KSpluck3, { arg out = 0, att = 0, dec = 0.01, midiPitch, art, noiseFreq = 1, doneAction = 2;
		var burstEnv;
		var sig, delayTime;
		delayTime = [midiPitch, midiPitch + 12].midicps.reciprocal;
		burstEnv = EnvGen.kr(Env.perc(att, dec));
		sig = PinkNoise.ar([burstEnv, burstEnv]); //Noise burst
		sig = CombL.ar(sig, delayTime, delayTime,
			art, add: sig); //Echo chamber
		sig = RLPF.ar(sig, LFNoise1.kr(noiseFreq, 13000, 14010), 0.1); //Filter ADSR GELSIN BURAYA
		DetectSilence.ar(sig, doneAction: doneAction);
		OffsetOut.ar(out, sig*0.8)
	}
).add;
)

(
//run this first
SynthDef(\Flash, { arg out = 0, amp = 0.3, fund = 400, decay = 4, filter = 1, doneAction = 2;
	var sig;
	sig = Mix.ar( Array.fill(7,
		{
			arg counter;
			var partial;
			partial = counter + 1;
			SinOsc.ar(fund*partial) * EnvGen.kr(Env.linen(0, 0, decay + 2), levelScale: 1/(partial*filter)
			) * max(0, LFNoise1.kr(rrand(5.0, 12.0)));
		}
	)
	);
	sig = Pan2.ar(sig, Rand(-1.0, 1.0), amp);
	DetectSilence.ar(sig, doneAction: doneAction);
	OffsetOut.ar(out, sig)
}
).add;
)

(
Pbind(
	\instrument, \Lumbricost,
	\dur, 1.75,
	\amp, 0.5
).play;
)

(
SynthDef(\Lumbricost, {arg out = 0, amp = 1, pan = 0, attTim= 1, relTim=2.5, scale= 6, offset = 40, synch = 10, timescale = 10, widthmod = 0.4, width = 0.2, totVol, abc = 0, randLo = 0, randHi = 20000, bpfrq = 1, doneAction = 2;
	var generation =
	Pulse.ar(SinOsc.kr(5/synch, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(30/synch),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(7/synch, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(7/synch),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(9/synch, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(2/synch),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(10/synch, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(5/synch),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(3/synch, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(9/synch),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(2/synch, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(40/synch),widthmod,width,timescale), mul: 0.1);
	var env = generation * Env.perc(attackTime:attTim,releaseTime: relTim).ar(doneAction);
	var env1 = LeakDC.ar(env);
	var sig =  env1* ((totVol + amp -15).dbamp);
	sig = BPF.ar(sig, Rand(randLo-100, randHi+100), bpfrq);
	OffsetOut.ar(out, Pan2.ar(sig, pan));
}).add;
)