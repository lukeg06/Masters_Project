
% [imageList,noImages]= getDBInfo(DBpath,imageType)
%
%Input,
%       DBpath: Path to folder containng the images to be read. 
%
%       imageType: 'Range' or 'Portrait'
%
%Output,
%       imageList: List of all images in DB.
%
%       noImages: Number of images in db.

function [imageList,noImages]= getDBInfo(DBpath,imageType)

%%
if DBpath(end) ~= '\'
    DBpath = strcat(DBpath,'\');
end

imageList = ls(strcat(DBpath,'*',imageType,'*'));
noImages = size(imageList,1);
