classdef WeightingTable < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %basics
        Name
        Path
        Source
        SourceID
        
        File
        % Values
        % These values may need to be corrected depending on different
        % sources naming different impactfactors
        GWP
        
        AP
        
        EcoToxFW
        
        EutrophFW
        
        EutrophMar
        
        EutrophTerr
        
        %EutrophComb
        
        HumToxCan
        
        HumToxNonCan
        
        IonRad
        
        OzDep
        
        PartMat
        
        PhotoOz
        
        ResWater
        
        ResMinFosRen
        
        ResFosNonRen
        
        LandUse
    end
    
    methods
        
        %constructor
        function obj = WeightingTable(varargin)
            list = {'Castellani et al. 2016 WFsA', 'Castellani et al. 2016 WFsB',...
                    'EDIP 2003 (Stranddorf et al., 2005)','Tuomisto et al. 2012',...
                    'Bj�rn & Hauschild European 2015','Bj�rn & Hauschild Global 2015',...
                    'Ponsioen & Goedkoop 2016','Hubbes et al. 2012','EFRecommendenWeightingFactors',...
                    'EFRecommendedWeightingFactorsWithoutLandUseAndCombinedResourceD','Castellani et al. 2016 WFsA EU Normalized', 'EFRecommendedWeightingFactorsWithoutLandUseAndResourceD'};
                if nargin == 0
                    dirc=dir('WeightingTable/*.mat');
                    [~,I] = max([dirc(:).datenum]);
                    if ~isempty(I)
                        latestfile = 'WeightingTable20200428.mat';%dirc(I).name;
                    end
                    obj.Path = ('WeightingTable/'+string(latestfile));
                    [indx,~] = listdlg('PromptString',{'Select a weighting set'},...
                        'SelectionMode','single','ListString',list);
                    obj.SourceID = indx;
                    obj.Source=string(list(indx));
                    
                elseif nargin == 1
                    if contains(string(varargin{1}),'C:\')
                        obj.Path = varargin{1};
                        [indx,~] = listdlg('PromptString',{'Select a weighting set'},...
                            'SelectionMode','single','ListString',list);
                        obj.Source=string(list(indx));
                        obj.SourceID = indx;
                    else
                        dirc=dir('WeightingTable/*.mat');
                        [~,I] = max([dirc(:).datenum]);
                        if ~isempty(I)
                            latestfile = 'WeightingTable20200428.mat';%dirc(I).name;
                        end
                        obj.Path = ('WeightingTable/'+string(latestfile));
                        obj.Source = string(list(varargin{1}));
                        obj.SourceID = varargin{1};
                    end
                    
                    
                    
                elseif nargin == 2
                    obj.SourceID = varargin{1};
                    obj.Source = string(list(varargin{1}));
                    obj.File = varargin{2};
                
                elseif nargin == 3
                    obj.Path = varargin{1};
                    obj.Source = string(list(varargin{2}));
                    obj.SourceID = varargin{2};
                    obj.File = varargin{3};
                end
            
            setProperties(obj);
        end
        
        function p = getPath(obj)
            p = obj.Path;
        end
        
        function s = getSource(obj)
            s = obj.Source;
        end
        
        function obj = setProperties(obj)
            obj.Name = extractAfter(obj.File,'WeightingTable\');

            load(obj.File);
            s = obj.SourceID+1;
            
            obj.GWP             =                 weightingdata{2,s};
            obj.AP              =                 weightingdata{3,s};
            obj.EcoToxFW        =                 weightingdata{4,s};
            obj.EutrophFW       =                 weightingdata{5,s};
            obj.EutrophMar      =                 weightingdata{6,s};
            obj.EutrophTerr     =                 weightingdata{7,s};
            %obj.EutrophComb     =                 sum(obj.EutrophFW+obj.EutrophMar+obj.EutrophTerr)/3; 
            obj.HumToxCan       =                 weightingdata{8,s};
            obj.HumToxNonCan    =                 weightingdata{9,s};
            obj.IonRad          =                 weightingdata{10,s};
            obj.OzDep           =                 weightingdata{11,s};
            obj.PartMat         =                 weightingdata{12,s};
            obj.PhotoOz         =                 weightingdata{13,s};
            obj.ResWater        =                 weightingdata{14,s};
            obj.ResMinFosRen    =                 weightingdata{15,s};
            obj.ResFosNonRen    =                 weightingdata{16,s};
            obj.LandUse         =                 weightingdata{17,s};
            
         
            
        end
        
        function [weighted_Impacts] = weight_impacts(GaBiTable,obj)
                    
        end
        
        
    end
end

