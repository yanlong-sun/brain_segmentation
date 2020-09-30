clc;
clear;

v_orig = load_nii('../../test_data_nii/1663535.nii.gz');
test_data_tif_path = '../../test_data_tif/'; 

slice_number_long = 10000;
v = v_orig.img;
[n1,n2,n3] = size(v); 
for i = 1 : n3
    save_path = [test_data_tif_path, '1663535/', '1663535_', num2str(slice_number_long + i), '.tif'];
    imwrite(v(:,:,i), save_path);
end

    
slicedirOutput=dir(test_data_tif_path);
slicefileNames={slicedirOutput.name};

% 'cat' all sorted slices into one volume
for i = 4: length(slicefileNames)
    slices_case_name = char(string(slicefileNames(i)));  
    slices_dir_path = [test_data_tif_path, slices_case_name, '/'];
    slices_list = dir(strcat(slices_dir_path,'*.tif')); 
    slices = imread([slices_dir_path, slices_list(i).name]);
    
    for j = 2 : length(slices_list)
        single_slice = imread([slices_dir_path, slices_list(j).name]);
        slices = cat(3, slices, single_slice);
    end
end
   
destination_path = ['../data/test/', slices_case_name, '/'];
[slices_preprocessed, mask_preprocessed] = preprocessing3D(slices, zeros(size(slices)), destination_path, slices_case_name);
