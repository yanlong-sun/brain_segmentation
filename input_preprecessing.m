clc;
clear;

test_data_nii_path = '../test_data_nii/';
test_data_tif_path = '../test_data_tif/';

slice_number_long = 10000;

nii_folder=dir(test_data_nii_path);
nii_file={nii_folder.name};

for num_nii = 4 : length(nii_file)
    case_name = nii_file(num_nii);
    case_name = char(case_name);
    case_name = case_name(1 : end-7);    

    v_orig = load_nii([test_data_nii_path, case_name, '.nii.gz']);    
    mkdir(test_data_tif_path, case_name);
    
    v = v_orig.img;
    [n1,n2,n3] = size(v); 
    for i = 1 : n3
        save_path = [test_data_tif_path, case_name,'/' case_name,'_', num2str(slice_number_long + i), '.tif'];
        imwrite(uint16(v(:,:,i)), save_path);
        if i == 1
            slices = imread(save_path);
        else
            single_slice = imread(save_path);
            figure(3)
            imshow(uint8(single_slice))
            slices = cat(3, slices, single_slice);     
        end   
    end

    destination_path = ['./data/test/', case_name, '/'];
    [slices_preprocessed, mask_preprocessed] = preprocessing3D(slices, zeros(size(slices)), destination_path, case_name);
end