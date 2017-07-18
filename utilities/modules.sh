#!/bin/bash

# AUTHOR: Ryan McCormick (ATR Center 2017 Intern)

# This is a utility file to make sure you've loaded all necessary
# modules for your work. The 'source' command makes sure that 
# these modules apply to your current session

# Alternatively you could load your modules in your .personal_bashrc
# which is sourced everytime you ssh into thunder

source module use /p/work2/projects/ryat/modules/modulefiles
# These are useful modules for running matconvnet on Thunder with GPUs
source module load git cuda jpeg cudnn matlab/R2017a
