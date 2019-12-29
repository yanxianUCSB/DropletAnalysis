classdef ImageData
    properties
        filepath = 'testin/2N4R-1/Pos0/img_000000000_Brightfield_000.tif';
        A, map, transparency;
    end
    
    methods
        function obj = ImageData(filepath)
            obj.filepath = filepath;
            [obj.A, obj.map, obj.transparency] = imread(obj.filepath);
        end
        function show(obj)
            image(obj.A, 'CDataMapping', 'scaled');
        end
    end
end