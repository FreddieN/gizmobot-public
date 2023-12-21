import json
import numpy as np
import matplotlib.pyplot as plt

#Prototyping code for what was developed as 'radar' mode in the app
results_data = []
overall = []

with open('results', 'r') as results:
    results_data = json.loads(results.read()) #read in the results file

for i in [1,2,3,0]: #order that each sensor value should be added to overall dataset
    for item in results_data: 
        if(item[i] < 7000): #check if a value is less than 7000mm and therefore a valid reading
            overall.append(item[i])
        else:
            overall.append(0)

print(overall)

values=overall
angles = np.linspace(0, 2 * np.pi, len(values), endpoint=False) #build an array of angles between 0 and 360 with interval determined by how many in the overall array

fig, ax = plt.subplots(subplot_kw={'projection': 'polar'}) #plot a polar figure
ax.plot(angles, values) #plot a radar plot of the points

plt.show()