% Script to load all results and generate a bloxplot for them

resultsPath ='.\Results\Results_For_Boxplot\';

prn = importdata(strcat(resultsPath,'prn','_3DError.txt'));
al_left = importdata(strcat(resultsPath,'al_left','_3DError.txt'));
al_right =importdata(strcat(resultsPath,'al_right','_3DError.txt'));
en_left =importdata(strcat(resultsPath,'en_left','_2D3DEBGM','_3DError.txt'));
en_right =importdata(strcat(resultsPath,'en_right','_2D3DEBGM','_3DError.txt'));
m =importdata(strcat(resultsPath,'m','_3DError.txt'));
ex_left =importdata(strcat(resultsPath,'ex_left','_2DEBGM','_3DError.txt'));
ex_right =importdata(strcat(resultsPath,'ex_right','_2DEBGM','_3DError.txt'));
ch_left =importdata(strcat(resultsPath,'ch_left','_2D3DEBGM','_3DError.txt'));
ch_right=importdata(strcat(resultsPath,'ch_right','_2D3DEBGM','_3DError.txt'));
%%

boxplot([prn.data(:,3) al_left.data(:,3) al_right.data(:,3) en_left.data(:,3)...
    en_right.data(:,3) m.data(:,3) ex_left.data(:,3) ex_right.data(:,3) ch_left.data(:,3)...
    ch_right.data(:,3)],'labels',{'Prn','Al Left','Al Right','En Left','En Right'...
    'M''','Ex Left','Ex Right','Ch Left', 'Ch Right'})
title('3D Error')
ylabel('mm')
set(gca,'yLim',[0 10])