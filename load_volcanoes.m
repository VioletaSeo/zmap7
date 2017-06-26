function out = load_volcanoes(alternateFilename, volcanoVariableName)
    % loads volcano information from a file
    % by default, this loads volcao.mat, which contains
    % a Table called GVPHoloceneVolcanoes
    % This table has several fields that describe the volcano.
    % Most importantly: 
    %  VolcanoName - name of volcano
    %  LastKnownEruption - year in which eruption occurred (numeric, not a datetime)
    %  Latitude, Longitude - lat & lon in degrees
    %  Elevationm - elevation in meters

    if ~exist('alternateFilename','var')
        volcanoesFile = 'volcano.mat';
    else
        volcanoesFile = alternateFilename;
    end
    
    if ~exist('volcanoVariableName','var')
        volcanoVariableName = 'GVPHoloceneVolcanoes';
    end
    
    out = [];
    try
        XX = load(volcanoesFile, volcanoVariableName);
    catch ME
        error('unable to load volcanoes. Expected variable "%s" in file "%s"',...
        volcanoVariableName, volcanoesFile)
    end
    if isfield(XX,volcanoVariableName)
        out = XX.(volcanoVariableName);
    end
    fn = fieldnames(out);
    if ~all(ismember({'VolcanoName','Latitude','Longitude','Elevationm','LastKnownEruption'}, fn))
        warning('loaded volcano file, but it doesn''t appear to have all the required fields');
     end

end