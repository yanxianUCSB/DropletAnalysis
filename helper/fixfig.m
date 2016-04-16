%% fixfig
% FIXFIG(FIGNUM,VERBOSE)
%
% FIXFIG sets the font size and weight for all the items on a plot so that
%  they can be read more easily.

%% Introduction
function fixfig(fignum,verbose)
% FIXFIG(FIGNUM,VERBOSE) fixes up a Matlab figure by increasing the font
%  sizes, making lines thicker, etc., so that the result is suitable for
%  presentation on a screen (e.g., Powerpoint). The font size for all text
%  is increased, lines are made thicker, markers are made larger,
%  background is set to white, etc. The values are set as constants near
%  the top of the file. You may want to change the sizes and fonts to suit
%  your system.
%
% FIGNUM    The number of the figure to modify. Default is the current
%           figure.
%
% VERBOSE   Level of status messages. 0=none, 2=all. Default is 1.
%
% Example:
%
% Create a figure:
% 
% >> x = [1 2 3 4 5];
% >> a = rand(5,1);
% >> b = rand(5,1);
% >> plot(x,a,'.-r',x,b,'s-k');
% >> title('Random'); xlabel('x'); ylabel('a b');
%
% The figure is plotted, with the default MATLAB fonts and sizes, which are
% quite small and impossible to read if used in a screen presentation.
% Now type:
%
% >> fixfig
%
% and the figure is transformed with larger fonts, bolder lines, etc.
%
%
% M. A. Hopcroft
%  hopcroft at mems stanford edu
%
% MH MAY2009
% v1.01 fix typo at line 96 "('mkr')"
% v1.0  added text and line objects
%        cleaned up for public release
%     
% MH MAR205
% v0.9 script for personal use
%

%% Set constants: line width, marker size, font

% How thick do we like our lines?
lnwidth = 2;
% How big do we like our markers?
mksize = 6;
mksizept = mksize * 1; % points ('.') are always smaller
% Which font do we like in our figures?
myfont = 'Lucida Bright'; 

% Note: set title and axis fonts near end of file

if nargin < 1
    fignum=gcf;
end
if nargin < 2
    verbose=2;
end


%% Modify the figure

% make the background white
set(fignum,'color','w');

% identify the subplots
a=get(fignum,'Children')';

if verbose>=1, fprintf(1,'fixfig: Fixing Figure %d, with %d axes.\n',fignum,length(a)); end

k=0;
for i=fliplr(a)
    k=k+1;
    %% Set the linewidths and marker sizes
    
    % find all the lines on this axis
    dataline = findobj(i,'Type','line');
    if verbose>=2, fprintf(1,'fixfig: Axis %d has %d lines.\n', k,length(dataline)); end

    % cycle through the lines on the plot
    for j = dataline'
        % set the linewidth
        set(j,'LineWidth',lnwidth);
        % set the marker size
        mkr = get(j,'Marker');
        if ~strcmp(mkr,'none')
            mkrsz = get(j,'MarkerSize');
            if mkrsz <= mksize, set(j,'MarkerSize',mksize); end
            if strcmp(mkr,'.')
                if mkrsz <= mksizept, set(j,'MarkerSize',mksizept); end
            end
        end
    end
    
    % if there is text on the plot, find it and enlarge it
    datatext = findobj(i,'Type','text');
    for p = datatext'
        % set the font
        set(p,'FontSize',16,'FontWeight','bold','FontName',myfont);
    end
    
    %axes(i); % specify the subplot
    %set(fignum,'CurrentAxes',i);
    
    % axis labels
    set(gca,'FontSize',16,'FontWeight','bold','FontName',myfont)

    % title
    set(get(gca,'Title'),'FontSize',20,'FontWeight','bold','FontName',myfont)

    % x axis label
    set(get(gca,'XLabel'),'FontSize',18,'FontWeight','bold','FontName',myfont)

    % y axis label
    set(get(gca,'YLabel'),'FontSize',18,'FontWeight','bold','FontName',myfont)
    
    % make fill transparent so that legends, text, etc can be seen
%    set(i,'Color','none')
end

grid off

return