% test_localisePRN.m

%Script to test the localisePRN function. Saves the detected PRN location
%to a file for further use. The test also measures the error between the
%automatically detected PRN and the manually localised one. 

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
prnLocationFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\prnLocations.txt','w');
test_localisePRNResultsFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localisePRNResults.txt','w');
fprintf(test_localisePRNResultsFileID,'No.\tX Error(mm)\tY Error(mm)\tEuc Error(mm)\n');

%set location of template PRN
estimatedLocation = landmarkLocations(19,:,996);

for i = 1:noImages
 imageIn = im2double(imread(strcat(DBpath,imageList{i})));
 [PRNLocation] = localisePRN(imageIn,estimatedLocation,17,'false');
 
  %Write PRNLocation to file
  fprintf(prnLocationFileID,'%d\t%f\t%f\n',i,PRNLocation(1),PRNLocation(2));
  
  ind = strmatch(imageList{i},dbList);
  %Calute error & print to file
   y_error = abs(PRNLocation(1) - landmarkLocations(19,1,ind));
   x_error = abs(PRNLocation(2) - landmarkLocations(19,2,ind));
   euclidean_error = norm(PRNLocation - landmarkLocations(19,:,ind));
   
   fprintf(test_localisePRNResultsFileID,'%d\t%f\t%f\t%f\n',i,x_error,y_error,euclidean_error);
   %fprintf('%d\t%f\t%f\t%f\n',i,x_error,y_error,euclidean_error);
   %fprintf('Processing image %d\n',i)
   %plotLandmark(landmarkLocations(19,:,ind),gcf)
end


fclose(prnLocationFileID);
fclose(test_localisePRNResultsFileID);

copyfile('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\prnLocations.txt','C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\PRN_Results\prnLocations_centroid.txt')
copyfile('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localisePRNResults.txt','C:\Documents and Settings\Luke\My Documents\Dropbox\Project results\test_localisePRNResults.txt')

