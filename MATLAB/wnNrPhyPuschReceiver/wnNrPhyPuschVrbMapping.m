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


%% Mapping to Virtual resource blocks

function [pusch_prb_loc,SRbg,toneindx1,dataStartIdx] = wnNrPhyPuschVrbMapping (NrUlUlschPDUs, ...   % Structure for the configuration parameters
                                                        n_prb_allocated,fftSize)

% bit-map for PUSCH PRG mapping in Frequency domain
% Bitmap size should be equal to Carrier Bandwidth Part
% Calculating total number of resource block groups (RBG) for a uplink carrier bandwidth part
n_pusch_rbg = ceil((NrUlUlschPDUs.nBWPSize + mod(NrUlUlschPDUs.nBWPStart, NrUlUlschPDUs.nRBGSize))/NrUlUlschPDUs.nRBGSize);
 
pusch_rbg_bitmap = NrUlUlschPDUs.nRBGIndex;
  
% Getting the exact PRB locations dedicated to PUSCH transmission
% pusch_prb_loc contains all the PRBs index allocated for PUSCH
pusch_prb_loc = zeros(1,n_prb_allocated);
 
% When PUSCH uplink Resource Allocation Type 0 is set
switch (NrUlUlschPDUs.nResourceAllocType)
    case (0)
                dataStartIdx = (fftSize - NrUlUlschPDUs.nBwSize*12)/2 + 12*NrUlUlschPDUs.nBWPStart;

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
    
            SRbg = zeros(1,length(pusch_rbg_bitmap));
   SRbg(2:end-1) = NrUlUlschPDUs.nRBGSize;
         SRbg(1) = pusch_1st_rbg_s;
       SRbg(end) = pusch_last_rbg_s;
       prb_index = 1;
       
       ind = 1;
    for i = 0:1:length(pusch_rbg_bitmap)-1
       
        % If this RBG is allocated to PUSCH 
        if (pusch_rbg_bitmap(i+1) == 1)
           
            % For the first RBG as it may have different number of PRBs
            if (i == 0)
               for j=0:1:pusch_1st_rbg_s-1
                    pusch_prb_loc(prb_index) = j + 1; % +1 because BWP will start from zero 
                    toneindx((ind-1)*12+1:ind*12) = 12*(pusch_prb_loc(prb_index)-1)+1:12*(pusch_prb_loc(prb_index)) ;
                    prb_index = prb_index + 1;
                    ind = ind+1;
               end
            % For the last RBG as it may have different number of PRBs    
            elseif (i == length(pusch_rbg_bitmap)-1)
                for j=0:1:pusch_last_rbg_s-1
                     pusch_prb_loc(prb_index) = pusch_1st_rbg_s + (i-1)*NrUlUlschPDUs.nRBGSize + j + 1; % +1 because BWP will start from zero 
                     toneindx((ind-1)*12+1:ind*12) = 12*(pusch_prb_loc(prb_index)-1)+1:12*(pusch_prb_loc(prb_index)) ;
                     prb_index = prb_index + 1;
                     ind = ind+1;
                end
        
            % For the remaining RBGs
            else
                for j=0:1:NrUlUlschPDUs.nRBGSize-1
                    pusch_prb_loc(prb_index) = (i)*NrUlUlschPDUs.nRBGSize + j + pusch_1st_rbg_s - NrUlUlschPDUs.nRBGSize + 1; % +1 because BWP will start from zero 
                    toneindx((ind-1)*12+1:ind*12) = 12*(pusch_prb_loc(prb_index)-1)+1:12*(pusch_prb_loc(prb_index)) ;
                    prb_index = prb_index + 1;
                    ind = ind+1;
                end
            end
        end
        
    end
    for ind1 = 1:NrUlUlschPDUs.nPrbAllocated*12/((NrUlUlschPDUs.nDMRSConfigType+2)*2)
        toneindx1(1,(ind1-1)*(2)+1:(2)*(ind1)) = toneindx((NrUlUlschPDUs.nDMRSConfigType+2)*2*(ind1-1) + (2-NrUlUlschPDUs.nDMRSConfigType)*(0:1) +1);
    end
    switch NrUlUlschPDUs.nDMRSConfigType
        case 0
            toneindx1(2,:) = toneindx1(1,:)+1;
        case 1
            toneindx1(2,:) = toneindx1(1,:)+2;
            toneindx1(3,:) = toneindx1(2,:)+2;
    end
% When PUSCH uplink Resource Allocation Type 1 is set
% In uplink resource allocation of type 1, the resource block assignment 
% information indicates to a scheduled UE a set of contiguously allocated 
% localized or distributed virtual resource blocks within the 
% active carrier bandwidth part.

    case (1)
       dataStartIdx = (fftSize - NrUlUlschPDUs.nBwSize*12)/2 + 12*NrUlUlschPDUs.nBWPStart+NrUlUlschPDUs.nRBStart*12;

        SRbg = [];
        for prb_index = 0:1:NrUlUlschPDUs.nRBSize-1
            pusch_prb_loc(prb_index+1) = NrUlUlschPDUs.nRBStart + prb_index + 1; % +1 because BWP will start from zero 
        end 

        toneindx1 = [];
end 

end % End of the function
    

    
