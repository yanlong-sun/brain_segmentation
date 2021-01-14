import cv2
from imgaug import augmenters as iaa

seq = iss.Sequential(
    [

    ]
)

unaug_training_image_path = './data/train/'
aug_training_image_path = './data/aug_train/'
imgs_train, imgs_mask_train, names = load_data(unaug_train_images_path)
aug_imgs_train = seq.augment_images(imgs_train)
aug_imgs_mask_train = seq.augment_images(imgs_mask_train)
c = 1
for each in aug_imgs_mask_train:
    cv2.imwrite(aug_training_image_path, '')


