function s = getColor(n)
colorList = ['y'; 'm'; 'r'; 'g'; 'b';  'k'];
s = (colorList(mod(n, 6) + 1));
end
