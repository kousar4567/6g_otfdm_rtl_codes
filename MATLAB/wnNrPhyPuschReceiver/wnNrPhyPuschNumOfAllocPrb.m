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


%% This function calculates the Number of PRBs allocated to PUSCH based on Resource 
% Allocation types

function [nPrbAllocated] = wnNrPhyPuschNumOfAllocPrb (NrUlUlschPDUs)

% Number of PRBs allocated
% If Resource allocation type is 0
if (NrUlUlschPDUs.nResourceAllocType == 0)
    
    % Calculating total number of resource block groups (RBG) for a uplink carrier bandwidth part
    n_pusch_rbg = ceil((NrUlUlschPDUs.nBWPSize + mod(NrUlUlschPDUs.nBWPStart, NrUlUlschPDUs.nRBGSize))/NrUlUlschPDUs.nRBGSize);
     
    % First RBG size 
    pusch_1st_rbg_s = NrUlUlschPDUs.nRBGSize - mod(NrUlUlschPDUs.nBWPStart, NrUlUlschPDUs.nRBGSize);
        
    % last RBG size
    if (mod(NrUlUlschPDUs.nBWPStart + NrUlUlschPDUs.nBWPSize, NrUlUlschPDUs.nRBGSize) == 0)
        pusch_last_rbg_s = NrUlUlschPDUs.nRBGSize;
    else
        pusch_last_rbg_s = mod(NrUlUlschPDUs.nBWPStart + NrUlUlschPDUs.nBWPSize, NrUlUlschPDUs.nRBGSize);
    end
    
    % Counting all the 1's (except first and last) in Resource block group bitmap to calculated
    % number of RBG's allocated
    allocated_rbg = 0;
    for ind = 2:1:length(NrUlUlschPDUs.nRBGIndex)-1
        if NrUlUlschPDUs.nRBGIndex(1,ind) == 1
            allocated_rbg = allocated_rbg + 1;
        end
    end
            
    % Calculating the number of PRBs allocated considering first and last
    % RBG size
    nPrbAllocated = pusch_1st_rbg_s  * NrUlUlschPDUs.nRBGIndex(1,1) + ...
                      pusch_last_rbg_s * NrUlUlschPDUs.nRBGIndex(1,end) + ...
                      NrUlUlschPDUs.nRBGSize * allocated_rbg;

                  
% If resource allocation type is 1
elseif NrUlUlschPDUs.nResourceAllocType == 1
    nPrbAllocated = NrUlUlschPDUs.nRBSize;
end

end % End of the function