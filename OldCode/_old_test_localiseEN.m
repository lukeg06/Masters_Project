%Script to localise left EN.

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

% Define savefile paths
%open files for writing results
en_Left_LocationFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\EN_left_Locations.txt','w');
test_localiseENLeftResultsFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseENLeftResults.txt','w');

fprintf(test_localiseENLeftResultsFileID,'No.\tX Error(mm)\tY Error(mm)\tRad Error(mm)\n');




%%
for imNo = 1:noImages
   
    imageIn = im2double(imread(strcat(DBpath,imageList{imNo})));
    imageIn2D = rgb2gray(im2double(imread(strcat(DBpath,imageList2D{imNo}))));
    [Output] = localiseENLeft(imageIn,imageIn2D,prncoordinates(imNo,:),AL_LeftCoordinates(imNo,:),AL_RightCoordinates(imNo,:));
    
    ind_Img = strmatch(imageList{imNo},dbList);
    en_loc = Output.EnLeftLocation;
    y_error = abs(en_loc(1) - landmarkLocations(5,1,ind_Img));
    x_error = abs(en_loc(2) - landmarkLocations(5,2,ind_Img));
    euclidean_error = norm(en_loc - landmarkLocations(5,:,ind_Img));
    
    fprintf(test_localiseENLeftResultsFileID,'%d\t%f\t%f\t%f\n',imNo,x_error,y_error,euclidean_error);
    fprintf('%d\t%f\t%f\t%f\n',imNo,x_error,y_error,euclidean_error);
     fprintf(en_Left_LocationFileID,'%f\t%f\n',en_loc(1),en_loc(2));
end