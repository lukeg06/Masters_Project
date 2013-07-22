% Script to calculate 2D error. Results stored in result vector. Assumes
% that data has been imported using the importdata wizard.

x_mean = mean(data(:,2))
x_std = std(data(:,2))
y_mean = mean(data(:,3))
y_std = std(data(:,3))
rad_2d_mean=mean(data(:,4))
rad_2d_std = std(data(:,4))

result = [x_mean,x_std,y_mean,y_std,rad_2d_mean,rad_2d_std]