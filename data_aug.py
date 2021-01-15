import shutil
from imgaug import augmenters as iaa
from imgaug.augmentables.segmaps import SegmentationMapsOnImage
from skimage.io import imread
from imageio import imwrite
import os
import numpy as np


def data_aug():
    seq = iaa.SomeOf(4, [
            iaa.Crop(px=(0, 16)),  # crop images from each side by 0 to 16px (randomly chosen)
            iaa.Fliplr(0.5),  # horizontally flip 50% of the images
            iaa.Affine(rotate=(-25, 25)),
            iaa.AdditiveGaussianNoise(scale=(10, 60)),
            iaa.GaussianBlur(sigma=(0, 3.0)),  # blur images with a sigma of 0 to 3.0
            iaa.LinearContrast((0.4, 1.6)),
            iaa.GammaContrast((0.5, 2.0)),
            iaa.ElasticTransformation(alpha=50, sigma=5)
        ], random_order=True
    )
    n = 4
    training_image_path = './data/train/'
    images_list = os.listdir(training_image_path)
    for image_name in images_list:
        if 'mask' in image_name:
            continue
        elif 'tif' in image_name:
            unaug_slice = imread(training_image_path + image_name)
            unaug_mask = np.bool_(imread(training_image_path + image_name.split('.')[0] + '_mask.tif'))
            unaug_mask = SegmentationMapsOnImage(unaug_mask, shape=unaug_slice.shape)

            for i in range(n):
                aug_slice, aug_mask = seq(image=unaug_slice, segmentation_maps=unaug_mask)
                aug_mask = aug_mask.draw(size=aug_slice.shape[:2])[0]
                slice_path = training_image_path + image_name.split('.')[0] + str(100+i) + '.tif'
                mask_path = training_image_path + image_name.split('.')[0] + str(100+i) + '_mask.tif'
                imwrite(slice_path, aug_slice)
                imwrite(mask_path, aug_mask)

if __name__ == '__main__':
    data_aug()
