function [tSample, Geom, NSpeed, NFExt, NFInt] = extract_nodal_values(RunArg)
% EXTRACT_GEOMETRY Extract the whole Metafor simulation data.
%
% Argument:
%   RunArg (struct) -- Code execution parameters.
% Return:
%   tSample (1xN double) -- Time sample of the simulation recordings.
%   Geo     (cell)       -- Geometrical data.
%   NSpeed  (cell)       -- Nodal speeds.
%   NFExt   (cell)       -- Nodal external forces.
%   NFInt   (cell)       -- Nodal internal forces.

simDir = fullfile(RunArg.resDir_, "workspace", RunArg.sName);

tSample = load(fullfile(simDir, "tSample" + ".ascii"));

Geom  = cell(1, RunArg.nRing_);
NSpeed = cell(1, RunArg.nRing_);
NFExt = cell(1, RunArg.nRing_);
NFInt = cell(1, RunArg.nRing_);

for iRing = 1:RunArg.nRing_
	[Geom{iRing}, NSpeed{iRing}, NFExt{iRing}, NFInt{iRing}] = ...
		extract_ring(RunArg, simDir, iRing);
end
end

function [GeoRing, NSpeedRing, NFExtRing, NFIntRing] = ...
	extract_ring(RunArg, simDir, iRing)
% EXTRACT_RING_GEOMETRY  Extract Metafor data of one ring.
%
% Arguments:
%   simDir (str) -- Path of the simulation results.
%   iRing  (int) -- Numeric label of the ring.
% Return:
%   GeomRing   (cell) -- Geometrical data of the ring.
%   NSpeedRing (cell) -- Speed data of the ring.
%   NFExtRing  (cell) -- External force data of the ring.
%   NFIntRing  (cell) -- Internal force data of the ring.

GeoRing   = cell(1, RunArg.nCurve_);
NSpeedRing = cell(1, RunArg.nCurve_);
NFExtRing = cell(1, RunArg.nCurve_);
NFIntRing = cell(1, RunArg.nCurve_);

for iCurve = 1:numel(GeoRing)
	[GeoRing{iCurve}, NSpeedRing{iCurve}, NFExtRing{iCurve}, NFIntRing{iCurve}] = ...
		extract_curve_geometry(simDir, iRing, iCurve);
end
end

function [GeoCurve, NSpeedCurve, NFExtCurve, NFIntCurve] = ...
	extract_curve_geometry(simDir, iRing, iCurve)
% EXTRACT_CURVE_GEOMETRY  Extract Metafor data of one curve.
%
% Arguments:
%   simPath (str) -- Path of the simulation results.
%   iRing   (int) -- Numeric label of the ring.
%   iCurve  (int) -- Numeric label of the curve.
% Return:
%   GeomCurve   (cell) -- Geometrical data of the curve.
%   NSpeedCurve (cell) -- Speed data of the curve.
%   NFExtCurve  (cell) -- External force data of the curve.
%   NFIntCurve  (cell) -- Internal force data of the curve.

thisCurve = "_curve" + iCurve + "_ring" + iRing;

tx_re = load(fullfile(simDir, "RE_TX" + thisCurve + ".ascii"));
tx_ab = load(fullfile(simDir, "AB_TX" + thisCurve + ".ascii"));
ty_re = load(fullfile(simDir, "RE_TY" + thisCurve + ".ascii"));
ty_ab = load(fullfile(simDir, "AB_TY" + thisCurve + ".ascii"));

tx_gv = load(fullfile(simDir, "GV_TX" + thisCurve + ".ascii"));
ty_gv = load(fullfile(simDir, "GV_TY" + thisCurve + ".ascii"));

tx_gf1 = load(fullfile(simDir, "GF1_TX" + thisCurve + ".ascii"));
ty_gf1 = load(fullfile(simDir, "GF1_TY" + thisCurve + ".ascii"));

tx_gf2 = load(fullfile(simDir, "GF2_TX" + thisCurve + ".ascii"));
ty_gf2 = load(fullfile(simDir, "GF2_TY" + thisCurve + ".ascii"));

GeoCurve.tx.re = tx_re;
GeoCurve.tx.ab = tx_ab;
GeoCurve.ty.re = ty_re;
GeoCurve.ty.ab = ty_ab;

NSpeedCurve.tx = tx_gv;
NSpeedCurve.ty = ty_gv;

NFExtCurve.tx = tx_gf1;
NFExtCurve.ty = ty_gf1;

NFIntCurve.tx = tx_gf2;
NFIntCurve.ty = ty_gf2;
end
