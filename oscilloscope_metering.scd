( // a custom dual oscilloscope
Server.default = Server.internal;
Server.default.waitForBoot({
// make internal the default server
var waveScope, phaseScope; // the two scopes
// allocate two audio buffers
var bufferA = Buffer.alloc(Server.default, 1024,2);
var bufferB = Buffer.alloc(Server.default, 1024,2);
// a stereo signal
var sound = {
var signal = Resonz.ar(
[ ClipNoise.ar(1.7), ClipNoise.ar(1.8) ],
SinOsc.ar(1000).range(100,500)); // a stereo signal
ScopeOut.ar(signal, bufferA); // update first buffer
ScopeOut.ar(signal, bufferB); // update second buffer
Out.ar(0,signal); // write to output
}.play;
// create the main Window
var window = Window("Dual Oscilloscope", 640@320).front
.onClose_({ // on close stop sound and free buffers
		sound.free;
bufferA.free;
bufferB.free;
});
window.addFlowLayout; // add a flowLayout to the window
// create the ScopeViews and set their buffers
waveScope = ScopeView(window,314@310).bufnum_(bufferA.bufnum);
phaseScope = ScopeView(window,314@310).bufnum_(bufferB.bufnum);
// customize waveScope
waveScope.style_(1)
// overlay channels
.waveColors_([Color.red,
Color.yellow]).background_(Color.magenta(0.4))
.xZoom_(1.7).yZoom_(1.2);
// scaling factors
// customize phaseScope
phaseScope.style_(2)
// lissajous mode
.waveColors_([Color.magenta]).background_(Color.cyan(0.3))
.xZoom_(1.2).yZoom_(1.2);
// scaling factors
})
)


( // a custom Frequency Analyzer
Server.default = Server.local; // set local as the default server
Server.default.waitForBoot({
// create the parent window
var window = Window("Frequency Analyzer", 640@480).front
.onClose_({ // on close
sound.free; // stop sound
scope.kill; // kill the analyzer
});
// the bus to scope
var bus = Bus.audio(Server.default,2);
// a stereo signal
var sound = {
var signal = Resonz.ar(
[ ClipNoise.ar(1.7), ClipNoise.ar(1.8) ],
SinOsc.ar(1000).range(100,500)); // a stereo signal
Out.ar(bus,signal); // update bus for scoping
Out.ar(0,signal);
// write to output
}.play;
	// the frequency scope
var scope = FreqScopeView(window,640@480).active_(true);
// activate it
scope.background_(Color.red).waveColors_([Color.yellow]);
// set colors
scope.dbRange_(120); // set amplitude range (in decibels)
scope.inBus_(bus); // select Bus to scope
})
)


( // Simple Level Metering
Server.default.waitForBoot({
// create the parent window
var window = Window.new("Level Metering", Rect(200,400,60,220)).
front
	.onClose_({
// stop routine when the window is closed
updateIndicator.stop;
sound.free;
});
var bus = Bus.control();
	 // create a Bus to store amplitude data
// an audio signal
var sound = {
var sound = WhiteNoise.ar(Demand.kr
(Dust.kr(20),0,Dbrown(0,1,0.3)));
var amp = Amplitude.kr(sound); // track the signal's amplitude
Out.kr(bus, amp); // write amplitude data to control bus
Out.ar(0,sound);
// write sound to output bus
}.play;
// create and customize Indicator
var indicator = LevelIndicator(window,Rect(10,10,40,200))
.warning_(0.5)
// set warning level
.critical_(0.7)
// set critical level
.background_(Color.cyan) // set Color
.numTicks_(12)
// set number of measurement lines
.numMajorTicks_(3)
// set number of major measurement lines
.drawsPeak_(true);
// draw Peak Values
// update the Indicator's value with a routine
var updateIndicator = fork{loop{
bus.get({
// get current value from the bus
arg value;
{indicator.value_(value);
// set Indicator's value
indicator.peakLevel_(value); // set Indicator's peak value
}.defer(); // schedule in the AppClock
});
0.01.wait; // indicator will be updated every 0.01 seconds
}};
});
)


( // Monitoring a complex numerical Dataset
var indicators, updateIndicators;
var index = 0; // a global index used to iterate through the dataset
var dataset = Array.fill(8,{Array.fill(1000,{rrand(0,1.0)})});
// a multi-dimensional dataset
// create window
var window = Window.new("Monitoring a complex numerical dataset",
360@210).front.onClose_({ updateIndicators.stop });
window.addFlowLayout; // add flowLayout
// create and customize 8 Level indicators
indicators = Array.fill(8, {LevelIndicator(window,40@200)});
indicators.do { arg item;
item.warning_(0.8).critical_(0.9).background_(Color.cyan).drawsPeak_
(true);
};
// update the indicators with a routine
updateIndicators = fork{loop{
indicators.do{ arg item, i; {
var value = dataset[i][index]; // read value from the dataset
item.value_(value);
// set each Indicator's value
item.peakLevel_(value);
// set each Indicator's peak value
}.defer(); // schedule in the AppClock
};
// increment index or set to 0 if it has exceeded dataset's size
if ( index < 1000) {index = index + 1;} {index = 0; };
0.1.wait; // indicators will be updated every 0.1 seconds
}};
)

(  // A non-standard visualizer
var sliders, updateSliders;
var index = 0;  // a global index used to iterate through the dataset
var dataset = Array.fill(8,{Array.fill(1000,{rrand(0,1.0)})}); // a multi-dimensional dataset

// create window
var window = Window.new("Monitoring a complex numerical dataset", 360@210).front.onClose_({ updateSliders.stop});
window.addFlowLayout; // add flowLayout

// create and customize 8 RangeSliders
sliders = Array.fill(8, {RangeSlider(window,40@200)});
sliders.do { arg item;
	item.background_(Color.cyan); // set background Color
	item.knobColor_(Color.green); // set knob color
};

updateSliders = fork{loop{
	sliders.do{ arg item, i; {
		var value;
		// store current and previous values in an array and sort it so that the smaller number is always the first
		value = [dataset[i][index-1], dataset[i][index]].sort;
		// set each RangeSlider's value
		item.setSpan(value[0],value[1]);
	}.defer();
	};
	if ( index < 1000) {index = index + 1;} {index = 0; }; // increment
	0.1.wait; // sliders will be updated every 0.1 seconds
}};
)

a=1@2;f=1;w=Window().front.drawHook_({900.do{Pen.line(a*200,(a=(a*(f=f+2e-6)).y.cos+1@a.x)*200)};Pen.stroke});AppClock.play{w.refresh;0.01} // by Andrea Valle