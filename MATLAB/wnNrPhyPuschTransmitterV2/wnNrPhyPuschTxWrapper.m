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


%% Top module for pusch tx channel

function [dmrssamples,multiplexed_samples,m_point_dft_out_samples,spec_extended_output,filtered_out,PuschModOut,puschScramblerOut,puschRatematchOut,puschWithCrc,nrPuschCbsOut,punctOut] = ...
    wnNrPhyPuschTxWrapper(tb_data,Tbs_valid_no,exe_prb,NrUlUlschPDUs)

    % Reading the configuration data
    qam =NrUlUlschPDUs.modOrder;% bi2de(config_in(1:3),'left-msb');
    tbsize =NrUlUlschPDUs.nTBSize;% bi2de(config_in(4:34),'left-msb');
    pi_by_2_bpsk=NrUlUlschPDUs.tppi2BPSK;%bi2de(config_in(35),'left-msb');
    rvid =NrUlUlschPDUs.rvid;%bi2de(config_in(36:38),'left-msb');
    rnti =NrUlUlschPDUs.nRNTI;%bi2de(config_in(39:54),'left-msb');
    nId= NrUlUlschPDUs.nNid;%bi2de(config_in(55:64),'left-msb');
    codingRate=NrUlUlschPDUs.codingRate;% bi2de(config_in(65:74),'left-msb');
    numLayers=NrUlUlschPDUs.nNrOfLayers;%bi2de(config_in(79:82),'left-msb');
    numPRBs=NrUlUlschPDUs.nRBSize;%bi2de(config_in(83:91),'left-msb');
    numSymbols=NrUlUlschPDUs.nNrOfSymbols;% bi2de(config_in(92:95),'left-msb');

 N_dft =numPRBs*12;% bi2de(config_in(171:181),'left-msb')  ;  % DFT size used in OTFDM as a multiple of 12
L_rs =NrUlUlschPDUs.nDMRSpSymb;% bi2de(config_in(96:110),'left-msb');
L_cp =L_rs;% bi2de(config_in(159:170),'left-msb')  ;   % CP length of DMRS data

nscid=NrUlUlschPDUs.nSCID;%bi2de(config_in(122),'left-msb');
nidnscid=NrUlUlschPDUs.nidnscid;%bi2de(config_in(123:138),'left-msb');
nsf= NrUlUlschPDUs.nsf;%bi2de(config_in(139:145),'left-msb');
nidrs=NrUlUlschPDUs.NIdRS ;%bi2de(config_in(146:155),'left-msb');
seq_hopping=NrUlUlschPDUs.seq_hopping;%bi2de(config_in(156),'left-msb');
group_hopping=NrUlUlschPDUs.group_hopping;%bi2de(config_in(157),'left-msb');
dmrs_UplinkTransformPrecoding_r16=NrUlUlschPDUs.dmrs_UplinkTransformPrecoding_r16;%bi2de(config_in(158),'left-msb');
L_data =N_dft - (L_rs + L_cp);%bi2de(config_in(182:192),'left-msb')  ;  % number of modulation samples in one OTFDM symbol
cp_length_spectrum_extension = (12*exe_prb)/2;%ceil(((10/100)*N_dft)/2); %extension factor 5
   

  

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Internal register for TB data
    inputTbs = [];
    for i=1:Tbs_valid_no%length(tb_data)
        inputTbs = [inputTbs de2bi(tb_data(i),'right-msb',32)];
    end
    inputTbs = inputTbs(1:tbsize);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CRC Generation
     % Polynomial for CRC24A
    CRC24A = [1,1,0,0,0,0,1,1,0,0,1,0,0,1,1,0,0,1,1,1,1,1,0,1,1];

    %Polynomial for CRC16
    CRC16 = [1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1];

    % If Transport block size is less than 3824 use CRC16 otherwise CRC24A
    if tbsize < 3824
        CRC = CRC16;
        puschCrcLen = 16;
    else
        CRC = CRC24A;
        puschCrcLen = 24;
    end
    if ((tbsize <= 292) || ...
        (tbsize <= 3824 && codingRate <= 0.67) || ...
        (codingRate <= 0.25))

        puschLdpcBaseGraph = 2;
        cnst = 5;
        maxCodeBlockSize = 3840;
    else
        puschLdpcBaseGraph = 1;
        cnst = 3;
        maxCodeBlockSize = 8448;
    end  

    inputTbs = double(inputTbs);
    
    % Processing for CRC attachment
    [puschWithCrc, ~] = wnNrPhyCrcGenAttach(inputTbs, ...
                                            CRC);  
  

     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Processing for Code Block Segmentation and CRC Attachment
    
    % To match the code block length to the LDPC input filler bit is used
    % Which will be removed in the LDPC rate-matching 
    filler_bit = -1;
    
    [nrPuschCbsOut, nPuschCbs, eachCbSize, Zc_min, eachCbLenWithCrc, Kb, mb] = ...
                                                 wnNrPhyPuschCbSegCrcAttach(puschWithCrc, ...
                                                                            tbsize, ...
                                                                            puschCrcLen, ...
                                                                            puschLdpcBaseGraph, ...
                                                                            maxCodeBlockSize, ...
                                                                            filler_bit);
