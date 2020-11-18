"2Mo_Start.scd".loadRelative; // execute me first

///////////////////////////////////////  Live

/////////////////////  Transport

///////////  Sequencer + Song transport

~song1_2Mo.value; // recall Fx + Synth values

( // Play Both
/*~globalQuant = 1; // !!! change globalQuant before song !!!
Tdef(\song, ~defaultSong).play(t, true, ~globalQuant);*/

/*~globalQuant = 4; // !!! change globalQuant before song !!!
Tdef(\song, ~song2).play(t, true, ~globalQuant);*/

/*~globalQuant = 7; // !!! change globalQuant before song !!!
Tdef(\song, ~song3).play(t, true, ~globalQuant);*/

/*~globalQuant = 5; // !!! change globalQuant before song !!!
Tdef(\song, ~song4).play(t, true, ~globalQuant);*/

~globalQuant = 7; // !!! change globalQuant before song !!!
Tdef(\song, ~song5).play(t, true, ~globalQuant);

/*~globalQuant = 5; // !!! change globalQuant before song !!!
Tdef(\song, ~song6).play(t, true, ~globalQuant);*/

/*~globalQuant = 7; // !!! change globalQuant before song !!!
Tdef(\song, ~song7).play(t, true, ~globalQuant);*/

/*~globalQuant = 7; // !!! change globalQuant before song !!!
Tdef(\song, ~song8).play(t, true, ~globalQuant);*/

/*~globalQuant = 9; // !!! change globalQuant before song !!!
Tdef(\song, ~song8Bis).play(t, true, ~globalQuant);*/

/*~globalQuant = 5; // !!! change globalQuant before song !!!
Tdef(\song, ~song9).play(t, true, ~globalQuant);*/

/*~globalQuant = 7; // !!! change globalQuant before song !!!
Tdef(\song, ~song10).play(t, true, ~globalQuant);*/

if (~sequencerTransport.isPlaying.not, { ~sequencerTransport = p.play(t, quant: ~globalQuant); });
)

( // Stop Both
Tdef(\song).stop;
~sequencerTransport.stop;
)

( // Reset Both
Tdef(\song).reset;
~sequencerTransport.reset;
~resetPdefView.value;
)

///////////  Song transport

(
~globalQuant = 4; // !!! change globalQuant before song !!!
Tdef(\song, ~song2).play(t, true, ~globalQuant); // Play Song
)

Tdef(\song).pause;
Tdef(\song).resume(t, ~globalQuant);

Tdef(\song).stop;
Tdef(\song).reset;

///////////  Sequencer transport

if (~sequencerTransport.isPlaying.not, { ~sequencerTransport = p.play(t, quant: ~globalQuant); }); // Play Sequencer

~sequencerTransport.stop; // Stop Sequencer

( // Reset Sequencer
~sequencerTransport.reset;
~resetPdefView.value;
)

///////////////////////////////////////  Playground

Pbindef(\unit4, \dur, Pseq([1, 1.25, Rest(1), 1.5, Rest(2)], inf)).quant_(~globalQuant);
~changePattern.value(Pdef(\unit1), ~defaultPattern1);

~samplerStereo.set(\out, ~channelBus[0]);

(

/*h = Signal.newClear(1025).waveFill({
	arg x, old, i;
	sin(x);
}, -pi/2, pi/2);
h = h.waveFill({
	arg x, old, i;
	old * ((cos(x * 0.08) / 4) + 0.3);
}, 0, 50pi).normalize;
h = h.asWavetableNoWrap;*/

/*h = Env([-1,1], [1], [0]).asSignal(1025);
h = h + (Signal.sineFill(
	1025,
	(0!3) ++ [0, 0, 0, 1, 1, 1].scramble,
	{ rrand(0, 2pi) }!9
))/4;
h = h.normalize;
h = h.asWavetableNoWrap;*/

// h = Buffer.alloc(s, 1024, 1);
// h.cheby({ rrand(0, 1.0) }!rrand(3, 16));

// h.sine3({ rrand(20, 2000) }!6, { rrand(0, 1.0) }!6, { rrand(pi, 8*pi) }!6);

// h.sine2({ rrand(20, 2000) }!6, { rrand(0, 1.0) }!6);

// h.sine1({ rrand(0, 1.0) }!7);

h.cheby([1, 0.5, 1, 0.125]); // default values

h.plot;

~waveShape.set(\shaperbuf, h);

)