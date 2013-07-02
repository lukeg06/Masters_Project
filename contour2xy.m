function [coordinates_out] = contour2xy(contourImage,reverse)

% [imageList,noImages]= getDBInfo(DBpath,imageType)
%
%Input,
%       ContourImage: Binary image in containing a single contour
%
%       
%
%Output,
%       coordinates: [y,x] coodinates of each pixel in the contour. Works
%       from one limbend of the contour to the other.


[imageLimbEnds] = (vsg('LimbEnds',uint8(contourImage)*255))./255;

% Seach for [0 0 0
%            0 1 0
%            1 0 1]
% and rotational varients which could lead to false detection of limb ends.

if exist('reverse','var')
    if ~or(strcmp(reverse,'true'),strcmp(reverse,'false'))
        reverse = 'false';
    end
else
    reverse = 'false';
end

a = [0 0 0;0 1 0;1 0 1];
b0 = imerode(double(contourImage),a);
b90 = imerode(double(contourImage),rot90(a,1));
b180 = imerode(double(contourImage),rot90(a,2));
b270 = imerode(double(contourImage),rot90(a,3));


b = b0|b90|b180|b270;
c = and(imageLimbEnds,b);

imageLimbEnds = xor(c,imageLimbEnds);

% Check to see that contour is valid


if(sum(imageLimbEnds(:)) ~= 2)
    
    error('Issue with contour. Possibly more than one contour present');
end



%% Find start and end point coordinates
[p1] = vsg('FWP',imageLimbEnds.*255);
p1(1) = p1(1)+1;
p1(2) = p1(2)+1;
temp = imageLimbEnds.*255;
temp(p1(2),p1(1)) = 0;
[p2] =  vsg('FWP',temp);
p2(1) = p2(1)+1;
p2(2) = p2(2)+1;

pts = [p1;p2];
pts_sorted= sortrows(pts,1);

startPt = pts_sorted(1,:);
endPt = pts_sorted(2,:);
%% Start at startPoint and move along point to end point
currentPt = startPt;
previousPt = 0;
found = 0;
previousPreviousPt = 0;
coordinates(1,:)= startPt';
k = 2;
while ~isequal(currentPt,endPt)
    for i = -1:1
        
        for j = -1:1
           testPt = [currentPt(1)+i;currentPt(2)+j];
           if ~isequal(testPt,previousPt)
               if ~isequal(previousPreviousPt,testPt)
                  if ~isequal(testPt,currentPt)
                       if (contourImage(testPt(2),testPt(1)) == 1)
                                nextPt = testPt;
                                found = 1;
                                break;
                       end
                  end
               end
           end
           
        end
        if found == 1
            found = 0;
            break;
        end
        
    end
    
   previousPreviousPt = previousPt;
    previousPt = currentPt;
    currentPt = nextPt;
    coordinates(k,:)= nextPt';
    k = k+1;
end


%Swap x and y and reverse order
if strcmp(reverse,'true')
coordinates_out = [coordinates(end-1:-1:1,2),coordinates(end-1:-1:1,1)];
else
coordinates_out = [coordinates(:,2),coordinates(:,1)];
end