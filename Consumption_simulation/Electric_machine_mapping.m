function [em, Hybrid_Truck, Electric_Truck] = Electric_machine_mapping( Fueltype, Eckdrehzahl, Maximales_Drehmoment, Maximale_Drehzahl, Spannung, Maximale_Leistung, typ_EM, ifOptimized)
% Designed by Sebastian Wolff at FTM, Technical University of Munich
%-------------
%Param.Fueltype, Param.em.n_eck, Param.em.M_max, Param.em.n_max, Param.Bat.Voltage, Param.em.P_max, Param.em.Type, false
% Created in: 2017
% ------------
% Version: Matlab2017b
%-------------
% Function representing the torque map and efficiency map of an electric
% machine. Required by the consumption simulation.
% ------------
% Input:    - Fueltype:           a scalar number that defines which type
%                                   of fuel is selected
%           - Eckdrehzahl: 
%           - Maximales_Drehmoment: a scalar representing maximum torque
%                                   from the electric motor
%           - Maximale_Drehzahl:    a scalar representing maximum
%                                   rotational speed in rpm from the
%                                   electric motor
%           - Spannung:             a scalar that defines the voltage tha
%                                   the electric motor receives
%           - Maximale_Leistung:    a scalar representing the maximum power
%                                   of the electric motor. Product of speed
%                                   and torque
%           - typ_EM:               Discrete number, 1 or 2, that specifies
%                                   which type of electric machine the
%                                   vehicle uses
% ------------
% Output:   - em:                   struct array containing electric
%                                   machine variables
%           - Hybrid_Truck:           Discrete number, 0 or 1, that specifies
%                                   if there is electrification in the
%                                   vehicle
%           - Electric_Truck:          Discrete number, 0 or 1, that specifies
%                                   if the vehicle is pure electric
% ------------
    %% To determine if electric drive is present
    % switch Fueltype
    % case {4, 5, 6, 10, 11}
    %     Hybrid_Truck = 1;                                 % Hybrid_Truck 1 = ON, there is electrification, even with pure electric drive 
    %     Electric_Truck = 0;                                % Electric_Truck 0 = OFF, there is no pure electric drive only
    %     
    % case {7, 12, 13}
    %     Hybrid_Truck = 1;                                 % Hybrid_Truck 1 = ON, there is electrification, even with pure electric drive 
    %     Electric_Truck = 1;                                % Electric_Truck 1 = ON, there exists pure electric drive only
    %     
    % case {1, 2, 3, 8, 9}
    %     Hybrid_Truck = 0;                                 % Hybrid_Truck 0 = OFF, there is only pure ICE engines
    %     Electric_Truck = 0;                                % Electric_Truck 0 = OFF, there is no pure electric drive only
    % end

    switch Fueltype
        case {4,5,6,10,11,15,17}
            Hybrid_Truck = 1;                               % Hybrid_Truck 1 = ON, there is electrification, even with pure electric drive 
            Electric_Truck = 0;                              % Electric_Truck 0 = OFF, there is no pure electric drive only

            %em.P_max = Maximale_Leistung;                 %[kW] Maximum power
            em.M_max = Maximales_Drehmoment;              %[Nm] Maximum torque
            em.n_eck = Eckdrehzahl;
            em.P_max = ((em.n_eck * em.M_max *2* pi)/60)/1000;
            em.n_max = Maximale_Drehzahl;                 %[1/min] Maximum rotational speed   

    %         em.M_max = Maximales_Drehmoment;                   %[Nm] Maximum torque
    %         em.n_eck = Eckdrehzahl;                            %[1/min] Rotational speed
    %         em.n_max = Maximale_Drehzahl;                      %[1/min] Maximum speed    
    %         em.P_max = ((em.n_eck * em.M_max *2* pi)/60)/1000; %[kW] Maximum power
    %     
        case {7, 12, 13}
            Hybrid_Truck = 1;                               % Hybrid_Truck 1 = ON, there is electrification, even with pure electric drive 
            Electric_Truck = 1;                              % Electric_Truck 1 = ON, there exists pure electric drive only

            em.M_max = Maximales_Drehmoment;        %[Nm] Maximum torque
            em.n_max = Maximale_Drehzahl;           %[1/min] Maximum speed

            if ~ifOptimized
                em.P_max = Maximale_Leistung;              %[kW] Maximum power
                em.n_eck = em.P_max*1000/em.M_max/2/pi*60; %[1/min] Rotational speed
                   
            else 
                em.n_eck = Eckdrehzahl;
                em.P_max = ((em.n_eck * em.M_max *2* pi)/60)/1000;

            end
    %         if Maximale_Leistung
    %             em.P_max = Maximale_Leistung;           %[kW]
    %             %Determination of rotational speed
    %             em.n_eck = Eckdrehzahl; %The default value of Hybrid will be overwritten in the next line.
    %             em.n_eck = em.P_max*1000/em.M_max/2/pi*60;
    %         else
    %             em.n_eck = Eckdrehzahl;                        %[rpm]
    %             em.P_max = ((em.n_eck * em.M_max *2* pi)/60)/1000; %[kW] Maximum power
    %         end

        otherwise
            Hybrid_Truck = 0;                               % Hybrid_Truck 0 = OFF, there is only pure ICE engines
            Electric_Truck = 0;                              % Electric_Truck 0 = OFF, there is no pure electric drive only

            % No Hybrid/Electric, mapping is generaed but not used
