% Script to test the influence of the sigma value use in gradient
% calculations.

%Define paths etc
landmarkPath = 'C:\Databases\Texas3DFR\ManualFiducialPoints\';
DBpath = 'C:\Databases\Texas3DFR\PreprocessedImages\';
outputPath = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\';

%load landmarks & image list.
[landmarkLocations] = loadLandmarks(landmarkPath);
[imageList,noImages]= getDBInfo(DBpath,'range');


%open files for writing results
test_localisePRN_sigmaResultsFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localisePRNResults_sigma.txt','w');
fprintf(test_localisePRN_sigmaResultsFileID,'No.\tX Std(mm)\tY Std(mm)\tRad Std(mm)\n');

%set location of template PRN
estimatedLocation = landmarkLocations(19,:,996);
randomSample = randperm(1149);
for sigma = 1:20
    y=1;
    for i = (1:100)
     imageIn = im2double(imread(strcat(DBpath,imageList(i,:))));
     [PRNLocation] = localisePRN(imageIn,estimatedLocation,sigma,'false');

      %Calute error & print to file
       x_error(y) = abs(PRNLocation(1) - landmarkLocations(19,1,i));
       y_error(y) = abs(PRNLocation(2) - landmarkLocations(19,2,i));
       euclidean_error(y) = norm(PRNLocation - landmarkLocations(19,:,i));
        y= y+1;
    end
    std_x = std(x_error);
    std_y = std(y_error);
    std_rad = std(euclidean_error);
    fprintf(test_localisePRN_sigmaResultsFileID,'%d\t%f\t%f\t%f\n',sigma,std_x,std_y,std_rad);
end



fclose(test_localisePRN_sigmaResultsFileID);

copyfile('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localisePRNResults_sigma.txt.txt','C:\Documents and Settings\Luke\My Documents\Dropbox\Project results\test_localisePRN_sigmaResults.txt')
