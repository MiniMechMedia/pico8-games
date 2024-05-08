import matplotlib.pyplot as plt
import numpy as np

# Coordinates of the point
x, y = 2, 3

# Create a figure and an axes
fig, ax = plt.subplots()

# Plot the point (2, 3)
ax.plot(x, y, 'ro')  # 'ro' stands for red circle

# Set limits on the axes to make the point more central
ax.set_xlim(0, 5)
ax.set_ylim(0, 5)

# Set the granularity of the grid
ax.set_xticks(np.arange(0, 5, 0.2))
ax.set_yticks(np.arange(0, 5, 0.2))

# Enable grid
ax.grid(True)

# Show the plot
plt.show()