function [tSample, Geom, NSpeed, NForce] = extract_nodal_values(RunArg)
% EXTRACT_GEOMETRY Extract the whole Metafor simulation data.
%
% Arguments:
%   RunArg (struct) -- Code execution parameters.
% Return:
%   tSample (1xN double) -- Time sample of the simulation recordings.
%   Geo     (cell)       -- Geometrical data.
%   NSpeed  (cell)       -- Nodal speeds.
%   NForce  (cell)       -- Nodal external forces.

simDir = fullfile(RunArg.resDir_, "workspace", RunArg.sName);

tSample = load(fullfile(simDir, "tSample" + ".ascii"));

Geom  = cell(1, RunArg.nRing_);
NSpeed = cell(1, RunArg.nRing_);
NForce = cell(1, RunArg.nRing_);

for iRing = 1:RunArg.nRing_
	[Geom{iRing}, NSpeed{iRing}, NForce{iRing}] = extract_ring(RunArg, simDir, iRing);
end
end

function [GeoRing, NSpeedRing, NForceRing] = extract_ring(RunArg, simDir, iRing)
% EXTRACT_RING_GEOMETRY  Extract Metafor data of one ring.
%
% Arguments:
%   simDir (str) -- Path of the simulation results.
%   iRing  (int) -- Numeric label of the ring.
% Return:
%   GeomRing   (cell) -- Geometrical data of the ring.
%   NSpeedRing (cell) -- Speed data of the ring.
%   NForceRing (cell) -- Force data of the ring.

GeoRing   = cell(1, RunArg.nCurve_);
NSpeedRing = cell(1, RunArg.nCurve_);
NForceRing = cell(1, RunArg.nCurve_);

for iCurve = 1:numel(GeoRing)
	[GeoRing{iCurve}, NSpeedRing{iCurve}, NForceRing{iCurve}] = extract_curve_geometry(simDir, iRing, iCurve);
end
end

function [GeoCurve, NSpeedCurve, NForceCurve] = extract_curve_geometry(simDir, iRing, iCurve)
% EXTRACT_CURVE_GEOMETRY  Extract Metafor data of one curve.
%
% Arguments:
%   simPath (str) -- Path of the simulation results.
%   iRing   (int) -- Numeric label of the ring.
%   iCurve  (int) -- Numeric label of the curve.
% Return:
%   GeomCurve   (cell) -- Geometrical data of the curve.
%   NSpeedCurve (cell) -- Speed data of the curve.
%   NForceCurve (cell) -- Force data of the curve.

thisCurve = "_curve" + iCurve + "_ring" + iRing;

tx_re = load(fullfile(simDir, "RE_TX" + thisCurve + ".ascii"));
tx_ab = load(fullfile(simDir, "AB_TX" + thisCurve + ".ascii"));
ty_re = load(fullfile(simDir, "RE_TY" + thisCurve + ".ascii"));
ty_ab = load(fullfile(simDir, "AB_TY" + thisCurve + ".ascii"));

tx_gv = load(fullfile(simDir, "GV_TX" + thisCurve + ".ascii"));
ty_gv = load(fullfile(simDir, "GV_TY" + thisCurve + ".ascii"));

tx_gf1 = load(fullfile(simDir, "GF1_TX" + thisCurve + ".ascii"));
ty_gf1 = load(fullfile(simDir, "GF1_TY" + thisCurve + ".ascii"));

GeoCurve.tx.re = tx_re;
GeoCurve.tx.ab = tx_ab;
GeoCurve.ty.re = ty_re;
GeoCurve.ty.ab = ty_ab;

NSpeedCurve.tx = tx_gv;
NSpeedCurve.ty = ty_gv;

NForceCurve.tx = tx_gf1;
NForceCurve.ty = ty_gf1;
end