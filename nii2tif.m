clc;
clear;
v_orig = load_nii('../test_data_nii/1663535.nii.gz');
v = v_orig.img;
[n1,n2,n3] = size(v); 
for i = 1 : n3
    save_path = ['../test_data_tif/test1/', '1663535_', num2str(i), '.tif'];
    imshow(v(:,:,i),[])
    imwrite(v(:,:,i), save_path);
end
