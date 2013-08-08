%Segundo localise prn.


close all;clear all;

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


for imNo =1:noImages
    
    imageIn = im2double(imread(strcat(DBpath,imageList{imNo})));
  [x,y,z] = range2xyz(imageIn);

%     
% x =   repmat(x,1,size(x,1));
% y =   repmat(y,1,size(y,1));
% z =   repmat(z,1,size(z,1));

%rangeLmks = facialLandmarks_Segundo2010 (x, y, z,'kh_thresholds',0.03,0.015,'xNose_rows',16);
%  rangeLmks = facialLandmarks_Segundo2010 (x, y, z,'kh_thresholds',0.003,0.003/10,'xNose_rows',16);
 %rangeLmks = facialLandmarks_Segundo2010 (x, y,z,'kh_thresholds',0.00000003,0.00000003);
     rangeLmks = facialLandmarks_Segundo2010 (x, y,z,'kh_thresholds',0.04,0.0003,'xNose_rows',16);
     % rangeLmks = facialLandmarks_Segundo2010 (x, y,z,'xNose_rows',16);
    PRNLocation = pixel2mm([rangeLmks.landmarks2D_YX(1,2),rangeLmks.landmarks2D_YX(1,1)]);
   ind = strmatch(imageList{imNo},dbList);
  %Calute error & print to file
   y_error = abs(PRNLocation(2) - landmarkLocations(19,2,ind));
   x_error = abs(PRNLocation(1) - landmarkLocations(19,1,ind));
   euclidean_error = norm(PRNLocation - landmarkLocations(19,:,ind));
    fprintf('%d\t%f\t%f\t%f\n',imNo,x_error,y_error,euclidean_error);
    fprintf(test_localisePRNResultsFileID,'%d\t%f\t%f\t%f\n',imNo,x_error,y_error,euclidean_error);
end

