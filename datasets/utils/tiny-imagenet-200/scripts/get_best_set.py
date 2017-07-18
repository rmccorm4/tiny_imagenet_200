import os

# AUTHOR: Ryan McCormick (2017 ATR Center Intern)
#
# Purpose: This script is for getting the best accuracy/minimum top1err of
#		   many trained tiny-imagenet-200 networks using matconvnet conventions.
#
# Execution: `python3 plot_network_accuracy_distribution.py`
#
# DISCLAIMER: Written for Python3, easily changeable for Python2.

combo = input("Enter the number of classes in your subsets: ")
inc = input("Enter your increment value: ")

err_list = []
for i in range(1, 101):
	err_file = open(os.path.join('..', combo + '_class_combinations', 'increment_by_' + inc, str(i), 'min_top1err.txt'))
	error = float(err_file.read())
	err_list.append(error)

best_err = min(err_list)
best_set = err_list.index(best_err)

# +1 for zero-indexing
print('Best class set was:', best_set + 1)
print('Best error was:', best_err)
