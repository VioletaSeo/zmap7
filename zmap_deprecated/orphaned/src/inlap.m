% function inlap
% inlap.m
%
% make dialog interface for seislap
%
% Last change 7/95               A.Allmann

%
report_this_filefun(mfilename('fullpath'));

global ptime
global seis_inpu1 seis_inpu2 seis_inpu3 qui1
global repeat_button lapf maepi



%set catalog
if size(newcat)==0
    newcat=a;
end

%initial values
figure_w_normalized_uicontrolunits(mess)
clf
set(gca,'visible','off')
set(gcf,'Units','pixel','NumberTitle','off','Name','Input Parameters for Seislap');

set(gcf,'pos',[ wex  wey welx+100 wely+50])

bev=find(newcat.Magnitude==max(newcat.Magnitude)); %biggest events in catalog


%default values of input parameters
ldx=100;
latt=newcat(bev(1),2);
longt=newcat(bev(1),1);
Mmin=3;
ldepth=newcat(bev(1),7);
if quie==1
    qui1=1;
    tlap=100;
    binlength=10;
elseif quie==2
    qui1=2;
    tlap=10;
    binlength=1;
end

% creates a dialog box to input some parameters
%
txt1 = text(...
    'Color',[0 0 0 ],...
    'EraseMode','normal',...
    'Position',[0. 0.96 0 ],...
    'Rotation',0 ,...
    'FontWeight','bold',...
    'FontSize',ZmapGlobal.Data.fontsz.m ,...
    'String','Minimum Magnitude: ');



txt2 = text(...
    'Color',[0 0 0 ],...
    'EraseMode','normal',...
    'Position',[0. 0.81 0 ],...
    'Rotation',0 ,...
    'FontWeight','bold',...
    'FontSize',ZmapGlobal.Data.fontsz.m ,...
    'String','Please input DX in km ');


txt3 = text(...
    'Color',[0 0 0 ],...
    'EraseMode','normal',...
    'Position',[0. 0.66 0 ],...
    'Rotation',0 ,...
    'FontWeight','bold',...
    'FontSize',ZmapGlobal.Data.fontsz.m ,...
    'String','Please input overlap time in days:');

txt4 = text(...
    'Color',[0 0 0 ],...
    'EraseMode','normal',...
    'Position',[0. 0.51 0 ],...
    'Rotation',0 ,...
    'FontWeight','bold',...
    'FontSize',ZmapGlobal.Data.fontsz.m ,...
    'String','Longitude of point of interest:');
txt5 = text(...
    'Color',[0 0 0 ],...
    'EraseMode','normal',...
    'Position',[0. 0.36 0 ],...
    'Rotation',0 ,...
    'FontWeight','bold',...
    'FontSize',ZmapGlobal.Data.fontsz.m ,...
    'String','Lattitude of point of interest:');

txt6 = text(...
    'Color',[0 0 0 ],...
    'EraseMode','normal',...
    'Position',[0. 0.21 0 ],...
    'Rotation',0 ,...
    'FontWeight','bold',...
    'FontSize',ZmapGlobal.Data.fontsz.m ,...
    'String','Binlength in days:');

inp1_field  = uicontrol('Style','edit',...
    'Position',[.85 .87 .13 .08],...
    'Units','normalized','String',num2str(Mmin),...
    'Callback','Mmin=str2double(get(inp1_field,''String''));set(inp1_field,''String'',num2str(Mmin));');



inp2_field  = uicontrol('Style','edit',...
    'Position',[.85 .75 .13 .08],...
    'Units','normalized','String',num2str(ldx),...
    'Callback','ldx=str2double(get(inp2_field,''String''));set(inp2_field,''String'',num2str(ldx));');


inp3_field=uicontrol('Style','edit',...
    'Position',[.85 .63 .13 .08],...
    'Units','normalized','String',num2str(tlap),...
    'Callback','tlap=str2double(get(inp3_field,''String''));     set(inp3_field,''String'',num2str(tlap));');

inp4_field=uicontrol('Style','edit',...
    'Position',[.85 .51 .13 .08],...
    'Units','normalized','String',num2str(longt),...
    'Callback','longt=str2double(get(inp4_field,''String'')); set(inp4_field,''String'',num2str(longt));');


inp5_field=uicontrol('Style','edit',...
    'Position',[.85 .39 .13 .08],...
    'Units','normalized','String',num2str(latt),...
    'Callback','latt=str2double(get(inp5_field,''String'')); set(inp5_field,''String'',num2str(latt));');

inp6_field=uicontrol('Style','edit',...
    'Position',[.85 .27 .13 .08],...
    'Units','normalized','String',num2str(binlength),...
    'Callback','binlength=str2double(get(inp6_field,''String'')); set(inp6_field,''String'',num2str(binlength));');

close_button=uicontrol('Style','Pushbutton',...
    'Position', [.7 .05 .15 .12 ],...
    'Units','normalized','Callback','welcome','String','Cancel');

inflap_button=uicontrol('Style','Pushbutton',...
    'Position', [.47 .05 .15 .12 ],...
    'Units','normalized','Callback','clinfo(13)','String','Info');

go_button=uicontrol('Style','Pushbutton',...
    'Position',[.25 .05 .15 .12 ],...
    'Units','normalized',...
    'Callback','tlap=str2num(get(inp3_field,''String''));ldx=str2num(get(inp2_field,''String''));binlength=str2num(get(inp6_field,''String''));latt=str2num(get(inp5_field,''String''));longt=str2num(get(inp4_field,''String''));Mmin=str2num(get(inp1_field,''String''));clf;welcome;if quie==1 lap1=seislap2(ldx,tlap,binlength,longt,latt,Mmin,ldepth,1);elseif quie==2 lap1=seislap2(ldx,tlap,binlength,longt,latt,Mmin,ldepth,2);end;',...
    'String','Go');

%freeze_button = uicontrol(...
%'BackgroundColor',[ 0.7 0.7 0.7 ],...
%'Callback','fre = get(freeze_button,''Value'');',...
%'ForegroundColor',[ 0 0 0 ],...
%'Position',[ 0.25 0.30 0.4 0.15 ],...
%'String','Freeze Colorbar? ',...
%'Style','checkbox',...
%'Units','normalized',...
%'Visible','on');
%

set(gcf,'visible','on');watchoff


