% RUN_PPROCESS  Run the post-prcessing code

% Find the output results directory
rootDirectory = fullfile(fileparts(mfilename('fullpath')), "../../..");
cd(rootDirectory);

RunArg.sname = "template";

run src\pprocess\main.m;
refresh_workspace;

clear rootDirectory;
