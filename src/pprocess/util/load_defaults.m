function Default = load_defaults
% LOAD_DEFAULTS  Default execution parameters used throughout the source code.
%
% Parameters ending with an underscore are internals,
% and are not meant to be changed.

% Project structure.
%   Those are the paths of the main project directories. These paths are defined
%   at runtime, by the main function of the post-processing code (main.m).
%   rootDir_ -> Root of the project
%   resDir_  -> Resources: saved Metafor simulations
%   outDir_  -> Outputs: saved post-processing results
Default.rootDir_ = "";
Default.resDir_  = "";
Default.outDir_  = "";

% Number of rings to extract.
Default.nRing_ = 3;

% Number of curves composing one ring.
Default.nCurve_ = 6;

% Simulation name.
%   Should match the name of the desired Metafor
%   simulation, located in the res/ directory.
Default.sName = "template";

% Particular time of the simulation
% where one desire getting the results.
Default.tFocus = 7E-4;

% Output options.
%   'p' -> Enable [P]lots creation.
%   's' -> [S]ave generated data.
Default.outs = 'ps';
end
