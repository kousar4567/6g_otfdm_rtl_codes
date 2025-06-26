
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


%% Function to configure NR-PUSCH as per the received Ulsch PDUs from L2/L3 to
% L1 in UL.config message

% This file contains all the parameters coming from L2/L3 in downlink
% config message for Ulsch and also some more parameters in the end
% received in cell config message to configure UL PUSCH transmitter part

function [NrUlUlschPDUs] = wnNrPhyPuschInit()

% Operating frequency band 
% 0 : FR1
% 1 : FR2

NrUlUlschPDUs.nrOperatingFreqBand = 1; %0;

% Allocated Bandwidth size in MHz
% Possible values: FR1 : scs0 = {5,10,15,20,25,30,40,50}
%                        scs1 = {5,10,15,20,25,30,40,50,60,80,90,100}
%                        scs2 = {10,15,20,25,30,40,50,60,80,90,100}
%                  FR2 : scs2 = {50,100,200}
%                        scs3 = {50,100,200,400}
NrUlUlschPDUs.maxTxBwInMHz = 200; %100;

% uint8_t  : subcarrierSpacing value:0->4
NrUlUlschPDUs.nSubcSpacing = 3; %1;

% Total Bandwidth Size (in Number of PRBs)
NrUlUlschPDUs.nBwSize = 132; 

% uint16_t : The RNTI used for identifying the UE when receiving 
% the PDU Value: 1 -> 65535
NrUlUlschPDUs.nRNTI = 65535;

% uint16_t : UE index in the 3ector Value:0 -> 1199
NrUlUlschPDUs.nUEId = 0;

% uint16_t : bandwidth part size Value: 20->275
NrUlUlschPDUs.nBWPSize = 132;

% uint16_t : bandwidth part start RB index Value: 0->254
NrUlUlschPDUs.nBWPStart = 0;

% uint8_t  : Cyclic prefix type
% 0: Normal;
% 1: Extended
NrUlUlschPDUs.nCptype = 0;

% If a UE is configured to receive code block group (CBG)
% based transmissions
% 0: Disabled
% 1: Enabled
NrUlUlschPDUs.cbgTransmission = 0;

% Indicates whether CBGFI (CBG flush indicator) for CBG based
% (re)transmission in DL is enabled
% 0: Previous received information of the CBG should not be used
% 1: CBGs being retransmitted are combinable with the earlier received
NrUlUlschPDUs.cbgFlushIndicator = 0;

% Maximum number of CBGs per transport block : 2, 4, 6, 8
NrUlUlschPDUs.maxCBGsPerTB = 4;

% CBG transmission information (CBGTI): 0, 2, 4, 6, or 8 bits
% Each bit represent the CBG index which is re-transmitted
% First NcbgMax_perTb bits represents first code-word CBGs
NrUlUlschPDUs.cbgTransmitInfo = zeros(1,8);
% NrDlDlschPDUs.cbgTransmitInfo = [1,1; ...
%                                  1,1];

% uint8_t  : HARQ Process number, Value : 0->15
NrUlUlschPDUs.nHARQID =0;



% uint8_t : Transmission Scheme
% 0: non-codebook based transmission
% 1: Codebook based transmission
NrUlUlschPDUs.nTransmissionScheme = 1;

% uint8_t  : Layer number Value : 1->4
NrUlUlschPDUs.nNrOfLayers = 1;

% uint8_t  : Number of antenna ports Value : 2,4
NrUlUlschPDUs.nNrOfAntennaPorts = 1;

% uint8_t  : Antenna port index 
% 0: port 1000
% 1: port 1001
% 
% 11: port 1011
% Value : 0->11
% Make sure the antenna ports are in the increasing order
NrUlUlschPDUs.nPortIndex(1:NrUlUlschPDUs.nNrOfAntennaPorts) = [0];


% uint16_t : Data-scrambling-Identity Value : 0->1023
NrUlUlschPDUs.nNid = 50;

% uint8_t  : For DMRS generation Value : 0->1
NrUlUlschPDUs.nSCID = 0;

% uint16_t : UL-DMRS-Scrambling-ID 0, For DMRS generation Value : 0->65535
% .nNIDnSCID0 = 0125;

% uint16_t : UL-DMRS-Scrambling-ID 1, For DMRS generation Value : 0->65535
NrUlUlschPDUs.nNIDnSCID1 = 50; % 0;

% uint8_t  : start symbol index of PUSCH mapping, include both DMRS and data
% Value: 0->13
NrUlUlschPDUs.nStartSymbolIndex = 0;

% uint8_t  : PUSCH duration in symbols, include both DMRS and data
% Value: 1->14
% NrUlUlschPDUs.nNrOfSymbols = 1;
NrUlUlschPDUs.nNrOfSymbols = 11;

