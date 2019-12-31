classdef DropletAnalyzer
    properties
        imagedata
    end
    methods(Static)
        level = isodata(I)
    end
    methods
        function obj = DropletAnalyzer()

            return
        end
        function level = getlevel(obj, imagedata)
            level = obj.isodata(imagedata.A);
            return
        end
    end
    %1. convert image file path to ImageData
    %2. convert ImageData to size freq
    %3. read all subfolder and output a table of size freq
end

