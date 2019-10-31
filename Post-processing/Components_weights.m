function [ fig_out ] = Components_weights( Param )
% Designed by Sebastian Wolff in FTM, Technical University of Munich
%-------------
% Created on: 18.03.2017
% ------------
% Version: Matlab2017b
%-------------
% This function creates a bar chart for different component weights.
% ------------
% Input:    - Kraftstoff: a scalar number that defines which type of fuel
%                         is selected
%           - x:          struct array containing all vehicle parameters
%           - DrvTrn:     a scalar number that defines which type of
%                         vehicle is selected
%           - list:       a celly array with 14 columns containing the
%                         string names of the different types of vehicles
% ------------
% Output:   - Param: struct array containing all simulation parameters
% ------------
% Die Herstellkosten der SZM werden aufgeschlüsselt und visualisiert.
% Die Kosten der Antriebskomponenten wurden vorher in der
% Anschaffungskostenklasse berechnet. Die Kosten für Achsen, Fahrerhaus,
% Montage/Lack werden mit Fixpreisen angenommen.
% Die Herstellkosten berechnen sich aus den Anschaffungskosten unter
% Abzug der Gemeinkosten, sowie Händler- und OEM-Marge.

pa = Param.Gewichte;
Hybrid = Param.Hybrid_LKW;

m_Ref = 7320; % 7320kg is the weight of MAN TGX 18.440, base weight is derived from this
m_Frame = m_Ref*0.05;
m_Wheels = m_Ref*0.09;
m_Cab = m_Ref*0.19;
m_Coupling = m_Ref*0.03;
m_Chassis = m_Ref*0.2;
m_Others = m_Ref*0.13;

m_Hybrid = pa.m_Battery + pa.m_EM + pa.m_PwrElectr + pa.m_Charger;
m_drivetrain = pa.m_Engine + pa.m_Exhaust + pa.m_Gearbox + pa.m_Retarder + pa.m_Tanksystem + pa.m_Fuel+ (pa.m_Battery + pa.m_EM + pa.m_PwrElectr + pa.m_Charger) * Hybrid;

% Vectors for bar charts
bar_complete(1,:) = [ m_Others,  m_Chassis, m_Cab, pa.m_Engine, m_Frame, m_Wheels, m_Coupling, pa.m_Gearbox+pa.m_Retarder, pa.m_Tanksystem + pa.m_Fuel, pa.m_Exhaust, m_Hybrid] ./pa.m_Total; % NaN is used because different height of the bars is required
bar_complete(2,:) = [pa.m_Engine, pa.m_Exhaust, pa.m_Gearbox, pa.m_Retarder, pa.m_Fuel, pa.m_Tanksystem, pa.m_Battery, pa.m_EM, pa.m_PwrElectr, pa.m_Charger, NaN] ./m_drivetrain;

% Plotting
xLabels = {'Total weight', 'Drivetrain weight share'};
legendLabels1_temp = {'Others', 'Suspension & axles', 'Driver cab', 'Engine', 'Frame', 'Wheels', 'Sattelkupplung', 'Transmission', 'Fuel system', 'Exhaust treatment', 'Hybrid components'}; 
legendLabels2_temp = {'Engine', 'Exhaust treatment', 'Transmission', 'Retarder', 'Fuel', 'Fuel system', 'Battery', 'Electrical machine', 'Power electronics', sprintf('On-board charger &\n DC-DC converter')};

% Prelocate bar chart labels
legendLabels = cell(2,length(bar_complete));
dataLabels = legendLabels;

for i=1:length(bar_complete)
    legendLabels{1,i} = legendLabels1_temp(i);
    dataLabels{1,i} = sprintf('%.2f %%', bar_complete(1,i)*100);
end

for i=1:length(bar_complete)-1
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
label_pos_y = bar_complete/2 + barbase; % Y Position Text Label
label_pos_x = [0.68; 1.32]; % X Position Text Label
dataLabel_pos_y = label_pos_y; % Y Position Daten Label 
dataLabel_pos_x = zeros(size(bar_complete)); % X Position Daten Label
line_pos_y = label_pos_y; % Übergabe hier zur Verarbeitung von schrägen Linien falls Abstand zu klein
line_pos_x = [0.69, 0.74; 1.26, 1.29];

% Calculate data label positions, if distance is less than 0.1 then label
% moves inside
for j=1:2
    for i=1:size(dataLabel_pos_y,2)-1
        if barbase(j,i+1) - barbase(j,i) <= 0.13
            if j == 1
                dataLabel_pos_x(j,i) = 1.32;
            else
                dataLabel_pos_x(j,i) = 0.68;
            end
        else
            dataLabel_pos_x(j,i) = 1;
        end
        
        % Last iteration step manually
        if i == size(dataLabel_pos_y,2)-1
            if barbase(j,i+1) - barbase(j,i) <= 0.12
                if j == 1
                    dataLabel_pos_x(j,i+1) = 1.32;
                else
                    dataLabel_pos_x(j,i+1) = 0.68;
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
        if label_pos_y(j,i+1) - label_pos_y(j,i) <= 0.08
            label_pos_y(j,i+1) = label_pos_y(j,i+1) + 0.12 - (label_pos_y(j,i+1) - label_pos_y(j,i));
        end
    end
end


line_pos_y(3:4,:) = label_pos_y;

% Create new figure
figure('name', 'Weights', 'units','normalized','position',[.1 .1 .75 .4])

subplot(2,1,1)

colormap(gca, colormap_blau)
bar([bar_complete(1,:); zeros(1,length(bar_complete))], 0.5, 'stacked', 'EdgeColor', 'w') 
set(gca, 'XTickLabel', xLabels(1), 'Box', 'off', 'TickLength', [0 0] ,'YTick', [], 'YColor', 'w', 'Xlim', [0.1 1.9], 'Ylim', [0,1.25], 'DefaultAxesFontName','Arial', 'DefaultAxesFontSize', 12);

for i=1:length(bar_complete) -  (1 * (1-Hybrid))
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

% Plotting total weights
%text(1.4, 0.1, strcat('$\sum$ ', sprintf(' %.0f kg', pa.m_Total)), 'Interpreter','latex', 'FontSize', 18);

subplot(2,1,2)
colormap(gca, colormap_rot);
bar([bar_complete(2,:); zeros(1,length(bar_complete))], 0.5, 'stacked', 'EdgeColor', 'w') % Balkendiagramm plotten
set(gca, 'XTickLabel', xLabels(2),'Box', 'off', 'TickLength', [0 0], 'YTick', [], 'YColor', 'w', 'Xlim', [0.1 1.9], 'Ylim', [0,1.25], 'DefaultAxesFontName','Arial', 'DefaultAxesFontSize', 12);

for i=1:(length(bar_complete) - 1 - 4 * (1-Hybrid))

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

%text(0.2, 0.1, strcat('$\sum$ ', sprintf(' %.0f kg', m_drivetrain)), 'Interpreter','latex', 'FontSize', 18);

% Output
fig_out = gcf;
end