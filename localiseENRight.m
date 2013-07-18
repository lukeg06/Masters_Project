function [Output] = localiseENRight(imageIn,imageIn2D,prncoordinates,AL_LeftCoordinates,AL_RightCoordinates,method)

%% Define Search Region

%Find location of highest vertical point of image
nonZero = find(imageIn>0);
[i_row,j_col] =ind2sub(size(imageIn),nonZero);
V_y = min(i_row);

prn_x = prncoordinates(1);

upperLimit_y = prncoordinates(2)- (0.3803*1.5*norm(prncoordinates(2)-pixel2mm(V_y)));
lowerLimit_y = prncoordinates(2)- (0.3803*0.3803*norm(prncoordinates(2)-pixel2mm(V_y)));

leftLimit_x = AL_LeftCoordinates(1) - (0.5 * norm(AL_LeftCoordinates(1)-AL_RightCoordinates(1)));
rightLimit_x = AL_RightCoordinates(1) + (0.5 * norm(AL_LeftCoordinates(1)-AL_RightCoordinates(1)));



%% Detect curvature
sigma = 15;
[H, K] =  curvature(imageIn,sigma);

%find where H > 0; ie convave
H_concave = bsxfun(@max,zeros(size(H)),H);
H_concave_bin = bsxfun(@eq,H_concave,H);

K_concave = bsxfun(@times,H_concave_bin,K);

K_masked_left = zeros(size(K_concave));
K_masked_left(mm2pixel(upperLimit_y):mm2pixel(lowerLimit_y),mm2pixel(leftLimit_x):mm2pixel(prn_x)) = K_concave(mm2pixel(upperLimit_y):mm2pixel(lowerLimit_y),mm2pixel(leftLimit_x):mm2pixel(prn_x));

K_masked_right = zeros(size(K));
K_masked_right(mm2pixel(upperLimit_y):mm2pixel(lowerLimit_y),mm2pixel(prn_x):mm2pixel(rightLimit_x)) = K_concave(mm2pixel(upperLimit_y):mm2pixel(lowerLimit_y),mm2pixel(prn_x):mm2pixel(rightLimit_x));

%%
%Find location of global maximum
imageMasked = K_masked_right;
[val ind]= max(imageMasked(:));
[i,j] = ind2sub(size(imageMasked),ind);
% Isolate all pixels with maximum value
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
windowSizeTotal = [20 20]./3;
windowSize = windowSizeTotal./2;
imageMaskedFinal = zeros(size(imageIn));
image1 = imageIn;
centerPoint = round(mm2pixel(maxLocation./3)); % round before to keep matlab happy
% imageMaskedFinal((centerPoint(2) - round(windowSize(2)/0.32)):(centerPoint(2) + round(windowSize(2)/0.32)),...
%     (centerPoint(1) - round(windowSize(1)/0.32)):(centerPoint(1) + round(windowSize(1)/0.32))) ...
%     = image1((centerPoint(2) - round(windowSize(2)/0.32)):(centerPoint(2) + round(windowSize(2)/0.32)),...
%     (centerPoint(1) - round(windowSize(1)/0.32)):(centerPoint(1) + round(windowSize(1)/0.32)));

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

[outCalculateSimilarity] =  calculateSimilarity(jets,'EN Right',method,jetIndex);
c = jetIndex(outCalculateSimilarity.index,:);

a = zeros(size(imageIn));
b = zeros(size(responseMaskedRegion3D,2),size(responseMaskedRegion3D,3));
b(c(1),c(2)) = 1;
a((centerPoint(2) - round(windowSize(2)/0.32)):(centerPoint(2) + round(windowSize(2)/0.32)),...
    (centerPoint(1) - round(windowSize(1)/0.32)):(centerPoint(1) + round(windowSize(1)/0.32))) ...
    = b;

[~,p] = max(a(:));
[c1(2),c1(1)] = ind2sub(size(a),p);

Output.EnRightLocation = pixel2mm(c1.*3);
