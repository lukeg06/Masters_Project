function [PRNLocation] = localisePRN(imageIn,estimatedLocation,sigma,displayImage)
addpath('C:\VSG_IPA_toolbox\')

% This function is used to detect the precise location of the pronasale (PRN).
% An nose tip estimate is provided which is based on the location of a
% template nose tip which was use for ICP registration. This point is used
% to define a search region. This region is searched for a peak Gaussian
% curvatue. This is take to be the location of the pronasale.
%
%function [PRNLocation] = localisePRN(imageIn,estimatedLocation,dispayImage)
%
%Inputs,
%       imageIn: The range image of the subject in question. 
%
%       estimatedLocation: The estimated location of the PRN in mm. This is taken
%       to be the location of the template image PRN.
%       
%       displayImage: Show detected location and gradient images.
%Outputs,
%       prnLocation: Location of the PRN in mm. 
%



%%
% Calculate Gaussian Curvature
[~,K] = curvature(imageIn,sigma);

% Define search region around estimatedLocation
estimatedLocation_pixels = round(mm2pixel(estimatedLocation));
imageMasked = zeros(size(imageIn));
imageMasked((estimatedLocation_pixels(2) - round(25/0.32)):(estimatedLocation_pixels(2) + round(25/0.32)),(estimatedLocation_pixels(1) - round(21/0.32)):(estimatedLocation_pixels(1) + round(21/0.32))) = K((estimatedLocation_pixels(2) - round(25/0.32)):(estimatedLocation_pixels(2) + round(25/0.32)),(estimatedLocation_pixels(1) - round(21/0.32)):(estimatedLocation_pixels(1) + round(21/0.32)));

%Find location of global maximum

[val ind]= max(imageMasked(:));
[i,j] = ind2sub(size(imageMasked),ind);
% Isolate all pixels with maximum value
mat1 = ones(size(imageMasked)).*val;
mat2 = double(bsxfun(@eq,mat1,imageMasked));
% Find larget blob
[mat3] = vsg('BiggestBlob',uint8(mat2.*255));
if sum(mat3(:)) ~= 0
    [centroid_mat] = vsg('Centroid',mat3);
    [p1] = vsg('FWP',centroid_mat);
else
    p1 = [j i];
end

PRNLocation = pixel2mm([p1(1) p1(2)]);

%Display images
if strcmp(displayImage,'true')
    figure,
    subplot(2,2,1),imagesc(imageIn),title('Input Image');
    subplot(2,2,2),imagesc(K),title('Gaussian Curvature');
    subplot(2,2,3),imagesc(imageMasked),title('Search Region');
    subplot(2,2,4),imshow(imageIn),title('PRN Location');
    hold on; plot(j,i,'*m'); hold off;
    
end

