/*(
SynthDef.new(\simplebpf, {
	arg freq = 440, rq = 0.2;
	var sig;
	sig = PinkNoise.ar(1!2);
	sig = BPF.ar(sig, freq.lag(0.5), rq.lag(0.5), 1/rq.sqrt.lag(0.5));
	Out.ar(0, sig);
}).add
)*/

(
Window.closeAll;

w = Window
.new("nested", Rect.new(750,50,500,500))
.front
.alwaysOnTop_(true);

w.view.decorator_(FlowLayout(w.bounds, 30@30, Point(30,30)));

c = Array.fill(4, {
	arg view;
		view = CompositeView(w, 200@200)
		.background_(Color.rand);

		view.decorator_(FlowLayout(view.bounds, 5@5, 5@5));
});

Array.fill(5, {Slider(c[0], 30@150)});
Array.fill(8, {Knob(c[1], 40@50)});
)

