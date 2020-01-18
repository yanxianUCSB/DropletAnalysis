classdef ObjectArray
    properties
        size
    end
    properties (Hidden)
        data
    end
    methods 
        function size = get.size(obj)
            size = numel(obj.data);
        end
        function b = isempty(obj)
            b = isempty(obj.data);
        end
    end
end