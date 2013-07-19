%Script to localise left EN.
function test_localiseEN_Right(method)

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
save_filename1 = strcat('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\EN_right_Locations_',method,'.txt');
save_filename2 = strcat('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseENRightResults_',method,'.txt');

en_Right_LocationFileID = fopen(save_filename1,'w');

test_localiseENRightResultsFileID = fopen(save_filename2,'w');

fprintf(test_localiseENRightResultsFileID,'No.\tX Error(mm)\tY Error(mm)\tRad Error(mm)\n');




%%

for imNo = 1:noImages
    
    imageIn = im2double(imread(strcat(DBpath,imageList{imNo})));
    imageIn2D = rgb2gray(im2double(imread(strcat(DBpath,imageList2D{imNo}))));
    [Output] = localiseENRight(imageIn,imageIn2D,prncoordinates(imNo,:),AL_LeftCoordinates(imNo,:),AL_RightCoordinates(imNo,:),method);
    
    ind_Img = strmatch(imageList{imNo},dbList);
    en_loc = Output.EnRightLocation;
    x_error = abs(en_loc(1) - landmarkLocations(8,1,ind_Img));
    y_error = abs(en_loc(2) - landmarkLocations(8,2,ind_Img));
    euclidean_error = norm(en_loc - landmarkLocations(8,:,ind_Img));
    
    fprintf(test_localiseENRightResultsFileID,'%d\t%f\t%f\t%f\n',imNo,x_error,y_error,euclidean_error);
    fprintf('%d\t%f\t%f\t%f\n',imNo,x_error,y_error,euclidean_error);
     fprintf(en_Right_LocationFileID,'%f\t%f\n',en_loc(1),en_loc(2));
end

fclose(en_Right_LocationFileID);
flose(test_localiseENRightResultsFileID);