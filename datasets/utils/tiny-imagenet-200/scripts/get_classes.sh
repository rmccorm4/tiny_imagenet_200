#!/bin/bash

# AUTHOR: Ryan McCormick (2017 ATR Center Intern)
#
# NOTE: This script is very general and can be used to search for any
# 		terms of file1 contained in file2, outputting the matches to an
#		output file of your choice.
#
# This script is for getting the labels of your various <N>-class subsets
# of tiny-imagenet-200 so you can actually see what classes you are training
# on.

echo "Enter file1 to get search terms from: "
read file1
echo "Enter file2 to find search terms in: "
read file2
echo "Enter name of the output file: "
read outfile

# This will append to output file so make sure its empty
# if you want only these contents
cat $file1 | while read line
do
	grep $line $file2 >> $outfile
done
