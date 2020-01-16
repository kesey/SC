(
// All ins and outs use two channels

// source synthdef
// take releaseTime = decayTime

SynthDef(\source, { |out = 0, freq = 400, decayTime = 0.5,
    attackTime = 0.005, amp = 0.1, gate = 1|
    var env, sig = Decay.ar(Impulse.ar(0), decayTime, Saw.ar(freq));
    env = EnvGen.ar(Env.asr(attackTime, amp, decayTime, \lin), gate, doneAction: 2);
    Out.ar(out, sig ! 2 * env)
}).add;

// spat fx
// This effect introduces a very small delay,
// in examples balancing by lag (as it obviously has to be done with echo) is neglected.

SynthDef(\spat, { |out, in, freq = 1, maxDelayTime = 0.005,
    amp = 1, mix = 1|
    var sig, inSig = In.ar(in, 2);
    sig = DelayC.ar(
        inSig,
        maxDelayTime,
        { LFDNoise3.ar(freq, maxDelayTime, maxDelayTime/2) } ! 2,
        amp
    );
    Out.ar(out, (1 - mix) * inSig + (sig * mix));
}).add;

// echo fx, always unified delay maxEchoDelta

SynthDef(\echo, { |out, in, maxEchoDelta = 0.2, echoDelta = 0.1,
    decayTime = 1, amp = 1, mix = 1|
    var sig, inSig = In.ar(in, 2);
    sig = DelayL.ar(
        CombL.ar(inSig, maxEchoDelta, echoDelta, decayTime, amp),
        maxEchoDelta,
        maxEchoDelta - echoDelta
    );
    Out.ar(out, (1 - mix) * inSig + (sig * mix));
}).add;

// reverb fx
// rough estimation: freeVerb's room arg = decayTime / 10

SynthDef(\reverb, { |out, in, damp = 0.5,
    decayTime = 10, amp = 1, mix = 1|
    var sig, inSig = In.ar(in, 2);
    Out.ar(out, FreeVerb.ar(inSig, mix, min(decayTime, 10) / 10, damp, amp));
}).add;

a = Bus.audio(s, 2);
b = Bus.audio(s, 2);

x = Synth(\reverb, [mix: 0.3, damp: 0.1, decayTime: 3, in: a]);
y = Synth(\reverb, [mix: 0.2, damp: 0.1, decayTime: 10, in: b]);

Pdef(\unit1,
	PbindFx([
        \instrument, \source,
        \dur, Pn(Pshuf(0.2!5 ++ Rest(0.2))),

        \midinote, Pseq((90, 80..40), inf) +
            Pn(Pshuf([[0, 5], 0, [0, 2.5], 0, [-2.5, 12.5], [-3, 0]])),

        \fxOrder, Pn(Pshuf([1, 2, [1,2]])),

        \lag, Pfunc { |e| e.fxOrder.asArray.includes(2).if { 0 }{ 0.2 } },
        \amp, Pfunc { |e| (e.fxOrder != [1,2]).if { 0.3 }{ 0.6 } },

        \decayTime, Pfunc { |e|
            rrand(0.3, 0.8) / (e.fxOrder.asArray.includes(2).if { 10 }{ 1 })
        },
        \cleanupDelay, Pkey(\decayTime),

        \out, b
    ],[
        \fx, \spat,
        \freq, Pn(Pshuf([1, 1, 1, 5, 20, 50])),
        \maxDelayTime, 0.005,
        \cleanupDelay, Pkey(\maxDelayTime)
    ],[
        \fx, \echo,
        \echoDelta, Pseq((1..5)/50, inf),
        \decayTime, Pwhite(0.3, 1.8),
        \cleanupDelay, Pkey(\decayTime)
    ])
);

q = Pdef(\unit1).play;
)

Pbindef(\unit1, \attackTime, 0.8);

/*~busKr = Bus.control(s, 1);
~busKr.set(2);
Pbindef(\unit1, \attackTime, ~busKr.asMap);*/
// stop

q.stop;

// free extra resources

[x, y, a, b].do(_.free);