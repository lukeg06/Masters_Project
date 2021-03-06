% Align Images Using Icp - Script to align all the images in  the data set
% to some template face. This program aligns the faces and then saves the
% results in an output file. 
clear all;
close all;
% Load image info
DBpath = 'C:\Databases\Texas3DFR\PreprocessedImages\';
[imageList,noImages] = getDBInfo(DBpath,'Range');

% Load landmark location information
[landmarkLocations] = loadLandmarks('C:\Databases\Texas3DFR\ManualFiducialPoints\');


% Read template face image. As defined in Gupta
indTemplate = strmatch('Clean_0996_115_20050912193203_Range.png',imageList);
templateImage = im2double(imread(strcat(DBpath,imageList(indTemplate,:))));
templateXYZ = range2xyz(templateImage);

% Read template nose location
templatePRNLocation = landmarkLocations(19,:,indTemplate);

%%
% Align images
addpath('toolboxes\icp\');
outputPath = 'C:\Databases\Texas3DFR\AlignedData\';

%open file for writing icpEstimate values
icpEstimateOuputFileID = fopen('C:\Databases\Texas3DFR\AlignedData\icpEstimates.txt','a');

for i = 1:noImages
    
    
    %Check to see if aligned image exists
    alignedDataFile = strcat(outputPath,imageList(i,1:end-3),'aligned');
    if exist(alignedDataFile,'file') == 2
        fprintf('File %d already exists, skipping.\n',i)
    else
        dataImage = im2double(imread(strcat(DBpath,imageList(i,:))));
        dataXYZ = range2xyz(dataImage);
        [icpEstimate,alignedXYZ]= icpNose(templateXYZ,dataXYZ,templatePRNLocation);
        
        %save estimate
        fprintf(icpEstimateOuputFileID,'%d\t%f\t%f\n',i,icpEstimate(1),icpEstimate(2));
        
        %Save aligned image
        save(al
        ignedDataFile,'alignedXYZ');
       
        fprintf('Processed image %d\n',i)
    end
    
end
fclose(icpEstimateOuputFileID);
