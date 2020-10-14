# File for plotting ode data

import matplotlib.pyplot as plt
import numpy as np

class plot():
    '''
    Class for plotting ode data
    '''
    @staticmethod
    def plot_temp_time(sol):
        '''returns a plot of temperature over time
        param:
        data = numpy array
        '''
        plt.plot(sol.t/86400, sol.y[0])
        plt.show()

