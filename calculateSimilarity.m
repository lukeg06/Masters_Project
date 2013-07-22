% Function to calculate similarity between Gabor jets from a particular
% region and the jets of a particular landmark. These jets are based on 89
% training images from the Texas 3DFR DB.
%
%[out] = calculateSimilarity(jetsIn,landmark,matchType,temp)
%
%Inputs,
%       jetsIn: Matrix which contrained the jets for each pixel in a given
%       region. size = [noGaborCoefficients,noJets]
%       
%       landmark: String which specifies which landmark jets should be
%       compared to. String of format 'landmarkAbrv right/left'. E.g. 'ch left'
%
%       matchType: String which specifies which EBGM search should be
%       used. 2D/3D/2D+3D.
%       
%Outputs,
%       out: Output object.
%
%       out.index: Index of maximum similarity. Coordinates within search
%       region of max score.
%
%       out.score: Actual similarity score. Range from -1 to 1. 


function [out] = calculateSimilarity(jetsIn,landmark,matchType,temp)

DBpath = 'C:\Databases\Texas3DFR\GaborResponses\';
[dbList,noImages]= getDBInfo(DBpath,'jet');
imageList = importdata('C:\Databases\Texas3DFR\Partitions\Example_Images_jet.txt');

similarityScores = zeros(noImages,size(jetsIn,2));
actualJets = zeros(size(jetsIn,1),noImages);
for i = 1:noImages
    subject = importdata(strcat(DBpath,imageList{i}));
    
    
    switch lower(landmark)
        case 'en left'
            landmarkJets = subject.EN.left;
        case 'en right'
            landmarkJets = subject.EN.right;
        case 'ex left'
            landmarkJets = subject.EX.left;
        case 'ex right'
            landmarkJets = subject.EX.right;
        case 'ch left'
            landmarkJets = subject.CH.left;
        case 'ch right'
            landmarkJets = subject.CH.left;
        otherwise
            error('Incorrect Landmark');
    end
    
    
    switch matchType
        case '3D'
            actualJet = landmarkJets.val3D;
        case '2D'
            actualJet = landmarkJets.val2D;
            
        case '2D + 3D'
            actualJet = [landmarkJets.val2D;landmarkJets.val3D];
        otherwise
            error('Incorrect MatchType');            
    end
    
    actualJets(:,i) = actualJet;
end

landmarkJets.abs_val = abs(actualJets);
landmarkJets.angle_val = angle(actualJets);
clear actualJets;
for j = 1:size(jetsIn,2)
    
    
    similarityScores(:,j) = similarityScore2(jetsIn(:,j),landmarkJets);
    
end



% Find max similarity score;
[maxVal maxInd] = max(similarityScores(:));
[i1,j1] = ind2sub(size(similarityScores),maxInd);
out.index = j1;
out.score = maxVal;
% error('yo')
% for j = 20
%     for i = 1:(21*21)
%         l = temp(i,:);
%         imageSim(l(1),l(2)) = similarityScores(j,i);
%     end
%     imagesc(imageSim)
%     pause;
% end


end



function [score] = similarityScore(testJet,landmarkJets)




%Compare magnitudes.
 j1 = repmat(testJet,1,size(landmarkJets.abs_val,2));
j1_abs = abs(j1);
j2_abs = landmarkJets.abs_val;

j1_angle = angle(j1);
j2_angle = landmarkJets.angle_val;

score = sum(j1_abs.*j2_abs)./  sqrt(sum(j1_abs.^2).*sum(j2_abs.^2));



end

function [score] = similarityScore2(testJet,landmarkJets)




%Compare magnitudes.
 j1 = repmat(testJet,1,size(landmarkJets.abs_val,2));
j1_abs = abs(j1);
j2_abs = landmarkJets.abs_val;

j1_angle = angle(j1);
j2_angle = landmarkJets.angle_val;

score = (sum(j1_abs.*j2_abs.*cos(j1_angle-j2_angle)))./ sqrt(sum(j1_abs.^2).*sum(j2_abs.^2));



end
