%%%
%%% Helper Function Class
%%%

classdef helper
    methods(Static)
        
        % Adds two resistances in parallel
        % Returns resistance in in K/W
        function f = parallel_adder(a, b)
            f = 1./((1./a) + (1./b));
        end
        
        % Solves the double ode for temp of tile and wall
        % Returns the a time t and temperatures T
        function [t, T] = solve_double_ode(tspan, C)
            %T(1)/(R1*C.mass_wall *C.C_wall)+T(2)*(-1/(C.mass_wall *C.C_wall*R2)-1/(C.mass_wall *C.C_wall*R1))+C.T_out/(C.mass_wall *C.C_wall*R2)
            R1 = helper.R_tile_air(C.h_indoor, C.area_tile);
            R2 = helper.R_air_out(C);
            [t, T] = ode45(@(t, T) [((1/(C.mass_tile*C.C_tile)) *(helper.solar_flux(t, C.area_window) - ((T(1)-T(2))/R1))); T(1)/(R1*C.mass_air *C.C_air)+T(2)*(-1/(C.mass_air *C.C_air*R2)-1/(C.mass_air *C.C_air*R1))+C.T_out/(C.mass_air *C.C_air*R2) ], tspan, [C.T_0, C.T_0]);
        end
        
        % Solves the single ode
        % Returns a t x 2 matrix with time and Temp
        function [t, T] = solve_ode(tspan, T_0, area_window, R_tot, mass_tile, C_tile)
            [t, T] = ode45(@(t, T) (helper.solar_flux(t, area_window)-((T-helper.outside_temp(t))./R_tot))*(1./(mass_tile*C_tile)), tspan, T_0);
        end
        
        % Solves the ode with constant temp
        % Returns a t x 2 matrix with time and Temp
        function [t, T] = solve_ode_con(tspan, T_0, area_window, R_tot, mass_tile, C_tile)
            [t, T] = ode45(@(t,T) (helper.solar_flux(t, area_window)-((T-T_0)./R_tot))*(1./(mass_tile*C_tile)), tspan, T_0);
        end
        
        % Calculates solar flux given a time (t) and window area A
        % Returns solar flux in W/m^2
        function f = solar_flux(t, A)
            class(t)
            f = A *((-361*cos((pi*t)./(12*3600)) + 224*cos((pi*t)./(6*3600)) + 210)); % W/(m^2)
        end
        
        % Calculates the outside temperature for a given time t
        % Returns temperature in Celsius
        function f = outside_temp(t)
            f = -3 + 6*sin((2*pi*t./(24*60*60))+ 3*pi./4);
        end
        
        % Calculates resistance from tile to the wall
        % Returns resistance in K/W
        function f = R_tile_air(h_indoor, area_tile)
            f = helper.convection_resistance(h_indoor, area_tile);
        end
        
        % Calculates resistance from the air inside to air outside
        % Returns resistance in K/W
        function f = R_air_out(C)
            CONV_air_wall = helper.convection_resistance(C.h_outdoor, C.area_walls);
            COND_through_wall = helper.conduction_resistance(C.thickness_wall, C.k_fiberglass, C.area_walls);
            CONV_wall_air = helper.convection_resistance(C.h_outdoor, C.area_walls);
            CONV_air_window = helper.convection_resistance(C.h_window, C.area_window); 
            COND_through_window = helper.conduction_resistance(C.thickness_window, C.k_glass, C.area_window);
            CONV_window_air = helper.convection_resistance(C.h_window, C.area_window); 
            R_wall = (CONV_air_wall + COND_through_wall + CONV_wall_air);
            R_window = (CONV_air_window + CONV_window_air + COND_through_window);
            f = helper.parallel_adder(R_wall, R_window);
        end
        
        % Calculates the total resistance 
        % Returns resistance in K/W
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
        % Returns resistance in K/W
        function f = convection_resistance(h, A)
            f = 1./(h*A);
        end
        
        % Calculates the conduction resistance given thickness (L), thermal
        % conductivity (k), and cross-sectional area (A)
        % Returns resistance in K/W
        function f = conduction_resistance(L, k, A)
            f = L./(k*A);
        end
    end
end