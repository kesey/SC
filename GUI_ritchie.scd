(
SynthDef.new(\simplebpf, {
	arg freq = 440, rq = 0.2;
	var sig;
	sig = PinkNoise.ar(1!2);
	sig = BPF.ar(sig, freq.lag(0.5), rq.lag(0.5), 1/rq.sqrt.lag(0.5));
	Out.ar(0, sig);
}).add
)

(
Window.closeAll;
w = Window
		.new("guiritchie", Rect.new(750,50,500,200))
		.front
		.alwaysOnTop_(true);

~slider = Slider
			.new(w.view, Rect.new(20,20,150,30))
			.background_(Color(0.3,1,0.6))
			.action_({
				arg obj;
				var cf;
				cf = obj.value.linexp(0,1,100,4000).postln;
				if(
					x.isPlaying,
					{x.set(\freq, cf);}
				);
				~numberBox.value_(obj.value.linexp(0,1,100,4000))
			});

~numberBox = NumberBox(w, Rect(180,20,80,30))
				.value_(100)
				.clipLo_(100)
				.clipHi_(4000)
				.font_(Font("Monaco", 16))
				.decimals_(2)
				.action_({
					arg obj;
					~slider.valueAction_(obj.value.explin(100,4000,0,1));
				});

~knob = Knob(w, Rect(270,20,30,30))
			.action_({
				arg obj;
				var qual;
				qual = obj.value.linexp(0,1,1,100).reciprocal;
				if(
					x.isPlaying,
					{x.set(\rq, qual);}
				);
			});

~button = Button(w, Rect(430,20,50,30))
			.states_([
				["OFF", Color.black, Color.gray(0.8)],
				["ON", Color.blue, Color(0.3,1,0.6)]
			])
			.action_({
				arg obj;
				if(
					obj.value == 1,
					{
						x = Synth.new(
								\simplebpf,
								[
									\freq, ~slider.value.linexp(0,1,100,4000),
									\rq, ~knob.value.linexp(0,1,1,100).reciprocal;
								]
						).register;
					},
					{x.free}
				)
			});

~lev = LevelIndicator(w, Rect(20,80,20,80))
			.warning_(0.6)
			.critical_(0.8);
)

~lev.value = 0.7;