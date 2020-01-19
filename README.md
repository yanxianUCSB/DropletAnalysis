# DropletAnalysis
Detect droplets in microscope images using intensity-based segmentation.

## Requirements:
Image Processing Toolbox.
MATLAB 2019a and above.

## Test:
`runtests('test/ImageDataTest.m')`

## Usage:
Make sure your image filename contains 'Brightfield'. Otherwise modify the ImageData.imread function accordingly.

First move your image tif files into folder `folder_in`, and create a directory `folder_out`. Then run the following scripts. 
```
datain = fullfile(getuserdir(),'folder_in');  
dataout= 'folder_out';  
ZeissCoverage(datain, dataout);
```

## Reference:
"To quantify the amount of droplet formed under the given experimental condition of interest, images were taken by a 12-bit CCD camera of an inverted compound microscope, and recorded in TIF format. With illumination and focus optimized, droplets settling on the cover slide have contrast intensity (either darker or brighter) than their surrounding on the images.  Iterative thresholding [1] was used to separate background and foreground. For each image, the area of the droplets was divided by the total area of the image, generating a percent droplet coverage value on the cover slide. Droplets with eccentricity above 0.9 or equivalent diameter below 1μm were filtered out in order to reduce false reading." (https://doi.org/10.1371/journal.pbio.2002183)

[1] “Picture Thresholding Using an Iterative Selection Method.” IEEE Transactions on Systems, Man, and Cybernetics 8, no. 8 (August 1978): 630–32. doi:10.1109/TSMC.1978.4310039.
