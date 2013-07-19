%Script to localise Right EX.

function test_localiseEX_Right(method)
imageList2D = importdata('C:\Databases\Texas3DFR\Partitions\test_2D.txt');

%Define paths etc
landmarkPath = 'C:\Databases\Texas3DFR\ManualFiducialPoints\';
DBpath = 'C:\Databases\Texas3DFR\PreprocessedImages\';
outputPath = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\';



%load en locations
filename = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\EN_Results\EN_left_Locations.txt';
A = importdata(filename);
EN_LeftCoordinates = A ;clear A;
filename = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\EN_Results\EN_right_Locations.txt';
A = importdata(filename);
EN_RightCoordinates = A ;clear A;

%load landmarks & image list.
[landmarkLocations] = loadLandmarks(landmarkPath);
[dbList,~]= getDBInfo(DBpath,'range');
imageList = importdata('C:\Databases\Texas3DFR\Partitions\test.txt');
noImages = size(imageList,1);

% Define savefile paths
%opex files for writing results
savefilename1  = strcat('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\EX_right_Locations_',method,'.txt');
savefilename2 =  strcat('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseEXRightResults_',method,'.txt');

ex_Right_LocationFileID = fopen(savefilename1,'w');
test_localiseEXRightResultsFileID = fopen(savefilename2,'w');

fprintf(test_localiseEXRightResultsFileID,'No.\tX Error(mm)\tY Error(mm)\tRad Error(mm)\n');




%%

for imNo = 1:noImages
    
    imageIn = im2double(imread(strcat(DBpath,imageList{imNo})));
    imageIn2D = rgb2gray(im2double(imread(strcat(DBpath,imageList2D{imNo}))));
    [Output] = localiseEXRight(imageIn,imageIn2D,EN_LeftCoordinates(imNo,:),EN_RightCoordinates(imNo,:),method);
    
    ind_Img = strmatch(imageList{imNo},dbList);
    ex_loc = Output.ExRightLocation;
    x_error = abs(ex_loc(1) - landmarkLocations(9,1,ind_Img));
    y_error = abs(ex_loc(2) - landmarkLocations(9,2,ind_Img));
    euclidean_error = norm(ex_loc - landmarkLocations(9,:,ind_Img));
    
    fprintf(test_localiseEXRightResultsFileID,'%d\t%f\t%f\t%f\n',imNo,x_error,y_error,euclidean_error);
    fprintf('%d\t%f\t%f\t%f\n',imNo,x_error,y_error,euclidean_error);
    fprintf(ex_Right_LocationFileID,'%f\t%f\n',ex_loc(1),ex_loc(2));
end

fclose(ex_Right_LocationFileID);
fclose(test_localiseEXRightResultsFileID);