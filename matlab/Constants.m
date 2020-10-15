%%%
%%% Constants Class
%%%

classdef Constants
    properties
    % m^2 (
        area_window = 2.6*5;
        area_tile = 4*4;
        area_wall_1 = 3*5;     
        area_wall_2 = 3*5.1;         
        area_floor_ciel = 5.1*5*2; 
    % )
    % m (
        thickness_wall = 0.015; 
        thickness_tile = 0.3; 
        thickness_window = 0.003175;
    % )
        h_window = 0.7;              % W/(m^2)K
        k_fiberglass = 0.04;         % W/mK
        k_glass = 0.08;              % W/mK
        density_tile = 3000;         % kg/m^3
        C_tile = 800;                % J/(kg)K
        h_indoor = 15;               % W/(m^2)K
        h_outdoor = 30;              % W/(m^2)K
        T_0 = -3;                    % C
        volume_tile;                 % m^3
        mass_tile;                   % kg
        area_walls;                  % m^2
    end
    methods 
        function C = init(obj)
            obj.volume_tile = obj.area_tile * obj.thickness_tile; 
            obj.mass_tile = obj.volume_tile * obj.density_tile; 
            obj.area_walls = (obj.area_wall_1 + obj.area_wall_2)*2 + obj.area_floor_ciel; 
            C = obj;
        end
    end 
end