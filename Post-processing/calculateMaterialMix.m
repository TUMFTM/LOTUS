function [MaterialMix, ComponentList] = calculateMaterialMix(Param, Eco_Efficiency)
%CALCULATEMATERIALMIX Summary of this function goes here
% Function to calculate the material mix necessary for recycling
% calculation
%   This function take Param as a Imput an uses its weights-values. These
%   are combined with a table specific for each vehicle type in order to
%   evaluate the material mix of each vehicle.
% Components such as the lead acid battery and the li-ion battery are not
% considered as they are treated piecewise.

% this can be updated later, if new tables are available
load('GaBiTables/MaterialMix20200516.mat'); % variable is called materialMix // do not confuse with MaterialMix

% check the Matlabweights
MatWeight = Eco_Efficiency.MatlabWeight;
% VehicleType = Param.Vehicle;
switch Param.Fueltype
    %remove "other" parts and batteries and rename some parts
    case {7, 12}
%         if isfield(MatWeight,'m_OthersEV')
%             MatWeight = rmfield(MatWeight,'m_OthersEV');
%         end
        if isfield(MatWeight,'m_BatteryEV')
            MatWeight = rmfield(MatWeight,'m_BatteryEV');
        end
        if isfield(MatWeight,'m_E_EngineEV')
            MatWeight.m_E_Engine = MatWeight.m_E_EngineEV;
            MatWeight = rmfield(MatWeight,'m_E_EngineEV');
        end
        
    case {1, 14}
%         if isfield(MatWeight,'m_OtherICE')
%             MatWeight = rmfield(MatWeight,'m_OtherICE');
%         end
        if isfield(MatWeight,'m_BatteryLeadAcid')
            MatWeight= rmfield(MatWeight,'m_BatteryLeadAcid');
        end
    case 4
        if isfield(MatWeight,'m_E_EngineHEV')
            MatWeight.m_E_Engine = MatWeight.m_E_EngineHEV;
            MatWeight = rmfield(MatWeight,'m_E_EngineHEV');
        end
        if isfield(MatWeight,'m_EngineHEV')
            MatWeight.m_EngineICE = MatWeight.m_EngineHEV;
            MatWeight = rmfield(MatWeight,'m_EngineHEV');
        end
%         if isfield(MatWeight,'m_OthersHEV')
%             MatWeight = rmfield(MatWeight,'m_OthersHEV');
%         end
        if isfield(MatWeight,'m_BatteryHEV')
            MatWeight = rmfield(MatWeight,'m_BatteryHEV');
        end
        if isfield(MatWeight,'m_BatteryLeadAcid')
            MatWeight = rmfield(MatWeight,'m_BatteryLeadAcid');
        end 
    case 13
        if isfield(MatWeight,'m_E_EngineFCEV')
            MatWeight.m_E_Engine = MatWeight.m_E_EngineFCEV;
            MatWeight = rmfield(MatWeight,'m_E_EngineFCEV');
        end
%         if isfield(MatWeight, 'm_OthersFCEV')
%             MatWeight = rmfield(MatWeight,'m_OthersFCEV');
%         end
        if isfield(MatWeight, 'm_BatteryFCEV')
            MatWeight = rmfield(MatWeight,'m_BatteryFCEV');
        end
end

% correction for tires and wheels
%MatWeight.m_Tires_and_Wheels = (Eco_Efficiency.UsePhase.numTires +7)*MatWeight.m_Tires_and_Wheels;

fnMatlabWeight = fieldnames(MatWeight);

MaterialMix = struct;

% initialize materials
MaterialMix.Steel              = 0;
MaterialMix.Rubber             = 0;
MaterialMix.Aluminium          = 0;
MaterialMix.Duroplast          = 0;
MaterialMix.Thermoplast        = 0;
MaterialMix.Copper             = 0;
MaterialMix.Ceramic            = 0;
MaterialMix.Glass              = 0;
MaterialMix.Organic            = 0;
MaterialMix.Paint              = 0;
MaterialMix.Wood               = 0;
MaterialMix.ElectricalScrap    = 0;

fnMaterialMix = fieldnames(MaterialMix);
% iterate over all components in the MatlabWeight struct
for i = 1 : length(fnMatlabWeight) % for now others is excluded, might be included later, if proper inforation is available
    % iterate over all materials and update them
    for j = 1 : length(fnMaterialMix)
        switch fnMatlabWeight{i}
            case 'm_E_Engine'
                switch Param.Fueltype
                    case {7, 12}
                        MaterialMix.(fnMaterialMix{j}) = MaterialMix.(fnMaterialMix{j}) +...
                            materialMix.(fnMatlabWeight{i}).Percentage(materialMix.(fnMatlabWeight{i}).Material==(fnMaterialMix{j})) * Eco_Efficiency.MatlabWeight.m_E_EngineEV;
                        
                    case 4
                        MaterialMix.(fnMaterialMix{j}) = MaterialMix.(fnMaterialMix{j}) +...
                            materialMix.(fnMatlabWeight{i}).Percentage(materialMix.(fnMatlabWeight{i}).Material==(fnMaterialMix{j})) * Eco_Efficiency.MatlabWeight.m_E_EngineHEV;
                        
                    case 13
                        MaterialMix.(fnMaterialMix{j}) = MaterialMix.(fnMaterialMix{j}) +...
                            materialMix.(fnMatlabWeight{i}).Percentage(materialMix.(fnMatlabWeight{i}).Material==(fnMaterialMix{j})) * Eco_Efficiency.MatlabWeight.m_E_EngineFCEV;
                        
                end
            case 'm_EngineICE'
                switch Param.Fueltype
                    case 4
                    MaterialMix.(fnMaterialMix{j}) = MaterialMix.(fnMaterialMix{j}) +...
                        materialMix.(fnMatlabWeight{i}).Percentage(materialMix.(fnMatlabWeight{i}).Material==(fnMaterialMix{j})) * Eco_Efficiency.MatlabWeight.m_EngineHEV;
                    otherwise
                    MaterialMix.(fnMaterialMix{j}) = MaterialMix.(fnMaterialMix{j}) +...
                        materialMix.(fnMatlabWeight{i}).Percentage(materialMix.(fnMatlabWeight{i}).Material==(fnMaterialMix{j})) * Eco_Efficiency.MatlabWeight.m_EngineICE;
                end
                
            
            otherwise
                MaterialMix.(fnMaterialMix{j}) = MaterialMix.(fnMaterialMix{j}) +...
                materialMix.(fnMatlabWeight{i}).Percentage(materialMix.(fnMatlabWeight{i}).Material==(fnMaterialMix{j})) * Eco_Efficiency.MatlabWeight.(fnMatlabWeight{i});
            
        
        
        end
    end
end

%MaterialMix.Recycling.MaterialMix.numLiIonBattery = 1 + MaterialMix.UsePhase.numBattery;
%MaterialMix.Recycling.MaterialMix.numLeadAcidBattery = 2;

end

