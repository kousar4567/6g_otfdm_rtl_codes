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
% (https://creativecommons.org/licenses/by-nd/4.0/) shall apply.


%% This function calculates the length of the output of the rate matching
% based on resource allocation, modulation order, code blocks and number of
% layers

% This function produces the rate match length for each code block

function [nrPuschRatematchLen] = wnNrPhyPuschRateMatchlen (modOrder,nNrOfSymbols,nNrOfLayers, ...
                                                             L_rs, ...
                                                             L_cp,...
                                                             L_ptrs, ...
                                                             numPRBs)
                                                             
% FIXME : Number of SRS positions per PRB in PUSCH
% CSIRS is not included || Default value = 0



% Summing up all the orthogonal CDM Groups used in the current transmission
% "dmrsCdmG" gives whether that particular CDM Group is is being used for
% transmission or not.
% dmrs_pr_prb
% Number of REs allocated to NR PDSCH
% no_of_REs_allocated = nPrbAllocated * 12 * nNrOfSymbols ... % Total REs for PDSCH 
%                       - orthoCdmGroup * dmrs_pr_prb * nPrbAllocated ...   % REs to leave for PUSCH and for orthogonal DMRS
%                       - nPtrsSyms ;                                       % REs to leave for PTRS
% 
   no_of_REs_allocated=((numPRBs*12)-L_cp-L_rs-L_ptrs)*nNrOfSymbols;          
% Consider Number of Layers and Modulation order used for PDSCH
nrPuschRatematchLen = no_of_REs_allocated *  nNrOfLayers * modOrder;

end % End of the function