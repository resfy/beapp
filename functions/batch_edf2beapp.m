% this function is entirely adapted from the Biosig toolbox for EEGLAB
% and from the following functions:
% pop_readedf() - Read a European data format .EDF data file.
% Author: Arnaud Delorme, CNL / Salk Institute, 13 March 2002
%
% pop_readbdf() - Read Biosemi 24-bit BDF file
% Author: Arnaud Delorme, CNL / Salk Institute, 13 March 2002

function grp_proc_info_in = batch_edf2beapp(grp_proc_info_in,markerCh)

cd(grp_proc_info_in.src_dir{1});

flist = dir('*.edf');
grp_proc_info_in.src_fname_all = {flist.name};

% load group information for files
load(grp_proc_info_in.beapp_file_info_table)
if grp_proc_info_in.beapp_run_per_file 
   beapp_file_info_table =  beapp_file_info_table(grp_proc_info_in.beapp_file_idx,:);
end

%% store information for files listed in both the user input table and the source directory 
[src_fname_all,indexes_in_table] = intersect(beapp_file_info_table.FileName,grp_proc_info_in.src_fname_all,'stable');
if isempty(src_fname_all)
    error (['BEAPP: No data listed in beapp_file_info_table found in source directory' grp_proc_info_in.src_dir{1}]);
else 
    grp_proc_info_in.src_fname_all = src_fname_all';
    
    
    for tmp =1:length(grp_proc_info_in.src_fname_all)
        fmt = strcat(grp_proc_info_in.src_fname_all{tmp}(1:end-4), '.mat');
        grp_proc_info_in.beapp_fname_all{tmp} =fmt; %grp_proc_info_in.src_fname_all;
    end
    % display(grp_proc_info_in.beapp_fname_all)
end

% if user wants to ignore specific channels, store which channels for which
% nets (otherwise get all net information from beapp_file_info_table)
if ~isempty(grp_proc_info_in.beapp_indx_chans_to_exclude)
    if ~isempty(grp_proc_info_in.src_unique_nets) && isequal(length(grp_proc_info_in.src_unique_nets),length(grp_proc_info_in.beapp_indx_chans_to_exclude))
        user_unique_nets = grp_proc_info_in.src_unique_nets;
    else 
        if isempty(grp_proc_info_in.src_unique_nets)
            error ('User has asked to exclude channels but not included net information in grp_proc_info.src_unique_nets');
        elseif ~isequal(length(grp_proc_info_in.src_unique_nets),length(grp_proc_info_in.beapp_indx_chans_to_exclude))
            error ('User has asked to exclude channels but number of nets in grp_proc_info.src_unique_nets does not \n%s',...
                'correspond to number of nets expected from grp_proc_info.beapp_indx_chans_to_exclude');
        end
    end
end

% store group net types and sampling rates (from table)
grp_proc_info_in.src_net_typ_all = beapp_file_info_table.NetType(indexes_in_table);
grp_proc_info_in.src_srate_all = beapp_file_info_table.SamplingRate(indexes_in_table);
grp_proc_info_in.src_unique_nets = unique(grp_proc_info_in.src_net_typ_all,'stable');

% check if user has given file-specific line noise specifications
if ~isnumeric(grp_proc_info_in.src_linenoise)
    if strcmp(grp_proc_info_in.src_linenoise,'input_table')
       grp_proc_info_in.src_linenoise_all = beapp_file_info_table.Line_Noise_Freq(indexes_in_table);  
    end
else
     grp_proc_info_in.src_linenoise_all = grp_proc_info_in.src_linenoise*ones(length(indexes_in_table));
end
clear tmp_flist indexes_in_table beapp_file_info_table

%load net information
% add_nets_to_library(grp_proc_info_in.src_unique_nets,grp_proc_info_in.ref_net_library_options,grp_proc_info_in.ref_net_library_dir,grp_proc_info_in.ref_eeglab_loc_dir,grp_proc_info_in.name_10_20_elecs);
[grp_proc_info_in.src_unique_net_vstructs,grp_proc_info_in.src_unique_net_ref_rows, grp_proc_info_in.src_net_10_20_elecs,grp_proc_info_in.largest_nchan] = load_nets_in_dataset(grp_proc_info_in.src_unique_nets,grp_proc_info_in.ref_net_library_options, grp_proc_info_in.ref_net_library_dir);

