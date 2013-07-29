% Script to locate each of the ten facial landmarks. Saves all results in a
% single file.

imageList2D = importdata('C:\Databases\Texas3DFR\Partitions\test_2D.txt');

%Define paths etc
landmarkPath = 'C:\Databases\Texas3DFR\ManualFiducialPoints\';
DBpath = 'C:\Databases\Texas3DFR\PreprocessedImages\';
outputPath = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\';

%Load image list.
[dbList,~]= getDBInfo(DBpath,'range');
imageList = importdata('C:\Databases\Texas3DFR\Partitions\test.txt');
noImages = size(imageList,1);

%set location of template PRN
estimatedLocation = landmarkLocations(19,:,996);

% Define savefile paths

%savefile1;

for imNo =1:noImages
    
    imageIn = im2double(imread(strcat(DBpath,imageList{imNo})));
    imageIn2D = rgb2gray(im2double(imread(strcat(DBpath,imageList2D{imNo}))));
    
    %PRN localisation
    [PRNLocation] = localisePRN(imageIn,estimatedLocation,17,'false');
    %AL localisation
    % ...... Need to tidy
    ALLeftLocation =
    ALRightLocation =
    %EN localisation
    [Output] = localiseENLeft(imageIn,imageIn2D,PRNLocation,ALLeftLocation,ALRightLocation,'2D + 3D');
    ENLeftLocation = Output.EnLeftLocation;
    [Output] = localiseENright(imageIn,imageIn2D,PRNLocation,ALLeftLocation,ALRightLocation,'2D + 3D');
    ENRightLocation = Output.EnRightLocation;
    
    %M' Localisation
    MLocation  = (ENLeftLocation + ENRightLocation)./2;
    
    %EX localisation
    [Output] = localiseEXLeft(imageIn,imageIn2D,ENLeftLocation,ENRightLocation,'2D');
    EXLeftLocation = Output.ExLeftLocation;
    [Output] = localiseEXRight(imageIn,imageIn2D,ENLeftLocation,ENRightLocation,'2D');
    EXRightLocation = Output.ExRightLocation;
    
    %CH Localisation
    [Output] = localiseCHLeft(imageIn,imageIn2D,PRNLocation,ALLeftLocation,ALRightLocation,'2D + 3D');
    CHLeftLocation = Output.ChLeftLocation;
    [Output] = localiseCHRight(imageIn,imageIn2D,PRNLocation,ALLeftLocation,ALRightLocation,'2D + 3D');
    CHRightLocation = Output.ChRightLocation;
    
    %Save localisation results
    results = [PRNLocation;ALLeftLocation;ALRightLocation;ENLeftLocation;ENRightLocation,MLocation,CHLeftLocation,CHRightLocation];
    
    %Savefile name
end