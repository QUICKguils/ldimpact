% LOCKIN  Study the lock-in effect when Poisson ratio approaches 0.5.

% Load the right simulation data
rootDirectory = fullfile(fileparts(mfilename('fullpath')), "../..");
load(fullfile(rootDirectory, "out", "lockin.mat"));

% Visualize the evolution of the center of gravity
% of the two inner rings
plot_displacements(Geom, Displ, tSample, 3/3*0.0008, true);
hold on;
plot(MDispl{1}.tx,MDispl{1}.ty);
plot(MDispl{2}.tx,MDispl{2}.ty);
hold off;

% Compute the maximum displacement
max_displ = max(abs(MDispl{1}.abs-MDispl{1}.abs(1)));

% Recorded CG displ. of ring 1, for Poisson ratio approaching 0.5
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