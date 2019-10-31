            %--------------- Wireless Power Tansfer ---------------
%             if length(x) == 29
%                 WPT.Voltage = 650;                 % Voltage for inductive charging in V, to disable set WPT to 0
%                 WPT.P_max    = 200;                 % Maximum power in kW
%                 %WPT.expansion  = 0.6 * 0.7;           % eRoad expansion in // Transmitter is ON 70% of the time (Navidi2016)
%                 WPT.expansion   = 0.1;
%                 WPT.eta      = 0.92;                % 92% WPT efficiency (Karakitsios 2017, ICT Report 2013)
%                 WPT.SOC_target = x(28);
%                 WPT.SOC_electric_only = x(29);      % Minimum SOC for pure electric driving
%             else
%                 WPT.SOC_target = .8;
%                 WPT.SOC_electric_only = 0.3;        % Minimum SOC for pure electric driving
%             end