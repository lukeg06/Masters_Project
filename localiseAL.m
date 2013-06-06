% function [ALLocation] = localiseAL(imageIn,prnLocation,dispayImage)
%
% This function is used to localise the left alare and right alare. The
% function uses the location of the pronasale to define a search region for
% the nose corners. A Laplacian of Gaussian edge detector is used on this
% search region. Critical points are detected by examining the curvature
% of the nose contour. Points with the highest negative curvature are taken
% to be critical points. The nose width points are taken to be the widest
% critical points, closest to the prn in the vertical direction.
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



function [ALLocation] = localiseAL(imageIn,PRNLocation,displayImage)
addpath('./toolboxes/chaincode/')


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
a = -round(3.75*sigma):round(3.75*sigma);
g = (-a./((sigma.^3).*sqrt(2*pi))).*exp((-a.^2)./(2*(sigma.^2)));
g_norm = g./sum(g(:));

%%
dog = conv(chainCode.ucode,g_norm,'same');
for i = 1:size(dog(:))
   if dog(i) < 0.05
       dog(i) = 0;
   end
end


[val ind] = findpeaks(dog);
criticalPoints = zeros(size(ind,2),2);
y = 1;
for i = ind(1:end)
    criticalPoints(y,:) = [noseContour(i,2) noseContour(i,1)];
    y = y+1;
end



% Locate leftmost and rightmost critical points which are closest to the
% PRN along the vertical direction. Go left and right 1st up and down

% 
rightInds = find(criticalPoints(:,1)>prn_coordinates(1));
leftInds = find(criticalPoints(:,1)<prn_coordinates(1));

rightPts = sort(criticalPoints(rightInds,:),2);
leftPts = sort(criticalPoints(leftInds,:),2);

noseContour_rev = [noseContour(:,2),noseContour(:,1)]; 
contourInds = find(noseContour_rev(:,2) == prn_coordinates(2));

%% Sort to keep in order
contourPts = sort(noseContour_rev(contourInds,:),2);

indLeft1 = find(leftPts(:,1)>= contourPts(1,1),1,'first');
indLeft2 = find(leftPts(:,1)< contourPts(1,1),1,'first');
possibleLeft = [leftPts(indLeft1,:);leftPts(indLeft2,:)];

[~,indLeftFinal] = min(abs((possibleLeft(:,2)- prn_coordinates(2))));

leftAL =  possibleLeft(indLeftFinal,:);

%%
indRight1 = find(rightPts(:,1)>= contourPts(2,1),1,'first');
indRight2 = find(rightPts(:,1)< contourPts(2,1),1,'first');
possibleRight = [rightPts(indRight1,:);rightPts(indRight2,:)];

[~,indRightFinal] = min(abs((possibleRight(:,2)- prn_coordinates(2))));


%% 
rightAL =  possibleRight(indRightFinal,:);

ALLocation =  [pixel2mm(leftAL);pixel2mm(rightAL)];


% Display 
if strcmp(displayImage,'true')
    figure,
    subplot(2,2,1),imagesc(imageIn),title('Input Image');
    subplot(2,2,2),imagesc(imageNoseEdge),title('Nose Contour');
    subplot(2,2,3),imshow(imageNoseEdge);
    hold on;
    for i = 1:size(ind,2)
       plot(noseContour(ind,2),noseContour(ind,1),'*m'); 
    end
    hold off;title('Critical Points')
   
    subplot(2,2,4),imshow(imageIn),title('AL Locations');
    hold on; 
    plot(mm2pixel(ALLocation(1,1)),mm2pixel(ALLocation(1,2)),'*m'); 
     plot(mm2pixel(ALLocation(2,1)),mm2pixel(ALLocation(2,2)),'*m'); 
    hold off;
    
end