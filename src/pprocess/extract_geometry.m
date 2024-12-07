% TODO:
% - maybe don't isolate each iFac: return them all in the same Geo structure.
% - number of rings and curves are hardcoded, maybe create a global prop struct.
% - not efficient load file each time, if we have to iterate over iFac.

function Geo = extract_geometry(RunArg, varargin)
% EXTRACT_GEOMETRY Extract the whole geometry, for the given FAC step.
%
% Arguments:
%   RunArg (struct) -- Code execution parameters.
%   iFac   (int)    -- Numeric label of the FAC step.
% Return:
%   Geo (cell) -- Geometrical data of the whole problem.

% Set default value for optional inputs.
optargs = {6};  % TODO: should dynamically depends on the nFac sample
% Overwrite default value of optional inputs.
optargs(1:numel(varargin)) = varargin;
% Place optional args in memorable variable names.
[iFac] = optargs{:};

simDir = fullfile(RunArg.resDir_, "workspace", RunArg.sname);

Geo = cell(1, 3);

for iRing = 1:numel(Geo)
	Geo{iRing} = extract_ring_geometry(simDir, iRing, iFac);
end
end

function GeoRing = extract_ring_geometry(simDir, iRing, iFac)
% EXTRACT_RING_GEOMETRY  Extract geometry of one ring.
%
% Arguments:
%   simDir (str) -- Path of the simulation results.
%   iRing  (int) -- Numeric label of the ring.
%   iFac   (int) -- Numeric label of the FAC step.
% Return:
%   GeoRing (cell) -- Geometrical data of the ring.

GeoRing = cell(1, 6);

for iCurve = 1:numel(GeoRing)
	GeoRing{iCurve} = extract_curve_geometry(simDir, iRing, iCurve, iFac);
end
end

function GeoCurve = extract_curve_geometry(simDir, iRing, iCurve, iFac)
% EXTRACT_CURVE_GEOMETRY  Extract geometry of one curve.
%
% Arguments:
%   simPath (str) -- Path of the simulation results.
%   iRing   (int) -- Numeric label of the ring.
%   iCurve  (int) -- Numeric label of the curve.
%   iFac    (int) -- Numeric label of the FAC step.
% Return:
%   GeoCurve (cell) -- Geometrical data of the curve.

thisCurve = "_curve" + iCurve + "_ring" + iRing;

tx_re_allfac = load(fullfile(simDir, "RE_TX" + thisCurve + ".ascii"));
tx_ab_allfac = load(fullfile(simDir, "AB_TX" + thisCurve + ".ascii"));
ty_re_allfac = load(fullfile(simDir, "RE_TY" + thisCurve + ".ascii"));
ty_ab_allfac = load(fullfile(simDir, "AB_TY" + thisCurve + ".ascii"));

GeoCurve.tx.re = tx_re_allfac(iFac, :);
GeoCurve.tx.ab = tx_ab_allfac(iFac, :);
GeoCurve.ty.re = ty_re_allfac(iFac, :);
GeoCurve.ty.ab = ty_ab_allfac(iFac, :);
end
