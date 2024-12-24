function [MSpeed, MDispl] = compute_mean_motion(NSpeed, Displ)
% COMPUTE_MEAN_MOTION  Compute the velocity and displacement of the ring CGs.
%
% Arguments:
%   NSpeed (cell) -- Nodal speeds.
%   Displ  (cell) -- Displacements of the rings.
% Return:
%   MSpeed (cell) -- Mean speeds.
%   MDispl (cell) -- Mean displacements.

MSpeed = cell(size(NSpeed));
MDispl = cell(size(Displ));

for iRing = 1:numel(NSpeed)
	MSpeed{iRing}.tx = zeros(size(NSpeed{iRing}{1}.tx, 1), 1);
	MSpeed{iRing}.ty = zeros(size(NSpeed{iRing}{1}.ty, 1), 1);
	MDispl{iRing}.tx = zeros(size( Displ{iRing}{1}.tx, 1), 1);
	MDispl{iRing}.ty = zeros(size( Displ{iRing}{1}.ty, 1), 1);
	for iCurve = 1:numel(NSpeed{iRing})
		MSpeed{iRing}.tx = MSpeed{iRing}.tx + sum(NSpeed{iRing}{iCurve}.tx, 2) / size(NSpeed{iRing}{iCurve}.tx, 2);
		MSpeed{iRing}.ty = MSpeed{iRing}.ty + sum(NSpeed{iRing}{iCurve}.ty, 2) / size(NSpeed{iRing}{iCurve}.ty, 2);
		MDispl{iRing}.tx = MDispl{iRing}.tx + sum( Displ{iRing}{iCurve}.tx, 2) / size( Displ{iRing}{iCurve}.tx, 2);
		MDispl{iRing}.ty = MDispl{iRing}.ty + sum( Displ{iRing}{iCurve}.ty, 2) / size( Displ{iRing}{iCurve}.ty, 2);
	end
	MSpeed{iRing}.tx = MSpeed{iRing}.tx / (numel(NSpeed{iRing}));
	MSpeed{iRing}.ty = MSpeed{iRing}.ty / (numel(NSpeed{iRing}));
	MDispl{iRing}.tx = MDispl{iRing}.tx / (numel(NSpeed{iRing}));
	MDispl{iRing}.ty = MDispl{iRing}.ty / (numel(NSpeed{iRing}));

	MSpeed{iRing}.abs = sqrt(MSpeed{iRing}.tx.^2 + MSpeed{iRing}.ty.^2);
	MDispl{iRing}.abs = sqrt(MDispl{iRing}.tx.^2 + MDispl{iRing}.ty.^2);
end

end