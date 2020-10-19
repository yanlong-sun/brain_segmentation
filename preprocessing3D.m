function [ slices, mask] = preprocessing3D( slices, mask, destination_path, prefix )
%PREPROCESSING3D Implements preprocessing of a 3D volume containing slices 
%of a FLAIR modality together with its segmentation mask. Needs a path to 
%the folder (string) where you want to save the result and a filename 
%prefix (string) to which a slice number is appended. The images will be 
%saved in tiff format.
%
%Examples:
%
%   Basic usecase:
%
%       [slices, mask] = preprocessing3D(slices, mask, '/media/username/data/train/', 'patient_001');
%   
%   If you don't have a segmentation mask and want to preprocess test 
%   images for inference, pass a zeros matrix instead:
%
%       [slices, mask] = preprocessing3D(slices, zeros(size(slices)), '/media/username/data/train/', 'patient_001');


    slices = double(slices);
    
    mask(mask ~= 0) = 1;

    % fill holes in segmentation mask
    for s = 1:size(mask, 3)
        mask(:, :, s) = imfill(mask(:, :, s), 'holes');
    end

    % fix the rage of pixel values after bicubic interpolation
    slices(slices < 0) = 0;

    
    
    minimum = 2;
    maximum = 149.9;
    slices(slices < minimum) = minimum;
    slices(slices > maximum) = maximum;
    slices = (slices - minimum) ./ (maximum - minimum);

    
    
    
    
    
    % save preprocessed images
    slices = im2uint8(slices);
    mask = 255 * (mask);

    
    % resize to have smaller dimension equal 256 pixels
    if min(size(slices(:, :, 1))) ~= 256

        scale = 256 / max(size(slices(:,:,1)));
        % resize images to 256 with bicubic interpolation
        slices = imresize(slices, scale);
        % and mask with NN interpolation
        mask = imresize(mask, scale, 'method', 'nearest');

    end

    % center crop to 256x256 square
    slices = center_crop(slices, [256 256]);
    mask = center_crop(mask, [256 256]);
    
      
    
    
    slicesPerImage = 1;
    slice_number_long = 10000;
    for s = size(slices, 3):-slicesPerImage:1
        startSlice = max([1, (s - slicesPerImage + 1)]);
        imageSlices = slices(:, :, startSlice:(startSlice + slicesPerImage - 1));
        maskSlices = mask(:, :, startSlice:(startSlice + slicesPerImage - 1));
        
        figure(3)
        imshow(imageSlices)
        
        saveastiff(imageSlices, [destination_path prefix '_' num2str(slice_number_long + startSlice) '.tif']);
        saveastiff(maskSlices, [destination_path prefix '_' num2str(slice_number_long + startSlice) '_mask.tif']);
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

    