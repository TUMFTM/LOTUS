function [fig] = Transmission_evaluation(Param, Ergebnis)
% Designed by Sebastian Wolff in FTM, Technical University of Munich
%-------------
% Created on: 16.02.2017
% ------------
% Version: Matlab2017b
%-------------
% Function to post-process the transmission results.
% The functions of weight calculations and transmission properties have to
% be executed first. If not, they will be automatically called in this
% function.
% This function creates a graphical evaluation of the gearbox functions for
% a powertrain.
% The parts of the postprocessing:
%   1. Traction diagram (including ideal traction, ability to climb and
%      Driving resistance in the plane
%   2. Relative Verweilzeiten in den einzelnen Gangstufen
%   3. Maximum speed of the respective gear steps
%   4. Gradeability in the individual gear steps (Theoretical)
% ------------
% Input:    - Param:   struct array containing all vehicle parameters
%           - Results: struct array that contains the raw results from the
%                      consumption simulation
% ------------
% Output:   - Fig:     Matlab figure that visualizes the post-processed
%                      results
% ------------

% Check inputs
if ~isfield(Param.vehicle, 'mass')
    disp('Weight calculation will proceed')
    Param = Weights_calculation(Param);
end
if ~isfield(Param.transmission, 'q')
    disp('Transmission properties will be assigned')
    Param.transmission = Transmission_properties(Param);
end

%% Pass variables
transmission = Param.transmission;
engine = Param.engine;
final_drive = Param.final_drive;
tires = Param.tires;
vehicle = Param.vehicle;
ambient = Param.ambient;
eta_ges = transmission.trq_eff .* final_drive.trq_eff; % overall efficiency
%eta_ges(1:transmission.z) = 1;

%% Variables for electric truck
if Param.Kraftstoff == 7 || Param.Kraftstoff == 12
   engine.full_load.speed = Param.em.speed;
   engine.full_load.trq = Param.em.trq;
   engine.full_load.power = Param.em.trq .* Param.em.speed * 2 * pi / (60 * 1000);
   engine.speed_min = 0;
   engine.speed_max = Param.em.n_max;
   engine.M_max = Param.em.M_max;
end

%% TUM colors
% Seconday colors
tumcol.dunkelblau       = [0 82 147]/255;    %Dark blue           Pantone 301     sek. 1
tumcol.tiefesdunkelblau = [0 51 89]/255;     %Deep dark blue      Pantone 540     sek. 2
tumcol.dunkelgrau       = [88 88 90]/255;    %Dark gray                           sek. 3
tumcol.mittelgrau       = [156 157 159]/255; %Medium gray                         sek. 4
tumcol.hellgrau         = [217 218 219]/255; %Light gray                          sek. 5

% Extended color palette
% For representations that require an extended color palette, use the
% accent colors of the TUM. In complex Charts or graphics is the extended
% color palette to display.
tumcol.erw01 = [105 8 90]/255;
tumcol.erw02 = [15 27 95]/255;
tumcol.erw03 = [0 119 138]/255;
tumcol.erw04 = [0 124 48]/255;
tumcol.erw05 = [103 154 29]/255;
tumcol.erw06 = [255 220 0]/255;
tumcol.erw07 = [249 186 0]/255;
tumcol.erw08 = [214 76 19]/255;
tumcol.erw09 = [196 7 27]/255;
tumcol.erw10 = [156 13 22]/255;

colorOrder = [tumcol.erw01; ...
    tumcol.erw02; ...
    tumcol.erw03; ...
    tumcol.erw04; ...
    tumcol.erw05; ...
    tumcol.erw06; ...
    tumcol.erw07; ...
    tumcol.erw08; ...
    tumcol.erw09; ...
    tumcol.erw10; ...
    tumcol.erw01; ...
    tumcol.erw02; ...
    tumcol.erw03; ...
    tumcol.erw04; ...
    tumcol.erw05; ...
    tumcol.erw06; ...
    tumcol.erw07; ...
    tumcol.erw08; ...
    tumcol.erw09; ...
    tumcol.erw10; ...
    ];

%% Traction calculation
% v_max in [km/h]
v_max = engine.speed_max * 2 * pi * tires.radius * 60 ./...
    (transmission.ratios .* final_drive.ratio * 1000);

v = 1:1:100;

% Smoothing the mapping of the internal combustion engine
if engine.Nummer == 1
    engine.full_load.trq = engine.Skalierungsfaktor * [1466.01000000000,...
        1604.82000000000,2050.44000000000,2100,2100,2100,...
        1951.32000000000,1475.88000000000,0]; %[Nm]
    engine.full_load.speed = ...
        [800,903,1000,1200,1300,1400,1600,2000,2001];  %[rpm]
    engine.full_load.power = (engine.full_load.trq .* ...
        (engine.full_load.speed * 2*pi/60)) / 1000; %[kW]
end

P_max = max(engine.full_load.power); %Engine's maximum power [kW]
F = P_max ./ (v./3.6); % Maximum traction force [N]

% Preallocate Figure
fig = figure;
fig.Name = 'Transmission postprocess';
set(fig, 'units','normalized','outerposition',[0 0 1 1]);

% Plotting traction diagram
subplot(2,2,1)
title('Traction diagram (\eta_{Antrieb} berücksichtigt)')

%% Calculating traction curve for all gears
% Preallocation
cut_diesel = 1; % Cut off too small values ??from diesel mapping (only for traction diagram)
cut_gas = 17; % Cut off too small values ??from natural gas mapping (only for traction diagram)

v_i = zeros((length(engine.full_load.speed)-cut_diesel - cut_gas * (engine.Nummer == 2 || engine.Nummer == 3)), transmission.z);
F_Z_i = zeros((length(engine.full_load.speed)-cut_diesel - cut_gas * (engine.Nummer == 2 || engine.Nummer == 3)), transmission.z);

clear i j
for i=1:transmission.z
    for j=1:(length(engine.full_load.speed)-cut_diesel - (cut_gas * (engine.Nummer == 2 || engine.Nummer == 3)))
        %Calculate the gear-dependent speeds [km/h]
        v_i(j,i) = 3.6 * 2 * pi * engine.full_load.speed(j) * ...
            tires.radius / (60 * final_drive.ratio * ...
            transmission.ratios(i));
        
        % Calculate the gear-dependent traction [kN]
        F_Z_i(j,i) = engine.full_load.trq(j) * final_drive.ratio * ...
            transmission.ratios(i) * eta_ges(i) / (tires.radius * 1000);
        
        % Plotting the gear-dependent traction curves (-1, since maps
        % generate as last entry of trq0)
        if j == (length(engine.full_load.speed)-cut_diesel  - cut_gas * (engine.Nummer == 2 || engine.Nummer == 3))
            hold on
            figure(fig)
            plot(v_i(:,i), F_Z_i(:,i),'-', 'Color', colorOrder(i,:))
        else
            continue
        end
    end
end

% Plotting traction curve
plot(v,F, '--', 'Color', tumcol.dunkelgrau)

% Fahrwiderstandskurven für Ebene, q_reststeig und q_max
m_ges = vehicle.mass + vehicle.payload;

F_ebene = (m_ges * ambient.gravity * cosd(0)...
    * tires.roll_drag_coeff.total + m_ges * ambient.gravity...
    * sind(0) + 0.5 * ambient.air_density *...
    vehicle.frontal_area * vehicle.air_drag_coeff * (v./3.6).^2) / 1000;

plot(v, F_ebene, '-.', 'Color', tumcol.dunkelgrau)

% F_qmax = (m_ges * ambient.gravity * cosd(atand(transmission.pitch/100))...
%         * tires.roll_drag_coeff.total * 0 + m_ges * ambient.gravity...
%         * sind(atand(transmission.pitch/100)) + 0.5 * ambient.air_density *...
%         vehicle.frontal_area * vehicle.air_drag_coeff * (v./3.6).^2) / 1000;
%
% plot(v, F_qmax, 'k--')


% F_qrest = (m_ges * ambient.gravity * cosd(atand(transmission.q_reststeig/100))...
%         * tires.roll_drag_coeff.total + m_ges * ambient.gravity...
%         * sind(atand(transmission.q_reststeig/100)) + 0.5 * ambient.air_density *...
%         vehicle.frontal_area * vehicle.air_drag_coeff * (v./3.6).^2) / 1000;
%     
% plot(v, F_qrest, 'k--')

% Visualizing climbing ability at 85 Km/h
line([85, 85], [F_ebene(85), interp1(v_i(:,end), F_Z_i(:,end), 85)], 'Color', tumcol.dunkelgrau, 'Linewidth', 2) %Linie Reststeigfähigkeit
text(91, F_ebene(85)+20, 'Climbing ability', 'Horizontalalignment', 'center') % Beschriftung Reststeigfähigkeit
line([85, 91], [F_ebene(85)+(interp1(v_i(:,end), F_Z_i(:,end), 85)-F_ebene(85))/2, F_ebene(85)+17], 'Color', tumcol.mittelgrau)
xlabel('v [km/h]','FontSize', 9);
ylabel('Traction [kN]', 'FontSize', 9);
grid on
set(gca, 'XTickLabel', 0:10:100, 'XLim',  [0 100], 'YLim', [0 (max(max(F_Z_i)) + 25)], 'Box', 'off', 'DefaultAxesFontName','Arial', 'DefaultAxesFontSize', 9)

%% Creating legend
legend_entries = cell(transmission.z+2,1);

for i=1:transmission.z
    gear_name = sprintf('%u. gear; Ratio=%.2f', i, transmission.ratios(i));
    legend_entries{i} = gear_name;
end
legend_entries{end-1} = sprintf('Ideal traction curve');
legend_entries{end} = sprintf('F_{Z, Ebene}');

legend(legend_entries, 'FontSize', 9)


if Param.VSim.Opt == false && Param.VSim.Display > 1
    fprintf('Maximum traction: %.4f kN\n', max(max(F_Z_i)))
end

%% Time spent in each gear (relative)

verweilzeit = zeros(transmission.z,1);
textposition_verweilzeit = zeros(transmission.z,2);
textlabel_verweilzeit = cell(1,transmission.z);

for i=1:transmission.z
    verweilzeit(i) = sum(Ergebnis.OUT_summary.signals(5).values == i)/length(Ergebnis.OUT_summary.signals(5).values);
    textlabel_verweilzeit{i} = sprintf('%.3f %%', verweilzeit(i)*100);
    textposition_verweilzeit(i,:) = [i (verweilzeit(i) + 0.05)];
end

% Plotting
subplot(2,2,2)
bar(verweilzeit, 0.6, 'LineStyle', 'none', 'FaceColor', tumcol.dunkelblau)
zyklus_name = {'ACEA cycle' , 'Truckerrunde', 'Long_Haul', 'Uphil climb', 'Startup',...
    'Test drive from Neuburg to Paderborn', 'Test drive Truckerrunde on 23.08.2012',...
    'HERE maps drive from Neuburg to Paderborn', 'HERE maps smoothed Truckerrunde',...
    'CSHVC cycle', 'Test drive Truckerrunde from Holledau to Langenbruck on 23.08.2012',...
    'Truck2030 for 100km', 'Truck2030 for 200km', 'Stationary cycle LVK','Cycle for 30, 50, 60, 80 km/h',...
    'Full cycle between Sorriso and Santos', 'Platooning Lead', 'Platooning Middle', 'Platooning Trail'};
title(strcat('Relative time of each gear (', zyklus_name(Param.Fahrzyklus), ')'),'FontSize', 11)
xlabel('Gear', 'FontSize', 9)
set(gca, 'Box', 'off', 'XLim', [0.3 transmission.z+0.6], 'Ticklength', [0, 0], 'XTick', 0:1:transmission.z, 'YTick', [], 'YColor', 'w', 'Ylim', [0,1.25], 'DefaultAxesFontName','Arial', 'DefaultAxesFontSize', 9);

% Textlabel plotting
for i=1:transmission.z
    h = text(textposition_verweilzeit(i,1), textposition_verweilzeit(i,2),  textlabel_verweilzeit{i});
    set(h, 'Rotation', 90);
end
%% V_Max per gear
% v_max in [km/h] is calculated above

subplot(2,2,3)
bar(v_max, 0.6, 'LineStyle', 'none', 'FaceColor', tumcol.dunkelblau)
title('V_{max} for each gear', 'FontSize', 11)
xlabel('Gears','FontSize', 9)
ylabel('V_{max} [km/h]', 'FontSize', 9)
set(gca, 'Box', 'off', 'YGrid', 'on', 'XLim', [0.3 transmission.z+0.6], 'XTick', 0:1:transmission.z, 'YTick', 0:10:120, 'Ticklength', [0, 0], 'Ylim', [0,130], 'DefaultAxesFontName','Arial', 'DefaultAxesFontSize', 9);

% Line at legal maximum speed
line([0, 20], [85, 85], 'LineStyle', '--','LineWidth', 1.2,  'Color', tumcol.mittelgrau)
text(1, 87, 'Legal maximum speed', 'FontSize', 9)

%% Climbing ability per gear

subplot(2,2,4)
bar(transmission.q, 0.6, 'LineStyle', 'none', 'FaceColor', tumcol.dunkelblau)
title('Maximum slope for each gear', 'FontSize', 11)
xlabel('Gear', 'FontSize', 9)
ylabel('Slope [%]', 'FontSize', 9)
set(gca, 'Box', 'off', 'YGrid', 'on', 'XLim', [0.3 transmission.z+0.6], 'XTick', 0:1:transmission.z, 'YTick', 0:5:55, 'Ticklength', [0, 0], 'Ylim', [0,60], 'DefaultAxesFontName','Arial', 'DefaultAxesFontSize', 9);

% Line at legal maximum speed
line([0, 20], [18, 18], 'LineStyle', '--', 'LineWidth', 1.2, 'Color', tumcol.mittelgrau)
text(transmission.z-1, 19, 'Slip limit', 'HorizontalAlignment','right', 'FontSize', 9)