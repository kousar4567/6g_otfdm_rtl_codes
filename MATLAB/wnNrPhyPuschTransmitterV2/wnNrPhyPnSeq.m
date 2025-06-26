%%
% Copyright (c) 2016-2022, WiSig Networks Pvt Ltd. All rights reserved.
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



function pnSeqOut = wnNrPhyPnSeq(seed, ... % Length of the output PN Sequence  
                                 seqLen)       % Seed for PN Sequence x2
                                                          
% Offset parameter as defined in 38.211 5.2.1
Nc = 1600;

% Seed for x1 is fixed
% 31 bits seed. 1 followed by 30 0s
x1 = [1 zeros(1, 30)];

% Convert the decimal seed to binary values
% LSB at 1st position and MSB at last
% 31 bits seed
x2 = de2bi(seed, 31);

% initialize the output array with 0s 
pnSeqOut = zeros(1, seqLen);

% LFSR is implemented to calculate x1 and x2
% Appropriate bits are XORed and stored in variable 'xor'.
% Remaining bits are shifted right and MSB
% is updated by the earlier calculated XOR
offset = Nc-31;
for idx = 0:offset+seqLen-1
    tempXor = xor(x1(1), x1(4)); 
    x1 = circshift(x1, -1);
    x1(31) = tempXor;

    tempXor = xor(xor(x2(1), x2(2)), xor(x2(3), x2(4))); 
    x2 = circshift(x2, -1);
    x2(31) = tempXor;
    
    % When appropriated index value is reached, assign output equal to
    % XOR of x1 and x2 for that index value
    if (idx >= offset)
        pnSeqOut(idx-offset+1) = xor(x1(31), x2(31)); 
    end
end


