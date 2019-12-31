classdef DropletTest < matlab.unittest.TestCase
% Test cases for droplet analysis

    methods (Test)
        function testTifReadIn(testCase)
            % test tiff data readin
            actSolution = 1;
            expSolution = 1;
            testCase.verifyEqual(actSolution, expSolution);
        end
        
        function dtestGetTifData(tc)
           filename = 'testin/untitled1.tif';
           tifData = getTifData(filename);
           tc.verifyClass(tifData.imageData, 'uint16');
           tc.verifyEqual(tifData.numFrames, 1);
        end
        
        function testDropletAnalyzer(tc)
            %%
            filepath = 'testin/2N4R-1/Pos0/img_000000000_Brightfield_000.tif';
            imagedata = ImageData(filepath);
            da = DropletAnalyzer();
            da.imagedata = imagedata;
        end
    end

end