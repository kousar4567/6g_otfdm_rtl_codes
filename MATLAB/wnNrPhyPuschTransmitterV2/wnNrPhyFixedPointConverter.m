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
%%

function [Data_out,Data_size,Dmrs_out,Dmrs_size,Ptrs_out,Ptrs_size] = wnNrPhyFixedPointConverter(precoder_real,precoder_imag,numLayers,precoderOutSize,...
    dmrsReal,dmrsImag,dmrsOutSize,nNrofDMRSSymbols);
 
    % Initializing the output variable
    % Each element is of 64 bits
    Data_out = zeros(1,precoderOutSize,'int64');
    Dmrs_out = zeros(1,dmrsOutSize*nNrofDMRSSymbols,'int64');

    % Data_out1 is an array of 2 elements each of 32 bits size
    % The two elements are concatenated and passed to the Data_out variable
    Data_out1 = zeros(1,2,'int32');
    Dmrs_out1 = zeros(1,2,'int32');

    % Concatinating real and imag values of two layers wihin a 64-bit variable
    for i= 1:precoderOutSize
       for j= 1:numLayers
            
            real = int16(precoder_real(j,i) * 2^14);
            imag = int16(precoder_imag(j,i) * 2^14);
            
            Data_out1(j) = bitshift(int32(imag), 16)+ bitand( int32(real), int32(65535));
            
       end
       Data_out(i) =  bitshift(int64(Data_out1(2)), 32)+ bitand( int64(Data_out1(1)), int64(4294967295));

    end

     % DMRS Concatinating real and imag values of two layers wihin a 64-bit variable
    for k = 0:nNrofDMRSSymbols-1
     for i = 1:dmrsOutSize
       for j = 1:numLayers
            
            Dmrs_real_reg = int16(dmrsReal(i,k+1,j) * 2^14);
            Dmrs_imag_reg = int16(dmrsImag(i,k+1,j) * 2^14);
            
            Dmrs_out1(j) = bitshift(int32(Dmrs_imag_reg), 16)+ bitand( int32(Dmrs_real_reg), int32(65535));
            if numLayers == 1
                Dmrs_out1(2) = bitshift(int32(Dmrs_imag_reg), 16)+ bitand( int32(Dmrs_real_reg), int32(65535));
            end
       end
       Dmrs_out(k*dmrsOutSize+i) =  bitshift(int64(Dmrs_out1(2)), 32)+ bitand( int64(Dmrs_out1(1)), int64(4294967295));

     end
    end

    % Ordering the output data to column wise order for dpi support
    Data_out=Data_out';
    Dmrs_out=Dmrs_out';
    Ptrs_out=Dmrs_out(1:dmrsOutSize);

    % Size of the output data
    Data_size = int32(precoderOutSize);
    Dmrs_size = int16(size(Dmrs_out,1));
    Ptrs_size=int16(dmrsOutSize);


end