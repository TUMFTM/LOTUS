function [ transmission ] = Transmission_properties(Param)
% Designed by Sebastian Wolff in FTM, Technical University of Munich
%-------------
% Created on: 23.05.2016
% ------------
% Version: Matlab2016b
%-------------
% The function determines the transmission weight and cost. It uses the
% parameters "Eingangsmoment", "Maximaler Übersetzung" and "Ganganzahl" to
% determine the transmission properties.
% Die Berechnung erfolgt anhand, der von
% Naunheimer et al vorgeschlagenen Formeln, bzw. Werte.
% ------------
% Input:    - Param: struct array containing all simulation parameters
% ------------
% Output:   - transmission: struct array containing transmission variables.
%                           The new properties are added to it
% ------------
%% Pass variables
transmission = Param.transmission;
engine = Param.engine;
final_drive = Param.final_drive;
tires = Param.tires;
vehicle = Param.vehicle;
ambient = Param.ambient;
overall_ratio = transmission.ratios .* final_drive.ratio;
total_eff = transmission.trq_eff .* final_drive.trq_eff;
total_weight = Param.weights.m_Total; % Fully loaded condition

%% Variables of the electric truck
if Param.Fueltype == 7 || Param.Fueltype == 12 || Param.Fueltype == 13
   engine.full_load.speed = Param.em.speed;
   engine.full_load.trq = Param.em.trq;
   engine.full_load.power = Param.em.trq .* Param.em.speed * 2 * pi / (60 * 1000);
   engine.speed_min = 0;
   engine.speed_max = Param.em.n_max;
   engine.M_max = Param.em.M_max;
end

%% Properties calculations

% Percentage of gradeability in 1st gear
for i=1:length(transmission.ratios)
    F_traction = engine.M_max * overall_ratio(i) * total_eff(i) / tires.radius; % Maximum traction force
    alpha = asind(F_traction / (total_weight * ambient.gravity)); % Grade angle
    
    if isreal(alpha)
        transmission.q(i) = round(tand(alpha)*100,3);
        
    else
        transmission.q(i) = 100;
    end
end

%% Percentage of startability on gradients in 1st gear
alpha_anfahren = 1:0.05:60;

% 40% acceleration of MAN TGX.540 (top model) in the plane
a = 0.4 * 0.5168;

% Approachability is determined iteratively
for i=1:length(alpha_anfahren)
    F_anfahren = total_weight * (ambient.gravity * cosd(alpha_anfahren(i))* tires.roll_drag_coeff.total...
        + ambient.gravity* sind(alpha_anfahren(i)) + transmission.lamda(1) * a);
    
    if F_anfahren < F_traction
        transmission.q_starting = tand(alpha_anfahren(i)) * 100;

    else
        transmission.q_starting = 0;
    
    end
end

%% Rangiergeschwindigkeit 1. & 2. Gang bei speed_min rpm
pos = abs(engine.full_load.speed - engine.speed_min) < 50;

v_r1 = 7.2 * pi * engine.full_load.speed(pos) * tires.radius / (60 * final_drive.ratio * transmission.ratios(1));
v_r2 = 7.2 * pi * engine.full_load.speed(pos) * tires.radius / (60 * final_drive.ratio * transmission.ratios(2));

transmission.v_manoeuvre1 = v_r1;
transmission.v_manoeuvre2 = v_r2;

%% Reststeigfähigkeit (Steigung, die ohne Runterschalten bei 85 km/h bewältigt werden kann)
% Rotational speed, n_85, at 85 km/h

transmission.n_85 = 85 * 60 * final_drive.ratio * transmission.ratios(end) / (7.2 * pi * tires.radius);

% Maximum power and traction at n_85
P_n85 = interp1(engine.full_load.speed, engine.full_load.power, transmission.n_85); % kW
F_traction_n85 = P_n85 * 1000  * transmission.trq_eff(end) * final_drive.trq_eff / (85 / 3.6); % N

% Travel resistance, level at 85 km/h, no acceleration, in N
F_resistance = total_weight * ambient.gravity * tires.roll_drag_coeff.total +...
    0.5 * ambient.air_density * vehicle.frontal_area *...
    vehicle.air_drag_coeff * (85/3.6)^2;

% Excess traction in N
F_traction_Rest = F_traction_n85 - F_resistance;

% Calculation of gradeability in %
transmission.q_remain_climb = 0;

for i=1:length(alpha_anfahren)
    F_Steigfaehigkeit = total_weight * (ambient.gravity * cosd(alpha_anfahren(i)) * tires.roll_drag_coeff.total...
        + ambient.gravity * sind(alpha_anfahren(i)))...
        + 0.5 * ambient.air_density * vehicle.frontal_area * vehicle.air_drag_coeff * (85/3.6)^2 - F_resistance ;
    
    if F_Steigfaehigkeit < F_traction_Rest
        transmission.q_remain_climb = tand(alpha_anfahren(i)) * 100; % [%]
        
    else
        break
    end
end

%% Output the results
if Param.VSim.Display >= 1 && Param.VSim.Opt == false
    fprintf('Maximum climbing ability in 1st gear:         %.4f %% \n', transmission.q(1))
    fprintf('Maximum climibing slope without downshifting: %.4f %% \n', transmission.q_remain_climb)
    fprintf(' \n');
end

end