(
w = Window("GUI_TEST",Rect(0, 0, 690, 300));
w.front;
//w.view.decorator = FlowLayout(w.view.bounds, 3@3, 3@3);
w.layout = VLayout();

c = CompositeView();
c.background_(Color.red);
c.minHeight_(110);
//c.scroll(true);
//c.decorator_(FlowLayout(c.bounds, 3@3, 3@3));

c.layout = HLayout();
10.do({
	c.layout.add(EZKnob(c, label: "bibi").view.minWidth_(60));
});
c.layout.add(Button().states_([["X", Color.white, Color.red]]).action_({ c.removeAll; c.remove; }));

d = CompositeView();
d.background_(Color.green);
d.minHeight_(110);

d.layout = HLayout();
5.do({
	d.layout.add(Knob());
});
d.layout.add(Button().states_([["X", Color.white, Color.red]]).action_({ d.removeAll; d.remove; }));

e = CompositeView();
e.background_(Color.yellow);
e.minHeight_(110);

e.layout = HLayout();
5.do({
	e.layout.add(Knob());
});
e.layout.add(Button().states_([["X", Color.white, Color.red]]).action_({ e.removeAll; e.remove; }));

w.layout.add(c);
w.layout.add(d);
w.layout.add(e);
)