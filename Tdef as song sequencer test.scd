s.boot;

(
n = 60; // Tempo in beat per minutes
t = TempoClock.default;
t.tempo = n / 60; // TempoClock by default in beat per seconds

ServerQuit.add({ arg server;
	Pdef.removeAll;
	Tdef.removeAll;
	server.freeAll;
}, s);

//////////////////////////// SynthDef

SynthDef(\snare2,{ arg t_trig = 1, amp=1, out=0, pan = 0;
	var env = EnvGen.ar(Env.perc(0.001,0.2),t_trig,doneAction:2);
	var freq = EnvGen.ar(Env([12000,100,12000],[0.01,0.01]));
	var sig = WhiteNoise.ar(env);
	sig = LPF.ar(sig,freq);
	sig = sig.tanh;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp) );
}).add;

SynthDef(\prayer_bell, { |out = 0, t_trig = 1, sing_switch = 0, freq = 2434, amp = 0.5, decayscale = 1, lag = 10, level = 0.08, pan = 0, i_doneAction = 2|
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

SynthDef(\IkedaHiNoise, { arg out = 0, t_trig = 0, attack = 0.02, decay = 0.1, amp = 0.05, rq = 0.9, pan = 0, level = 10;
	var noise, sig;
	noise = WhiteNoise.ar(Decay2.kr(t_trig, attack, decay, amp));
	sig = BPF.ar(noise, TRand.kr(12000, 15000, t_trig), rq.max(0.001));
	DetectSilence.ar(sig, 0.0001, doneAction:2);
	OffsetOut.ar(out, Pan2.ar(sig, pan, level));
}).add;

SynthDef(\kick2,{arg out = 0, t_gate = 1 ,freq = 60, tu = 1, amp = 1, atf = 80, rel =1, pan = 1;
	var env = EnvGen.ar(Env.perc(0,rel),t_gate,doneAction:2);
	var frequ = EnvGen.ar(Env([freq-30,freq,60],[0.001,0.01]));
	var sig = SinOsc.ar(frequ*tu,0,env);
	sig = Pan2.ar(LPF.ar(sig,100), pan, amp);
	OffsetOut.ar(out, sig);
}).add;

//////////////////////////// Pattern

~testPattern1 = Pbind(
	\instrument, \kick2,
	\dur, Pseq([1, 2, 0.75, 0.25]/4, inf),
	\amp, 0.35
);

~testPattern2 = Pbind(
	\instrument, \IkedaHiNoise,
	[\dur, \amp, \decay],  Pseq([[0.5/2, 0.03, 0.5], Pn([0.5/2, 0.05, 0.01], 3)], inf),
	\pan , Pwhite(-1, 1, inf)
);

~testPattern3 = Pbind(
	\instrument, \prayer_bell,
	\dur, Pseq([4], inf),
	\level, 0.03,
	\freq, 378,
	\decayscale, 0.48
);

~testPattern4 = Pbind(
	\instrument, \snare2,
	\dur, 2,
	\amp, 0.10
);

//////////////////////////// Sequencer

p = Ppar([Pdef(\unit1), Pdef(\unit2), Pdef(\unit3), Pdef(\unit4)], inf);

//////////////////////////// Song
~globalQuant = 0.125;

~testSong = {
	loop {
		"0".postln;
		Pdef(\unit1, ~testPattern1).quant_(~globalQuant); // Kick
		Pdef(\unit2, ~testPattern2).quant_(~globalQuant); // Hat
		Pdef(\unit3, ~testPattern3).quant_(~globalQuant); // Bell
		Pdef(\unit4, ~testPattern4).quant_(~globalQuant); // Snare
		8.0.wait;
		"1".postln;
		Pbindef(\unit1, \dur, Pseq([2, 2], inf)).quant_(~globalQuant);
		8.0.wait;
		"2".postln;
		Pbindef(\unit1, \dur, Pseq([1, Pn(0.25, 2), 1.25, 1, 0.25], inf)).quant_(~globalQuant);
		8.0.wait;
		"3".postln;
		Pbindef(\unit1, \dur, Pseq([1, 0.5, 1, 0.125, 1, 0.25, 0.125], inf)).quant_(~globalQuant);
		8.0.wait;
	}
};

)

//////////////////////////// Transport

( // Play
if (~sequencerTransport.isPlaying.not, { ~sequencerTransport = p.play(t, quant: ~globalQuant); });
Tdef(\song, ~testSong).play(t, quant: ~globalQuant);
)

( // Stop
Tdef(\song).stop;
~sequencerTransport.stop;
)

( // Reset
Tdef(\song).reset;
~sequencerTransport.reset;
)