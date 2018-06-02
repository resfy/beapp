function [evt_info] = beapp_read_eeglab_events(eeglab_event_struct,behav_coding_bad_value,...
            src_eeglab_cond_info_field)

%% read in eeglab events
    
if ~isempty(eeglab_event_struct)
    % event sub function
    % add event label, time latency, and sample number to EEGLAB structure
    for curr_event=1:length(eeglab_event_struct)
        
        % assumes .type field either contains actual type (condition
        % specific) or presentation tag name
        evt_info(curr_event).evt_codes= eeglab_event_struct(curr_event).type;
        %evt_info(curr_event).type= eeglab_event_struct(curr_event).type;
        
        evt_info(curr_event).evt_times = {''};
        
        % assumes init_time is in seconds 
        if isfield(eeglab_event_struct, 'init_time')
            evt_info(curr_event).evt_times_micros_rel = eeglab_event_struct(curr_event).init_time*1000;
        elseif isfield(eeglab_event_struct, 'init_time_micros')
            evt_info(curr_event).evt_times_micros_rel = eeglab_event_struct(curr_event).init_time_micros;
        else
            evt_info(curr_event).evt_times_micros_rel = NaN;
        end
        
        if isfield (eeglab_event_struct,'epoch')
            
            % should only be 1 for unsegmented files
            evt_info(curr_event).evt_times_epoch_rel = eeglab_event_struct(curr_event).epoch;
            if  ~grp_proc_info_in.src_format_typ ==3 && (eeglab_event_struct(curr_event).epoch > 1)
                warning ([file_proc_info.beapp_fname{1} ': src format typ indicated as unsegmented .set but file contains more than one segment, confirm unsegmented']);
            end
        else
            evt_info(curr_event).evt_times_epoch_rel = 1;
        end
        
        % assumes latency is in samples not time
        evt_info(curr_event).evt_times_samp_rel = eeglab_event_struct(curr_event).latency;
        
        if isfield(eeglab_event_struct, 'urevent')
            evt_info(curr_event).evt_ind = eeglab_event_struct(curr_event).urevent;
        else 
            evt_info(curr_event).evt_ind = NaN;
        end
        
        if isfield(eeglab_event_struct, 'duration')
            evt_info(curr_event).evt_duration_samps = eeglab_event_struct(curr_event).duration;
        else
            evt_info(curr_event).evt_duration_samps = 0;
        end
        
        if isfield(eeglab_event_struct, src_eeglab_cond_info_field)
            evt_info(curr_event).evt_cel_type = getfield(eeglab_event_struct,curr_event,src_eeglab_cond_info_field);
        else
            evt_info(curr_event).evt_cel_type = NaN;
        end

           
        if isfield(eeglab_event_struct,'behav_code')
            if ~isempty(eeglab_event_struct(curr_event).behav_code)
                
                evt_info(curr_event).behav_code = ismember(eeglab_event_struct(curr_event).behav_code,behav_coding_bad_value);
            else
                evt_info(curr_event).behav_code = NaN;
            end
        else 
            evt_info(curr_event).behav_code = NaN;
        end
    end
end