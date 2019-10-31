function [t_60_80] = Acceleration(VSim)

    % If the consumption simulation is performed
    if (VSim.bDiesel ~= 0 || VSim.bGas ~= 0 || VSim.energyTotal ~= 0)
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
                t_60_80=inf;
                t_60_80;
            else    
                lin_int1=(VSim.v_t(v80+1)-80);
                lin_int2=(VSim.v_t(v80+1)-VSim.v_t(v80));
                t_60_80=(v80-v60)+((lin_int2-lin_int1)/(lin_int2));
                %t_60_80=t0_80-t0_60;
                t_60_80;
            end
    else
        t_60_80=inf;
    end
end