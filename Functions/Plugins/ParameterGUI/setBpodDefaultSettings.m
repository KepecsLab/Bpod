function s = setBpodDefaultSettings(s, defaults)
% FS
% allows for new settings fields to be added to protocol while still
% using old protocol settings
%     
% s- settings structure
% defaults- cell array specifying settings fields and default values
    
% Usage: S = BpodSystem.ProtocolSettings
% defaults = {'GUI.Epoch', 1; OdorTime, 1};
% S = setBpodDefaultSettings(S, defaults);



for counter = 1:size(defaults, 1)
    sf = defaults{counter, 1}; % settings field
    sv = defaults{counter, 2}; % settings value
    % check to see if field exists
    periods = strfind(sf, '.');
    
    if isempty(periods)
        lastField = sf;
        firstFields = '';
    else
        lastField = sf(periods(end)+1 : end);
        firstFields = sf(1 : periods(end)-1); 
    end

    fieldSet = [];
    expression = ['fieldSet=isfield(s.' firstFields ',' '''' lastField ''');'];
    % if the whole thing doesn't evaulate then you need to use the default value regardless, e.g.
    % if GUIMeta doesn't exist at all you need to create it as well as
    % associated subfields
    try
        eval(expression);
    catch
        fieldSet = 0;
    end
    
    % if not, then create field and assign default values
    if ~fieldSet
        expression = ['s.' sf '=sv;'];
        eval(expression);
    end
end
    
    