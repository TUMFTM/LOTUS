function [m_kraftstoff, m_tank] = Fuel_tank_weights(Param)
% Designed by Bert Haj Ali in FTM, Technical University of Munich
%-------------
% Created on: 20.11.2018
% ------------
% Version: Matlab2017b
%-------------
% Function that calculates the weight of fuel and AdBlue tanks as well as
% exhaust's gasses treatment
% ------------
% Input:    - Param:        a struct array that contains all vehicle parameters.
%                           This function only uses the ones related to weight calculation
% ------------
% Output:   - m_kraftstoff: a scalar number that defines the net weight of
%                           the fuel used, such as diesel or LNG
%           - m_tank:       a scalar number that defines the net weight of
%                           the fuel tank, or fuel + AdBlue tanks, without
%                           fuel
% ------------
%% Sources
% [1]	M. Fries, “Maschinelle Optimierung der Antriebsauslegung zur Reduktion von CO2-Emissionen und Kosten im Nutzfahrzeug,” Dissertation, Lehrstuhl für Fahrzeugtechnik, Technische Universität München, München, 2018.
% [2]	W. Artl, “Wasserstoff und Speicherung im Schwerlastverkehr: Machbarkeitsstudie,” Friedrich-Alexander Universität Erlangen-Nürnberg, Erlangen, 2018. [Online] Verfügbar: https://www.tvt.cbi.uni-erlangen.de/LOHC-LKW_Bericht_final.pdf. Gefunden am: Mai. 02 2018.
% ------------

    rho_diesel = 0.85;
    rho_cng = 0.00081;
    rho_lng = 0.54;
    
    switch Param.Fueltype
        case {1, 4} % All variants with diesel engines
            m_kraftstoff = Param.tank.v_diesel * rho_diesel + rho_cng * Param.tank.v_cng + rho_lng * Param.tank.v_lng;
            m_tank = 17.159 * log(Param.tank.v_diesel) - 54.98; % [kg] Source: Ramon Tengel

        case {3, 6} % All variants with LNG
            m_kraftstoff = Param.tank.v_diesel * rho_diesel + rho_cng * Param.tank.v_cng + rho_lng * Param.tank.v_lng;
            m_tank = 8.935 * (Param.tank.v_lng^0.5579); % [kg] Source: Ramon Tengel

        case {2, 5} % All variants with CNG
            m_kraftstoff = Param.tank.v_diesel * rho_diesel + rho_cng * Param.tank.v_cng + rho_lng * Param.tank.v_lng;
            m_tank = 0.3773 * Param.tank.v_cng + 8.2657; % [kg] Source: Ramon Tengel

        case {7, 12} % Electric truck
            m_tank = 0;
            m_kraftstoff = 0;

        case {8, 10} % Dual Fuel Diesel + CNG (Composite Tank)
            m_diesel = 17.159 * log(Param.tank.v_diesel) - 54.98;
            m_cng = 0.3773 * Param.tank.v_cng + 8.2657;
            m_kraftstoff = Param.tank.v_diesel * rho_diesel + rho_cng * Param.tank.v_cng + rho_lng * Param.tank.v_lng;
            m_tank = m_diesel + m_cng + 20; % 20kg extra weight for dual fuel. Source: SA Jon Schmidt

        case {9, 11} % Dual Fuel Diesel + LNG
            m_diesel = 17.159 * log(Param.tank.v_diesel) - 54.98;
            m_lng = 8.935 * Param.tank.v_lng^0.5579;
            m_kraftstoff = Param.tank.v_diesel * rho_diesel + rho_cng * Param.tank.v_cng + rho_lng * Param.tank.v_lng;
            m_tank = m_diesel + m_lng + 20; % 20kg extra weight for dual fuel. Source: SA Jon Schmidt

        case {13}
            m_tank = Param.tank.m_h2 * 17.5;    % [2]
            m_kraftstoff = Param.tank.m_h2;        
    end
end