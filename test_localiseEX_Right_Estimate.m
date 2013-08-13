

%load en locations
filename = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\EN_Results\EN_left_Locations.txt';
A = importdata(filename);
EN_LeftCoordinates = A ;clear A;
filename = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\EN_Results\EN_right_Locations.txt';
A = importdata(filename);
EN_RightCoordinates = A ;clear A;


%%


%Define paths etc
landmarkPath = 'C:\Databases\Texas3DFR\ManualFiducialPoints\';
DBpath = 'C:\Databases\Texas3DFR\PreprocessedImages\';
outputPath = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\';
%%
%load landmarks & image list.
[landmarkLocations] = loadLandmarks(landmarkPath);
[dbList,~]= getDBInfo(DBpath,'range');
imageList = importdata('C:\Databases\Texas3DFR\Partitions\test.txt');
noImages = size(imageList,1);


imageList2D = importdata('C:\Databases\Texas3DFR\Partitions\test_2D.txt');

% Define savefile paths
%opex files for writing results
savefilename1  = strcat('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\EX_right_Locations_','estimate','.txt');
savefilename2 =  strcat('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseEXRightResults_','estimate','.txt');

ex_Right_LocationFileID = fopen(savefilename1,'w');
test_localiseEXRightResultsFileID = fopen(savefilename2,'w');

fprintf(test_localiseEXRightResultsFileID,'No.\tX Error(mm)\tY Error(mm)\tRad Error(mm)\n');

%% calculate extimate for outer eye corner
for imNo =1:noImages
    
    imageIn = im2double(imread(strcat(DBpath,imageList{imNo})));
    imageIn2D = rgb2gray(im2double(imread(strcat(DBpath,imageList2D{imNo}))));
    
    
ex_left_estimate = [(EN_LeftCoordinates(imNo,1) - norm(EN_LeftCoordinates(imNo,1) - EN_RightCoordinates(imNo,1))),...
    (EN_LeftCoordinates(imNo,2) + EN_RightCoordinates(imNo,2))/2];
   ex_right_estimate = [(EN_RightCoordinates(imNo,1) + norm(EN_LeftCoordinates(imNo,1) - EN_RightCoordinates(imNo,1))),...
    (EN_LeftCoordinates(imNo,2) + EN_RightCoordinates(imNo,2))/2];

if mm2pixel(ex_right_estimate(1)) > size(imageIn,2)
   ex_right_estimate(1) = pixel2mm(size(imageIn,2));
end
 ExRightLocation = ex_right_estimate;



ind_Img = strmatch(imageList{imNo},dbList);

y_error = abs(ExRightLocation(1) - landmarkLocations(9,1,ind_Img));
x_error = abs(ExRightLocation(2) - landmarkLocations(9,2,ind_Img));
euclidean_error = norm(ExRightLocation - landmarkLocations(9,:,ind_Img));



 fprintf(test_localiseEXRightResultsFileID,'%d\t%f\t%f\t%f\n',imNo,x_error,y_error,euclidean_error);
    fprintf('%d\t%f\t%f\t%f\n',imNo,x_error,y_error,euclidean_error);
    fprintf(ex_Right_LocationFileID,'%f\t%f\n',ExRightLocation(1),ExRightLocation(2));
end

fclose(ex_Right_LocationFileID);
fclose(test_localiseEXRightResultsFileID);