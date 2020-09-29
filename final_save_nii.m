clc;
clear;

mat = load('../predictions/1663535/predictions.mat');

%% Pred Part
pred = mat.pred;
pred_nii = make_nii(pred);
pred_img2 = pred_nii.img;
[n1,n2,n3] = size(pred_img2);
pred_img = zeros(size(pred_img2));

slice_number_long = 10000;
for j = 1 : n1
    pred_img(:, :, j) = pred_img2(j, :, :);
    save_path = ['../predictions/1663535/test/', num2str(slice_number_long + i), '.png'];
    imwrite(pred_img( :,:, j), save_path);
    if j == 1
        preds = imread(save_path);
        preds = imcrop(preds, [1, 64, 255, 127]);
    end
    single_pred = imread(save_path);
    single_pred = imcrop(single_pred, [1, 64, 255, 127]);
    imshow(single_pred)
    preds = cat(3, preds, single_pred);
end

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

%% 


v_orig = load_nii('../test_data_nii/1663535.nii.gz');
v2 = v_orig;
v3 = v_orig;
v2.img = slices;
v3.img = preds;
save_nii(v2, '../predictions/1663535/image.nii');
save_nii(v3, '../predictions/1663535/pred.nii');

