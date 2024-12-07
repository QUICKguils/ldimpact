function Displ = compute_displacements(RunArg, Geo)
% COMPUTE_DISPLACEMENTS  Compute the displacements of the geometry.
%
% Arguments:
%   RunArg (struct) -- Code execution parameters.
%   Geo    (cell)   -- Geometrical data of the whole problem.
% Return:
%   Displ (cell) -- Displacements of the rings.

Displ = cell(size(Geo));

for iRing = 1:numel(Geo)
	DisplRing = cell(size(Geo{iRing}));

	for iCurve = 1:numel(DisplRing)
		DisplRing{iCurve}.tx = Geo{iRing}{iCurve}.tx.ab + Geo{iRing}{iCurve}.tx.re;
		DisplRing{iCurve}.ty = Geo{iRing}{iCurve}.ty.ab + Geo{iRing}{iCurve}.ty.re;
	end

	Displ{iRing} = DisplRing;
end

if contains(RunArg.outs, 'p')
	plotRef = true;
	plot_displacements(Geo, Displ, plotRef);
end
end


function plot_displacements(Geo, Displ, plotRef)
% PLOT_DISPLACEMENTS  Plot the displacements of the geometry.
%
% Arguments:
%   Geo     (cell) -- Geometrical data of the whole problem.
%   Displ   (cell) -- Displacements of the rings.
%   plotRef (bool) -- Plot the reference configuration.

figure("WindowStyle", "docked");
axis equal;
hold on;

for iRing = 1:numel(Displ)
	for iCurve = 1:numel(Displ{iRing})
		if plotRef
			plot(Geo{iRing}{iCurve}.tx.ab, Geo{iRing}{iCurve}.ty.ab, 'Color', [181, 180, 169]/255, 'LineWidth', 1);
		end
		plot(Displ{iRing}{iCurve}.tx, Displ{iRing}{iCurve}.ty, 'Color', [0, 112, 127]/255, 'LineWidth', 1);

	end
end

xlabel("X-position (mm)");
ylabel("Y-position (mm)");
end
