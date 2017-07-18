% AUTHOR: Ryan McCormick (2017 ATR Center Intern)

% Example of saving the best validation accuracy from a
% a tiny-imagenet-200 <N>-class network

% Refer to https://github.com/djsaunde/RiNNs
% to get the code for functions such as +train/save_best.m
% and ProjectSetup.m + SystemSettings.m

/home/atrcenter/Desktop/DanRyan/RiNNs/train.save_best('tiny_imagenet_32x32')
load /home/atrcenter/Desktop/DanRyan/RiNNs/work/training/tiny_imagenet_32x32/best.mat
x = struct2cell(stats.val)
top1errs = cell2mat( x(2,:,:) )
min_top1err = min(top1errs)
