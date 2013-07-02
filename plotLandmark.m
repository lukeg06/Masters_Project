function plotLandmark(point,handle,colour)
figure(handle)
hold on

if ~exist('colour','var')
    colour = 'r';
end
    
for i =1:size(point,1)
    
    plot(mm2pixel(point(i,1)),mm2pixel(point(i,2)),strcat('*',colour));
    
end

hold off