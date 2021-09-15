function [ Param ] = Parameterizing(Fueltype, x, ifElectric, Vehicle, ifOptimized)
% Designed at FTM, Technical University of Munich
%-------------
% Created on: 01.11.2018
% Modified on: 14.12.2018
% ------------
% Version: Matlab2017b
%-------------
% The function Parameterizing() reads the needed parameters for the 
% consumption simulation from the Composition and specifies other
% parameters besieds renaming the variable "Param", this is necessary for
% Optimization.
%
% This function now is renamed to Parameterizing(). It
% merges both the hybrid and non-hybrid parametrizing functions as well as
% the function VSim_parametrieren() into one script for simpler execution.
% The toggle between the stand-alone and optimized simulations is the
% variable ifOptimized assigned in Main_file.
% Bert Haj Ali
% ------------
% Input:    - Fueltype:  a scalar number that defines which type of fuel
%                          is selected
%           - x:           struct array containing all vehicle parameters
%           - Vehicle:     a string which indicate the type of vehicle used
%                          in the simulation. It is one of the fieldnames
%                          of the 'x' matrix
%           - ifElectric:  a discrete 0 or 1 that indicates if the vehicle
%                          is pure electric or not
%           - ifOptimized: a discrete 0 or 1 that indicates if the input
%                          values come after or before the optimization
% ------------
% Output:   - Param: struct array containing all simulation parameters
% ------------
%% Sources
% [1]	M. Fries, M. Sinning, M. Lienkamp, und M. H�pfner, Virtual Truck - A Method for Customer Oriented Commercial Vehicle Simulation, 2016.
% [2]	C. M�hrle et al, �Bayerische Kooperation f�r Transporteffizienz - Truck2030 - Status Report 2016 -,� 2017.
% [3]	M. Fries, M. Kruttschnitt, und M. Lienkamp, �Multi-objective optimization of a long-haul truck hybrid operational strategy and a predictive powertrain control system,� in Twelfth International Conference on Ecological Vehicles and Renewable Energies (EVER), 2017, S. 1�7.
% [4]	M. Fries, S. Wolff, und M. Lienkamp, �Optimization of Hybrid Electric Drive System Components in Long-Haul Vehicles for Evaluation of Transport Efficicency and TCO,� Technische Universit�t M�nchen, M�nchen, 2017.
% [5]	M. Fries, M. Lehmeyer, und M. Lienkamp, �Multi-criterion optimization of heavy-duty powertrain design for the evaluation of transport efficiency and costs,� in IEEE ITSC 2017: 20th International Conference on Intelligent Transportation Systems : Mielparque Yokohama in Yokohama, Kanagawa, Japan, October 16-19, 2017, Piscataway, NJ: IEEE, 2017, S. 1�8.
% [6]	O. Olsson, �Slide-in Electric Road System: Inductive project report,� Viktoria Swedish ICT, G�teborg, Okt. 2013. Gefunden am: Nov. 29 2017.
% [7]	M. Wietschel und et. al, �Machbarkeitsstudie zur Ermittlung der Potentiale des Hybrid-Oberleitungs-Lkw,� Fraunhofer Institut f�r System und, Karlsruhe, 2017.
% 
% ------------

%% Addition Seidenfus 27.04.2020
    Param.Vehicle = Vehicle;

%% Constant parameters
    fprintf('Assigning constant parameters.\n');
    load('cycle_Anfahren.mat'); %#ok<*LOAD> 
    sample_time = 0.1;  %#ok<*NASGU> %[s] Step size for the consumption simulation
    %Factor_EM = 0.2;    %[-] Faktor zur elektrischen Maschine, ab einem Abstand von Factor_EM*M_EM_max zu m_be_min wird Lastpunktverschiebung betrieben

    % Standard Semi Trailer or Long Vehcile? Determines base costs, tractor
    % and trailer weight
    vehicle.long_truck = false;
    
    % TCO calculation with or without a trailer
    TCO_Trailer = true;

    % Payloads [2]
    %vehicle.payload = 0;      % When payload = 0, maximum possible weight is assumed in Gewichtsberechnung
    vehicle.payload = 19300;  % VECTO payload
    %vehicle.payload = 18360; % [kg] 540 kg/Pallette
    %vehicle.payload = 25500; % [kg] bulk
    %vehicle.payload = 11000; % [kg] medium value of weight for goods
