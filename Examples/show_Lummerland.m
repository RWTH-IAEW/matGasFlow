function h = show_Lummerland
%SHOW_LUMMERLAND Summary of this function goes here
%   Detailed explanation goes here
img = imread('Lummerland.jpg');
scaling_factor = 500/size(img,2);
img = imresize(img,scaling_factor);
h = figure;
hold on
image(img)
text(50,60,'Festland','HorizontalAlignment','center')
text(220,220,'Legoland','HorizontalAlignment','center')
text(340,60,'Lummerland','HorizontalAlignment','center')
text(440,60,'Zamonien','HorizontalAlignment','center')
% busses
busses = [...
    70, 120; ...
    310, 120; ...
    350, 90; ...
    420, 80; ...
    380, 120; ...
    360, 150; ...
    220, 180];
scatter(busses(:,1),busses(:,2))
bus_names = {'a','b','c','d','e','f','g'};
for ii = 1:size(busses,1)
    text(busses(ii,1), busses(ii,2)-7,bus_names(ii),'HorizontalAlignment','center')
end
% text(a(1), a(2),'a','HorizontalAlignment','center')
% text(310,120,'b','HorizontalAlignment','center')
axis tight
x0=10;
y0=10;
width=800;
height=350;
set(gcf,'position',[x0,y0,width,height])

end

