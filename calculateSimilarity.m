function [out] = calculateSimilarity(jetsIn,landmark,matchType,temp)


%% TEMP DESCRIPTION !!!!!!
%function to calculate the similarity score for a region. Takes in a number
%of jets and calculates the similarity for each of them. It then selects
%the most similar in returns its index. In this way the location of the
%jet most similar to the landmark in question can be determined. This is
%based on the method given in the paper. I am using the similarity score
%which only examines the magnitude response. If that doesnt work out then I
%will use the phase one. Though this looks a little more difficult.

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
