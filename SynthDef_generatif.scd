(

///////////////////////////////////////  Generatif

SynthDef(\lcm1, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, rate1 = 200, loRange1 = 1, rate2 = 6, loRange2 = 10, gate = 1, doneAction = 2;
    var sig, sig1, sig2, env;
    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);
    sig1 = SinOsc.ar(LFNoise2.ar(rate1, 500, 501)).range(loRange1, 100).round(1);
    sig2 = SinOsc.ar(LFNoise1.kr(rate2, 500, 501)).range(loRange2, 100).round(1);
    sig = tanh(lcm(sig1, sig2)*0.1);
    sig = sig * env;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\lcm2Gene, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, rate1 = 28, rate2 = 26, smooth1 = 0.4, smooth2 = 0.2, gate = 1, doneAction = 2;
    var sig, sig1, sig2, mod1, mod2, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    mod1 = TExpRand.kr(1, 1000, Impulse.kr(rate1));
    mod1 = Lag2.kr(mod1, smooth1);

    mod2 = TExpRand.kr(1, 1000, Dust.kr(rate2));
    mod2 = Lag2.kr(mod2, smooth2);

    sig1 = Saw.ar(mod1).range(-100,100).round(1);
    sig2 = LFCub.ar(mod2).range(-100,100).round(1);

    sig = tanh(lcm(sig1, sig2) * 0.001);

    sig = sig * env;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\gcdGene, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, sig1Frq = 0.02, sig2Frq = 1.24, dev = 0.1, mod = 30, gate = 1, doneAction = 2;
    var sig, sig1, sig2, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    sig1 = LFSaw.ar(sig1Frq) * 300 + 1;
    sig2 = LFSaw.ar(sig2Frq + [0, dev]) * 200 + 1;

    sig = SinOsc.ar(gcd(sig1, sig2) * mod + 300);

    sig = sig * env;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\gcdDmGene, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, sig1Frq = 3000, sig2Frq = 2995, mod1 = 100, mod2 = 100, dev = 25, gate = 1, doneAction = 2;
    var sig, sig1, sig2, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    sig1 = PulseCount.ar(Impulse.ar(sig1Frq)) % mod1;
    sig2 = PulseCount.ar(Impulse.ar(sig2Frq)) % mod2;

    sig = gcd(sig1, sig2 + [30, dev]);
    sig = Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3);

    sig = sig * env;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\gcdDm2Gene, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, sig1Frq = 3000, sig2Frq = 2995, mod1 = 20, mod2 = 20, dev1 = 3, dev2 = 7, gate = 1, doneAction = 2;
    var sig, sig1, sig2, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    sig1 = PulseCount.ar(TDuty.ar(Dseq((1..20), inf) + 41 * SampleDur.ir)) % mod1;
    sig2 = PulseCount.ar(TDuty.ar(Dseq((21..1), inf) + 40 * SampleDur.ir);) % mod2;

    sig = gcd(sig1, sig2 + [dev1, dev2]);
    sig = Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3);

    sig = sig * env;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\gcdDm3Gene, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, sig1Size = 10, sig2Size = 10, sig3Size = 10, add1 = 102, add2 = 101, add3 = 100, mod1 = 100, mod2 = 101, mod3 = 102, dev1 = 10, dev2 = 20, gate = 1, doneAction = 2;
    var sig, sig1, sig2, sig3, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    sig1 = TDuty.ar(Dseq([Dser(\seq1.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]), sig1Size)], inf) + add1 * SampleDur.ir);
    sig2 = TDuty.ar(Dseq([Dser(\seq2.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]), sig2Size)], inf) + add2 * SampleDur.ir);
    sig3 = TDuty.ar(Dseq([Dser(\seq3.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]), sig3Size)], inf) + add3 * SampleDur.ir);

    sig1 = PulseCount.ar(sig1) % mod1;
    sig2 = PulseCount.ar(sig2) % mod2;
    sig3 = PulseCount.ar(sig3) % mod3;

    sig = gcd(gcd(sig1 + [0, 0], sig2 + [0, dev1]), sig3 + [0, dev2]);
    sig = Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3);

    sig = sig * env;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\gcdLcmDmGene, { arg out = 0, amp = 0.1, pan = 0, spread = 0.5, atk = 0.001, rls = 0.2, sustain = 1, mul1 = 1, mul2 = 40, mulTanh = 0.0001, modu1 = 100, modu2 = 300, rate1 = 0.6, rate2 = 0.06, smooth1 = 0.4, smooth2 = 0, gate = 1, doneAction = 2;
    var mod1, mod2, sin1, sin2, sig, sig1, sig2, sig3, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    mod1 = TRand.kr(1, 300, Impulse.kr(rate1));
    mod1 = Lag2.kr(mod1, smooth1);

    mod2 = TRand.kr(1, 300, Dust.kr(rate2));
    mod2 = Lag2.kr(mod2, smooth2);

    sin1 = SinOsc.ar(mod1).range(1,100) * mul1;
    sin2 = SinOsc.ar(mod2) * mul2;

    sig1 = gcd(sin1, sin2) % modu1;
    sig2 = lcm(sin1, sin2) % modu2;

    sig = tanh([sig1 * sig2, sin1 * sin2] * mulTanh);

    sig = Splay.ar(sig, spread) * env;
    sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\gcdDm4Gene, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, serSize = 27, start = 100, end = 0.1, rate1 = 10, mod2 = 300, mod3 = 101, dev1 = 0, dev2 = 2, add = 600, add1 = 61, mul1 = 43, gate = 1, doneAction = 2;
    var seq, envMod, src1, src2, src3, sig, sig1, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    seq = Dseq([Dser(\ser.kr(#[ 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77 ]), serSize)], inf);

    // envMod = XLine.kr(start, end, 100);

    envMod = LFTri.kr(0.005, -1).exprange(start, end);

    src1 = TDuty.ar(seq * envMod * SampleDur.ir);
    src2 = PulseCount.ar(Impulse.ar(rate1)) % mod2;
    src3 = PulseCount.ar(src1) % mod3;

    sig = gcd(src2, src3 + [0, 2]);
    sig1 = gcd(lcm(src2 + [dev1, dev2], src3),sig);

    sig = SinOsc.ar(sig * 443 + add) * 0.1;
    sig1 = SinOsc.ar(sig1 * mul1 + add1) * 0.4;

    sig = Pan2.ar(Limiter.ar(LPF.ar(HPF.ar(sig, 50) + sig1, 5000), 0.3) * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\gcdDm5Gene, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, serSize = 99, start = 10, end = 0.01, rate1 = 1, mod2 = 500, mod3 = 501, dev1 = 1, dev2 = 3, add = 400, add1 = 61, mul1 = 53, gate = 1, doneAction = 2;
    var seq, envMod, src1, src2, src3, sig, sig1, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    seq = Dseq([Dser(\ser.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99]), serSize)], inf);

    //envMod = XLine.kr(start, end, 100);

    envMod = LFTri.kr(0.005, -1).exprange(start, end);

    src1 = TDuty.ar(seq * envMod * SampleDur.ir);
    src2 = PulseCount.ar(Impulse.ar(rate1)) % mod2;
    src3 = PulseCount.ar(src1) % mod3;

    sig = gcd(src2, src3 + [0, 2]);
    sig1 = gcd(lcm(src2 + [dev1, dev2], src3),sig);

    sig = SinOsc.ar(sig * 443 + add) * 0.1;
    sig1 = SinOsc.ar(sig1 * mul1 + add1) * 0.3;

    sig = Pan2.ar(Limiter.ar(LPF.ar(HPF.ar(sig, 50) + sig1, 5000), 0.3) * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\gcdDmFbGene, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, ser1Size = 4, ser2Size = 5, add1 = 50, add2 = 50.1, mod = 50, sinFmin = 70, div = 10, sigSel = 0, fbSel = 0, gate = 1, doneAction = 2;
    var seq1, seq2, src1, src2, count1, count2, in, sinFrq, sig, sig1, sig2, sig3, sig4, sig5, fb, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    seq1 = Dseq([Dser(\ser1.kr(#[0, 1, 2, 3]), ser1Size)], inf);
    seq2 = Dseq([Dser(\ser2.kr(#[4, 3, 2, 1, 0]), ser2Size)], inf);

    src1 = TDuty.ar(seq1 + add1 * SampleDur.ir);
    src2 = TDuty.ar(seq2 + add2 * SampleDur.ir);

    count1 = PulseCount.ar(src1) % mod;
    count2 = PulseCount.ar(src2) % mod;

    in = LocalIn.ar(2);
    sig1 = gcd(count1, count2 + [0, 1]);
    sinFrq = sig1.linexp(0, mod, sinFmin, 10000);
    sig2 = SinOsc.ar(sinFrq, 0, in / 2);
    sig3 = SinOsc.ar(sinFrq * (in / div + 1));
    sig4 = SinOsc.ar(sinFrq);
    sig5 = SinOsc.ar(sinFrq) + BPF.ar(in * 0.95, LFDNoise3.ar(0.2).range(100, 10000));

    sigSel = sigSel.min(3).max(0);
    sig = Select.ar(sigSel, [sig2, sig3, sig4, sig5]);

    fbSel = fbSel.min(3).max(0);
    fb = Select.ar(fbSel, [sinFrq.reverse, in.reverse, sig * in, sig]);
    LocalOut.ar(fb);

    sig = Pan2.ar(Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3) * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\factorFun, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, mod = 0.5, gate = 1, doneAction = 2;
    var sig, env, factorfunc, scaling, gcdoutput;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    scaling = gcd(\f1.kr(#[1, 1, 1, 1]).product, \f2.kr(#[1, 1, 1, 1]).product);

    factorfunc = {|factors|
        var fprod = factors.product;

        //either 1 or factor randomly over time
        factors.collect{|f| (ToggleFF.ar(Dust.ar(LFNoise0.kr(f).range(1, mod.linexp(0, 1, 16, 440)))) * (f-1)) + 1;
        };

    };

    gcdoutput = gcd(factorfunc.(\f1.kr).product,factorfunc.(\f2.kr).product) / scaling;

    sig = SinOsc.ar(mod.linlin(0, 1, 20, 2000) * gcdoutput) * 0.3;

    sig = Pan2.ar(sig * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

/*Pdef(
    \test,
    Pbind(
        \instrument, \factorFun,
        \dur, 2,
        \f1, [#[2,3,5,10]],
        \f2, [#[2,1,6]],
        \mod, Pseq([0.2, 0.8, 1, 0.3, 0.12], inf),
        \amp, 0.5
    )
).play;

Pdef(\test).stop;*/

SynthDef(\factorFun1, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, hiRange = 0.5, pmIdx = 0.2, sigSel = 0, gate = 1, doneAction = 2;
    var sig, sig1, sig2, sig3, env, factorfunc, scaling, scaling1, gcdoutput, lcmoutput, f3, f4;
    hiRange = hiRange.min(1).max(0);
    pmIdx = pmIdx.min(1).max(0);
    sigSel = sigSel.min(2).max(0);

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    scaling = gcd(\f1.kr(#[1, 1, 1, 1, 1, 1, 1]).product, \f2.kr(#[1, 1, 1, 1, 1]).product);
    scaling1 = lcm(\f1.kr.product, \f2.kr.product);

    factorfunc = {|factors|
        var fprod = factors.product;

        //either 1 or factor randomly over time
        factors.collect{|f| (ToggleFF.ar(Dust.ar(LFNoise0.kr(f).range(1, hiRange.linexp(0, 1, 1, 440)))) * (f-1)) + 1 };

    };

    f3 = factorfunc.(\f1.kr).product;
    f4 = factorfunc.(\f2.kr).product;

    gcdoutput = gcd(f3, f4) / scaling;
    lcmoutput = lcm(f3, f4) / scaling1;

    sig1 = SinOsc.ar(pmIdx.linlin(0, 1, 20, [2000, 4001]) * [gcdoutput, lcmoutput]);
    sig2 = SinOsc.ar(([gcdoutput, lcmoutput] * 2000) + (gcdoutput * pmIdx.linexp(0, 1, 0.1, 10) * SinOsc.ar(lcmoutput))) * 0.8;
    sig3 = PMOsc.ar(lcmoutput*[5000,5001], gcdoutput*[700,703], pmIdx.linlin(0, 1, 1, 10)) * 0.74;

    sig = Select.ar(sigSel, [sig1, sig2, sig3]);
    sig = Pan2.ar(sig * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

/*Pdef(
    \test,
    Pbind(
        \instrument, \factorFun1,
        \dur, 2,
        \f1, [#[2,2,2,3,5,7,11]],
        \f2, [#[2,2,3,7,13]],
        \pmIdx, Pseq([0.2, 0.8, 1, 0.3, 0.12], inf),
        \hiRange, Pseq([0.2, 0.8, 1.5, -5], inf),
        \sigSel, 0,
        \amp, 0.1
    )
).play;*/

// need this: s.options.memSize_(16384*10);
SynthDef(\modelBits, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, mod1 = 1, mod2 = 1, gate = 1, doneAction = 2;
    var sig, sig1, sig2, count1, count2, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    count1 = PulseCount.ar(Impulse.ar(8e3 * mod1));
    count2 = PulseCount.ar(Impulse.ar(7009 * mod2));

    sig1 = HPF.ar(
        (
            ((count1 * 15) & (count1 >> 5)) |
            ((count1 * 5) & (count1 >> [3, 4])) |
            ((count1 * 2) & (count1 >> 9)) |
            ((count1 * 8) & (count1 >> 11)) |
            (((count1 * count1) & count1) | (count1 >> 3))
            - 3 % 256
        ) / 127-1 * 3
        , 20
    ) * 0.1;

    sig2 = LPF.ar(HPF.ar(gcd(count1 * count2, count2 + count1), WhiteNoise.ar()*2000 + 1000), 20);
    sig2 = sig2 * sig1;
    sig = Splay.ar(Limiter.ar(Greyhole.ar(sig1 + sig2, sig1, 0.5, sig1), 0.5).flatten);
    sig = Pan2.ar(sig * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\ulysse42, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, mod1 = 0.2, mod2 = 0.71, gate = 1, doneAction = 2;
    var sig, sig1, sig2, sig3, z1, z2, sinFrq, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    mod1 = mod1.linlin(0, 1, -10, 10);
    sig1 = LFSaw.kr(0.062).range(-10, 10);
    sig1 = sig1 + (mod2.linlin(0, 1, 0, 5) * (0..8));
    sig2 = sig1.frac;
    sig3 = 0.8 - sig2.moddif(0.5, 1);

    z1 = gcd(sig1, mod1) + sig2;
    z2 = lcm(sig1, mod1) + sig2;
    sinFrq = 120 * ([z1, z2].flop.abs + 1);

    sig = (SinOsc.ar(sinFrq) * AmpComp.kr(sinFrq) * sig3).mean;
    sig = Pan2.ar(sig * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\dannySimple, { arg out = 0, amp = 0.2, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, add1 = 0, add2 = 0, div1 = 0.03, div2 = 5, rng1Lo = (-3), rng1Hi = 2, rng2Lo = (-2), rng2Hi = 3, gate = 1, doneAction = 2;
    var sig, sig1, sig2, env, thr, frq1, frq2;

    thr = 0.03;
    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    frq1 = \freq1.kr(#[5, 6, 7, 8]);
    frq2 = \freq2.kr(#[ 3, 4, 5, 6, 7 ]);

    sig1 = SinOsc.ar(frq1 + add1 / div1).range(rng1Lo, rng1Hi);
    sig2 = SinOsc.ar(frq2 + add2 / div2).range(rng2Lo, rng2Hi);

    sig = gcd(sig1.product.round(1), sig2.round(1));
    sig = Limiter.ar(LeakDC.ar(Splay.ar(sig)), thr).clip2(thr);
    sig = Pan2.ar(sig * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\dannySimple1, { arg out = 0, amp = 0.7, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, add1 = 970, add2 = 1030, div1 = 30, div2 = 30, rng1Lo = (-4), rng1Hi = 4, rng2Lo = (-4), rng2Hi = 4, gate = 1, doneAction = 2;
    var sig, sig1, sig2, env, thr, frq1, frq2;

    thr = 0.03;
    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    frq1 = \freq1.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);
    frq2 = \freq2.kr(#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);

    sig1 = SinOsc.ar(frq1 + add1 / div1).range(rng1Lo, rng1Hi);
    sig2 = SinOsc.ar(frq2 + add2 / div2).range(rng2Lo, rng2Hi);

    sig = gcd(sig1.product.round(1), sig2.round(1));
    sig = Limiter.ar(LeakDC.ar(Splay.ar(sig)), thr).clip2(thr);
    sig = Pan2.ar(sig * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\modelAix, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, revtSel = 0, gate = 1, doneAction = 2;
    var snd, revt, revt1, revt2, revt3, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    snd = Pulse.ar(freq: LFNoise0.ar([2,3]).exprange(50,5000));
    snd = snd * LFPulse.ar(
        freq: LFNoise0.ar(1).exprange(0.5,8),
        width:0.02,
        mul: LFNoise1.ar(3).exprange(0.01,1000));
    snd = HPF.ar(snd, 50);

    // reverb time - various optons:
    revt1 = LFNoise0.ar(1).exprange(0.0001, 0.01);
    revt2 = LFTri.ar(0.0165, -1).exprange(1, 0.0001);
    revt3 = LFTri.ar(1/10, 1).range(0.01, 0.0001);

    revt = Select.ar(revtSel, [revt1, revt2, revt3, K2A.ar(0.000001)]);
    snd = Greyhole.ar(snd, revt, 0.5, revt);
    snd = Limiter.ar(snd, 0.9);
    snd = Pan2.ar(snd * env, pan, amp);
    OffsetOut.ar(out, snd);
}).add;

SynthDef(\lcmnoise, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, spread = 1, gate = 1, doneAction = 2;
    var snd, revchain, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    snd = [
        tanh(
            lcm(
                SinOsc.ar(LFNoise0.kr(LFNoise0.kr(1/10).exprange(0.1,1)).exprange(1,15000)
                ).range(-100,100).round(1),
                SinOsc.ar(LFNoise0.kr(LFNoise0.kr(1/10).exprange(0.1,1)).exprange(1,15000)
                ).range(-100,100).round(1)
            )*0.0001
        ),
        tanh(
            lcm(
                Saw.ar(LFNoise0.kr(LFNoise0.kr(1/10).exprange(0.1,1)).exprange(1,15000)
                ).range(-100,100).round(1),
                LFCub.ar(LFNoise0.kr(LFNoise0.kr(1/10).exprange(0.1,1)).exprange(1,15000)
                ).range(-100,100).round(1)
            )*0.0001
        )
    ];

    snd = BHiPass.ar(snd, 180);
    snd = snd.softclip * 0.8;
    snd = Splay.ar(snd, spread: spread);
    revchain = snd * Lag.ar(
        LFPulse.ar(
            LFNoise0.ar(1).exprange(0.01,2),
            width:0.001
        ),
        0.1
    ) * LFNoise1.ar(1).range(10,10000);

    revchain = Greyhole.ar(
        in: revchain,
        delayTime: LFNoise1.ar(1).range(0.0001,0.2),
        damp: 0.5,
        size: LFNoise1.ar(0.1).exprange(0.0001,5),
        feedback: 0.95
    );
    revchain = LeakDC.ar(revchain);
    revchain = Limiter.ar(revchain) * LFNoise1.ar([1,1]).range(0,0.9);
    snd = snd * LFNoise0.ar([0.9,0.8]).range(0,2);
    snd = snd + revchain;
    //snd = Limiter.ar(snd, 0.7);
    snd = snd.softclip;
    snd = LPF.ar(snd, LFNoise1.ar(0.1).exprange(100,20000));
    snd = Pan2.ar(snd * env, pan, amp);
    OffsetOut.ar(out, snd);
}).add;

SynthDef(\gcdFunc, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, thr = 0.1, gate = 1, doneAction = 2;
    var sig, src, gcdFunc, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);

    gcdFunc = { |a| (a.size > 2).if { gcd(a[0], gcdFunc.(a.drop(1))) } { gcd(a[0], a[1]) } };

    src = { SinOsc.ar([40, 51], LFDNoise3.ar(0.05).range(0, 2pi)).range(-4, 4) } ! 4;
    sig = gcdFunc.(src);
    sig = Limiter.ar(LPF.ar(LeakDC.ar(Splay.ar(sig)), 10000), thr).clip2(thr);
    sig = Pan2.ar(sig * env, pan, amp);
    OffsetOut.ar(out, sig);
}).add;

SynthDef(\duryGene, { arg out = 0, amp = 0.1, atk = 0.001, rls = 0.2, sustain = 1, impFreq1 = 0.02, impFreq2 = 0.04, smooth1 = 4, smooth2 = 1.7, smooth3 = 0.9, gate = 1, doneAction = 2;
    var snd, rep, repCh, randNum, fac, fac1, fac2, fac3;

    rep = [4, 8, 16, 24, 32];
    repCh = TChoose.kr(Impulse.kr(impFreq1), rep);
    randNum = [

        54, 60, 66, 72, 81, 90, 96, 102,
        108, 128, 132, 144, 162, 180, 192, 204,
        216, 240, 264, 288, 324, 360, 384, 408,
        432, 480, 528, 576, 648, 720, 768, 816,
        864, 960, 1056, 1152, 1296, 1440, 1536, 1632,
        1728, 1920, 2112, 2304, 2592, 2880, 3072, 3264,
        3456, 3840, 4224, 4608, 5184, 5760, 6144, 6528,
        6912, 7680, 8448, 9216, 10368, 11520, 12288, 528

    ];
    fac = [1, 10, 100, 1000];
    fac1 = Lag2.kr(TChoose.kr(Impulse.kr(impFreq2), fac), smooth1);
    fac2 = Lag3.kr(TChoose.kr(Impulse.kr(impFreq1 * 0.76), fac), smooth2);
    fac3 = Lag2.kr(TChoose.kr(Impulse.kr(impFreq2 * 0.86), fac), smooth3);

    snd = Mix.fill(8, { arg i;
        var detune;
        var saw;
        var tri;
        var sig;
        detune = LFNoise1.kr(0.003 + Rand(0, 0.9)).range(0.1, 1 + Rand(0, 250.0)) * Rand(0, 2.0) * TChoose.kr(Impulse.kr(0), [1,-1]);
        tri = LFTri.ar(TChoose.kr(Impulse.kr(0), randNum) * ( 1 + ( SinOsc.ar(TChoose.kr(Impulse.kr(0), randNum) / fac1) * TChoose.kr(Impulse.kr(0), randNum) / fac2 )) + detune, Rand(0, 1)/*, 0.25*/);
        saw = RLPF.ar(Saw.ar(TChoose.kr(Impulse.kr(0), randNum) * 0.01 + detune, 0.75), TChoose.kr(Impulse.kr(0), randNum), Rand(0, 2));
        saw = TChoose.kr(Impulse.kr(0), [
            saw,
            saw.fold2( SinOsc.ar(TChoose.kr(Impulse.kr(0), randNum) / fac3).range(0.1, 1) ),
            saw.wrap2( SinOsc.ar(TChoose.kr(Impulse.kr(0), randNum) / fac3).range(0.1, 1) ),
            saw *  SinOsc.ar(TChoose.kr(Impulse.kr(0), randNum) / 2),
            ( saw *  SinOsc.ar(TChoose.kr(Impulse.kr(0), randNum) / fac3).range(1, 20) ).tanh / 2
        ]);
        sig = (tri + saw) * EnvGen.kr(Env.asr(rrand(4,20), 1, 1/repCh), gate, doneAction: doneAction);
        sig = Limiter.ar(sig * 1/(i + 0.1));
        sig = Pan2.ar(sig, Rand(-1, 1));
    });

    OffsetOut.ar(out, snd * amp);
}).add;

SynthDef(\west, {
	arg out = 0, pan=0, fadeIn=0.01, fadeOut=0.01, freq = 220, pitchBendRatio = 1, glide = 0, fm1Ratio = 0.66, fm2Ratio = 3.3, fm1Amount = 0.0, fm2Amount = 0.0,
	vel = 0.7, pressure = 0, timbre = 0, waveShape = 0, waveFolds = 0, envType = 0, attack = 0.04, peak = 10000, decay = 1, amp = 1, lfoShape = 0, lfoFreq = 0.5,
	lfoToFreqAmount = 0, lfoToWaveShapeAmount = 0, lfoToWaveFoldsAmount = 0, lfoToFm1Amount = 0, lfoToFm2Amount = 0,
	lfoToAttackAmount = 0, lfoToPeakAmount = 0, lfoToDecayAmount = 0, lfoToReverbMixAmount = 0, drift = 0, dur=10, t_gate=1, gate=1, killGate=1, doneAction = 2;

	var i_nyquist = SampleRate.ir * 0.5, signal, controlLag = 0.005, i_numHarmonics = 44,
	modFreq, mod1, mod2, mod1Index, mod2Index, mod1Freq, mod2Freq, sinOsc, triOsc, additiveOsc, additivePhase,
	filterEnvVel, filterEnvLow, lpgEnvelope, lpgSignal, asrEnvelope, asrFilterFreq, asrSignal, killEnvelope, i_driftRate = 0.15, maxDecay=8;

	// Make lfos
	var lfo = Select.kr(lfoShape, [
		LFTri.kr(lfoFreq),
		LFSaw.kr(lfoFreq),
		LFPulse.kr(lfoFreq),
		LFDNoise0.kr(lfoFreq * 2)
	]);

	var lfoArray = Array.fill(9, 0);
	lfoArray[0] = (lfo * lfoToFreqAmount * 18).midiratio; // Freq ratio
	lfoArray[1] = (lfo * lfoToWaveShapeAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift); // Wave Shape
	lfoArray[2] = ((lfo * lfoToWaveFoldsAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 2; // Wave Folds
	lfoArray[3] = ((lfo * lfoToFm1Amount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 0.5; // FM1 Amount
	lfoArray[4] = ((lfo * lfoToFm2Amount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 0.5; // FM2 Amount
	lfoArray[5] = ((lfo * lfoToAttackAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 2.2; // Attack
	lfoArray[6] = (((lfo * lfoToPeakAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 24).midiratio; // Peak multiplier
	lfoArray[7] = ((lfo * lfoToDecayAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift)) * 2.2; // Decay
	lfoArray[8] = (lfo * lfoToReverbMixAmount) + LFNoise1.kr(freq: i_driftRate, mul: drift); // Reverb Mix


	// LFO ins
	freq = (freq * lfoArray[0]).clip(0, i_nyquist);
	waveShape = (waveShape + lfoArray[1]).clip(0, 1);
	waveFolds = (waveFolds + lfoArray[2]).clip(0, 3);
	fm1Amount = (fm1Amount + lfoArray[3]).clip(0, 1);
	fm2Amount = (fm2Amount + lfoArray[4]).clip(0, 1);
	attack = (attack + lfoArray[5]).clip(0.003, 8);
	peak = (peak * lfoArray[6]).clip(100, 10000);
	decay = (decay + lfoArray[7]).clip(0.01, maxDecay);

	// Lag inputs
	freq = Lag.kr(freq * pitchBendRatio, 0.007 + glide);
	fm1Ratio = Lag.kr(fm1Ratio, controlLag);
	fm2Ratio = Lag.kr(fm2Ratio, controlLag);
	fm1Amount = Lag.kr(fm1Amount.squared, controlLag);
	fm2Amount = Lag.kr(fm2Amount.squared, controlLag);

	vel = Lag.kr(vel, controlLag);
	waveShape = Lag.kr(waveShape, controlLag);
	waveFolds = Lag.kr(waveFolds, controlLag);
	attack = Lag.kr(attack, controlLag);
	peak = Lag.kr(peak, controlLag);
	decay = Lag.kr(decay, controlLag);

	// Modulators
	mod1Index = fm1Amount * 22;
	mod1Freq = freq * fm1Ratio * LFNoise2.kr(freq: 0.1, mul: 0.001, add: 1);
	mod1 = SinOsc.ar(freq: mod1Freq, phase: 0, mul: mod1Index * mod1Freq, add: 0);
	mod2Index = fm2Amount * 12;
	mod2Freq = freq * fm2Ratio * LFNoise2.kr(freq: 0.1, mul: 0.005, add: 1);
	mod2 = SinOsc.ar(freq: mod2Freq, phase: 0, mul: mod2Index * mod2Freq, add: 0);
	modFreq = freq + mod1 + mod2;

	// Sine and triangle
	sinOsc = SinOsc.ar(freq: modFreq, phase: 0, mul: 0.5);
	triOsc = VarSaw.ar(freq: modFreq, iphase: 0, width: 0.5, mul: 0.5);

	// Additive square and saw
	additivePhase = LFSaw.ar(freq: modFreq, iphase: 1, mul: pi, add: pi);
	additiveOsc = Mix.fill(i_numHarmonics, {
		arg index;
		var harmonic, harmonicFreq, harmonicCutoff, attenuation;

		harmonic = index + 1;
		harmonicFreq = freq * harmonic;
		harmonicCutoff = i_nyquist - harmonicFreq;

		// Attenuate harmonics that will go over nyquist once FM is applied
		attenuation = Select.kr(index, [1, // Save the fundamental
			(harmonicCutoff - (harmonicFreq * 0.25) - harmonicFreq).expexp(0.000001, harmonicFreq * 0.5, 0.000001, 1)]);

		(sin(additivePhase * harmonic % 2pi) / harmonic) * attenuation * (harmonic % 2 + waveShape.linlin(0.666666, 1, 0, 1)).min(1);
	}
	);

	// Mix carriers
	signal = LinSelectX.ar(waveShape * 3, [sinOsc, triOsc, additiveOsc]);

	// Fold
	signal = Fold.ar(in: signal * (1 + (timbre * 0.5) + (waveFolds * 2)), lo: -0.5, hi: 0.5);

	// Hack away some aliasing
	signal = LPF.ar(in: signal, freq: 12000);

	// Noise
	signal = signal + PinkNoise.ar(mul: 0.003);

	// LPG
	filterEnvVel = vel.linlin(0, 1, 0.5, 1);
	filterEnvLow = (peak * filterEnvVel).min(300);

	lpgEnvelope = EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [0.003, decay], curve: [4, -20]), gate: t_gate, timeScale: dur);
	lpgSignal = RLPF.ar(in: signal, freq: lpgEnvelope.linlin(0, 1, filterEnvLow, peak * filterEnvVel), rq: 0.9);
	lpgSignal = lpgSignal * EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [0.002, decay], curve: [4, -10]), gate: t_gate, timeScale: dur);

	// ASR with 4-pole filter
	asrEnvelope = EnvGen.ar(envelope: Env.new(levels: [0, 1, 0], times: [attack, decay], curve: -4, releaseNode: 1), gate: gate);
	asrFilterFreq = asrEnvelope.linlin(0, 1, filterEnvLow, peak * filterEnvVel);
	asrSignal = RLPF.ar(in: signal, freq: asrFilterFreq, rq: 0.95);
	asrSignal = RLPF.ar(in: asrSignal, freq: asrFilterFreq, rq: 0.95);
	asrSignal = asrSignal * EnvGen.ar(envelope: Env.asr(attackTime: attack, sustainLevel: 1, releaseTime: decay, curve: -4), gate: gate);

	signal = Select.ar(envType, [lpgSignal, asrSignal]);

	signal = signal * vel.linlin(0, 1, 0.2, 1) ;

	// Saturation amp
	signal = tanh(signal * pressure.linlin(0, 1, 1.5, 3) * amp).softclip;

	// main Envelope
	signal = signal * EnvGen.kr(
		Env([0.0,1.0,1.0,0], [fadeIn, fadeOut], releaseNode: 2),
		gate: killGate,
		doneAction: doneAction
	);

	// Pan
	signal = Pan2.ar(signal, pan);

	OffsetOut.ar(out, signal);

}).add;

)