%Script to develop ch. Used for determining which sigma value to use.
close all;
clear all;

%15& 16 ch pointss


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
sigma = 11;
for sigma2 = 10:25
    for imNo = 1:10
        imageIn = im2double(imread(strcat(DBpath,imageList{imNo})));
        imageIn2D = rgb2gray(im2double(imread(strcat(DBpath,imageList2D{imNo}))));
        
        
        
        
        leftLimit_x = AL_LeftCoordinates(imNo,1) - (0.7 * norm(AL_LeftCoordinates(imNo,1)-AL_RightCoordinates(imNo,1)));
        rightLimit_x = AL_RightCoordinates(imNo,1) + (0.7 * norm(AL_LeftCoordinates(imNo,1)-AL_RightCoordinates(imNo,1)));
        
        %% Detect curvature
        
        ind_Img = strmatch(imageList{imNo},dbList);
        
        
        [~, K] =  curvature(imageIn,sigma);
        [H, ~] =  curvature(imageIn,sigma2);
        K_eliptical = bsxfun(@max,zeros(size(K)),K);
        K_eliptical(mm2pixel(prncoordinates(imNo,2)):end,mm2pixel(prncoordinates(imNo,1)));
        
        [val ind] = findpeaks(K_eliptical(mm2pixel(prncoordinates(imNo,2)):end,mm2pixel(prncoordinates(imNo,1))));
        
        %Test to check if I am correctly detecting the upper and lower lip.
        %Measure the distance between vertical position of lip and manually
        %selected lip;
        lower_limit = pixel2mm(mm2pixel(prncoordinates(imNo,2)) + ind(3)) ;
        upper_limit = pixel2mm((mm2pixel(prncoordinates(imNo,2)) + ind(2)) );
        %%
        H_Masked_left = zeros(size(imageIn));
        H_Masked_right = zeros(size(imageIn));
        H_Masked_right((mm2pixel(upper_limit):mm2pixel(lower_limit)),(mm2pixel(AL_RightCoordinates(imNo,1)):mm2pixel(rightLimit_x)))...
            = H((mm2pixel(upper_limit):mm2pixel(lower_limit)),(mm2pixel(AL_RightCoordinates(imNo,1)):mm2pixel(rightLimit_x)));
        H_Masked_left((mm2pixel(upper_limit):mm2pixel(lower_limit)),(mm2pixel(leftLimit_x):mm2pixel(AL_LeftCoordinates(imNo,1))))...
            = H((mm2pixel(upper_limit):mm2pixel(lower_limit)),(mm2pixel(leftLimit_x):mm2pixel(AL_LeftCoordinates(imNo,1))));
        
        %%
        %Find location of global maximum
        imageMasked = H_Masked_left;
        [val ind]= max(imageMasked(:));
        [i,j] = ind2sub(size(imageMasked),ind);
        %% Isolate all pixels with maximum value
        mat1 = ones(size(imageMasked)).*val;
        mat2 = double(bsxfun(@eq,mat1,imageMasked));
        % Find larget blob
        [mat3] = vsg('BiggestBlob',uint8(mat2.*255));
        if sum(mat3(:)) ~= 0
            [centroid_mat] = vsg('Centroid',mat3);
            [p1] = vsg('FWP',centroid_mat);
        else
            p1 = [j i];
        end
        
        maxLocation = pixel2mm([p1(1) p1(2)]);
       
         ind_Img = strmatch(imageList{imNo},dbList);
          
        ind_Img = strmatch(imageList{i},dbList);
        %Calute error & print to file
        x_error(imNo) = abs(maxLocation(1) - landmarkLocations(15,1,ind_Img));
        y_error(imNo) = abs(maxLocation(2) - landmarkLocations(15,2,ind_Img));
        euclidean_error(imNo) = norm(maxLocation - landmarkLocations(15,:,ind_Img));
        
       fprintf('%f\t%f\t%f\n',x_error(imNo),y_error(imNo),euclidean_error(imNo));
    end
     results = [mean(x_error),std(x_error),mean(y_error),std(y_error),mean(euclidean_error),std(euclidean_error)];
        
       fprintf(FileID,'%d\t%f\t%f\t%f\t%f\t%f\t%f\n',sigma2,results);
end


fclose(FileID);