% This script sets the height and width of the plot and the ratio to the
% golden ratio.

function [] = publisizeFig()

set(gcf, 'Units','inches','PaperUnits','inches');

oldPosition = get(gcf,'Position');
startingAspect = pbaspect;
startingRatio = startingAspect(1)/startingAspect(2);

propertyNames = {   'Width',...
                    'Height',...
                    'Ratio (w/h)',...
                    'Linewidth',...
                    'Axes Font',...
                    'Label Font',...
                    'Font Name'};
                
dlg_title = 'Working Title';

defAns = {num2str(oldPosition(3)),...
            num2str(oldPosition(4)),...
            num2str(4/3),...
            num2str(1),...
            num2str(10),...
            num2str(12),...
            'Arial'};
                
num_lines = 1;                
figureParameterValues = inputdlg(propertyNames,dlg_title,num_lines,defAns);
width = str2num(figureParameterValues{1});
height = str2num(figureParameterValues{2});
newRatio = str2num(figureParameterValues{3});
left = oldPosition(1);
bottom = oldPosition(2);
lineWidth = str2num(figureParameterValues{4});
axesFontSize = str2num(figureParameterValues{5});
labelFontSize = str2num(figureParameterValues{6});
fontName = figureParameterValues{7};

xlabelHandle = get(gca,'xlabel');
ylabelHandle = get(gca,'ylabel');
set(xlabelHandle,...
        'Fontname',     'Arial',...
        'FontSize',     labelFontSize,...
        'FontWeight',   'bold');
set(ylabelHandle,...
    'Fontname',     'Arial',...
    'FontSize',     labelFontSize,...
    'FontWeight',   'bold');

set(gca,'FontSize',     axesFontSize,...
        'FontWeight',   'bold',...
        'LineWidth',    lineWidth,...
        'TickLength',   [0.02,0.005]);

    
    
set(gcf,'Position', [left, bottom, width, width/newRatio]);

%Set the linewidth of the data points:
dataPointsHandle = get(gca,'Children');
set(dataPointsHandle,'LineWidth',lineWidth);
%Set the figure legend properties
legend off;
lh = legend('toggle');
M = findobj(lh,'type','line');
set(M,'linewidth',lineWidth);




%{
set(gca, 'Units','normalized',... 
    'Position',[0.15 0.2 0.75 0.7]);
%}

    
    
%{
% Set figure size for currently opened figure

set(gcf, 'Units','inches','PaperUnits','inches');
oldPosition = get(gcf,'Position');
left=oldPosition(1);
bottom=oldPosition(2);
width=oldPosition(3);
height = oldPosition(4);

set(gcf,'Position', [left, bottom, 3.5, (3.5/width)*height])
pbaspect([1,1/1.618,1]);
%}
