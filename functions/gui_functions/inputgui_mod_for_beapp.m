% inputgui_mod_for_beapp() - Modified very slightly from EEGLAB's inputgui
% to allow for run flexibility.
%
% A comprehensive gui automatic builder. This function helps
%              to create GUI very quickly without bothering about the
%              positions of the elements. After creating a geometry,
%              elements just place themselves in the predefined
%              locations. It is especially useful for figures in which
%              you intend to put text buttons and descriptions.
%
% Usage:
%   >> [ outparam ] = inputgui( 'key1', 'val1', 'key2', 'val2', ... );
%   >> [ outparam userdat strhalt outstruct] = ...
%             inputgui( 'key1', 'val1', 'key2', 'val2', ... );
%
% Inputs:
%   'geom'       - cell array of cell array of integer vector. Each cell
%                  array defines the coordinate of a given input in the
%                  following manner: { nb_row nb_col [x_topcorner y_topcorner]
%                  [x_bottomcorner y_bottomcorner] };
%   'geometry'   - cell array describing horizontal geometry. This corresponds
%                  to the supergui function input 'geomhoriz'
%   'geomvert'   - vertical geometry argument, this argument is passed on to
%                  the supergui function
%   'uilist'     - list of uicontrol lists describing elements properties
%                  { { ui1 }, { ui2 }... }, { 'uiX' } being GUI matlab
%                  uicontrol arguments such as { 'style', 'radiobutton',
%                  'String', 'hello' }. See Matlab function uicontrol() for details.
%                   Uitables can also be created using this function with the following format: 
%                     {{'style','uitable','data', data,...
%                 'ColumnEditable',[false, true],'ColumnName',{'Headers','Headers2'},...
%                 'ColumnFormat',{'char','logical'},'tag','table_name'}}
%   'helpcom'    - optional help command
%   'helpbut'    - text for help button
%   'title'      - optional figure title
%   'userdata'   - optional userdata input for the figure
%   'mode'       - ['normal'|'noclose'|'plot' fignumber]. Either wait for
%                  user to press OK or CANCEL ('normal'), return without
%                  closing window input ('noclose'), only draw the gui ('plot')
%                  or process an existing window which number is given as
%                  input (fignumber). Default is 'normal'.
%   'eval'       - [string] command to evaluate at the end of the creation
%                  of the GUI but before waiting for user input.
%   'screenpos'  - see supergui.m help message.
%   'skipline'   - ['on'|'off'] skip a row before the "OK" and "Cancel"
%                  button. Default is 'on'.
% 'tag' --  figure tag. default is 'subsection_template_fig';...
% 'buttoncolor'  - figure button color (def   [0.6000    0.8000    1.0000])
%     'backcolor' - figure background color (def  [0.8590, 1.0000, 1.0000];)...
%     'nextbutton' -  {'on','off'} def 'off' -- add a next button to figure;...
%     'backbutton' -  {'on','off'} def 'off' -- add a back button to figure;...
%     'nextbuttoncall' - button call for next button
%     'backbuttoncall' - button call for back button
%     'mutetagwarn' -- mute warnings for generating a figure with the same
%     tag as another figure    def = 0
% 'adv_geometry' -- geometry for associated advanced settings
%   'adv_uilist'   -- uilist for associated advanced settings 
%   'adv_geomvert' 'real' -- vertical geometry for associated advanced
%   settings
    
