function plotLandmark(point,handle)
figure(handle)
hold on

for i =1:size(point,1)
   
    plot(mm2pixel(point(i,1)),mm2pixel(point(i,2)),'*m');
    
end

hold off