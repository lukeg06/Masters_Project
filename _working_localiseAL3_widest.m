% Localise AL2
function [Output] = localiseAL3_widest(imageIn,PRNLocation,windowSizeTotal,sigma,displayImage,direction)

addpath('./toolboxes/chaincode/')

imageEdge = edge(imageIn,'log',0,7);


% Check to see if the user has specified a specific direction for the
% algorithm to search in.
if ~exist('direction','var')
    direction = 'right';
end


%Define search region around  prn.
windowSize = windowSizeTotal./2;
imageMasked = zeros(size(imageIn));
prn_coordinates = round(mm2pixel(PRNLocation)); % round before to keep matlab happy
imageMasked((prn_coordinates(2) - round(windowSize(2)/0.32)):(prn_coordinates(2) + round(windowSize(2)/0.32)),...
    (prn_coordinates(1) - round(windowSize(1)/0.32)):(prn_coordinates(1) + round(windowSize(1)/0.32))) ...
    = imageEdge((prn_coordinates(2) - round(windowSize(2)/0.32)):(prn_coordinates(2) + round(windowSize(2)/0.32)),...
    (prn_coordinates(1) - round(windowSize(1)/0.32)):(prn_coordinates(1) + round(windowSize(1)/0.32)));

%
%% Find the edges of the nose by moving out horizontally from the icp estimage

%Remove Junctions
a = vsg('Junctions',imageMasked.*255);
imageMasked = xor(a,imageMasked);

% Label edges
image_labelled = bwlabeln(imageMasked,8);

% From the prn_coordinate look for the the first edge in to the right
label_value = searchForContour(direction);

% If for some reason didn't find contour in the initial direction then
% search for it the other way.
if isempty(label_value)
    if isequal(direction,'right')
        direction = 'left';
    elseif isequal(direction,'left')
          direction = 'right';
    end
    label_value = searchForContour(direction);  
end


% isoloate nose edge.
imageNoseEdge = bsxfun(@eq,image_labelled,(ones(size(imageIn)).*label_value));


% check to make sure we don't have a closed contour
limbEnds = vsg('LimbEnds',imageNoseEdge.*255)./255;

if sum(limbEnds(:)) ==0
    
    imageMasked = xor(imageMasked,imageNoseEdge);
    image_labelled = bwlabeln(imageMasked,8);

    label_value = searchForContour(direction);

% If for some reason didn't find contour in the initial direction then
% search for it the other way.
if isempty(label_value)
    if isequal(direction,'right')
        direction = 'left';
    elseif isequal(direction,'left')
          direction = 'right';
    end
    label_value = searchForContour(direction);  
end

    % isoloate nose edge.
    imageNoseEdge = bsxfun(@eq,image_labelled,(ones(size(imageIn)).*label_value));
end

% Traverse noseContour
noseContour = contour2xy2(imageNoseEdge);


if noseContour == 0;
    Output.ALLocation = 0;
    return;
end
chainCode = chaincode([noseContour(:,1) noseContour(:,2)],'true');
%%
a = -round(3.75*sigma):round(3.75*sigma);
g = (-a./((sigma.^3).*sqrt(2*pi))).*exp((-a.^2)./(2*(sigma.^2)));
%g_norm = g./sum(g(:));
g_norm = g;

%%
dog = conv(chainCode.ucode,g_norm,'same');



%[val ind] = findpeaks(dog,'minpeakheight',0.05);
[val ind] = findpeaks(dog);
criticalPoints = zeros(size(ind,2),2);
y = 1;
for k = 1:size(ind,2)
    i = ind(k);
    criticalPoints(y,:) = [noseContour(i,2) noseContour(i,1)];
    y = y+1;
end



% Locate leftmost and rightmost critical points which are closest to the
% PRN along the vertical direction. Go left and right 1st up and down

%
rightInds = find(criticalPoints(:,1)>prn_coordinates(1));
leftInds = find(criticalPoints(:,1)<prn_coordinates(1));

rightPts = sortrows(criticalPoints(rightInds,:),2);
leftPts = sortrows(criticalPoints(leftInds,:),2);

if size(leftPts,1) > 1
    possibleLeft = [leftPts(:,:)];
else
    possibleLeft =leftPts;
end
%[~,indLeftFinal] = min(abs((possibleLeft(:,2)- prn_coordinates(2))));

[~,ind_l] = min(possibleLeft(:,1));
leftAL = possibleLeft(ind_l,:);

%
if size(rightPts,1) > 1
    possibleRight = rightPts(:,:);
else
    possibleRight = rightPts;
end

%[~,indRightFinal] = min(abs((possibleRight(:,2)- prn_coordinates(2))));
[~,ind_r] = max(possibleRight(:,1));
rightAL = possibleRight(ind_r,:);

% Check to see if either of the two points hasn't been detected. If not
% check to see if getting the other contour will fix the issue. Left in
% most cases. Set an error flag.



%Check left not detected
if isempty(leftAL)
    detectionErrorLeft = 1;
else
    detectionErrorLeft = 0;
end

% Check if right not detected
if isempty(rightAL)
    detectionErrorRight = 1;
else
    detectionErrorRight = 0;
end



Output.errors = [detectionErrorLeft,detectionErrorRight];
Output.ALLocation =  [pixel2mm(leftAL);pixel2mm(rightAL)];


% Display
if strcmp(displayImage,'true')
    figure,
    subplot(2,2,1),imagesc(imageIn),title('Input Image');
    subplot(2,2,2),imagesc(imageNoseEdge),title('Nose Contour');
    subplot(2,2,3),imshow(imageNoseEdge);
    hold on;
    for i = 1:size(ind,2)
        plot(noseContour(ind,2),noseContour(ind,1),'*y');
    end
    plotLandmark(PRNLocation,gcf)
    hold off;title('Critical Points')
    
    subplot(2,2,4),imshow(imageIn),title('AL Locations');
    hold on;
    plot(mm2pixel(ALLocation(1,1)),mm2pixel(ALLocation(1,2)),'*m');
    plot(mm2pixel(ALLocation(2,1)),mm2pixel(ALLocation(2,2)),'*m');
    hold off;
    
end






% Nested functions.Have access to parents variable so no need to worry
% about
    function [label_value] = searchForContour(direction)
        
        if isequal(direction,'left')
            ind = find(image_labelled(prn_coordinates(2),prn_coordinates(1):-1:1)>0,1,'first');
            label_value = image_labelled(prn_coordinates(2),prn_coordinates(1)-(ind-1));
        elseif isequal(direction,'right')
            ind = find(image_labelled(prn_coordinates(2),prn_coordinates(1):end)>0,1,'first');
            label_value = image_labelled(prn_coordinates(2),prn_coordinates(1)+(ind-1));
        else
            error('Direction for search contour has not been defined')
        end
        
    end


end