function m = normr2(m)
for ii = 1:size(m, 1)
    m(ii, :) = m(ii, :)/sum(m(ii, :));
end
