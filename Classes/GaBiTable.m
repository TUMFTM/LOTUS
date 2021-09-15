classdef GaBiTable < handle
    %UNTITLED Summary of this class goes here
    %   Class which contains all needed data for the calculation.
    %   Data is read from Excelfiles. These files need to be name in such a
    %   way that it is possible to read them in an interative loop.
    %   e.g.: [Name of the Drivetrain][Name of the component][scaleing
    %   factor].xlsx.
    %   It need to be determined, if the Tables should contain the data for
    %   the GaBi components or the whole footprint analysis.
    %   It remains to be shown, if the scaling of the table values is
    %   applicable for every component. However if drivetrains with
    %   slightly different properties such as BatterySize come into play, a
    %   componente-based evaluation might be the better way to go.
    
    %   Another question is which GaBi output should be used as the
    %   properties differ in their quality and quantity. This assumption
    %   has an influence on the properties contained in this class.
    
    % Update 09.04.2020:
    % This class contains all environmental impacts for one Component
    % (specified in the property ComponentType) of one Vehicle (specified
    % in the property VehicleType).
    % Both of these values build the ID for the object. 
    % It remains to be seen if a numeric ID will be necessary for the
    % optimization where multiple vehicles will be compared.
    
    
    properties
        Name        % contains information to distinguish between the created tables
                    % name is structured like this:
                    % [ComponentType][VehicleType]
        Path        % returns the path the file is saved in
        % the following properties mailny depend on the used GaBi
        % Output-Scheme mentioned above
        
        File        % Alternative for lastfile search, the file will be passed directly
        
        ComponentType      % contains information to allocate the object to an component
        
        ScalingFactor     % contains information about the weight used in GaBi to model this component
                            % This value is the scaling by mass. This means the values read in into the GaBi Objects are scaled down to x/1kg. 
                            % In order to scale up to the weights used in
                            % Matlab forthe simulation the corresponding
                            % values need to be linked to the created GaBiTables
        VehicleType     % contains information to allocate the object to an vehicle type
        
        
        %following emmision properties are relateted to the recommended
        %LCIA Methods JRC/ILCD version 2011 (without land use) midpoint
        
        %global warming potential excluding biogenic carbon in co2-eq.
        GWP
        
        % acidification potential in mole of H+-eq.
        AP
        
        %Ecotoxicity freshwater midpoint in CTUe
        EcoToxFW
        
        %Eutrophication freshwater midpoint
        EutrophFW
        
        %Eutrophication marine midpoint
        EutrophMar
        
        %Eutrophication terrestrial midpoint
        EutrophTerr
        
        %Combined Eutrophication midpoint
        %EutrophComb
        
        %Human Tox cancer
        HumToxCan
        
        %Human Tox non-cancer
        HumToxNonCan
        
        %Ionizing radiation in kBq U235 eq
        IonRad
        
        %Ozone depletion in kg CFC-11-eq.
        OzDep
        
        %Particular matter in kg PM2,5-eq.
        PartMat
        
        %Photochemical ozone formation potential in kg NMCOV
        PhotoOz
        
        %Resource depletion water m�-eq.
        ResWater
        
        %Resource depletion mineral, fossil and renewable in kg Sb-eq.
        ResMinFosRen
        
        %Resource depletion fossil, non-renewable
        ResFosNonRen
        
        % More (meta-)properties could be
        % Size
        % Date_of_creation
        % ...
    end
    
    methods
        %constructor detailed
        function obj = GaBiTable(varargin)
            if nargin == 6
                
                obj.File = varargin{6};
                % varargin 4 and 5 not used anymore, in code pass ~ for it
                % obj.Path =
                % ('/Eco-Efficiency-HDVSim\GaBiTables\'+string(latestfile));
                %  not used anymore
                obj.ComponentType = varargin {1};
                obj.VehicleType = varargin{2};
                obj.ScalingFactor = varargin{3};
            elseif nargin == 5 % for usephase and recycling
                
                
                if varargin{5} == 0
                    dirc=dir('GaBiTables/Use*.mat'); % looks for UsePhase tables
                    [~,I] = max([dirc(:).datenum]);
                    if ~isempty(I)
                        latestfile = 'UsePhaseTable20200428.mat';%dirc(I).name;
                    end
                elseif varargin{5} == 1
                    dirc=dir('GaBiTables/Recycling*.mat'); % looks for Recycling tables
                    [~,I] = max([dirc(:).datenum]);
                    if ~isempty(I)
                        latestfile = dirc(I).name;
                    end
                end
                
                obj.Path = ('GaBiTables/'+string(latestfile));
                obj.ComponentType = varargin{1};
                obj.VehicleType = varargin{2};
                obj.ScalingFactor = varargin{3};
            elseif nargin==4
                obj.Path = varargin{1};
                obj.ComponentType = varargin{2};
                obj.VehicleType = varargin{3};
                obj.ScalingFactor = varargin{4};
            elseif nargin == 3
                dirc = dir('GaBiTables/Assembly*.mat');
                [~,I] = max([dirc(:).datenum]);
                if ~isempty(I)
                    latestfile = 'AssemblyTable20200417.mat';%dirc(I).name;
                end
                obj.Path = ('GaBiTables/'+string(latestfile));
                obj.ComponentType = varargin{1};
                obj.VehicleType = varargin{2};
                obj.ScalingFactor = varargin{3};
            else
                %This snippet will look through the folder and select the
                %latest file automatically
                dirc=dir('GaBiTables/Assembly*.mat');
                [~,I] = max([dirc(:).datenum]);
                if ~isempty(I)
                    latestfile = 'AssemblyTable20200417.mat';%dirc(I).name;
                end
                obj.Path = ('GaBiTables/'+string(latestfile));
                
                obj.ComponentType = varargin{1};
                obj.VehicleType = varargin{2};
                obj.ScalingFactor = 0;

            end
            
            setProperties(obj);
                        
        end
        
        
        %get path
        function p = getPath(obj)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            p = obj.Path;
        end
        
        %function T_buff = get_T_buff(obj)
        %    T_buff = load(string(obj.Name)+'.mat');
        %end
        function VType = getVehicleType(obj)
            VType = obj.VehicleType;
        end
        
        function CType = getComponentType(obj)
            CType = obj.ComponentType;
        end
        
        
        
        function obj = setProperties(obj)
            name_string = extractAfter(string(obj.Path),'GaBiTables/');
            obj.Name = (name_string(1:end-4));
            
            
            
            vehicle = string(obj.VehicleType);
            component = string(obj.ComponentType);
            
            if isempty(obj.File)
            load('GaBiTables/'+name_string,vehicle);
            else
                % extract the proper part of the struct into the workspace
                load(obj.File,vehicle);
                
            end
            
            switch vehicle
                case "EV"
                    tmp = EV;
                case "ICE"
                    tmp = ICE;
                case "HEV"
                    tmp = HEV;
                case "FCEV"
                    tmp = FCEV;
                case "HICE"
                    tmp = HICE;
                case "Diesel"
                    tmp = Diesel;
                case "Coolant"
                    tmp = Coolant;
                case "MotorOil"
                    tmp = MotorOil;
                case "Electricity"
                    tmp = Electricity;
                case "Hydrogen"
                    tmp = Hydrogen;
                case "Steel"
                    tmp = Steel;
                case "Aluminium"
                    tmp = Aluminium;
                case "Copper"
                    tmp = Copper;
                case "Duroplast"
                    tmp = Duroplast;
                case "Thermoplast"
                    tmp = Thermoplast;
                case "Ceramic"
                    tmp = Ceramic;
                case "Glass"
                    tmp = Glass;
                case "Oil"
                    tmp = Oil;
                case "LiIonBattery"
                    tmp = LiIonBattery;
                case "LeadAcidBattery"
                    tmp = LeadAcidBattery;
                case "Paint"
                    tmp = Paint;
                case "Rubber"
                    tmp = Rubber;
                case "Wood"
                    tmp = Wood;
                case "ElectricalScrap"
                    tmp = ElectricalScrap;
                case "Organic"
                    tmp = Organic;
            end
            
            
            obj.AP                              = tmp{component,3} * obj.ScalingFactor;
            obj.GWP                             = tmp{component,4} * obj.ScalingFactor;
            obj.EcoToxFW                        = tmp{component,6} * obj.ScalingFactor;
            obj.EutrophFW                       = tmp{component,7} * obj.ScalingFactor;
            obj.EutrophMar                      = tmp{component,8} * obj.ScalingFactor;
            obj.EutrophTerr                     = tmp{component,9} * obj.ScalingFactor;
            %obj.EutrophComb                     = 0;    %= tmp{component,9} * obj.ScalingFactor;
            % problem solving attempt: eutroph comb does not exist
            % changes in numbering up from 6 to 9
            obj.HumToxCan                       = tmp{component,10} * obj.ScalingFactor;
            obj.HumToxNonCan                    = tmp{component,11} * obj.ScalingFactor;
            obj.IonRad                          = tmp{component,12} * obj.ScalingFactor;
            obj.OzDep                           = tmp{component,13} * obj.ScalingFactor;
            obj.PartMat                         = tmp{component,14} * obj.ScalingFactor;
            obj.PhotoOz                         = tmp{component,15} * obj.ScalingFactor;
            obj.ResWater                        = tmp{component,16} * obj.ScalingFactor;
            obj.ResMinFosRen                    = tmp{component,17} * obj.ScalingFactor;
            obj.ResFosNonRen                    = tmp{component,18} * obj.ScalingFactor;
            
            
            
            
        end
        
                
        function obj = delete(obj)
            
            % function will not be used to this state of progress but will
            % be implemented for the sake of completeness
            clear obj;
        end
    
    end
end

