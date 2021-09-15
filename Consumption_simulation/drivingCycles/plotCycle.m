% Script to plot cycle parameters

cycle = load('cycle_VECTO_Long_Haul.mat');
%cycle = load('cycle_VECTO_Regional_Delivery.mat');
%cycle = load('cycle_Long_Haul.mat');
%cycle = load('cycle_Tractor.mat');

distance = cycle.cycle.distance;
slope = cycle.cycle.slope;
speed = cycle.cycle.speed;
speed(1) = 0;


figure_width  = 8*2;
figure_height = 6*2;
FontSize = 8;
FontSize2 = 13;

color1 = [0/255 101/255 189/255];
color2 = [227/255 114/255 34/255];

figure();
hold on
x0 = 0;
y0 = 0;
width = 16;
height = 10;
set(gcf,'units','centimeters','position',[x0,y0,width,height])
set(gcf,'position',[x0,y0,width,height])
xlabel('Distance in m','FontSize',FontSize) 
xlim([0 100300]);
title('VECTO Long Haul Cycle','FontSize',FontSize);

yyaxis left
ylabel('Target speed in km/h','FontSize',FontSize)
plot(distance, 3.6*speed, 'color', color1);

yyaxis right
ylabel('Slope in %')
plot(distance,slope*100,'--','color',color2);


hold off