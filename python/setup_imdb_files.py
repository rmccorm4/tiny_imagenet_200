from data_utils import load_tiny_imagenet
import numpy as np
from scipy.io import savemat

struct = load_tiny_imagenet('<PATH_TO_TINY_IMAGENET_DATASET>/tiny-imagenet-200')

data = []
for idx, field in enumerate(struct):
    if idx in [1, 3, 5]:
        data.append(np.einsum('lkij->ijkl', field))
    else:
        data.append(field)

matdata = np.concatenate((data[1], data[3]), 3)
matlabels = np.concatenate((data[2], data[4]))
matlabels.reshape((1, 110000))
matlabels = matlabels.reshape((1, 110000))
s = np.ones((1, 110000))
s[:, 90000:100000] = 2
s[:, 100000:110000] = 3
mean = np.mean(matdata, axis=3)
data1 = matdata[:,:,:,:55000]
data2 = matdata[:,:,:,55000:]

### CHECK MEMORY OF DATA ARRAYS ###
# numpy datatypes have attribute 'nbytes'
#data1.nbytes # 2.7GB
#data2.nbytes # 2.7GB

# Can't savemat for dictionaries > 4GB in size, so I broke them up and
# put all of the information together in MatLab (see 'generate_TINY_IMAGENET.m')

# In total there is:
#	Images == slmdict + data1dict + data2dict : set, labels, mean, data
# 	Meta == matmeta : sets, classes 
slmdict = {'set':s, 'labels':matlabels, 'mean':mean} #set, labels, and mean
data1dict = {'data1':data1}
data2dict = {'data2':data2}
matmeta = {'sets': np.asarray([ 'train', 'val', 'test' ]), 'classes': np.array(data[0])}

# Converting to matlab file
# FILES CAN'T BE OVER ~4GB, SO I SAVED THEM SEPARATELY
# See 'generate_TINY_IMAGENET.m' for how to combine the file data
# May need to make 'imdb_files' directory or just change path
savemat('imdb_files/imdb_set_labels_mean', slmdict)
savemat('imdb_files/imdb_data1', data1dict)
savemat('imdb_files/imdb_data2', data2dict)
savemat('imdb_files/imdb_meta', matmeta)
