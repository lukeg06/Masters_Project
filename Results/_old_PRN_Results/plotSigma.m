figure,
hold on;
plot(data(:,1),data(:,2))
plot(data(:,1),data(:,3),'m')
plot(data(:,1),data(:,4),'r')
plot(data(:,1),data(:,5),'y')
plot(data(:,1),data(:,6),'g')
plot(data(:,1),data(:,7),'k')
hold off
legend('X Error Std','Y Error Std','Radial Error Std','X Error Mean','Y Error Mean','Radial Error Mean');
xlabel('Sigma');
ylabel('mm');
title('Smoothing Vs Localisation Error')