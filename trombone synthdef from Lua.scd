(
SynthDef(\trombone, { arg out = 0, freq = 178, amp = 1, kpfac = 2, kpdel = 3, gate = 1, t_gate = 1, pan = 0, gdamp = 0.003, delayM = 110, t_trig = 0, ffac = 0.9, reflec = 0, reflec2 = 0, reflec3 = 0, kernel = 0, cbufnum = -1, thresh = 0.85, kind = 1/*, useef = 0*/;
	var radio, jitfac, freqJ, presion, localin, delayL, delay, freqfac, freqlip, env, signal, filsignal, pitch, errorgQ, errorR, toloop, trig;

	// input from buses
	/*open = In.kr(bopen,1);
	local radio = In.kr(bradio,1);
	local delfac = In.kr(bus_delfac.busIndex,1);*/
	jitfac = LFDNoise3.kr(5,0.005,1);

	freqJ = freq*jitfac;

	presion = LinLin.kr(amp,0,1,5000,25000);
	presion = presion * EnvGen.kr(Env([1,1,1.5,1,1],[0,0.01,0.05,0.8],[0,-3,2,0]),t_gate);
	radio = EnvGen.kr(Env([0.5,0.5,1,1,1],[0,0.1,0.05,0.8],[0,-3,2,0]),t_gate);

	localin = LocalIn.kr(2,[delayM,ffac]);
	delayL = localin[1];
	delay = delayL.max(1).min(1400);
	freqfac = localin[2];
	freqfac = freqfac.max(0.7).min(1.5);


	freqlip = freqJ*freqfac;
	env = EnvGen.ar(Env.adsr(0,0,1,0.0),gate,doneAction:2);
	signal = AdachiAyers.ar(freqlip,presion,radio,reflec,reflec2,reflec3,1,1,delay*1)*100*env;
	signal = LeakDC.ar(signal);
	filsignal = LPF.ar(signal,3000);
	pitch = PitchTracker.kr(filsignal,audiosize*2,0.5,freqJ,thresh,kind,useef,cbufnum,t_gate);

	errorgQ = pitch[1]-freqJ;
	errorR = errorgQ/freq;

	toloop = (delay + kpdel*kpfac*errorR);
	LocalOut.kr([toloop,freqfac - kpfac*0.002*errorR]);
	// info for plotting
	trig = Impulse.kr(ControlRate.ir()/30);
	SendReply.kr(trig,"ratiol",[freq,pitch[1],errorR,delay,errorR,freqfac,pitch[2],pitch[3]]);

	signal = Convolution2.ar(signal,kernel,0,2048);
	Out.ar(out,Pan2.ar(signal,pan));
}).add;
)
(
Pbind(
	\instrument, \trombone,
	\dur, 2
).play;
)