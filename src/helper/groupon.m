function cells = groupon(cellin, coln)
    % Ver 1.4
    cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
    cells = {};
    
    if length(coln) == 1,
        thiscol = cellin(:, coln);
        uni = unique(thiscol);
        for unii = 1:length(uni),
            thisunicol = uni{unii};
            cells(unii) = {cellin(cellfun(cellfind(thisunicol), thiscol), :)};
        end
        return;
    end
    
    cells1 = groupon(cellin, coln(1));
    for ii = 1:length(cells1)
        cells = [cells, groupon(cells1{ii}, coln(2:length(coln)))];
    end
    %     if length(cells1) == 1,
    %         cells = groupon(cells1{1}, coln(2:length(coln)));
    %     else
    %         A = groupon(cells1{1}, coln(2:length(coln)));
    %         B = groupon(cells1{2}, coln(2:length(coln)));
    %         cells = [A, B];
    %     end
    