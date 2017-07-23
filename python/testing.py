import numpy as np
from data_utils import load_tiny_imagenet
import numpy as np, matplotlib.pyplot as plt

struct = load_tiny_imagenet('../utils/tiny-imagenet-200/')
train = struct[1]
image = train[0, :, :, :]

image = np.einsum('kij->ijk', image)

plt.imshow(image)
plt.show()