%     vehicle.payload = 14000; % [kg] medium weight for autmotive goods or food
    %vehicle.payload = 13120; % [kg] weight for the automotive goods 

    % Active cruise control [3]
    preditiveCruiseControl = 1;      % Active cruise control 1 = ON 0 = OFF

    % Cruising [3]
    Sailing_without_drag_torque = 1;    % ON or OFF

    % Additional factors
    ambient.gravity        = 9.80665; %[m/s^2] gravity
    ambient.air_density    =  1.1883; %[kg/m�] air density
    ambient.friction_coeff = 0.8;     %[-] friction coefficient of the road

    % Driver controls
    driver.controller_proportional_gain = 230000;   %[-] Kp of driver control, delta v of 1m / s leads to 80% accelerator pedal position
    driver.controller_integral_gain     = 3000;     %[-] Ki of drive control
    driver.slew_rate_throttle_in        = 2;        %[-] Maximaler Pedalgraident Gaspedal
    driver.slew_rate_throttle_out       = -2;       %[-] Maximaler Pedalgraident Gaspedal
    driver.slew_rate_brake_in           = 2;        %[-] Maximaler Pedalgraident Bremspedal
    driver.slew_rate_brake_out          = -2;       %#ok<*STRNU> %[-] Maximaler Pedalgraident Bremspedal

    % Complete vehicle optimal concept
    vehicle.frontal_area        = 10.2;           % [m2] Optimum of frontal area (assumption)
    tires.radius                = 0.47*0.95;      % [m] Optimum concept tire radius according to Conti r_dyn, amounts to 95% of the wheel radius (assumption)
    tires.roll_drag_coeff.total = 0.007;%0.0043;         % [-] Optimum concept rolling resistance coefficient (assumption)

    % Choosing which BEV vehicle
    if ~isfield(Vehicle, 'empty')
        switch Vehicle
            case 'BEV_Tesla'
                vehicle.air_drag_coeff = 0.36;

            case 'BEV_OC'
                vehicle.air_drag_coeff = 0.6;

            otherwise
                vehicle.air_drag_coeff = 0.53;           % [-] Optimum concept drag coefficient (assumption)
        end
        
    else
         vehicle.air_drag_coeff = 0.53; 
    end

    % Side consumptions
    auxiliary_consumers.onBattery = false;             %[W] Average power P_NV
    auxiliary_consumers.power = 3500;             %[W] Average power P_NV
%     auxiliary_consumers.power = 20000;             %[W] Average power P_NV

    % Other vehicle parameters
    IZ12 = 3600;   % [mm] Wheelbase

    % Preparation for the consumption simulation
    vehicle.Fx_max      = 11500 * ambient.gravity * ambient.friction_coeff;   % Maximum allowed driving force on the driven axle
    vehicle.F_brake_max = (39500) * ambient.gravity * ambient.friction_coeff; % Maximum breaking force, sum on all axis
    max_distance        = max(cycle.distance);                                % Termination criterion

