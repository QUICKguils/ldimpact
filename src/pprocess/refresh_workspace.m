% REFRESH_WORKSPACE  Bring Matlab computed data in global workspace.

% Find the output results directory
outDirectory = fullfile(fileparts(mfilename('fullpath')), "../../out");

Path = load(fullfile(outDirectory, "projectPath.mat"));

clear outDirectory;
