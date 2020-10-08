# MVP Passive Solar House Model

import numpy as np
import scipy.integrate as integrate
import csv

from helpers import helper

# Constants
area_window = 2.6*5
area_tile = 4*4
area_wall_1 = 3*5  
area_wall_2 = 3*5.1     
area_floor_ciel = 5.1*5*2
area_walls = (area_wall_1 + area_wall_2)*2 + area_floor_ciel

thickness_wall = 0.015
thickness_tile = 0.3
volume_tile = area_tile * thickness_tile # m^3
h_window = 0.7              # W/(m^2)K
k_fiberglass = 0.04         # W/mK
density_tile = 3000         # kg/m^3
C_tile = 800                # J/(kg)K
mass_tile = volume_tile * density_tile # kg
h_indoor = 15               # W/(m^2)K
h_outdoor = 30              # W/(m^2)K
T_outdoor = -3              # C 

# Calculate individual resistances
CONV_tile_air = helper.convection_resistance(h_indoor, area_tile)
CONV_air_wall = helper.convection_resistance(h_indoor, area_walls)
COND_through_wall = helper.conduction_resistance(thickness_wall, k_fiberglass, area_walls)
CONV_wall_air = helper.convection_resistance(h_outdoor, area_walls)
CONV_air_window = helper.convection_resistance(h_window, area_window) 
#COND_through_window = conduction_resistance(thickness_wall, k_fiberglass, area_walls)
#maybe not needed ^^
CONV_window_air = helper.convection_resistance(h_window, area_window) 
R_wall = (CONV_air_wall + COND_through_wall + CONV_wall_air)
R_window = (CONV_air_window + CONV_window_air)
R_tot = CONV_tile_air + helper.parallel_adder(R_wall, R_window)
T_0 = T_outdoor

def passive_house(t, T):
    dT = np.array([
        T,
        500-(((T-T_outdoor)/R_tot))*(1/(mass_tile*C_tile))
    ])
    return dT

def solve_ode():
    days = 10
    tspan = np.linspace(0, days*86400, days*86400)
    Y = integrate.odeint(passive_house, [T_0, 0], tspan)
    return Y

def save_data(data):
    '''Saves data to csv
    param:
    data = numpy array
    '''
    np.savetxt("../data/ode/ode_data.csv", data)

def run():
    save_data(solve_ode())

if __name__ == "__main__":
    run()