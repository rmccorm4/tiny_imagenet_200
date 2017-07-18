function generate_TINY_IMAGENET(varargin)
%% GENERATE_TINY_IMAGENET - Prepare the image database structure for the
% Tiny ImageNet dataset.
%
%   generate_TINY_IMAGENET generates the imdb structure for the Tiny ImageNet
%   dataset. The input files are downloaded if necessary.
%
%   generate_TINY_IMAGENET('option', value, 'option', value, ....) can be 
%   used to control generation parameters. Allowed options are shown below. 
%   Default values for each option are shown in parentheses.
%
%	output ('imdb'): The name of the .mat file which contains the generated Tiny ImageNet
%	dataset.
%
%	wnids (''): The name of the wnids file created by produce_files.sh
%				If num_classes == 200, it will use the wnids200.txt file
%				given by the tiny-imagenet-200 database. 
%
%				If you are downloading tiny-imagenet-200 from online, you will
%				need to rename wnids.txt to wnids200.txt or change the code here
%			    if the script did not handle this properly, but it should.
%
%	num_classes (200): Number of classes to generate an IMDB file for, valid
% 					   range between 1-200, however for any number other than
%					   200 you will need to create the wnids files using
%					   `produce_files.sh` found in utils/tiny-imagenet-200/scripts.
%
%	resize (false): Whether to resize the Tiny ImageNet images. If true, will resize images
%					to 32x32 rather than 64x64, but this can be changed manually.
%


%% Set optional arguments
opts.output = 'imdb.mat' ;
opts.wnids = '' ;
opts.num_classes = 200
opts.resize = false
opts.normalize = false ;

% Taken from generate_CIFAR
opts.contrastNormalization = true ;
opts.whitenData = true ;

opts = vl_argparse(opts, varargin) ;

if ischar(opts.num_classes)
	opts.num_classes = str2num(opts.num_classes);
end

%% Train / validate / test split
if opts.num_classes <= 200 & opts.num_classes >= 1
	train = 500 * opts.num_classes;
	validate = 0;
	test = 50 * opts.num_classes;
else
	disp(['Invalid number of classes passed!'])
	exit
end

%% Check for data and download if necessary
dataDir = fullfile('utils', 'tiny-imagenet-200') ;
if ~exist(dataDir, 'file')
	url = 'http://cs231n.stanford.edu/tiny-imagenet-200.zip' ;
	fprintf('\nDownloading %s...\n', url) ;
	mkdir('.', 'utils') ;
	unzip(url, 'utils') ;
end

% Rename wnids.txt to wnids200.txt for generality purposes
generateDir = pwd;
if ~exist(fullfile(dataDir, 'wnids200.txt'), 'file')
	cd(dataDir)
	system('cp wnids.txt wnids200.txt');
	cd(generateDir)
end

%% Find meta data
if opts.num_classes == 200
	opts.wnids = fullfile('utils', 'tiny-imagenet-200', 'wnids200.txt');
	fileWnids = fopen(opts.wnids)	
elseif ~strcmp(opts.wnids, '')
	fileWnids = fopen(opts.wnids)
else	
	disp(['No wnids file passed!'])
	exit
end

disp(['Generating imdb for ' opts.wnids '...'])

wnids = textscan(fileWnids, '%s') ;
fclose(fileWnids) ;

% imdb.classes.names will be all of the numbers in wnids.txt
imdb.classes.names = wnids{1} ;
imdb.imageDir = dataDir ;

%% Training images
names = {} ;
labels = {} ;
% for every n* in the train folder
for d = dir(fullfile(dataDir, 'train', 'n*'))'
	% if n* in imdb.classes.names add it to labels
    [~,lab] = ismember(d.name, imdb.classes.names) ;
    if lab ~= 0
        ims = dir(fullfile(dataDir, 'train', d.name, 'images', '*.JPEG')) ;
        names{end+1} = strcat(['train', filesep, d.name, filesep, 'images', filesep], {ims.name}) ;
        labels{end+1} = ones(1, numel(ims)) * lab ;
    end
