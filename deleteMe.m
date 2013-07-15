% Gabor test


filterBank = FilterBank();
imageIn = im2double(rgb2gray(imread('lena.jpg')));

imageResponse = filterBank.filterImage(imageIn);

%% Image filtered. Extract jet at point of interest.
 loc = [265,265];

 jetModel = imageResponse(:,loc(1),loc(2));
 
 %% Calculate similarity
 
 resultImage = zeros(size(imageIn));
for i = 1:512
    
   for j = 1:512
      
       actualJet = jetModel;
       testJet = imageResponse(:,i,j);
       resultImage(i,j) = similarityScore(testJet,actualJet);
       
   end
end
figure,imagesc(resultImage);