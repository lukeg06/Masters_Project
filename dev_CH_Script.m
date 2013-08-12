%Script used in the development of CH localisation.
close all;
clear all;
method = '2D + 3D'
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
sigma = 12;
upper_lip_error = 0;
lower_lip_error = 0;
for imNo = 1:noImages
    imageIn = im2double(imread(strcat(DBpath,imageList{imNo})));
    imageIn2D = rgb2gray(im2double(imread(strcat(DBpath,imageList2D{imNo}))));
    
    
    
    
    leftLimit_x = AL_LeftCoordinates(imNo,1) - (0.7 * norm(AL_LeftCoordinates(imNo,1)-AL_RightCoordinates(imNo,1)));
    rightLimit_x = AL_RightCoordinates(imNo,1) + (0.7 * norm(AL_LeftCoordinates(imNo,1)-AL_RightCoordinates(imNo,1)));
    
    %% Detect curvature
    
    ind_Img = strmatch(imageList{imNo},dbList);
    
    
    [H, K] =  curvature(imageIn,sigma);
    
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
    
    
    %% Define 20mmx20mm window around detected peak;
    windowSizeTotal = [30 11]./3;
    windowSize = windowSizeTotal./2;
    imageMaskedFinal = zeros(size(imageIn));
    image1 = imageIn;
    centerPoint = round(mm2pixel(maxLocation./3)); % round before to keep matlab happy
    %% Load
    
    
    %% Generate Bank
    filterBank = FilterBank();
    response3D = filterBank.filterImage(imresize(imageIn,1/3));
    responseMaskedRegion3D = response3D(:,(centerPoint(2) - round(windowSize(2)/0.32)):(centerPoint(2) + round(windowSize(2)/0.32)),...
        (centerPoint(1) - round(windowSize(1)/0.32)):(centerPoint(1) + round(windowSize(1)/0.32)));
    clear response3D;
    
    response2D = filterBank.filterImage(imResize(imageIn2D,1/3));
    responseMaskedRegion2D = response2D(:,(centerPoint(2) - round(windowSize(2)/0.32)):(centerPoint(2) + round(windowSize(2)/0.32)),...
        (centerPoint(1) - round(windowSize(1)/0.32)):(centerPoint(1) + round(windowSize(1)/0.32)));
    clear response2D;
    
    %%
    k = 0;
    % jets[40,noPixels]
    
    
    
    jetIndex =zeros(size(responseMaskedRegion3D,2)*size(responseMaskedRegion3D,3),2);
    switch method
        case '2D + 3D'
            jets = zeros(80,size(responseMaskedRegion3D,2)*size(responseMaskedRegion3D,3));
            for i = 1:size(responseMaskedRegion3D,2)
                for j = 1:size(responseMaskedRegion3D,3)
                    k = k+1;
                    jets(:,k) = [responseMaskedRegion2D(:,i,j);responseMaskedRegion3D(:,i,j)];
                    jetIndex(k,:) = [i j];
                end
                
            end
        case '2D'
            jets = zeros(40,size(responseMaskedRegion2D,2)*size(responseMaskedRegion2D,3));
            for i = 1:size(responseMaskedRegion2D,2)
                for j = 1:size(responseMaskedRegion3D,3)
                    k = k+1;
                    jets(:,k) = [responseMaskedRegion2D(:,i,j)];
                    jetIndex(k,:) = [i j];
                end
                
            end
            
        case '3D'
            jets = zeros(40,size(responseMaskedRegion3D,2)*size(responseMaskedRegion3D,3));
            for i = 1:size(responseMaskedRegion3D,2)
                for j = 1:size(responseMaskedRegion3D,3)
                    k = k+1;
                    jets(:,k) = [responseMaskedRegion3D(:,i,j)];
                    jetIndex(k,:) = [i j];
                end
                
            end
    end
    
    % Identify the search region. Each pixel from this is then extracted
    
    [outCalculateSimilarity] =  calculateSimilarity(jets,'CH Left',method,jetIndex);
    c = jetIndex(outCalculateSimilarity.index,:);
    
    a = zeros(size(imageIn));
    b = zeros(size(responseMaskedRegion3D,2),size(responseMaskedRegion3D,3));
    b(c(1),c(2)) = 1;
    a((centerPoint(2) - round(windowSize(2)/0.32)):(centerPoint(2) + round(windowSize(2)/0.32)),...
        (centerPoint(1) - round(windowSize(1)/0.32)):(centerPoint(1) + round(windowSize(1)/0.32))) ...
        = b;
    
    [~,p] = max(a(:));
    [c1(2),c1(1)] = ind2sub(size(a),p);
    
    Output.EnLeftLocation = pixel2mm(c1.*3);
    
    fprintf(FileID,'%d\t%d\t%d\n',sigma,upper_lip_error,lower_lip_error);
    
end
fclose(FileID);