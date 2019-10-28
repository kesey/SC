Server.default = s = Server.local = Server.scsynth;
o = ServerOptions.new; // get devices on Windows
o.device;
// s.options.devices; // list avalaible audio devices MacOS only

// s.options.inDevice_("Built-in Microph");
// s.options.outDevice_("Built-in Output");
s.options.device_("name your sound card");
// s.options.numInputBusChannels_(8);
s.options.numOutputBusChannels_(2);

(
{
	var freq;
	// freq = MouseX.kr(20,20000).poll;
	// freq = LFTri.kr(0.0005, 0, 20000, 20).poll;
	// freq = Line.kr(20, 20000, 10).poll; // UP
	// freq = Line.kr(20000, 20, 10).poll; // DOWN
	SinOsc.ar(freq!2, 0, 1);
}.play;
)

{ LFTri.kr(0.005, 0, 20000, 20) }.plot(100);

{ WhiteNoise.ar() }.play;