% uint8_t  : resource allocation type 0: type 0
%            resource allocation type 1: type 1
NrUlUlschPDUs.nResourceAllocType = 1;

% uint16_t  : For resource allocation type 1.
% The starting resource block for this Ulsch allocation
NrUlUlschPDUs.nRBStart = 8;

% uint16_t  : For resource allocation type 1
% The number of resource block allocated to this Ulsch grant.
% This should match the value sent in the UL DCI PDU which allocated this grant
NrUlUlschPDUs.nRBSize = 126;

% uint8_t  : For resource allocation type 0. Number of RBGs
NrUlUlschPDUs.nNrOfRBGs = 0;

% uint8_t  : For resource allocation type 0. RBG size
% Value: 2,4,8,16
NrUlUlschPDUs.nRBGSize = 0;

% uint32_t : For resource allocation type 0.
% RBG index allocated for this Ulsch in bitmap.
% The most significant bit represents the RBG of lower index.
% The maximum number is 138 with 275 RBs and RBG size 2.
NrUlUlschPDUs.nRBGIndex(1:NrUlUlschPDUs.nNrOfRBGs) = floor(2*rand(1,NrUlUlschPDUs.nNrOfRBGs));


% This gives the Precoding Matrix Indicator
% 0->27
NrUlUlschPDUs.nPMI = 0;

% uint8_t  : Redundancy version Value : 0->3
NrUlUlschPDUs.nRV = 0;

% uint8_t  : HARQ Process number, Value : 0->15
NrUlUlschPDUs.nHARQID = 0;
% uint8_t  : MCS index Value : 0->31
NrUlUlschPDUs.nMCS = 11; %QPSK-3; 16QAM-5; 64QAM-11;256QAM-20
% temporary MCS : mainly used in AMCs
NrUlUlschPDUs.tempMCS = NrUlUlschPDUs.nMCS;

% uint8_t  : Redundancy version Value : 0->3
NrUlUlschPDUs.nRV(1) = 0;

% uint8_t  : New data indication 
% 0: retransmission
% 1: new data
NrUlUlschPDUs.nNDI = 1;

% uint8_t  : Pusch mapping Type 
% 0: mapping type A
% 1: mapping type B
NrUlUlschPDUs.nMappingType = 0;

% uint8_t  : UL DMRS config type 
% 0: type 1
% 1: type 2
NrUlUlschPDUs.nDMRSConfigType = 0;

% uint8_t  : UL DMRS symbol number 
% 1: single symbol
% 2: double symbol
NrUlUlschPDUs.nNrofDMRSSymbols = 1;

% For double front loaded
%1 - single front loaded
%2- double front loaded
NrUlUlschPDUs.DlDci2Dmrs = 2;

% uint8_t  : UL additional DMRS position UL-DMRS-add-pos
% Value: 0->3
NrUlUlschPDUs.nDMRSAddPos = 0;

% Number of DMRS samples per OFDM symbol
% Can take values from 1 to M_sc/2
% NrUlUlschPDUs.nDMRSpSymb = max(primes(NrUlUlschPDUs.nRBSize*1.5));
NrUlUlschPDUs.nDMRSpSymb = 90;


% Number of DMRS CP samples
% This number is always <= number of DMRS samples
% NrUlUlschPDUs.nCpsam = max(primes(1*NrUlUlschPDUs.nRBSize));
NrUlUlschPDUs.nCpsam = 90;



% DMRS symbol indices
%  1 symb: 1:1:14  -> 14 DMRS symbols
%  2 symb: 1:2:14  ->  7 DMRS symbols 
%  3 symb: 1:3:14  ->  5 DMRS symbols
%  4 symb: 1:4:14  ->  4 DMRS symbols
%  5 symb: 1:5:14  ->  3 DMRS symbols
%  6 symb: 1:6:14  ->  2 DMRS symbols
%  7 symb: 1:7:14  ->  2 DMRS symbols
%  8 symb: 1:8:14  ->  2 DMRS symbols
%  9 symb: 1:9:14  ->  2 DMRS symbols
% 10 symb: 1:10:14 ->  2 DMRS symbols

NrUlUlschPDUs.Dmrssymbidx = [0:NrUlUlschPDUs.nNrOfSymbols-1];% [0 2 4 6 7 8 10 12 ];%

% Number of DMRS symbols
% can be in the range of 1->14
NrUlUlschPDUs.nNrofDMRSsymb = length(NrUlUlschPDUs.Dmrssymbidx);

% Number of DMRS chunks

NrUlUlschPDUs.nNrofChunks = 1;


