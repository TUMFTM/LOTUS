%% Load Vehicle Concepts
results.reference = load('Post-processing/JCP_EE/Results/20210419_Reference.mat');
results.diesel    = load('Post-processing/JCP_EE/Results/20210507_Diesel.mat');
results.hev       = load('Post-processing/JCP_EE/Results/20210507_HEV.mat');
results.bev       = load('Post-processing/JCP_EE/Results/20210507_BEV.mat');
results.bev2      = load('Post-processing/JCP_EE/Results/20230122_BEV.mat');
results.fcev      = load('Post-processing/JCP_EE/Results/20210507_FCEV.mat');
results.hice      = load('Post-processing/JCP_EE/Results/20210507_HICE.mat');
%%

vehicle_names = fieldnames(results);
component_names_1 = fieldnames(results.reference.Eco_Efficiency.GaBiTables);
component_names_2 = fieldnames(results.bev2.Eco_Efficiency.GaBiTables);
component_names = unique([component_names_1;component_names_2]);

impact_categories = fieldnames(results.reference.Eco_Efficiency.GaBiTables.gtCabin);

data_out = array2table(zeros(0,4));
data_out.Properties.VariableNames = {'Vehicle', 'Component', 'Impact', 'Value'};

for i1 = 1:length(vehicle_names)
    for i2 = 3:length(component_names)
        for j = 7:length(impact_categories)
            if isfield(results.(vehicle_names{i1}).Eco_Efficiency.GaBiTables, component_names{i2})
                tmp = {vehicle_names{i1}, component_names{i2}, impact_categories{j}, results.(vehicle_names{i1}).Eco_Efficiency.GaBiTables.(component_names{i2}).(impact_categories{j})};
            else
                tmp = {vehicle_names{i1}, component_names{i2}, impact_categories{j}, 0};
            end
            data_out = [data_out; tmp];
        end
    end
end

%%
writetable(data_out, '/Users/sebastianwolff/Documents/disswolff/02_Daten/OptiResults/resultsComponents.csv')

