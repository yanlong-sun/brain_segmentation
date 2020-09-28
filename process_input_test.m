clc;
clear;

% sliceFolder = fullfile('./test_raw_data/');
% slicedirOutput=dir(fullfile(sliceFolder));
% slicefileNames={slicedirOutput.name};
% slices_case_name = char(slicefileNames);  

slices_case_name = '2523412';
%slices_dir_path = ['./test_raw_data/',slices_case_name, '/'];
slices_dir_path = ['./test_raw_data/'];
slices_list = dir(strcat(slices_dir_path,'*.tif')); 

slices = imread([slices_dir_path, slices_list(1).name]);
    
    
for i = 2 : length(slices_list)
	single_slice = imread([slices_dir_path, slices_list(i).name]);
	slices = cat(3, slices, single_slice);
end
    
destination_path = '../DR_Project/data/test/';
[slices_preprocessed, mask_preprocessed] = preprocessing3D(slices, zeros(size(slices)), destination_path, slices_case_name);
