import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider

a = 0.02
b = 0.2 
c = -65  
d = 8   

def izhikevich_model(v, u, I, a=a, b=b, c=c, d=d, dt=0.1):
    if v >= 30:
        v = c
        u += d
        spike = 1
    else:
        v += dt * (0.04 * v**2 + 5 * v + 140 - u + I)
        u += dt * a * (b * v - u)
        spike = 0
    return v, u, spike

v = -65    # membrane potential
u = b * v  # recovery variable
I = 0      # current input
time = np.linspace(0, 100, 10000)
v_trace = [] 

fig, ax = plt.subplots(figsize=(10, 6))
plt.subplots_adjust(bottom=0.25)
ax.set_xlabel("Time (ms)")
ax.set_ylabel("Membrane Potential (mV)")
line, = ax.plot([], [], lw=2)
ax_slider = plt.axes([0.25, 0.01, 0.65, 0.03], facecolor='lightgoldenrodyellow')
slider = Slider(ax_slider, 'Current Input (I)', 3, 4, valinit=0, valstep=0.001)
ax.set_ylim(-80, 40)


def update(val):
    global v, u, I, v_trace
    I = slider.val
    v_trace.clear() 
    for t in time:
        v, u, _ = izhikevich_model(v, u, I)
        v_trace.append(v)
    
    # Update the plot data
    line.set_xdata(time)
    line.set_ydata(v_trace)

    ax.relim()
    ax.autoscale_view()
    plt.draw()

update(0)
slider.on_changed(update)
plt.show()