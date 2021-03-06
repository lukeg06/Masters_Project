%Script to develop ch. Used for determining which sigma value to use.
close all;
clear all;

%15& 16 ch pointss


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



savefilename1 =  strcat('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\localise_CH_Sigma.txt');

FileID = fopen(savefilename1,'w');

fprintf(FileID,'sigma\tupper_lip_error\tlower_lip_error\n');
for sigma = 10
    upper_lip_error = 0;
lower_lip_error = 0;
for imNo = 1:noImages
    imageIn = im2double(imread(strcat(DBpath,imageList{imNo})));
    imageIn2D = rgb2gray(im2double(imread(strcat(DBpath,imageList2D{imNo}))));
    
    
    
    
    leftLimit_x = AL_LeftCoordinates(imNo,1) + (0.7 * norm(AL_LeftCoordinates(imNo,1)-AL_RightCoordinates(imNo,1)));
    rightLimit_x = AL_RightCoordinates(imNo,1) - (0.7 * norm(AL_LeftCoordinates(imNo,1)-AL_RightCoordinates(imNo,1)));
    
    %% Detect curvature
    
    ind_Img = strmatch(imageList{imNo},dbList);
    
    
    [H, K] =  curvature(imageIn,sigma);
    
    K_eliptical = bsxfun(@max,zeros(size(K)),K);
    K_eliptical(mm2pixel(prncoordinates(imNo,2)):end,mm2pixel(prncoordinates(imNo,1)));
    
    [val ind] = findpeaks(K_eliptical(mm2pixel(prncoordinates(imNo,2)):end,mm2pixel(prncoordinates(imNo,1))));
    
    %Test to check if I am correctly detecting the upper and lower lip.
    %Measure the distance between vertical position of lip and manually
    %selected lip;
    lower_limit = pixel2mm(mm2pixel(prncoordinates(imNo,2)) + ind(3)) ; 
    upper_limit = pixel2mm((mm2pixel(prncoordinates(imNo,2)) + ind(2)) );
    
    ch = landmarkLocations(15,2,ind_Img);

%     if size(ind,2)~= 4
%         fprintf('%d',imNo)
%     end
    if ch < upper_limit
    upper_lip_error = upper_lip_error +1;
    end

    if ch > lower_limit
    lower_lip_error = lower_lip_error +1;
    end
     
   
end

fprintf(FileID,'%d\t%d\t%d\n',sigma,upper_lip_error,lower_lip_error);
 
end

fclose(FileID);