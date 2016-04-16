function cells = groupon2(cellin, coln, TOL)
    % Ver 1.0
%     cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
    cells = {};
    
    if length(coln) == 1,
        thiscol = cellin(:, coln);
        
        [~, ~, IC] = uniquetol(thiscol, TOL);
        uni = unique(IC);
        for thisunicol = uni;
            cells = [cells, {cellin(thisunicol == IC, :)}];
        end
        return;
    end
    
    cells1 = groupon2(cellin, coln(1), TOL);
    
    for ii = 1:length(cells1)
        cells = [cells, groupon2(cells1{ii}, coln(2:length(coln)), TOL)];
    end
    %     if length(cells1) == 1,
    %         cells = groupon(cells1{1}, coln(2:length(coln)));
    %     else
    %         A = groupon(cells1{1}, coln(2:length(coln)));
    %         B = groupon(cells1{2}, coln(2:length(coln)));
    %         cells = [A, B];
    %     end
    
