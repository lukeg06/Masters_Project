% Function to localise EX

function [output] = localiseEXRight(imageIn,imageIn2D,EN_LeftCoordinates,EN_RightCoordinates,method)



ex_left_estimate = [(EN_LeftCoordinates(1) - norm(EN_LeftCoordinates(1) - EN_RightCoordinates(1))),...
    (EN_LeftCoordinates(2) + EN_RightCoordinates(2))/2];
   ex_right_estimate = [(EN_RightCoordinates(1) + norm(EN_LeftCoordinates(1) - EN_RightCoordinates(1))),...
    (EN_LeftCoordinates(2) + EN_RightCoordinates(2))/2];


 maxLocation = ex_right_estimate;
windowSizeTotal = [30 20]./3;
windowSize = windowSizeTotal./2;
imageMaskedFinal = zeros(size(imageIn));
image1 = imageIn;
centerPoint = round(mm2pixel(maxLocation./3)); % round before to keep matlab happy


% Generate Bank
filterBank = FilterBank();
response3D = filterBank.filterImage(imresize(imageIn,1/3));

if centerPoint(1) + round(windowSize(1)/0.32) > size(response3D,3)
   
    centerPoint(1) = size(response3D,3) - round(windowSize(1)/0.32);
end

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

[outCalculateSimilarity] =  calculateSimilarity(jets,'EX Right',method,jetIndex);
c = jetIndex(outCalculateSimilarity.index,:);

a = zeros(size(imageIn));
b = zeros(size(responseMaskedRegion3D,2),size(responseMaskedRegion3D,3));
b(c(1),c(2)) = 1;
a((centerPoint(2) - round(windowSize(2)/0.32)):(centerPoint(2) + round(windowSize(2)/0.32)),...
    (centerPoint(1) - round(windowSize(1)/0.32)):(centerPoint(1) + round(windowSize(1)/0.32))) ...
    = b;

[~,p] = max(a(:));
[c1(2),c1(1)] = ind2sub(size(a),p);

output.ExRightLocation = pixel2mm(c1.*3);
end