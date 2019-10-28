// MONO KICKS

(
SynthDef(\kick, {
	arg out=0,tu = 1,amp=1;
	var env0, env1, env1m, sig;
	env0 =  EnvGen.ar(Env.new([0.5, 1, 0.3, 0], [0.01, 0.5, 0.26], [-4, -2, -4]), doneAction:2);
	env1 = EnvGen.ar(Env.new([120, 43, 29], [0.03, 0.29], [-4, -5]));
	env1m = env1.midicps;
	sig = LFPulse.ar(env1m*tu, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(1);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m*tu, 0.5, env0*4);
	sig = sig * amp;
	sig = sig.clip2(1);
	Out.ar(out, sig);
}).add;

SynthDef(\sd, { | out=0, amp=1 |
	var osc1, osc2, env;
	osc1 = WhiteNoise.ar;
	osc2 = FSinOsc.ar(200);
	env = EnvGen.kr(Env.perc(0, 0.05), doneAction: 2);
	Out.ar(out, Pan2.ar(LPF.ar(Mix([osc1, osc2]), 12000), 0, env*amp));
}).add;

SynthDef(\hat, { | out=0, amp=1 |
	var osc1, env;
	osc1 = WhiteNoise.ar;
	env = EnvGen.kr(Env.perc(0, 0.01), doneAction: 2);
	Out.ar(out, Pan2.ar(osc1, 0, env*amp));

}).add;
)

(
n = 180;
t = TempoClock(n/60);
u = TempoClock(n*2/60);

~swingify = Prout({ |ev|
    var now, nextTime = 0, thisShouldSwing, nextShouldSwing = false, adjust;
    while { ev.notNil } {
        // current time is what was "next" last time
        now = nextTime;
        nextTime = now + ev.delta;
        thisShouldSwing = nextShouldSwing;
        nextShouldSwing = ((nextTime absdif: nextTime.round(ev[\swingBase])) <= (ev[\swingThreshold] ? 0)) and: {
            (nextTime / ev[\swingBase]).round.asInteger.odd
        };
        adjust = ev[\swingBase] * ev[\swingAmount];
        // an odd number here means we're on an off-beat
        if(thisShouldSwing) {
            ev[\timingOffset] = (ev[\timingOffset] ? 0) + adjust;
            // if next note will not swing, this note needs to be shortened
            if(nextShouldSwing.not) {
                ev[\sustain] = ev.use { ~sustain.value } - adjust;
            };
        } {
            // if next note will swing, this note needs to be lengthened
            if(nextShouldSwing) {
                ev[\sustain] = ev.use { ~sustain.value } + adjust;
            };
        };
        ev = ev.yield;
    };
});

Pdefn(\dur1, Pseq([1,0.5,2], inf));
Pdefn(\amp1, Pseq([1,0.15], inf));

Pdef(\kix,
	Pchain(
		~swingify,
		Pbind(
			\instrument, \kick,
			\tu, 1,
			\amp, Pdefn(\amp1),
			\dur, Pdefn(\dur1)
		),
		(swingBase: 0, swingAmount: 8, swingThreshold: 0.5)
	)
).play(t);

Pdef(\snares,
	Pbind(
		\instrument, \sd,
		\amp, 1, //Pseq([1,0.15], inf),
		\dur, 4 //Pseq([4,5], inf)
	)
).play(t);

Pdef(\hats,
	Pbind(
		\instrument, \hat,
		\amp, Pseq([1,0.15,1], inf),
		\dur, 0.25//,
		//\timingOffset, 2.5
	)
).play(t);

)

Pdef(\kix).quant_(82);
Pdef(\kix).play();
Pdef(\kix).stop;
Pdef(\snares).play(t);
Pdef(\snares).quant_(8);
Pdef(\snares).stop;
Pdef(\snares).play;
Pdef(\snares).pause;
Pdef(\snares).resume;
Pbindef(\snares,\dur,Pseq([2, 3], inf),\amp,2);


/*********************************************************test******************************************************************/

(
n = 180;
t = TempoClock(n/60);

~swingify = Prout({ |ev|
    var now, nextTime = 0, thisShouldSwing, nextShouldSwing = false, adjust;
    while { ev.notNil } {
        // current time is what was "next" last time
        now = nextTime;
        nextTime = now + ev.delta;
        thisShouldSwing = nextShouldSwing;
        nextShouldSwing = ((nextTime absdif: nextTime.round(ev[\swingBase])) <= (ev[\swingThreshold] ? 0)) and: {
            (nextTime / ev[\swingBase]).round.asInteger.odd
        };
        adjust = ev[\swingBase] * ev[\swingAmount];
        // an odd number here means we're on an off-beat
        if(thisShouldSwing) {
            ev[\timingOffset] = (ev[\timingOffset] ? 0) + adjust;
            // if next note will not swing, this note needs to be shortened
            if(nextShouldSwing.not) {
                ev[\sustain] = ev.use { ~sustain.value } - adjust;
            };
        } {
            // if next note will swing, this note needs to be lengthened
            if(nextShouldSwing) {
                ev[\sustain] = ev.use { ~sustain.value } + adjust;
            };
        };
        ev = ev.yield;
    };
});

Pdefn(\dur1, Pseq([1,0.5,2], inf));
Pdefn(\amp1, Pseq([1,0.15], inf));

p = Penvir((), Ptpar([
    0.0, Pdef(\kix,
		Pchain(
			~swingify,
			Pbind(
				\instrument, \kick,
				\tu, 1,
				\amp, Pdefn(\amp1),
				\dur, Pdefn(\dur1)
			),
			(swingBase: 0.4, swingAmount: 1.4, swingThreshold: 0.2)
		)
	).collect({ |event|
        ~lastKixEvent = event;
    }),
    0.1, Pdef(\snares,
		Pchain(
			~swingify,
		    Pbind(
				\instrument, \sd,
				\amp, Pdefn(\amp1),
				\dur, Pdefn(\dur1),
				\timingOffset, Pfunc({ ~lastKixEvent[\timingOffset] }),
				\sustain, Pfunc({ ~lastKixEvent[\sustain] })
			),
			(swingBase: 0.4, swingAmount: 0, swingThreshold: 0.2)
		)
	).collect({ |event|
        ~lastSnaresEvent = event;
    }),
	0.1, Pdef(\hats,
		Pchain(
			~swingify,
		    Pbind(
				\instrument, \hat,
				\amp, Pseq([1,0.15,1], inf),
				\dur, 0.25,
				\timingOffset, 0,
				\sustain, 1
			),
			(swingBase: 0.4, swingAmount: 0, swingThreshold: 0.2)
		)
	).collect({ |event|
        ~lastHatsEvent = event;
    })
])).play(t);
)

p.stop;