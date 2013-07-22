% Resize all images

%Define paths etc
DBpath = 'C:\Databases\Texas3DFR\PreprocessedImages\';
 outputPath= 'C:\Databases\Texas3DFR\Resized_PreprocessedImages\';

%load landmarks & image list.
[dbList,~]= getDBInfo(DBpath,'Range');
noImages = size(dbList,1);

%%
for i  = 1:noImages
    
     imageIn = im2double(imread(strcat(DBpath,dbList(i,:))));
     im_resize = imresize(imageIn, 1/3);
     f = strcat(outputPath,dbList(i,1:end-4),'.png');
     imwrite(im_resize,f,'png');
     
     fprintf('Processing Image %d\n',i);
end
