%Script to develop en detection
close all;
clear all;




%Define paths etc
landmarkPath = 'C:\Databases\Texas3DFR\ManualFiducialPoints\';
DBpath = 'C:\Databases\Texas3DFR\PreprocessedImages\';
outputPath = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\';

% Load prn locations
filename = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\PRN_Results\prnLocations.txt';
A = importdata(filename);
prncoordinates = A(:,2:3); clear A;

%load al locations
filename = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\AL_Results\AL_left_Locations.txt';
A = importdata(filename);
AL_LeftCoordinates = A ;clear A;
filename = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\AL_Results\AL_right_Locations.txt';
A = importdata(filename);
AL_RightCoordinates = A ;clear A;

%load landmarks & image list.
[landmarkLocations] = loadLandmarks(landmarkPath);
[dbList,~]= getDBInfo(DBpath,'range');
imageList = importdata('C:\Databases\Texas3DFR\Partitions\test.txt');
noImages = size(imageList,1);

%%
for i = 2
imageIn = im2double(imread(strcat(DBpath,imageList{i})));

end

%% Define Search Region

%Find location of highest vertical point of image
nonZero = find(imageIn>0);
[i_row,j_col] =ind2sub(size(imageIn),nonZero);
V_y = min(i_row);

prn_x = prncoordinates(2);

upperLimit_y = prncoordinates(i,2)- (0.3803*1.5*norm(prncoordinates(i,2)-pixel2mm(V_y)));
lowerLimit_y = prncoordinates(i,2)- (0.3803*0.3803*norm(prncoordinates(i,2)-pixel2mm(V_y)));

leftLimit_x = AL_LeftCoordinates(i,1) - (0.5 * norm(AL_LeftCoordinates(i,1)-AL_RightCoordinates(i,1)));
rightLimit_x = AL_RightCoordinates(i,1) + (0.5 * norm(AL_LeftCoordinates(i,1)-AL_RightCoordinates(i,1)));



%% Detect curvature
sigma = 15;
[~, K] =  curvature(imageIn,sigma);

K_masked_left = zeros(size(K));
K_masked_left(mm2pixel(upperLimit_y):mm2pixel(lowerLimit_y),mm2pixel(leftLimit_x):mm2pixel(prn_x)) = K(mm2pixel(upperLimit_y):mm2pixel(lowerLimit_y),mm2pixel(leftLimit_x):mm2pixel(prn_x));

K_masked_right = zeros(size(K));
K_masked_right(mm2pixel(upperLimit_y):mm2pixel(lowerLimit_y),mm2pixel(prn_x):mm2pixel(rightLimit_x)) = K(mm2pixel(upperLimit_y):mm2pixel(lowerLimit_y),mm2pixel(prn_x):mm2pixel(rightLimit_x));




%%
%Find location of global maximum
imageMasked = K_masked_left;
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

maxLocation = pixel2mm([p1(1) p1(2)]);