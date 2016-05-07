function s = getColor(n)
colorList = [ 'r'; 'g'; 'b'; 'k'; 'm'; 'y'];
s = (colorList(mod(n, 6) ));
end