end
names = horzcat(names{:}) ;
labels = horzcat(labels{:}) ;

% Setting image database fields
imdb.images.id = 1:numel(names) ;
imdb.images.name = names ;
imdb.images.set = horzcat(ones(1, train), 2*ones(1, validate)) ;
imdb.images.labels = labels ;

%% Test images (Using validation for testing)
fileValAnnotations = fopen(fullfile(dataDir, 'val', 'val_annotations.txt')) ;
val_annotations = textscan(fileWnids, '%s %s %d %d %d %d') ;
fclose(fileValAnnotations) ;

names = {} ;
labels = {} ;
for i = 1:length(val_annotations{1})
    % If class of validation image in the class names
    [~,lab] = ismember(val_annotations{2}{i}, imdb.classes.names) ;
    if lab ~= 0
        names{end+1} = fullfile('val', 'images', val_annotations{1}{i}) ;
        labels{end+1} = lab ;
    end
end
labels = horzcat(labels{:}) ;

% Setting image database fields
imdb.images.id = horzcat(imdb.images.id, (1:numel(names)) + length(imdb.images.id)) ;
imdb.images.name = horzcat(imdb.images.name, names) ;
imdb.images.set = horzcat(imdb.images.set, 3*ones(1, test)) ;
imdb.images.labels = horzcat(imdb.images.labels, labels) ;

%% Process the data
data = [] ;

fprintf('\nLoading data...\n') ;
for progress = 1:length(imdb.images.name)
    if mod(progress, numel(imdb.images.labels)/10) == 0
        disp(['Processing image ' int2str(progress) ' / ' int2str(numel(imdb.images.labels))]) ;
    end

    path = fullfile(dataDir, imdb.images.name(progress)) ;
    im = imread(char(path)) ;
    im = single(im) ;

    if (size(im, 3) == 1) % if the image is grayscale
        data = cat(4, data, cat(3, im, im, im)) ;
    else % if the image is RGB
        data = cat(4, data, im);
    end
end

% Dividing by max value (255) to make all values in range [0, 1]
if opts.normalize
	imdb.images.data = data / 255 ;
else
	imdb.images.data = data ;
end

% Image scaling
if opts.resize
    disp(['Resizing data by a factor of 0.5'])
	% opts.resize between 0.0 and 1.0 ---> 0.5 would cut from 64x64 to 32x32
	imdb.images.data = imresize(imdb.images.data, 0.5) ;
    sz = [64 64] * 0.5 ;
else
    sz = [64 64] ;
end

% Taken from generate_CIFAR
total = 550 * opts.num_classes;
if opts.contrastNormalization
    disp(['Normalizing data...'])
    z = reshape(imdb.images.data,[], total) ;
    z = bsxfun(@minus, z, mean(z,1)) ;
    n = std(z,0,1) ;
    z = bsxfun(@times, z, mean(n) ./ max(n, 40)) ;
    imdb.images.data = reshape(z, sz(1), sz(2), 3, []) ;
end

if opts.whitenData
    disp(['Whitening data...'])
    z = reshape(imdb.images.data,[], total) ;
    W = z(:,imdb.images.set == 1) * z(:,imdb.images.set == 1)' / total ;
    [V, D] = eig(W) ;
    % the scale is selected to approximately preserve the norm of W
    d2 = diag(D) ;
    en = sqrt(mean(d2)) ;
    z = V * diag(en./max(sqrt(d2), opts.num_classes)) * V' * z ;
    imdb.images.data = reshape(z, sz(1), sz(2), 3, []) ;
end

%% Save out to disk
mkdir('.', 'tiny_imagenet')
disp(['Saving imdb file to ' int2str(num_classes) opts.output '...']) ;
save([int2str(num_classes) opts.output], '-struct', 'imdb', '-v7.3') ;