% Number of DMRS CDM Groups without Data
% 0 =: {0}
% 1 =: {0,1}
% 2 =: {0,1,2}
NrUlUlschPDUs.nDmrsWithoutData = 1;

% uint8_t  : UL-PTRS-present
% 0: PT-RS is not present 
% 1: PT-RS is present
NrUlUlschPDUs.nPTRSPresent = 0;

% uint8_t  : Up to 2 ports UL-PTRS-ports. Value: 1->2
NrUlUlschPDUs.nNrOfPTRSPorts = 1;

% uint8_t  : Value: 0->11
% 0: port 1000
% 1: port 1001
% ...
% 11: port 1011
% This is the port index associated with PUSCh DMRS
NrUlUlschPDUs.nPTRSPortIndex(1:NrUlUlschPDUs.nNrOfPTRSPorts) = 0;

% uint8_t  : PT-RS time density Value: 0,1, 2 or 4
% 0 means PT-RS is not present
NrUlUlschPDUs.nPTRSTimeDensity = 1;

% uint8_t  : PT-RS frequency density Value: 0, 2 or 4
% 0 means PT-RS is not present
NrUlUlschPDUs.nPTRSFreqDensity = 2;

% uint8_t  : UL-PTRS-RE-offset, refer to Table 7.4.1.2.2-1 in [2] Value: 0->3
NrUlUlschPDUs.nPTRSReOffset = 1;

% uint8_t  : PUSCH-to-PT-RS EPRE ratio
% ratio of PUSCH EPRE to PTRS EPRE, refer to Table 4.1-2 in [4]
% Value :0->3
NrUlUlschPDUs.nEpreRatioOfPUSCHToPTRS = 1;

% uint16_t : DMRS EPRE Value :1->20000
% 0.001 dB step, -6dB to 14 dB
NrUlUlschPDUs.nEpreRatioOfDmrsToSSB = 7000;

%% Following parameters will not be provided by L2-L3 in UL config message
% these parameters are either drived in PUSCH chain itself or received in
% other config messages

% % Modulation order
 NrUlUlschPDUs.modOrder = 2;
% 
% % Coding Rate
 NrUlUlschPDUs.codingRate = 0.5875; % Both these parameters are calcualted
% from the MCS table.

% uint32_t : Transmit block size (in bytes)
NrUlUlschPDUs.nTBSize = 16296; %round(NrUlUlschPDUs.nRBSize*12*12*NrUlUlschPDUs.modOrder*NrUlUlschPDUs.codingRate*NrUlUlschPDUs.nNrOfLayers)-10;
% Numerology
NrUlUlschPDUs.numerology = NrUlUlschPDUs.nSubcSpacing;

% NR Cell ID
NrUlUlschPDUs.nPhyCellId = 1 %012;

% higher-layer parameter UL-DMRS-typeA-pos
NrUlUlschPDUs.ulDmrsTypeAPos = 2;

% Slot Number 
NrUlUlschPDUs.slotNum = 0;

% When Double front loaded is configured then
% the associated DCI determines whether single symbol
% or double-symbol DM-RS shall be used
NrUlUlschPDUs.ulDci2Dmrs = 2;

% Number of Symbols per slot
NrUlUlschPDUs.nSymsPrSlot = 14;

NrUlUlschPDUs.NohPrb = 0;

% Intialization value for DMRS when transform precoding is enabled
NrUlUlschPDUs.NIdRS = 1; %15;
% uint8_t  : MCS-Table-PUSCH
% 0: not set to '256QAM'
% 1: set to '256QAM'
NrUlUlschPDUs.nMcsTable = 1;
% uint8_t  : MCS-Table-PUSCH for DFT-S-OFDM
% 0: pi/2 bpsk'
% 1: other qams'
NrUlUlschPDUs.nmcsTableTransPrecode = 0;


% uint8_t : Transform precoding
% 0: Transform Precoding Enabled
% 1: Transform Precoding Disabled
NrUlUlschPDUs.nTransPrecode = 0;
% Flag to enable pi2BPSK modulation
NrUlUlschPDUs.tppi2BPSK = 1;


 NrUlUlschPDUs.rvid = 0;           %3 bits
 NrUlUlschPDUs.tpmi_index= 0;      %4 bits
 NrUlUlschPDUs.nidnscid=0;         %16 bits
 NrUlUlschPDUs.nNIDnSCID0 = 1;

 NrUlUlschPDUs.nsf=0;              %7 bits
 NrUlUlschPDUs.seq_hopping=1;      %1 bits
 NrUlUlschPDUs.group_hopping=0;    %1 bits
    NrUlUlschPDUs.dmrs_UplinkTransformPrecoding_r16 = 1; %1 bits
end % End of the function