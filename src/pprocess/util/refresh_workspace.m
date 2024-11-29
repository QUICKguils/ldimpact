% REFRESH_WORKSPACE  Bring Matlab computed data in global workspace.

% Find the output results directory
outDirectory = fullfile(fileparts(mfilename('fullpath')), "../../../out");

RunArg = load(fullfile(outDirectory, "runningArguments.mat"));

clear outDirectory;
