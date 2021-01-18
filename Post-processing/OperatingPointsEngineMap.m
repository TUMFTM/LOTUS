 % TUM Farben
tumcol.blau=[0 101 189]/255;               %blau
tumcol.hellblau=[152 198 234]/255;        %hellblau
tumcol.dunkelblau=[0 82 147]/255;          %dunkelblau             Pantone 301     sek. 1
tumcol.tiefesdunkelblau=[0 51 89]/255;     %tiefes dunkelblau      Pantone 540     sek. 2
tumcol.dunkelgrau = [88 88 90]/255;        %dunkelgrau                             sek. 3
tumcol.mittelgrau = [156 157 159]/255;     %mittelgrau                             sek. 4
tumcol.hellgrau = [217 218 219]/255;       %hellgrau                               sek. 5

%% Erzeugung Raster über Lastpunkte  und Berechnung der Haeufigkeitsverteilung
OUT_engine = Results.EM_summary;
engine = Param.em;
allLastpunkte = [OUT_engine.signals(5).values, OUT_engine.signals(4).values];


%
figure
hold on
[C1, h1] = contour(Param.em.efficiency.speed, Param.em.efficiency.torque, Param.em.efficiency.characteristic_map, [linspace(0, 0.95, 5) linspace(0.95,1,15)], 'Color', tumcol.hellgrau);
% 
[C2, h2] = contour(Param.em.efficiency.speed, flip(-Param.em.efficiency.torque), flip(Param.em.efficiency.characteristic_map), [linspace(0, 0.95, 5) linspace(0.95,1,15)], 'Color', tumcol.hellgrau);

% [C1, h1] = contour(Param.em.efficiency.speed, Param.em.efficiency.torque, Param.em.efficiency.characteristic_map, [0.97, 0.98, 0.99], 'Color', tumcol.hellgrau, 'ShowText','on');

% [C2, h2] = contour(Param.em.efficiency.speed, flip(-Param.em.efficiency.torque), flip(Param.em.efficiency.characteristic_map), [0.97, 0.98, 0.99], 'Color', tumcol.hellgrau);


h3 = scatter(allLastpunkte(:,1),allLastpunkte(:,2), 'Marker', 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', tumcol.blau, 'MarkerFaceAlpha', 0.025);

h4 = plot (Param.em.speed, Param.em.trq, 'Color', tumcol.dunkelblau, 'LineWidth', 2);
h5 = plot (Param.em.speed, -Param.em.trq  ,'Color', tumcol.dunkelblau, 'LineWidth', 2);

[~, idx] =  max(Param.em.efficiency.characteristic_map);

h6 = plot(Param.em.speed, Param.em.efficiency.torque(idx),'LineWidth', 2, 'Color', tumcol.hellblau, 'LineStyle', ':');

h7 = line([0 Param.em.n_max],[0 0], 'Color', 'k');

xlabel('Rot. speed in rpm')
ylabel('Torque in Nm')
xlim([0 Param.em.n_max])
ylim([-ceil(Param.em.M_max/100)*100 ceil(Param.em.M_max/100)*100])
box on
ax = gca;
ax.XAxis.Exponent=0;
ax.YAxis.Exponent=0;
ax.YAxis.TickLabelFormat = '%,.0f';
ax.XAxis.TickLabelFormat = '%,.0f';
% legend([h1 h3 h4 h6], {'Efficiency Map', 'Operating Points', 'Max. Torque', '\eta_{max}'})


%% Average Efficiency

efficiency = interp2(Param.em.efficiency.speed, Param.em.efficiency.torque, Param.em.efficiency.characteristic_map, allLastpunkte(:,1),  abs(allLastpunkte(:,2)));

avgEffRec = mean(Results.Elektro_LKW.signals(5).values(Results.Elektro_LKW.signals(5).values>0), 'omitnan')

avgEff = mean(Results.Elektro_LKW.signals(5).values(Results.Elektro_LKW.signals(5).values>1e-3), 'omitnan')



%% Plot Driving Cycle
% 
% figure
% hold on
% 
% colororder([tumcol.blau; tumcol.hellblau])
% 
% yyaxis left
% plot(Param.cycle.distance/1000, Param.cycle.speed*3.6)
% ylabel('Speed in km/h')
% yyaxis right
% plot(Param.cycle.distance/1000, Param.cycle.altitude)
% ylabel('Altitude in m a.s.l.')
% xlim([0, max(Param.cycle.distance/1000)])
% box on
% xlabel('Distance in km')