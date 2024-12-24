% WAVE  Study the propagation of elastic waves in ring 1.

% Load the right simulation data
rootDirectory = fullfile(fileparts(mfilename('fullpath')), "../..");
load(fullfile(rootDirectory, "out", "wave.mat"));

rho = 0.1;  % [g/mm³]
half_perim = Perim{1}(1) / 2;  % [mm]
quarter_perim = half_perim/2;  % [mm]

% Recorded wave time, so that information arrives behind the node.
nu_range = [0.125, 0.3, 0.4, 0.49, 0.499, 0.4995, 0.4999];
max_range = [
	11.0745,  % 0.125
	11.0715,  % 0.3
	11.0661,  % 0.4
	11.0664,  % 0.49
	11.0400,  % 0.499
	11.0262,  % 0.4995
	10.6119,  % 0.4999
];

figure("WindowStyle", "docked");
plot(nu_range, max_range, Marker="x");
xlabel("Poisson ratio");
ylabel("Maximum displacement (mm)");

