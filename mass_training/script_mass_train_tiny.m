function mass_train_tiny(start, finish, inc, num_classes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTHOR: Ryan McCormick (2017 ATR Center Intern)
%
% This code isn't necessarily pretty, just a quick and dirty implementation
% for training a lot of networks and saving their best accuracies in a 
% simple fashion.
%
% This code is written to train many 10-class subsets of tiny-imagenet-200,
% but can be simply refactored for any number of classes in a subset.
%
% If not doing 10-class subsets, you will need to change the call to
% `mass_train_tiny_imagenet_32x32` to your network architecture/training script
%
%
% DISCLAIMER: This code is not meant to work for anything out of the box,
%			  it was written to run for a very specific problem. However,
%			  it shouldn't be very difficult to refactor it.
%
% You will probably need to change some of the paths and network names
% for your own purposes. This script is meant to work together with 
% produce_files.sh and generate_TINY_IMAGENET.m for creating many 
% network setups.

if ~isdeployed
	run '../../ProjectSetup'
	run '../../SystemSettings'
else
	source_path = '/work1/workspace/rmccorm4/RiNNs/';
	work_path = [source_path 'work/'];
	datasets_path = [source_path 'datasets/'];
end

disp(['Pass in start, finish, inc, num_classes for your desired results!'])

if ischar(start)
	start = str2num(start)
end

if ischar(finish)
	finish = str2num(finish)
end

if ~ischar(inc)
	inc = int2str(inc)
end

if ~ischar(num_classes)
	num_classes = int2str(num_classes)
end

mass_train_path = [source_path 'scripts/mass_training'];
for i = start : finish
	% Define important paths for organization
	network_name = ['tiny_imagenet_32x32_network' int2str(i)];
	imdb_dir = [datasets_path 'tiny_imagenet/' num_classes '_class_combinations/increment_by_' inc];
	imdb_path = [datasets_path 'tiny_imagenet/' num_classes '_class_combinations/increment_by_' inc '/imdb' int2str(i) '.mat'];
	train_output_path = [work_path 'training/' num_classes '_class_combinations/increment_by_' inc '/' network_name]
	post_train_path = [num_classes '_class_combinations/increment_by_' inc '/' network_name];
	mkdir([source_path 'training_plots/' num_classes '_class_combinations/increment_by_' inc '/'])

	cd(datasets_path)
	disp(['Generating imdb and training for ' imdb_path '...'])
	% Get path to wnid files
	wnids_path = fullfile(datasets_path, 'utils', 'tiny-imagenet-200', [num_classes '_class_combinations'], ['increment_by_' inc], int2str(i)) ;
	wnids_file = fullfile(wnids_path, ['wnids' num_classes '.txt'])
	if ~exist(imdb_path)
		% Generate imdb file for num_classes	
		mkdir(imdb_dir)
		generate_TINY_IMAGENET('output', imdb_path, 'wnids', wnids_file, 'num_classes', num_classes)
	end

	if ~exist([train_output_path '/best.mat'])
		% Train on these num_classes
		cd([work_path '/training/' num_classes '_class_combinations'])
		system(['rm -r ' network_name])
		cd(mass_train_path)
		
		% Training plots saved to ~/RiNNs/training_plots
		mass_train_tiny_imagenet_32x32('imdb_path', imdb_path, 'train_output_path', post_train_path)
		
		% Record best error
		cd(source_path)
		train.save_best(post_train_path)

		% Remove every epoch other than best
		epochs = [train_output_path '/net-epoch*']
		command = sprintf('rm %s', epochs)
		system(command)
		
		% Load best
		load([train_output_path '/best.mat'])
		
		% Get best min_top1err
		x = struct2cell(stats.val) ;
		top1errs = cell2mat( x(2,:,:) ) ;
		min_top1err = min(top1errs)
		
		% Write min_top1err out to file for given classes
		fid = fopen(fullfile(wnids_path, 'min_top1err.txt'), 'w')
		formatSpec = '%f'
		fprintf(fid, formatSpec, min_top1err)
		fclose(fid)
	end
end

exit
