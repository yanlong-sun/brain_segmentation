clc;
clear;

mat = load('../predictions/1663535/predictions.mat');

name = mat.name;
name_size = size(name);
name_num = zeros(1, name_size(1));
for j = 1 : name_size(1)
    name_num(j) = str2double(name(j, 9:11));
end

pred = mat.pred;
image = mat.image;
mask = mat.mask;

pred_sorted  = zeros(size(pred));
image_sorted = zeros(size(image));
%mask_sorted = zeros(size(mask));

[name_sorted, index] = sort(name_num);

for i = 1 : length(index)
    pred_sorted(i, :, :) = pred(index(i), :, :);
    image_sorted(i, :, :, :) = image(index(i), :, :, :);
    %mask_sorted(i, :, :) = mask(index(i), :, :);
end

v_orig = load_nii('../test_data_nii/1663535.nii.gz');
v2 = v_orig;
v3 = v_orig;
v2.img = image;
v3.img = pred;
save_nii(v2, '../predictions/1663535/image.nii');
save_nii(v3, '../predictions/1663535/pred.nii');

