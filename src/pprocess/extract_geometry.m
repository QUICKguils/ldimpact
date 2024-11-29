% TODO:
% - number of rings and curves are hardcoded, maybe create a global struct.

function Geo = extract_geometry(Path, simName, iFac)
%EXTRACT_GEOMETRY Extract the whole geometry, for the given FAC step.

simPath = fullfile(Path.res, simName);

Geo = cell(1, 3);

for iRing = 1:numel(Geo)
	Geo{iRing} = extract_ring_geometry(simPath, iRing, iFac);
end
end

function GeoRing = extract_ring_geometry(simPath, iRing, iFac)
% EXTRACT_RING_GEOMETRY  Extract geometry of one ring, for one simulation.
%
% simPath (str) -- File name of the simulation, saved under Path.res.
% iRing   (int) -- Numeric label of the ring.
% iFac    (int) -- Numeric label of the FAC step.

GeoRing = cell(1, 6);

for iCurve = 1:numel(GeoRing)
	GeoRing{iCurve} = extract_curve_geometry(simPath, iRing, iCurve, iFac);
end
end

function CurveRing = extract_curve_geometry(simPath, iRing, iCurve, iFac)
% EXTRACT_CURVE_GEOMETRY  Extract geometry of one curve, for one simulation.
%
% simPath (str) -- File name of the simulation, saved under Path.res.
% iRing   (int) -- Numeric label of the ring.
% iCurve  (int) -- Numeric label of the curve.
% iFac    (int) -- Numeric label of the FAC step.

thisCurve = "_curve" + iCurve + "_ring" + iRing;

tx_re_allfac = load(fullfile(simPath, "RE_TX" + thisCurve + ".ascii"));
tx_ab_allfac = load(fullfile(simPath, "AB_TX" + thisCurve + ".ascii"));
ty_re_allfac = load(fullfile(simPath, "RE_TY" + thisCurve + ".ascii"));
ty_ab_allfac = load(fullfile(simPath, "AB_TY" + thisCurve + ".ascii"));

CurveRing.tx.re = tx_re_allfac(iFac, :);
CurveRing.tx.ab = tx_ab_allfac(iFac, :);
CurveRing.ty.re = ty_re_allfac(iFac, :);
CurveRing.ty.ab = ty_ab_allfac(iFac, :);
end
