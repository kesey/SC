(

MIDIClient.init;
MIDIIn.connectAll;

MIDIFunc.cc({ arg val, num, chan, src;
	val.debug("value");
	num.debug("numero");
	chan.debug("channel");
	src.debug("source");
});
)

MIDIFunc.trace;