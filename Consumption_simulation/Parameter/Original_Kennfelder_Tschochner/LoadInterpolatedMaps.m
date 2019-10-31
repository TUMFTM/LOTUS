% M. Tschochner 2015-10-12

load('CNG_Engine_Truck_Michi_RawInterpolatedData.mat')
figure; grid on;
surf(ip.xgs, ip.ygs, ip.zgs);

load('LNG-CI_HPDI_Engine_Michi_RawInterpolatedData.mat')
figure; grid on;
surf(ip.xgs, ip.ygs, ip.zgs);


load('Mercedes-Benz_2L0_M274_DualFuel_Michi_Benzin_RawInterpolatedData.mat')
figure; grid on;
surf(ip.xgs, ip.ygs, ip.zgs);


load('Mercedes-Benz_2L0_M274_DualFuel_Michi_NG_RawInterpolatedData.mat')
figure; grid on;
surf(ip.xgs, ip.ygs, ip.zgs);

