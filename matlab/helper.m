%%%
%%% Helper Function Class
%%%

classdef helper
    methods(Static)
        
        % Adds two resistances in parallel
        % Returns resistance
        function f = parallel_adder(a, b)
            f = 1./((1./a) + (1./b));
        end
        
        % Solves the ode
        % Returns a t x 2 matrix with time and Temp
        function [t, T] = solve_ode(tspan, T_0, area_window, R_tot, mass_tile, C_tile)
            [t, T] = ode45(@(t,T) (helper.solar_flux(t, area_window)-((T-helper.outside_temp(t))./R_tot))*(1./(mass_tile*C_tile)), tspan, T_0);
        end
        
        % Solves the ode with constant temp
        % Returns a t x 2 matrix with time and Temp
        function [t, T] = solve_ode_con(tspan, T_0, area_window, R_tot, mass_tile, C_tile)
            [t, T] = ode45(@(t,T) (helper.solar_flux(t, area_window)-((T-T_0)./R_tot))*(1./(mass_tile*C_tile)), tspan, T_0);
        end
        
        % Calculates solar flux given a time (t) and window area A
        % Returns solar flux
        function f = solar_flux(t, A)
            f = A *((-361*cos((pi*t)./(12*3600)) + 224*cos((pi*t)./(6*3600)) + 210)); % W/(m^2)
        end
        
        % Calculates the outside temperature for a given time t
        % Returns temperature in Celsius
        function f = outside_temp(t)
            f = -3 + 6*sin((2*pi*t./(24*60*60))+ 3*pi./4);
        end
        
        % Ralculates the total resistance 
        % Returns resistance
        function f = total_resistance(h_indoor, h_outdoor, h_window, area_tile, area_walls, area_window, thickness_window, thickness_wall, k_fiberglass, k_glass)
            CONV_tile_air = helper.convection_resistance(h_indoor, area_tile);
            CONV_air_wall = helper.convection_resistance(h_indoor, area_walls);
            COND_through_wall = helper.conduction_resistance(thickness_wall, k_fiberglass, area_walls);
            CONV_wall_air = helper.convection_resistance(h_outdoor, area_walls);
            CONV_air_window = helper.convection_resistance(h_window, area_window); 
            COND_through_window = helper.conduction_resistance(thickness_window, k_glass, area_window);
            CONV_window_air = helper.convection_resistance(h_window, area_window); 

            R_wall = (CONV_air_wall + COND_through_wall + CONV_wall_air);
            R_window = (CONV_air_window + CONV_window_air + COND_through_window);

            f = CONV_tile_air + helper.parallel_adder(R_wall, R_window);
        end
        
        % Calculates the convection resistance given heat transfer coefficient (h)
        % and cross-sectional area (A)
        % Returns resistance
        function f = convection_resistance(h, A)
            f = 1./(h*A);
        end
        
        % Calculates the conduction resistance given thickness (L), thermal
        % conductivity (k), and cross-sectional area (A)
        % Returns resistance
        function f = conduction_resistance(L, k, A)
            f = L./(k*A);
        end
    end
end