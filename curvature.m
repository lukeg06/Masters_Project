function [H, K] =  curvature(imageIn,sigma)
% function which returns the mean (h) and gaussian (k) curvature of the image.
%
%function [H, K] =  curvature(imageIn,sigma)
%
%Inputs,
%       imageIn: Input range image.
%
%       sigma: Standard deviation of the gaussian used in gradient
%       calculation.
%
%Ouputs
%       H: Mean surface curvature.
%
%       K: Gaussian surface curvature.
  
%First Derivatives
[Zx Zy] = gradient2(imageIn,sigma);

% Second Derivatives
[Zxx Zxy] = gradient2(Zx,sigma);
[Zxy Zyy] = gradient2(Zy,sigma);




%Calculate Gaussian surface curvature
K = ((Zxx .* Zyy) - (Zxy.^2))./ ((1 + (Zx.^2) + (Zy.^2)).^2);




%Calculate Mean surface curvature
H = (Zxx.*(1 + (Zy.^2))) + (Zyy.*(1 - (Zx.^2)) - (2.*Zx.*Zy.*Zxy))./((1+(Zx.^2)+(Zy.^2)).^(3/2));

%Principal Curvatures
k1 = H + sqrt((H.^2) - K);
k2 = H - sqrt((H.^2) - K);

conv_elip = zeros(size(imageIn));
test = zeros(size(imageIn));

% Elliptical Regions
for i = 1: size(K(:))
   if(K(i) > 0) 
       conv_elip(i) = K(i);
       
       test(i) = 1;
   else
       conv_elip(i) = 0;
   end
   
end

% Convex regions
for i = 1: size(H(:))
   if(not(H(i) < 0)) 
       test(i) = 1;
   else
       conv_elip(i) = 0;
   end
   
end

