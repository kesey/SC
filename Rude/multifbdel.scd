
(
	// basic
	~transfert = { arg x, a, b, c;
		//2**(x * a);
		//x.gaussCurve(a*4, b*4, c*4)
		//a * (exp(squared(x - b) / (-2.0 * squared(c))))
		var val;
		//x = x + 0.5;
		val = x;
		val = val * a * 4;
		//val = val + b;

		val = val * 2 - 1;
		val = val**3;
		val = ( val*c ) + ( ( val**3 ) * (1-c) );
		//[val, ( val-0.5 ).softclip(0,1)+0.5].debug("bb,aa");
		val = val + (b*2-1);
		val = val.softclip;
		val = val +1 / 2 - 0.0625;
		//val = (x**3);
		//val = ( x*a*4 )**(3) + 0.5;
		//val.softclip(0,1);
		val
	};
	RandDelayNetwork(\multifbdel, {
		var block, algo;
		block = [
			\delay!16,
			\shift!2,
			\shift2!2,
			\dist!2,
			\fbnode!2,
			\fbnode2!2,
			\pan,
		].flatten.choose;
		algo = [
			\par, \seq
		].wchoose([0.1,0.9].normalizeSum);
		switch(algo,
			\par, {
				\par -> [2,4].choose.collect({
					\seq -> [ block, \end ]
				})
			},
			\seq, {
				\seq -> ([block] ++ (\end ! [1,2].choose))
			},
		)
	},
	IdentityDictionary.newFrom([
		\fbnode, { arg si, env;
			if(env.fbnode.isNil) {
				// in
				env.fbnode = FbNode(2);
				env.fbnode * \fb1.kr(0) + si;
			} {
				// out
				env.fbnode.write(Limiter.ar(si));
				env.fbnode = nil;
				si;
			};
		},
		\fbnode2, { arg si, env;
			if(env.fbnode.isNil) {
				// in
				env.fbnode = FbNode(2);
				env.fbnode * \fb2.kr(0) + si;
			} {
				// out
				env.fbnode.write(Limiter.ar(si));
				env.fbnode = nil;
				si;
			};
		},
		\pan, { arg si;
			Pan2.ar(si, rrand(-1,1)*0.1, 1).mean;
		},
		\delay, { arg si;
			var delay = [\delay, \delay2].choose.kr;
			DelayL.ar(si, 0.8, ~transfert.(rrand(0.01,0.8), \deltran1.kr, \deltran2.kr, \deltran3.kr) * [1, 1+0.01.rand] * delay) + si;
		},
		\shift, { arg si;
			FreqShift.ar(si, 100.0.rand * [1, 1+0.01.rand] * [1,-1].choose * \shift.kr) + si / 1.2;
		},
		\shift2, { arg si;
			FreqShift.ar(si, 100.0.rand * [1, 1+0.01.rand] * [1,-1].choose * \shift2.kr) + si / 1.2;
		},
		\dist, { arg si;
			(si * 10.0.rand * \distamp.kr).tanh / 2;
		},
		\end, { arg si;
			//[
			//	{
			//		"endamp1".debug;
			//		si * \endamp1.kr(1)
			//	},
			//	{
			//		"endamp2".debug;
			//		si * \endamp2.kr(1)
			//	},
			//].choose.value;
			si;
		}
	]))
	.make_graph_({ arg in, code, rdnkey;
		var sig;
		var sigin;
		var del, shi;
		var del2, shi2;
		var distamp;
		var hasFreq, afreq;
		var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
		var pitchlag;
		var pitchmix;
		var fb, fb1, fb2;
		var gain;
		var mix;
		var indelay;
		//"default_make_graph".debug("!!!");
		rdnkey = rdnkey ? \default;
		code = code ? "4--";
		sig = in;
		mix = \mix.kr(0.5);
		gain = \gain.kr(1);
		fb = \fb.kr(0.01);
		del = \delay.kr(1,0.1);
		del2 = \delay2.kr(1,0.1);
		shi = \shift.kr(1);
		shi2 = \shift2.kr(1);
		distamp = \distamp.kr(1);
		pitchlag = \pitchlag.kr(1/8) / TempoClock.default.tempo;
		pitchmix = \pitchmix.kr(0.5);
		fb1 = \fb1.kr(0);
		fb2 = \fb2.kr(0);

		sig = LPF.ar(sig, \prelpf.kr(17000));
		sig = HPF.ar(sig, \prehpf.kr(17));

		sig = sig + (LocalIn.ar(2) * fb);

		sig = LPF.ar(sig, \lpf.kr(17000));
		sig = HPF.ar(sig, \hpf.kr(17));
		sig = RandDelayNetwork(rdnkey).ar(sig, code);

		sig1 = sig.tanh * \fbdistamp.kr(1/2.1);
		sig = SelectX.ar(\fbdistmix.kr(1), [sig, sig1]);

		sig = Limiter.ar(sig);

		sig1 = sig;
		#afreq, hasFreq = Pitch.kr(sig1).flop;
		sig1 = BRF.ar(sig1, afreq.lag(pitchlag));
		#afreq, hasFreq = Pitch.kr(sig1).flop;
		sig1 = BRF.ar(sig1, afreq.lag(pitchlag));
		sig = SelectX.ar(pitchmix, [sig, sig1]);

		LocalOut.ar(sig);
		sig = LPF.ar(sig, \postlpf.kr(17000));
		sig = HPF.ar(sig, \posthpf.kr(17));
		sig = Limiter.ar(sig);
		sig = sig * \wetamp.kr(1);

		indelay = \indelay.kr(0);
		sigin = DelayL.ar(in, 0.2, indelay);
		sig = SelectX.ar(mix, [sigin, sig]);
		sig = sig * gain;
		//sig.debug("end sig");
		sig;
	});


	////////////////////////// ////////////////////////// ////////////////////////// //////////////////////////



	RandDelayNetwork(\deltrans, {
		var block, algo;
		block = [
			\delay!16,
			\shift!2,
			\shift2!2,
			\dist!2,
			\dist2!2,
		].flatten.choose;
		algo = [
			\par, \seq
		].wchoose([0.3,0.9].normalizeSum);
		switch(algo,
			\par, {
				\par -> [2,4].choose.collect({
					\seq -> [ block, \end ]
				})
			},
			\seq, {
				\seq -> ([block] ++ (\end ! [1,2].choose))
			},
		)
	},
	IdentityDictionary.newFrom([
		\delay, { arg si;
			var delay = [\delay, \delay2].choose.kr;
			DelayL.ar(si, 0.8, ~transfert.(rrand(0.01,0.8), \deltran1.kr, \deltran2.kr, \deltran3.kr) * [1, 1+0.01.rand] * delay) + si;
		},
		\shift, { arg si;
			FreqShift.ar(si, 100.0.rand * [1, 1+0.01.rand] * [1,-1].choose * \shift.kr) + si / 1.2;
		},
		\shift2, { arg si;
			FreqShift.ar(si, 100.0.rand * [1, 1+0.01.rand] * [1,-1].choose * \shift2.kr) + si / 1.2;
		},
		\dist, { arg si;
			(si * rrand(0.8,10) * \distamp.kr).tanh / 2;
		},
		\dist2, { arg si;
			(si * rrand(0.8,10) * \distamp.kr).softclip / 2;
		},
		\end, { arg si;
			si;
		}
	]))
	.make_graph_({ arg in, code, rdnkey;
		var sig;
		var sigin;
		var del, shi;
		var del2, shi2;
		var distamp;
		var hasFreq, afreq;
		var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
		var pitchlag;
		var pitchmix;
		var fb, fb1, fb2;
		var gain;
		var mix;
		var indelay;
		//"default_make_graph".debug("!!!");
		rdnkey = rdnkey ? \default;
		code = code ? "4--";
		sig = in;
		mix = \mix.kr(0.5);
		gain = \gain.kr(1);
		fb = \fb.kr(0.01);
		del = \delay.kr(1,0.1);
		del2 = \delay2.kr(1,0.1);
		shi = \shift.kr(1);
		shi2 = \shift2.kr(1);
		distamp = \distamp.kr(1);
		pitchlag = \pitchlag.kr(1/8) / TempoClock.default.tempo;
		pitchmix = \pitchmix.kr(0.5);
		fb1 = \fb1.kr(0);
		fb2 = \fb2.kr(0);

		sig = LPF.ar(sig, \prelpf.kr(17000));
		sig = HPF.ar(sig, \prehpf.kr(17));

		sig = sig + (LocalIn.ar(2) * fb);

		sig = LPF.ar(sig, \lpf.kr(17000));
		sig = HPF.ar(sig, \hpf.kr(17));
		sig = RandDelayNetwork(rdnkey).ar(sig, code);

		sig1 = sig.tanh * \fbdistamp.kr(1/2.1);
		sig = SelectX.ar(\fbdistmix.kr(1), [sig, sig1]);

		sig = Limiter.ar(sig);

		sig1 = sig;
		#afreq, hasFreq = Pitch.kr(sig1).flop;
		sig1 = BRF.ar(sig1, afreq.lag(pitchlag));
		#afreq, hasFreq = Pitch.kr(sig1).flop;
		sig1 = BRF.ar(sig1, afreq.lag(pitchlag));
		sig = SelectX.ar(pitchmix, [sig, sig1]);

		LocalOut.ar(sig);
		sig = LPF.ar(sig, \postlpf.kr(17000));
		sig = HPF.ar(sig, \posthpf.kr(17));
		sig = Limiter.ar(sig);
		sig = sig * \wetamp.kr(1);

		indelay = \indelay.kr(0);
		sigin = DelayL.ar(in, 0.2, indelay);
		sig = SelectX.ar(mix, [sigin, sig]);
		sig = sig * gain;
		//sig.debug("end sig");
		sig;
	});

	/////////////////////////


	RandDelayNetwork(\deldefault).make_graph_({ arg in, code, rdnkey;
		var sig;
		var sigin;
		var del, shi;
		var del2, shi2;
		var distamp;
		var hasFreq, afreq;
		var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
		var pitchlag;
		var pitchmix;
		var fb, fb1, fb2;
		var gain;
		var mix;
		var indelay;
		//"default_make_graph".debug("!!!");
		rdnkey = rdnkey ? \default;
		code = code ? "4--";
		sig = in;
		mix = \mix.kr(0.5);
		gain = \gain.kr(1);
		fb = \fb.kr(0.001);
		del = \delay.kr(0.001,0.1);
		del2 = \delay2.kr(0.001,0.1);
		shi = \shift.kr(0);
		shi2 = \shift2.kr(0);
		distamp = \distamp.kr(1);
		pitchlag = \pitchlag.kr(1/8) / TempoClock.default.tempo;
		pitchmix = \pitchmix.kr(0);

		sig = LPF.ar(sig, \prelpf.kr(17000));
		sig = HPF.ar(sig, \prehpf.kr(17));

		sig = sig + (LocalIn.ar(2) * fb);

		sig = LPF.ar(sig, \lpf.kr(17000));
		sig = HPF.ar(sig, \hpf.kr(17));
		sig = RandDelayNetwork(rdnkey).ar(sig, code);

		sig1 = sig.tanh * \fbdistamp.kr(1/2);
		sig = SelectX.ar(\fbdistmix.kr(1), [sig, sig1]);

		sig = Limiter.ar(sig);

		sig1 = sig;
		#afreq, hasFreq = Pitch.kr(sig1).flop;
		sig1 = BRF.ar(sig1, afreq.lag(pitchlag));
		#afreq, hasFreq = Pitch.kr(sig1).flop;
		sig1 = BRF.ar(sig1, afreq.lag(pitchlag));
		sig = SelectX.ar(pitchmix, [sig, sig1]);

		LocalOut.ar(sig);
		sig = LPF.ar(sig, \postlpf.kr(17000));
		sig = HPF.ar(sig, \posthpf.kr(17));
		sig = Limiter.ar(sig);
		sig = sig * \wetamp.kr(1);

		indelay = \indelay.kr(0);
		sigin = DelayL.ar(in, 0.2, indelay);
		sig = SelectX.ar(mix, [sigin, sig]);
		sig = sig * gain;
		//sig.debug("end sig");
		sig;
	});

	/////////////////////////


	RandDelayNetwork(\deldefshift).make_graph_({ arg in, code, rdnkey;
		var sig;
		var sigin;
		var del, shi;
		var del2, shi2;
		var distamp;
		var hasFreq, afreq;
		var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
		var pitchlag;
		var pitchmix;
		var fb, fb1, fb2;
		var gain;
		var mix;
		var indelay;
		//"default_make_graph".debug("!!!");
		rdnkey = rdnkey ? \default;
		code = code ? "4--";
		sig = in;
		mix = \mix.kr(0.5);
		gain = \gain.kr(1);
		fb = \fb.kr(0.001);
		del = \delay.kr(0.001,0.1);
		del2 = \delay2.kr(0.001,0.1);
		shi = \shift.kr(0);
		shi2 = \shift2.kr(0);
		distamp = \distamp.kr(1);
		pitchlag = \pitchlag.kr(1/8) / TempoClock.default.tempo;
		pitchmix = \pitchmix.kr(0);

		sig = LPF.ar(sig, \prelpf.kr(17000));
		sig = HPF.ar(sig, \prehpf.kr(17));

		sig = sig + (LocalIn.ar(2) * fb);

		sig = LPF.ar(sig, \lpf.kr(17000));
		sig = HPF.ar(sig, \hpf.kr(17));
		sig = RandDelayNetwork(rdnkey).ar(sig, code);

		sig1 = sig.tanh * \fbdistamp.kr(1/2);
		sig = SelectX.ar(\fbdistmix.kr(1), [sig, sig1]);

		sig = Limiter.ar(sig);

		sig1 = sig;
		#afreq, hasFreq = Pitch.kr(sig1).flop;
		sig1 = BRF.ar(sig1, afreq.lag(pitchlag));
		#afreq, hasFreq = Pitch.kr(sig1).flop;
		sig1 = BRF.ar(sig1, afreq.lag(pitchlag));
		sig = SelectX.ar(pitchmix, [sig, sig1]);

		LocalOut.ar(sig);
		sig = LPF.ar(sig, \postlpf.kr(17000));
		sig = HPF.ar(sig, \posthpf.kr(17));
		sig = Limiter.ar(sig);
		sig = sig * \wetamp.kr(1);

		indelay = \indelay.kr(0);
		sigin = DelayL.ar(in, 0.2, indelay);
		sig = SelectX.ar(mix, [sigin, sig]);
		sig = sig * gain;
		//sig.debug("end sig");
		sig;
	});
	RandDelayNetwork(\deldefshift).dict[\shift ] = { arg si;
		FreqShift.ar(si, 1.0.rand * [1,-1].choose * \shift.kr) + si / 1.2;
	};
	RandDelayNetwork(\deldefshift).dict[\shift2] = { arg si;
		FreqShift.ar(si, 1.0.rand * [1,-1].choose * \shift2.kr) + si / 1.2;
	};

	///////////////////
);

