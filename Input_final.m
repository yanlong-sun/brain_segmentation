clc;
clear;

test_data_slices_nii_path = '../test_tr_data/slices/';
test_data_masks_nii_path = '../test_tr_data/masks/';

test_data_slices_tif_path = '../test_tr_tif/slices_tif/';
test_data_masks_tif_path = '../test_tr_tif/masks_tif/';

destination_path = './data/test_model/';

slice_number_long = 10000;

slices_nii_folder=dir(test_data_slices_nii_path);
slices_nii_file={slices_nii_folder.name};

% Traverse all .nii.gz file
for num_nii = 4 : length(slices_nii_file)
    
    case_name = slices_nii_file(num_nii);
    case_name = char(case_name);
    case_name = case_name(1 : end-7);
    
    finishing = [num2str(num_nii-3),'/',num2str(length(slices_nii_file)-3)];
    disp(finishing)
    disp(case_name)
    
    v_slices = load_untouch_nii([test_data_slices_nii_path, case_name, '.nii.gz']);  
    v_masks = load_untouch_nii([test_data_masks_nii_path, case_name, '.manual.mask.nii.gz']);
    mkdir(test_data_slices_tif_path, case_name);  
    mkdir(test_data_masks_tif_path, case_name); 
    slices_tif = v_slices.img;
    masks_tif = v_masks.img;
    [n1,n2,n3] = size(slices_tif);
%% Save as tiff
    for i = 1 : n3 
        slices_save_path = [test_data_slices_tif_path, case_name,'/' case_name,'_', num2str(slice_number_long + i), '.tif'];
        masks_save_path = [test_data_masks_tif_path, case_name,'/' case_name,'_', num2str(slice_number_long + i), '.tif'];
        saveastiff(im2uint8(rescale(slices_tif(:,:,i), 0, 1)), slices_save_path);
        saveastiff(im2uint8(rescale(masks_tif(:,:,i), 0, 1)), masks_save_path);
        if i == 1
            slices = imread(slices_save_path);
            masks = imread(masks_save_path);
        else
            single_slice = imread(slices_save_path);
            single_mask = imread(masks_save_path);
            slices = cat(3, slices, single_slice); 
            masks = cat(3, masks, single_mask);
        end
    end
%% classify into two categories(1)    
    if max(max(max(slices_tif))) > 1220
        [slices_preprocessed, mask_preprocessed] = preprocessing3D(slices, masks, destination_path, case_name);
        
%% classify into two categories(2)
    else
        slices = double(slices);
        % fix the rage of pixel values after bicubic interpolation
        slices(slices < 0) = 0;

        % get histogram of an image volume
        [N, edges] = histcounts(slices(:), 'BinWidth', 2);

        % rescale the intensity peak to be at value 100
        minimum = edges(find(edges > prctile(slices(:), 2), 1));

        diffN = zeros(size(N));
        for nn = 2:numel(N)
            diffN(nn) = N(nn) / N(nn - 1);
        end
        s = find(edges >= prctile(slices(:), 50), 1);
        f = find(diffN(s:end) > 1.0, 5);
        start = s + f(5);

        [~, ind] = max(N(start:end));
        peak_val = edges(ind + start - 1);
        maximum = minimum + ((peak_val - minimum) * 2.55);

        slices = rescale(slices, minimum, maximum);
        slices = slices / 255;
%         slices(slices < minimum) = minimum;
%         slices(slices > maximum) = maximum;
%         slices = (slices - minimum) ./ (maximum - minimum);
        [slices_preprocessed, mask_preprocessed] = preprocessing3D(slices, masks, destination_path, case_name);  
    end 
end