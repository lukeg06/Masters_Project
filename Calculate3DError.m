% Calculate 3D error. Take Z value to the value at the detected xy
% coordinates. Since the coordinates of the feature area in double format
% rounding is used on the coordinate. MM values are used in all cases.

clear all;
close all;
%% Load coordinates from file
filename = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\PRN_Results\prnLocations.txt';
A = importdata(filename);
coordinates = A(:,2:3);

% load list of images
DBpath = 'C:\Databases\Texas3DFR\PreprocessedImages\';
imageList = importdata('C:\Databases\Texas3DFR\Partitions\test.txt');
noImages = size(imageList,1);

% load landmarks
landmarkPath = 'C:\Databases\Texas3DFR\ManualFiducialPoints\';
[landmarkLocations] = loadLandmarks(landmarkPath);

%open file for writing results
[zResultsFileID] = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\PRN_Results\prn_3d_error.txt','w');
fprintf(zResultsFileID,'No.\tZ Error(mm)\t3D Error\n');

zError_total = ones(noImages,1);
Radial_3D_total = ones(noImages,1);
% load images and calculate 3d error
for i = 1:noImages
    imageTest = im2double(imread(strcat(DBpath,imageList{i})));
    z_greyVal_estimate = imageTest(mm2pixel(coordinates(i,1)),mm2pixel(coordinates(i,2)));
    z_greyVal_estimate_mm = (z_greyVal_estimate.*255).*0.32;
    
    z_greyVal_actual = imageTest(mm2pixel(landmarkLocations(19,1,i)),mm2pixel(landmarkLocations(19,2,i)));
    z_greyVal_actual_mm = (z_greyVal_actual.*255).*0.32;
    
    zError = abs(z_greyVal_actual_mm - z_greyVal_estimate_mm);
    zError_total(i) = zError;
   
    
    locationEstimate = [coordinates(i,1) coordinates(i,2) z_greyVal_estimate_mm];
    locationActual = [landmarkLocations(19,1,i) landmarkLocations(19,2,i) z_greyVal_actual_mm];
    Radial_3D = norm(locationActual-locationEstimate);
    Radial_3D_total(i) = Radial_3D;

    % Write results to file
    fprintf(zResultsFileID,'%d\t%f\t%f\n',i,zError,Radial_3D);
   fprintf('%d\t%f\t%f\n',i,zError,Radial_3D)
end

Radial_3DMean = mean(Radial_3D_total(:));
zMean = mean(zError_total(:));
zStd = std(zError_total(:));
Radial_3DStd = std(Radial_3D_total(:));

fclose(zResultsFileID);
