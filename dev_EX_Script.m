% Calculate m' point

%load en locations
filename = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\EN_Results\EN_left_Locations.txt';
A = importdata(filename);
EN_LeftCoordinates = A ;clear A;
filename = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\EN_Results\EN_right_Locations.txt';
A = importdata(filename);
EN_RightCoordinates = A ;clear A;


%%


%Define paths etc
landmarkPath = 'C:\Databases\Texas3DFR\ManualFiducialPoints\';
DBpath = 'C:\Databases\Texas3DFR\PreprocessedImages\';
outputPath = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\';
%%
%load landmarks & image list.
[landmarkLocations] = loadLandmarks(landmarkPath);
[dbList,~]= getDBInfo(DBpath,'range');
imageList = importdata('C:\Databases\Texas3DFR\Partitions\test.txt');
noImages = size(imageList,1);


imageList2D = importdata('C:\Databases\Texas3DFR\Partitions\test_2D.txt');

%% calculate extimate for outer eye corner
for imNo = 1:noImages
    
    
    imageIn = im2double(imread(strcat(DBpath,imageList{imNo})));
    imageIn2D = rgb2gray(im2double(imread(strcat(DBpath,imageList2D{imNo}))));
    
    
ex_left_estimate = [(EN_LeftCoordinates(imNo,1) - norm(EN_LeftCoordinates(imNo,1) - EN_RightCoordinates(imNo,1))),...
    (EN_LeftCoordinates(imNo,2) + EN_RightCoordinates(imNo,2))/2];
   ex_right_estimate = [(EN_RightCoordinates(imNo,1) + norm(EN_LeftCoordinates(imNo,1) - EN_RightCoordinates(imNo,1))),...
    (EN_LeftCoordinates(imNo,2) + EN_RightCoordinates(imNo,2))/2];


 maxLocation = ex_left_estimate;
windowSizeTotal = [30 20]./3;
windowSize = windowSizeTotal./2;
imageMaskedFinal = zeros(size(imageIn));
image1 = imageIn;
centerPoint = round(mm2pixel(maxLocation./3)); % round before to keep matlab happy
% imageMaskedFinal((centerPoint(2) - round(windowSize(2)/0.32)):(centerPoint(2) + round(windowSize(2)/0.32)),...
%     (centerPoint(1) - round(windowSize(1)/0.32)):(centerPoint(1) + round(windowSize(1)/0.32))) ...
%     = image1((centerPoint(2) - round(windowSize(2)/0.32)):(centerPoint(2) + round(windowSize(2)/0.32)),...
%     (centerPoint(1) - round(windowSize(1)/0.32)):(centerPoint(1) + round(windowSize(1)/0.32)));

% Load


% Generate Bank
filterBank = FilterBank();
response3D = filterBank.filterImage(imresize(imageIn,1/3));
responseMaskedRegion3D = response3D(:,(centerPoint(2) - round(windowSize(2)/0.32)):(centerPoint(2) + round(windowSize(2)/0.32)),...
    (centerPoint(1) - round(windowSize(1)/0.32)):(centerPoint(1) + round(windowSize(1)/0.32)));
clear response3D;

response2D = filterBank.filterImage(imResize(imageIn2D,1/3));
responseMaskedRegion2D = response2D(:,(centerPoint(2) - round(windowSize(2)/0.32)):(centerPoint(2) + round(windowSize(2)/0.32)),...
    (centerPoint(1) - round(windowSize(1)/0.32)):(centerPoint(1) + round(windowSize(1)/0.32)));
clear response2D;

%
k = 0;
% jets[40,noPixels]

method = '2D';

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

[outCalculateSimilarity] =  calculateSimilarity(jets,'EX Left',method,jetIndex);
c = jetIndex(outCalculateSimilarity.index,:);

a = zeros(size(imageIn));
b = zeros(size(responseMaskedRegion3D,2),size(responseMaskedRegion3D,3));
b(c(1),c(2)) = 1;
a((centerPoint(2) - round(windowSize(2)/0.32)):(centerPoint(2) + round(windowSize(2)/0.32)),...
    (centerPoint(1) - round(windowSize(1)/0.32)):(centerPoint(1) + round(windowSize(1)/0.32))) ...
    = b;

[~,p] = max(a(:));
[c1(2),c1(1)] = ind2sub(size(a),p);

ExLeftLocation = pixel2mm(c1.*3);

    ind_Img = strmatch(imageList{imNo},dbList);

y_error = abs(ExLeftLocation(1) - landmarkLocations(4,1,ind_Img))
x_error = abs(ExLeftLocation(2) - landmarkLocations(4,2,ind_Img))
euclidean_error = norm(ExLeftLocation - landmarkLocations(4,:,ind_Img))

end