%%%
%%% First pass for a simple house model
%%%


% Some constants
% m^2 (
area_window = 2.6*5;
area_tile = 4*4;
area_wall_1 = 3*5;     
area_wall_2 = 3*5.1;         
area_floor_ciel = 5.1*5*2; 
area_walls = (area_wall_1 + area_wall_2)*2 + area_floor_ciel; 
% )
% m (
thickness_wall = 0.015; 
thickness_tile = 0.3; 
thickness_window = 0.003175
% )
volume_tile = area_tile * thickness_tile; % m^3
h_window = 0.7;              % W/(m^2)K
k_fiberglass = 0.04;         % W/mK
k_glass = 0.08;              % W/mK
density_tile = 3000;         % kg/m^3
C_tile = 800;                % J/(kg)K
mass_tile = volume_tile * density_tile; %kg
h_indoor = 15;               % W/(m^2)K
h_outdoor = 30;              % W/(m^2)K
T_outdoor = -3;              % C 

R_tot = total_resistance(h_indoor, h_outdoor, h_window, area_tile, area_walls, area_window, thickness_window, thickness_wall, k_fiberglass, k_glass)
days = 10;
tspan = [0, days*86400];
T_0 = T_outdoor;
[t, T] = ode45(@(t,T) (solar_flux(t, area_window)-((T-T_outdoor)/R_tot))*(1/(mass_tile*C_tile)), tspan, T_0);
t_hours  = t/3600;
figure()
plot(t_hours, T, '--')
title('Passive Solar House Temp')
xlabel('Time (hours)')
ylabel('Temperature (C)')
max(T)
mean(T)


%%%
%%% Sweep Insulation Thickness
%%%

days = 10;
tspan = [0, days*86400];

insulation_sweep = linspace(0.01, 0.03, 5)
figure();
insulation_sweep(1)
hold on
for i = 1:length(insulation_sweep)
    R_tot = total_resistance(h_indoor, h_outdoor, h_window, area_tile, area_walls, area_window, thickness_window, insulation_sweep(i), k_fiberglass, k_glass)
    [t, T] = ode45(@(t,T) (solar_flux(t, area_window)-((T-T_outdoor)/R_tot))*(1/(mass_tile*C_tile)), tspan, T_0);
    plot(t, T, '-', 'DisplayName', 'Thickness: ' + string(insulation_sweep(i)))
end
hold off
legend()


%%%
%%% Sweep Tile Thickness
%%%
days = 40;
tspan = [0, days*86400];

tile_sweep = linspace(0.4, 0.6, 5);
figure();
tile_sweep(1)
hold on
for i = 1:length(tile_sweep)
    R_tot = total_resistance(h_indoor, h_outdoor, h_window, area_tile, area_walls, area_window, thickness_window, thickness_wall, k_fiberglass, k_glass)
    volume_tile = area_tile * tile_sweep(i); % m^3
    mass_tile = volume_tile * density_tile;
    [t, T] = ode45(@(t,T) (solar_flux(t, area_window)-((T-T_outdoor)/R_tot))*(1/(mass_tile*C_tile)), tspan, T_0);
    plot(t, T, '-', 'DisplayName', 'Thickness: ' + string(tile_sweep(i)))
end
hold off
legend()




%%%
%%% Helper Functions
%%%

% calculates the conduction resistance given thickness (L), thermal
% conductivity (k), and cross-sectional area (A)
function f = conduction_resistance(L, k, A)
    f = L/(k*A);
end

% calculates the convection resistance given heat transfer coefficient (h)
% and cross-sectional area (A)
function f = convection_resistance(h, A)
    f = 1/(h*A);
end

% adds two resistances in parallel
function f = parallel_adder(a, b)
    f = 1/((1/a) + (1/b));
end

% calculates solar flux given a time (t) and window area A
function f = solar_flux(t, A)
    f = A *((-361*cos((pi*t)/(12*3600)) + 224*cos((pi*t)/(6*3600)) + 210)); % W/(m^2)
end

function f = total_resistance(h_indoor, h_outdoor, h_window, area_tile, area_walls, area_window, thickness_window, thickness_wall, k_fiberglass, k_glass)
    CONV_tile_air = convection_resistance(h_indoor, area_tile);
    CONV_air_wall = convection_resistance(h_indoor, area_walls);
    COND_through_wall = conduction_resistance(thickness_wall, k_fiberglass, area_walls);
    CONV_wall_air = convection_resistance(h_outdoor, area_walls);
    CONV_air_window = convection_resistance(h_window, area_window); 
    COND_through_window = conduction_resistance(thickness_window, k_glass, area_window);
    CONV_window_air = convection_resistance(h_window, area_window); 
    
    R_wall = (CONV_air_wall + COND_through_wall + CONV_wall_air);
    R_window = (CONV_air_window + CONV_window_air + COND_through_window);
    
    f = CONV_tile_air + parallel_adder(R_wall, R_window);
end
    