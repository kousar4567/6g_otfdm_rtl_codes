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
% (https://creativecommons.org/licenses/by-nd/4.0/legalcode) shall apply.


function [dmrs1,DmrsSymNum,dmrsPrPrb,CdmGroup,grp2,dmrsCdmGWithData,dmrsCdmGWithoutData,scale] = wnNrPhyPuschDmrsGen(NrUlUlschPDUs)

load wnNrPhyPuschDmrsAddPos.mat add_pos % table 6.4.1.1.3-3 in TS 38.211
grp2 = 0;
gh = 0;
sh = 0;


% DMRS scaling
switch NrUlUlschPDUs.nDmrsWithoutData
    case 0
        scale = 1;
    case 1
        scale = 10^(3/20);
    case 2
        scale = 10^(4.77/20);
end
scale = 1;

%%      working on CONFIGURATION TYPE
        dmrsseqleng = NrUlUlschPDUs.nDMRSpSymb;
                  C = 2;
           CdmGroup = zeros(1,2);
    %%%% CONFIGURATION TYPE FINISHED%%%%%%%%%%    
if NrUlUlschPDUs.nNrofDMRSSymbols == 1 || NrUlUlschPDUs.DlDci2Dmrs == 1
    %% for single front loaded DMRS for both max_length = 1 &2  

                l_prime = 0;
     
    %%     working on MAPPING TYPE
    if NrUlUlschPDUs.nMappingType == 0
        % getting the starting position of the DMRS symbol
        if NrUlUlschPDUs.ulDmrsTypeAPos == 3
            l_0 = 3;
        else 
            l_0 = 2;
        %             NrUlUlschPDUs.nDMRSAddPos =3;
        end 
        % getting the l_bar to calculate the DMRS symbol locations
       
        l_bar = 0;%[l_0 add_pos.single_symbol.mtA{NrUlUlschPDUs.nNrOfSymbols-2,NrUlUlschPDUs.nDMRSAddPos+2}];
        
    else
        l_0 = 0;
        if NrUlUlschPDUs.nNrOfSymbols>3
            l_bar = NrUlUlschPDUs.nStartSymbolIndex+[l_0 add_pos.single_symbol.mtB{NrUlUlschPDUs.nNrOfSymbols-2,NrUlUlschPDUs.nDMRSAddPos+2}];
        else
            l_bar = NrUlUlschPDUs.nStartSymbolIndex+[l_0 add_pos.single_symbol.mtB{1,NrUlUlschPDUs.nDMRSAddPos+2}];
        end
    end
    %%%%%%%MAPPING TYPE FINISHED%%%%%%
    % -------finished with symbol selection---------%

    %%     Single FRONT-LOADED DMRS Symbol 
    for ind_symb = 1:length(l_bar)
        cdm0 = 1;
        cdm1 = 1;
    %         Generation of base sequence which depends on the symbol number
         [dmrs1(ind_symb,:)] = wnNrPhyPuschScfdmaDmrs(NrUlUlschPDUs,gh,sh,l_bar(ind_symb),dmrsseqleng);
         
         for ind_port = 0:length(NrUlUlschPDUs.nPortIndex)-1       
             
            temp = zeros(dmrsseqleng*C,1);
            
            for k_prime = 0:1
    %        getting different values from tables 6.4.1.1.3-1 and
    %        6.4.1.1.3-2 in section 6.4.1.1.3 from TS 38.211
                [cdm_group(ind_port+1), delta, wf_k, wt_l] = wnNrPhyPuschDmrsCfg1Tbl(NrUlUlschPDUs.nPortIndex(ind_port+1),k_prime,l_prime(1));

%               calculation of tone number
                for ind_tone = 0:dmrsseqleng*0.5-1
                    k = 4*ind_tone+2*k_prime+delta;
                    temp(k+1,1) = wf_k*wt_l*dmrs1(ind_symb,2*ind_tone+k_prime+1);
                end
            end           
            temp = temp*scale;
            if cdm_group(ind_port+1) == 0
                dmdmrsSymOutrs(ind_symb).cdm(cdm_group(ind_port+1)+1).data(:,cdm0) = temp;
                cdm0 = cdm0+1;
                
            elseif cdm_group(ind_port+1) == 1
                dmdmrsSymOutrs(ind_symb).cdm(cdm_group(ind_port+1)+1).data(:,cdm1) = temp;
                cdm1 = cdm1+1;
            end
         end
%          copying symbol number
         DmrsSymNum(ind_symb) = l_bar(ind_symb);
    end
        CdmGroup(1) = cdm0-1;
        CdmGroup(2) = cdm1-1;
    Lprime = [];


elseif NrUlUlschPDUs.nNrofDMRSSymbols == 2 && NrUlUlschPDUs.DlDci2Dmrs == 2
    %%     for DOUBLE front loaded DMRS 
     l_prime = 0:1;

    %% ---------- working on MAPPING TYPE -----------%
    if NrUlUlschPDUs.nMappingType == 0
        % getting the starting position of the DMRS symbol
        if NrUlUlschPDUs.ulDmrsTypeAPos == 3
            l_0 = 3;
        else 
            l_0 = 2;
        end 
        % getting the l_bar to calculate the DMRS symbol locations
        l_bar = 0;%[l_0 add_pos.double_symbol.mtA{NrUlUlschPDUs.nNrOfSymbols-2,NrUlUlschPDUs.nDMRSAddPos+2}];
    else
        l_0 = 0;
        if NrUlUlschPDUs.nNrOfSymbols>3
            l_bar = NrUlUlschPDUs.nStartSymbolIndex + [l_0 add_pos.double_symbol.mtB{NrUlUlschPDUs.nNrOfSymbols-2,NrUlUlschPDUs.nDMRSAddPos+2}];
        else
            l_bar = NrUlUlschPDUs.nStartSymbolIndex + [l_0 add_pos.double_symbol.mtB{1,NrUlUlschPDUs.nDMRSAddPos+2}];
        end
    end
    %%---------------------------------------------------------%%
    % -------finished with symbol selection---------%

    
    %%     DOUBLE FRONT-LOADED DMRS SYMBOL
    for ind_symb = 1:length(l_bar)
        cdm0 = 1;
        cdm1 = 1;
    %         Generation of base sequence which depends on the symbol number
%       dmrs1(2*ind_symb,:) = wnNrPhyPuschScfdmaDmrs(NrUlUlschPDUs,gh,sh,l_bar(ind_symb),dmrsseqleng);
%     dmrs1(2*ind_symb+1,:) = wnNrPhyPuschScfdmaDmrs(NrUlUlschPDUs,gh,sh,l_bar(ind_symb)+1,dmrsseqleng);
                 [dmrs11] = wnNrPhyPuschScfdmaDmrs(NrUlUlschPDUs,gh,sh,l_bar(ind_symb),dmrsseqleng);
                 [dmrs12] = wnNrPhyPuschScfdmaDmrs(NrUlUlschPDUs,gh,sh,l_bar(ind_symb)+1,dmrsseqleng);
                for ind_port = 0:length(NrUlUlschPDUs.nPortIndex)-1
                     temp = zeros(dmrsseqleng*C,1);
                    temp1 = zeros(dmrsseqleng*C,1);
                    for k_prime = 0:1
        %           getting different values from tables 6.4.1.1.3-1 and
        %           6.4.1.1.3-2 in section 6.4.1.1.3 from TS 38.211    
                            [cdm_group(ind_port+1), delta1, wf_k1, wt_l1] = wnNrPhyPuschDmrsCfg1Tbl(NrUlUlschPDUs.nPortIndex(ind_port+1),k_prime,l_prime(1));
                            [~, ~, wf_k2, wt_l2(ind_port+1)]              = wnNrPhyPuschDmrsCfg1Tbl(NrUlUlschPDUs.nPortIndex(ind_port+1),k_prime,l_prime(2));

%               calculation of tone number
                        for ind_tone = 0:dmrsseqleng*0.5-1
                                k = 4*ind_tone+2*k_prime+delta1;
                            temp(k+1,1) = wf_k1*wt_l1*dmrs11(2*ind_tone+k_prime+1);
                            temp1(k+1,1) = wf_k2*wt_l2(ind_port+1)*dmrs12(2*ind_tone+k_prime+1);
                        end 
                    end 
                    temp = scale*temp;
                    temp1 = scale*temp1;
                    if cdm_group(ind_port+1) == 0
                        dmdmrsSymOutrs(2*ind_symb-1).cdm(cdm_group(ind_port+1)+1).data(:,cdm0) = temp;
                        dmdmrsSymOutrs(2*ind_symb).cdm(cdm_group(ind_port+1)+1).data(:,cdm0) = temp1;
                        cdm0 = cdm0+1;

                    elseif cdm_group(ind_port+1) == 1
                        dmdmrsSymOutrs(2*ind_symb-1).cdm(cdm_group(ind_port+1)+1).data(:,cdm1) = temp;
                        dmdmrsSymOutrs(2*ind_symb).cdm(cdm_group(ind_port+1)+1).data(:,cdm1) = temp1;
                        cdm1 = cdm1+1;
                    end
                end  
%                 copying symbol number
       DmrsSymNum(2*ind_symb-1) = l_bar(ind_symb);
         DmrsSymNum(2*ind_symb) = l_bar(ind_symb)+1;
    end 
    CdmGroup(1) = cdm0-1;
    CdmGroup(2) = cdm1-1;
    if abs(sum(wt_l2)) < NrUlUlschPDUs.nNrOfLayers
            grp2 = 1;
    end
end

    % Remove the symbol offset for DMRS
if NrUlUlschPDUs.nMappingType == 1
    DmrsSymNum = DmrsSymNum - NrUlUlschPDUs.nStartSymbolIndex;
end

dmrsPrPrb = length(DmrsSymNum) * (dmrsseqleng/(NrUlUlschPDUs.nDMRSpSymb/6));
 % DMRS CDM Group(s) without Data 
    if (NrUlUlschPDUs.nDmrsWithoutData == 0)
        dmrsCdmGWithoutData = [1,0,0];
        switch NrUlUlschPDUs.nDMRSConfigType
            case 0
                dmrsCdmGWithData = 1;
            case 1
                dmrsCdmGWithData = 2;
        end
    elseif (NrUlUlschPDUs.nDmrsWithoutData == 1)
        dmrsCdmGWithoutData = [1,1,0];
        switch NrUlUlschPDUs.nDMRSConfigType
            case 0
                dmrsCdmGWithData = 0;
            case 1
                dmrsCdmGWithData = 1;
        end
    elseif (NrUlUlschPDUs.nDmrsWithoutData == 2)
        dmrsCdmGWithoutData = [1,1,1];
        switch NrUlUlschPDUs.nDMRSConfigType
            case 0
                dmrsCdmGWithData = 0;
            case 1
                dmrsCdmGWithData = 0;
        end
    end 
end
