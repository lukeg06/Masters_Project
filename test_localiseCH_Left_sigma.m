%Script to localise left EN.

function test_localiseCH_Left_sigma(method)
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



%%
for sigma2 = 1:15
for imNo = 1:140
    
    imageIn = im2double(imread(strcat(DBpath,imageList{imNo})));
    imageIn2D = rgb2gray(im2double(imread(strcat(DBpath,imageList2D{imNo}))));
    [Output] = localiseCHLeftSigma(imageIn,imageIn2D,prncoordinates(imNo,:),AL_LeftCoordinates(imNo,:),AL_RightCoordinates(imNo,:),method,sigma2);
    
    ind_Img = strmatch(imageList{imNo},dbList);
    ch_loc = Output.ChLeftLocation;
    x_error(imNO) = abs(ch_loc(1) - landmarkLocations(15,1,ind_Img));
    y_error(imNO) = abs(ch_loc(2) - landmarkLocations(15,2,ind_Img));
    euclidean_error(imNO) = norm(ch_loc - landmarkLocations(15,:,ind_Img));
    

end
 results = [mean(x_error),std(x_error),mean(y_error),std(y_error),mean(euclidean_error),std(euclidean_error)];
   
 fprintf(FileID,'%d\t%f\t%f\t%f\t%f\t%f\t%f\n',sigma2,results);
end
fclose(ch_Left_LocationFileID);
fclose(test_localiseCHLeftResultsFileID);