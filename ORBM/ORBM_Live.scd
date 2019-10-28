this.executeFile(PathName(thisProcess.nowExecutingPath).parentPath ++ "ORBM_Start.scd"); // Execute Me First

///////////////////////////////////////  Live

///////////////////// Transport

/////////// Sequencer + Song transport

( // Play Both
/*~globalQuant = 1; // !!! change globalQuant before song !!! // length of the longest pattern
Tdef(\song, ~defaultSong).play(t, true, ~globalQuant);*/

/*~globalQuant = 4; // !!! change globalQuant before song !!!
Tdef(\song, ~song2).play(t, true, ~globalQuant);*/

/*~globalQuant = 7; // !!! change globalQuant before song !!!
Tdef(\song, ~song3).play(t, true, ~globalQuant);*/

/*~globalQuant = 5; // !!! change globalQuant before song !!!
Tdef(\song, ~song4).play(t, true, ~globalQuant);*/

/*~globalQuant = 7; // !!! change globalQuant before song !!!
Tdef(\song, ~song5).play(t, true, ~globalQuant);*/

~globalQuant = 5; // !!! change globalQuant before song !!!
Tdef(\song, ~song6).play(t, true, ~globalQuant);

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

/////////// Song transport

(
~globalQuant = 4; // !!! change globalQuant before song !!!
Tdef(\song, ~song2).play(t, true, ~globalQuant); // Play Song
)

Tdef(\song).pause;
Tdef(\song).resume(t, ~globalQuant);
Tdef(\song).stop;
Tdef(\song).reset;

/////////// Sequencer transport

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

Pdef(\unit1).source.mute;

)