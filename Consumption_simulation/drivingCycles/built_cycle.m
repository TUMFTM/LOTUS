cycle.stop_end = 5;
cycle.stop_start = 5;
cycle.speed_init = 0;

%% Altitude
for i=1:1:32000
    cycle.altitude(i) = 0;
end
%% distance
for i=1:1:32000
    cycle.distance(i) = i;
end

%% stop time
for i=1:1:32000
    cycle.stop_time(i) = 0;
end
%% 30 km/h keine Steigung
for i=1:1:4000
    cycle.speed(i) = 8.33;
end

for i=1:1:4000
    cycle.slope(i) = 0.00;
end

%% 30 km/h mit Steigung

for i=4001:1:8000
    cycle.speed(i) = 8.33;
end

for i=4001:1:8000
    cycle.slope(i) = 0.03;
end


%% 50 km/h ohne Steigung
for i=8001:1:12000
    cycle.speed(i) = 13.8;
end

for i=8001:1:12000
    cycle.slope(i) = 0.00;
end

%% 50 km/h mit Steigung
for i=12001:1:16000
    cycle.speed(i) = 13.8;
end

for i=12001:1:16000
    cycle.slope(i) = 0.03;
end

%% 60 km/h ohne Steigung
for i=16001:1:20000
    cycle.speed(i) = 18.05;
end

for i=16001:1:20000
    cycle.slope(i) = 0.00;
end

%% 60 km/h mit Steigung
for i=20001:1:24000
    cycle.speed(i) = 18.05;
end

for i=20001:1:24000
    cycle.slope(i) = 0.03;
end

%% 80 km/h ohne Steigung
for i=24001:1:28000
    cycle.speed(i) = 23.6;
end

for i=24001:1:28000
    cycle.slope(i) = 0.00;
end

%% 80 km/h mit Steigung
for i=28001:1:32000
    cycle.speed(i) = 23.6;
end

for i=28001:1:32000
    cycle.slope(i) = 0.03;
end

%%% Plot leistung

Engine1_Power = (Ergebnis.OUT_engine.signals(1).values).*(Ergebnis.OUT_engine.signals(2).values);
Engine1_Power = Engine1_Power.*((2*pi/60)*(1/1000));
plotyy(Ergebnis.OUT_engine.signals(8).values,Engine1_Power,Ergebnis.OUT_engine.signals(8).values,Ergebnis.OUT_engine.signals(4).values);

%plotyy(Ergebnis.OUT_engine.signals(8).values,Ergebnis.OUT_engine.signals(4).values,Ergebnis.OUT_engine.signals(8).values,Ergebnis.OUT_engine.signals(5).values)
%c=(2*pi.*Ergebnis.OUT_engine.signals(1).values.*(Ergebnis.OUT_engine.signals(2).values/.60))/.1000
%plotyy(Ergebnis.OUT_engine.signals(8).values,c,Ergebnis.OUT_engine.signals(8).values,Ergebnis.OUT_engine.signals(4).values);