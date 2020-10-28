clc;
clear;

prediction_path = '../predictions/';
%test_data_tif_path = '../test_data_tif/';
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
    mask = mat.mask;
    pred_nii = make_nii(pred);   % this nii file has the wrong head
    pred_nii_img = pred_nii.img;
    
    mask_nii = make_nii(mask);
    mask_nii_img = mask_nii.img;
    
    [n1,n2,n3] = size(pred_nii_img);
    slice_number_long = 10000;
    for j = 1 : n1
        pred_img(:, :, j) = pred_nii_img(j, :, :);
        mask_img(:, :, j) = mask_nii_img(j, :, :);
        if j == 1
            preds = mat2gray(pred_img(:, :, j));
            masks = mat2gray(mask_img(:, :, j));
        else
            single_pred = mat2gray(pred_img(:, :, j));
            single_mask = mat2gray(mask_img(:, :, j));
            imshow(single_pred)
            preds = cat(3, preds, single_pred);
            masks = cat(3, masks, single_mask);
        end
    end


    %% SAVE part
    v_orig = load_nii(['../test_data/slices/', case_name, '.nii.gz']);
    v2 = v_orig;
    v3 = v_orig;
    v4 = v_orig;
    [a1, a2, a3] = size(slices);
    v2.hdr.dime.dim = [3, a1, a2, a3, 1, 1, 1, 1];
    v3.hdr.dime.dim = [3, a1, a2, a3, 1, 1, 1, 1];
    v4.hdr.dime.dim = [3, a1, a2, a3, 1, 1, 1, 1];
    
    slices = get_original_size(slices, a1, a2, a3);
    preds = get_original_size(preds, a1, a2, a3);
    masks = get_original_size(masks, a1, a2, a3);
    v2.img = slices;
    v3.img = preds;
    v4.img = masks;
    
    save_nii(v2, [prediction_path, case_name, '/', case_name, '_image.nii']);
    save_nii(v3, [prediction_path, case_name, '/', case_name, '_pred.nii']);
    save_nii(v4, [prediction_path, case_name, '/', case_name, '_mask.nii']);

end

function [ image ] = get_original_size(image, a1, a2, a3)
    num_pad_n1 = 256-n1;
    num_pad_n2 = 256-n2; 
    
    num_pad_n1_half = round(num_pad_n1/2);
    num_pad_n2_half = round(num_pad_n2/2);
    
    if and(n1<256, n2<256)
        image = padarray(image, [num_pad_n1_half, 0], 'pre');
        image = padarray(image, [num_pad_n1 - num_pad_n1_half, 0 ], 'post');
        image = padarray(image, [0, num_pad_n2_half], 'pre');  
        image = padarray(image, [0, num_pad_n2 - num_pad_n2_half], 'post'); 
    end
    
    if and(n1<256, n2>=256)
        image = padarray(image, [num_pad_n1_half, 0 ], 'pre');
        image = padarray(image, [num_pad_n1 - num_pad_n1_half, 0 ], 'post');  
    end
    
    if and(n1>=256, n2<256)
        image = padarray(image, [0, num_pad_n2_half], 'pre');  
        image = padarray(image, [0, num_pad_n2 - num_pad_n2_half], 'post');  
    end

    image_size = size(image);
    if or(image_size(1)>256, image_size(2)>256)
        win1 = centerCropWindow3d(size(image), [256,256, n3]);
        image = imcrop3(image, win1);  
    end

end



