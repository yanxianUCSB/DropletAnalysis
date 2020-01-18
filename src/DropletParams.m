classdef DropletParams
    % parameters used in detecting droplets
    properties
            sensitivity = 0.6;
            minDiam = 4;
            maxDiam = 100;
            ecc = 1;
            cir = 0.5;
            isdefault = true;
    end
    methods
        function obj = DropletParams()
        end
        function [a, b, c, d, e] = print(obj)
            a = obj.sensitivity;
            b = obj.minDiam;
            c = obj.maxDiam;
            d = obj.ecc;
            e = obj.cir;
        end
    end
end
