clc;
clear;

mat = load('../predictions/predictions.mat');

name = mat.name;
name_size = size(name);
name_num = zeros(1, name_size(1));
for j = 1 : name_size(1)
    name_num(j) = str2double(name(j, 9:11));
end

pred = mat.pred;
image = mat.image;
mask = mat.mask;


pred_sorted  = zeros(153, 256, 256);
image_sorted = zeros(153, 256, 256, 3);
mask_sorted = zeros(153, 256, 256);

[name_sorted, index] = sort(name_num);

for i = 1 : length(index)
    pred_sorted(i, :, :) = pred(index(i), :, :);
    image_sorted(i, :, :, :) = image(index(i), :, :, :);
    mask_sorted(i, :, :) = mask(index(i), :, :);
    
%     image_sorted(i, :, :, 1) = image_sorted(i, :, :, 1) .* pred_sorted(i, :, :);
%     image_sorted(i, :, :, 2) = image_sorted(i, :, :, 2) .* pred_sorted(i, :, :);
%     image_sorted(i, :, :, 3) = image_sorted(i, :, :, 3) .* pred_sorted(i, :, :);
end





pred_nii = make_nii(pred_sorted);
image_nii = make_nii(image_sorted);
mask_nii = make_nii(mask_sorted);

save_nii(pred_nii, '../nii/pred.nii')
save_nii(image_nii, '../nii/image.nii')
save_nii(mask_nii, '../nii/mask.nii')

