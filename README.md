# brain_segmentation

Step_1:  convert .nii.gz format to .tif
		'python 1_nii_to_tif.py  ../test_data_nii  ../test_data_tif'

Step_2:  preprocessing the slices (For testing)
		run 'process_input_test.m'

Step_3:  prediction(I haven't amended the code to prediction a bunch of volumes, so I need to change the 'test_image_path' to the specific path in 'data.py' )
		'python test.py'

Step_4:  convert .mat format to .nii


		
		
* training on  "CC-359"      CC0001 - CC0030
