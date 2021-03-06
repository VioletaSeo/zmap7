function [xsecx,xsecy, inde] = mysect(eqlat,eqlon,depth,width,length,lat1,lon1,lat2,lon2)
    % MYSECT to make a cross section of data points on a map
    % Based off of LC_XSECTION
    %
    %LC_XSECT
    %
    %	[xsecx, xsecy] = LC_xsect(eqlat,eqlon,depth,width,length,...
    %                                        lat1,lon1,lat2,lon2)        (1)
    %
    %	[xsecx, xsecy] = LC_xsect(eqlat,eqlon,depth,width,length,...
    %                                        lat0,lon0,azimuth)          (2)
    %
    %	[xsecx, xsecy] = LC_xsect(eqlat,eqlon,depth,width)         (3)
    %
    %	Function to make a cross section of data points on a map
    %	created by LC_MAP (Lambert Conformal).
    %	The WIDTH of the zone from which the data points is given
    %	in "km" and represent the total width (1/2 on one side, 1/2 on
    %	the other side).
    %	The LENGTH of the xsection in "km" is only used in method (2),
    %	but this argument is still neccessary in argument list of
    %	method (1) in order to keep the argument list in the right order.
    %	The data points location are given by EQLAT, EQLON and DEPTH.
    %	The cross section location can be given in any one of three ways:
    %
    %	  (1) given latitudes and longitudes of two points on the map,
    %             using the arguments as described above.
    %
    %	  (2) given latitude and longitude of a center point and an azimuth.
    %
    %	  (3) using the cursor to select two points on the map by clicking
    %	      a mouse button above the desired points.
    %
    %	If the output argument is used, the distance-depth data is kept
    %	in variables for other use; otherwise the xsection will be plotted
    %	on a new figure window.
    %
    %	It is possible to set the symbol type, size and line width by
    %	setting the following global variables:
    %	"symb_type", "symb_size" and "symb_width" respectively. Otherwise
    %	it will use the defaults.
    %
    %	It is also possible to set the minimum and maximum depth of the
    %	cross-section by setting the following global variables:
    %	"mindepth" and "maxdepth".  If either or both are not set, it
    %	will use 0 km as the minimum depth and/or the depth of the deepest
    %	data point as the maximum depth.
    %
    %	NOTE:
    %	It is assumed that LC_MAP was used before using this function!
    %	This is necessary to set global variables used by this function.
    
    %TODO fix the global situation, incoming parameters cannot match globals directly. -CGR
    
    report_this_filefun();
    
    global  torad
    % global lat1 lon1 lat2 lon2
    global leng rbox box
    global sine_phi0 phi0 lambda0 phi1 phi2 pos sw eq1
    global maxlatg minlatg maxlong minlong
    global symb_type symb_size symb_width
    global label1 label2 mapl
    global mindepth maxdepth h2
    global eq0p
    todeg = 180 / pi;
    eq1 =[];
    
    switch nargin
        case 8 % method 2: given lat & lon of center point and angle
            
            lat0 = lat1;
            lon0 = lon1;
            [x0, y0] = lc_tocart(lat0,lon0);
            azimuth = lat2;
            
            if azimuth >= 180, azimuth = azimuth - 180; end
            theta0 = ((lon0*torad - lambda0) * sine_phi0) * todeg;
            alpha = azimuth - theta0;
            beta = (90 - azimuth) + theta0;
            
            x2 = ((length / 2) * cos(beta*torad));
            y2 = ((length / 2) * sin(beta*torad));
            x1 = x0 - x2;
            y1 = y0 - y2;
            x2 = x0 + x2;
            y2 = y0 + y2;
            
            [lat1, lon1] = lc_froca(x1,y1);
            [lat2, lon2] = lc_froca(x2,y2);
            
        case 4	% method 3: selection of the end points by mouse
            [lat1, lon1] = inputm(1);
            h=plotm(lat1, lon1,'rx','MarkerSize',6,'LineWidth',2);
            [lat2, lon2] = inputm(1);
            
            delete(h)
            h=plotm([lat1 lat2],[lon1 lon2],'rx:','MarkerSize',6,'LineWidth',2);
            
            [arclen,azimuth] = distance([lat1, lon1] , [lat2, lon2]);
            leng=deg2km(arclen);
            alpha=0;
            %{
            limits = ginput(1);
            x1 = limits(1,1);
            y1 = limits(1,2);
            [lat1, lon1] = lc_froca(x1,y1);
            lc_event(lat1,lon1,'rx',6,2)
            limits = ginput(1);
            x2 = limits(1,1);
            y2 = limits(1,2);
            
            if x1 > x2
                xtemp = x1; ytemp = y1;
                x1 = x2; y1 = y2;
                x2 = xtemp; y2 = ytemp;
            end
            
            [lat1, lon1] = lc_froca(x1,y1);
            [lat2, lon2] = lc_froca(x2,y2);
            lc_event(lat2,lon2,'rx',6,2)
            
            x0 = (x1 + x2) / 2;
            y0 = (y1 + y2) / 2;
            [lat0, lon0] = lc_froca(x0,y0);
            dx = x2 - x1;
            dy = y2 - y1;
            
            alpha = 90 - (atan(dy/dx)*todeg);
            length = sqrt(dx^2 + dy^2);
            leng = length;
            %}
            
        case 9	% method 1: given lat & lon of the two end points
            figure(mapl);
            [x1, y1] = lc_tocart(lat1,lon1);
            [x2, y2] = lc_tocart(lat2,lon2);
            
            if x1 > x2
                xtemp = x1; ytemp = y1;
                x1 = x2; y1 = y2;
                x2 = xtemp; y2 = ytemp;
                sw = 'on'
            else
                sw = 'of'
            end
            
            x0 = (x1 + x2) / 2;
            y0 = (y1 + y2) / 2;
            [lat0, lon0] = lc_froca(x0,y0);
            dx = x2 - x1;
            dy = y2 - y1;
            
            alpha = 90 - (atan(dy/dx)*todeg);
            length = sqrt(dx^2 + dy^2);
            
        otherwise
            
            disp('ERROR: incompatible number of arguments')
            help mysect
            return
    end
    
    % correction factor to correct for longitude away from the center meridian
    theta0 = ((lon0*torad - lambda0) * sine_phi0) * todeg;
    
    % correct the XY azimuth of the Xsection line with the above factor to obtain
    % the true azimuth
    azimuth = alpha + theta0;
    if azimuth < 0, azimuth = azimuth + 180; end
    
    % convert XY coordinate azimuth to a normal angle like we used to deal with
    sigma = 90 - alpha;
    
    % transformation matrix to rotate the data coordinate w.r.t the Xsection line
    transf = [cos(sigma*torad) sin(sigma*torad)
        -sin(sigma*torad) cos(sigma*torad)];
    
    % inverse transformation matrix to rotate the data coordinate back
    invtransf = [cos(-sigma*torad) sin(-sigma*torad)
        -sin(-sigma*torad) cos(-sigma*torad)];
    
    % convert the map coordinate of the events to cartesian coordinates
    idx_map = find(minlatg < eqlat & eqlat < maxlatg & ...
        minlong < eqlon & eqlon < maxlong);
    [eq(1,:) eq(2,:)] = lc_tocart(eqlat,eqlon);
    % create new coordinate system at center of Xsection line
    eq0(1,:) = eq(1,:) - x0;
    eq0(2,:) = eq(2,:) - y0;
    
    % rotate this last coordinate system so that X-axis correspond to Xsection line
    eq0p = transf * eq0;
    % project the event data to the Xsection line
    eq1(1,:) = eq0p(1,:);
    eq1(2,:) = eq0p(2,:) ;
    
    % convert back to the original coordinate system
    eq1p = invtransf * eq1;
    eq2(1,:) = eq1p(1,:) + x0;
    eq2(2,:) = eq1p(2,:) + y0;
    
    % plot the Xsection line on the map
    plot([x1 x2],[y1 y2],'--','LineWidth',1.5)
    
    % label the Xsection end points
    xlim = get(gca,'XLim');
    ylim = get(gca,'YLim');
    label_dist = (2 / 100) * sqrt((2*xlim(2))^2 + (2*ylim(2))^2);
    label_pt(1,1) = -(length/2 + label_dist);
    label_pt(2,1) = 0;
    label_pt(1,2) = length/2 + label_dist;
    label_pt(2,2) = 0;
    rlabel_pt = invtransf * label_pt;
    label_pt(1,:) = rlabel_pt(1,:) + x0;
    label_pt(2,:) = rlabel_pt(2,:) + y0;
    if isempty(label1), label1 = 'A'; end
    if isempty(label2), label2 = 'B'; end
    label1 = 'A'; label2 = 'B';
    lbl1_h = text(label_pt(1,1),label_pt(2,1),label1,'FontSize',14,...
        'Vertical','middle','Horizontal','center','FontWeight','bold');
    lbl2_h = text(label_pt(1,2),label_pt(2,2),label2,'FontSize',14,...
        'Vertical','middle','Horizontal','center','FontWeight','bold');
    
    % create a box of width "width" around the Xsection line and plot it
    box(1,1) = -length/2; box(2,1) = width/2;
    box(1,2) = length/2; box(2,2) = width/2;
    box(1,3) = length/2; box(2,3) = -width/2;
    box(1,4) = -length/2; box(2,4) = -width/2;
    xbox = [box(1,:) box(1,1)];
    ybox = [box(2,:) box(2,1)];
    rbox = invtransf * [xbox ; ybox];
    rbox(1,:) = rbox(1,:) + x0;
    rbox(2,:) = rbox(2,:) + y0;
    plot(rbox(1,:),rbox(2,:),'-y','LineWidth',1.3)
    
    % check if symbol parameters global variables are set, if not --> defaults
    if isempty(symb_type), symb_type = '+r'; end
    if isempty(symb_size), symb_size = 3; end
    if isempty(symb_width), symb_width = [0.5]; end
    
    % find index of all events which are within the given box width
    idx_box = find(abs(eq0p(2,:)) <= width/2 & abs(eq0p(1,:)) <= length/2);
    inde = idx_box;
    
    % plot the events on the map
    plot(eq(1,idx_box),eq(2,idx_box),'mo','MarkerSize',symb_size,...
        'LineWidth',symb_width)
    
    
    % Open another graphic window for the cross section
    
    xsec_fig_h=findobj('Type','Figure','-and','Name','Cross -Section');
    
    
    % Set up the Map window Enviroment
    %
    if isempty(xsec_fig_h)
        xsec_fig_h = figure_w_normalized_uicontrolunits( ...
            'Name','Cross -Section',...
            'Tag','xsection',...
            'NumberTitle','off', ...
            'backingstore','on',...
            'Visible','on');
        
        
        
    end
    
    figure(xsec_fig_h);
    
    delete(findobj(xsec_fig_h,'Type','axes'));
    set(xsec_fig_h,'PaperPosition',[1 .5 9 6.9545])
    
    % Plot events on cross section figure
    xdist = eq1(1,idx_box) + (length / 2);
    %eq1(1,:) = eq1(1,:) + (length / 2);
    
    global Xwbz Ywbz
    Xwbz = xdist;
    Ywbz = depth(idx_box);
    
    xsecx = xdist;
    xsecy = depth(idx_box);
    
    plot(xdist,-depth(idx_box),symb_type,'MarkerSize',symb_size,...
        'LineWidth',symb_width);
    
    set(gca,'Color',color_bg)
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'normal','FontSize',10,'Linewidth',1,'Ticklength',[0.02 0.02])
    
    if isempty(maxdepth)
        maxZ = max(depth(idx_box));
    else
        maxZ = maxdepth;
    end
    
    if isempty(mindepth)
        minZ = min(depth(idx_box));
    else
        minZ = mindepth;
    end
    
    if length > (maxZ - minZ)*11/8.5
        position = [.1 .1 .7 ((maxZ-minZ)/length)*0.7*11/8.5];
    else
        position = [.1 .1 (length/(maxZ-minZ))*0.7*8.5/11 .7];
    end
    pos = position;
    set(gca,'Position',position,'XLim',[0 length],'Ylim',[-maxZ -minZ],...
        'LineWidth',1)
    h2=gca;
    % Plot labels
    xlabel('Distance [km]');
    ylabel('Depth [km]');
    
    label_base1 = 1 + .04;
    label_base2 = 1 + .08;
    label_base3 = 1 + .12;
    lbl3_h = text(0,label_base2,label1,'FontSize',12,'Horizontal','center',...
        'FontWeight','bold','Vertical','middle','Units','norm');
    lat1_dm = sprintf("    %2.2i N %4.2f'",fix(lat1),(frac(lat1)*60));
    lon1_dm = sprintf("   %3.3i W %4.2f'",abs(fix(lon1)),abs(frac(lon1)*60));
    lbl5_h = text(0,label_base1+0.00,lat1_dm,'FontSize',10,'Horizontal','left',...
        'Vertical','bottom','Units','norm');
    lbl6_h = text(0,label_base3+0.04,lon1_dm,'FontSize',10,'Horizontal','left',...
        'Vertical','bottom','Units','norm');
    
    lbl4_h = text(1,label_base2,label2,'FontSize',12,'Horizontal','center',...
        'FontWeight','bold','Vertical','middle','Units','norm');
    lat2_dm = sprintf('%2.2i N %4.2f''    ',fix(lat2),(frac(lat2)*60));
    lon2_dm = sprintf('%3.3i W %4.2f''    ',abs(fix(lon2)),abs(frac(lon2)*60));
    lbl7_h = text(1,label_base1+0.0,lat2_dm,'FontSize',10,...
        'Horizontal','right','Vertical','bottom','Units','norm');
    lbl8_h = text(1,label_base3+0.04,lon2_dm,'FontSize',10,...
        'Horizontal','right','Vertical','bottom','Units','norm');
    
    
    set(gcf,'visible','on')
    drawnow
    % Go back to map figure
    %figure(map_fig);
    
end