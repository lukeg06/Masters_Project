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
DBpath = 'C:\Databases\Texas3DFR\Resized_PreprocessedImages\';
outputPath = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\';
savePath = 'C:\Databases\Texas3DFR\GaborResponses\';

%load landmarks & image list.
[landmarkLocations] = loadLandmarks(landmarkPath);
[dbList3D,~]= getDBInfo(DBpath,'range');
[dbList2D,~]= getDBInfo(DBpath,'Portrait');
imageList3D = importdata('C:\Databases\Texas3DFR\Partitions\Example_Images_3D.txt');
imageList2D = importdata('C:\Databases\Texas3DFR\Partitions\Example_Images_2D.txt');
noImages = size(imageList2D,1);

landmarkLocations = landmarkLocations./3;

%% Generate Filter Bank
filterBank = FilterBank();
for i = 1:noImages
    imageIn3D = im2double(imread(strcat(DBpath,imageList3D{i})));
    imageIn2D = im2double(rgb2gray(imread(strcat(DBpath,imageList2D{i}))));
    
    %Note. Uses the fast 2D convolution method provided by David Young.
    %conv2 = 160s/80 images. convolve2 = 20s/80 images.
    response3D = filterBank.filterImage(imageIn3D);
    response2D = filterBank.filterImage(imageIn2D);
    
    ind3D = strmatch(imageList3D{i},dbList3D);
    ind2D = strmatch(imageList2D{i},dbList2D);
    % Isolate responses at landmark locations.
    EN.left.val3D = response3D(:,mm2pixel(landmarkLocations(5,2,ind3D)),mm2pixel(landmarkLocations(5,1,ind3D)));
    EN.left.val2D = response2D(:,mm2pixel(landmarkLocations(5,2,ind2D)),mm2pixel(landmarkLocations(5,1,ind2D)));
    EN.right.val3D = response3D(:,mm2pixel(landmarkLocations(8,2,ind3D)),mm2pixel(landmarkLocations(8,1,ind3D)));
    EN.right.val2D = response2D(:,mm2pixel(landmarkLocations(8,2,ind2D)),mm2pixel(landmarkLocations(8,1,ind2D)));
    
    EX.left.val3D = response3D(:,mm2pixel(landmarkLocations(4,2,ind3D)),mm2pixel(landmarkLocations(4,1,ind3D)));
    EX.left.val2D = response2D(:,mm2pixel(landmarkLocations(4,2,ind2D)),mm2pixel(landmarkLocations(4,1,ind2D)));
    EX.right.val3D = response3D(:,mm2pixel(landmarkLocations(9,2,ind3D)),mm2pixel(landmarkLocations(9,1,ind3D)));
    EX.right.val2D = response2D(:,mm2pixel(landmarkLocations(9,2,ind2D)),mm2pixel(landmarkLocations(9,1,ind2D)));
        
    CH.left.val3D = response3D(:,mm2pixel(landmarkLocations(15,2,ind3D)),mm2pixel(landmarkLocations(15,1,ind3D)));
    CH.left.val2D = response2D(:,mm2pixel(landmarkLocations(15,2,ind2D)),mm2pixel(landmarkLocations(15,1,ind2D)));
    CH.right.val3D = response3D(:,mm2pixel(landmarkLocations(16,2,ind3D)),mm2pixel(landmarkLocations(16,1,ind3D)));
    CH.right.val2D = response2D(:,mm2pixel(landmarkLocations(16,2,ind2D)),mm2pixel(landmarkLocations(16,1,ind2D)));
    
    % Save responses.
    subject.EN = EN;
    subject.EX = EX;
    subject.CH = CH;
    fileName = imageList3D{i};
     saveFileName = strcat(savePath,fileName(1:end-10),'_jet');
     save(saveFileName,'subject');
    
  
     
    
end