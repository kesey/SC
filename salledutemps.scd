(
fork{
  loop{
    play{
     Splay.ar(
{Klank.ar(`[99.rand*(1..9)],Crackle.ar(2,0.01))*LFGauss.ar(9,1/4,0,0,2)}!2
     )
    };
    1.wait;
  }
};// ‪#endlessRogerCormanmovie‬/
)

(
SynthDef(\corman, { arg out = 0, amp = 1, tu = 1, dur = 9, attack = 1, release = 10, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = {DynKlank.ar(`[(tu * Demand.kr(Impulse.kr(0), 0, Diwhite(0, 98)))*(1..9)],Crackle.ar(2,0.01))*LFGauss.ar(dur,0.7,0,1)}!2;
	sig = sig * env;
	sig = Splay.ar(sig);
	OffsetOut.ar(out, sig * amp);
}).add;
)

g = Synth(\corman);
g.set(\gate, 0);

(
Pbind(
	\instrument, \corman,
	\dur, 5,
	\tu, 2
).play;
)

(
fork{
  loop{
    play{
     Splay.ar(
       //{Klank.ar(`[99.rand*(1..9)],Crackle.ar(2,0.01))*LFGauss.ar(9,1/4,0,0,2)}!2;
       //{Klank.ar(`[13.rand*(55/4)*(1..8)],Crackle.ar(2,0.005))*LFGauss.ar(9,1/4,0,0,2)}!3;
       //{Klank.ar(`[12.rand+1*(55/4)*(1..8)],Crackle.ar(2,0.005))*LFGauss.ar(9,1/4,0,0,2)}!3; // no zapguns
 {Klank.ar(`[((55/2)+(7.rand*2*(55/24)))*(2**(0..8))],Crackle.ar(2,0.005))*LFGauss.ar(9,1/4,0,0,2)}!5
     )
    };
    1.wait;
  }
};
)

(
SynthDef(\salledutemps1, { arg out = 0, amp = 1, tu = 1, dur = 9, myst = 55, attack = 1, release = 4, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = {DynKlank.ar(`[((myst/2)+ (tu * (Demand.kr(Impulse.kr(0), 0, Diwhite(0, 6))*2*(myst/24))))*(2**(0..8))],Crackle.ar(2, 0.005))*LFGauss.ar(dur,0.7,0,1)}!5;
	sig = sig * env;
	sig = Splay.ar(sig);
	OffsetOut.ar(out, sig * amp);
}).add;
)

g = Synth(\salledutemps);
g.set(\gate, 0);

(
Pbind(
	\instrument, \salledutemps,
	\dur, 5,
	\tu, 2,
	\myst, 55
).play;
)



(
fork {
	loop {
		Synth(\salledutemps, [\amp, 5]);
		1.wait;
	};
}.play
)