%%%
%%% Passive Solar House Model
%%%

% Initialize constants 
C = Constants;
C = C.init;

%%%
%%% Run Model over time
%%%
[t, T] = run(C, 10);
t_hours  = t/3600;
plot(t_hours, T, '--', 'DisplayName', 'Variable Outside Temperature')
title('Passive Solar House Variable Outside Temp')
xlabel('Time (hours)')
ylabel('Temperature (C)')

% Run model over time while sweeping insulation thickness
sweep_insulation(0.01, 0.03, 5, C, 10)

% Run model over time while sweeping tile thickness
sweep_tile(0.4, 0.6, 5, C, 20)


%%%
%%% Run and sweep functions
%%%


% Calculates R_tot and solves ode
% Returns time t in seconds and temperature T in C
function [t, T] = run(C, days)
    tspan = [0, days*86400];
    R_tot = helper.total_resistance(C.h_indoor, C.h_outdoor, C.h_window, C.area_tile,...
        C.area_walls, C.area_window, C.thickness_window, C.thickness_wall, C.k_fiberglass, C.k_glass);
    [t, T] = helper.solve_ode(tspan, C.T_0, C.area_window, R_tot, C.mass_tile, C.C_tile);
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
        [t, T] = run(C, days);
        plot(t, T, '-', 'DisplayName', 'Thickness: ' + string(insulation_sweep(i)))
    end
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
        [t, T] = run(C, days);
        plot(t, T, '-', 'DisplayName', 'Thickness: ' + string(tile_sweep(i)))
    end
    hold off
    legend()
end

