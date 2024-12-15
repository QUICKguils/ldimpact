function plot_displacements(Geom, Displ, tSample, tTarget, plotRef)
% PLOT_DISPLACEMENTS  Plot the displacements of the geometry.
%
% Arguments:
%   Geom    (cell)       -- Geometrical data of the whole problem.
%   Displ   (cell)       -- Displacements of the rings.
%   tSample (1xN double) -- Time sample of the simulation recordings.
%   tPlot   (double)     -- Time at wich to plot the displacements.
%   plotRef (bool)       -- Plot the reference configuration.

figure("WindowStyle", "docked");
axis equal;

% Search for the closest recorded time
[~, iFac] = min(abs(tSample-tTarget));
tFac = tSample(iFac);

hold on;
for iRing = 1:numel(Displ)
	for iCurve = 1:numel(Displ{iRing})
		if plotRef
			plot( ...
				Geom{iRing}{iCurve}.tx.ab(1, :), ...
				Geom{iRing}{iCurve}.ty.ab(1, :), ...
				'Color', [181, 180, 169]/255, 'LineWidth', 1);
		end
		plot( ...
			Displ{iRing}{iCurve}.tx(iFac, :), ...
			Displ{iRing}{iCurve}.ty(iFac, :), ...
			'Color', [0, 112, 127]/255, 'LineWidth', 1);
	end
end
hold off;

title("Displacements at " + num2str(1E3*tFac) + "ms");
xlabel("X-position (mm)");
ylabel("Y-position (mm)");
end