(

	RandDelayNetwork(\del3).make_graph_({ arg in, code, rdnkey;
		var sig;
		var sigin;
		var del, shi;
		var del2, shi2;
		var del3, shi3;
		var shiftmix;
		var distamp, distamp2, distamp3;
		var hasFreq, afreq;
		var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
		var pitchlag;
		var pitchmix;
		var fb, fb1, fb2;
		var gain;
		var mix;
		var indelay;
		//"default_make_graph".debug("!!!");
		rdnkey = rdnkey ? \default;
		code = code ? "4--";
		sig = in;
		mix = \mix.kr(0.5);
		gain = \gain.kr(1);
		fb = \fb.kr(0.001);
		del = \delay.kr(0.001,0.1);
		del2 = \delay2.kr(0.001,0.1);
		del3 = \delay3.kr(0.001,0.1);
		distamp = \distamp.kr(1);
		distamp2 = \distamp2.kr(1);
		distamp3 = \distamp3.kr(1);
		shi = \shift.kr(0);
		shi2 = \shift2.kr(0);
		shi3 = \shift3.kr(0);
		shiftmix = \shiftmix.kr(0);
		
		pitchlag = \pitchlag.kr(1/8) / TempoClock.default.tempo;
		pitchmix = \pitchmix.kr(0);

		sig = LPF.ar(sig, \prelpf.kr(17000));
		sig = HPF.ar(sig, \prehpf.kr(17));

		sig = sig + (LocalIn.ar(2) * fb);

		sig = LPF.ar(sig, \lpf.kr(17000));
		sig = HPF.ar(sig, \hpf.kr(17));
		sig = RandDelayNetwork(rdnkey).ar(sig, code);

		sig1 = sig.tanh * \fbdistamp.kr(1/2);
		sig = SelectX.ar(\fbdistmix.kr(1), [sig, sig1]);

		sig = Limiter.ar(sig);

		sig1 = sig;
		#afreq, hasFreq = Pitch.kr(sig1).flop;
		sig1 = BRF.ar(sig1, afreq.lag(pitchlag));
		#afreq, hasFreq = Pitch.kr(sig1).flop;
		sig1 = BRF.ar(sig1, afreq.lag(pitchlag));
		sig = SelectX.ar(pitchmix, [sig, sig1]);

		LocalOut.ar(sig);
		sig = LPF.ar(sig, \postlpf.kr(17000));
		sig = HPF.ar(sig, \posthpf.kr(17));
		//sig = MidEQ.ar(sig, \eqmid.kr(7000), \eqdb.kr(0), \eqrq.kr(0.5));
		sig = Limiter.ar(sig);
		sig = sig * \wetamp.kr(1);

		indelay = \indelay.kr(0);
		sigin = DelayL.ar(in, 0.2, indelay);
		sig = SelectX.ar(mix, [sigin, sig]);
		sig = sig * gain;
		//sig.debug("end sig");
		sig;
	});

	RandDelayNetwork(\del3).grow = { 
		var block, algo;
		block = [
			[\delay, \delay2, \delay3]!8,
			[\shift, \shift2, \shift3]!4,
			[\dist, \dist2, \dist3]!4,
			\flanger!4,
			\bpf!2, 
			\brf!2,
		].flat.choose;
		algo = [
			\par, \seq
		].wchoose([0.1,0.9].normalizeSum);
		if(algo == \par) {
			\par -> [2,4].choose.collect({
				\seq -> [ block, \end ]
			})
		} {
			\seq -> ([block] ++ (\end ! [1,2].choose))
		}
	};

	RandDelayNetwork(\del3).dict = IdentityDictionary.newFrom([
		\delay, { arg si;
			DelayC.ar(si, 0.8, rrand(0.01,0.8) * [1, 1+(\stereo.kr*0.01.rand)] * \delay.kr) + si;
		},
		\delay2, { arg si;
			DelayC.ar(si, 0.8, rrand(0.01,0.8) * [1, 1+(\stereo.kr*0.01.rand)] * \delay2.kr) + si;
		},
		\delay3, { arg si;
			DelayC.ar(si, 0.8, rrand(0.01,0.8) * [1, 1+(\stereo.kr*0.01.rand)] * \delay3.kr) + si;
		},
		\flanger, { arg si;
			DelayC.ar(si, 0.8, rrand(0.01,0.8) * [1, 1+0.01.rand] * SinOsc.kr(0.5.rand).range(1,1.1) * \delay2.kr) + si;
		},
		\shift, { arg si;
			SelectX.ar(\shiftmix.kr, [
				si,
				FreqShift.ar(si, 1.0.rand * [1,-1].choose * \shift.kr) + si / 1.2,
			]);
		},
		\shift2, { arg si;
			SelectX.ar(\shiftmix.kr, [
				si,
				FreqShift.ar(si, 1.0.rand * [1,-1].choose * \shift2.kr) + si / 1.2,
			]);
		},
		\shift3, { arg si;
			SelectX.ar(\shiftmix.kr, [
				si,
				FreqShift.ar(si, 1.0.rand * [1,-1].choose * \shift3.kr) + si / 1.2,
			]);
		},
		\bpf, { arg si;
			BPF.ar(si, exprand(100,10000)* \bpffac.kr(1), ( 0.5.rand * \bpfrqfac.kr(1) ) + 0.01) + ( si / 4 );
		},
		\brf, { arg si;
			BRF.ar(si, exprand(100,10000)* \brffac.kr(1), ( 0.5.rand * \brfrqfac.kr(1) ) + 0.01) + ( si / 4 );
		},
		\dist, { arg si;
			(si * 10.0.rand * \distamp.kr).tanh / 2;
		},
		\dist2, { arg si;
			(si * 10.0.rand * \distamp2.kr).tanh / 2;
		},
		\dist3, { arg si;
			(si * 10.0.rand * \distamp3.kr).tanh / 2;
		},
		\end, { arg si;
			si;
		}
	]);


	Spec.add(\delay3, \delay.asSpec);
	Spec.add(\shift3, \shift.asSpec);
	Spec.add(\shiftmix, \unipolar.asSpec);
	Spec.add(\distamp, ControlSpec(0.1,100,\exp));
	Spec.add(\distamp2, \distamp.asSpec);
	Spec.add(\distamp3, \distamp.asSpec);
);

