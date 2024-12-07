function Diam = compute_diameters(Displ)
% COMPUTE_DIAMETERS  Compute the diameters of the rings.
%
% Argument:
%   Displ (cell) -- Displacements of the rings.
% Return:
%   Diam (cell) -- Diameters of the rings.

Diam = cell(size(Displ));

for iRing = 1:numel(Displ)
		Diam{iRing} = compute_ring_diameters(Displ{iRing});
end
end

function DiamRing = compute_ring_diameters(DisplRing)
% COMPUTE_RING_DIAMETERS  Compute the diameters of one ring.
%
% Argument:
%   DisplRing (cell) -- Displacements of the ring.
% Return:
%   DiamRing (cell) -- Diameters of the ring.

inner_cx = [DisplRing{1}.tx, DisplRing{2}.tx];
inner_cy = [DisplRing{1}.ty, DisplRing{2}.ty];

outer_cx = [DisplRing{3}.tx, DisplRing{4}.tx];
outer_cy = [DisplRing{3}.ty, DisplRing{4}.ty];

DiamRing.inner = sum(sqrt(diff(inner_cx).^2 + diff(inner_cy).^2));
DiamRing.outer = sum(sqrt(diff(outer_cx).^2 + diff(outer_cy).^2));
end
