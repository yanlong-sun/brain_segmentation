clc;
clear;

prediction_path = '../predictions/';
test_data_tif_path = '../test_data_tif/';
pred_folder= dir(prediction_path);
pred_file={pred_folder.name};

for num_pred= 4 : length(pred_file)
    case_name = pred_file(num_pred);
    case_name = char(case_name);
    mat = load([prediction_path, case_name, '/predictions.mat']);
    
    %% Image Part
    test_data_path = ['./data/test/',case_name, '/']; 
    slice_dirOutput=dir(test_data_path);
    slice_fileNames={slice_dirOutput.name};
    first_slice_path = ['./data/test/',case_name, '/', case_name,'_', num2str(10001), '.tif' ];
    slices = imread(first_slice_path);
    for i = 2 : (length(slice_fileNames)-2)/2
        single_slice_path = ['./data/test/',case_name, '/',case_name,'_', num2str(10000+i), '.tif' ];
        single_slice = imread(single_slice_path);
        figure(4)
        imshow(single_slice)
        slices = cat(3, slices, single_slice);
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
        end
        single_pred = mat2gray(pred_img(:, :, j));
        imshow(single_pred)
        preds = cat(3, preds, single_pred);
    end


    %% SAVE part
    v_orig = load_nii(['../test_data_nii/', case_name, '.nii.gz']);
    v2 = v_orig;
    v3 = v_orig;
    [a1, a2, a3] = size(slices);
    v2.hdr.dime.dim = [3, a1, a2, a3, 1, 1, 1, 1];
    v3.hdr.dime.dim = [3, a1, a2, a3, 1, 1, 1, 1];
    v2.img = slices;
    v3.img = preds;
    save_nii(v2, [prediction_path, case_name, '/', case_name, '_image.nii']);
    save_nii(v3, [prediction_path, case_name, '/', case_name, '_pred.nii']);

end
