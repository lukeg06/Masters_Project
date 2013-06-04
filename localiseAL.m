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
imageMasked((prn_coordinates(2) - round(21/0.32)):(prn_coordinates(2) + round(21/0.32)),(prn_coordinates(1) - round(25/0.32)):(prn_coordinates(1) + round(25/0.32))) = imageEdge((prn_coordinates(2) - round(21/0.32)):(prn_coordinates(2) + round(21/0.32)),(prn_coordinates(1) - round(25/0.32)):(prn_coordinates(1) + round(25/0.32)));

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
noseContour = contour2xy(imageNoseEdge);
chainCode = chaincode([noseContour(:,1) noseContour(:,2)],'true');
sigma = 5;
a = 1:round(3.75*sigma);
g = (-a./((sigma.^3).*sqrt(2*pi))).*exp((-a.^2)./(2*(sigma.^2)));
g_norm = g./sum(g(:));

%%
dog = conv(chainCode.ucode,g_norm);
for i = 1:size(dog(:))
   if dog(i) < 0.05
       dog(i) = 0;
   end
end

dog_trunc = dog(1:end-size(g,2)+1);
[val ind] = findpeaks(dog_trunc);

figure,imshow(imageNoseEdge);
hold on;
for i = 1:size(noseContour1,1)
   plot(noseCountour1(i,2),noseContour1(i,1),'*m'); 
end
hold off;
    


