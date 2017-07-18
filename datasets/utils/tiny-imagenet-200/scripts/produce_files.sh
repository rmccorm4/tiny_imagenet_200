#!/bin/bash

# AUTHOR: Ryan McCormick (2017 ATR Center Intern)
# 
# This script is for generating subsets of tiny-imagenet-200 class
# wnid files. It reads the wnids200 file which contains all 200
# class ids for tiny-imagenet-200 and will produce <N>-class subsets
# in the form of words<N>.txt and wnids<N>.txt
#
# Additionally, since the wnids200 file has similar classes close together,
# I added an increment while reading the file to try to get different
# classes for the best accuracy. For example, for generating 10-class subsets
# you can use an increment of 10 to read every 10th line of wnids200.txt and
# produce 100 different wnids10.txt files with 10 different class IDs.
#
# These wnids10 files would be lines i, i+10, i+20, ..., i+100 of
# wnids200.txt for every i from 1 to (200 - num_classes*increment)
#
# So for 10 class subsets with increment of 10, you could produce 100
# different wnids10.txt files to generate an imdb file for using 
# generate_TINY_IMAGENET.m
#
# Just simply pass generate_TINY_IMAGENET.m the path to your different wnids 
# files and if done correctly you could produce imdb1.mat - imdb100.mat inside
# of datasets/tiny_imagenet

# EXECUTION:
# ./produce_files.sh $1 $2
# $1 = <number of classes between 1-200 (200 already exists as wnids200.txt)> 
# $2 = <number of lines to skip while reading wnids200>

end=$[200-$1*$2]

for i in $(seq 1 $end)
do
	outdir="../$1_class_combinations/increment_by_$2/$i"
	mkdir -p $outdir
	# Get every 10th line starting at i'th line - only taking first 20 lines of output
	sed -n "$i~$2p" < "../wnids200.txt" | head -n $1 > "$outdir/wnids$1.txt"
	sed -n "$i~$2p" < "../words200.txt" | head -n $1 > "$outdir/words$1.txt"
done
