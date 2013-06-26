% Script to test the influence of the sigma value use in gradient
% calculations.

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
test_localisePRN_sigmaResultsFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localisePRNResults_sigma.txt','w');
fprintf(test_localisePRN_sigmaResultsFileID,'No.\tX Std(mm)\tY Std(mm)\tRad Std(mm)\n');

%set location of template PRN
estimatedLocation = landmarkLocations(19,:,996);
randomSample = randperm(1149);
for sigma = 1:20
    y=1;
    for i = 7
     imageIn = im2double(imread(strcat(DBpath,imageList{i})));
     [PRNLocation] = localisePRN(imageIn,estimatedLocation,sigma,'true');
        
      ind = strmatch(imageList{i},dbList);
      %Calute error & print to file
       y_error(y) = abs(PRNLocation(1) - landmarkLocations(19,1,ind));
       x_error(y) = abs(PRNLocation(2) - landmarkLocations(19,2,ind));
       euclidean_error(y) = norm(PRNLocation - landmarkLocations(19,:,ind));
        y= y+1;
        plotLandmark(landmarkLocations(19,:,ind),gcf);
        pause
    end
    std_x = std(x_error);
    std_y = std(y_error);
    std_rad = std(euclidean_error);
    mean_x = mean(x_error);
    mean_y = mean(y_error);
    mean_rad = mean(euclidean_error);
 fprintf('%d\t%f\t%f\t%f\t%f\t%f\t%f\n',sigma,std_x,std_y,std_rad,mean_x,mean_y,mean_rad);

    fprintf(test_localisePRN_sigmaResultsFileID,'%d\t%f\t%f\t%f\t%f\t%f\t%f\n',sigma,std_x,std_y,std_rad,mean_x,mean_y,mean_rad);
end



fclose(test_localisePRN_sigmaResultsFileID);

copyfile('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localisePRNResults_sigma.txt','C:\Documents and Settings\Luke\My Documents\Dropbox\Project results\test_localisePRN_sigmaResults.txt')
