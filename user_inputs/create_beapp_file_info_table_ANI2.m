%% mat_file_info_table generation

% directory where files are stored (check me!)
table_files_src_dir = SourceDir;%'D:\Vanaya Neurolab\ANI NEW STIMULUS - DATA SAMPLE\2-PPFilesRiset';
% full path to eeglab.m within BEAPP-HAPPE (check me!)
eeglab_path = EEGlabDir;%'D:\Vanaya Neurolab\MATLAB CODES\BEAPP\beapp\Packages\eeglab14_1_2b\eeglab.m';

%% Do not edit me
cd(fileparts(which(mfilename)));

% possible names for EEG variables (resfy: don't need to modify it even we use edf)
table_save_directory = cd;
cd(table_files_src_dir)
src_eeg_vname_pos={'Category_1_Segment1', 'EEG_Segment1', 'Category_1', 'Category1'};  

flist = dir(filetype); 
flist = {flist.name}';
FileName = flist;
SamplingRate = NaN(length(flist),1);
NetType= cell(length(flist),1);
LineNoise = 60*ones(length(flist),1);%USA

beapp_file_info_table = table(FileName, SamplingRate, NetType,LineNoise);
beapp_file_info_table.Properties.VariableNames = {'FileName','SamplingRate','NetType','Line_Noise_Freq'};
beapp_file_info_table.FileName = flist;

if strcmp(filetype,'*.mat')
    for curr_file = 1: length(flist) 
        load (flist{curr_file}); 
        file_eeg_vname = intersect(who,src_eeg_vname_pos);
        disp(['Reading file number ' int2str(curr_file)]);
        if length(file_eeg_vname) ~=1
            disp(flist{curr_file})
            warning(['problem finding EEG data variable with information provided. Skipping']);
            continue;
        else
            eeg=eval(file_eeg_vname{1});
        end
       
        % modify here depending on how
        if (size(eeg,1) == 64) || (size(eeg,1) == 65)
            beapp_file_info_table.NetType(curr_file) = {'Geodesic Sensor Net 64 2.0'};
        elseif (size(eeg,1) == 128) || (size(eeg,1) == 129)
            beapp_file_info_table.NetType(curr_file) = {'HydroCel GSN 128 1.0'};
        end
    
        beapp_file_info_table.SamplingRate(curr_file) = samplingRate;
        clear samplingRate Category_1_Segment1 EEG_Segment1 eeg Category_1 Category1
    end
elseif strcmp(filetype,'*.edf')
    %resfy
    for curr_file = 1: length(flist)
        if headsetType == 'emotiv'
            beapp_file_info_table.NetType(curr_file) = {'Emotiv EPOC Plus/X headset 14'}; %{flist{curr_file}(end-41:end-37)};
            beapp_file_info_table.SamplingRate(curr_file) = 128;
        elseif headsetType == 'deymed'
            beapp_file_info_table.NetType(curr_file) = {'Deymed Diagnostig EEG'}; %{flist{curr_file}(end-41:end-37)};
            beapp_file_info_table.SamplingRate(curr_file) = 128;
        end
    end
elseif strcmp(filetype,'*.set')
    %resfy
    for curr_file = 1: length(flist) 
        if headsetType == 'emotiv'
            beapp_file_info_table.NetType(curr_file) = {'Emotiv EPOC Plus/X headset 14'}; %{flist{curr_file}(end-41:end-37)};
            beapp_file_info_table.SamplingRate(curr_file) = 128;
        elseif headsetType == 'deymed'
            beapp_file_info_table.NetType(curr_file) = {'Deymed Diagnostig EEG'}; %{flist{curr_file}(end-41:end-37)};
            beapp_file_info_table.SamplingRate(curr_file) = 128;
        end
    end
end
cd(table_save_directory);
save('beapp_file_info_table.mat','beapp_file_info_table');

