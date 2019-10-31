% Neues Kennfeld laden

% ip.zgs=1./((ip.zgs./1000)*(47215/3600)); %CNG: 47215 statt 50000
% ip.zgs=ip.zgs./100;

% ip.zgs=ip.zgs.';
% ip.zgs(isnan(ip.zgs)) = 0;
% ip.bsfc.be=ip.zgs;
% ip.bsfc.trqorig=(ip.ygs(1,:)).';
% ip.bsfc.speed=ip.xgs(:,1);
% ip.bsfc.speed=ip.bsfc.speed.';
% for i=1:200
%     [ip.bsfc.be_min,max_eta(i)]=max(ip.bsfc.be(:,i));
%     ip.bsfc.M_be_min_orig(i)=ip.bsfc.trqorig(max_eta(i));
% end
% clear i;
% clear max_eta;
% bsfc=ip.bsfc;
% clear ip;

% Neues Kennfeld nochmal laden

ip.ygs(isnan(ip.zgs)) = 0;
for i=1:200
full_load.trqorig(i)=max(ip.ygs(i,:));
end
clear i;
full_load.speed=bsfc.speed;
clear ip;
engine.bsfc=bsfc;
engine.full_load=full_load;
clear engine.bsfc.be_min bsfc full_load;