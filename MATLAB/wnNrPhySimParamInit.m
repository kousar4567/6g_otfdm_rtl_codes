%
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
%%

function [NrPhySimParam] = wnNrPhySimParamInit()

    % SNR range for simulations in dB
        NrPhySimParam.sinr = [50:50];
%         NrPhySimParam.sinr = [17 19 21];

    % Total Number of Iterations
        NrPhySimParam.totalItr = 20;
    
    % Number of receive antennas
        NrPhySimParam.nRxant = 1;
    
    % Carrier frequency
        NrPhySimParam.fc = 7e9;
    % UE speed in Km/Hr
        NrPhySimParam.Speed = 5;
        
    % Frequency Offset(in HZ)
        NrPhySimParam.freqOffset = 00;
        
    % Flag to keep the frequency offset in the Tx signal
    % 0 : No offset induced
    % 1 : Offset induced
        NrPhySimParam.freqOffkeepflag = 0;
    
    % Flag to estimate the frequency offset in the Receiver
    % 0 : No estimation of frequency offset
    % 1 : estimation of frequency offset
        NrPhySimParam.freqOffestflag = 0;  
        
    % Time Offset(in terms of number of samples)
        NrPhySimParam.timeOffset = 00;
        
    % Flag to keep the Timing offset in the Tx signal
    % 0 : No offset induced
    % 1 : Offset induced
        NrPhySimParam.timeOffkeepflag = 0;
    
    % Flag to estimate the Timing offset in the Receiver
    % 0 : No estimation of timing offset
    % 1 : estimation of timing offset
        NrPhySimParam.timeOffestflag = 0;
    
    % Doppler value in Hz
    NrPhySimParam.doppler = NrPhySimParam.fc*NrPhySimParam.Speed*5/(3e8*18);
    % Flag to enable linear interpolation in receier
    % 0 : mean of channel estimates on all the symbols.
    % 1 : Use linear interpolation to get the channel estimates.
        NrPhySimParam.Dopplerflag = 0;
        
    % Channel Type
    % 0 : AWGN Channel
    % 1 : Multipath Channel
        NrPhySimParam.chanType = 01;
    
    % Flag to keep the perfect channel
    % 0 : Estimated channel
    % 1 : Perfect Channel
        NrPhySimParam.truchan = 0;
        
    % Flag to keep the perfect Noise variance estimate
    % 0 : Estimated Noise variance
    % 1 : Perfect Noise variance
        NrPhySimParam.trunoisevar = 01;
        
    % Flag to perform per tone equalization
    % 0 : Equalization as per tone avg factor
    % 1 : Equalization per tone
        NrPhySimParam.pertoneequa = 01;
        
    % Phase Noise Channel
    % 0 : Phase Noise Channel disabled
    % 1 : Phase Noise Channel enabled
    
        NrPhySimParam.phaseNoiseChannel = 0;
    
    % Flag to add interference
    % 0 : Interference disabled
    % 1 : Interference enabled
        NrPhySimParam.interf = 0;
    
    %Flag to enable HARQ transmission
    % 0 : HARQ transmission Disable
    % 1 : HARQ transmission Enable
        NrPhySimParam.EnableHARQ = 0;
    
    %Maximum retransmission Counter 
        NrPhySimParam.nMaxReTxCount= 4;
        
    % Tone averaging factor
    NrPhySimParam.toneavgfac = 1;
    
    % Model Desired Delay
    % Very short delay spread   10   ns
    % Short delay spread        30   ns
    % Nominal delay spread      100  ns
    % Long delay spread         300  ns
    % Very long delay spread    1000 ns 
    NrPhySimParam.ds = 30e-9;
end