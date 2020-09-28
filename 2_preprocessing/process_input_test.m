clc;
clear;

test_data_tif_path = '../../test_data_tif/';     

slicedirOutput=dir(test_data_tif_path);
slicefileNames={slicedirOutput.name};


for i = 3: length(slicefileNames)
    slices_case_name = char(string(slicefileNames(i)));  
    slices_dir_path = [test_data_tif_path, slices_case_name, '/'];
    slices_list = dir(strcat(slices_dir_path,'*.tif')); 

    slices = imread([slices_dir_path, slices_list(1).name]);
    for j = 2 : length(slices_list)
        single_slice = imread([slices_dir_path, slices_list(j).name]);
        slices = cat(3, slices, single_slice);
    end
end
   
destination_path = ['../data/test/', slices_case_name, '/'];
[slices_preprocessed, mask_preprocessed] = preprocessing3D(slices, zeros(size(slices)), destination_path, slices_case_name);
