function [NodeCount, Kin] = compute_kinetic(NSpeed)
% COMPUTE_KINETIC Compute the specific kinetic energy of the rings.
%
% Arguments:
%   NSpeed (cell) -- Nodal speeds.
% Return:
%   NodeCount (cell) -- Number of nodes of the rings.
%   Kin       (cell) -- Specific kinetic energies.

Kin = cell(size(NSpeed));
NodeCount = cell(size(NSpeed));

for iRing = 1:numel(NSpeed)
	NodeCount{iRing} = 0;
	Kin{iRing} = zeros(size(NSpeed{iRing}{1}.tx, 1), 1);
	for iCurve = [1, 2, 3, 4]  % Avoid duplicate nodes on curves 5 and 6
		NodeCount{iRing} = NodeCount{iRing} + size(NSpeed{iRing}{iCurve}.tx, 2);
		v_square = NSpeed{iRing}{iCurve}.tx.^2 + NSpeed{iRing}{iCurve}.ty.^2;
		Kin{iRing} = Kin{iRing} + sum(v_square, 2);
	end
	Kin{iRing} = Kin{iRing} / NodeCount{iRing};
end

end