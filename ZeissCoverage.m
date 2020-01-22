function ZeissCoverage(dirin, dirout, bimwrite)
if nargin < 1
    dirin = uigetdir('Define input directory');
end
if nargin < 2
    dirout = dirin;
end
if nargin < 3
    bimwrite = false;
end

    d = dir(dirin);
    d = d([d.isdir]);
    assert(numel(d) > 2);
    d = d(3:end);
    results = {'Subfolder', 'Filename', 'Coverage'};
    kk = 1;
    for ii = 1:numel(d)
        display(d(ii).name);
        ida0 = ImageDataArray(fullfile(d(ii).folder, d(ii).name));
        if ida0.isempty; continue; end
        ida1 = ida0.finddroplet(DropletParams());
        pcnts = ida1.getpc();
        for jj = 1:numel(pcnts)
            results{kk, 1} = d(ii).name;
            results{kk, 2} = ida1.idArray(jj).filepath;
            results{kk, 3} = pcnts(jj);
            kk = kk+1;
        end
        if bimwrite
            ida0.idArray(imax).stretchlim().imwrite(strcat(dirout, filesep, d(ii).name, '-0.png'))
            ida1.idArray(imax).stretchlim().imwrite(strcat(dirout, filesep, d(ii).name, '-1.png'));
        end
    end
    cell2csv(strcat(dirout, filesep, 'results.csv'), results);
end
