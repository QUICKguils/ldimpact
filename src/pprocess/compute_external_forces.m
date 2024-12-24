function FExt = compute_external_forces(NFExt)
% COMPUTE_EXTERNAL_FORCES  Compute the external forces applied on the rings.
%
% Argument:
%   NFExt (cell) -- Nodal External forces.
% Return:
%   FExt (cell) -- External forces applied on the rings.

FExt = cell(size(NFExt));

for iRing = 1:numel(NFExt)
	FExt{iRing}.tx = zeros(size(NFExt{iRing}{1}.tx, 1), 1);
	FExt{iRing}.ty = zeros(size(NFExt{iRing}{1}.ty, 1), 1);
	for iCurve = 1:numel(NFExt{iRing})
		FExt{iRing}.tx = FExt{iRing}.tx + sum(NFExt{iRing}{iCurve}.tx, 2);
		FExt{iRing}.ty = FExt{iRing}.ty + sum(NFExt{iRing}{iCurve}.ty, 2);
	end
	FExt{iRing}.abs      = sqrt(FExt{iRing}.tx.^2 + FExt{iRing}.ty.^2);
	FExt{iRing}.angleDeg = atan2d(FExt{iRing}.ty, FExt{iRing}.tx);
end
end

