clc;
clear;

mat = load('../predictions/1663535/predictions.mat');

%% Pred Part
name = mat.name;
image = mat.image;
pred = mat.pred;





%% Original Image Part
test_data_tif_path = './data/test/';     
slicedirOutput=dir(test_data_tif_path);
slicefileNames={slicedirOutput.name};
for i = 4: length(slicefileNames)
    slices_case_name = char(string(slicefileNames(i)));  
    slices_dir_path = [test_data_tif_path, slices_case_name, '/'];
    slices_list = dir(strcat(slices_dir_path,'*.tif'));

    slices = imread([slices_dir_path, slices_list(1).name(1:13),'.tif']);
    slices = imcrop(slices, [1,64,255,127]);
    
    for j = 3 : 2 : length(slices_list)
        single_slice = imread([slices_dir_path, slices_list(j).name(1:13),'.tif']);
        single_slice = imcrop(single_slice, [1, 64, 255, 127]);
        slices = cat(3, slices, single_slice);
    end
end

%% 


v_orig = load_nii('../test_data_nii/1663535.nii.gz');
v2 = v_orig;
v3 = v_orig;
v2.img = slices;
v3.img = pred_final;
save_nii(v2, '../predictions/1663535/image.nii');
save_nii(v3, '../predictions/1663535/pred.nii');

