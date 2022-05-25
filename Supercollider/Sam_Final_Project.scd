// This is an improvement of a sketchpad made by Eli Fieldsteel. Original video can
// be found here: https://www.youtube.com/watch?v=PxTxAna_hwI

(
s.waitForBoot({
	var point, win, controlWin, view;
	var r, g, b, rChange, gChange, bChange, colorTask;
	var controls, spex, penWidth, size, shape, shapeSynth;

	// Synth for line being drawn
	SynthDef(\line, {
		arg freq=440, width=0.5, pan=0, amp=0.15, length=1;
		var sig, env;
		env = EnvGen.kr(Env([0,1,0],[0.012,0.012]*length,\linear),doneAction:2);
		sig = VarSaw.ar(freq, 0, width);
		sig = Pan2.ar(sig, pan, amp);
		sig = sig * env;
		Out.ar(0, sig);
	}).add;

	// Synth for when canvas is erased
	SynthDef(\erase, {
			arg midiPitch, art;
			var burstEnv, att = 0, dec = 0.01; //Variable declarations
			var out, delayTime;
			delayTime = [midiPitch, midiPitch + 12].midicps.reciprocal;
			burstEnv = EnvGen.kr(Env.perc(att, dec));
			out = PinkNoise.ar([burstEnv, burstEnv]); //Noise burst
			out = CombL.ar(out, delayTime, delayTime,
				art, add: out); //Echo chamber
			out = RLPF.ar(out, LFNoise2.kr(2, 2000, 2100), 0.1)*1.5; //Filter
			DetectSilence.ar(out, doneAction:2);
			Out.ar(0, out*0.8)
	}).add;

	// Synth for circle being added
	SynthDef(\circle, {
		var sig, freq = 100;
		sig = SinOsc.ar(XLine.kr(100, 1000, 6), mul: 0.7)!2;
		Out.ar(0, sig);
	}).add;

	// Synth for square being added
	SynthDef(\square, {
		var sig, freq = 100;
		sig = Pulse.ar(XLine.kr(100, 1000, 6), mul: 0.4)!2;
		Out.ar(0, sig);
	}).add;

	// Synth for background changes
	SynthDef(\background, {
		arg out = 0, sustain = 0.4, drum_mode_level = 0.25,
			freq = 90, drum_timbre = 1.0, amp = 0.25;
			var drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix, drum_mode_env;
			var stick_noise, stick_env;
			var drum_reson, tom_mix;

			drum_mode_env = EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
			drum_mode_sin_1 = SinOsc.ar(freq*0.8, 0, drum_mode_env * 0.5);
			drum_mode_sin_2 = SinOsc.ar(freq, 0, drum_mode_env * 0.5);
			drum_mode_pmosc = PMOsc.ar(	Saw.ar(freq*0.9),
				freq*0.85,
				drum_timbre/1.3,
				mul: drum_mode_env*5,
				add: 0);
			drum_mode_mix = Mix.new([drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc]) * drum_mode_level;
			stick_noise = Crackle.ar(2.01, 1);
			stick_env = EnvGen.ar(Env.perc(0.005, 0.01), 1.0) * 3;
			tom_mix = Mix.new([drum_mode_mix, stick_env]) * 2 * amp;
			Out.ar(out, [tom_mix, tom_mix])
	}).add;

	// Default values for controls
	penWidth = 3; size = 10; shape = "Circle";

	// Default vals for RGB
	r = 0; g = 0.33; b = 0.67;

	// Rate of change for each color
	rChange = 0.02; gChange = 0.02; bChange = 0.02;

	// Keep RGB in range 0 to 2
	colorTask = Task({
		{
			r = (r + rChange) % 2;
			g = (g + gChange) % 2;
			b = (b + bChange) % 2;
			0.05.wait;
		}.loop;
	});

	// Create fullscreen window
	win = Window("MUSIC CANVAS", Rect(0, 0, Window.screenBounds.width, Window.screenBounds.height));
	win.onClose = {
		if (
			colorTask.isPlaying,
			{colorTask.stop}
		);
	};

	// Set the user view
	view = UserView(win, Window.screenBounds);
	view.clearOnRefresh = false;
	view.background = Color.black;

	// Create a controller-window
	controlWin = Window("CANVAS CONTROLS", Rect(0, Window.screenBounds.bottom, 208, 150));
	controlWin.view.decorator = controls = FlowLayout(controlWin.view.bounds);
	EZSlider(controlWin, 200 @ 24, 'Thickness', [1, 100.0].asSpec, {|ez| penWidth = ez.value; }, 3);
	controls.nextLine;
	Button(controlWin, Rect(20, 20, 200, 50)).states_([
		["Circle", Color.black, Color.green],
		["Square", Color.black, Color.red]]).action_({
			shape = if (shape == "Circle", { "Square" },{ "Circle" });
	    });
	Button(controlWin, Rect(20, 20, 200, 50)).states_([
		["Background", Color.black, Color.white],
		["Background", Color.white, Color.black]]).action_({
			if (view.background == Color.black, {
					view.background = Color.white;
					Synth(\SOStom, [\freq, 180]);
				}, {
					view.background = Color.black;
					Synth(\SOStom, [\freq, 90]);
				}
			);
	    });
	win.refresh;

	view.mouseDownAction = {
		|v, x, y, mod, butNum|
		point = [x,y];
		// Clear screen on right click
		if (
			butNum == 1, {
				v.drawFunc_({nil});
				v.clearDrawing;
				v.refresh;
				r = Task({
					rrand(3, 12).do {
						Synth(\erase,
						[
							\midiPitch, [0, 2, 4, 6, 8, 10].choose + [36, 48, 60, 72].choose,
							\art, [0.125, 0.25, 0.5, 1.0, 2.0].choose
						]);
						//Choose a wait time before next event
						[0.1, 0.05, 0.02, 0.01].choose.wait;
					};
				}).play(SystemClock)
			}, {}
		);
		// Create shape on middle mouse click
		if (
			butNum == 2, {
				// Enlarge shape until mouse moves or shape reaches maximum
				{
					shapeSynth = if (shape == "Circle", {Synth(\circle)},{Synth(\square)});
					{(point==[x,y]).and(size<500)}.while ({
						v.drawFunc = {
							Pen.fillColor = Color.new(
								r.fold(0, 1),
								g.fold(0, 1),
								b.fold(0, 1)
							);
							if (shape == "Circle") {
								Pen.addOval(
									Rect(x - (size/2), y - (size/2), size, size)
								);
							};
							if (shape == "Square") {
								Pen.addRect(
									Rect(x - (size/2), y - (size/2), size, size)
								);
							};
							Pen.fill;
						};
						win.refresh;
						size = size + 1;
						0.01.wait;
					});
					shapeSynth.free;
				}.fork(AppClock);
				size = 10;
			}, {}
		);
	};

	view.mouseMoveAction = {
		|v, x, y|
		v.drawFunc = {
			Pen.strokeColor = Color.new(
				r.fold(0, 1),
				g.fold(0, 1),
				b.fold(0, 1)
			);
			Pen.width = penWidth;
			Pen.line(point.asPoint, x@y);
			point = [x, y];
			Pen.stroke;
		};
		win.refresh;

		Synth(\line, [
			\freq, ((x / win.bounds.width).linlin(0, 1, 32, 100)).midicps, // Create MIDI notes between 32-100 from left to right of screen
			\width, (y / Window.screenBounds.height).linlin(0, 1, 0.001, 0.05), // Increase width from top to bottom of screen
			\pan, x.linlin(0, Window.screenBounds.width, -1, 1), // Pan left when mouse on left of screen, right on right
			\length, (penWidth / 5) // Thicker pen = longer note
		]);
	};

	colorTask.start;
	win.front;
	controlWin.front;
});
)
