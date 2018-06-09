% ROC plot settings
% Shariful Islam: 04 July 2016 - 09:07:11 


% Color Order:
% cc =mycolors(1:10);
% set(gca,'ColorOrder',cc);
% clear cc;

% LineStyle Order:
% set(gca,'LineStyleOrder', '.-|x--|x-|p-.|h-','LineWidth',0.1,...
% set(gca,'LineStyleOrder', 'o--|.-|x-|p-.|h-','LineWidth',0.5);

set(gca,'OuterPosition',[0 0 1 1],'Units','normalized',... % default
    'XGrid','on','XLim',[-0.05 1.05],'XColor',[0.6 0.6 0.6],...
    'XTick',0:.1:1,'XMinorTick','on',...
    'YGrid','on','YLim',[-0.05 1.05],'YColor',[0.6 0.6 0.6],...
    'YTick',[0:.1:1],'YMinorTick','on');
axis square;
xlabel('False alarm rate',  'fontweight','bold','Color','k');
ylabel('True positive rate','fontweight','bold','Color','k');

