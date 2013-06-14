function [coordinates_out] = contour2xy2(contourImage)

contourImagecp= contourImage;
[imageLimbEnds] = (vsg('LimbEnds',uint8(contourImage)*255))./255;

% Seach for [0 0 0
%            0 1 0
%            1 0 1]
% and rotational varients which could lead to false detection of limb ends.

a = [0 0 0;0 1 0;1 0 1];
b0 = imerode(double(contourImage),a);
b90 = imerode(double(contourImage),rot90(a,1));
b180 = imerode(double(contourImage),rot90(a,2));
b270 = imerode(double(contourImage),rot90(a,3));


b = b0|b90|b180|b270;
c = and(imageLimbEnds,b);

imageLimbEnds = xor(c,imageLimbEnds);

%%
d = [0 1 0;1 1 0;0 0 0];
e0 = imerode(double(contourImage),d);
e90 = imerode(double(contourImage),rot90(d,1));
e180 = imerode(double(contourImage),rot90(d,2));
e270 = imerode(double(contourImage),rot90(d,3));


e = e0|e90|e180|e270;
contourImage = xor(e,contourImage);
% Check to see that contour is valid


if(sum(imageLimbEnds(:)) ~= 2)
    
    coordinates_out = 0;
        return;
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

pts = [p1,p2];
pts_sorted= sortrows(pts',1)';

startPt = pts_sorted(:,2);
endPt = pts_sorted(:,1);

currentPt = startPt;
contourImage(currentPt(2),currentPt(1)) = 0;

found = 0;

coordinates(1,:)= startPt';
k = 2;

while ~isequal(currentPt,endPt)
    for j = -1:1
        for i = -1:1
            testPt = [currentPt(1)+i;currentPt(2)+j];
           
                 if (contourImage(testPt(2),testPt(1)) == 1)
                                nextPt = testPt;
                                found = 1;
                                break;
                 end
           
        end
         if found == 1
           
            break;
        end
        
    end
    %% What to do if point found
    if found == 1
        currentPt = nextPt;
        coordinates(k,:)= nextPt';
        k = k+1;
        contourImage(testPt(2),testPt(1)) = 0;
         found = 0;
         
    else
        coordinates_out = 0;
        return;
    end
end


%Swap x and y and reverse order
%coordinates_out = [coordinates(end-1:-1:1,2),coordinates(end-1:-1:1,1)];
coordinates_out = [coordinates(:,2),coordinates(:,1)];






