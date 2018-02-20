classdef comp2periodz < ZmapGridFunction
    % COMP2PERIODZ compares seismicity rates for two time periods
    % The differences are as z- and beta-values and as percent change.
    
    properties
        t1 % start time for period 1
        t2 % end time for period 1
        t3 % start time for period 2
        t4 % end time for period 2
        binsize = ZmapGlobal.Data.bin_dur;
    end
    
    properties(Constant)
        PlotTag='myplot';
        ReturnDetails = { ... VariableNames, VariableDescriptions, VariableUnits
            ...
            ... % these are returned by the calculation function
            'z_value','z-value', '';... #1 'valueMap'
            'pct_change', 'percent change', 'pct';... #2  'per'
            'beta_value', 'Beta value map','';... #3 'beta_map'
            'Number_of_Events_1', 'Number of events in first period', '';... #4
            'Number_of_Events_2', 'Number of events in second period', '';... #5
            ...
            ... % these are provided by the gridfun
            'Radius_km','Radius','km';...# 'reso'
            'x', 'Longitude', 'deg';...
            'y', 'Latitude', 'deg';...
            'max_mag', 'Maximum magnitude at node', 'mag';...
            'Number_of_Events', 'Number of events in node', ''...
            };
    end
    
    methods
        function obj=comp2periodz(zap, varargin)
            % This subroutine compares seismicity rates for two time periods.
            % The differences are as z- and beta-values and as percent change.
            %   Stefan Wiemer 1/95
            %   Rev. R.Z. 4/2001
            
            report_this_filefun(mfilename('fullpath'));
            
            if ~exist('zap','var') || isempty(zap)
                zap = ZmapAnalysisPkg.fromGlobal();
            end
            
            ZmapFunction.verify_catalog(zap.Catalog);
            
            obj.EventSelector = zap.EventSel;
            obj.RawCatalog = zap.Catalog;
            obj.Grid = zap.Grid;
            obj.Shape = zap.Shape;
            
            obj.active_col = 'z_value';
            
            if nargin <2
                % create dialog box, then exit.
                obj.InteractiveSetup();
            else
                % run this function without human intervention
                obj.doIt();
            end
            
        end
        
        function InteractiveSetup(obj)
            
            t0b = min(obj.RawCatalog.Date);
            teb = max(obj.RawCatalog.Date);
            obj.t1 = t0b;
            obj.t4 = teb;
            obj.t2 = t0b + (teb-t0b)/2;
            obj.t3 = obj.t2+minutes(0.01);
            
            % get two time periods, along with grid and event parameters
            zdlg=ZmapDialog([]);
            zdlg.AddBasicHeader('Please define two time periods to compare');
            zdlg.AddBasicEdit('t1','start period 1',obj.t1,'start time for period 1');
            zdlg.AddBasicEdit('t2','end period 1',obj.t2,'end time for period 1');
            zdlg.AddBasicEdit('t3','start period 2',obj.t3,'start time for period 2');
            zdlg.AddBasicEdit('t4','end period 2',obj.t4,'end time for period 2');
            zdlg.AddBasicEdit('binsize','Bin Size (days)',obj.binsize,'number of days in each bin');
            %zdlg.AddEventSelectionParameters('eventsel', ZG.ni, ra, 50)
            %zdlg.AddGridParameters('gridparam',dx,'deg', dy,'deg', [],[])
            [res,okPressed]=zdlg.Create('Please choose rate change estimation option');
            if ~okPressed
                return
            end
            
            obj.SetValuesFromDialog(res)
            
            obj.doIt()
        end
        
        function SetValuesFromDialog(obj, res)
            obj.t1=res.t1;
            obj.t2=res.t2;
            obj.t3=res.t3;
            obj.t4=res.t4;
            obj.binsize=res.binsize;
        end
        
        function CheckPreConditions(obj)
            assert(obj.t1 < obj.t2,'Period 1 starts before it ends');
            assert(obj.t3 < obj.t4,'Period 2 starts before it ends');
            assert(isa(obj.binsize,'duration'),'bin size should be a duration in days');
        end
        
        % get the grid-size interactively and
        % calculate the b-value in the grid by sorting
        % the seimicity and selectiong the ni neighbors
        % to each grid point
        function results=Calculate(obj)
            
            %  make grid, calculate start- endtime etc.  ...
            
            lt =  (obj.RawCatalog.Date >= obj.t1 &  obj.RawCatalog.Date < obj.t2) ...
                | (obj.RawCatalog.Date >= obj.t3 &  obj.RawCatalog.Date <= obj.t4);
            obj.RawCatalog = obj.RawCatalog.subset(lt);
            
            
            returnFields = obj.ReturnDetails(:,1);
            returnDesc = obj.ReturnDetails(:,2);
            returnUnits = obj.ReturnDetails(:,3);
            
            interval1_bins = obj.t1 : obj.binsize : obj.t2; % starts
            interval2_bins = obj.t3 : obj.binsize : obj.t4; % starts
            interval1_edges = [interval1_bins, interval1_bins(end)+obj.binsize];
            interval2_edges = [interval2_bins, interval2_bins(end)+obj.binsize];
            
            
            % loop over all points
            
            [bvg,nEvents,maxDists,maxMag, ll]=gridfun(@calculation_function,...
                obj.RawCatalog, obj.Grid, obj.EventSelector, 5);
            % bvg will contain : [z_value, pct_change beta_value nEvents1 nEvents2] 
            
            
            
            bvg(:,strcmp('x',returnFields))=obj.Grid.X(:);
            bvg(:,strcmp('y',returnFields))=obj.Grid.Y(:);
            bvg(:,strcmp('Number_of_Events',returnFields))=nEvents;
            bvg(:,strcmp('Radius_km',returnFields))=maxDists;
            bvg(:,strcmp('max_mag',returnFields))=maxMag;
            
            
            myvalues = array2table(bvg,'VariableNames', returnFields);
            myvalues.Properties.VariableDescriptions = returnDesc;
            myvalues.Properties.VariableUnits = returnUnits;
            
            obj.Result.values=myvalues;
            
            obj.Result.period1.dateRange=[obj.t1 obj.t2];
            obj.Result.period2.dateRange=[obj.t3 obj.t4];
            
            if nargout
                results=myvalues;
            end
            % save data
            
            % plot the results
            % old and valueMap (initially ) is the z-value matrix
           
            
            %det =  'ast'; 
            %ZG.shading_style = 'interp';
            % View the b-value map
            % view_ratecomp
            
            function out=calculation_function(b)
                % calulate values at a single point 
                % calculate distance from center point and sort wrt distance

                idx_back =  b.Date >= obj.t1 &  b.Date < obj.t2 ;
                [cumu1, ~] = histcounts(b.Date(idx_back),interval1_edges);
                
                idx_after =  b.Date >= obj.t3 &  b.Date <= obj.t4 ;
                [cumu2, ~] = histcounts(b.Date(idx_after),interval2_edges);
                
                mean1 = mean(cumu1);        % mean seismicity rate in first interval
                mean2 = mean(cumu2);        % mean seismicity rate in second interval
                sum1 = sum(cumu1);          % number of earthquakes in the first interval
                sum2 = sum(cumu2);          % number of earthquakes in the second interval
                var1 = cov(cumu1);          % variance of cumu1
                var2 = cov(cumu2);          % variance of cumu2
                % remark (db): cov and var calculate the same value when applied to a vector
                ncu1 = length(interval1_bins);         % number of bins in first interval
                ncu2 = length(interval2_bins);         % number of bins in second interval
                
                as = (mean1 - mean2)/(sqrt(var1/ncu1 +var2/ncu2));
                per = -((mean1-mean2)./mean1)*100;
                
                % beta nach reasenberg & simpson 1992, time of second interval normalised by time of first interval
                bet = (sum2-sum1*ncu2/ncu1)/sqrt(sum1*(ncu2/ncu1));
                
                out = [as  per bet sum1 sum2];
                
            end
        end
        function ModifyGlobals(obj)
            obj.ZG.bvg = obj.Result.values;
        end
    end %methods
    
    methods(Static)
        function h=AddMenuItem(parent,zapFcn)
            % create a menu item
            label='Compare two periods (z, beta, probabilty)';
            h=uimenu(parent,'Label',label,'Callback', @(~,~)comp2periodz(zapFcn()));
        end
    end % static methods
end % classdef
    
        