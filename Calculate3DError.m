% Calculate 3D error. Take Z value to the value at the detected xy
% coordinates. Since the coordinates of the feature area in double format
% rounding is used on the coordinate. MM values are used in all cases.

clear all;
close all;
%% Load coordinates from file
[file_, pathname] = uigetfile( ...
       {'*.txt'}, ...
        'Pick a coordinate file');
 
filename = strcat(pathname,file_);
A = importdata(filename);
coordinates = [A(:,2),A(:,1)];

% load list of images
DBpath = 'C:\Databases\Texas3DFR\PreprocessedImages\';
imageList = importdata('C:\Databases\Texas3DFR\Partitions\test.txt');
noImages = size(imageList,1);

% load landmarks
landmarkPath = 'C:\Databases\Texas3DFR\ManualFiducialPoints\';
[landmarkLocations] = loadLandmarks(landmarkPath);
[dbList,~]= getDBInfo(DBpath,'range');

file_out_name = inputdlg({'Enter Save file name (No extension)'},'Save file name',1,{'title'});
%open file for writing results
save_path = strcat(pathname,file_out_name{:},'.txt');
[zResultsFileID] = fopen(save_path,'w');
fprintf(zResultsFileID,'No.\tZ Error(mm)\t3D Error\n');

zError_total = ones(noImages,1);
Radial_3D_total = ones(noImages,1);
% load images and calculate 3d error
ans_out = inputdlg({'Enter coordinate index'},'Coordinate Index',1,{'0'});
coordinate_index = str2num(ans_out{:});
for i = 1:noImages
    if isequal(coordinates(i,:),[0,0])
        fprintf(zResultsFileID,'%d\t%f\t%f\n',i,0,0); 
        continue;
    end
        imageTest = im2double(imread(strcat(DBpath,imageList{i})));
    
    ind = strmatch(imageList{i},dbList);
    z_greyVal_estimate = imageTest(mm2pixel(coordinates(i,2)),mm2pixel(coordinates(i,1)));
    z_greyVal_estimate_mm = (z_greyVal_estimate.*255).*0.32;
    
    z_greyVal_actual = imageTest(mm2pixel(landmarkLocations(coordinate_index,2,ind)),mm2pixel(landmarkLocations(coordinate_index,1,ind)));
    z_greyVal_actual_mm = (z_greyVal_actual.*255).*0.32;
    
    zError = abs(z_greyVal_actual_mm - z_greyVal_estimate_mm);
    zError_total(i) = zError;
   
    
    locationEstimate = [coordinates(i,2) coordinates(i,1) z_greyVal_estimate_mm];
    locationActual = [landmarkLocations(coordinate_index,2,ind) landmarkLocations(coordinate_index,1,ind) z_greyVal_actual_mm];
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
result = [zMean,zStd,Radial_3DMean,Radial_3DStd];

fclose(zResultsFileID);