%
% Output:
%   outparam   - list of outputs. The function scans all lines and
%                add up an output for each interactive uicontrol, i.e
%                edit box, radio button, checkbox and listbox.
%   userdat    - 'userdata' value of the figure.
%   strhalt    - the function returns when the 'userdata' field of the
%                button with the tag 'ok_adv'  or is modified. This returns the
%                new value of this field.
%                 Possible values are:
%                 'retuninginputui' if user selects Save button
%                 'retuninginputui_next' if user selects next button
%                 'retuninginputui_back' if user selects back button
%                 '' if user selects Cancel        
%   outstruct  - returns outputs as a structure (only tagged ui controls
%                are considered). The field name of the structure is
%                the tag of the ui and contain the ui value or string.
%   instruct   - resturn inputs provided in the same format as 'outstruct'
%                This allow to compare in/outputs more easy.
%
%
% Note: the function also adds three buttons at the bottom of each
%       interactive windows: 'CANCEL', 'HELP' (if callback command
%       is provided) and 'OK'.
%
% Example:
%   res = inputgui('geometry', { 1 1 }, 'uilist', ...
%                         { { 'style' 'text' 'string' 'Enter a value' } ...
%                           { 'style' 'edit' 'string' '' } });
%
%   res = inputgui('geom', { {2 1 [0 0] [1 1]} {2 1 [1 0] [1 1]} }, 'uilist', ...
%                         { { 'style' 'text' 'string' 'Enter a value' } ...
%                           { 'style' 'edit' 'string' '' } });
%
% Author: Arnaud Delorme, CNL / Salk Institute, La Jolla, 1 Feb 2002
%
% See also: supergui(), eeglab()

% Copyright (C) Arnaud Delorme, CNL/Salk Institute, 27 Jan 2002, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [result, userdat, strhalt, resstruct, instruct,strhalt_adv,resstruct_adv] = inputgui_mod_for_beapp( varargin);

if nargin < 2
    help inputgui;
    return;
end;

% decoding input and backward compatibility
% -----------------------------------------
if isstr(varargin{1})
    options = varargin;
else
    options = { 'geometry' 'uilist' 'helpcom' 'title' 'userdata' 'mode' 'geomvert' };
    options = { options{1:length(varargin)}; varargin{:} };
    options = options(:)';
end;

% checking inputs
% ---------------
g = finputcheck(options, { 'geom'     'cell'                []      {}; ...
    'geometry' {'cell','integer'}    []      []; ...
    'uilist'   'cell'                []      {}; ...
    'helpcom'  { 'string','cell' }   { [] [] }      ''; ...
    'title'    'string'              []      ''; ...
    'eval'     'string'              []      ''; ...
    'helpbut'  'string'              []      'Help'; ...
    'skipline' 'string'              { 'on' 'off' } 'on'; ...
    'addbuttons' 'string'            { 'on' 'off' } 'on'; ...
    'userdata' ''                    []      []; ...
    'getresult' 'real'               []      []; ...
    'minwidth'  'real'               []      200; ...
    'screenpos' ''                   []      []; ...
    'mode'     ''                    []      'normal'; ...
    'horizontalalignment'  'string'   { 'left','right','center' } 'left';...
    'geomvert' 'real'                []       []; ... % start beapp additions
    'buttoncolor' 'real'             []       [0.6000    0.8000    1.0000];...
    'backcolor' 'real'                []       [0.8590, 1.0000, 1.0000];...
    'nextbutton' 'string'        {'on','off'} 'off';...
    'backbutton' 'string'        {'on','off'} 'off';...
    'nextbuttoncall' 'string' [] '';...
    'backbuttoncall' 'string' [] '';...
    'tag'        'string'        [] 'subsection_template_fig';...
    'mutetagwarn' 'real'      [0, 1] 0;...
    'popoutpanel' 'real'      [0, 1] 0;...
    'adv_geometry' {'cell','integer'}    []      []; ...
    'adv_uilist'   'cell'                []      {}; ...
    'adv_geomvert' 'real'                []       []; ... % start beapp additions
    'grp_proc_info_in' '' [] [];...
    }, 'inputgui');
if isstr(g), error(g); end;

