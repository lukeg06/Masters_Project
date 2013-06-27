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
% alLocationFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\ALLocations.txt','w');
% test_localiseALRightResultsFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseALRightResults.txt','w');
% test_localiseALLeftResultsFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseALLeftResults.txt','w');
% 
% fprintf(test_localiseALRightResultsFileID,'No.\tX Error(mm)\tY Error(mm)\tRad Error(mm)\n');
% fprintf(test_localiseALLeftResultsFileID,'No.\tX Error(mm)\tY Error(mm)\tRad Error(mm)\n');

alsigmaFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\AL_Sigma.txt','w');
fprintf(alsigmaFileID,'sigma\tx_el_std\tx_er_std\ty_el_std\ty_er_std\trad_el_std\trad_er_std\tx_el_mean\tx_er_mean\ty_el_mean\ty_er_mean\trad_el_mean\trad_er_mean\tErrors\n');


for sigma = 20:30
    errors = 0;
for i = 1:200
 
    imageIn = im2double(imread(strcat(DBpath,imageList{i})));
    prnLocation = prncoordinates(i,:);
     [ALLocation] =localiseAL3_widest(imageIn,prnLocation,[50 42],sigma,'false');
 
%     if ALLocation == 0
%          fprintf(test_localiseALRightResultsFileID,'%d\t1234\t1234\t1234\n',i,x_error_right,y_error_right,rad_error_right);
%          fprintf(test_localiseALRightResultsFileID,'%d\t1234\t1234\t1234\n',i,x_error_right,y_error_right,rad_error_right);
%            fprintf('%d\t1234\t1234\t1234\n',i,x_error_right,y_error_right,rad_error_right);
%            continue;
%     end
    
   ind = strmatch(imageList{i},dbList);
   
   if size(ALLocation,1) == 2
  %Calute error & print to file
   x_error_left(i) = abs(ALLocation(1,1) - landmarkLocations(11,1,ind));
   y_error_left(i) = abs(ALLocation(1,2) - landmarkLocations(11,2,ind));
   rad_error_left(i) = norm(ALLocation(1,:) - landmarkLocations(11,:,ind));
   %fprintf(test_localiseALLeftResultsFileID,'%d\t%f\t%f\t%f\n',i,x_error_left,y_error_left,rad_error_left);

    x_error_right(i) = abs(ALLocation(2,1) - landmarkLocations(12,1,ind));
   y_error_right(i) = abs(ALLocation(2,2) - landmarkLocations(12,2,ind));
   rad_error_right(i) = norm(ALLocation(2,:) - landmarkLocations(12,:,ind));
   %fprintf(test_localiseALRightResultsFileID,'%d\t%f\t%f\t%f\n',i,x_error_right,y_error_right,rad_error_right);

    %fprintf('%d\t%f\t%f\t%f\n',i,x_error_right,y_error_right,rad_error_right);
   else 
       errors = errors+1;
       continue
   end
end
x_el_std = std(x_error_left);
x_er_std = std(x_error_right);

y_el_std = std(y_error_left);
y_er_std = std(y_error_right);

rad_el_std = std(rad_error_left);
rad_er_std = std(rad_error_right);

x_el_mean = mean(x_error_left);
x_er_mean = mean(x_error_right);

y_el_mean = mean(y_error_left);
y_er_mean = mean(y_error_right);

rad_el_mean = mean(rad_error_left);
rad_er_mean = mean(rad_error_right);

fprintf(alsigmaFileID,'%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%d\n',sigma,x_el_std,x_er_std,y_el_std,y_er_std,rad_el_std,rad_er_std,x_el_mean,x_er_mean,y_el_mean,y_er_mean,rad_el_mean,rad_er_mean,errors);
end

fclose(alsigmaFileID);

copyfile('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\AL_Sigma.txt','C:\Documents and Settings\Luke\My Documents\Dropbox\Project results\AL_Sigma.txt')
% copyfile('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseALLeftResults.txt'
% ,'C:\Documents and Settings\Luke\My Documents\Dropbox\Project results\test_localiseAL_left.txt')