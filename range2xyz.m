%Function to transform a range image into an (m*n)*3 matrix.
%function [xyz] = range2xyz(im)
%im = a range image where each pixel value is the depth at that point in
%the secne
%xyz =  (m*n)*3 matrix where m*n is the number of pixels in the range image

function [x,y,z] = range2xyz(im)






 % According to the indications in the database paper, the resolution of

 % the grid is 0.32mm for all 3 axes
z =  0.32.*(im.*255);
x = repmat( .32 : .32 : .32 * size(z, 2), [size(z,1), 1] );

y = repmat( (.32 * size(z, 1) : -.32 : .32)', [1, size(z,2)] );


