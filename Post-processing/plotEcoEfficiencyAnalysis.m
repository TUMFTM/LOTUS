function [] = plotEcoEfficiencyAnalysis(Eco_Efficiency,Param, isMultiple)
%PLOTECOEFFICIENCYANALYSIS Summary of this function goes here
% This function plots the results of the eco-efficiency analysis.
%   Detailed explanation goes here
%   By changing the value isMultiple the plot will show the results of
%   multiple instead of one analysis. The values will be stored in either a
%   separated struct or somewhere else and be read in.

%   Another possibility would be to loop over alle the results afterwards
%   and plot them. This may be a solution to avoid keep hold on without
%   setting it off again.
%% Set up figure

%  look for active figure and close it to avoid spamming windows.
%close(findobj('type', 'figure', 'name', 'Eco Efficiency'));

name_str = 'Eco Efficiency';
figure('Name',name_str,'NumberTitle','off'); 
set(0,'DefaultAxesFontName','Times New Roman');
scatterColor = [0 0 0];
hold on;

%% Plot data
if ~isMultiple % only one solution
    
    % set axis
    
    % x: TCO
    x = Param.TCO.Total_costs/(Param.TCO.Annual_mileage(1)*(Param.vehicle.payload/100000));
    % y: Eco-Efficiency
    
    y = Eco_Efficiency.Eco_Impact;
    %y1 = Eco_Efficiency.Sum.Assembly.GWP;
     y1 = Eco_Efficiency.Sum.Impact_Assembly/(Param.TCO.Annual_mileage(1)*Param.TCO.Operating_life(1)*(Param.vehicle.payload/1000));
    %y2 = Eco_Efficiency.Sum.UsePhase.GWP;
     y2 = Eco_Efficiency.Sum.Impact_UsePhase/(Param.TCO.Annual_mileage(1)*Param.TCO.Operating_life(1)*(Param.vehicle.payload/1000));
    %y3 = Eco_Efficiency.Sum.Recycling.GWP;
     y3 = Eco_Efficiency.Sum.Impact_Recycling/(Param.TCO.Annual_mileage(1)*Param.TCO.Operating_life(1)*(Param.vehicle.payload/1000));
    
    switch Param.Vehicle
        case  {"BEV" , "BEV_Tesla"}
            scatterColor = [1 1 0];
            
        case "Diesel"
            scatterColor = [1 0 0];
            
        case "DieselHybrid"
            scatterColor = [0 1 0];
            
        case "FCEV"
            scatterColor = [0 0 1];
    end
    
    scatter(x,y,[],...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor' ,scatterColor,...
        'LineWidth', 0.75,...
        'tag',sprintf('Total: VehicleType: %s',Param.Vehicle));
    
    scatter(x,y1,[],...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor' ,scatterColor,...
        'LineWidth', 0.75,...
        'tag',sprintf('Assembly: VehicleType: %s',Param.Vehicle));
    
    scatter(x,y2,[],...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor' ,scatterColor,...
        'LineWidth', 0.75,...
        'tag',sprintf('UsePhase: VehicleType: %s',Param.Vehicle));
    
    scatter(x,y3,[],...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor' ,scatterColor,...
        'LineWidth', 0.75,...
        'tag',sprintf('Recycling: VehicleType: %s',Param.Vehicle));
    
    datacursormode on
    dcm = datacursormode(gcf);
    set(dcm,'UpdateFcn',@myupdatefcn)
    
    title ('Eco Efficiency');
    xlabel  ('Total Cost of Ownership [€/tkm]')
    %axis ([0 500000 -2e-6 3e-6]);
    axis ([0 15 y3*2 y*2]);
    ylabel  ('Environmental Impact')
else
    %multiple solution
end


%hold off;
end



function txt = myupdatefcn(~,event)
    pos = get(event,'Position');
    dts = get(event.Target,'Tag');
    txt = {dts,...
           ['TCO [€]: ',num2str(pos(1))],...
         ['Eco-Impact: ',num2str(pos(2))]};
end


