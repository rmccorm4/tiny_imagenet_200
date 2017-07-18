#!/bin/bash

# AUTHOR: Ryan McCormick (ATR Center 2017 Intern)
#
# Purpose: To setup everything necessary for matconvnet
#          as well as CUDA and CUDNN for GPU acceleration on (thunder)
#		   but it will most likely work on any machine
#
# Instructions: Make sure you have loaded the cuda, cudnn, and jpeg modules
#				if you'll be utilizing GPUs. You may need to request access
#				to these modules from someone in charge of the ATR interns
#				
#				Execute './hpc_matconvnet_setup.sh' and follow the prompts
#
# DISCLAIMER: This could probably be cleaned up and simplified but it worked
#				for me and didn't want to spend too much time on setup.
#				feel free to suggest changes or report issues.

# Setup directory for all downloads if it doesn't already exist
mkdir -p $HOME/bin
cd $HOME/bin

### VLFEAT
# Download vlfeat from their website if it's not already downloaded
if [ ! -f "$HOME/bin/vlfeat-0.9.20-bin.tar.gz" ]; then
        wget http://www.vlfeat.org/download/vlfeat-0.9.20-bin.tar.gz
fi

# Untar it, move into the directory, and build the files
tar -xvzf vlfeat-0.9.20-bin.tar.gz
cd vlfeat-0.9.20

# mlpath will be matlab's root path
# Should look something like /usr/local/MATLAB/R2017a (locally, not on HPC)
mlpath=`matlab -e | sed -n 's/MATLAB=//p'`

# Run mex script
make MEX="$mlpath/bin/mex"

# Testing VLFeat installation
echo "run('vlfeat-0.9.20/toolbox/vl_setup')" > "$HOME/bin/startup.m"
echo "quit" >> "$HOME/bin/startup.m"

echo
echo "VLFeat successfully installed!"
echo

### MATCONVNET
cd $HOME/bin

# Download if it doesn't exist
if [ ! -f "$HOME/bin/matconvnet-1.0-beta24.tar.gz" ]; then
        wget http://www.vlfeat.org/matconvnet/download/matconvnet-1.0-beta24.tar.gz
fi

tar -xvzf matconvnet-1.0-beta24.tar.gz
cd matconvnet-1.0-beta24

mcnpath="$HOME/bin/matconvnet-1.0-beta24"
# Check for GPU or CPU compilation
echo
echo "Enter if you want to compile for 'CPU' or 'GPU' (if you have it): "
read processor

# CPU
if [[ "$processor" == "CPU" ]] || [[ "$processor" == "cpu" ]]; then
        echo "addpath matlab" > cpu_setup.m
        echo "vl_compilenn" >> cpu_setup.m
        echo "vl_setupnn" >> cpu_setup.m
        echo "vl_testnn" >> cpu_setup.m
        echo "quit" >> cpu_setup.m
        matlab -nodisplay -nodesktop -r "run cpu_setup.m"

        echo
        echo "MatConvNet setup correctly for CPU!"
        echo

# GPU - difficult to automate because of nvidia account and sudo requirements 
#		if no modules available
elif [[ "$processor" == "GPU" ]] || [[ "$processor" == "gpu" ]]; then
		echo "Make sure you have loaded the cuda and cudnn modules before continuing!"
		echo "This command or something similar should suffice: "
		echo "module load cuda cudnn jpeg matlab/R2017a (Or your preferred version)"
        echo "Have you loaded the cuda, cudnn, and jpeg modules? Enter [y/n]: "
        read answer

        if [[ "$answer" -eq "y" ]]; then
                echo "addpath matlab" > gpu_compile.m
                echo "mex -setup C" >> gpu_compile.m
                echo "mex -setup C++" >> gpu_compile.m
                echo "vl_compilenn('enableGpu', true, 'enableCudnn', true,'enableImreadJpeg', true)" >> gpu_compile.m
                echo "addpath matlab" > gpu_setup.m
                echo "vl_setupnn" >> gpu_setup.m
                echo "vl_testnn('gpu', true, 'cpu', false)" >> gpu_setup.m
                matlab -nodisplay -nodesktop -r "run 'gpu_compile.m'"
                matlab -nodisplay -nodesktop -r "run 'gpu_setup.m'"
                echo "See '$mcnpath/gpu_setup.m' or '$mcnpath/gpu_compile.m' for any instructions that failed"
        fi
fi

