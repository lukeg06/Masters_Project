%Script to test the localiseAL ALFunction
close all;
clear all;


% Load PRN locations
filename = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\PRN_Results\prnLocations.txt';
A = importdata(filename);
prncoordinates = A(:,2:3);


%Define paths etc
landmarkPath = 'C:\Databases\Texas3DFR\ManualFiducialPoints\';
DBpath = 'C:\Databases\Texas3DFR\PreprocessedImages\';
outputPath = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\';

%load landmarks & image list.
[landmarkLocations] = loadLandmarks(landmarkPath);
[dbList,~]= getDBInfo(DBpath,'range');
imageList = importdata('C:\Databases\Texas3DFR\Partitions\test.txt');
noImages = size(imageList,1);


%open files for writing results
alLocationFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\ALLocations.txt','w');
test_localiseALRightResultsFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseALRightResults.txt','w');
test_localiseALLeftResultsFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseALLeftResults.txt','w');

fprintf(test_localiseALRightResultsFileID,'No.\tX Error(mm)\tY Error(mm)\tRad Error(mm)\n');
fprintf(test_localiseALLeftResultsFileID,'No.\tX Error(mm)\tY Error(mm)\tRad Error(mm)\n');

for i = 1:noImages

    imageIn = im2double(imread(strcat(DBpath,imageList{i})));
    prnLocation = prncoordinates(i,:);
    [ALLocation] = localiseAL2(imageIn,prnLocation,'false');
    if ALLocation == 0
         fprintf(test_localiseALRightResultsFileID,'%d\t1234\t1234\t1234\n',i,x_error_right,y_error_right,rad_error_right);
         fprintf(test_localiseALRightResultsFileID,'%d\t1234\t1234\t1234\n',i,x_error_right,y_error_right,rad_error_right);
           fprintf('%d\t1234\t1234\t1234\n',i,x_error_right,y_error_right,rad_error_right);
           continue;
    end
    
   ind = strmatch(imageList{i},dbList);
  %Calute error & print to file
   x_error_left = abs(ALLocation(1,1) - landmarkLocations(11,1,ind));
   y_error_left = abs(ALLocation(1,2) - landmarkLocations(11,2,ind));
   rad_error_left = norm(ALLocation(1,:) - landmarkLocations(11,:,ind));
   fprintf(test_localiseALLeftResultsFileID,'%d\t%f\t%f\t%f\n',i,x_error_left,y_error_left,rad_error_left);

    x_error_right = abs(ALLocation(2,1) - landmarkLocations(12,1,ind));
   y_error_right = abs(ALLocation(2,2) - landmarkLocations(12,2,ind));
   rad_error_right = norm(ALLocation(2,:) - landmarkLocations(12,:,ind));
   fprintf(test_localiseALRightResultsFileID,'%d\t%f\t%f\t%f\n',i,x_error_right,y_error_right,rad_error_right);

    fprintf('%d\t%f\t%f\t%f\n',i,x_error_right,y_error_right,rad_error_right);

   
end

fclose(alLocationFileID);
fclose(test_localiseALRightResultsFileID);
fclose(test_localiseALLeftResultsFileID);

copyfile('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseALRightResults.txt','C:\Documents and Settings\Luke\My Documents\Dropbox\Project results\test_localiseAL_right.txt')
copyfile('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseALLeftResults.txt','C:\Documents and Settings\Luke\My Documents\Dropbox\Project results\test_localiseAL_left.txt')
