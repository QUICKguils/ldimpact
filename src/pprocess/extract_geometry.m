function extract_geometry()
%EXTRACT_GEOMETRY 

re_tx = load("src\workspace\main\RE_TX_r2_curve1.ascii");
re_ty = load("src\workspace\main\RE_TY_r2_curve1.ascii");
AB_tx = load("src\workspace\main\AB_TX_r2_curve1.ascii");
ab_tx = load("src\workspace\main\AB_TX_r2_curve1.ascii");
ab_ty = load("src\workspace\main\AB_TY_r2_curve1.ascii");
re_tx = load("src\workspace\main\RE_TX_r2_curve1.ascii");
re_ty = load("src\workspace\main\RE_TY_r2_curve1.ascii");
ab_tx = load("src\workspace\main\AB_TX_r2_curve1.ascii");
ab_ty = load("src\workspace\main\AB_TY_r2_curve1.ascii");
displ_tx = ab_tx(1, :) + re_tx(end, :);
displ_ty = ab_ty(1, :) + re_ty(end, :);
plot(ab_tx(1, :), ab_ty(1, :))
axis equal
hold on
plot(displ_tx, displ_ty)

end

