%%%
%%% Passive Solar House Model
%%%

C = Constants;
C = C.init;

[t, T] = run(C, 10);

t_hours  = t/3600;
plot(t_hours, T, '--', 'DisplayName', 'Variable Outside Temperature')
title('Passive Solar House Variable Outside Temp')
xlabel('Time (hours)')
ylabel('Temperature (C)')

function [t, T] = run(C, days)
    tspan = [0, days*86400];
    R_tot = helper.total_resistance(C.h_indoor, C.h_outdoor, C.h_window, C.area_tile,...
        C.area_walls, C.area_window, C.thickness_window, C.thickness_wall, C.k_fiberglass, C.k_glass);
    [t, T] = helper.solve_ode(tspan, C.T_0, C.area_window, R_tot, C.mass_tile, C.C_tile);
end
%{
[t1, T1] = ode45(@(t,T) (helper.solar_flux(t, area_window)-((T-T_outdoor)/R_tot))*(1/(mass_tile*C_tile)), tspan, T_0);

t_hours1 = t1/3600;
figure()
hold on
plot(t_hours1, T1, '-', 'DisplayName', 'Constant Outside Temperature')
title('Passive Solar House Temp Variable Temp outside')
xlabel('Time (hours)')
ylabel('Temperature (C)')
legend()

%%%
%%% Sweep Insulation Thickness
%%%

days = 10;
tspan = [0, days*86400];
insulation_sweep = linspace(0.01, 0.03, 5);
figure();
insulation_sweep(1)
hold on
for i = 1:length(insulation_sweep)
    R_tot = helper.total_resistance(h_indoor, h_outdoor, h_window, area_tile, area_walls, area_window, thickness_window, insulation_sweep(i), k_fiberglass, k_glass);
    [t, T] = ode45(@(t,T) (helper.solar_flux(t, area_window)-((T-T_outdoor)/R_tot))*(1/(mass_tile*C_tile)), tspan, T_0);
    plot(t, T, '-', 'DisplayName', 'Thickness: ' + string(insulation_sweep(i)))
end
hold off
legend()

%%%
%%% Sweep Tile Thickness
%%%

days = 40;
tspan = [0, days*86400];
tile_sweep = linspace(0.4, 0.6, 5); % m
figure();
hold on
for i = 1:length(tile_sweep)
    R_tot = helper.total_resistance(h_indoor, h_outdoor, h_window, area_tile, area_walls, area_window, thickness_window, insulation_sweep(i), k_fiberglass, k_glass);
    volume_tile = area_tile * tile_sweep(i); % m^3
    mass_tile = volume_tile * density_tile; % kg
    [t, T] = ode45(@(t,T) (helper.solar_flux(t, area_window)-((T-T_outdoor)/R_tot))*(1/(mass_tile*C_tile)), tspan, T_0);
    plot(t, T, '-', 'DisplayName', 'Thickness: ' + string(tile_sweep(i)))
end
hold off
legend()

%}
