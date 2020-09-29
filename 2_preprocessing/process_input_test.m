clc;
clear;

test_data_tif_path = '../../test_data_tif/';     

slicedirOutput=dir(test_data_tif_path);
slicefileNames={slicedirOutput.name};

mat = load('../../predictions/1663535/predictions.mat');
name = mat.name;
name_size = size(name);
name_num = zeros(1, name_size(1));
for j = 1 : name_size(1)
    name_num(j) = str2double(name(j, 9:11));
end
[name_sorted, index] = sort(name_num);

for i = 4: length(slicefileNames)
    slices_case_name = char(string(slicefileNames(i)));  
    slices_dir_path = [test_data_tif_path, slices_case_name, '/'];
    slices_list = dir(strcat(slices_dir_path,'*.tif')); 

    slices = imread([slices_dir_path, slices_list(index(1)).name]);
    
    for j = 2 : length(index)
        single_slice = imread([slices_dir_path, slices_list(index(j)).name]);
        slices = cat(3, slices, single_slice);
    end
end
   
destination_path = ['../data/test/', slices_case_name, '/'];
[slices_preprocessed, mask_preprocessed] = preprocessing3D(slices, zeros(size(slices)), destination_path, slices_case_name);
