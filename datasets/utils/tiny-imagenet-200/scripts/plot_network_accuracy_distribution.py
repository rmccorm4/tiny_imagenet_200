import os
# Non-HPC
import matplotlib.pyplot as plt

# AUTHOR: Ryan McCormick (2017 ATR Center Intern)
#
# This script is for plotting the distribution of trianing accuracies of
# various <N>-class subsets of a dataset such as tiny-imagenet-200.
#
# You will have to create your <N>-class subsets using `produce_files.sh`
# and train all of the associated networks using generate_TINY_IMAGENET.m
# and mass_train_tiny_imagenet_32x32.m
#
# You will have to first get all of the proper min_top1errors in the
# proper places using `record_best_error.m` or rewrite this script 
# for your own purposes.
#
# DISCLAIMER: Written for Python3, easily adaptable for Python2.
#
# Requirements: min_top1err.txt files for each network you want to plot
#				which can be gotten from producing networks with
#				`produce_files.sh` and training those networks, saving
#				their best resulting stats.val.top1err value to a file
#				named 'min_top1err.txt'. You can see how to save the best
#				error in the example in `record_best_error.m`
#
# Execution: `python3 plot_errors.py`

combo = input('Enter number of classes: ')
title = input('Enter plot title: ')
ylabel = input('Enter y-axis label: ')

err_dict = {}
for i in range(1, 51):
	err_file = open(os.path.join('..', combo + '_class_combinations', 'increment_by_10', str(i), 'min_top1err.txt'))
	error = float(err_file.read())
	err_dict[i] = error
	err_file.close()
"""
for i in range(1, 151):
	err_file = open(os.path.join('..', combo + '_class_combinations', 'increment_by_4', str(i), 'min_top1err.txt'))
	error = float(err_file.read())
	err_dict[i+100] = error
	err_file.close()

for i in range(1, 51):
	err_file = open(os.path.join('..', combo + '_class_combinations', 'increment_by_15', str(i), 'min_top1err.txt'))
	error = float(err_file.read())
	err_dict[i+250] = error
	err_file.close()
"""

accuracies = [(1-err_dict[key])*100 for key in err_dict.keys()]
#plt.plot(err_dict.keys(), err_dict.values(), 'ro')

#plt.hist(err_dict.values(), 10)
plt.hist(accuracies, 20, edgecolor='black', linewidth=1.2)
plt.xlabel('Accuracies (0-100%)')
plt.ylabel(ylabel)
plt.title(title)
#plt.ylabel('Amount of 10-class sets out of 300')
#plt.title('Distribution of 10-class subset accuracies for Tiny_Imagenet')
plt.grid(True, linestyle='dotted')
plt.show()
