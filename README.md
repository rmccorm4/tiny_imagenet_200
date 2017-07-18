# tiny_imagenet_200
This is a conglomeration of useful scripts and tools I've created
for processing tiny-imagenet-200 in its entirety, or creating any
number of smaller class subsets for training purposes.

They're definitely not perfect but I tried to make them as general
as possible, feel free to let me know if anything doesn't work or
if you have questions about anything.

I am most proud of produce_files.sh and generate_TINY_IMAGENET.m
which together can create any number of class subsets and generate
imdb files on them for training in a somewhat organized fashion.

For example, if training on 200 classes doesn't give you satisfactory
accuracy since there are only 500 training and 50 validation images per
class, you might want to do 10 class or 15 class subsets, and this
is what produce_files.sh is for.

Most of the scripts can be found in datasets/utils/tiny-imagenet-200/scripts.
This path structure is just because this is part of my summer work and
didn't want to spend too much time reorganizing the paths for this repo.