nrPuschCbsOut = nrPuschCbsOut';
size(nrPuschCbsOut);
% eachCbSize
eachCbLenWithCrc = ceil(eachCbLenWithCrc);
% Processing for LDPC Encoding
punctOut = nrLDPCEncode(nrPuschCbsOut,puschLdpcBaseGraph);
punctOut =punctOut';

L_ptrs=0;
[PuschRatematchLen] = wnNrPhyPuschRateMatchlen (qam,numSymbols,numLayers, ...
        L_rs, ...
        L_cp,...
        L_ptrs, ...
        numPRBs);
 

% Constant variables for Rate matching evaluation
CBGTI = 0;
LbrmFbrmSelect = 0;
BWPSize = 133;

% Rate Matching for LDPC
[puschRatematchOut, puschRmLen,bit_select_out] = wnNrPhyPuschRateMatching(punctOut, ...
                                                           nPuschCbs, ...
                                                           puschLdpcBaseGraph, ...
                                                           qam, ...
                                                           Zc_min, ...
                                                           CBGTI, ...
                                                           LbrmFbrmSelect, ...
                                                           BWPSize,numLayers,rvid, ...
                                                           PuschRatematchLen, ...
                                                           filler_bit);


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Processing for Code Block concatenation
[puschCbConcatOut] = wnNrPhyPuschCbConCat(puschRatematchOut, ...
                                          puschRmLen, ...
                                          nPuschCbs);   

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Processing for Scrambling
[puschScramblerOut] = wnNrPhyPuschScrambler(puschCbConcatOut, ...
                                            rnti, ...
                                            nId);   

                                         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Processing for Modulation
[PuschModOut] = wnNrPhyModulation(puschScramblerOut, ...
                                  PuschRatematchLen, ...
                                  qam);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % OTFDM chain
dmrssamples=[];
multiplexed_samples=[];
m_point_dft_out_samples=[];
spec_extended_output=[];
filtered_out=[];
indExtfac=((12*exe_prb)/N_dft)*100; %TODO :according to extension factor

for k = 1:numSymbols

 %% dmrs generation
dmrssamples = [dmrssamples ; DMRSgeneration(L_rs,nscid,nidnscid,group_hopping,seq_hopping,nidrs,nsf,k-1,dmrs_UplinkTransformPrecoding_r16)];
                %TODO:change the Nzc according to L_rs
%% mux of DATA and DMRS
multiplexed_samples = [multiplexed_samples ; datamultiplexer(dmrssamples(k,:),PuschModOut(1+(k-1)*L_data:k*L_data))];

%% Processing of multiplexed data to DFT
m_point_dft_out_samples = [m_point_dft_out_samples ; (1/sqrt(N_dft)).*fft(multiplexed_samples(k,:))];
%(1/sqrt(N_dft)).*
%% Processing of Spectrum extension
if (pi_by_2_bpsk)
    filtered_out =[filtered_out ,tap_2_filter(transpose(m_point_dft_out_samples(k,:)),N_dft,1)];
else
spec_extended_output = [spec_extended_output ; specextendeddata(m_point_dft_out_samples(k,:),cp_length_spectrum_extension,N_dft)];
%% spectrum shaping with SQRC filter
filtered_out =[filtered_out ,square_root_raised_cosine_filter(transpose(spec_extended_output(k,:)),N_dft,indExtfac,1)];
end
end





end
