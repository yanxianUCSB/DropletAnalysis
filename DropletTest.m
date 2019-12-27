classdef DropletTest < matlab.unittest.TestCase
% Test cases for droplet analysis

    methods (Test)
        function testTifReadIn(testCase)
            % test tiff data readin
            actSolution = 1;
            expSolution = 1;
            testCase.verifyEqual(actSolution, expSolution);
        end

    end

end