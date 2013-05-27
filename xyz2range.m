function [out] = xyz2range(XYZ)

out = (reshape(XYZ(:,3),751,501)./0.32);
