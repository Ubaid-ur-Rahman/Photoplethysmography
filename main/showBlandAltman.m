function showBlandAltman(HR_PPG, HR_RPPG)
        
   
        gnames = {'HR analysis'}; % names of groups in data {dimension 1 and 2}
        corrinfo = {'n','r','eq'}; % stats to display of correlation scatter plot
        BAinfo = {'RPC(%)'}; % stats to display onavg Bland-ALtman plot
        limits = 'auto';%[50 120]; % how to set the axes limits
        symbols = 'Num'; % symbols for the data sets (default)
        colors = [.25, .25, .75]; % colors for the data sets
        tit='';
        label = {'EstimatedHR', 'HR'};

        absError = abs(HR_PPG-HR_RPPG);
        MAE = mean(absError);

        [~, fig, ~] = BlandAltman(HR_RPPG(1,:),HR_PPG(1,:),label,tit,gnames,corrinfo,BAinfo,limits,colors,symbols);
        str=[' MAE : ' num2str(round(MAE,2)) ];

        a=annotation('textbox', [0.2 0.85 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 12, 'String',str );
        set(a,'Units','pixels');
        set(fig,'Units','pixels');
        aPos=get(a,'Position');
        figPos=get(fig,'Position');
        set(a,'Position',[(figPos(3)-aPos(3))/2 aPos(2) aPos(3) aPos(4)]);
        
    
end