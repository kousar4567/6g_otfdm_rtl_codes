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


%% Function for Code block CRC Removal


function [output_bits, remainder_check] = wnNrPhyCrcRemoval(input_bits, crc_polynomial)

% Polynomial Length
len_polynomial = size(crc_polynomial,2);

crc_input = input_bits;

% Length of Input
len_input = size(crc_input,2);

% CRC Generating
count_temp = 0;
while ((len_input - count_temp) >= len_polynomial)
    crc_input_s = crc_input(1:len_polynomial);
    remainder = xor(crc_input_s , crc_polynomial);
    crc_input(1:len_polynomial) = remainder;
    
    j = 1; shft = 0;
    
    while (j <= len_polynomial)
        if(remainder(j) ~= 0)
            break;
        else
            shft = j;
            j = j + 1;
        end
    end
    
    count_temp = count_temp + shft;
    crc_input(1:shft) = [];
end

remainder_check = sum(crc_input);

if (remainder_check == 0)
    output_bits = input_bits(1:len_input-len_polynomial+1);
else
    output_bits = zeros(1,len_input-len_polynomial+1);
    remainder_check = 1;
end
