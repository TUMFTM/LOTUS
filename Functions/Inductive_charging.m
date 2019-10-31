function [WPT] = Inductive_charging(x, Vehicle)
% Designed by Bert Haj Ali at FTM, Technical University of Munich
%-------------
% Created on: 06.11.2018
% ------------
% Version: Matlab2017b
%-------------
% This function reads the parameters concenring the inductive charging,
% when present and creates the necessary variables
% ------------
% Input:    - x:       struct array containing all vehicle parameters
%           - Vehicle: a string which indicate the type of vehicle used
%                      in the simulation. It is one of the fieldnames of
%                      the 'x' matrix
% ------------
% Output:   - WPT:     struct array containing the wireless power transfer
%                      parameters
% ------------
%% Sources
% [1]	M. Wietschel und et. al, “Machbarkeitsstudie zur Ermittlung der Potentiale des Hybrid-Oberleitungs-Lkw,” Fraunhofer Institut für System und, Karlsruhe, 2017.
% [2]	O. Olsson, “Slide-in Electric Road System: Inductive project report,” Viktoria Swedish ICT, Göteborg, Okt. 2013. Gefunden am: Nov. 29 2017.
% [3]   T. Navidi, Y. Cao, und P. T. Krein, “Analysis of wireless and catenary power transfer systems for electric vehicle range extension on rural highways,” in 2016 IEEE Power and Energy Conference at Illinois (PECI): Urbana, IL, USA, Feb. 19th-20th 2016, Piscataway, NJ: IEEE, 2016, S. 1–6.

% ------------

    WPT.Voltage          = 800;   % Voltage for inductive charging in V, to disable set WPT to 0
    WPT.SOC_target        = x(14); % SOC target for the inductive charging logic
    WPT.SOC_electric_only = x(15); % Minimal SOC for pure electric driving 
    
    switch Vehicle
        case 'BEV_OC' % [1]
            WPT.P_max             = 500;    % Maximum power in kW
            WPT.eta               = 0.96;   % 96% WPT efficiency
            WPT.expansion            = 0.12;   % eRoad expansion in %

        otherwise % WPT System [2, 3]
            WPT.P_max             = 200;       % Peak Power [2]
            WPT.eta               = 0.88;      % Efficiency in % [3]
            WPT.expansion            = 0.43;      % 30% Coverage, 0.7% of the time -> 0.43% Coverage // Transmitter is ON 70 % of the time [3]

    end
end