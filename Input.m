clc;
clear;

test_data_slices_nii_path = '../test_tr_data/slices/';
test_data_masks_nii_path = '../test_tr_data/masks/';

test_data_slices_tif_path = '../test_tr_tif/slices_tif/';
test_data_masks_tif_path = '../test_tr_tif/masks_tif/';

slice_number_long = 10000;

slices_nii_folder=dir(test_data_slices_nii_path);
slices_nii_file={slices_nii_folder.name};


for num_nii = 4 : length(slices_nii_file)
    case_name = slices_nii_file(num_nii);
    case_name = char(case_name);
    case_name = case_name(1 : end-7);
    finishing = [num2str(num_nii-3),'/',num2str(length(slices_nii_file)-3)];
    disp(finishing)
    disp(case_name)
    v_slices = load_untouch_nii([test_data_slices_nii_path, case_name, '.nii.gz']);  
    v_masks = load_untouch_nii([test_data_masks_nii_path, case_name, '.manual.mask.nii.gz']);
    slices = v_slices.img;
    masks = v_masks.img;   
    
   
    destination_path = './data/test_model/';
    [slices_preprocessed, mask_preprocessed] = preprocessing(slices, masks, destination_path, case_name);
end
