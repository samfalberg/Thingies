s.makeWindow.boot;

(
SynthDef("Harpsichord", {
	arg out = 0, freq = 440, amp = 0.1, pan = 0;
    var env, snd;
	env = Env.perc(level: amp).kr(doneAction: 2);
	snd = Pulse.ar(freq, 0.25, 0.75);
	snd = snd * env;
	Out.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef("Keys", {
    |out = 0, freq = 440, gate = 1, pan = 0, amp = 0.1,
    vel = 0.8, modIndex = 0.2, mix = 0.2, lfoSpeed = 0.4, lfoDepth = 0.1|
    var env1, env2, env3, env4;
    var osc1, osc2, osc3, osc4, snd;

    lfoSpeed = lfoSpeed * 12;

    freq = freq * 2;

    env1 = EnvGen.ar(Env.adsr(0.001, 1.25, 0.0, 0.04, curve: \lin));
    env2 = EnvGen.ar(Env.adsr(0.001, 1.00, 0.0, 0.04, curve: \lin));
    env3 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin));
    env4 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin));

    osc4 = LFSaw.ar(freq * 0.5) * 2pi * 2 * 0.535887 * modIndex * env4 * vel;
    osc3 = LFSaw.ar(freq, osc4) * env3 * vel;
    osc2 = LFSaw.ar(freq * 15) * 2pi * 0.108819 * env2 * vel;
    osc1 = LFSaw.ar(freq, osc2) * env1 * vel;
    snd = Mix((osc3 * (1 - mix)) + (osc1 * mix));
    snd = snd * (LFSaw.ar(lfoSpeed) * lfoDepth + 1);

    snd = snd * EnvGen.ar(Env.asr(0, 1, 0.1), gate, doneAction: 2);
    snd = Pan2.ar(snd, pan, amp);

    Out.ar(out, snd);
}).add;

SynthDef("Retro", {
	|out, amp=0.3, freq=440|
	var snd;
	snd = LFPulse.ar(freq)!2;
	snd = snd * EnvGen.ar(Env.perc(0.005, 0.75), doneAction:2);
	OffsetOut.ar(out, snd*amp);
}).add;
)


