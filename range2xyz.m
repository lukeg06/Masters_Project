%Function to transform a range image into an (m*n)*3 matrix.
%function [xyz] = range2xyz(im)
%im = a range image where each pixel value is the depth at that point in
%the secne
%xyz =  (m*n)*3 matrix where m*n is the number of pixels in the range image

function [xyz] = range2xyz(im)

[y,x] = ind2sub(size(im), 1:numel(im));



xyz = [x(:).*0.32, y(:).*0.32, (im(:).*255).*0.32];