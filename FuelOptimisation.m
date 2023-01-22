function [Fueltype, vehicle_param, ifElectric, Vehicle] = FuelOptimisation(ifOptimized, vehicleType)


%%  Fuel type - define used Fuel type  

if ifOptimized == false
    
%     Fueltype = 1;     % Diesel
%     Fueltype = 2;     % CNG
%     Fueltype = 3;     % LNG
%     Fueltype = 4;     % Diesel Hybrid
%     Fueltype = 5;     % CNG Hybrid
%     Fueltype = 6;     % LNG Hybrid
%     Fueltype = 7;     % Electric
%     Fueltype = 8;     % Diesel & CNG
%     Fueltype = 9;     % Diesel & LNG    
%     Fueltype = 10;    % Diesel & CNG Hybrid
%     Fueltype = 11;    % Diesel & LNG Hybrid
%     Fueltype = 12;    % Electric w/WPT
%     Fueltype = 13;    % Hydrogen fuel cell
end

if ifOptimized
    % Different drivetrains, numbered from 1 to 16
    fprintf('Running optimized values.\n');
%     x.Diesel             = [0 1 15.86000 7 0 0 2.846000 2100 1000 1200];
%     x.DieselHybrid       = [0 4 10.520605460 6 0 0 2.8441717180 1909.5221960 1000 1250 10 66 16 11 678.47390480 1329.6630290 28.044216340 0 0.12956916500 32.474264820 406.36894840 500 0.023589275000 1000 78.461491790 0.20089233000 0.31350623800 2 1];
%     x.DieselWPT          = [0 4 21.0263405482621 8 0 0 2.75079801131642 1533.73369447105 1001.00956566108 1251.13760132476 9.98720680383947 50 18 34 1943.81328931452 1461.85060573265 77.9601927252744 0 0 30 372.237044691592 425.294982954638 0.0316723286194047 1000 69.4576203674285 0.346534291947138 0.686709186162780 2 1 0.0415562422930985 1];
%     x.LNG                = [0 3 13.800882220 6 0 0 2.90 1878.8055380 1200 1304.0170190 6.7149625750 70 22 22];
%     x.LNGHybrid          = [0 6 13.774204910 6 0 0 2.7224560210 1863.8839330 1121.4255780 1381.7616290 9.5093264750 62 24 25 1046.7633910 1104.4388630 17 0 0.50467893100 50.895326510 184.81336470 222.50330520 0.025920146000 6193.6814600 67.285637680 0.40768474200 0.22987773600 2 1];
%     x.CNG                = [0 2 14.13997046 6 0 0 2.888423077 1884.979771 1162.158336 1328.527388 6.680368096 53 21 29];
%     x.CNGHybrid          = [0 5 12.390985310 6 0 0 2.8353013110 1775.1813810 1097.5696080 1395.8710770 10 52 23 24 797.41555600 1500 22.32500 0.14335653600 0.24601746300 47.579877220 354.94236770 170.59968710 0.030822649000 2508.8086190 28.646700290 0.21682574100 0.26175081800 2 1];
%     x.LNGDiesel          = [0 9 10.019228510 5 0 0 2.8396232890 2022.7543360 1022.6905600 1254.1651330 6.6841801480 12 29 33];
%     x.LNGDieselHybrid    = [0 11 17.079364870 6 0 0 2.8606694640 1810.3914520 1020.2473540 1265.1440220 9.9764551570 83 4 20 658.10577830 1499.8555710 30.523987230 0 0.089152566000 33.216997240 434.94963420 500 0.030662181000 4273.3533630 39.050502600 0.26290110400 0.30288959200 2 1];
%     x.CNGDiesel          = [0 8 10.019228510 5 0 0 2.8396232890 2022.7543360 1022.6905600 1254.1651330 6.6841801480 12 29 33];
%     x.CNGDieselHybrid    = [0 10 17.079364870 6 0 0 2.8606694640 1810.3914520 1020.2473540 1265.1440220 9.9764551570 83 4 20 658.10577830 1499.8555710 30.523987230 0 0.089152566000 33.216997240 434.94963420 500 0.030662181000 4273.3533630 39.050502600 0.26290110400 0.30288959200 2 1];
%     x.BEV                = [1 7 1563 13 1 1166 10.0500050681571 4.34242437682060 3 1 0 978 1339 2 2];
%     x.BEV_Tesla          = [1 7 430*4 34 1 1000000/800 1 10 1 0 0 850 1421 1 2];
%     x.BEV_WPT            = [1 12 1563 13 1 400 10.0500050681571 4.34242437682060 3 1 0 978 1339 2 2 0.8 0.3];
%     x.BEV_OC             = [1 12 1563 13 1 400 10.0500050681571 4.34242437682060 3 1 0 978 1339 2 2 0.95 0.3];
%     x.FCEV               = [1 13 1563 13 1 400 10.0500050681571 4.34242437682060 3 1 0 978 1339 2 2];

    %% JCP Eco-Efficiency Paper
    % use y.Name for Paper
    % Reference vehicle
    y.Reference             = [0 1 15.86000 7 0 0 2.846000 2100 1000 1200];
    % Optimization results
    y.Diesel                = [0 1 17.7811 5.0000 0 0 2.5938 2071.7600 1011.3400 1252.4824 9.7827 24.0000 14.0000 20.0000];
    y.HEV                   = [0 4 10.0000 4.0000 0 0 2.5572 2126.0100 1002.2300 1293.3000 10.0000 63.0000 31.0000 17.0000 500.0000 1.0000 34.3184 0.4666 0.9728 67.0000 0.0057 40.0973 493.3420 0.0375 4200.6200 69.9588 0.2239 0.9999 2.0000 1.0000];
    y.BEV                   = [1 7 706.0000 39.0000 0.9291 722.0000 1.3136 10.0099 1.0000 0 0 2.0000 2.0000];
    y.FCEV                  = [1 13 652.0000 1.0000 0.4277 63.0000 4.0000 29.2671 1.0000 0 0 2.0000 2.0000 267.0000];
    y.HICE                  = [0 14 17.2961 5.0000 0 0 5.1311 801.5990 2001.6193 2503.1405 7.7281 43.0000 32.0000 9.0000];
    y.FCEV2                  = [1 13 17.2961 5.0000 0 0 5.1311 801.5990 2001.6193 2503.1405 7.7281 43.0000 32.0000 9.0000];




list = fieldnames(y);
%     Choose drivetrain type in input dialog box
%
%    Change:
%    Dropdown List for choosing the drivetrain (changed by MSe 20.01.2020)
%
    [indx,~] = listdlg('PromptString',{'Select a drivetrain.'...
        'Only one drivetrain can be select at a time.',''},...
        'SelectionMode','single', 'ListString',list);
     
    Vehicle = list{indx};
    
%    DrvTrn = Drivetrains(list);
%    Vehicle = DrvTrn{1};
 
%   Change End

%     Choose drivetrain type manually
%     DrvTrn = 12;
%     Vehicle = list{DrvTrn};
    
    ifElectric = y.(Vehicle)(1);
    
    Fueltype = y.(Vehicle)(2);
    
    vehicle_param = y.(Vehicle)(3:end);

%     Create the parameters and Param array

else 
    fprintf('Manual data entry.\n');
    Vehicle = 'empty';
    
    vehicle_param = 1;
    
    ifElectric = 1;

end

end