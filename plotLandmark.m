function plotLandmark(point,handle,colour)


if ~exist('colour','var')
    colour = 'r';
end
    

if ~exist('handle','var')
    handle = gcf;
end

figure(handle)
hold on
for i =1:size(point,1)
    
    plot(mm2pixel(point(i,1)),mm2pixel(point(i,2)),strcat('*',colour));
    
end

hold off