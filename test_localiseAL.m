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
al_Left_LocationFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\AL_left_Locations.txt','w');
al_Right_LocationFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\AL_right_Locations.txt','w');
test_localiseALRightResultsFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseALRightResults.txt','w');
test_localiseALLeftResultsFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseALLeftResults.txt','w');

fprintf(test_localiseALRightResultsFileID,'No.\tX Error(mm)\tY Error(mm)\tRad Error(mm)\n');
fprintf(test_localiseALLeftResultsFileID,'No.\tX Error(mm)\tY Error(mm)\tRad Error(mm)\n');

for i = 1:noImages
   
    
    error = 0;
    %Error codes
    %1 = search region two small
    %2 = left point not detected 1st time
    %3 = right point not detected 1st time
    %
    
    imageIn = im2double(imread(strcat(DBpath,imageList{i})));
    prnLocation = prncoordinates(i,:);
    [Output] =localiseAL3_widest(imageIn,prnLocation,[50 42],21,'true','right','false');
    ALLocation = Output.ALLocation;
    
%     
%     if ALLocation == 0
%         error = 1;
%         [Output] = localiseAL3_widest(imageIn,prnLocation,[60 42],21,'false','right','false');
%         ALLocation = Output.ALLocation;
%     end
%     
%     if ALLocation == 0
%         fprintf(test_localiseALRightResultsFileID,'%d\n',i);
%         fprintf(test_localiseALLeftResultsFileID,'%d\n',i);
%         fprintf('Error in image %d \n',i);
%         continue;
%         
%     end
%     
%     if isempty(ALLocation)
%          error = 1;
%         [Output] = localiseAL3_widest(imageIn,prnLocation,[60 42],21,'false','right','false');
%         ALLocation = Output.ALLocation;
%     end
%     
%     if isempty(ALLocation)
%         fprintf(test_localiseALRightResultsFileID,'%d\n',i);
%         fprintf(test_localiseALLeftResultsFileID,'%d\n',i);
%         fprintf('Error in image %d \n',i);
%         continue;
%     end
    
    % Try expanding search region. 5mm each side.
    if size(ALLocation,1) ~= 2
         error = 1;
        [Output] = localiseAL3_widest(imageIn,prnLocation,[60 42],21,'false','right','false');
        ALLocation = Output.ALLocation;
    end
    
    % If expanding didn't work then try looking searching for other
    % contour.
    
    if size(ALLocation,1) ~= 2
        
        if isequal(Output.errors,[0,1])
             error = 3;
            reverse = 'true';
            [Output] =localiseAL3_widest(imageIn,prnLocation,[50 42],21,'false','right',reverse);
            ALLocation = Output.ALLocation;
            leftAL = ALLocation;
            
            
            %left point detected. Get the right.
            [Output] = localiseAL3_widest(imageIn,prnLocation,[50 42],21,'false','right',reverse);
            rightAL = Output.ALLocation;
            ALLocation = [leftAL;rightAL];
        elseif isequal(Output.errors,[1,0])
             error = 2;
            reverse = 'true';
            [Output] =localiseAL3_widest(imageIn,prnLocation,[50 42],21,'false','right',reverse);
            ALLocation = Output.ALLocation;
            rightAL = ALLocation;
            %right detected. Get left.
            [Output] = localiseAL3_widest(imageIn,prnLocation,[50 42],21,'false','left',reverse);
            leftAL = Output.ALLocation;
            ALLocation = [leftAL;rightAL];
        else
            fprintf(test_localiseALRightResultsFileID,'%d\n',i);
            fprintf(test_localiseALLeftResultsFileID,'%d\n',i);
              fprintf(al_Left_LocationFileID,'%f\t%f\n',0,0);
            fprintf(al_Right_LocationFileID,'%f\t%f\n',0,0);
            fprintf('Error in image %d \n',i);
            continue;
        end
        if size(ALLocation,1) ~= 2
            fprintf(test_localiseALRightResultsFileID,'%d\n',i);
            fprintf(test_localiseALLeftResultsFileID,'%d\n',i);
            fprintf(al_Left_LocationFileID,'%f\t%f\n',0,0);
            fprintf(al_Right_LocationFileID,'%f\t%f\n',0,0);
            fprintf('Error in image %d \n',i);
            continue;
        end
        
    end
    
    
    
    
    
    ind = strmatch(imageList{i},dbList);
    %Calute error & print to file
    x_error_left = abs(ALLocation(1,1) - landmarkLocations(11,1,ind));
    y_error_left = abs(ALLocation(1,2) - landmarkLocations(11,2,ind));
    rad_error_left = norm(ALLocation(1,:) - landmarkLocations(11,:,ind));
    fprintf(test_localiseALLeftResultsFileID,'%d\t%f\t%f\t%f\t%d\n',i,x_error_left,y_error_left,rad_error_left,error);
    
    x_error_right = abs(ALLocation(2,1) - landmarkLocations(12,1,ind));
    y_error_right = abs(ALLocation(2,2) - landmarkLocations(12,2,ind));
    rad_error_right = norm(ALLocation(2,:) - landmarkLocations(12,:,ind));
    fprintf(test_localiseALRightResultsFileID,'%d\t%f\t%f\t%f\t%d\n',i,x_error_right,y_error_right,rad_error_right,error);
    
    fprintf('%d\t%f\t%f\t%f\n',i,x_error_left,y_error_left,rad_error_left);
    %     plotLandmark([landmarkLocations(12,:,ind);landmarkLocations(11,:,ind)],gcf)
    %     pause;
    %     close(gcf)
    
    fprintf(al_Left_LocationFileID,'%f\t%f\n',ALLocation(1,1),ALLocation(1,2));
    fprintf(al_Right_LocationFileID,'%f\t%f\n',ALLocation(2,1),ALLocation(2,2));
end

fclose(al_Left_LocationFileID);
fclose(al_Right_LocationFileID);
fclose(test_localiseALRightResultsFileID);
fclose(test_localiseALLeftResultsFileID);

copyfile('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseALRightResults.txt','C:\Documents and Settings\Luke\My Documents\Dropbox\Project results\test_localiseAL_right.txt')
copyfile('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseALLeftResults.txt','C:\Documents and Settings\Luke\My Documents\Dropbox\Project results\test_localiseAL_left.txt')
