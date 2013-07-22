% Calculate m' point

%load en locations
filename = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\EN_Results\EN_left_Locations.txt';
A = importdata(filename);
EN_LeftCoordinates = A ;clear A;
filename = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\EN_Results\EN_right_Locations.txt';
A = importdata(filename);
EN_RightCoordinates = A ;clear A;

m_locs = (EN_LeftCoordinates + EN_RightCoordinates)./2;
%%


%Define paths etc
landmarkPath = 'C:\Databases\Texas3DFR\ManualFiducialPoints\';
DBpath = 'C:\Databases\Texas3DFR\PreprocessedImages\';
outputPath = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\';
%%
%load landmarks & image list.
[landmarkLocations] = loadLandmarks(landmarkPath);
[dbList,~]= getDBInfo(DBpath,'range');
imageList = importdata('C:\Databases\Texas3DFR\Partitions\test.txt');
noImages = size(imageList,1);

%%
% Define savefile paths
%open files for writing results
m_LocationFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\m_Locations.txt','w');
test_localiseMResultsFileID = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\test_localiseMResults.txt','w');

fprintf(test_localiseMResultsFileID,'No.\tX Error(mm)\tY Error(mm)\tRad Error(mm)\n');


for imNo = 1:noImages
   
    
    ind_Img = strmatch(imageList{imNo},dbList);
    m = m_locs(imNo,:);
    y_error = abs(m(1) - landmarkLocations(18,1,ind_Img));
    x_error = abs(m(2) - landmarkLocations(18,2,ind_Img));
    euclidean_error = norm(m - landmarkLocations(18,:,ind_Img));
    
    fprintf(test_localiseMResultsFileID,'%d\t%f\t%f\t%f\n',imNo,x_error,y_error,euclidean_error);
    fprintf('%d\t%f\t%f\t%f\n',imNo,x_error,y_error,euclidean_error);
     fprintf(m_LocationFileID,'%f\t%f\n',m(1),m(2));
end