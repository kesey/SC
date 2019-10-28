( // general set up

////////////////////////////////// 1. server config

// Server.supernova; // Switches the server program to supernova. Check ParGroup how to make use of multicore hardware with the supernova server.
// Server.scsynth; // This is the default server
Server.default = s = Server.local = Server.scsynth;
/********Multi-Client Setups***********/
// s.addr = NetAddr("168.192.1.20", 57110); // in case of distant server, args are IP and port number
// s.options.maxLogins = 2; // 2 users on the same server
/**************************************/
// s.options.devices; // list avalaible audio devices MacOS only
// o = ServerOptions.new; // get devices on Windows
// o.device;
s.options.inDevice_("Built-in Microph");
s.options.outDevice_("Built-in Output");
// s.options.device_("name your sound card");
s.options.numInputBusChannels_(8);
s.options.numOutputBusChannels_(8);

// s.options.memSize_(2.pow(20)); // real time memory size (used by delay like CombN)
s.newBusAllocators;

////////////////////////////////// 2. OSC config

//NetAddr.localAddr; // retrieve the current IP and port
//OSCFunc.trace(true); // Turn posting on
//OSCFunc.trace(false); // Turn posting off

////////////////////////////////// 3. midi config

MIDIClient.init; // post a list of available devices
// MIDIClient.sources; // list avalaible midi sources
// MIDIIn.connect(0, MIDIClient.sources[0]); // connect on first port with first device equivalent to MIDIIn.connect
MIDIIn.connectAll; // connect to all attached input sources
// MIDIClient.destinations; // list avalaible midi destinations
// ~midiOut = MIDIOut(0).latency_(Server.default.latency); //quick way to access device 0, port 0

////////////////////////////////// 4. boot

s.serverRunning.not.if({ s.boot });
s.meter; // level meter
s.plotTree; // node tree
ServerBoot.removeAll;
ServerTree.removeAll;
ServerQuit.removeAll;

// s.options.dump; // visualise server options
// GUI.current; // Test which GUI library you are using by default
)

(
////////////////////////////////// 5. initialize global variables
~out = 0;
~path = PathName(thisProcess.nowExecutingPath).parentPath;

////////////////////////////////// 6. define specific functions
~makeBuffers = {
	b = Dictionary.new;
	PathName(~path ++ "Audio").entries.do{
		arg subfolder;
		b.add(
			subfolder.folderName.asSymbol ->
			Array.fill(
				subfolder.entries.size,
				{
					arg i;
					Buffer.read(s, subfolder.entries[i].fullPath);
				}
			)
		);
	};
};
// b[\airplane_cards][0].play; // use it in a SynthDef like this: s.bind { Synth(\sampler, [\out, 0, \buffer, b]) };

~cleanup = {
	s.newBusAllocators;
	ServerBoot.removeAll;
	ServerTree.removeAll;
	ServerQuit.removeAll;
};

~startRec = {
	s.recChannels = 2;
	s.recSampleFormat = "int24"; // 24 bit
	s.recHeaderFormat = "aiff";
	s.prepareForRecord("~/path/name/session.wav");
	// thisProcess.platform.recordingsDir; // verify your recording dir
	s.record;
};

~stopRec = {
	s.stopRecording;
};

////////////////////////////////// 7. register functions with ServerBoot/Quit/Tree
ServerBoot.add(~makeBuffers, ~startRec);
ServerQuit.add(~cleanup, ~stopRec);
)

