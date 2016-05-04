%------------ FUNCTION: findcircles.m ------------%

% This function finds circles in an image. The inputs are:
%
% radiusRange - the range of radii to be searched (2 by N array).
% image - image to be analysed
% EdgeThreshold - circle edge gradient threshold
%
% For more information, see documentation for imfindcircles.m
%
% This function requires two additional functions
% not normally installed with MATLAB:
%
% RemoveOverLap.m - available at:
% http://www.mathworks.com/matlabcentral/fileexchange/42370-circles-overlap-remover
%
% snip.m - available at:
% http://www.mathworks.com/matlabcentral/fileexchange/41941-snip-m-snip-elements-out-of-vectors-matrices
function [centers,radii] = findcircles(radiusRange,image,EdgeThreshold,ObjectPolarity,Sensitivity)
centers = [];
radii = [];
circleData = struct('Center',centers,'Radius',radii);
for i = 1 : length(radiusRange)
 [centers,radii,~] = imfindcircles(image,radiusRange(i,:),...
     'ObjectPolarity', ObjectPolarity,...
     'Sensitivity', Sensitivity, ...
     'EdgeThreshold',EdgeThreshold);
 circleData.Center = vertcat(circleData.Center,centers); 
 circleData.Radius = vertcat(circleData.Radius,radii);
end;
% [centers,radii] = RemoveOverLap(circleData.Center,circleData.Radius,10,1);
centers = circleData.Center;
radii = circleData.Radius;
