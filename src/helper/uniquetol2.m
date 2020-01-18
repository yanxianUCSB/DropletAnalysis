function [DIV, salt, saltindex] =  uniquetol2(db, DIV)
%%
DIV = sort(DIV);
salt = zeros(length(DIV),1);
saltindex = zeros(length(db), 1);

%%
for iii = 1:length(db)
    olddiv = -Inf;
    for newdiv = DIV
        if olddiv < db(iii) && db(iii) <= newdiv
            salt(iii) = newdiv;
            saltindex(iii) = find(newdiv == DIV);
            break
        end
    end
end

if size(DIV, 1) < size(DIV, 2)
    DIV = DIV';
end