%             em.P_max = 300;     %[kW]
%             em.M_max = 630;     %[Nm]
%             em.n_max = 2000;    %[rpm]

            
            
    end

    % Assignment of machine number (now takes place directly in VSim_parameterize)
    % Wolff 2017, not used here
    % if Electric_Truck == 1
    %     engine.number = 4;

    % else
    %     % So that even with no electric truck, the varialble engine is still available
    %     % otherwise error message
    %     engine.number = NaN;
    %     
    % end 

    %% Distinction between hybrid and fully electric drivetrain

    % If this script or the default values ??for the electric drive
    % are to be adapted in drive initialization, then the
    % standard maps must also be recreated!

    % If there is no hybrid, or if the default settings for hybrid vehicles have not been chosen 
    if Hybrid_Truck == 0 || (Electric_Truck == 0  && Maximales_Drehmoment == 1050 && Maximale_Drehzahl == 2000 && Spannung == 650 && typ_EM == 1)
              load('characteristic_map_em_standard_hybrid');
              
    % If the default settings (E Force One) for electric vehicles have been chosen
    elseif Electric_Truck == 1 && round(Maximales_Drehmoment) == 2041 && Maximale_Drehzahl == 4418 && Spannung == 800 && typ_EM == 2
%               load('characteristic_map_em_standard_electric');
              load('engineMap_EForce.mat');
    % If the default settings (Nikola Tre) for fuel cell electric vehicles have been chosen
    elseif Electric_Truck == 1 && round(Maximales_Drehmoment) == 452 && Maximale_Drehzahl == 4395 && Spannung == 800 && typ_EM == 2
            load('engineMap_Nikola.mat');
    else
        %% Shifiting parameters

        %Last modified by Jon Schmidt on 10.05.2016
        %Switching parameters based on the electric motor in the E-Force One truck optimized with
        %final drive ratio: 7.684 on driving cycle ACEA 
        %(the following values result from the efficiency map of the electric motor)

        %em.shift_parameter.n_lo = 0.71*em.M_max;                                                   %Slanted upshift    
        em.shift_parameter.n_pref = 0.94*em.n_eck;                                              %Vertical upshift (rotational speed)                                                           

        %em.shift_parameter.n1 = em.M_max;                                                          %Slanted downshift, not used                                                               
        em.shift_parameter.n2 = 0.21*em.n_eck;                                                   %Vertical downshift, (Tangent to 95% efficiency)                                                                
        %em.shift_parameter.n3 = (em.shift_parameter.n_lo + em.shift_parameter.n_pref) / 2;         %Slanted downshift, not used
        %em.shift_parameter.n4 = 0.29*em.n_eck;                                                     %Not used        
        %em.shift_parameter.n5 = em.shift_parameter.n_pref;                                         %Vertical upshift
        em.shift_parameter.n6 = 0.8*em.n_max;                                              %Field weakening range is entered in the efficiency optimum range

        % Well-to-Wheel CO2-Emission according to [Edw14, S.122], average emissions
            % After Eu-Mix (2017)
 %          em.fuel.co2_per_kwh = 504;                  %[gCO2/kWh]
           em.fuel.co2_per_kwh = 478;                  %[gCO2/kWh] Status Elektromobilit�t 2020 "Referenz-Szenario 2020"
 %           em.fuel.co2_per_kwh = 366;                  %[gCO2/kWh] Status Elektromobilit�t 2020 "Realistisches Szenario 2030"

        %% Electrical machine
        % Torque map adapted to motor data
        % Jon Schmidt, 08.01.2016
         em.speed = (0:10:em.n_max);
         em.trq = zeros(1,(em.n_max/10+1));
         em.Type = typ_EM;

        for i = 1:((em.n_max/10)+1)
            if em.speed(i) <= em.n_eck
                em.trq(i) = em.M_max;
            end

            if em.speed(i) > em.n_eck
                em.trq(i) = em.P_max*1000/em.speed(i)/2/pi*60;
            end
        end

        %% Calculation of the efficiency of PMSM or ASM machines
        % Specification of the desired data
        M_EM_nenn = em.M_max;  % [Nm]
        M_EM_max = em.M_max;   % [Nm] considering reasonable ratio of maximum to rated torque
        n_EM_nenn = em.n_eck;  % [1/min]
        n_EM_max = em.n_max;  % [1/min] observing appropriate field weakening range
        P_EM_nenn = M_EM_nenn * n_EM_nenn/60*2*pi;
        %typ_EM = 'PMSM';    % 'ASM' or 'PMSM'

        eta_mit_LE = 0;     % 1: efficiency of power electronics converter is 1 (in this case the parameter Eff.v of the "SimpleInverter" module must be set to 1 in DynA4)
        U_Bat = Spannung;    % Battery voltage [V]
        cos_phi = 0.85; % Average power factor

        % Calculation of the characteristics
        % cwd = fullfile(pwd, filesep, 'Verbrauchssimulation', filesep, 'Parameter', filesep);
        % cd([cwd  'Erzeugung_Wirkungsgradkennfeld_Dateien' filesep])

        [vektor_eta, step_M, step_n, vektor_M_max, vektor_M, vektor_n, M_EM_max, n_EM_nenn, m_EM, J_EM] = Interpolieren(M_EM_nenn, n_EM_nenn, M_EM_max, n_EM_max, P_EM_nenn, typ_EM);

        % Run the conversion script
        %[vektor_Pelv, vektor_Pelr, vektor_Irmsv, vektor_Irmsr, vektor_Urms] = Umrechnung(vektor_eta, M_EM_max, n_EM_nenn, U_Bat, cos_phi, step_n, step_M);

        % Run the LE_Berechnung.m script
        %[m_LE, eta_LE] = LE_Berechnung(P_EM_nenn, vektor_Pelv, vektor_Pelr, vektor_Irmsv, vektor_Irmsr, vektor_Urms, U_Bat, cos_phi);

        % Calculation of overall efficiency of electric machine & power electronics
        %if eta_mit_LE == 1
        %    vektor_eta = vektor_eta .* eta_LE;
        %end

        % Preparing the data for DynA4
        Inrt_v = J_EM;

        matrix=zeros(201,201);
        for idx=1:201
            matrix(:,idx) = vektor_eta(((idx-1)*201+1):((idx-1)*201+201));
        end

        MaxMotorTrqCurve_x = (vektor_n /60*2*pi)';      % convert to rad/s
        MaxMotorTrqCurve_v = vektor_M_max;

        %MaxGeneratorTrqCurve_x = (vektor_n /60*2*pi)';  % convert to rad/s
        %MaxGeneratorTrqCurve_v = vektor_M_max;

        MotorEffMap3D_y = (vektor_n /60*2*pi)'; % convert to rad/s
        MotorEffMap3D_z = vektor_M(101:201)';

        %GeneratorEffMap3D_y = (vektor_n /60*2*pi)'; % convert to rad/s
        %GeneratorEffMap3D_z = vektor_M(101:201)';

        matrix = [ones(201,1)*0.001, matrix(:,2:end)]; % Speed ??0 gets an efficiency of 0.001 (necessary for DynA4)

        for M=2:101
            MotorEffMap3D_v( :, :, M  ) = matrix (M+100,:);
            %GeneratorEffMap3D_v( :, :, M  ) = matrix(102-M,:);
        end

        %GeneratorEffMap3D_v(GeneratorEffMap3D_v==0)= 0.001; % replace 0 with 0.001 (Efficiency 0 leads to invalid results for DYNA4)
        MotorEffMap3D_v(MotorEffMap3D_v==0)= 0.001; % replace 0 with 0.001 (Efficiency 0 leads to invalid results for DYNA4)

        %cd(cwd);

        % Teil Michael
        eta = zeros (201,101);

        for a = 1:201

            for b = 1:101
                eta(a,b) = MotorEffMap3D_v(1,a,b);
                b=b+1;
            end

            a=a+1;
        end

        em.efficiency.characteristic_map   = eta';
        em.efficiency.speed   = MotorEffMap3D_y *60/2/pi;
        em.efficiency.torque = MotorEffMap3D_z;

        % Assign remaining switching parameters
        em.shift_parameter.M_max = max(em.trq);
    
        % Default no. of Machines
        em.noEM = 2;
    end

end