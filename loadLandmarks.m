% Function to load the landmarks for all of the images in the in DB. Store
% the points in a 25 x 2 x 1149 matrix. All locations are in mm.

function [landmarkLocations] = loadLandmarks(landmarkPath)
%%
if landmarkPath(end) ~= '\'
    landmarkPath = strcat(landmarkPath,'\');
end

landmarkList = ls(strcat(landmarkPath,'*','Fiducial','*'));


% import the data from each of the text files and store

% Allocate space for points

landmarkLocations = zeros(25,2,1149);
for i = 1:size(landmarkList,1)
    filepath = strcat(landmarkPath,landmarkList(i,:));
    fPoints = importdata(filepath,'\t',0);
    landmarkLocations(:,:,i) = pixel2mm(fPoints);
end