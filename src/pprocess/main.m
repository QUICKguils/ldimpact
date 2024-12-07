function main(RunArg)
% MAIN  Trigger all the post-processing code.
%
% Argument:
%   RunArg (struct) -- Code execution parameters, with fields:
%     sname (str) -- Simulation name.
%     outs (1xN char) -- Output options.
%       'p' -> Enable [P]lots creation.
%       's' -> [S]ave generated data.
%
% The default values used to run this function
% are stored in src/pprocess/load_defaults.m


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

% Overwrite these defaults with user input
switch nargin
	case 0
		RunArg = Default;
	case 1
		for fn = fieldnames(Default)'
			if ~isfield(RunArg, fn)
				RunArg.(fn{:}) = Default.(fn{:});
			end
		end
	otherwise
		error("Wrong number of input parameters.");
end

% Save the project structure in the running arguments
RunArg.rootDir_ = rootDirectory;
RunArg.resDir_  = resDirectory;
RunArg.outDir_  = outDirectory;

%% Execute the post-processing code

Geo = extract_geometry(RunArg);

Displ = compute_displacements(RunArg, Geo);

Diam = compute_diameters(Displ);

%% Save the generated data

if contains(RunArg.outs, 's')
	save(fullfile(outDirectory, "runningArguments.mat"), "RunArg");
	save(fullfile(outDirectory, "geometry.mat"),         "Geo");
	save(fullfile(outDirectory, "displacements.mat"),    "Displ");
	save(fullfile(outDirectory, "diameters.mat"),        "Diam");
end

end