%% Vehicle design process
    fprintf('Proceeding to vehicle design.\n');
    if ifOptimized % When the parameters are optimized
        [transmission, final_drive, engine] = Transmission_design(x, Fueltype); %#ok<*ASGLU> [4]
        
        % Assign specific parameters depending on the type of fuel
        if ~ifElectric % All drivetrains except electric
            [v_PPC_delta, look_ahead_PPC, distance_1_PPC, distance_2_PPC] = Active_cruise_control(x, Fueltype);

            % Check if hybridization is present
            [SOC_addition,critical_altitude_difference,distance_PPC_altitude_difference,...
             addition_for_critical_slope, em, Bat, SOC_target, SOC_T_EM_completely_available,...
             M_el, T_distance_LPS_up, T_distance_LPS_down] = Hybrid_operating_strategy(x, Fueltype);
         
        else % {Electric, Electric w/WPT, Full cell}
            % Active cruise control [3]
            v_PPC_delta                      = 10/3.6;   % Speed increase/fall below speed, standard value at 7 km/h
            look_ahead_PPC                   = 250;      % 100 - 1000m ahead for seeking the critical slope, lower limit
            distance_1_PPC                   = 175;      % 100 - 500m slope_length_positive Length of slope, sets upper limit with look_ahead
            distance_2_PPC                   = 200;      % 200 -400m slope_length_neg Length of the track before a critical gradient
            addition_for_critical_slope      = 0.01;
            
            [ em, Bat ] = Electric_drivetrain(x);
            %engine.shift_parameter.n_lo       = x(10)*em.n_eck; %untere Schaltschwelle
            %shift_parameter.n_pref     = x(11)*em.n_eck; %obere Schaltschwelle
            
            % Check if WPT or fuell cell are present
            if Fueltype == 12
                %[ WPT ] = Inductive_charging(x, Vehicle);
                Verkehrsdichte = 1;  % 1 = "Normale Verkehrsdichte";  2 = "Mittele Verkehrsdichte" ;  3 = "Hohe Verkehrsdichte"; (Defined by Aonan Shen, on 01.04.2020, Matlab Version R2019b))

                [ OC ] = Overheadline_charging(0.68,4,4);% Overhead line system desgin (Designed by Aonan Shen, on 01.04.2020, Matlab Version R2019b)

                
                
            elseif Fueltype == 13
                [ FuelCell ] = FuelCell_design(x(12), 400); %  FuelCell_design(max power, nominal voltage), function of fuel cell design
                Bat.SOC_start = 0.5;
                %(150, 400)
            end
        end

        % WPT is only used in 'electric drivetrain with WPT'. The values below are
        % generic for non-WPT vehicles and required for the Simulink models to run
%         if Fueltype ~= 12
%             WPT.Voltage          = 0;         % Voltage of the inductive charging, to disable WPT set to 0
%             WPT.P_max             = 200;       % Maximum power in kW
%             WPT.expansion           = 0.6 * 0.7; % eRoad expansion in // Transmitter is ON 70% of the time (Navidi2016)
%             WPT.expansion            = 0.3;
%             WPT.eta               = 0.92;      % 92% WPT efficiency (Karakitsios 2017, ICT Report 2013)
%             WPT.SOC_target        = .8;
%             WPT.SOC_electric_only = 0.3;       % Minimal SOC for pure electric driving
%         end

    else % when the parameters are not optimized
        % Differential design
        final_drive.ratio = 2.846;                    %[-] Differential gear ratio. Also available: 2.71  / 2.846 / 2.92 / 3.077                                                         
%        final_drive.ratio = 10;                      % Gesch�tzt Tesla Semi
        final_drive.trq_eff = 0.98;                   %[-] Efficiency of the differential

%         transmission = Transmission_gearing(1, 1, false, false, final_drive.ratio); % Tesla Semi (assumption)
%         transmission = Transmission_gearing(3, 1, false, false, final_drive.ratio); % Nikola Two  (assumption)
        transmission = Transmission_gearing(15.86, 7, 0, 0, final_drive.ratio); % [4]
