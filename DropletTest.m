classdef DropletTest < matlab.unittest.TestCase
% Test cases for droplet analysis

    methods (Test)
        function testTifReadIn(testCase)
            % test tiff data readin
            actSolution = 1;
            expSolution = 1;
            testCase.verifyEqual(actSolution, expSolution);
        end
        
        function testGetTifData(tc)
           filename = 'testin/untitled1.tif';
           tifData = getTifData(filename);
           tc.verifyClass(tifData.imageData, 'uint16');
           tc.verifyEqual(tifData.numFrames, 1);
        end

    end

end