for curr_file = 1:length(flist)
    
    fprintf('Reading EDF format using BIOSIG...\n');

    %% resfy: read EDF file
    awal = grp_proc_info_in.src_dir; akhir = grp_proc_info_in.src_fname_all{curr_file};
    nama = strcat(awal, strcat('\', akhir));
    EDFdata = pop_biosig(nama{1}); % eeg = {EEG.data}
    EDFdata = eeg_checkset(EDFdata); 
    %markerCh
    EDFdata = pop_chanevent(EDFdata,markerCh);% 24: keystrooke marker, 26: serial marker

    eeg{1} = EDFdata.data(7:20,:);
    %harus menambahkan variable event untuk disimpan di setiap prosesnya
    file_proc_info.evt_info = EDFdata.event; 
    
    % save source file variables; resfy: ambil data dari header EDF saja
    file_proc_info.src_fname=grp_proc_info_in.src_fname_all(curr_file);%file name: EEG.filename 
    file_proc_info.src_srate=EDFdata.srate;%sampling rates: EEG.srate 
    file_proc_info.src_nchan=EDFdata.nbchan;%jumlah kanal: EEG.nbchan
    file_proc_info.src_epoch_nsamps(1)=EDFdata.pnts; %nsamps epoch: EEG.pnts 
    file_proc_info.src_num_epochs = 1; %num epoch: EEG.trials
    file_proc_info.src_linenoise =  60; %line noise: set jadi 60 langsung
    file_proc_info.epoch_inds_to_process = [1]; % assumes mat files only have one recording period
    
    % save starting beapp file variables from source information
    file_proc_info.beapp_fname={[file_proc_info.src_fname{1}(1:end-4) '.mat']}; %grp_proc_info_in.beapp_fname_all(curr_file);
    file_proc_info.beapp_srate=file_proc_info.src_srate;
    file_proc_info.beapp_bad_chans ={[]};
    file_proc_info.beapp_nchans_used=[file_proc_info.src_nchan];
    file_proc_info.beapp_indx={1:size(eeg{1},1)}; % indices for electrodes being used for analysis at current time
    file_proc_info.beapp_num_epochs = 1; % assumes mat files only have one recording period
       
    %% save file net information 
    file_proc_info.net_typ=grp_proc_info_in.src_net_typ_all(curr_file);
    uniq_net_ind = find(strcmp(grp_proc_info_in.src_unique_nets, file_proc_info.net_typ{1}));
    file_proc_info.net_vstruct = grp_proc_info_in.src_unique_net_vstructs{uniq_net_ind};
    file_proc_info.net_10_20_elecs = grp_proc_info_in.src_net_10_20_elecs{uniq_net_ind};
    file_proc_info.net_ref_elec_rnum = grp_proc_info_in.src_unique_net_ref_rows(uniq_net_ind);
    if ~isempty(grp_proc_info_in.beapp_indx_chans_to_exclude)

        uniq_net_ind_user_inputs = find(strcmp(user_unique_nets, file_proc_info.net_typ{1}));
        if isempty(uniq_net_ind_user_inputs)
            error(['User has asked to exclude channels but not included net information for net ' file_proc_info.net_typ{1} ' in grp_proc_info.src_unique_nets']);
        else
            file_proc_info.beapp_indx = {setdiff(file_proc_info.beapp_indx{1},grp_proc_info_in.beapp_indx_chans_to_exclude{uniq_net_ind_user_inputs})};
            eeg{1}(grp_proc_info_in.beapp_indx_chans_to_exclude{uniq_net_ind_user_inputs} ,:) = deal(NaN);
            file_proc_info.beapp_nchans_used=[length(file_proc_info.beapp_indx{1})];
        end
    end

    %% initialize file history information
    file_proc_info.hist_run_tag=grp_proc_info_in.hist_run_tag; % updated in each run
    file_proc_info.hist_run_table = beapp_init_file_hist_table (grp_proc_info_in.beapp_toggle_mods.Properties.RowNames);

    %% save beapp formatted files in output directory
    cd(grp_proc_info_in.beapp_toggle_mods{'format','Module_Dir'}{1});
    if ~all(cellfun(@isempty,eeg))
        
        file_proc_info = beapp_prepare_to_save_file('format',file_proc_info, grp_proc_info_in,grp_proc_info_in.src_dir{1});
        save(file_proc_info.beapp_fname{1},'file_proc_info','eeg'); %,'allEDFdata');
    end
    clearvars -except grp_proc_info_in curr_file user_unique_nets markerCh
end
clear grp_proc_info_in.src_srate_all grp_proc_info_in.src_linenoise_all grp_proc_info_in.src_net_typ_all