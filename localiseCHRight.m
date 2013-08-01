function [output] = localiseCHRight(imageIn,imageIn2D,prncoordinates,AL_LeftCoordinates,AL_RightCoordinates,method)

leftLimit_x = AL_LeftCoordinates(1) - (0.7 * norm(AL_LeftCoordinates( 1)-AL_RightCoordinates( 1)));
rightLimit_x = AL_RightCoordinates(1) + (0.7 * norm(AL_LeftCoordinates( 1)-AL_RightCoordinates( 1)));


%% Detect curvature


sigma = 11;
[~, K] =  curvature(imageIn,sigma);

K_eliptical = bsxfun(@max,zeros(size(K)),K);
K_eliptical(mm2pixel(prncoordinates( 2)):end,mm2pixel(prncoordinates( 1)));

%Find first trough
[valT ind1] = findpeaks(K(mm2pixel(prncoordinates( 2)):end,mm2pixel(prncoordinates( 1))).*-1);

[valP ind] = findpeaks(K(mm2pixel(prncoordinates( 2)):end,mm2pixel(prncoordinates( 1))));


indSubPrn = find(ind>ind1(1));
[valChin indChin] = max(valP(indSubPrn));

indLips = indSubPrn(indSubPrn<=indSubPrn(indChin));


if size(indLips,2)<3
    
    % Expecting at least three peaks. The upper and lower lip and the chin.
    % Sometimes one or other of the lips isnt detected. In the case we take
    % the trough after the nose and the one before the chin as the limits.
 
    
    ind_chinTrough = find(ind1<ind(indLips(indChin)),1,'last');
    lower_limit = pixel2mm(mm2pixel(prncoordinates( 2)) + ind1(ind_chinTrough)) ;
    %trough after nose
    upper_limit = pixel2mm((mm2pixel(prncoordinates( 2)) + ind1(1)) );
else
    %Take two largest valid peaks as max.
    
%    [svals sind] = sort(valP(indLips),'descend');
%    indLipsSorted = indLips(sind);
    lower_limit = pixel2mm(mm2pixel(prncoordinates( 2)) + ind(indLips(end-1))) ;
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


%% Define 20mmx20mm window around detected peak;
windowSizeTotal = [30 11]./3;
windowSize = windowSizeTotal./2;
centerPoint = round(mm2pixel(maxLocation./3)); % round before to keep matlab happy

%% Generate Bank
filterBank = FilterBank();
response3D = filterBank.filterImage(imresize(imageIn,1/3));
responseMaskedRegion3D = response3D(:,(centerPoint(2) - round(windowSize(2)/0.32)):(centerPoint(2) + round(windowSize(2)/0.32)),...
    (centerPoint(1) - round(windowSize(1)/0.32)):(centerPoint(1) + round(windowSize(1)/0.32)));
clear response3D;

response2D = filterBank.filterImage(imresize(imageIn2D,1/3));
responseMaskedRegion2D = response2D(:,(centerPoint(2) - round(windowSize(2)/0.32)):(centerPoint(2) + round(windowSize(2)/0.32)),...
    (centerPoint(1) - round(windowSize(1)/0.32)):(centerPoint(1) + round(windowSize(1)/0.32)));
clear response2D;

%%
k = 0;

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

[outCalculateSimilarity] =  calculateSimilarity(jets,'CH Right',method,jetIndex);
c = jetIndex(outCalculateSimilarity.index,:);

a = zeros(size(imageIn));
b = zeros(size(responseMaskedRegion3D,2),size(responseMaskedRegion3D,3));
b(c(1),c(2)) = 1;
a((centerPoint(2) - round(windowSize(2)/0.32)):(centerPoint(2) + round(windowSize(2)/0.32)),...
    (centerPoint(1) - round(windowSize(1)/0.32)):(centerPoint(1) + round(windowSize(1)/0.32))) ...
    = b;

[~,p] = max(a(:));
[c1(2),c1(1)] = ind2sub(size(a),p);

output.ChRightLocation = pixel2mm(c1.*3);