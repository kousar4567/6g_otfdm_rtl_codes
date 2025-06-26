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


%% Function for Code Block Segmentation and Code block CRC Attachment for
% NR-PUSCH

function [nrPuschCbsFillOut, nPuschCodeBlks, eachCodeBlkSize, Zc_min, eachCodeBlkLenWithCrc, Kb, mb, ii] = ...
                                                                     wnNrPhyPuschCbSegCrcAttach(puschWithCrc, ...
                                                                                                data_len_pusch_in, ...
                                                                                                puschCrcLen, ...
                                                                                                puschLdpcBaseGraph, ...
                                                                                                maxCodeBlockSize, ...
                                                                                                filler_bit)
                                                               
% Table 5.3.2-1 in TS38.212, Release 15
ldpc_lifting_size_set_Zc = [2,4,8,16,32,64,128,256, ...
                            3,6,12,24,48,96,192,384, ...
                            5,10,20,40,80,160,320, ...
                            7,14,28,56,112,224, ...
                            9,18,36,72,144,288, ...
                            11,22,44,88,176,352, ...
                            13,26,52,104,208, ...
                            15,30,60,120,240];

LDPC_Kb = 0;
eachCodeBlkSize=0;
Kb=0;
mb=0;

% Kb is a constant to select LDPC_Lifting_size_values                        
switch (puschLdpcBaseGraph )
    case 1
        LDPC_Kb = 22;
        Kb = 22;
        mb = 46;
    case 2
        mb = 42;
        Kb = 10;
        if ((data_len_pusch_in + puschCrcLen) > 640)
            LDPC_Kb = 10;
        elseif ((data_len_pusch_in + puschCrcLen) > 560)
            LDPC_Kb = 9;
        elseif ((data_len_pusch_in + puschCrcLen) > 192)
            LDPC_Kb = 8;
        else
            LDPC_Kb = 6;
        end
end 
%  
    nrPuschCbsOut = [];%zeros(1,280);%length(puschWithCrc));%80); 
    temp_code_block = [];
% Code block won't be segmented
if ((data_len_pusch_in + puschCrcLen) <= maxCodeBlockSize)
    nrPuschCbsOut = puschWithCrc;
%     nrPuschCbsOut(1:length(puschWithCrc)) = puschWithCrc;
    
    % Total code blocks will remain 01 
    nPuschCodeBlks = 1;
    
    % Code block length will remain same
    pdsch_code_block_len = data_len_pusch_in + puschCrcLen;
   
   
% Code block will be segmented 
else
    % Total code blocks
    nPuschCodeBlks = ceil((data_len_pusch_in + puschCrcLen)/(maxCodeBlockSize - 24));
    
    % Code block length
    pdsch_code_block_len = (data_len_pusch_in + puschCrcLen) + nPuschCodeBlks*24;
    
    % Length of each code block without CRC
    each_code_block_len = pdsch_code_block_len/nPuschCodeBlks - 24;
   
    %Polynomial for CRC24B
    CRC24B = [1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1];

 
   each_code_block_len=floor(each_code_block_len)  ;
   each_CBlen_with_crc_size = each_code_block_len+length(CRC24B)-1;

   nrPuschCbsOut = zeros(nPuschCodeBlks,each_CBlen_with_crc_size);
    
    % Segment the input into multiple code blocks of length = each_code_block_len
    for i = 1:1:nPuschCodeBlks
        temp_code_block = puschWithCrc(1 + (i-1)*each_code_block_len : each_code_block_len*i);
        % Attach CRC24B to each code block
        [nrPuschCbsOut(i,1:each_CBlen_with_crc_size), ~] = wnNrPhyCrcGenAttach (temp_code_block, CRC24B);
    end
    
end

% Length of each code block with CRC
eachCodeBlkLenWithCrc = pdsch_code_block_len/nPuschCodeBlks;

% Sorting the LDPC lifting size valtues to get Zc
sorted_Zc = sort(ldpc_lifting_size_set_Zc);

% Finding the minimum value of Zc in all sets of lifting sizes such that
% Kb * Zc >= eachCodeBlkLenWithCrc
ii = 1;
while (sorted_Zc(ii) < eachCodeBlkLenWithCrc/LDPC_Kb)
    ii = ii + 1;
end
Zc_min = sorted_Zc(ii);

% Calculating the final code block size based on LDPC l;ifting size table
switch (puschLdpcBaseGraph)
    case 1
        eachCodeBlkSize = 22*Zc_min;
    case 2
        eachCodeBlkSize = 10*Zc_min;
end

F = eachCodeBlkSize - eachCodeBlkLenWithCrc;

eachCodeBlkLenWithCrc=floor(eachCodeBlkLenWithCrc);

if size(nrPuschCbsOut,2) == eachCodeBlkLenWithCrc
    new_size = F;
else
    new_size = eachCodeBlkSize - size(nrPuschCbsOut,2);
end

% size(nrPuschCbsOut)
nrPuschCbsFillOut = zeros(nPuschCodeBlks,eachCodeBlkSize);
nrPuschCbsFillOut(:,1:eachCodeBlkLenWithCrc)=nrPuschCbsOut(:,1:eachCodeBlkLenWithCrc);
% Finally each code block will be filled with 'filler bits' (here -2)
% from 'eachCodeBlkLenWithCrc' to 'eachCodeBlkSize'
% nrPuschCbsOut = [nrPuschCbsOut zeros(1,new_size)];
for i = 1:1:nPuschCodeBlks
    nrPuschCbsFillOut(i, (eachCodeBlkLenWithCrc + 1) : eachCodeBlkSize) = filler_bit;
end                                                               

end % End of the function