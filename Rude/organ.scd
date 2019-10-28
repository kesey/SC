


// a finir


(
SynthDef(\organ, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
	var sig;
	sig = SinOsc.ar(freq * [1/2, 3/2, 1, 2,     2 + (3/2), 3, 3 + (5/4), 3 + (3/2), 4]);
	//sig = LFPulse.ar(freq * [1, 3, 2, 4,    6, 8, 10, 12,    16]/4);
	sig = sig * \wheels.kr([0,0,0,0, 0,8,0,0, 0]/8);
	sig = sig * EnvGen.ar(Env.adsr(0.01,0.01,0.8,0.01),gate,doneAction:2);
	sig = Pan2.ar(sig, pan, amp).mean;
	Out.ar(out, sig);
}).add;
);

(
Pdef(\organ, Pbind(
	\instrument, \organ,
	\degree, Pseq([0,0,0,1,2,3],inf),
	\legato, 0.5,
	\dur, 1/2,
	\amp, 0.2
)).play;
);

100 * 3/2
100 * 7.midiratio




// a decortiquer

(
fork {
	TempoClock.tempo = 1;
	Ndef(\ttso).play;
	loop {
		var seed = thisThread.randSeed = 100000000.rand.debug('seed');
		var wait = 20.rrand(60).debug('wait');
		Ndef(\ttso, {
			var gamma= {[rrand(30,50),rrand(50,70),rrand(50,70),rrand(70,100)].choose.midicps*LFNoise2.kr(1,0.01,1)}!24;
			Pan2.ar(
				LeakDC.ar(
					Normalizer.ar(
						BPeakEQ.ar(
							FreeVerb.ar(
								Splay.ar(RLPF.ar(LFSaw.ar(gamma)/4,gamma*LFCub.kr(rrand(0.01,0.1),0,2,3),LFNoise2.kr(1/8,0.6,0.7))),
								0.1,0.1,0.1
							),
							[100.rrand(200),1000.rrand(2000),5000.rrand(7000),10000.rrand(15000)],Array.rand(4,0,6),Array.rand(4,0,6)
						).mean,
						0.8,0.1
					)
				),
				LFNoise2.kr(0.1.exprand(10)).range(-0.1,0.1),
				SelectX.kr(
					[SinOsc,LFTri].choose.kr(2.rrand(25).reciprocal).range(0,2),
					[
						0.7.rrand(1),
						LFGauss.kr(
							Latch.kr(
								LFNoise2.kr(1).range(1/5,5.rrand(20)).reciprocal, 
								Impulse.kr(LFNoise2.kr(3.rrand(10).reciprocal).range(0.5,3.rrand(6)))
							),
							SinOsc.kr(3.rrand(15).reciprocal).range(0.07.rrand(0.16),0.25.rrand(0.4))
						),
						0.1.rrand(0.5)
					]
				)
			)
		}).fadeTime_(3.rrand(6));
		wait.wait;
	}
}
)


// 2012.05.04
// Work for NX014 Class
// Inspiration: A Rukano Tweet. Thanks rukano!
// Comment: Cosmic Organ.

p = ProxySpace.push(s.boot);

~a.play;

(
~a = {  var alpha,gamma;
		alpha= LFNoise2;
			gamma= {[rrand(30,50),rrand(50,70),rrand(50,70),rrand(70,100)].choose.midicps*alpha.kr(1,0.01,1)}!24;
	Pan2.ar(LeakDC.ar(Normalizer.ar(
		BPeakEQ.ar(BPeakEQ.ar(BPeakEQ.ar(BPeakEQ.ar(FreeVerb.ar(
	Splay.ar(RLPF.ar(LFSaw.ar(gamma)/4,gamma*LFCub.kr(rrand(0.01,0.1),0,2,3),alpha.kr(1/8,0.6,0.7)))			
		,0.1,0.1,0.1)
		 ,100,6.0,6),1000,6.0,0),5000,6.0,0),10000,6.0,6)
		 ,(0.8/0.999)*1,0.1)),0)
};
)

~a = nil;



//////////



(
Ndef(\organ, {

	var signal, freq=540;
	var osig;

	freq = MouseY.kr(200,800);
	signal = Saw.ar(freq * [0.998, 1, 1.003]).sum

	+ SinOsc.ar(-7.midiratio*freq, 0, -4.dbamp)

	+ SinOsc.ar(2*freq, 0, -4.dbamp);

	signal = (signal*0.5)

	+ Resonz.ar(signal, 

		200/[200, 400, 800, 1400, 3200, 5000, 8000], 

		[200, 400, 800, 1400, 3200, 5000, 8000]).mean;

		signal = MoogFF.ar(signal, freq * 4, 3.2);


		osig = signal;
		signal = FFT(LocalBuf(2**10), signal);
		signal = PV_MagSquared(signal);
		signal = PV_LocalMax(signal, 22);
		signal = IFFT(signal) * 50;
		signal = signal * (-28.dbamp);
		signal = SelectX.ar(MouseX.kr(0,1), [osig, signal]);
		signal = signal ! 2 * 0.2;

	}).play;
)