(
var groove1, groove2, groove2Chords, groove3, melody1, melody2, melody3;

groove1 = Pbind(\instrument, "Harpsichord",
	[\midinote, \dur],
	Pseq([
		[42,0.5], [[69,71,76],0.25], [54,0.25], [42,0.25], [[69,71,76],0.25], [54,0.25],
		[43,0.5], [[69,71,76],0.25], [55,0.25], [43,0.25], [[69,71,76],0.5], [[43,73,78],0.5],
		[35,0.5], [[61,62,69],0.25], [47,0.25], [35,0.25], [[61,62,69],0.25], [47,0.25],
		[37,0.5], [[65,71,76],0.25], [49,0.25], [37,0.25], [[65,71,76],0.5], [[41,65,74],0.5],
		[42,0.5], [[69,71,76],0.25], [54,0.25], [42,0.25], [[69,71,76],0.25], [54,0.25],
		[43,0.5], [[69,71,76],0.25], [55,0.25], [43,0.25], [[69,71,76],0.5], [[43,73,78],0.5],
		[[38,66,69,73],0.75],[[37,64,68,71],1],[[30,61,64,69],1.25], [[68,71,76],0.5], [[69,73,78],0.5]
	],2)
);

groove2 = Pbind(\instrument, "Harpsichord",
	[\midinote, \dur],
	Pseq([
		[43,0.75], [50,0.75], [55,0.5], [42,0.75], [42,0.75], [49,0.5],
		[43,0.75], [50,0.75], [55,0.5], [46,0.75], [46,0.75], [49,0.5],
		[43,0.75], [37,0.25], [38,0.25], [42,0.25], [43,0.25], [40,0.25], [42,0.75], [42, 1.25],
		[50,0.5], [43,0.25], [38,0.75], [43,0.5], [49,0.5], [42,0.5], [37,0.5], [42, 0.5],
		[43,0.5], [50,0.25], [38,0.5], [47,0.25], [50,0.25], [47,0.25], [42,0.5], [54,0.25], [42,0.5], [50,0.25],[49,0.25], [45,0.25],
		[43,0.5], [50,0.25], [38,0.5], [47,0.25], [50,0.25], [47,0.25], [46,0.5], [54,0.25], [56,0.5], [53,0.25], [49,0.25], [45,0.25],
		[43,0.5], [50,0.25], [38,0.5], [47,0.25], [50,0.25], [47,0.25], [42,0.5], [54,0.25], [42,0.5], [46,0.25], [49,0.25],[50,0.25],
		[55,0.5], [43,0.25], [38,0.5], [47,0.25], [50,0.25], [47,0.25], [49,0.5], [53,0.25], [56,0.5], [53,0.25], [49,0.25], [41,0.25], [42,3]
	])
);

groove2Chords = Pbind(\instrument, "Harpsichord",
	[\midinote, \dur],
	Pseq([
		[[55,59],2], [[54,57],0.75], [[54,57],1.25],
		[[55,59],2], [[56],0.75], [61,1.25],
		[[55,59],2], [[54,57],0.75], [[54,57],1.25],
		[[54,62],0.75], [[54,62],1.25], [[53,61],0.75], [[53,61],1.25]
	],2)
);

groove3 = Pbind(\instrument, "Harpsichord",
	[\midinote, \dur],
	Pseq([
		[38,0.5], [[50,69,71,76],0.25], [45,0.25], [38,0.25], [[50,69,71,76],0.25], [45,0.25],
		[37,0.5], [[53,69,71,76],0.25], [49,0.25], [45,0.25], [[41,69,71,76],0.25], [53,0.25], [[49,73,78],0.25], [45,0.25],
		[42,0.5], [[50,61,62,69],0.25], [42,0.25], [38,0.25], [[50,61,62,69],0.25], [42,0.25],
		[37,0.5], [[52,65,71,76],0.25], [49,0.25], [37,0.25], [[52,65,71,76],0.25], [49,0.25], [[40,65,74],0.25], [38,0.25],
		[35,0.5], [[47,59,62],0.25], [38,0.25], [35,0.25], [[47,59,62],0.25], [43,0.25],
		[41,0.5], [[49,65],0.25], [46,0.25], [41,0.25], [[49,65],0.25], [46,0.25], [[41,64,69],0.25], [46,0.25],
		[[42,54,66],0.75], [[44,56,68],0.75], [[45,57,69],1], [42,0.5], [40,0.5], [37,0.5],
		[38,0.5], [[50,69,71,76],0.25], [45,0.25], [38,0.25], [[50,69,71,76],0.25], [45,0.25],
		[37,0.5], [[53,69,71,76],0.25], [49,0.25], [45,0.25], [[41,69,71,76],0.25], [53,0.25], [[49,73,78],0.25], [45,0.25],
		[42,0.5], [[50,61,62,69],0.25], [42,0.25], [38,0.25], [[50,61,62,69],0.25], [42,0.25],
		[37,0.5], [[52,65,71,76],0.25], [49,0.25], [37,0.25], [[52,65,71,76],0.25], [49,0.25], [[40,65,74],0.25], [38,0.25],
		[35,0.5], [[47,59,62],0.25], [38,0.25], [35,0.25], [[47,59,62],0.25], [43,0.25],
		[41,0.5], [[49,65],0.25], [46,0.25], [41,0.25], [[49,65],0.25], [46,0.25], [[41,64,69],0.25], [46,0.25],
		[[38,66,69,73],0.75],[[37,64,68,71],1],[[30,61,64,69],1.25], [[68,71,76],0.5], [[69,73,78],0.5]
	])
);

melody1 = Pbind(\instrument, "Retro",
	[\midinote, \dur],
	Pseq([
		[59,0.25], [61,0.25], [66,0.25], [69,0.25], [71,0.25], [73,0.5], [71,0.5], [71,0.5], [76,0.75],
		[73,0.75], [66,0.5], [68,0.5], [69,0.25], [68,0.5], [64,0.25], [61,1.75],
		[59,0.25], [61,0.25], [66,0.25], [69,0.25], [71,0.25], [73,0.5], [71,0.5], [71,0.5], [76,0.75],
		[78,0.75], [80,0.5], [76,0.5], [78,2.75]
	],2)
);

melody2 = Pbind(\instrument, "Retro",
	[\midinote, \dur],
	Pseq([
		[78,0.25], [76,0.25], [74,0.25], [73,0.25], [71,0.25], [73,0.75], [66,2],
		[78,0.25], [76,0.25], [74,0.25], [73,0.25], [71,0.25], [73,0.75], [80,2],
		[78,0.25], [76,0.25], [74,0.25], [73,0.25], [71,0.25], [73,0.75], [66,0.75], [68,0.5],
		[69,0.75], [71,0.5], [74,0.5], [73,3],
		[78,0.25], [76,0.25], [74,0.25], [73,0.25], [71,0.25], [73,0.75], [66,2],
		[78,0.25], [76,0.25], [74,0.25], [73,0.25], [71,0.25], [73,0.75], [80,2],
		[78,0.25], [76,0.25], [74,0.25], [73,0.25], [71,0.25], [73,0.75], [66,0.75], [68,0.5],
		[69,0.75], [68,0.5], [69,0.5], [68,1.25], [66,0.5], [65,0.5], [66,3]
	])
);

melody3 = Pbind(\instrument, "Keys",
	[\midinote, \dur],
	Pseq([
		[66,0.25], [68,0.25], [69,0.75], [Rest,0.75], [68,0.25], [69,0.25], [71,0.75], [Rest,0.75],
		[69,0.25], [71,0.25], [73,0.5], [76,0.25], [71,1/6], [73,1/6], [71,1/6], [69,0.5],
		[71,0.5], [69,0.5], [76,0.5], [74,0.5], [73,1.25],
		[78, 0.5], [73, 0.5], [71,0.5], [69,0.5], [71,0.5], [69,0.25],
		[73,2], [54,0.5], [54,0.5], [54,0.5], [66,0.25], [54,0.5],
		[64,0.25], [61,0.25], [59,0.25], [68,0.25], [64,0.25], [61,0.25], [59,0.25], [64,0.25],
		[71,0.25], [67,0.25], [61,0.25], [67,0.25], [64,0.25], [61,0.25], [59,0.25], [64,0.25],
		[66,0.25], [61,0.25], [57,0.25], [68,0.25], [64,0.25], [61,0.25], [57,0.25], [69,0.25],
		[68,0.25], [64,0.25], [61,0.25], [59,0.25], [57,0.25], [61,0.25], [62,0.25], [66,0.25],
		[54,0.25], [61,0.25], [59,0.25], [54,0.25], [59,0.25], [61,0.25], [64,0.25], [66,0.25],
		[54,0.25], [61,0.25], [59,0.25], [66,0.25], [59,0.5], [64,0.5],
		[54,0.75], [66,0.25], [61,0.25], [54,0.5], [54,0.5], [Rest,2.75],
		[62,0.5], [69,0.5], [68,1/6], [69,1/6], [68,1/6], [66,0.25], [65,0.75], [68,0.25], [69,1.25],
		[73,0.5], [76,0.5], [76,1/6], [78,1/6], [76,1/6], [73,0.25], [71,0.5], [69,0.75],
		[64,0.25], [62,0.25], [57,0.25], [68,0.25], [62,0.25], [59,0.25], [68,0.25], [69,0.25],
		[71,0.25], [68,0.25], [65,0.25], [76,0.25], [65,0.25], [74,0.25], [73,0.25], [71,0.25],
		[73,0.75], [76,0.75], [78,3.25],
		[61,0.25], [66,0.25], [68,0.25], [69,0.25], [73,1/6], [74,1/6], [73,1/6], [71,0.75], [71,0.5],
		[76,0.5], [73,0.25], [69,0.25], [66,0.25], [73,0.5], [76,0.5], [71,0.125], [73,0.125],
		[71,1.5], [69,0.25], [68,0.25],
		[66,0.25], [62,0.25], [59,0.25], [69,0.25], [66,0.25], [62,0.25], [66,0.25], [69,0.25],
		[73,0.25], [71,0.25], [68,0.25], [78,0.25], [73,0.25], [68,0.25], [73,0.25], [78,0.25],
		[66,0.5], [66,0.25], [78,0.5], [66,0.5], [66,3]
	])
);

Ptpar([0, groove1, 32, groove1, 32.5, melody1, 64, groove2, 64, groove2Chords, 64.75, melody2, 96, groove1, 127.5, melody3, 128, groove1, 160, groove3, 192, groove1]).play(TempoClock(2.25));
)