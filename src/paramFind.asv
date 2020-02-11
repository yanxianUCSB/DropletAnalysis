%% pkfind
% REF: http://site.physics.georgetown.edu/matlab/code.html

data = ImageData('testin/2N4R-1/Pos0/img_000000000_Brightfield_000.tif');
data.show()
%%
data = data.finddroplet();
%%
% data2 = data.imbinarize(0.5).imfill();
data.show();
%% Find sensitivity for imbinarize
clear all;
datold = ImageData('testin/2N4R-1/Pos0/img_000000000_Brightfield_000.tif');
params = DropletParams();
params.sensitivity = 0.5764;
params.ecc = 0.691;
params.cir = 0.691;
sensitivities = linspace(0.5, 0.8, 5);
eccs = linspace(0.5, 1, 10);
cirs = linspace(0.5, 1, 10);
datnews = ImageData.empty();
for sensitivity = sensitivities
    for ecc = eccs
        for cir = cirs
            ii = find(sensitivity == sensitivities);
            jj = find(ecc == eccs);
            kk = find(cir == cirs);
            params.sensitivity = sensitivities(ii);
            params.ecc = eccs(jj);
            params.cir = cirs(kk);
            datnew = datold.finddroplet(params);
%             params.sensitivity = sensitivities(ii);
%             datnew = datold.imbinarize(params.sensitivity);
%             datnew = datnew.labelimage().regionprops();
%             datnew = datnew.subsetregion(params.minDiam, params.maxDiam, params.ecc, params.cir);
            h(:, ii, jj, kk) = hist([datnew.measurements.EquivDiameter], params.minDiam:params.maxDiam)';
            datnews(ii, jj, kk) = datnew;
            display(datnew);
        end
    end
end
save matlab.mat
%%
%%
loss = sum(h(5:end, :, :, :)); loss = loss(1,:,:,:);
plot(loss);
%% find optimal parameters for one image
clear all
imagedata = ImageData('testin/2N4R-1/Pos0/img_000000000_Brightfield_000.tif');
[x,fval,exitflag,output] = fminbnd(@(x)paramFind_loss(x, imagedata), ...
    [0.5, 4, 200, 0.5, 0.5], ...
    [0.7, 4, 200, 1, 1]);
save matlab.mat

%%
ImageData.imshowpair(datold, datnew);

%%
% clf
% datold.histogram
h = hist([datnew.measurements.EquivDiameter], params.minDiam:params.maxDiam);

% Circularity = (4*Area*pi)/(Perimeter2)
loss = @(diam, circ) diam./circ 
plot(h)
%%
histo = datold.histogram();
histn = datnew.histogram();

plot(   datold.histogram().Values)
