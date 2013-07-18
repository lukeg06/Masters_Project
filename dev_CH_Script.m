%Script to develop ch
close all;
clear all;




imageList2D = importdata('C:\Databases\Texas3DFR\Partitions\test_2D.txt');

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


for imNo = 20
    imageIn = im2double(imread(strcat(DBpath,imageList{imNo})));
    imageIn2D = rgb2gray(im2double(imread(strcat(DBpath,imageList2D{imNo}))));
    
    
    
    
    leftLimit_x = AL_LeftCoordinates(imNo,1) + (0.7 * norm(AL_LeftCoordinates(imNo,1)-AL_RightCoordinates(imNo,1)));
    rightLimit_x = AL_RightCoordinates(imNo,1) - (0.7 * norm(AL_LeftCoordinates(imNo,1)-AL_RightCoordinates(imNo,1)));
    
    %% Detect curvature
    
    sigma = 10;
    
    [H, K] =  curvature(imageIn,sigma);
    
    K_eliptical = bsxfun(@max,zeros(size(K)),K);
    K_eliptical(mm2pixel(prncoordinates(imNo,2)):end,mm2pixel(prncoordinates(imNo,1)));
    
    [val ind] = findpeaks(K_eliptical(mm2pixel(prncoordinates(imNo,2)):end,mm2pixel(prncoordinates(imNo,1))));
    
    if size(ind,2)~= 4
        fprintf('%d',imNo)
    end
    
end