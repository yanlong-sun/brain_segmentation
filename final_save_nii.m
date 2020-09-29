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

pred_sorted  = zeros(size(pred));
image_sorted = zeros(size(image));

[name_sorted, index] = sort(name_num);

for i = 1 : length(index)
    pred_sorted(i, :, :) = pred(index(i), :, :);
end


test_data_tif_path = './data/test/';     

slicedirOutput=dir(test_data_tif_path);
slicefileNames={slicedirOutput.name};
for i = 3: length(slicefileNames)
    slices_case_name = char(string(slicefileNames(i)));  
    slices_dir_path = [test_data_tif_path, slices_case_name, '/'];
    slices_list = dir(strcat(slices_dir_path,'*.tif')); 

    slices = imread([slices_dir_path, slices_list(index(1)).name]);
    slices = imcrop(slices, [1,64,255,127]);
    
    for j = 2 : length(index)
        single_slice = imread([slices_dir_path, slices_list(index(j)).name]);
        single_slice = imcrop(single_slice, [1, 64, 255, 127]);
        slices = cat(3, slices, single_slice);
    end
end




v_orig = load_nii('../test_data_nii/1663535.nii.gz');
v2 = v_orig;
v3 = v_orig;
v2.img = slices;
v3.img = pred_sorted;
save_nii(v2, '../predictions/1663535/image.nii');
save_nii(v3, '../predictions/1663535/pred.nii');

