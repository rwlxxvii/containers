```python

import deeplake

dataset_path = 'hub://activeloop/visdrone-det-train'
ds = deeplake.load(dataset_path) # Returns a Deep Lake Dataset but does not download data locally

# Indexing
image = ds.images[0].numpy() # Fetch the first image and return a numpy array
labels = ds.labels[0].data() # Fetch the labels in the first image

# Slicing
img_list = ds.labels[0:100].numpy(aslist=True) # Fetch 100 labels and store 
                                               # them as a list of numpy arrays

labels_list = ds.labels.info['class_names']

ds.summary()
ds.visualize()

```
