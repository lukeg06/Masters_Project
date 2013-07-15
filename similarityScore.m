function [score] = similarityScore(testJet,actualJet)

%Compare magnitudes.
%Compare magnitudes.
% j1 = testJet;
% j2 = actualJet;
% score = (sum(abs(j1).*abs(j2).*cos(angle(j1)-angle(j2))))./ sqrt(sum(abs(j1).^2).*sum(abs(j2).^2));

j1 = abs(testJet);
j2 = abs(actualJet);
score = sum(j1.*j2)./ sqrt(sum(j1.^2).*sum(j2.^2));
end


