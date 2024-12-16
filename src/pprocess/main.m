function main
% MAIN  Trigger all the post-processing code.
%
% The default values used to run this function
% are stored in src/pprocess/load_defaults.m
%
% The user can override these parameters by completing
% the configuration file stored in src/pprocess/set_running_arguments.m


%% Set the program initial state

% Close previous plots
close all;

% Find the root directory of the project
rootDirectory = fullfile(fileparts(mfilename('fullpath')), "../..");

% Define the resource directory (saved simulation results)
resDirectory = fullfile(rootDirectory, "res");
if ~isfolder(resDirectory)
	mkdir(resDirectory);
end

% Define the output directory (saved post-processing results)
outDirectory = fullfile(rootDirectory, "out");
if ~isfolder(outDirectory)
	mkdir(outDirectory);
end

% Add all the post-processing matlab files in the Matlab path
addpath(genpath(fullfile(rootDirectory, "src")));

%% Set the code execution parameters

% Fetch the defaults execution parameters
Default = load_defaults();

% Fetch the user config file
RunArg = set_running_arguments();

% Overwrite these defaults with user input
for fn = fieldnames(Default)'
	if ~isfield(RunArg, fn)
		RunArg.(fn{:}) = Default.(fn{:});
	end
end

% Save the project structure in the running arguments
RunArg.rootDir_ = rootDirectory;
RunArg.resDir_  = resDirectory;
RunArg.outDir_  = outDirectory;

%% Execute the post-processing code

[tSample, Geom, NSpeed, NForce] = extract_nodal_values(RunArg);

Displ = compute_displacements(Geom);

Perim = compute_perimeters(Displ);

Force = compute_forces(NForce);

if contains(RunArg.outs, 'p')
	plot_displacements(Geom, Displ, tSample, RunArg.tFocus, true);
	plot_perimeters_evo(tSample, Perim{2});
	plot_forces_evo(tSample, Force{2});
end

%% Save the generated data

if contains(RunArg.outs, 's')
	thisOut = fullfile(RunArg.outDir_, RunArg.sName);
	save( ...
		fullfile(thisOut), ...
		"RunArg", "tSample", "Geom", "NSpeed", "NForce", "Displ", "Perim", "Force");
end

end
