%%%
%%% Passive Solar House Model
%%%

% Initialize constants 
C = Constants;
C = C.init;

%%%
%%% Run Model over time
%%%

hold on
%%%
%%% With 1 thermal mass
%%%
% [t, T] = run(C, 20, false);
% t_hours  = t/3600;
% plot(t_hours, T, '-', 'DisplayName', 'Temperature')
% title('Temperature of Passive Solar House with 1 thermal mass')
% xlabel('Time (hours)')
% ylabel('Temperature (C)')
% legend()


%%% 
%%% With 2 thermal masses
%%%
[t, T] = run2(C, 5);
t_hours  = t/3600;
plot(t_hours, T(:,1), '-', 'DisplayName', 'Tile Temperature')
plot(t_hours, T(:,2), '-', 'DisplayName', 'Air temperature')
yline(max(T(100:end,2)), 'r')
yline(min(T(100:end,2)), 'g')
title('Temperature of Passive Solar House with 2 thermal masses')
xlabel('Time (hours)')
ylabel('Temperature (C)')
legend()

%%%
%%% With 1 thermal mass and constant temp
%%%
%[t1, T1] = run(C, 20, true);
%t_hours1  = t1/3600;
%plot(t_hours1, T1, '-', 'DisplayName', 'Constant Outside Temperature')
% %yline(max(T(100:end,:)), 'g')
% yline(max(T), 'g')
% title('Temperature of Passive Solar House with Constant T')
% xlabel('Time (hours)')
% ylabel('Temperature (C)')
% legend()

hold off

%%%
%%% Run model over time while sweeping insulation thickness
%%%
%sweep_insulation(0.01, 0.03, 5, C, 20)

%%%
%%% Run model over time while sweeping tile thickness
%%%
%sweep_tile(0.3, 0.7, 5, C, 1)


%%%
%%% Run and sweep functions
%%%

% Calculates R_tot and solves ode
% Returns time t in seconds and temperature T in C
function [t, T] = run(C, days, constant_t)
    tspan = [0, days*86400];
    R_tot = helper.total_resistance(C.h_indoor, C.h_outdoor, C.h_window, C.area_tile,...
        C.area_walls, C.area_window, C.thickness_window, C.thickness_wall, C.k_fiberglass, C.k_glass);
    if constant_t
        [t, T] = helper.solve_ode_con(tspan, C.T_0, C.area_window, R_tot, C.mass_tile, C.C_tile);
    else
        [t, T] = helper.solve_ode(tspan, C.T_0, C.area_window, R_tot, C.mass_tile, C.C_tile);
    end
end

% Runs the model with two thermal masses
% Returns time t in seconds and temperature T in C
function [t, T] = run2(C, day)
    tspan = [0, day*86400];
    [t, T] = helper.solve_double_ode(tspan, C);
end

% Sweeps through insulation thickness values and solves ode
% Returns a plot of temperature over time for different thicknesses
function f = sweep_insulation(start, stop, step, C, days)
    insulation_sweep = linspace(start, stop, step);
    figure();
    hold on
    for i = 1:length(insulation_sweep)
        C.thickness_wall = insulation_sweep(i);
        C = C.init;
        [t, T] = run(C, days, false);
        t_days = t./86400;
        plot(t_days, T, '-', 'DisplayName', 'Thickness: ' + string(insulation_sweep(i)))
    end
    title('Inside Temperature of Passive Solar House with Varying Insulation Thickness')
    xlabel('Time (days)')
    ylabel('Temperature (C)')
    hold off
    legend()
end

% Sweeps through tile thickness values and solves ode
% Returns a plot of temperature over time for different thicknesses
function f = sweep_tile(start, stop, step, C, days)
    tile_sweep = linspace(start, stop, step);
    figure();
    hold on
    for i = 1:length(tile_sweep)
        C.thickness_tile = tile_sweep(i);
        C = C.init;
        [t, T] = run(C, days, false);
        t_days = t./86400;
        plot(t_days, T, '-', 'DisplayName', 'Thickness: ' + string(tile_sweep(i)))
    end
    title('Inside Temperature of Passive Solar House with Varying Tile Thickness')
    xlabel('Time (days)')
    ylabel('Temperature (C)')
    hold off
    legend()
end

