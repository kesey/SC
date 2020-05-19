( // general set up

///////////////////////////////////////  Start

////////////////////////////////// 1. server config

// Server.supernova; // Switches the server program to supernova. Check ParGroup how to make use of multicore hardware with the supernova server.
Server.scsynth; // This is the default server
Server.default = s = Server.local;
Server.program = Server.program + "-B 127.0.0.1"; // fix network security issue in scsynth and supernova. Works with SC 3.8 and after, useful until 3.10.2
// s.makeWindow;
/********Multi-Client Setups***********/
// s.addr = NetAddr("168.192.1.20", 57110); // in case of distant server, args are IP and port number
// s.options.maxLogins = 2; // 2 users on the same server
/**************************************/
// ServerOptions.devices; // list avalaible audio devices MacOS only
// o = ServerOptions.new;
// o.device; // get devices on Windows
s.options.inDevice_("Fireface UCX (23732051)");
s.options.outDevice_("Fireface UCX (23732051)");
// s.options.device_("name your sound card");
s.options.numInputBusChannels_(3);
s.options.numOutputBusChannels_(4);

// o.memSize_(2.pow(20)); // real time memory size (used by delay like CombN)
s.options.memSize_(2.pow(20));
s.options.numBuffers = 1024 * 256;
s.options.maxNodes = 1024 * 32;

// rec options
s.options.recChannels = 2;
s.options.recSampleFormat = "int24"; // 24 bit
s.options.recHeaderFormat = "aiff";

// s.options.blockSize = 64;
s.options.dump; // visualise server options
// s.dumpOSC(1); // dump Osc On
// s.dumpOSC(0); // dump Osc Off

////////////////////////////////// 2. OSC config

// NetAddr.localAddr; // retrieve the current IP and port

// OSCFunc.trace(true); // dumps all incoming OSC messages
// OSCFunc.trace(false);

////////////////////////////////// 3. HID config

// HIDFunc.trace(true); // dumps all incoming HID messages
// HIDFunc.trace(false);

////////////////////////////////// 4. MIDI config

MIDIClient.initialized.not.if {
	MIDIClient.init; // post a list of available devices

	/*MIDIFunc.trace(true); // dumps all incoming MIDI messages
	MIDIFunc.trace(false);*/

	// MIDIIn.connectAll; // connect to all attached input sources
	// MIDIClient.sources; // list avalaible midi sources
	if (MIDIClient.sources[0].notNil, {
		MIDIIn.connect(0, MIDIClient.sources[0]); // connect on first port with first device equivalent to MIDIIn.connect
	});

	// MIDIClient.destinations; // list avalaible midi destinations
	if (MIDIClient.destinations[2].notNil, {
		~midiOut = MIDIOut.new(2).latency_(s.latency); // 2 for MIDIClient.destinations[2]
	});

};

////////////////////////////////// 5. initialize global variables

~path = PathName(thisProcess.nowExecutingPath).parentPath;
~globalQuant = 1; // length of the longest pattern
~globalQuant = ~globalQuant.max(0.0625); // avoid 0
~synthWindow = Dictionary.new;
~autoGuiControl = Dictionary.new;
~controlBus = Dictionary.new;
~active = Dictionary.new;
~firstTime = Dictionary.new;

~aux1Color = Color.new255(205, 205, 193);
~aux2Color = Color.new255(238, 238, 209);

t = TempoClock.default;
t.tempo = 60 / 60; // TempoClock by default in beat per seconds

////////////////////////////////// 6. define specific functions

"2Mo_Function.scd".loadRelative;

////////////////////////////////// 7. register functions with ServerBoot/Quit/Tree

ServerBoot.add(~initAllocators, s);

ServerQuit.add(~cleanup, s);

////////////////////////////////// 8. boot

s.serverRunning.not.if({ s.boot });

////////////////////////////////// 9. actions to perform once boot is completed

s.waitForBoot({
	if (~init.isNil, {
		"server boot complete".postln;
		// s.plotTree; // node tree

		~makeBuffers.value; // create and fill buffers with samples
		s.sync; // wait for previous action to be finish

		"2Mo_SynthDef_1.scd".loadRelative;
		s.sync;
		"2Mo_SynthDef_2.scd".loadRelative;
		s.sync;

		~dirt = SuperDirt(2, s);
		~dirt.loadSoundFiles;
		// ~dirt.postSampleInfo;
		s.sync;
		~dirt.start(57120, 0 ! 12);   // start listening on port 57120, create twelve stereo busses each sending audio to channel 0 & 1

		// Sync sclang to SuperDirt
		~syncSCtoSD.value(t, true);

		"2Mo_Routing.scd".loadRelative;
		s.sync;

		~pdefNumber = 8; // number of pdef or units
		~pdefNumber = ~pdefNumber.max(1).min(12); // limit number of pdef

		"2Mo_Gui.scd".loadRelative; // ~pdefNumber need to exist before executing ORBM_Gui.scd
		s.sync;

		~sequencer = Array.new(~pdefNumber);

		~pdefNumber.do({ // sequencer creation with pdefNumber of units
			arg i;
			var name;
			name = ("unit" ++ (i + 1)).asSymbol;
			~sequencer.add(
				Penvir(
					(pdefName: name, pdefPrevInstr: nil, pdefCcStart: 21, pdefMidiChan: i + 2, muteState: ~muteState),
					Pdef(name, ~initPattern)
				)
			);
		});

		p = Ppar(~sequencer, inf); // all units in parallel

		"2Mo_Pattern.scd".loadRelative; // Gui need to exist before executing ORBM_Pattern.scd
		s.sync;

		"2Mo_Song.scd".loadRelative; // Gui need to exist before executing ORBM_Song.scd
		s.sync;

		~init = true;
		"init complete".postln;
	});
});

////////////////////////////////// 10. utilities

// GUI.current; // Test which GUI library you are using by default
// UGen.browse; // another kind of documentation
// Class.browse;
// Help.gui; // open a dedicated help window
// Filter.dumpSubclassList; // <ClassName>.dumpSubClassList post all the class whose inherit from ClassName

// if you are posting a long list you might not get the whole list using .postln;
// for that use the following:
// Post << ~firstTime

)
