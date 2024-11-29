function Displ = compute_displacements(RunArgs, Geo)

Displ = cell(size(Geo));

for iRing = 1:numel(Geo)
	DisplRing = cell(size(Geo{iRing}))
	for iCurve = 1:numel(Geo{iRing})
		DisplRing{iCurve} = compute_ring_displacements(simPath, iRing, iFac);
	end
	Displ{iRing} = DisplRing;
end

displ_tx_curve1_ring2 = ab_tx_curve1_ring2(1, :) + re_tx_curve1_ring2(end, :);
displ_ty_curve1_ring2 = ab_ty_curve1_ring2(1, :) + re_ty_curve1_ring2(end, :);

displ_tx_curve2_ring2 = ab_tx_curve2_ring2(1, :) + re_tx_curve2_ring2(end, :);
displ_ty_curve2_ring2 = ab_ty_curve2_ring2(1, :) + re_ty_curve2_ring2(end, :);

displ_tx_curve3_ring2 = ab_tx_curve3_ring2(1, :) + re_tx_curve3_ring2(end, :);
displ_ty_curve3_ring2 = ab_ty_curve3_ring2(1, :) + re_ty_curve3_ring2(end, :);

displ_tx_curve4_ring2 = ab_tx_curve4_ring2(1, :) + re_tx_curve4_ring2(end, :);
displ_ty_curve4_ring2 = ab_ty_curve4_ring2(1, :) + re_ty_curve4_ring2(end, :);

end

function compute_ring_displacements(GeoRing)

for iRing = 1:size(Geo, 2)
	Geo{iRing} = compute_ring_displacements(simPath, iRing, iFac);
end

end

function plot_displacements(Displ)
axis equal
hold on

plot(ab_tx_curve1_ring2(1, :), ab_ty_curve1_ring2(1, :), 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 1)
plot(ab_tx_curve2_ring2(1, :), ab_ty_curve2_ring2(1, :), 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 1)
plot(ab_tx_curve3_ring2(1, :), ab_ty_curve3_ring2(1, :), 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 1)
plot(ab_tx_curve4_ring2(1, :), ab_ty_curve4_ring2(1, :), 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 1)

plot(displ_tx_curve1_ring2, displ_ty_curve1_ring2, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1)
plot(displ_tx_curve2_ring2, displ_ty_curve2_ring2, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1)
plot(displ_tx_curve3_ring2, displ_ty_curve3_ring2, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1)
plot(displ_tx_curve4_ring2, displ_ty_curve4_ring2, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1)
end
