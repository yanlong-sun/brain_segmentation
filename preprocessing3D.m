function [ slices, mask] = preprocessing3D( slices, mask, destination_path, prefix )   


    mask(mask ~= 0) = 1;

    % resize to have smaller dimension equal 256 pixels
    if min(size(slices(:, :, 1))) ~= 256

        scale = 256 / max(size(slices(:,:,1)));
        % resize images to 256 with bicubic interpolation
        slices = imresize(slices, scale);
        % and mask with NN interpolation
        mask = imresize(mask, scale, 'method', 'nearest');

    end
    
     % fill holes in segmentation mask   
    for s = 1:size(mask, 3)
        mask(:, :, s) = imfill(mask(:, :, s), 'holes');
    end
 
    % center crop to 256x256 square
    slices = center_crop(slices, [256 256]);
    mask = center_crop(mask, [256 256]);
    
    % save preprocessed images
    slices = im2uint8(slices);
    mask = 255 * (mask);  
    
    
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