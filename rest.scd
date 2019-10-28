(
// visualize stream
var a;
a = Pseries(4, Prand(#[-1, 1], inf), 10);
a = a.asStream;
a.nextN(20);
)

(
// general set up
// 1. midi config
MIDIClient.init;
//MIDIClient.sources; // list avalaible midi sources
MIDIIn.connectAll;
//MIDIClient.destinations; // list avalaible midi destinations
//MIDIOut.connect; // MacOS does not need to connect

// 2. server config
s = Server.local;
//s.options.devices; // list avalaible audio devices MacOS only
s.options.outDevice_("Built-in Output");
s.options.inDevice_("Built-in Microph");
s.options.numOutputBusChannels_(8);
s.options.numInputBusChannels_(8);
//s.options.memSize_(2.pow(20));
s.serverRunning.not.if({ s.boot });

s.meter; // level meter
s.plotTree; // node tree
)

