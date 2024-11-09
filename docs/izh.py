import numpy as np
import matplotlib.pyplot as plt

# Neuron parameters (scaled for fixed-point representation)
a = 0.02
b = 0.2
c = -65
d = 8
threshold = 30  # Spike threshold

# Initialize states for 16-bit and 8-bit precision
v_16, u_16 = -65, b * -65  # Initial values for v and u in 16-bit
v_8, u_8 = -65, b * -65    # Initial values for v and u in 8-bit

# Simulation parameters
time_steps = 100
current_input = 10  # Constant current input

# Containers for storing neuron states
v_16_states = []
v_8_states = []
diff_states = []

# Simulation loop
for _ in range(time_steps):
    # 16-bit precision calculations (simulated with floats)
    v_16 += 0.5 * (0.04 * v_16 * v_16 + 5 * v_16 + 140 - u_16 + current_input)
    u_16 += a * (b * v_16 - u_16)
    
    # 8-bit precision calculations (simulated by limiting decimal places)
    v_8 += round(0.5 * (0.04 * v_8 * v_8 + 5 * v_8 + 140 - u_8 + current_input), 2)
    u_8 += round(a * (b * v_8 - u_8), 2)
    
    # Spike reset
    if v_16 >= threshold:
        v_16, u_16 = c, u_16 + d
    if v_8 >= threshold:
        v_8, u_8 = c, u_8 + d

    # Store results
    v_16_states.append(v_16)
    v_8_states.append(v_8)
    diff_states.append(abs(v_16 - v_8))

# Plotting
plt.figure(figsize=(10, 6))
plt.plot(v_16_states, label="16-bit Precision", color='blue')
plt.plot(v_8_states, label="8-bit Precision", color='orange', linestyle='--')
plt.plot(diff_states, label="Difference", color='red', linestyle=':')
plt.xlabel("Time Step")
plt.ylabel("Membrane Potential (v)")
plt.legend()
plt.title("Comparison of 16-bit and 8-bit Precision in Izhikevich Neuron Model")
plt.show()