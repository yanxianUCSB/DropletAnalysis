function l = paramFind_loss(p, imagedata)
% params = struct();
% params.sensitivity = p(1);
% params.minDiam = p(2);
% params.maxDiam = p(3);
% params.ecc = p(4);
% params.cir = p(5);

datnew = imagedata.imbinarize(p(1));
datnew = datnew.labelimage().regionprops();
datnew = datnew.subsetregion(p(2), p(3), p(4), p(5));
h = hist([datnew.measurements.EquivDiameter], p(2):p(3));
h = h';
l = -sum(h(5:end, :));
end