////////////
(

	RandDelayNetwork(\del3full).make_graph_({ arg in, code, rdnkey;
		var sig;
		var sigin;
		var del, shi;
		var del2, shi2;
		var del3, shi3;
		var shiftmix;
		var distamp, distamp2, distamp3;
		var hasFreq, afreq;
		var sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8;
		var pitchlag;
		var pitchmix;
		var fb, fb1, fb2;
		var gain;
		var mix;
		var indelay;
		//"default_make_graph".debug("!!!");
		rdnkey = rdnkey ? \default;
		code = code ? "4--";
		sig = in;
		mix = \mix.kr(0.5);
		gain = \gain.kr(1);
		fb = \fb.kr(0.001);
		del = \delay.kr(0.001,0.1);
		del2 = \delay2.kr(0.001,0.1);
		del3 = \delay3.kr(0.001,0.1);
		distamp = \distamp.kr(1);
		distamp2 = \distamp2.kr(1);
		distamp3 = \distamp3.kr(1);
		shi = \shift.kr(0);
		shi2 = \shift2.kr(0);
		shi3 = \shift3.kr(0);
		shiftmix = \shiftmix.kr(0);
		
		pitchlag = \pitchlag.kr(1/8) / TempoClock.default.tempo;
		pitchmix = \pitchmix.kr(0);

		sig = LPF.ar(sig, \prelpf.kr(17000));
		sig = HPF.ar(sig, \prehpf.kr(17));

		sig = sig + (LocalIn.ar(2) * fb);

		sig = LPF.ar(sig, \lpf.kr(17000));
		sig = HPF.ar(sig, \hpf.kr(17));
		sig = RandDelayNetwork(rdnkey).ar(sig, code);

		sig1 = sig.tanh * \fbdistamp.kr(1/2);
		sig = SelectX.ar(\fbdistmix.kr(1), [sig, sig1]);

		sig = Limiter.ar(sig);

		sig1 = sig;
		#afreq, hasFreq = Pitch.kr(sig1).flop;
		sig1 = BRF.ar(sig1, afreq.lag(pitchlag));
		#afreq, hasFreq = Pitch.kr(sig1).flop;
		sig1 = BRF.ar(sig1, afreq.lag(pitchlag));
		sig = SelectX.ar(pitchmix, [sig, sig1]);

		LocalOut.ar(sig);
		sig = LPF.ar(sig, \postlpf.kr(17000));
		sig = HPF.ar(sig, \posthpf.kr(17));
		//sig = MidEQ.ar(sig, \eqmid.kr(7000), \eqdb.kr(0), \eqrq.kr(0.5));
		sig = Limiter.ar(sig);
		sig = sig * \wetamp.kr(1);

		indelay = \indelay.kr(0);
		sigin = DelayL.ar(in, 0.2, indelay);
		sig = SelectX.ar(mix, [sigin, sig]);
		sig = sig * gain;
		//sig.debug("end sig");
		sig;
	});

	RandDelayNetwork(\del3full).grow = { 
		var block, algo;
		block = [
			[\delay, \delay2, \delay3]!8,
			[\shift, \shift2, \shift3]!2,
			[\dist, \dist2, \dist3]!4,
			\flanger!2,
		].flat.choose;
		algo = [
			\par, \seq
		].wchoose([0.1,0.9].normalizeSum);
		if(algo == \par) {
			\par -> [2,4].choose.collect({
				\seq -> [ block, \end ]
			})
		} {
			\seq -> ([block] ++ (\end ! [1,2].choose))
		}
	};

	RandDelayNetwork(\del3full).dict = IdentityDictionary.newFrom([
		\delay, { arg si;
			DelayC.ar(si, 0.8, rrand(0.01,0.8) * [1, 1+(\stereo.kr*0.01.rand)] * \delay.kr) + si;
		},
		\delay2, { arg si;
			DelayC.ar(si, 0.8, rrand(0.01,0.8) * [1, 1+(\stereo.kr*0.01.rand)] * \delay2.kr) + si;
		},
		\delay3, { arg si;
			DelayC.ar(si, 0.8, rrand(0.01,0.8) * [1, 1+(\stereo.kr*0.01.rand)] * \delay3.kr) + si;
		},
		\flanger, { arg si;
			DelayC.ar(si, 0.8, rrand(0.01,0.8) * [1, 1+0.01.rand] * SinOsc.kr(0.5.rand).range(1,1.1) * \delay2.kr) + si;
		},
		\shift, { arg si;
			SelectX.ar(\shiftmix.kr, [
				si,
				FreqShift.ar(si, 1.0.rand * [1,-1].choose * \shift.kr) + si / 1.2,
			]);
		},
		\shift2, { arg si;
			SelectX.ar(\shiftmix.kr, [
				si,
				FreqShift.ar(si, 1.0.rand * [1,-1].choose * \shift2.kr) + si / 1.2,
			]);
		},
		\shift3, { arg si;
			SelectX.ar(\shiftmix.kr, [
				si,
				FreqShift.ar(si, 1.0.rand * [1,-1].choose * \shift3.kr) + si / 1.2,
			]);
		},
		\dist, { arg si;
			(si * 10.0.rand * \distamp.kr).tanh / 2;
		},
		\dist2, { arg si;
			(si * 10.0.rand * \distamp2.kr).tanh / 2;
		},
		\dist3, { arg si;
			(si * 10.0.rand * \distamp3.kr).tanh / 2;
		},
		\end, { arg si;
			si;
		}
	]);


	Spec.add(\delay3, \delay.asSpec);
	Spec.add(\shift3, \shift.asSpec);
	Spec.add(\shiftmix, \unipolar.asSpec);
	Spec.add(\distamp, ControlSpec(0.1,100,\exp));
	Spec.add(\distamp2, \distamp.asSpec);
	Spec.add(\distamp3, \distamp.asSpec);
);
