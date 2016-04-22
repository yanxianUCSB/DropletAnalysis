function figurePublish(path_root, DivCell, Axis)

% group.Salt = [0.000, 150, 260];
% group.Tau = [86, 129, 172, 214, 257];
% group.RNA = [11, 120, 240, 360, 480, 600, 720];
% group.glycerol = [0.1, 0.3];
% 
% yLimMax = 50;
% group.Salt = [0 150 300];
% group.Tau = [0 20 40 60];
% group.RNA = [0 20 40 60];
% group.glycerol = [0 0.05 0.1 0.15];

% yLimMax = 50;
% group.Salt = [0 70 150 500 2000 3000];
% group.Tau = [0 10 20 80 100 140 180];
% group.RNA = [0 10 40 120 240 480];
% group.glycerol = [0 0.01 0.05 0.1 0.3 0.5];

%% Figure
% The new defaults will not take effect if there are any open figures. To
% use them, we close all figures, and then repeat the first example.
close all;

% Defaults for this blog post
width = 6;     % Width in inches
height = 4;    % Height in inches
alw = 1.5;    % AxesLineWidth
fsz = 12;      % Fontsize
lw = 0.5;      % LineWidth
msz = 8;       % MarkerSize

% The properties we've been using in the figures
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz
set(0,'DefaultAxesFontSize',fsz); % set the default Fontsize to msz
set(0,'DefaultAxesLineWidth',alw); % set the default AxesLineWidth to msz

% Set the default Size for display
defpos = get(0,'defaultFigurePosition');
set(0,'defaultFigurePosition', [defpos(1) defpos(2) width*100, height*100]);

% Set the defaults for saving/printing to a file
set(0,'defaultFigureInvertHardcopy','on'); % This is the default anyway
set(0,'defaultFigurePaperUnits','inches'); % This is the default anyway
defsize = get(gcf, 'PaperSize');
left = (defsize(1)- width)/2;
bottom = (defsize(2)- height)/2;
defsize = [left, bottom, width, height];
set(0, 'defaultFigurePaperPosition', defsize);

% % Now we repeat the first example but do not need to include anything
% % special beyond manually specifying the tick marks.
% figure(1); clf;
% plot(dmn,f(dmn),'b-',dmn,g(dmn),'r--',xeq,f(xeq),'g*');
% xlim([-pi pi]);
% legend('f(x)', 'g(x)', 'f(x)=g(x)', 'Location', 'SouthEast');
% xlabel('x');
% title('Automatic Example Figure');
% set(gca,'XTick',-3:3); %<- Still need to manually specific tick marks
% set(gca,'YTick',0:10); %<- Still need to manually specific tick marks

%
% xLim = [0 15];
% yLim = [0 20];
% compareTheseSalt(path_root, group.Salt, group.Tau, group.RNA, group.glycerol,...
%     [0 80 120 0.1], xLim, yLim);
% compareTheseTau(path_root, group.Salt, group.Tau, group.RNA, group.glycerol,...
%     [0 80 120 0.3], xLim, yLim);
% compareThesePolyA(path_root, group.Salt, group.Tau, group.RNA, group.glycerol,...
%     [0 80 0 0.3], xLim, yLim);
% compareTheseGlycerol(path_root, group.Salt, group.Tau, group.RNA, group.glycerol,...
%     [0 60 60 0.1], xLim, yLim);
% compareTheseGlycerol(path_root, group.Salt, group.Tau, group.RNA, group.glycerol,...
%     [0 40 60 0.1], xLim, yLim);

end
