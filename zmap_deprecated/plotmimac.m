function plotmimac(mi,inde)
    
    % TODO maybe move into domisfit
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun(mfilename('fullpath'));
    
    global mif2 mif1
    global oneOfHowManyPopupIdx
    
    %var1 = 4;
    sc = oneOfHowManyPopupIdx;
    figure(UNK) % FIXME: really? this figure? unsure
    delete(findobj(UNK,'Type','axes'));
    rect = [0.15,  0.20, 0.75, 0.65];
    axes('position',rect)
    watchon
    
    % check if cross-section exists
    figNumber=findobj('Type','Figure','-and','Name','Cross -Section');
    
    if isempty(figNumber)
        errordlg('Please create a cross-section first, then rerun the last selection');
        nlammap
        return
    end
    
    
    % check if cross-section is still current
    if max(mi(:,1)) > length(mi(:,1))
        errordlg('Please rerun the cross-section first, then rerun the last selection');
        nlammap
        return
    end
    
    
    mic = mi(inde,:);
    le = size(newa,2); %FIXME where does newa come from? ZG.newa? input parameter?  Needs to be treated like a ZmapCatalog
    
    if var1 == 1
        for i = 1:length(newa(:,6))
            pl =  plot(newa(i,le),-newa(i,7),'ro');
            hold on
            set(pl,'MarkerSize',mic(i,2)/sc)
        end
        
    elseif var1 == 2
        
        for i = 1:length(newa(:,6))
            pl =  plot(newa(i,le),-newa(i,7),'bx');
            hold on
            set(pl,'MarkerSize',mic(i,2)/sc,'LineWidth',mic(i,2)/sc)
        end
        
    elseif var1 == 3
        
        for i = 1:length(newa(:,6))
            pl =  plot(newa(i,le),-newa(i,7),'bx');
            hold on
            c = mic(i,2)/max(mic(:,2));
            %c = newa(i,15)*10;
            set(pl,'MarkerSize',mic(i,2)/sc+3,'LineWidth',mic(i,2)/sc+0.5,'Color',[ c c c ] )
        end
        
    elseif var1 == 4
        
        g = jet;
        for i = 1:length(newa(:,6))
            pl =  plot(newa(i,le),-newa(i,7),'bx');
            hold on
            c = floor(mic(i,2)/max(mic(:,2))*63+1);
            set(pl,'MarkerSize',4,'LineWidth',2,'Color',[ g(c,:) ] )
        end
        colorbar
        colormap(jet)
    end
    
    if exist('maex', 'var')
        hold on
        pl = plot(maex,-maey,'*m');
        set(pl,'MarkerSize',8,'LineWidth',2)
    end
    
    if exist('maex', 'var')
        hold on
        pl = plot(maex,-maey,'*m');
        set(pl,'MarkerSize',8,'LineWidth',2)
    end
    
    xlabel('Distance [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel('Depth [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    strib = [  'Misfit '];
    title(strib,'FontWeight','bold',...
        'FontSize',ZmapGlobal.Data.fontsz.m,'Color','k')
    
    set(gca,'Color',color_bg);
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    uicontrol(...
        'Style','pushbutton',...
        'Units','normalized',...
        'Position',[0.9 0.7 0.08 0.08],...
        'String','Grid',...
        'callback',@(~,~)mificrgr(mi,inde));
    
    uicontrol(...
        'Style','pushbutton',...
        'Units','normalized',...
        'Position',[0.9 0.6 0.08 0.08],...
        'String','Sel EQ',...
        'callback',@cb_pickinv);
    
    watchoff
    
    function cb_pickinv(~,~)
        newa2=crossel(newa);
        ZG.newt2=newa2;
        ZG.newcat=newa2;
        timeplot();
    end

    
end
