% Generate training image responses. This script is used to calculate and
% save the coefficients for the EN,CH,EX points. Each of the training
% images is load and convolved with the filter bank. Using the manually
% selected landmark location the responses at each point can be extracted.
% These are there saved in a specific location for futher uses.


%Script to develop en detection
close all;
clear all;



%Define paths etc
landmarkPath = 'C:\Databases\Texas3DFR\ManualFiducialPoints\';
DBpath = 'C:\Databases\Texas3DFR\PreprocessedImages\';
outputPath = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\';
savePath = 'C:\Databases\Texas3DFR\TestGaborResponses\';

%load landmarks & image list.
[landmarkLocations] = loadLandmarks(landmarkPath);
[dbList3D,~]= getDBInfo(DBpath,'range');
[dbList2D,~]= getDBInfo(DBpath,'Portrait');
imageList3D = importdata('C:\Databases\Texas3DFR\Partitions\test.txt');
imageList2D = importdata('C:\Databases\Texas3DFR\Partitions\test_2D.txt');
noImages = size(imageList2D,1);

%% Generate Filter Bank
filterBank = FilterBank();
for i = 1:noImages
    imageIn3D = im2double(imread(strcat(DBpath,imageList3D{i})));
    imageIn2D = im2double(rgb2gray(imread(strcat(DBpath,imageList2D{i}))));
    
    %Note. Uses the fast 2D convolution method provided by David Young.
    %conv2 = 160s/80 images. convolve2 = 20s/80 images.
    response3D = filterBank.filterImage(imageIn3D);
    response2D = filterBank.filterImage(imageIn2D);
    
    subject.response3D = response3D;
    subject.response2D = response2D;
    
    fileName = imageList3D{i};
    saveFileName = strcat(savePath,fileName(1:end-10),'_response');
    save(saveFileName,'subject');
    
    fprintf('Processing image %d\n',i);
    
    clear subject;clear response3D;clear response2D
    
end