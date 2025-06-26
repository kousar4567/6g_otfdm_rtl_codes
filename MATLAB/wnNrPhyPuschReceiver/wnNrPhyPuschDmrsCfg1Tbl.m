%%
% Copyright (c) 2016-2018, WiSig Networks Pvt Ltd. All rights reserved.
% www.wisig.com
% 
% All information contained herein is property of WiSig Networks Pvt Ltd. 
% unless otherwise explicitly mentioned.
% 
% The intellectual and technical concepts in this file are proprietary 
% to WiSig Networks and may be covered by granted or in process national
% and international patents and are protect by trade secrets and       
% copyright law.
% 
% Redistribution and use in source and binary forms of the content in  
% this file, with or without modification are not permitted unless     
% permission is explicitly granted by WiSig Networks.                   
% If WiSig Networks permits this source code to be used as a part of 
% open source project, the terms and conditions of CC-By-ND (No Derivative) license
% (https://creativecommons.org/licenses/by-nd/4.0/legalcode) shall apply.




% 38.211 (According to release 15), Table 6.4.1.1.2-1: Parameters for pusch DM-RS configuration type 1.

function [cdm_group, delta, wf_k, wt_l] = wnNrPhyPuschDmrsCfg1Tbl (port_number, ...
                                                                   k_desh, ...
                                                                   l_desh)

% port_number=2;k_desh=0; l_desh =0;
    % To access this :: pusch_dmrs_config01_cdm_group(mod(port_number,1000))
    pusch_dmrs_config01_cdm_group = [0,0,1,1,0,0,1,1];

    % To access this :: pusch_dmrs_config01_delta(mod(port_number,1000))
    pusch_dmrs_config01_delta = [0,0,1,1,0,0,1,1];

    % To access this :: pusch_dmrs_config01_wf_k(mod(port_number,1000),k_desh)
    pusch_dmrs_config01_wf_k = [+1,+1,+1,+1,+1,+1,+1,+1; ...
                                +1,-1,+1,-1,+1,-1,+1,-1];

    % To access this :: pusch_dmrs_config01_wt_l(mod(port_number,1000), l_desh)
    pusch_dmrs_config01_wt_l = [+1,+1,+1,+1,+1,+1,+1,+1; ...
                                +1,+1,+1,+1,-1,-1,-1,-1];
                            
     cdm_group =  pusch_dmrs_config01_cdm_group(mod(port_number,1000)+1);
     delta     =  pusch_dmrs_config01_delta(mod(port_number,1000)+1);
     wf_k      =  pusch_dmrs_config01_wf_k(k_desh+1,mod(port_number,1000)+1);
     wt_l      =  pusch_dmrs_config01_wt_l(l_desh+1,mod(port_number,1000)+1 );
                            
end % End of the function