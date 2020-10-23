import numpy as np
import matplotlib.pyplot as plt

labels = np.loadtxt('./labels.txt')
values_1 = np.loadtxt('./values_1.txt')
values_2 = np.loadtxt('./values_2.txt')
y_pos = np.arange(len(labels))
fig = plt.figure(figsize=(12, 8))
plt.barh(y_pos, values_1, width=0.4, label="MY_result")
plt.barh(y_pos+0.4, values_2, width=0.4, label="Original_result")
plt.yticks(y_pos, labels)
plt.xticks(np.arange(0.5, 1.0, 0.05))
plt.xlabel('Dice coefficient', fontsize='x-large')
plt.axes().xaxis.grid(color='black', linestyle='-', linewidth=0.5)
axes = plt.gca()
axes.set_xlim([0.5, 1.0])
plt.tight_layout()
axes.axvline(np.mean(values_1), color='green', linewidth=2)
axes.axvline(np.mean(values_2), color='red', linewidth=2)

plt.savefig('DSC.png', bbox_inches='tight')
plt.close(fig)
