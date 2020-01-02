function ZeissCoverage(dirin, dirout)
    d = dir(dirin);
    d = d([d.isdir]);
    assert(numel(d) > 2);
    d = d(3:end);
    results = {'Subfolder', 'Max Coverage', 'Max Filename'};
    for ii = 1:numel(d)
        ida0 = ImageDataArray(fullfile(d(ii).folder, d(ii).name));
        if ida0.isempty; continue; end
        ida1 = ida0.finddroplet(DropletParams());
        pcnts = ida1.getpc();
        imax = find(pcnts == max(pcnts));
        results{ii, 1} = d(ii).name;
        results{ii, 2} = pcnts(imax);
        results{ii, 3} = ida1.idArray(imax).filepath;
        ida0.idArray(imax).stretchlim().imwrite(strcat(dirout, filesep, d(ii).name, '-0.png'))
        ida1.idArray(imax).stretchlim().imwrite(strcat(dirout, filesep, d(ii).name, '-1.png'));
    end
    cell2csv(strcat(dirout, filesep, 'results.csv'), results);
end