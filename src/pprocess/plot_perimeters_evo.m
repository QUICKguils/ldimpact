function plot_perimeters_evo(tSample, PerimRing)
% PLOT_PERIMETERS_EVO  Plot the time reldiff of the ring perimeters.
%
% Arguments:
%   tSample   (1xN double) -- Time sample of the simulation recordings.
%   PerimRing (struct)     -- Perimeters of the ring.


figure("WindowStyle", "docked");

hold on;
plot(1E3*tSample, 1E2*PerimRing.innerDiff, 'Color', [0,   112, 127]/255, 'LineWidth', 1);
plot(1E3*tSample, 1E2*PerimRing.outerDiff, 'Color', [240, 127, 060]/255, 'LineWidth', 1);
hold off;

title("Reldiff evo of the perimeters");
xlabel("Time (ms)");
ylabel("Perimeter reldiff (%)");
legend('Inner', 'Outer');
grid();
end
