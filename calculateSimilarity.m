function [out] = calculateSimilarity(jetsIn,landmark,matchType)


%% TEMP DESCRIPTION !!!!!!
%function to calculate the similarity score for a region. Takes in a number
%of jets and calculates the similarity for each of them. It then selects
%the most similar in returns its index. In this way the location of the
%jet most similar to the landmark in question can be determined. This is
%based on the method given in the paper. I am using the similarity score
%which only examines the magnitude response. If that doesnt work out then I
%will use the phase one. Though this looks a little more difficult. 