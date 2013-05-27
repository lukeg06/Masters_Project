%Input: path to folder containng the images to be read. Returns a list of
%the image names and the number of images. Image type = 'Range' or 'Portrait'

function [imageList,noImages]= getDBInfo(DBpath,imageType)

%%
if DBpath(end) ~= '\'
    DBpath = strcat(DBpath,'\');
end

imageList = ls(strcat(DBpath,'*',imageType,'*'));
noImages = size(imageList,1);
