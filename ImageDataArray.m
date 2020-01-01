classdef ImageDataArray < ObjectArray
    properties
        idArray
        isdroplet = false
    end
    methods
        function obj = ImageDataArray(argin)
            obj.idArray = ImageData().empty();
            if nargin == 0
                return
            end
            if ischar(argin)
                if strcmp(argin, 'demo')
                    argin = 'testin';
                end
                fileList = dir(fullfile(argin, '**', '*Brightfield*.tif'));
                obj.idArray = obj.imarrayread(fileList);
            elseif isa(argin, 'ImageData')
                obj.idArray = argin;
            end
        end
        function obj = finddroplet(obj)
            assert(~isempty(obj.idArray))
            for ii = 1:numel(obj.idArray)
                obj.idArray(ii) = obj.idArray(ii).finddroplet();
            end
            obj.isdroplet = true;
        end
        function hugeImage = toHugeImage(obj)
            assert(~isempty(obj.idArray))
            ht = obj.idArray(1).height;
            wd = obj.idArray(1).width;
            hugeImage = uint16(zeros(ht * numel(obj.idArray), wd));
            for ii = 1:numel(obj.idArray)
                hugeImage(ht*(ii-1) + 1 : ht*ii, :) = obj.idArray(ii).A;
            end
        end 
        function obj = strechlim(obj)
            assert(~obj.isempty())
            for ii = 1:numel(obj.idArray)
                obj.idArray(ii) = obj.idArray(ii).stretchlim();
            end
        end
    end
    methods % getters and setters
        function idArray = get.idArray(obj)
            idArray = obj.data;
        end
        function obj = set.idArray(obj, idArray)
            obj.data = idArray;
        end
    end
    methods (Static)
        function idArray = imarrayread(fileList)
            assert(isstruct(fileList));
            idArray = ImageData().empty();
            for ii = 1:numel(fileList)
                idArray(ii) = ImageData(fileList(ii));
            end
        end
    end
    %1. convert image file path to ImageData
    %2. convert ImageData to size freq
    %3. read all subfolder and output a table of size freq
end

