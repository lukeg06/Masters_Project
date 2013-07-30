%Segundo localise prn.


%Define paths etc
addpath('.\toolboxes\segundo2010');
landmarkPath = 'C:\Databases\Texas3DFR\ManualFiducialPoints\';
DBpath = 'C:\Databases\Texas3DFR\PreprocessedImages\';
outputPath = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\';

%load landmarks & image list.
[landmarkLocations] = loadLandmarks(landmarkPath);
[dbList,~]= getDBInfo(DBpath,'range');
imageList = importdata('C:\Databases\Texas3DFR\Partitions\test.txt');
noImages = size(imageList,1);


%open files for writing results
prnLocationFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\prnLocations.txt','w');
test_localisePRNResultsFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localisePRNResults_segundo.txt','w');
fprintf(test_localisePRNResultsFileID,'No.\tX Error(mm)\tY Error(mm)\tEuc Error(mm)\n');


for imNo =1
    
    imageIn = im2double(imread(strcat(DBpath,imageList{imNo})));
    imageInXYZ = range2xyz(imageIn);
    x = repmat(imageInXYZ(:,1),1,size(imageInXYZ(:,1)));
    rangeLmks = facialLandmarks_Segundo2010 (imageInXYZ(:,1), imageInXYZ(:,2), imageIn, 'nofilter');
    
end
