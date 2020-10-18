# Helper functions for MVP

import numpy as np

class helper():
    @staticmethod
    def conduction_resistance(L, K, A):
        ''' returns conduction resistance
        params:
        L = Thickness of material
        K = Thermal conductivity
        A = Area
        '''
        return L/(K*A)

    @staticmethod
    def convection_resistance(h, A):
        ''' return convection resistance
        params:
        h = heat transfer coefficient
        A = Area
        '''
        return 1/(h*A)

    @staticmethod
    def solar_flux(t, A):
        ''' returns heat (Qin)
        params:
        t = time
        A = Area
        '''
        q = -361*np.cos((np.pi*t)/(12*3600)) + 224*np.cos((np.pi*t)/(6*3600)) + 210
        return q*A

    @staticmethod
    def parallel_adder(*args):
        ''' returns total parallel resistance 
        params:
        args = resistors values
        '''
        R_total = 0
        for resistor in args:
            R_total += 1/resistor
        return 1/R_total