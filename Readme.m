%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                            %
%                                            %
%                 Changelog                  %
%               by Bert haj Ali              %
%                                            %
%                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Added LNGDiesel & LNGDieselHybrid to the "x" matrix

% In the "x" matrix, the first constant has been changed to refer to
% whether the vehicle is electric or not. 1 for pure electric & 0 is for
% combustion vehicle

% The Fahrzeuge_Iteration & Stand_alone_Verbrauchssimulation scripts have
% been combined into one script called "Main_file.m". To choose between
% either, a new variable "ifOptimized" has been introduced. Manually assign
% 1 or 0 depending whether optimized or manual values need to be run
% respectively.

% The funtions VSim_parametrieren(), VSim_parametrieren_optimiert(), and
% VSim_parametrieren_optimiert_hybrid() have been combined into one
% function called Parameterizing(). The functionalities are chosen based on
% the values of the variables ifElectric & ifOptmized as mention above. 

% In Parameterizing(), the parametrizing of the vehicles parameters such as
% transmission, battery, electric motor and so on have been moved to
% seperate functions that will only be called according to the fuel type
% used. This simplifies the code and shortens the execution time. For
% example, all transmission-related parameters are now executed in the
% function Transmission_design() found in Parameterizing(). Similarly goes
% for electric motor and wireless power transfer.

% The user can still manually input data in the function Parameterizing().
% However, they will only be executed if "ifOptimized" = 0"

% Constant paremeters & ambient parameters have been moved to the top of
% the function Parameterizing() for easy code analysis.

% In electric machine mapping, the parameters such as speed and power are
% no longer calculated there. Instead they are calculated in
% Electric_drivetrain() and Hybrid_operating_strategy() functions and are
% just passed along in Electric_machine_mapping().

% The flags Hybrid_LKW & Elektro_LKW are now assigned in
% Electric_machine_mapping() instead of in VSim_parametrieren...()functions

% In weight calculations, the calculation of the fuel system weight have
% been also moved to seperate functions called Tank_sizes() and
% Fuel_tank_weights().

% In postprocessing, the output in the command window has been cleaned up
% with more relevant information being shown. Also, some useful comments
% appear now as well.

% Figrues and results popping up and appearing in the command window now
% can be easily toggled from Main_file/m through the variables
% Param.VSim.Display & Param.VSim.Opt

% In terms of cleaning up the code, redundant "if loops", "switch cases",
% and variable assignments have benn eliminated to make reading the code
% easier. In addition, the logic of the code has been improved to enhance
% readability. Also, the code now appear more structured and organized
% which helps the used to navigate through the code.

% The simulink models have been cleaned up. Over lapping wires have been
% replaced with "Goto" & "From" blocks. Regions of different colour have
% been added to group one process or group blocks that are responsible for
% a single operation. 

% The blocks have been coloured in FTM style. Similar blocks or blocks of
% the same type now have the same background colour. This enables the user
% to easily identify each block. In addition, the block names and their
% variables have been added/translated to English. The script or piece of
% code that does this is in the "SimulinkHelperFTM" folder. For colouring,
% the provided script "SimulinkHelperFTM.M" have been used with some
% modifications to allow for more blocks and colors. For renaming, the
% script used is called "Renaming.m"

% Most of the functions names have benn translated to English. As well as
% all the explainatory comments and some variable names. 

% VSim_parametrieren_optimiert_hybrid() is now called
% VSim_parameterizing_optimized(). It is now not in use.

% VSim_parameterizing_optimized() is now called
% VSim_parameterizing_optimized_old(). It is now not in use.

% VSim_parametrieren() is now called VSim_parameterizing(). It is also not
% in use.

% The above 3 functions have been replaced with Parameterizing()

% The function transmission_function() is now called Transmission_gearing()
% and it is called inside a new function named Transmission_design().

% Kennfelderstellung_EM() is now called Electric_machine_mapping().
% Similarly, Kennfelderstellung_Diesel() is called Diesel_engine_mapping().
% Also, Kennfelderstellung_Gas_Tschochner() is called Gas_engine_mapping()
% and Kennfelderstellung_Dual_Tschochner() is called
% Dual_fuel_engine_mapping().

% FuelCell_Auslegung() is now called FuelCell_design().

% Gewichtsberechnung() is now called Wights_calculation().

% Param.VSim.Gasart is now Param.Engine.Gasart. It is also now assigned in
% Gas_engine_mapping() and Dual_fuel_engine_mapping().

% Fahrzyklus_laden() is now called Driving_cycle_loading(). 

% VSim_ausfuehren() is now called Vsim_run().

% VSim_auswerten() is now called VSim_evaluation().

% Beschleunigung_auslesen() and Elastizitaet_auslesen() have benn replaced
% with Acceleration_readout() and Acceleration() respectively.

% The function transmission_prop() is now called Transmission_properties().
% Also, getriebe_auswertung() is now called Transmission_evaluation(). In
% addition, Herstellkosten_Balkendiagramm() is called Production_costs()
% and Gewichtsanteile_Balkendiagramm() is called Components_weights().

% Param.VSim.Anzeige is now called Param.Vsim.Display and can be found in
% Main_file.m

% The variable Ergebnis is now called Results.

% In simulink, the block names have been changed to English and the
% simulation afterwards works fine. However, trying to change the variable
% names was partially successful; some errors remain.

% The folder called "Truck Simulation" contains the completed work with all
% the previous comments left. The simulink models have English names only
% for the block names.

% The folder called "Truck Simulation-English" contains the completed work
% with all redundant comments removed. Some variables were translated to
% English, and some variables names in simulink models were also translated
% to English. However, some errors remain.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                            %
%                                            %
%                 What's left                %
%                                            %
%                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Stateflow variables has to be changed from German to English.
% Making sure all variables that are passed to simulink are in English.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                            %
%                                            %
%              Steps for running             %
%               the simulation               %
%                                            %
%                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1-Open the script called Main_file.m; most of the simulation parameters
%   and properties can be accessed there.

% 2-Choose whether the values after the optimization or custome values to
%   be run. This is controlled by the flag "ifOptimized".

% 3-If optimized values are chosen, assign 1 to ifOptimized and choose
%   which vehicle is needed to run by assigning a number from 1 to 16 to
%   the variable "DrvTrn".

% 4-If custom values are needed, assign 0 to ifOptimized. Then choose the
%   type of fuel to run by uncommenting the required line in "Fuel type"
%   block. After that, assign the custom values to the parameters found in
%   Parameterizing().

% 5-Choose which driving cycle is needed by uncommenting the required line 
%   in the "Driving cylce" block.

% 6-Some simulation properties regarding the results can be adjusted. If
%   displaying figures is required, assign 2 to Param.VSim.Display;
%   otherwise leave it as 3. If output results in te command window is not
%   needed, then assign "True" to the variable Param.VSim.Opt; otherwise
%   leave it as "False". This is found in "Simulation properties" block.

% 7-When everything is set up, click on run. The steps will be shown in the
%   command window, and a notification will indicate whether the simulation
%   was successful or not. In the case of success, the results will be save
%   in the folder "Results".