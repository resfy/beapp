%% batch_beapp_format
% convert files to BEAPP format depending on source file type.
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The Batch Electroencephalography Automated Processing Platform (BEAPP)
% Copyright (C) 2015, 2016, 2017
% Authors: AR Levin, AS M�ndez Leal, LJ Gabard-Durnam, HM O'Leary
%
% This software is being distributed with the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See GNU General
% Public License for more details.
%
% In no event shall Boston Children�s Hospital (BCH), the BCH Department of
% Neurology, the Laboratories of Cognitive Neuroscience (LCN), or software
% contributors to BEAPP be liable to any party for direct, indirect,
% special, incidental, or consequential damages, including lost profits,
% arising out of the use of this software and its documentation, even if
% Boston Children�s Hospital,the Laboratories of Cognitive Neuroscience,
% and software contributors have been advised of the possibility of such
% damage. Software and documentation is provided �as is.� Boston Children�s
% Hospital, the Laboratories of Cognitive Neuroscience, and software
% contributors are under no obligation to provide maintenance, support,
% updates, enhancements, or modifications.
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License (version 3) as
% published by the Free Software Foundation.
%
% You should receive a copy of the GNU General Public License along with
% this program. If not, see <http://www.gnu.org/licenses/>.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function grp_proc_info_in = batch_beapp_format(grp_proc_info_in,markerCh,headsetType)
disp('|====================================|');
disp('Converting data to BEAPP format');

switch grp_proc_info_in.src_format_typ
    
    case 1 % .mat exports
        grp_proc_info_in = batch_matexport2beapp(grp_proc_info_in);
    case 2 % unsegmented mffs
        grp_proc_info_in = batch_mff2beapp(grp_proc_info_in);
    case 3 % segmented mffs
        grp_proc_info_in = batch_mff2beapp(grp_proc_info_in);
    case 4 % EEGLAB
        grp_proc_info_in = batch_eeglab2beapp(grp_proc_info_in);
    case 5 % EEGLAB pre-segmented
        grp_proc_info_in = batch_eeglab2beapp(grp_proc_info_in);
    case 6 %  BDFs and EDFs
        grp_proc_info_in = batch_edf2beapp(grp_proc_info_in,markerCh);
    case 7
        grp_proc_info_in = batch_set2beapp(grp_proc_info_in,markerCh,headsetType);
        
    case 23 % EASY
        
    case 37 % separately segmented mff files, only used in special cases
        extract_separate_file_segment_info(grp_proc_info_in);
        grp_proc_info_in = batch_mff2beapp(grp_proc_info_in);
end
end