%         transmission = Transmission_gearing(5, 3, 0, 0, final_drive.ratio);

        % Electric driving parameters [3]
        SOC_target = 0.85;                          %SOC target
        SOC_T_EM_completely_available    = 0.5;     % SOC_Boosting_fully available
        v_max_electrical_drive_only      = 50/3.6;  % Maximum speed up to which the vehicle is driven purey electrically 
        T_distance_LPS_up                = 250;     % Distance to the line of minimal consumption in Nm 
        T_distance_LPS_down              = 250;     % Distance to the line of minimal consumption in Nm 

        distance_PPC_altitude_difference = 10000;  % The distance ahead in m that the active cruise control can see
        critical_altitude_difference     = 50;     % critical height distance in m
        SOC_addition                     = 0.4;    % SOC_addition is incremented by SOC_addition
        M_el                             = 100;   % Maximum torque up to which the vehicle is driven purey electrically 
        SOC_el                           = 0.8;

        % Active cruise control [3]
        v_PPC_delta                      = 10/3.6;   % Speed increase/fall below speed, standard value at 7 km/h  
        look_ahead_PPC                   = 250;      % 100 - 1000m ahead for seeking the critical slope, lower limit
        distance_1_PPC                   = 175;      % 100 - 500m slope_length_positive Length of slope, sets upper limit with look_ahead
        distance_2_PPC                   = 200;      % 200 -400m slope_length_neg Length of the track before a critical gradient  
        addition_for_critical_slope      = 0.01;

       % Battery design, for hybrid and non-hybrid vehicles  [5]
        Bat.SOC_start                        = 1;      % [-] Initial battery SOC
        Bat.Voltage                          = 800;    % Battery voltage
        Bat.Useable_range                = 0.8;   % Battery DoD %0.8
        %Bat.Charge_cycles                      = ((Bat.Useable_range*100)/103620)^(1/-0.833); % Anzahl der Ladezyklen Quelle: MARKEL, T. und SIMPSON, A.: Plug-in Hybrid Electric Vehicle Energy Storage System Design. In: Advanced Automotive Battery Conference Baltimore, Maryland, 2006
        Bat.Charge_cycles                       = 3000; % Number of charging cycles. Source: MARKEL, T. und SIMPSON, A.: Plug-in Hybrid Electric Vehicle Energy Storage System Design. In: Advanced Automotive Battery Conference Baltimore, Maryland, 2006
        %Bat.Useable_capacity             = 9.2;    % [Ah] HYB1
        %Bat.Useable_capacity             = 30;     % [Ah] HYB2
        Bat.Useable_capacity              = 61.538; % [Ah] Battery capacity 
        Bat.Efficiency_power_electronics = 0.95;   % [-] Efficiency of the power electronics converter
        Bat.Type                             = 2;      % [1: Cylindrical (21700), 2: Pouch], used for costs, weight and constraints calculation (Wolff 2017)

        % Electric motor design, for hybrid and non-hybrid vehicles
        em.Type  = 1;                                 % 1: ASM (Standard); 2: PMSM
        em.n_eck = 1300;                              % [1/min]
        em.M_max = 2000;                              % [Nm] Maximum torque
        em.n_max = 2000;
        em.P_max = ((em.n_eck * em.M_max *2* pi)/60)/1000;

%     HYB1
%         em.P_max = 68;                               %[kW] Maximum power
%         em.M_max = 500;                              %[Nm] Maximum torque
%     
%     HYB2
%         em.P_max = 136;                               %[kW] Maximum power
%         em.M_max = 1000;                              %[Nm] Maximum torque
%     
%     HYB3
%         em.P_max = 204;                               %[kW] Maximum power
%         em.M_max = 1500;                              %[Nm] Maximum torque

        if Fueltype == 7 || Fueltype == 12 || Fueltype == 13
        % electric motor design, for pure electric vehicles
            em.Type  = 2;                                         % 1: ASM; 2: PMSM
%             em.M_max = 430*4;                                    % [Nm] Tesla Semi
            em.M_max = 2700;                                     % Nikola Two FCEV
        %     em.M_max = 2100;                                     % [Nm] Maximum torque
