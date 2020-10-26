clc;
clear;

test_data_slices_nii_path = './data/nii_data/slices/';
test_data_masks_nii_path = './data/nii_data/masks/';

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
    slices_tif = v_slices.img;
    masks_tif = v_masks.img;
    [n1,n2,n3] = size(slices_tif);
%% Save as tiff
    for i = 1 : n3 
        if i == 1
            slices = im2uint8(rescale(slices_tif(:,:,1), 0, 1));
            masks = im2uint8(rescale(masks_tif(:,:,1), 0, 1));
        else
            single_slice = im2uint8(rescale(slices_tif(:,:,i), 0, 1));
            single_mask = im2uint8(rescale(masks_tif(:,:,i), 0, 1));
            slices = cat(3, slices, single_slice); 
            masks = cat(3, masks, single_mask);
        end
    end
    
%% 
    %destination_path = './data/test_model/';    % Get statistical results
    destination_path = ['./data/test/', case_name, '/'];
     
%% classify into two categories    
    if max(max(max(slices_tif))) > 1220
        [slices_preprocessed, mask_preprocessed] = preprocessing_high(slices, masks, destination_path, case_name);
    else       
        [slices_preprocessed, mask_preprocessed] = preprocessing(slices_tif, masks, destination_path, case_name);  
    end 
end


%% functions
function [ slices, mask] = preprocessing_high( slices, mask, destination_path, prefix )      
    [slices, mask] = get_proper_size(slices, mask);
    save_preprocessed_images(slices, mask, destination_path, prefix );
end

function [ slices, mask] = preprocessing( slices, mask, destination_path, prefix )      
    [slices, mask] = get_proper_size(slices, mask);
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

    slices(slices < minimum) = minimum;
    slices(slices > maximum) = maximum;
    slices = (slices - minimum) ./ (maximum - minimum);
    
    save_preprocessed_images(slices, mask, destination_path, prefix );
end

function [slices, mask] = get_proper_size(slices, mask)
    mask(mask ~= 0) = 1;
    if min(size(slices(:, :, 1))) ~= 256
        scale = 256 / max(size(slices(:,:,1)));
        slices = imresize(slices, scale);
        mask = imresize(mask, scale, 'method', 'nearest');
    end  
    for s = 1:size(mask, 3)
        mask(:, :, s) = imfill(mask(:, :, s), 'holes');
    end
end


function [] = save_preprocessed_images(slices, mask, destination_path, prefix )

% center crop to 256x256 square
    slices = center_crop(slices, [256 256]);
    mask = center_crop(mask, [256 256]);
% save preprocessed images
    slices = im2uint8(slices);
    mask = 255 * (mask);      
    slicesPerImage = 1;
    easy_sort = 10000;
    for s = size(slices, 3):-slicesPerImage:1
        startSlice = max([1, (s - slicesPerImage + 1)]);
        imageSlices = slices(:, :, startSlice:(startSlice + slicesPerImage - 1));
        maskSlices = mask(:, :, startSlice:(startSlice + slicesPerImage - 1));
        
        figure(1)
        imshow(imageSlices)
        
        saveastiff(imageSlices, [destination_path prefix '_' num2str(easy_sort + startSlice) '.tif']);
        saveastiff(maskSlices, [destination_path prefix '_' num2str(easy_sort + startSlice) '_mask.tif']);
    end

end


function [ image ] = center_crop( image, cropSize )
%CENTER_CROP Center crop of given size
    image_size = size(image);
    if image_size(1) > image_size(2)+60
        image = padarray(image,[0,80],'post');
        image = padarray(image,[0,80],'pre');
    end
    
    if and(image_size(2) < image_size(1)+60, image_size(2) > image_size(1))
        image = padarray(image,[50,0],'post');
        image = padarray(image,[50,0],'pre');
    end
    
    if and(image_size(1) < image_size(2)+60, image_size(1) > image_size(2))
        image = padarray(image,[0,50],'post');
        image = padarray(image,[0,50],'pre');
    end
    
    if image_size(2) > image_size(1)+60
        image = padarray(image,[80,8],'post');
        image = padarray(image,[80,8],'pre');     
    end   
    [p3, p4, ~] = size(image);
    i3_start = max(1, floor((p3 - cropSize(1)) / 2));
    i3_stop = i3_start + cropSize(1) - 1;
    i4_start = max(1, floor((p4 - cropSize(2)) / 2));
    i4_stop = i4_start + cropSize(2) - 1;
    image = image(i3_start:i3_stop, i4_start:i4_stop, :);

end

