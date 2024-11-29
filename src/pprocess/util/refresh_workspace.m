% REFRESH_WORKSPACE  Bring Matlab computed data in global workspace.

% Find the output results directory
outDirectory = fullfile(fileparts(mfilename('fullpath')), "../../../out");

load(fullfile(outDirectory, "runningArguments.mat"));
load(fullfile(outDirectory, "geometry.mat"));
load(fullfile(outDirectory, "displacements.mat"));
load(fullfile(outDirectory, "diameters.mat"));

clear outDirectory;
