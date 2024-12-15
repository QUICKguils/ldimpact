function Displ = compute_displacements(Geom)
% COMPUTE_DISPLACEMENTS  Compute the displacements of the geometry.
%
% Arguments:
%   Geom   (cell)       -- Geometrical data of the whole problem.
% Return:
%   Displ (cell) -- Displacements of the rings.

Displ = cell(size(Geom));

for iRing = 1:numel(Geom)
	DisplRing = cell(size(Geom{iRing}));

	for iCurve = 1:numel(DisplRing)
		DisplRing{iCurve}.tx = Geom{iRing}{iCurve}.tx.ab + Geom{iRing}{iCurve}.tx.re;
		DisplRing{iCurve}.ty = Geom{iRing}{iCurve}.ty.ab + Geom{iRing}{iCurve}.ty.re;
	end

	Displ{iRing} = DisplRing;
end

end