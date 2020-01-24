classdef DropletParams
    % parameters used in detecting droplets
    properties
%             sensitivity = 0.6;
%             minDiam = 4;
%             maxDiam = 100;
%             ecc = 1;
%             cir = 0.5;
%             isdefault = true;
            sensitivity = 0.5;
            minDiam = 4;
            maxDiam = 200;
            ecc = 1;  % max eccentricity
            cir = 0.5;  % min circularity
            isdefault = false;
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
        function obj = set_default(obj)
            obj.sensitivity = 0.6;
            obj.minDiam = 4;
            obj.maxDiam = 100;
            obj.ecc = 1;
            obj.cir = 0.5;
            obj.isdefault = true;
        end
    end
end
