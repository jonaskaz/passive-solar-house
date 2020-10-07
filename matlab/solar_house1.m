%%%
%%% First pass for a simple house model
%%%


% Some constants
area_window = 2.6*5         % m^2
area_wall =                 % m^2
h_window = 0.7              % W/(m^2)K
k_fiberglass = 0.04         % W/mK
density_tile = 3000         % kg/m^3
C_tile = 800                % J/(kg)K
h_indoor = 15               % W/(m^2)K
h_outdoor = 30              % W/(m^2)K
temp_outdoor = -3           % C 

% Calculate individual resistances
CONV_tile_air = 
CONV_air_wall = 
COND_through_wall = 
CONV_wall_air = 
CONV_air_window = 
COND_through_window = 
CONV_window_air = 

tspan = [0, 1000000]
T0 = 10
[t, T] = ode45(@(t,T) (650-((T-T0)/.042))*(1/(4800*1000)), tspan, T0);

figure()
plot(t, T, '--')


% calculates the conduction resistance given thickness (L), thermal
% conductivity (k), and cross-sectional area (A)
function f = conduction_resistance(L, k, A)
    f = (L/(k*A);
end

% calculates the convection resistance given heat transfer coefficient (h)
% and cross-sectional area (A)
function f = convection_resistance(h, A)
    f = 1/(h*A);
end

% adds two resistances in parallel
function f = parallel_adder(a, b)
    f = 1/((1/a) + (1/b));

% calculates solar flux given a time (t)
function f = solar_flux(t)
    f = -361*cos((pi*t)/(12*3600)) + 224*cos((pi*t)/(6*3600)) + 210 % W/(m^2)
end