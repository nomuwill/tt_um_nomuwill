'''
Noah Williams
11/9/2024

Simulation for the Izhikevich Neuron Model
'''

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider
import matplotlib.colors as mcolors

class IzhikevichNeuron:

    ''' Used to model Izhikevich Neuron '''

    def __init__(self, a, b, c, d, thr, 
                 initial_voltage=-65, 
                 initial_recovery=0,
                 dt=.01):

        self.a = a    # Time constant for u (recovery variable)
        self.b = b    # Sensitivity of recovery variable to voltage
        self.c = c    # Reset value for voltage when a spike occurs
        self.d = d    # Reset value for recovery variable when a spike occurs
        self.thr = thr  # Spike threshold

        # Initial conditions
        self.v = initial_voltage   # Initial voltage (in mV)
        self.u = initial_recovery     # Initial recovery variable

        # Misc
        self.dt = dt    # Time step (ms) 

    def step(self, current):
        v_prime = (0.04 * self.v**2) + (5 * self.v) + 140 - self.u + current
        u_prime = self.a * (self.b * self.v - self.u)
        v_next = self.v + v_prime * self.dt
        u_next = self.u + u_prime * self.dt

        spike = 0
        if self.v >= self.thr:  
            self.v = self.c 
            self.u = self.u + self.d 
            spike = 1
        else:
            self.v = v_next
            self.u = u_next
        
        return spike
    
class TTIzhikevichNeuron:

    ''' 
    Used to test HDL model of Izhikevich Neuron Model 
    
    Model includes fixed point representation of parameters, '
        and scaling to match the HDL TinyTapeout implementation. 

    Parameters:
        a, b, c, d, thr: 16bit
        
    '''

    def __init__(self, a, b, c, d, thr, 
                 initial_voltage=-65, 
                 initial_recovery=0,
                 dt=.01):

        self.a = a    # Time constant for u (recovery variable)
        self.b = b    # Sensitivity of recovery variable to voltage
        self.c = c    # Reset value for voltage when a spike occurs
        self.d = d    # Reset value for recovery variable when a spike occurs
        self.thr = thr  # Spike threshold

        # Initial conditions
        self.v = initial_voltage   # Initial voltage (in mV)
        self.u = initial_recovery     # Initial recovery variable

        # Misc
        self.dt = dt    # Time step (ms) 

    def step(self, current):

        # Convert current to 8 bit bin
        current = bin(current)[2:]

        v = '00000000' + current

        v_prime = (0.04 * self.v**2) + (5 * self.v) + 140 - self.u + current
        u_prime = self.a * (self.b * self.v - self.u)
        v_next = self.v + v_prime * self.dt
        u_next = self.u + u_prime * self.dt

        spike = 0
        if self.v >= self.thr:  
            self.v = self.c 
            self.u = self.u + self.d 
            spike = 1
        else:
            self.v = v_next
            self.u = u_next
        
        return spike


def str_to_Q9pt7(str):
    ''' Convert binary string to Q9.7 fixed point '''
    return int(str, 2) / 2**7

def str_to_dec(str):
    ''' Convert binary string to decimal '''
    return int(str, 2)


if __name__ == "__main__":

    # Parameters
    n_steps = 10000  # Number of time steps to simulate
    currents = [8, 10, 12]  # List of input currents (scaled values)
    colors = ['grey', 'silver', 'black']
    

    a = '000000000_0000010'  # .015
    b = '000000000_0011000'  # .1875 
    c = '111110000_1110000'  # 63600
    d = '000010100_0000000'  # 20
    thr = '000000001_1100000'   # 30 
    u = '000000000_0000000'  # 0
    u_next = '000000000_0000000'  # 0
    v_next = '00000000'  # 0
    current = '00000000'
    spike = '0'

    # print(str_to_Q9pt7(a))
    # print(str_to_Q9pt7(b))
    # print(str_to_Q9pt7(c))
    # print(str_to_Q9pt7(d))
    # print(str_to_Q9pt7(thr))

    current = 6
    current = bin(current)
    print(current)




    # Create neuron
    # neuron = IzhikevichNeuron(a=0.02, b=0.15, c=-65, d=10, thr=threshold)

    # # Plot setup
    # fig, ax = plt.subplots(figsize=(10, 6))
    # plt.subplots_adjust(left=0.2, right=0.8, hspace=0.5)
    # ax.set_title("Voltage vs Time for Input Currents, Single Izh Neuron")
    # ax.set_xlabel("Time Step")
    # ax.set_ylabel("Voltage (mV)")

    # # Simulate for different currents
    # for i, current in enumerate(currents):
    #     # Reset neuron state
    #     neuron.v = -65
    #     neuron.u = 0
        
    #     voltages = np.zeros(n_steps)

    #     # Simulate for each current
    #     for step in range(n_steps):
    #         neuron.step(current)
    #         voltages[step] = neuron.v

    #     # Plot voltage for each current with corresponding color
    #     ax.plot(voltages, label=f"Current = {current} μA", color=colors[i])

    # # Add threshold
    # ax.axhline(y=threshold, color='lightgrey', linestyle='--', label='Threshold')

    # # Show legend
    # plt.legend()
    # plt.show()