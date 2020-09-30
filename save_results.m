clc;
clear;

mat = load('../predictions/1663535/predictions.mat');


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
        imshow(single_slice)
        slices = cat(3, slices, single_slice);
    end
end

%% Pred Part
pred = mat.pred;
pred_nii = make_nii(pred);   % this nii file has the wrong head
pred_nii_img = pred_nii.img;
[n1,n2,n3] = size(pred_nii_img);
slice_number_long = 10000;
for j = 1 : n1
    pred_img(:, :, j) = pred_nii_img(j, :, :);
    if j == 1
        preds = mat2gray(pred_img(:, :, j));
        imshow(preds)
        preds = imcrop(preds, [1, 64, 255, 127]);
    end
    single_pred = mat2gray(pred_img(:, :, j));
    single_pred = imcrop(single_pred, [1, 64, 255, 127]);
    imshow(single_pred)
    preds = cat(3, preds, single_pred);
end


%% SAVE part
v_orig = load_nii('../test_data_nii/1663535.nii.gz');
v2 = v_orig;
v3 = v_orig;
v2.img = slices;
v3.img = preds;
save_nii(v2, '../predictions/1663535/image.nii');
save_nii(v3, '../predictions/1663535/pred.nii');

