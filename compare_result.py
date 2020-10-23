import numpy as np
import matplotlib.pyplot as plt

my_model = np.load('./label_and_value.npz')
com = np.load('./label_and_value_1.npz')
labels = my_model['arr_0']
values_1 = my_model['arr_1']
values_2 = com['arr_1']
y_pos = np.arange(len(labels))
fig = plt.figure(figsize=(12, 8))

width = 0.4

plt.barh(y_pos, values_1, width, color='blue', label='MY_result')
plt.barh(y_pos + width, values_2, width, color='green', label='Original_result')

#ax.set(yticks=ind + width, yticklabels=df.graph, ylim=[2*width - 1, len(df)])
plt.legend()

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
