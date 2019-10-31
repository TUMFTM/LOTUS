function [ Results ] = VSim_run(Param)
% Designed by FTM, Technical University of Munich
%-------------
% Created on: 01.11.2018
% ------------
% Version: Matlab2017b
%-------------
% This function loads the respective simulink model of the consumption
% simulaton. Assigns the variables to the modelworkspace, starts the
% simulation and returns the results in the 'Results' array
% Bert Haj Ali
% ------------
% Input:    - Param:   struct array containing all simulation parameters
% ------------
% Output:   - Results: struct array containing the raw outputs of the
%             consumption simulation
% ------------
% Creates temporary folders
if Param.VSim.Opt == true
    cwd = pwd;
    addpath(cwd)
    tmpdir = tempname;
    mkdir(tmpdir)
    cd(tmpdir)
end

% Loads the Simulink model
load_system(Param.name);

% If necessary, open the Simulink model, if desired by the user
if Param.VSim.Display >= 2 && Param.VSim.Opt == 0 && Param.dcycle ~= 5
    open_system(Param.name);
end

% Assigns simulink model parameters
hws = get_param(Param.name, 'modelworkspace');

% Add to the model workspace
list = fieldnames(Param);
for  i = 1:numel(fieldnames(Param))
    %eval(list(i).name);
    %hws.assignin(list(i).name,eval(list(i).name));
    %Param.(list(i).name);
    hws.assignin(list{i},Param.(list{i}));
end

% Running the simulation
fprintf('Running the simulation.\n');
sim(Param.name);

list = whos;        % Existing variables
Results = struct;
for  i = 1:length(list)
    switch list(i).name
        case {'i', 'Param', 'list', 'hws'}
            
        otherwise
            Results.(list(i).name)= eval(list(i).name);
    end
end

% If necessary close Simulink model, if desired by user
if (Param.VSim.Display < 2)  ||  Param.VSim.Opt == 1
    bdclose(Param.name); % Delete without saving
end

% Delete temporary folder, multi-target optimization on multiple cores
if Param.VSim.Opt == true
    cd(cwd)
    evalin('base', 'clear mex');
    rmdir(tmpdir,'s')
    rmpath(cwd)
end

end