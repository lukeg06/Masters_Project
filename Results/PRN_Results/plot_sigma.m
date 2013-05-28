figure,
hold on;
plot(data(:,1),data(:,2))
plot(data(:,1),data(:,3),'m')
plot(data(:,1),data(:,4),'r')
hold off
legend('X Error Std','Y Error Std','Radial Error Std');
xlabel('Sigma');
ylabel('mm');