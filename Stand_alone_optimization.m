%% Stand_alone optimization
% Script for calling an optimization
%% Make preparations
delete(gcp('nocreate')) % delete parallel pool, if existing 
clc
clearvars
%profile on;
%% Add folder
% genpath used to add all subfolders 
addpath('Classes');
addpath('Functions');
addpath(genpath('Consumption_simulation'));
addpath(genpath('Optimization'));
addpath('TCO');


% Before optimization, check whether global parameters in
% VSim_parametrieren are correct!!!

%% Start optimization
Start_Mehrzielopti2015b
%Start_Mehrzielopti2015b_Paper2017
%Start_Mehrzielopti2015b_SMS_EMOA

%% Output
fprintf('Optimization finished.\n');

save(strcat(datestr(now, 'yyyy-mm-dd'), '_Optimierung_', sprintf('%i_%i', options.maxGen, options.popsize), '.mat'), 'Param', 'result')

%profile viewer;
%save output.mat;