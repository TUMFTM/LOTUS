function [ fig_out ] = Production_costs( Param )
% Designed by Sebastian Wolff in FTM, Technical University of Munich
%-------------
% Created on: 18.03.2017
% ------------
% Version: Matlab2017b
%-------------
% Bar chart for acquisition costs; all numbers are in EUR
% The manufacturing costs of the SZM are broken down and visualized.
% The cost of the drive components was previously calculated in the
% acquisition cost class.
% The costs for axles, cab, assembly and paint are taken with fixed prices.
% The manufacturing costs are calculated from the acquisition costs below
% with deduction of overheads, as well as dealer and OEM margins.
% ------------
% Input:    - Param:   struct array containing all vehicle parameters
% ------------
% Output:   - fig_out: Matlab figure that visualizes the costs
% ------------
Acquisition_cost = Param.Anschaffungskosten;

% Costs of components
p_engine = Acquisition_cost.KMot + Acquisition_cost.Kosten_Kuehler + Acquisition_cost.Kosten_Luefter; % Engine cost including radiator and fan
p_tank = Acquisition_cost.KT; % Complete fuel system cost (In Dual Fuel, gas and diesel added together)
p_exhaust = Acquisition_cost.KA; % Exhaust aftertreatment
p_battery = Acquisition_cost.Bat; % Hybrid battery
p_em = Acquisition_cost.EM; % Electric machine for the hybrid vehicles
p_pwrelectronics = Acquisition_cost.LE * Acquisition_cost.Hybrid; % Power Electronics for the hybrid vehicles
p_conv_charger = (Acquisition_cost.Conv + Acquisition_cost.LS) * Acquisition_cost.Hybrid; % DC-DC converter and on-board charger (current pricing)
p_transmission = Acquisition_cost.KG; % Transmission cost includinh Intarder
p_drivetrain = p_engine + p_tank + p_exhaust + p_battery + p_em + p_pwrelectronics ...
    + p_conv_charger  + p_transmission;

% Total costs
p_axles = 1850 + 3450; % Axles cost
p_cab = 10508; % Driver's cab cost
p_colour = 4000; % Assembly and paint cost
p_others = (Acquisition_cost.KA_ZM / (Acquisition_cost.Gemeinkosten * Acquisition_cost.OEM_Rendite * Acquisition_cost.Haendlermarge)) - p_drivetrain - p_axles - p_cab - p_colour; %Other costs

% Vectors for bar chart
bar_complete(1,:) = [p_axles; p_drivetrain; p_cab; p_colour; p_others; NaN; NaN; NaN]' ./(Acquisition_cost.KA_ZM / (Acquisition_cost.Gemeinkosten * Acquisition_cost.OEM_Rendite * Acquisition_cost.Haendlermarge)); % NaN is used because different height of the bars is required
bar_complete(2,:) = [p_engine; p_transmission; p_tank; p_exhaust; p_battery;...
    p_em; p_pwrelectronics; p_conv_charger]' ./p_drivetrain;

% Plotting
xLabels = {'Total cost', 'Transmission'};
legendLabels1_temp = {'Axles', 'Transmission', 'Cab', 'Assembly & paint', 'Others'};
legendLabels2_temp = {'Engine', 'Transmission', 'Fuel system', 'Abgasnachbeh.', 'Battery', 'Electric machine', 'Power electronics.', sprintf('On-board charger &\n DC-DC Converter')};

legendLabels = cell(2,length(bar_complete));
dataLabels = legendLabels;

for i=1:length(bar_complete)-3
    legendLabels{1,i} = legendLabels1_temp(i);
    dataLabels{1,i} = sprintf('%.2f %%', bar_complete(1,i)*100);
end

for i=1:length(bar_complete) - (4 * (1-Acquisition_cost.Hybrid))
    legendLabels{2,i} = legendLabels2_temp(i);
     dataLabels{2,i} = sprintf('%.2f %%', bar_complete(2,i)*100);
end

% TUM colors
tumcol.dunkelblau=[0 82 147]/255;          %dunkelblau             Pantone 301     sek. 1
%tumcol.tiefesdunkelblau=[0 51 89]/255;     %tiefes dunkelblau      Pantone 540     sek. 2
tumcol.hellgrau = [217 218 219]/255;       %hellgrau                               sek. 5
%tumcol.hellblau=[100 160 200]/255;         %hellblau               Pantone 542     akz. 5
tumcol.erw10 = [156 13 22]/255;

% Preallocate Colormap
colormap_blau = zeros(length(legendLabels1_temp),3);
colormap_rot = zeros(length(legendLabels2_temp),3);

% Colormap creation
for i=1:3
    colormap_blau(:,i) = (linspace(tumcol.dunkelblau(i), tumcol.hellgrau(i), length(legendLabels1_temp)))';
    colormap_rot(:,i) = (linspace(tumcol.erw10(i), tumcol.hellgrau(i), length(legendLabels2_temp)))';
