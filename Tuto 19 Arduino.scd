SerialPort.devices;
new("COM4", 115200);

(
x = [];
30.do{x = x.add(~port.read)};
x = x.collect(_.asAscii);
)

(
~charArray = [];
~getValues = Routine.new({
	var ascii;
	{
		ascii = ~port.read.asAscii;
		if(ascii.isDecDigit, {~charArray = ~charArray.add(ascii)});
		if(ascii == $a, {
			~val = ~charArray.collect(_.digit).convertDigits;
			~charArray = [];
		});
	}.loop;
}).play;
)

(
SynthDef.new(\saw, {
	arg cutoff = 1000;
	var sig;
	sig = Saw.ar([50,51]);
	sig = RLPF.ar(sig, cutoff.lag(0.02), 0.25, 0.2);
	Out.ar(0, sig);
}).add;
)