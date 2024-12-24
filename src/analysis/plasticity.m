% PLASTICITY  Study the energy loss through pastic deformations.

% Search for the root directory of the project
rootDirectory = fullfile(fileparts(mfilename('fullpath')), "../..");

figure("WindowStyle", "docked");
hold on;
load(fullfile(rootDirectory, "out", "plasticity_elast.mat"));
plot_kinetic(NSpeed, tSample);
load(fullfile(rootDirectory, "out", "plasticity_200.mat"));
plot_kinetic(NSpeed, tSample);
load(fullfile(rootDirectory, "out", "plasticity_E10000.mat"));
plot_kinetic(NSpeed, tSample);
xlabel("Time (ms)");
ylabel("Relative total kinetic energy");
hold off;

function plot_kinetic(NSpeed, tSample)
	[~, Kin] = compute_kinetic(NSpeed);
		
	mass_ring1 = pi*(10^2-8^2)*0.1;
	mass_ring2 = pi*(12^2-10^2)*0.01;
	
	ke_ring1 = 0.5 * mass_ring1 * Kin{1};
	ke_ring2 = 0.5 * mass_ring2 * Kin{2};
	
	plot(1E3*tSample, (ke_ring2+ke_ring1)/(ke_ring2(1)+ke_ring1(1)));
end