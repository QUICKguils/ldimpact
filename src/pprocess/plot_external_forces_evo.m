function plot_external_forces_evo(tSample, FExtRing)
% PLOT_EXTERNAL_FORCES_EVO  Plot the evo of the ring external forces.
%
% Arguments:
%   tSample  (1xN double) -- Time sample of the simulation recordings.
%   FExtRing (struct)     -- External forces applied on the ring.

figure("WindowStyle", "docked");

hold on;
plot(1E3*tSample, FExtRing.abs, 'Color', [0,   112, 127]/255, 'LineWidth', 1);
hold off;

title("Evo of the total external force");
xlabel("Time (ms)");
ylabel("Total external forces");
grid();
end
