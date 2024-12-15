function Perim = compute_perimeters(Displ)
% COMPUTE_PERIMETERS  Compute the perimeters of the rings.
%
% Argument:
%   Displ (cell) -- Displacements of the rings.
% Return:
%   Perim (cell) -- Perimeters of the rings.

Perim = cell(size(Displ));

for iRing = 1:numel(Displ)
	Perim{iRing} = compute_ring_perimeters(Displ{iRing});
end
end

function PerimRing = compute_ring_perimeters(DisplRing)
% COMPUTE_RING_DIAMETERS  Compute the perimeters of one ring.
%
% Argument:
%   DisplRing (cell) -- Displacements of the ring.
% Return:
%   PerimRing (cell) -- Perimeters of the ring.

inner_cx = [DisplRing{1}.tx, DisplRing{2}.tx];
inner_cy = [DisplRing{1}.ty, DisplRing{2}.ty];

outer_cx = [DisplRing{3}.tx, DisplRing{4}.tx];
outer_cy = [DisplRing{3}.ty, DisplRing{4}.ty];

PerimRing.inner = sum(sqrt(diff(inner_cx, 1, 2).^2 + diff(inner_cy, 1, 2).^2), 2);
PerimRing.outer = sum(sqrt(diff(outer_cx, 1, 2).^2 + diff(outer_cy, 1, 2).^2), 2);
% PerimRing.relDiff = (PerimRing.outer - PerimRing.inner) ./ PerimRing.inner;
PerimRing.innerDiff = (PerimRing.inner(1) - PerimRing.inner) ./ PerimRing.inner(1);
PerimRing.outerDiff = (PerimRing.outer(1) - PerimRing.outer) ./ PerimRing.outer(1);
end
