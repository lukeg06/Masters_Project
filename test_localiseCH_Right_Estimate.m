%Script used in the development of CH localisation.
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
prnLocations= A(:,2:3); clear A;

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



% Define savefile paths
%opex files for writing results
savefilename1  = strcat('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\CH_right_Locations_','estimate','.txt');
savefilename2 =  strcat('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseCHRightResults_','estimate','.txt');

ch_Right_LocationFileID = fopen(savefilename1,'w');
test_localiseCHRightResultsFileID = fopen(savefilename2,'w');

fprintf(test_localiseCHRightResultsFileID,'No.\tX Error(mm)\tY Error(mm)\tRad Error(mm)\n');

for imNo = 1:noImages
    prncoordinates = prnLocations(imNo,:);
    imageIn = im2double(imread(strcat(DBpath,imageList{imNo})));
    imageIn2D = rgb2gray(im2double(imread(strcat(DBpath,imageList2D{imNo}))));
    
    
    
    
   addpath('.\toolboxes\segundo2010');
leftLimit_x = AL_LeftCoordinates(1) - (0.7 * norm(AL_LeftCoordinates( 1)-AL_RightCoordinates( 1)));
rightLimit_x = AL_RightCoordinates(1) + (0.7 * norm(AL_LeftCoordinates( 1)-AL_RightCoordinates( 1)));

%% Detect curvature


sigma = 10;
[~, K] =  curvature(imageIn,sigma);

K_eliptical = bsxfun(@max,zeros(size(K)),K);
K_eliptical(mm2pixel(prncoordinates( 2)):end,mm2pixel(prncoordinates( 1)));

%Find first trough
[ind1] = peakFind_1d( K(mm2pixel(prncoordinates( 2)):end,mm2pixel(prncoordinates( 1))).*-1, 6 )';

[ind] = peakFind_1d( K(mm2pixel(prncoordinates( 2)):end,mm2pixel(prncoordinates( 1))), 2 )';
a= K(mm2pixel(prncoordinates( 2)):end,mm2pixel(prncoordinates( 1)));
valP = a(ind);

indSubPrn = find(ind>ind1(1));
%[valChin indChin] = max(valP(indSubPrn));
indLips = indSubPrn(indSubPrn<=indSubPrn(end));


if size(indLips,2)<3
    
    % Expecting at least three peaks. The upper and lower lip and the chin.
    % Sometimes one or other of the lips isnt detected. In the case we take
    % the trough after the nose and the one before the chin as the limits.
 
    
    ind_chinTrough = find(ind1<ind(indLips(end)),1,'last');
    lower_limit = pixel2mm(mm2pixel(prncoordinates( 2)) + ind1(ind_chinTrough)) ;
    %trough after nose
    upper_limit = pixel2mm((mm2pixel(prncoordinates( 2)) + ind1(1)) );
else
    %Take two largest valid peaks as max.
    
%    [svals sind] = sort(valP(indLips),'descend');
%    indLipsSorted = indLips(sind);
    lower_limit = pixel2mm(mm2pixel(prncoordinates( 2)) + ind(indLips(2))) ;
    upper_limit = pixel2mm((mm2pixel(prncoordinates( 2)) + ind(indLips(1))) );
end
    sigma2 = 2;
    [H, ~] =  curvature(imageIn,sigma2);
    
  %%
H_Masked_right = ones(size(imageIn)).*min(H(:));
H_Masked_right((mm2pixel(upper_limit):mm2pixel(lower_limit)),(mm2pixel(AL_RightCoordinates( 1)):mm2pixel(rightLimit_x)))...
    = H((mm2pixel(upper_limit):mm2pixel(lower_limit)),(mm2pixel(AL_RightCoordinates( 1)):mm2pixel(rightLimit_x)));

%%
%Find location of global maximum
imageMasked = H_Masked_right;
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

y_error = abs(maxLocation(1) - landmarkLocations(16,1,ind_Img));
x_error = abs(maxLocation(2) - landmarkLocations(16,2,ind_Img));
euclidean_error = norm(maxLocation - landmarkLocations(16,:,ind_Img));



 fprintf(test_localiseCHRightResultsFileID,'%d\t%f\t%f\t%f\n',imNo,x_error,y_error,euclidean_error);
    fprintf('%d\t%f\t%f\t%f\n',imNo,x_error,y_error,euclidean_error);
    fprintf(ch_Right_LocationFileID,'%f\t%f\n',maxLocation(1),maxLocation(2));
    

end
