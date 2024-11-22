function pprocess(RunArg)
% PPROCESS  Trigger all the post-processing code.
%
% Argument:
%   RunArg (struct) -- Optional code execution parameters, with fields:
%     outs       (1xN char)   -- Output options.
%       'p' -> Enable [P]lots creation.
%       's' -> [S]ave generated data.
%
% The default values used to run this function
% are stored in src/pprocess/pprocess_defaults.m


%% Set program initial state

% Close previous plots.
close all;

% Find the root directory of the project
rootDirectory = fullfile(fileparts(mfilename('fullpath')), "../..");

% Find the resource directory (saved Metafor data)
resDirectory = fullfile(rootDirectory, "res");

% Create the untracked output directory, if absent.
outDirectory = fullfile(rootDirectory, "out");
if ~isfolder(outDirectory)
	mkdir(outDirectory);
end

% Add all the post-processing matlab files in the Matlab path
addpath(genpath(fullfile(rootDirectory, "src")));

%% Options setting

% Fetch the defaults execution parameters.
Default = pprocess_defaults();

% Overwrite these defaults with user input.
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

%% Execute the post-processing code

%% Save generated data

if contains(RunArg.opts, 's')
% 	save(fullfile(resDirectory, "runArguments.mat"), "-struct", "RunArg");
end

end