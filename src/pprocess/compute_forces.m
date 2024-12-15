function Force = compute_forces(NForce)
% COMPUTE_FORCES  Compute the external forces applied on the rings.
%
% Argument:
%   NForce (cell) -- Nodal External forces.
% Return:
%   Force (cell) -- External forces applied on the rings.

Force = cell(size(NForce));

for iRing = 1:numel(NForce)
	Force{iRing}.tx = zeros(size(NForce{iRing}{1}.tx, 1), 1);
	Force{iRing}.ty = zeros(size(NForce{iRing}{1}.ty, 1), 1);
	for iCurve = 1:numel(NForce{iRing})
		Force{iRing}.tx = Force{iRing}.tx + sum(NForce{iRing}{iCurve}.tx, 2);
		Force{iRing}.ty = Force{iRing}.ty + sum(NForce{iRing}{iCurve}.ty, 2);
	end
	Force{iRing}.abs      = sqrt(Force{iRing}.tx.^2 + Force{iRing}.ty.^2);
	Force{iRing}.angleDeg = atan2d(Force{iRing}.ty, Force{iRing}.tx);
end
end