%             em.P_max = 192*4;                                    % [kw] Maximum power of Tesla Semi
            em.P_max = 750;                                      % Maximum power of Nikola Two FCEV
        %     em.n_eck = 5000;                                     % [1/min]
            em.n_max = 10000;                                    % [1/min]

        % Battery design, for pure electric vehicles
            Bat.Type                 = 1;
            %Bat.Useable_capacity = 1000000/Bat.Voltage;     % [Ah] Tesla Semi
            %Bat.Useable_capacity = 320000/Bat.Voltage;     % [Ah] Nikola Two FCEV

            Bat.Useable_capacity = 50; %was 100                      % [Ah] Opti VR
            %Bat.Useable_capacity = 250;
            %Bat.Useable_capacity = 300;                      % [Ah] Inductive charging
            %Bat.Useable_capacity = 300;                      % [Ah] Truck with overhead lines
            Bat.SOC_start                        = 0.5;      % [-] Initial battery SOC

        end
        
        % Wireless Power Transfer design [6]
        WPT.Voltage          = 0;         % [V] Voltage for inductive charging in, to disable set WPT to 0
        WPT.P_max             = 120;       % [kW] Maximum power
        WPT.expansion           = 0.6 * 0.7; % eRoad expansion in // Transmitter is ON 70% of the time (Navidi2016)
        WPT.eta               = 0.92;      % 92% WPT efficiency (Karakitsios 2017, ICT Report 2013)
        WPT.SOC_target        = 1;         % SOC target for the inductive charging logic
        WPT.SOC_electric_only = 1;         % Minimal SOC for pure electric driving
    
      % WPT design for truck with overheadlines [7]
%         WPT.Voltage = 650;           % [V] Voltage for inductive charging in, to disable set WPT to 0
%         WPT.P_max    = 500;           % [kW] Maximum power
%         WPT.expansion   = 0.6;           % eRoad expansion in // Transmitter is ON 70% of the time (Navidi2016)
%         WPT.eta      = 0.96;          % 92% WPT efficiency (Karakitsios 2017, ICT Report 2013)
%         WPT.SOC_target = 1;           % SOC target for the inductive charging logic
%         WPT.SOC_electric_only = 0.3;  % Minimal SOC for pure electric driving

        % Fuell cell design
        if Fueltype == 13
            FuelCell = FuelCell_design(180, 600); %  FuelCell_design(P_max, Nominal voltage)

        else
            FuelCell.P_nom = 0;
        end

        % ICE engine design
%         engine.M_max = 2100;                           % [Nm] Maximum torque
%         engine.M_max = 2231;
        engine.M_max = 2400;                           % [Nm] Maximum torque

        %engine.M_max = 1700;                          % [Nm] HYB 1
        %engine.M_max = 1500;                          % [Nm] HYB 2
        %engine.M_max = 1300;                          % [Nm] HYB 3
    end
    
    % Tank sizes for cost and weight calculations
    [tank] = Tank_sizes(Fueltype);

    %% ICE engines & motors mapping
    if ifOptimized
        switch Fueltype % Vehicles with ICE engines
            case {1,4}    %{'Diesel','Diesel-Hybrid'}
                [engine] = Diesel_engine_mapping(engine.M_max, engine.shift_parameter.n_lo, engine.shift_parameter.n_pref);

            case {2,3,5,6}    %{'CNG','LNG','CNG-Hybrid','LNG-Hybrid'}
                [engine] = Gas_engine_mapping(engine.M_max, Fueltype, engine.shift_parameter.n_lo, engine.shift_parameter.n_pref);

            case {8,9,16,10,11,17}    %{Dual-Fuel {CNG, LNG, H2}, Dual-Fuel Hybrid {CNG, LNG, H2}}
                [engine] = Dual_fuel_engine_mapping(engine.M_max, Fueltype, engine.shift_parameter.n_lo, engine.shift_parameter.n_pref);

            case {7, 12, 13}    % Electric truck
                engine.M_max  = 0;
                engine.number = 4;
                
            case {14,15}    %{'H2ICE','H2ICE-Hybrid'}
                [engine] = Hydrogen_engine_mapping(engine.M_max, engine.shift_parameter.n_lo, engine.shift_parameter.n_pref);
             
        end
        
    else
        switch Fueltype % Shifting strategies
            case {1,4}    %{'Diesel','Diesel-Hybrid'}
                engine.shift_parameter.n_lo = 1000;             % Euro VI downshift
                engine.shift_parameter.n_pref = 1200;           % Euro VI upshift
                [engine] = Diesel_engine_mapping(engine.M_max, engine.shift_parameter.n_lo, engine.shift_parameter.n_pref);
                
            case {2,3,5,6}    %{'CNG','LNG','CNG-Hybrid','LNG-Hybrid'}
                engine.shift_parameter.n_lo = 1100;             % Euro V downshift
                engine.shift_parameter.n_pref =1300;            % Euro V upshift
                [engine] = Gas_engine_mapping(engine.M_max, Fueltype, engine.shift_parameter.n_lo, engine.shift_parameter.n_pref );
                
            case {8,9,16,10,11,17}    %{Dual-Fuel {CNG, LNG, H2}, Dual-Fuel Hybrid {CNG, LNG, H2}}
                engine.shift_parameter.n_lo = 1100;             % downshift
                engine.shift_parameter.n_pref =1400;            % upshift
                [engine] = Dual_fuel_engine_mapping(engine.M_max, Fueltype, engine.shift_parameter.n_lo, engine.shift_parameter.n_pref);
                
            case {7, 12, 13}    % Elektro LKW
                engine.M_max  = 0;
                engine.number = 4;
                
            case {14,15}    %{'H2ICE','H2ICE-Hybrid'}
                engine.shift_parameter.n_lo = 1000;             % Euro VI downshift
                engine.shift_parameter.n_pref = 1200;           % Euro VI upshift
                [engine] = Hydrogen_engine_mapping(engine.M_max, engine.shift_parameter.n_lo, engine.shift_parameter.n_pref);
                
        end
    end
    
    [em, Hybrid_Truck, Electric_Truck] = Electric_machine_mapping(Fueltype, em.n_eck, em.M_max, em.n_max, Bat.Voltage, em.P_max, em.Type, ifOptimized);

    
