function [t_0_80] = Acceleration_readout(VSim)
% Designed by FTM, Technical University of Munich
%-------------
% Created on:  01.11.2018
% Modified on: 21.11.2018
% ------------
% Version: Matlab2017b
%-------------
% This function calculates the time it takes for the vehicle to accelerate
% from standstil to 80 km/h, and from 60 to 80 km/h
% ------------
% Input:    - VSim:    struct array that contains the outputs or the results
%                      from the consumption simulation such as electricity
%                      and fuel consumption
% ------------
% Output:   - t_0_80:  a scalar number where the acceleration time is stored
% ------------
    % If the consumption simulation is performed
    if (VSim.bDiesel ~= 0 || VSim.bGas ~= 0 || VSim.energyTotal ~= 0 || VSim.Hydrogen_consumption ~= 0)
            v80_1=0;
            for i=1:length(VSim.v_t)
                if VSim.v_t(i)==0
                    v0=i;
                elseif VSim.v_t(i)<=60
                    v60=i;
                elseif VSim.v_t(i)<=80
                    v80=i;
                elseif VSim.v_t(i)>80
                    v80_1=1;
                    break
                end
            end

            %lin_int1=(VSim.v_t(v60+1)-60);
            %lin_int2=(VSim.v_t(v60+1)-VSim.v_t(v60));
            %t_0_60=(v60-v0)+((lin_int2-lin_int1)/(lin_int2));
            if v80_1==0
                t_0_80=inf;
                t_0_80;
            else    
                lin_int1=(VSim.v_t(v80+1)-80);
                lin_int2=(VSim.v_t(v80+1)-VSim.v_t(v80));
                t_0_80=(v80-v0)+((lin_int2-lin_int1)/(lin_int2));
                %t_60_80=t0_80-t0_60;
                t_0_80;
            end
    else
        t_0_80=inf;
    end
end