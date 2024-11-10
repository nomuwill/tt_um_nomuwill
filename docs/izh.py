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

    def __init__(self, thr):
        self.a = 0.02    # Time constant for u (recovery variable)
        self.b = 0.2    # Sensitivity of recovery variable to voltage
        self.c = -65    # Reset value for voltage when a spike occurs
        self.d = 8    # Reset value for recovery variable when a spike occurs
        self.thr = thr  # Spike threshold

        # Initial conditions
        self.v = -65   # Initial voltage (in mV)
        self.u = 0     # Initial recovery variable

        # Misc
        self.dt = .01    # Time step (ms) 

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


if __name__ == "__main__":

    # Parameters
    n_steps = 10000  # Number of time steps to simulate
    currents = [4, 6, 8]  # List of input currents (scaled values)
    colors = ['grey', 'silver', 'black']
    threshold = 30  # Spike threshold

    # Create neuron
    neuron = IzhikevichNeuron(thr=threshold)

    # Plot setup
    fig, ax = plt.subplots(figsize=(10, 6))
    plt.subplots_adjust(left=0.2, right=0.8, hspace=0.5)
    ax.set_title("Voltage vs Time for Input Currents")
    ax.set_xlabel("Time Step")
    ax.set_ylabel("Voltage (mV)")

    # Simulate for different currents
    for i, current in enumerate(currents):
        # Reset neuron state
        neuron.v = -65
        neuron.u = 0
        
        voltages = np.zeros(n_steps)

        # Simulate for each current
        for step in range(n_steps):
            neuron.step(current)
            voltages[step] = neuron.v

        # Plot voltage for each current with corresponding color
        ax.plot(voltages, label=f"Current = {current} μA", color=colors[i])

    # Add threshold
    ax.axhline(y=threshold, color='lightgrey', linestyle='--', label='Threshold')

    # Show legend
    plt.legend()
    plt.show()