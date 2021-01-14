import cv2
from imgaug import augmenters as iaa
from data import *
def data_aug():
    seq = iaa.Sequential(
        [
            iaa.AdditiveGaussianNoise(loc=0, scale=(0.0, 0.05*255), per_channel=0.5),
            iaa.Sharpen(alpha=(0, 0.3), lightness=(0.9, 1.1))
        ]
    )

    unaug_training_image_path = './data/train/'
    aug_training_image_path = './data/aug_train/'
    imgs_train, imgs_mask_train, names = load_data(unaug_training_image_path)
    aug_imgs_train = seq.augment_images(imgs_train)
    aug_imgs_mask_train = seq.augment_images(imgs_mask_train)
    b, c = 1, 1
    for each in aug_imgs_train:
        cv2.imwrite(aug_training_image_path, '%s_mask.tif', b, each)
        b += 1
    for each in aug_imgs_mask_train:
        cv2.imwrite(aug_training_image_path, '%s.tif', c, each)
        c += 1

if __name__ == '__main__':
    data_aug()