end

% Calculate text label and line position
barbase = cumsum([zeros(size(bar_complete,1),1) bar_complete(:,1:end-1)],2);
label_pos_y = bar_complete/2 + barbase; % Y Position text label
label_pos_x = [0.7; 1.3]; % X Position text label
dataLabel_pos_y = label_pos_y; % Y Position data label 
dataLabel_pos_x = zeros(size(bar_complete)); % X Position data label
line_pos_y = label_pos_y;
line_pos_x = [0.71, 0.74; 1.26, 1.29];

% Calculate data label positions, if distance is less than 0.1 then label
% moves inside
for j=1:2
    for i=1:size(dataLabel_pos_y,2)-1
        if barbase(j,i+1) - barbase(j,i) <= 0.1
            if j == 1
                dataLabel_pos_x(j,i) = 1.3;
            else
                dataLabel_pos_x(j,i) = 0.7;
            end
        else
            dataLabel_pos_x(j,i) = 1;
        end
        
        % Last iteration step manually
        if i == size(dataLabel_pos_y,2)-1
            if barbase(j,i+1) - barbase(j,i) <= 0.1
                if j == 1
                    dataLabel_pos_x(j,i+1) = 1.3;
                else
                    dataLabel_pos_x(j,i+1) = 0.7;
                end
            else
                dataLabel_pos_x(j,i+1) = 1;
            end
        end
    end
end

% If the distance between text is less than 0.8, the distance is increased to 0.8
for j=1:2
    for i=1:size(label_pos_y,2)-1
        if label_pos_y(j,i+1) - label_pos_y(j,i) <= 0.05
            label_pos_y(j,i+1) = label_pos_y(j,i+1) + 0.1 - (label_pos_y(j,i+1) - label_pos_y(j,i));
        end
    end
end


line_pos_y(3:4,:) = label_pos_y;

% Creating new figure
figure('name', 'Costs Structure', 'units','normalized','position',[.1 .1 .75 .4])
subplot(1,2,1)
colormap(gca, colormap_blau) % Assigning colormap
bar([bar_complete(1,:); zeros(1,length(bar_complete))], 0.5, 'stacked', 'EdgeColor', 'w') % Plot bar chart
set(gca, 'XTickLabel', xLabels(1), 'Box', 'off', 'YTick', [], 'YColor', 'w', 'Xlim', [0.1 1.9], 'Ylim', [0,1.25], 'DefaultAxesFontName','Arial', 'DefaultAxesFontSize', 9);

for i=1:length(bar_complete)-3
    % Text Label
    text(label_pos_x(1),label_pos_y(1,i), legendLabels{1,i}, 'HorizontalAlignment','right');
    line(line_pos_x(1,:), [line_pos_y(1+2,i), line_pos_y(1,i)], 'Color', 'k')
    % Data Label
    if dataLabel_pos_x(1, i) == 1
        text(dataLabel_pos_x(1, i),label_pos_y(1,i), dataLabels{1,i}, 'HorizontalAlignment','center');
    else
        text(dataLabel_pos_x(1, i),label_pos_y(1,i), dataLabels{1,i}, 'HorizontalAlignment','left');
        line([1.26, 1.29], [line_pos_y(1,i),line_pos_y(1+2,i)], 'Color', 'k')
    end
end

subplot(1,2,2)
colormap(gca, colormap_rot) % Creating color map
bar([bar_complete(2,:); zeros(1,length(bar_complete))], 0.5, 'stacked', 'EdgeColor', 'w');
set(gca, 'XTickLabel', xLabels(2),'Box', 'off', 'YTick', [], 'YColor', 'w', 'Xlim', [0.1 1.9], 'Ylim', [0,1.25], 'DefaultAxesFontName','Arial', 'DefaultAxesFontSize', 9);

for i=1:length(bar_complete)
    % Interruption in case no hybridization is present
    if Acquisition_cost.Hybrid == 0 && i == 5
        break
    end
    text(label_pos_x(2),label_pos_y(2,i), legendLabels{2,i}, 'HorizontalAlignment','left');
    line(line_pos_x(2,:), [line_pos_y(2,i),line_pos_y(2+2,i)], 'Color', 'k')
    % Data Label
    if dataLabel_pos_x(2, i) == 1
        text(dataLabel_pos_x(2, i),label_pos_y(2,i), dataLabels{2,i}, 'HorizontalAlignment','center');
    else
        text(dataLabel_pos_x(2, i),label_pos_y(2,i), dataLabels{2,i}, 'HorizontalAlignment','right');
        line([0.71, 0.74], [line_pos_y(4,i),line_pos_y(2,i)], 'Color', 'k')
    end
end

% Output
fig_out = gcf;
end