if isempty(g.getresult)
    if isstr(g.mode)
        fig = figure('visible', 'off');
        set(fig, 'name', g.title);
        set(fig, 'userdata', g.userdata);
        
        if ~g.mutetagwarn % if not part of a current panel progression
            % beapp add start
            if ~isempty(findobj('tag',g.tag'))
                
                if g.popoutpanel == 1
                    answer = questdlg('You have another settings panel for this module open. Would you like to close that panel and open the selected settings?',...
                        'Multiple Module Settings Open','Go Back','Yes,close the other settings and continue','Go Back');
                else
                    answer = questdlg('You have settings for another module open. Would you like to close those and open the selected  settings?',...
                        'Multiple Module Settings Open','Go Back','Yes,close the other settings and continue','Go Back');
                end
                
                switch answer
                    
                    case 'Go Back'
                        result = [];
                        userdat =[];
                        strhalt = '';
                        resstruct = [];
                        instruct =[];
                        
                        % move open window to center
                        movegui(findobj('tag',g.tag'),'center');
                        uistack(findobj('tag',g.tag'),'top');
                        return;
                    case 'Yes,close the other settings and continue'
                        close(findobj('tag',g.tag));
                end
            end
        end
        
        set(fig, 'tag',g.tag);
        % beapp add end
        
        if ~iscell( g.geometry )
            oldgeom = g.geometry;
            g.geometry = {};
            for row = 1:length(oldgeom)
                g.geometry = { g.geometry{:} ones(1, oldgeom(row)) };
            end;
        end
        
        % skip a line
        if strcmpi(g.skipline, 'on'),
            g.geometry = { g.geometry{:} [1] };
            if ~isempty(g.geom)
                for ind = 1:length(g.geom)
                    g.geom{ind}{2} = g.geom{ind}{2}+1; % add one row
                end;
                g.geom = { g.geom{:} {1 g.geom{1}{2} [0 g.geom{1}{2}-2] [1 1] } };
            end;
            g.uilist   = { g.uilist{:}, {} };
        end;
        
        
        % beapp add -- add  next and back buttons to geometry counts
        if strcmpi(g.nextbutton, 'on') || strcmpi(g.backbutton, 'on'),
            
            % add a row with 4 slots
            g.geometry = { g.geometry{:} [1 1 1 1] };
            if ~isempty(g.geom)
                for ind = 1:length(g.geom)
                    g.geom{ind}{2} = g.geom{ind}{2}+1; % add one row
                end;
                g.geom = { g.geom{:} ...
                    {4 g.geom{1}{2} [0 g.geom{1}{2}-1] [1 1] }, ...
                    {4 g.geom{1}{2} [1 g.geom{1}{2}-1] [1 1] }, ...
                    {4 g.geom{1}{2} [2 g.geom{1}{2}-1] [1 1] }, ...
                    {4 g.geom{1}{2} [3 g.geom{1}{2}-1] [1 1] } };
            end;
            
            % fill in empty space for first 2 slots
            g.uilist = { g.uilist{:}, {} {} };
            if strcmpi(g.backbutton, 'on'),
                g.uilist = { g.uilist{:}, { 'width' 80 'align' 'right' 'Style', 'pushbutton', 'string', 'Back', 'tag' 'back' 'callback',...
                    'set(findobj(''parent'', gcf, ''tag'', ''ok''), ''userdata'', ''retuninginputui_back'');' } };
            else
                g.uilist = { g.uilist{:}, {'width' 80 'style','text','string','', 'tag', 'back'} };
            end
            if strcmpi(g.nextbutton, 'on'),
                g.uilist = { g.uilist{:}, { 'width' 80 'align' 'right' 'stickto' 'on' 'Style', 'pushbutton', 'tag', 'next', 'string', 'Next',...
                    'callback', 'set(findobj(''parent'', gcf, ''tag'', ''ok''), ''userdata'', ''retuninginputui_next'');' } };
            else
                g.uilist = { g.uilist{:}, { 'width' 80 'align' 'right' 'stickto' 'on' 'Style', 'text', 'tag', 'next', 'string', ''} };
            end
        end;
        
        % add buttons
        if strcmpi(g.addbuttons, 'on'),
            g.geometry = { g.geometry{:} [1 1 1 1] };
            if ~isempty(g.geom)
                for ind = 1:length(g.geom)
                    g.geom{ind}{2} = g.geom{ind}{2}+1; % add one row
                end;
                g.geom = { g.geom{:} ...
                    {4 g.geom{1}{2} [0 g.geom{1}{2}-1] [1 1] }, ...
                    {4 g.geom{1}{2} [1 g.geom{1}{2}-1] [1 1] }, ...
                    {4 g.geom{1}{2} [2 g.geom{1}{2}-1] [1 1] }, ...
                    {4 g.geom{1}{2} [3 g.geom{1}{2}-1] [1 1] } };
            end;
            if ~isempty(g.helpcom)
                if ~iscell(g.helpcom)
                    g.uilist = { g.uilist{:}, { 'width' 80 'align' 'left' 'Style', 'pushbutton', 'string', g.helpbut, 'tag', 'help', 'callback', g.helpcom } {} };
                else
                    g.uilist = { g.uilist{:}, { 'width' 80 'align' 'left' 'Style', 'pushbutton', 'string', 'Help gui', 'callback', g.helpcom{1} } };
                    g.uilist = { g.uilist{:}, { 'width' 80 'align' 'left' 'Style', 'pushbutton', 'string', 'More help', 'callback', g.helpcom{2} } };
                end;
            else
                g.uilist = { g.uilist{:}, {} {} };
            end;
            g.uilist = { g.uilist{:}, { 'width' 80 'align' 'right' 'Style', 'pushbutton', 'string', 'Cancel', 'tag' 'cancel' 'callback', 'close gcbf' } };
            g.uilist = { g.uilist{:}, { 'width' 80 'align' 'right' 'stickto' 'on' 'Style', 'pushbutton', 'tag', 'ok', 'string', 'Save', 'callback', 'set(gcbo, ''userdata'', ''retuninginputui'');' } };
        end;
        
        
        % add the three buttons (CANCEL HELP OK) at the bottom of the GUI
        % ---------------------------------------------------------------
        if ~isempty(g.geom)
            [tmp tmp2 allobj] = supergui_mod_for_beapp( 'fig', fig, 'minwidth', g.minwidth, 'geom', g.geom, ...
                'uilist', g.uilist, 'screenpos', g.screenpos,'backcolor',g.backcolor,'buttoncolor',g.buttoncolor,'horizontalalignment',g.horizontalalignment );
        elseif isempty(g.geomvert)
            [tmp tmp2 allobj] = supergui_mod_for_beapp( 'fig', fig, 'minwidth', g.minwidth, 'geomhoriz', g.geometry, ...
                'uilist', g.uilist, 'screenpos', g.screenpos,'backcolor',g.backcolor,'buttoncolor',g.buttoncolor,'horizontalalignment',g.horizontalalignment  );
        else
            if strcmpi(g.skipline, 'on'),  g.geomvert = [g.geomvert(:)' 1]; end;
            if strcmpi(g.addbuttons, 'on'),g.geomvert = [g.geomvert(:)' 1]; end;
            if strcmpi(g.nextbutton, 'on')||strcmpi(g.backbutton, 'on'),g.geomvert = [g.geomvert(:)' 1]; end;
            [tmp tmp2 allobj] = supergui_mod_for_beapp( 'fig', fig, 'minwidth', g.minwidth, 'geomhoriz', g.geometry, ...
                'uilist', g.uilist, 'screenpos', g.screenpos, 'geomvert', g.geomvert(:)','backcolor',g.backcolor,'buttoncolor',g.buttoncolor, 'horizontalalignment',g.horizontalalignment  );
        end;
    else
        fig = g.mode;
        set(findobj('parent', fig, 'tag', 'ok'), 'userdata', []);
        allobj = findobj('parent',fig);
        allobj = allobj(end:-1:1);
    end;
    
    % evaluate command before waiting?
    % --------------------------------
    if ~isempty(g.eval), eval(g.eval); end;
    instruct = outstruct(allobj); % Getting default values in the GUI.
    
    % create figure and wait for return
    % ---------------------------------
    if isstr(g.mode) & (strcmpi(g.mode, 'plot') | strcmpi(g.mode, 'return') )
        if strcmpi(g.mode, 'plot')
            return; % only plot and returns
        end;
    else
        strhalt_adv = '';
        resstruct_adv = [];
%         move_on = false;
%         while ~move_on
            waitfor( findobj('parent', fig, 'tag', 'ok'), 'userdata');
            
            strhalt= get(findobj('parent', fig, 'tag', 'ok'), 'userdata');
            % make and store settings from adv panel
            if isequal(strhalt,'adv_settings_panel')
                
                [~, ~, strhalt_adv, resstruct_adv, ~] = adv_inputgui_mod_for_beapp('geometry',g.adv_geometry,...
                    'uilist',g.adv_uilist,'geomvert',g.adv_geomvert,'tag',['adv_' g.tag]);
                
                 set(findobj('parent', fig, 'tag', 'ok'), 'userdata','refreshinputui');
                
%             else
%                 move_on =1;
            end
        %end
            
    end;
else
    fig = g.getresult;
    allobj = findobj('parent',fig);
    allobj = allobj(end:-1:1);
end;

result    = {};
userdat   = [];
strhalt   = '';
resstruct = [];

if ~(ishandle(fig)), return; end % Check if figure still exist

% output parameters
% -----------------
strhalt= get(findobj('parent', fig, 'tag', 'ok'), 'userdata');

[resstruct,result] = outstruct(allobj); % Output parameters
userdat = get(fig, 'userdata');
% if nargout >= 4
% 	resstruct = myguihandles(fig, g);
% end;

if isempty(g.getresult) && isstr(g.mode) && ( strcmp(g.mode, 'normal') || strcmp(g.mode, 'return') )
%     if (~strcmp(strhalt, 'retuninginputui_back') && ~strcmp(strhalt, 'retuninginputui_next'))
        close(fig);
%     end
end;
drawnow; % for windows

% function for gui res (deprecated)
% --------------------
% function g = myguihandles(fig, g)
% 	h = findobj('parent', fig);
%         if ~isempty(get(h(index), 'tag'))
% 			try,
% 				switch get(h(index), 'style')
% 				 case 'edit', g = setfield(g, get(h(index), 'tag'), get(h(index), 'string'));
% 				 case { 'value' 'radio' 'checkbox' 'listbox' 'popupmenu' 'radiobutton'  }, ...
% 					  g = setfield(g, get(h(index), 'tag'), get(h(index), 'value'));
%                 end;
% 			catch, end;
% 		end;

function [resstructout, resultout] = outstruct(allobj)
counter   = 1;
resultout    = {};
resstructout = [];

for index=1:length(allobj)
    if isnumeric(allobj), currentobj = allobj(index);
    else                  currentobj = allobj{index};
    end;
    if isnumeric(currentobj) | ~isprop(currentobj,'GetPropertySpecification') % To allow new object handles
        try,
            objstyle = get(currentobj, 'style');
            switch lower( objstyle )
                case { 'listbox', 'checkbox', 'radiobutton' 'popupmenu' 'radio' }
                    resultout{counter} = get( currentobj, 'value');
                    if ~isempty(get(currentobj, 'tag')), resstructout = setfield(resstructout, get(currentobj, 'tag'), resultout{counter}); end;
                    counter = counter+1;
                case 'edit'
                    resultout{counter} = get( currentobj, 'string');
                    if ~isempty(get(currentobj, 'tag')), resstructout = setfield(resstructout, get(currentobj, 'tag'), resultout{counter}); end;
                    counter = counter+1;
                    
            end;
        catch,
            try
                switch lower(get(currentobj,'type'))
                    case 'uitable'
                        tmp_uitable_holder.data = get(currentobj, 'data');
                        tmp_uitable_holder.header = get(currentobj, 'ColumnName'); % allows for duplicate names
                        resultout{counter} = tmp_uitable_holder;
                        if ~isempty(get(currentobj, 'tag')), resstructout = setfield(resstructout, get(currentobj, 'tag'), resultout{counter}); end;
                        counter = counter+1;
                        % will add in panels and tabs at some point
                end
            catch
            end
        end;
    else
        ps              = currentobj.GetPropertySpecification;
        resultout{counter} = arg_tovals(ps,false);
        count = 1;
        while isfield(resstructout, ['propgrid' int2str(count)])
            count = count + 1;
        end;
        resstructout = setfield(resstructout, ['propgrid' int2str(count)], arg_tovals(ps,false));
    end;
end;