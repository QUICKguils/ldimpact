function Default = load_defaults()
% LOAD_DEFAULTS  Default execution parameters used throughout the source code.

% Project structure.
%   Those are the paths of the main project directories. These paths are defined
%   at runtime, by the main function of the post-processing code (main.m).
%   rootDir_ -> Root of the project
%   resDir_  -> Resources: saved Metafor simulations
%   outDir_  -> Outputs: saved post-processing results
Default.rootDir_ = "";
Default.resDir_  = "";
Default.outDir_  = "";

% Simulation name.
%   Should match the name of the desired Metafor
%   simulation, located in the res/ directory.
Default.sname = "template";

% Output options.
%   'p' -> Enable [P]lots creation.
%   's' -> [S]ave generated data.
Default.outs = 'ps';
end
