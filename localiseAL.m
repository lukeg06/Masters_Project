function [ALLocation] = localiseAL(imageIn,PRNLocation,displayImage)
addpath('./toolboxes/chaincode/')
% function [ALLocation] localiseAL(imageIn,prnLocation,dispayImage)
%
% This function is used to localise the left alare and right alare. The
% function uses the location of the pronasale to define a search region for
% the nose corners. A Laplacian of Gaussian edge detector is used on this
% search region. The nose width points are taken to be the widest edge
% points, closest to the prn in the vertical direction.
%
% Inputs,
%       imageIn: The range image of subject in question.
%
%       prnLocation: The location of the prn as automatically detected in a previous
%       step.
%
%       displayImage: Show detected locations and edge images. 
%
% Output,
%       ALLocation: Location of the nose width points. A 2 x 2 matrix. Left
%       coordinates on first row.



imageEdge = edge(imageIn,'log',0,7);

%%
%Define search region around  prn.
imageMasked = zeros(size(imageIn));
prn_coordinates = round(mm2pixel(PRNLocation)); % round before to keep matlab happy
imageMasked((prn_coordinates(2) - round(25/0.32)):(prn_coordinates(2) + round(25/0.32)),(prn_coordinates(1) - round(21/0.32)):(prn_coordinates(1) + round(21/0.32))) = imageEdge((prn_coordinates(2) - round(25/0.32)):(prn_coordinates(2) + round(25/0.32)),(prn_coordinates(1) - round(21/0.32)):(prn_coordinates(1) + round(21/0.32)));

%
%% Find the edges of the nose by moving out horizontally from the icp estimage

% Label edges
image_labelled = bwlabeln(imageMasked,8);
% From the prn_coordinate look for the the first edge in to the right

for i = round(prn_coordinates(1)):size(imageIn,2)    
    if(image_labelled(round(prn_coordinates(2)),i)~= 0)
        label_value = image_labelled(round(prn_coordinates(2)),i);
        break; 
    end
end

% isoloate nose edge. 
imageNoseEdge = bsxfun(@eq,image_labelled,(ones(size(imageIn)).*label_value));

%% Identify critical points of negative curvature. As described by:
%
% Rodriguez, Jeffrey J., and J. K. Aggarwal. "Matching aerial images to 
% 3-D terrain maps." Pattern Analysis and Machine Intelligence, 
% IEEE Transactions on 12.12 (1990): 1138-1149.

% Generate Freeman chain code
noseCountour = (bwboundaries(imageNoseEdge,8));
noseCountour1 = noseCountour{:};
chainCode = chaincode([noseCountour1(end:-1:1,1) noseCountour1(end:-1:1,2)],'true');

sigma = 8;
a = chainCode.ucode;
g = (-a./((sigma.^3).*sqrt(2*pi))).*exp((-a.^2)./(2*(sigma.^2)));

