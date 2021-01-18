figure
set(gcf,'defaultAxesColorOrder', [0 0 0; 0 0 0])
b = bar(consumption','FaceColor','flat', 'LineStyle', 'none')

colorVec = tumColors;

customColor = [colorVec.accent.DarkBlue; colorVec.accent.LightBlue; colorVec.primary.Blue; colorVec.secondary.LightGrey; colorVec.secondary.DarkGrey];

for k = 1:size(consumption,1)
    b(k).CData = customColor(k,:);
end

xticklabels({'Truckerrunde'	'T2030' 'VECTO LH' 'VECTO RD'})

ylabel('Consumption in kWh/100km')

ax = gca;
ax.YGrid = 'on';
ylim([0 150])
set(gca, 'YTick', 0:30:150)

yyaxis right
ylim([0 100])
ylabel('Average Efficiency in %')
hold on

for ib = 1:numel(b)
    %XData property is the tick labels/group centers; XOffset is the offset
    %of each distinct group
    xData = b(ib).XData+b(ib).XOffset;
    plot(xData,efficiencyDC(ib,:)'.*100, 'kx', 'LineStyle', 'none', 'LineWidth', 1.33)
end

lgnd = legend([vehicles; 'Efficiency'], 'Location', 'SE')
lgnd.BoxFace.ColorType='truecoloralpha'
lgnd.BoxFace.ColorData=uint8(255*[1 1 1 0.9]')
lgnd.NumColumns = 2


%% Gear Ratio efficiency
figure
set(gcf,'defaultAxesColorOrder', [0 0 0; 0 0 0])

b2 = plot(efficiency'*100, 'LineWidth', 1.66);

for k = 1:size(efficiency,1)
    b2(k).Color = customColor(k,:);
end

xticks(1:5)
xticklabels({'80 %' '90 %' '100 %' '110 %' '120 %'})
ylim([0 100])
xlabel('Change in total gear ratio in %')
ylabel('Efficiency in %')
ax = gca;
ax.YGrid = 'on';
legend(vehicles, 'Location', 'SE')

figure
set(gcf,'defaultAxesColorOrder', [0 0 0; 0 0 0])
b2 = plot(efficiency'*100, 'LineWidth', 1.66);

for k = 1:size(efficiency,1)
    b2(k).Color = customColor(k,:);
end

xticks(1:5)
xticklabels({'80 %' '90 %' '100 %' '110 %' '120 %'})
ylim([75 100])
xlabel('Change in total gear ratio in %')
ylabel('Efficiency in %')
ax = gca;
ax.YGrid = 'on';


%% Gear ratio elasticity
figure
% hold on
% yyaxis right
b2 = plot(elasticity', 'LineWidth', 1.66);

for k = 1:size(elasticity,1)
    b2(k).Color = customColor(k,:);
end

xticks(1:5)
xticklabels({'80 %' '90 %' '100 %' '110 %' '120 %'})
ylim([0 20])
xlabel('Change in total gear ratio in %')
ylabel('Elasticity in s')
ax = gca;
ax.YGrid = 'on';
legend(vehicles, 'Location', 'SE')

%% plot driving cycles

figure
set(gcf,'defaultAxesColorOrder', [0 0 0; 0 0 0])
plot(cycle.distance/1000, cycle.speed.*3.6, 'LineWidth', 1, 'Color', colorVec.primary.Black)
xlim([0 100])
ylim([0 90])
ylabel('Velocity in km/h')
xlabel('Distance in km')

hold on
yyaxis right
plot(cycle.distance/1000, cycle.slope*100, 'LineWidth', 0.33, 'Color', colorVec.primary.Blue)
plot([0, 500], [0, 0], '-k', 'Linewidth', 0.1)
ylim([-10 10])
ylabel('Gradient in %')

lgnd = legend({'Speed', 'Gradient'}, 'Location', 'SW');
lgnd.BoxFace.ColorType='truecoloralpha'
lgnd.BoxFace.ColorData=uint8(255*[1 1 1 0.75]')

% xticks(0:40:360)
