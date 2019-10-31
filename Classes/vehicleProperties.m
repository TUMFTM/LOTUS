classdef vehicleProperties
    properties 
    % Emissions
        CO2_EM
        CO2_EM_ak
        CO2_EM_GU       = 0                     % Lower limit
        CO2_EM_GO       = 100                   % Upper limit
        CO2_EM_Range
        
    % Acceleration
        a_0_80
        a_0_80_ak
        a_0_80_GU       = 16.0;                 % Empty SZM2 + SAL1
        a_0_80_GO       = 70.0;                 % MAN TGX 18.440  Trucker Supertest, reference configuration NFZEP
        a_0_80_Range
        
    % BO-Kraftkreis
        BOK
        BOK_ak
        BOK_GU          = 2.55;                 % Lower limit, vehilce_width = 2.55m
        BOK_GO          = 7.2;                  % Upper limit, External_dimensions(12.5m) - Inner_dimensions(5.3m)
        BOK_Range
        
    % Loading volume/space
        V_Rel
        V_Rel_ak
        V_Rel_GU        = 0.25;                 % SZM3 + BDBL = 0.27
        V_Rel_GO        = 0.60;
        V_Rel_Range 
        
    %Roadwear factor
        VWF
        VWF_ak
        VWF_GU          = 0.9                   % Lower limit      best configuration      0.98    SZM2 + SAL1
        VWF_GO          = 8.1                   % Upper limit      worst configuration     8.03    SZM2 + SAL1(16t)
        VWF_Range
	
    % Overall operation
        EF                                      % Total value of the propertie
        n               = 5                     % Number of propertie
    end
    
    methods
        %function EF = get.EF(obj)
        %    EF=(obj.VWF+obj.CO2_EM+obj.BOK+obj.V_Rel+obj.a_0_80)/obj.n;
        %end
        
        function VWF_Range = get.VWF_Range(obj)
            VWF_Range=obj.VWF_GO-obj.VWF_GU;
        end
        
        function CO2_EM_Range = get.CO2_EM_Range(obj)
            CO2_EM_Range=obj.CO2_EM_GO-obj.CO2_EM_GU;
        end
        
        function BOK_Range = get.BOK_Range(obj)
            BOK_Range=obj.BOK_GO-obj.BOK_GU;
        end
        
        function V_Rel_Range = get.V_Rel_Range(obj)
            V_Rel_Range=obj.V_Rel_GO-obj.V_Rel_GU;
        end
        
        function a_0_80_Range = get.a_0_80_Range(obj)
            a_0_80_Range=obj.a_0_80_GO-obj.a_0_80_GU;
        end
    end
end