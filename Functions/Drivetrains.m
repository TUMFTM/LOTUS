function DrvTrn = Drivetrains(list)
% Designed by Bert Haj Ali at FTM, Technical University of Munich
%-------------
% Created on: 07.12.2018
% ------------
% Version: Matlab2017b
%-------------
% This function adds an input diaglog box in which the type of the
% drivetrain can be written there and then taken up by the consumption
% simulation. Please note that the names have to be written exactly as they
% are written in the Fahrzeuge_Iteration.m file.
% ------------
% Input:    - list:   string array that contains the names of the different
%                     drivetrains. They come from the fieldnames of the "x"
%                     array from Fahrzeuge_Iteration.m file.
% ------------
% Output:   - DrvTrn: a string corresponding to the name of a specific
%                     drivetrain type.
% ------------
    i = true;
    while i == true
        prompt = {'Choose drivetrain type:'};
        title = 'Drivetrain selector';
        dims = [1 55];
        DrvTrn = inputdlg(prompt, title, dims);
        
        if ~ismember(DrvTrn{1}, list) 
            fprintf('Invalid option. Please select a valid drivetrain type from the options below: \n');
                for j = 1:length(list)
                    fprintf('%s \n', list{j});
                end
        else
            i = false;
            fprintf('%s is selected.\n', DrvTrn{1});
        end 
    end
    
end

