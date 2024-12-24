function RunArg = set_running_arguments
% SET_RUNNING_ARGUMENTS  Override the default code execution parameters.
%
% The code execution parameters are set in the section below,
% by speficying instructions of the form:
%   Runarg.<param> = <value>
% where <param> is one of the code execution parameter name,
% whose default <value> is stored in src/pprocess/util/load_defaults.m

% Make sure the function returns at least an empty struct
RunArg = struct();

% ===== WRITE THE CONFIG HERE =====

RunArg.sName = "plasticity";
RunArg.outs = 's';
RunArg.tFocus = 3E-4;

% ==================================
end