%% Simulation selection
    switch Fueltype
        case {1, 4, 14, 15} % Diesel(hybrid) & H2ICE(hybrid)
            name = 'HDVSim_Hybrid_Truck';

        case {8, 9, 10, 11, 16, 17} % Dual-Fuel (hybrid)
            name = 'HDVSim_Dual_Fuel_Hybrid_Truck';

        case {2, 3, 5, 6} % Gas(hybrid)
            name = 'HDVSim_XNG_Hybrid_Truck';

        case 7 % Elektro
            name = 'HDVSim_BEV_Truck';

        case 12 % Elektro mit Wireless Power Transfer
            name = 'HDVSim_BEV_OC_Truck';

        case 13 % FCEV
            name = 'HDVSim_FCEV_Truck';
    end
    
%% Assemble workspace with Param
    list = whos;       
    Param = struct;
    for  i = 1:length(list)
        switch list(i).name
            case {'i', 'Param', 'list', 'hws', 'Composition'} % Diese Workspace-Variablen werden nicht in Param geschrieben

            otherwise
            Param.(list(i).name)                = eval(list(i).name);
        end
    end
%% Classes initialization
    % Wolff 2017
    %Param.weights = weights(Param, true, Vehicle); % initialize weights
    Param.weights = weights(Param, true);
    [Param] = Weights_calculation(Param, Vehicle); % Run weights calculation
    %Param.acquisitionCosts = acquisitionCosts(Param, true, Vehicle); % Acquisition cost initialization
    Param.acquisitionCosts = acquisitionCosts(Param, true); 
    % TCO initialization (Schatkowski)
    helpStruct = load('costStruct_2020_exclTax.mat');
    costStruct = helpStruct.costStruct;
    
    Param.TCO = TCO(1+TCO_Trailer, costStruct, true);
    Param.TCO.Operating_life(1) = 10;
    
    Param.vehicleProperties = vehicleProperties; % Properties initialization

    % Wird f�r Standalone verwendet, sonst in NFZEP berechnet
    Param.vehicleProperties.VWF_ak = 0.9;
    Param.vehicleProperties.BOK_ak = 2.55;
    Param.vehicleProperties.V_Rel_ak = 0.55;
end