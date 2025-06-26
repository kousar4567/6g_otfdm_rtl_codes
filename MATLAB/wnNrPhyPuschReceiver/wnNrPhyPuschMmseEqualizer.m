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
% (https://creativecommons.org/licenses/by-nd/4.0/legalcode) shall apply.


% ------------------MMSE EQUALIZER-----------------------%

function [EqualizedData, gamma, NoiseVariance,DataInterleaving,scale,filter,EqualizedData_F] = wnNrPhyPuschMmseEqualizer(ICI, ...
                                                                           NtonesScheduled, ...
                                                                           Nr, ...
                                                                           NrUlUlschPDUs, ...
                                                                           Rxer,...
                                                                           NrPuschDmrs, ...
                                                                           puschChEstimates, ...
                                                                           puschDmrsSyms, ...
                                                                           AntGrpFac, ...
                                                                           CovGrpFac,...
                                                                           CdmGroup, ...
                                                                           toneAvgFac, ...
                                                                           TimeOffset, ...
                                                                           tonecdm, ...
                                                                           N_t, ...
                                                                           toneStIdx, ...
                                                                           puschPtrsIdx, ...
                                                                           toneindx1,...
                                                                           snr,...
                                                                           NrPhySimParam,...
                                                                           freqOffsetAngle,indchunck,puschTrsfmPrcdOut,...
                                                                  dftsize,...
                                                                  Exs,...
                                                                  Mapdata)    
NrUlUlschPDUs.modOrder =1;
if NrPhySimParam.pertoneequa == 1
    N_t = 1;
end
% IRC - Flag to enable IRC
% NtonesScheduled - Total Number of tones scheduled
% Nr - Number of Receive antennas
% NrUlUlschPDUs - PDU parameters for PUSCH Transmission
% Rxer - Received data on all the antennas
% PuschDmrs - DMRS for all the scheduled ports 
% puschChEstimates - channel estimates
% puschDmrsSyms - pusch DMRS symbol indices
% AntGroupFactor - Antenna Grouping Factor
% GroupingFactorCov - Noise + Interference Grouping Factor
% CdmGroup - this specifies Number of layers configured on each CDM group
% toneAvgFac - tone averaging factor(used in channel estimation)
% CdmToneIndx - tone indiced correspoindig to each CDM group
% C    = 2, for configuration type 1 DMRS
%      = 3, for configuration type 2 DMRS
% TimeOffset - Time offset phase angle
% toneStIdx - starting tone index for the resources
% puschPtrsIdx - PTRS tone indices
                                                                   
%%  Parameters related to Data interleaved with DMRS
    % dmrsCdmGWithData - CDM groups which carry user data on DMRS symbols   
    DataInterleaving = 1;                                   
    % DMRS CDM Group(s) without Data 
    switch (NrUlUlschPDUs.nDmrsWithoutData)
        case 0
            switch (NrUlUlschPDUs.nDMRSConfigType)
                case (0)
                    dmrsCdmGWithData = 2;
                    datatoneindx = zeros(1,NtonesScheduled/2);
                    datatoneindx(1:1:end) = tonecdm(2,1:1:end);
                case (1)
                    dmrsCdmGWithData = [2,3];
                    datatoneindx = zeros(1,NtonesScheduled*2/3);
                    datatoneindx(1:4:end) = tonecdm(2,1:2:end);
                    datatoneindx(2:4:end) = tonecdm(2,2:2:end);
                    datatoneindx(3:4:end) = tonecdm(3,1:2:end);
                    datatoneindx(4:4:end) = tonecdm(3,2:2:end);
            end     
        case 1
            switch (NrUlUlschPDUs.nDMRSConfigType)
                case (0)
                    dmrsCdmGWithData = [];
                    DataInterleaving = 0;
                case (1)
                    dmrsCdmGWithData = 3;
                    datatoneindx = tonecdm(dmrsCdmGWithData,:);
            end
        case 2
             switch (NrUlUlschPDUs.nDMRSConfigType)
                 case (0)
                    dmrsCdmGWithData = [];
                 case (1)
                    dmrsCdmGWithData = [];
             end
            DataInterleaving = 0;
    end
          

%% tone indices in the case of allocation type 0
if NrUlUlschPDUs.nResourceAllocType == 0
    toneindx = zeros(1,NtonesScheduled);
    switch NrUlUlschPDUs.nDMRSConfigType
        case  0
            toneindx(1:2:end) = toneindx1(1,:);
            toneindx(2:2:end) = toneindx1(2,:);
        case 1
            for indCdm = 1:3
                toneindx(2*indCdm-1:6:end) = toneindx1(indCdm,1:2:end);
                toneindx(2*indCdm:6:end) = toneindx1(indCdm,2:2:end);
            end 
    end
end
%% Calculation of symbol index to calculate the LLR scaling values

if (length(puschDmrsSyms) > 1 && puschDmrsSyms(2)-puschDmrsSyms(1) == 1)
    symbscaindx = 1;%puschDmrsSyms(2)+2;
else
    symbscaindx = 1;%puschDmrsSyms(1)+2;
end
    
%% Modify Received data from all the tones on one antenna to one tone on all
% the antennas
% This operation ensures that the equalisation is performed on tone basis
% for all the receiver antennas

    for indsymb = 1:NrUlUlschPDUs.nNrOfSymbols
        tempp1 = zeros(Nr,NtonesScheduled);
       tempp00 = zeros(Nr,1);
        for indtone = 1:NtonesScheduled
            for LL = 1:Nr
                tempp00(LL) = Rxer(LL).data(indtone,indsymb); %Rxer=specfolded data
            end 
            tempp1(:,indtone) = tempp00;
        end 
        RxedDataPerTone(indsymb).data = tempp1;
    end 
    
%% Main part of Equalisation    

%   Described in section 2.5.2 and 2.5.3 in ADD
%   Noise+Interference matrix R_NN is calculated on antenna group
%   Trace of that R_NN gives the noise variance
  

%   The following loop calcuates the noise+interference matrix on
%   antenna group basis for the CDM groups carrying DMRS to compute Y-Hx
%             for indCdm = find(CdmGroup~=0)
%                  for indAntGroup=1:Nr/AntGrpFac
% 
%                      for ind1 = 1:NtonesScheduled/(NrUlUlschPDUs.nDMRSConfigType+2)     % tone = tonecdm(indcdm,:)
%                          RxedDmrsToneCdm = RxedDataPerTone(puschDmrsSyms(1)+1).data((indAntGroup-1)*AntGrpFac+1:indAntGroup*AntGrpFac,tonecdm(indCdm,ind1)); 
%                          TxSigComp = zeros(AntGrpFac,1);
%                          for ind2 = 1:AntGrpFac
%                              temp1 = zeros(1,CdmGroup(indCdm));
%                              indAnt = (indAntGroup-1)*AntGrpFac + ind2;
%                              for ind3 = 1:CdmGroup(indCdm)
%                                  temp1(1,ind3) = puschChEstimates(indAnt).cdm(indCdm).layer(ind3).data(tonecdm(indCdm,ind1),1+puschDmrsSyms(1));%change this for each ue,as for now there is no notion of UE
%                              end 
%                              switch NrUlUlschPDUs.nResourceAllocType
%                                 case 1
%                                     temp1 = temp1.*exp(1i*TimeOffset*(toneStIdx+tonecdm(indCdm,ind1)-1));
%                                 case 0
%                                     temp1 = temp1.*exp(1i*TimeOffset*(toneStIdx+toneindx1(indCdm,ind1)-1));
%                              end  
%                              TxSigComp(ind2,1) = sum(temp1 .* NrPuschDmrs(1).cdm(indCdm).data(tonecdm(indCdm,ind1),1:CdmGroup(indCdm)));
%                          end 
%                          InterferenceNoiseVector(:,1) = (RxedDmrsToneCdm - TxSigComp).';
%                          CovarMatrix(tonecdm(indCdm,ind1),indAntGroup).data = InterferenceNoiseVector * InterferenceNoiseVector';
%                          NoiseVar(tonecdm(indCdm,ind1),indAntGroup) = InterferenceNoiseVector' * InterferenceNoiseVector;
%                      end 
%                  end   
%                  tempcdm(indCdm) = indCdm;  % the maximum size of tempcdm is 2 for configuration type 1 and 3 for configuration type 2
%             end
    %   The following loop calcuates the noise+interference matrix on
    %   antenna group basis for the CDM groups not carrying any data or DMRS
%             for indCdm = find(CdmGroup==0)
%                 if DataInterleaving == 0
%                     for indAntGroup=1:Nr/AntGrpFac
%                         for indtone = tonecdm(indCdm,:)
%                             RxedDmrsToneCdm1 = RxedDataPerTone(puschDmrsSyms(1)+1).data((indAntGroup-1)*AntGrpFac+1:indAntGroup*AntGrpFac,indtone);
%                             InterferenceNoiseVector(:,1) = RxedDmrsToneCdm1.';
%                             CovarMatrix(indtone,indAntGroup).data = InterferenceNoiseVector * InterferenceNoiseVector';
%                             NoiseVar(indtone,indAntGroup) = InterferenceNoiseVector' * InterferenceNoiseVector;
%                         end
%                     end
%                     tempcdm(indCdm) = indCdm;
%                 end
%             end
            
        % Calculate effective Noise variance   
%         NoiseVariance = sum(sum(NoiseVar,2)/Nr)/((NtonesScheduled/(N_t))*(length(find(tempcdm~=0))));
        %Calculating temporary averaging factor for noise+covariance matrices
        if NrPhySimParam.trunoisevar == 1
            NoiseVariance = 10^(-snr/10); 
        end
%               tempavgfactor = (CovGrpFac/(N_t))*(length(find(tempcdm~=0)));
                    

            if ICI == 1
%% Averaging of NOISE+INTERFERENCE Covariance matrix over tones defined by variable "tempavgfactor"

% calculation of noise whitening filter for each antenna group and tone group
                scalingfactor = zeros(sum(CdmGroup),NtonesScheduled/CovGrpFac);
                gamma = zeros(sum(CdmGroup),NtonesScheduled/CovGrpFac);
                for indAntGroup=1:Nr/AntGrpFac
                    for indtonegrp = 1:NtonesScheduled/CovGrpFac
                        R_I_N_slot1 = zeros(AntGrpFac,AntGrpFac);
                        for indCdm = find(tempcdm~=0)
                            for rr = tonecdm(indCdm,1:CovGrpFac/N_t)
                                R_I_N_slot1 = R_I_N_slot1+CovarMatrix((indtonegrp-1)*CovGrpFac+rr,indAntGroup).data;
                            end 
                        end
                        R_I_N_group(indAntGroup,indtonegrp).group1 = 1/tempavgfactor*R_I_N_slot1;
                %Cholesky Decomposition
                        Decomp_UE_slot1 = chol(R_I_N_group(indAntGroup,indtonegrp).group1,'lower');
                %Noise Whitening Filter for a given antenna group and tone group
                       Noise_whiten(indAntGroup,indtonegrp).group1 = inv (Decomp_UE_slot1);
                    end  
                end  
              % Equalization
  
                EqualizedData = [];
                ind22 = 1;
                
                for indsymb = 1:NrUlUlschPDUs.nNrOfSymbols
                    if indsymb ~= puschDmrsSyms+1
                  %% Processing for a given data symbol
                        for indtone = 1:NtonesScheduled
                    %% Processing on a tone of a given data symbol
                            indtonegrp = ceil(indtone/(toneAvgFac*N_t));
                            indcovgrp = ceil(indtone/CovGrpFac);
                            H_MMSE_slot11_new=zeros(Nr,NrUlUlschPDUs.nNrOfLayers);
                            Y_1=zeros(Nr,1);

                                for indAntGroup=1:Nr/AntGrpFac
    
                                    H_MMSE_slot1=zeros(AntGrpFac,NrUlUlschPDUs.nNrOfLayers);
                             % accumulation of channel estimates for each
                            % antenna group
                                    for WW=1:AntGrpFac
    
                                        indAnt=(indAntGroup-1)*AntGrpFac+WW;
                                        ind = 1;
                                        temp6_slot1 = zeros(1,NrUlUlschPDUs.nNrOfLayers);
                                        for ind1 =1:length(CdmGroup)
                                            for ind2 = 1:CdmGroup(ind1)
                                                temp6_slot1(1,ind) = puschChEstimates(indAnt).cdm(ind1).layer(ind2).data(indtone,indsymb,indchunck);
                                                ind = ind+1;
                                            end

                                        end 

                                        H_MMSE_slot1(WW,:) = temp6_slot1;
    
                                    end 
                            % Whitening the channel estimates
                                    H_MMSE_slot11= Noise_whiten(indAntGroup,indcovgrp).group1*H_MMSE_slot1;
    
                            % Whitening the Received vector
                                    y_tilda_slot1=Noise_whiten(indAntGroup,indcovgrp).group1*RxedDataPerTone(indsymb).data((indAntGroup-1)*AntGrpFac+1:indAntGroup*AntGrpFac,indtone);

                                    H_MMSE_slot11_new( (indAntGroup-1)*AntGrpFac+1:(indAntGroup)*AntGrpFac,1:NrUlUlschPDUs.nNrOfLayers) = H_MMSE_slot11;
   
                                    Y_1((indAntGroup-1)*AntGrpFac+1:(indAntGroup)*AntGrpFac,1) = y_tilda_slot1;
    
 
                                end 
                                ChanWhite(indtonegrp).data  = (H_MMSE_slot11_new);% size : N_r X N_u
                                
                                RxdVecWhite(indtone).data = Y_1; %size : N_r X 1
                        end
                     % MMSE Equalization
                        for indtonegrp = 1:NtonesScheduled/(toneAvgFac*N_t)
                            scale(indtonegrp).data = inv((ChanWhite(indtonegrp).data'*ChanWhite(indtonegrp).data+eye(sum(CdmGroup))));
                            filter(indtonegrp).data =  scale(indtonegrp).data*ChanWhite(indtonegrp).data';%*Y_1;
                            
                            Y_Hat = zeros(sum(CdmGroup),(toneAvgFac*N_t)-puschPtrsIdx.loc.freq.len);
                            reCount = 1;
                            %Equalization
                            for indtone = 1:(toneAvgFac*N_t)
                                ind1 = (indtonegrp-1)*(toneAvgFac*N_t)+indtone;
                                if(~(sum(indsymb == puschPtrsIdx.loc.time.data+1) && sum(ind1 == puschPtrsIdx.loc.freq.data+1)))
                                    switch NrUlUlschPDUs.nResourceAllocType
                                        case 0
                                            Y_Hat(:,reCount) = filter(indtonegrp).data*RxdVecWhite(ind1).data.*exp(-1i*TimeOffset*(toneStIdx+toneindx(ind1)-1));
                                        case 1
                                            Y_Hat(:,reCount) = filter(indtonegrp).data*RxdVecWhite(ind1).data.*exp(-1i*TimeOffset*(toneStIdx+ind1-1));
                                    end
                                    reCount = reCount+1;
                                end
                            end
                            
                            EqualizedData = [EqualizedData (Y_Hat*exp(-1i*freqOffsetAngle*(indsymb-1)))];
                        end
                           EqualizedData((ind22-1)*NtonesScheduled+1:ind22*NtonesScheduled) = ifft(EqualizedData((ind22-1)*NtonesScheduled+1:ind22*NtonesScheduled),NtonesScheduled,2)*sqrt(NtonesScheduled);
                           ind22 = ind22+1;
                    % Calculation of LLR Scaling values

                        if indsymb == symbscaindx
                            for indtonegrp = 1:NtonesScheduled/(toneAvgFac*N_t)
                                scalingfactor(:,indtonegrp) = diag(scale(indtonegrp).data);
                                        gamma(:,indtonegrp) = (1./scalingfactor(:,indtonegrp))-1;
                            end
                        end 
                    elseif DataInterleaving>0
%                         for indcdm = dmrsCdmGWithData
                            for indtone = datatoneindx

                                indtonegrp = ceil(indtone/toneAvgFac);
                                indcovgrp = ceil(indtone/CovGrpFac);
                                H_MMSE_slot11_new = zeros(Nr,NrUlUlschPDUs.nNrOfLayers);
                                Y_1 = zeros(Nr,1);

                                    for indAntGroup=1:Nr/AntGrpFac

                                        H_MMSE_slot1 = zeros(AntGrpFac,NrUlUlschPDUs.nNrOfLayers);

                                        for WW=1:AntGrpFac

                                            indAnt=(indAntGroup-1)*AntGrpFac+WW;
                                            ind = 1;
                                            for ind1 = find(CdmGroup~=0)
                                                for ind2 = 1:CdmGroup(ind1)
                                                    temp6_slot1(ind) = puschChEstimates(indAnt).cdm(ind1).layer(ind2).data(indtone,indsymb,indchunck);%% include antenna dimension in this
                                                    ind = ind+1;
                                                end

                                            end 

                                            H_MMSE_slot1(WW,:) = temp6_slot1;

                                        end 
    %                                     Whitening the channel estimates
                                        H_MMSE_slot11= Noise_whiten(indAntGroup,indcovgrp).group1*H_MMSE_slot1;

    %                                     Whitening the Received vector
                                        y_tilda_slot1=Noise_whiten(indAntGroup,indcovgrp).group1*RxedDataPerTone(indsymb).data((indAntGroup-1)*AntGrpFac+1:indAntGroup*AntGrpFac,indtone);

                                         H_MMSE_slot11_new( (indAntGroup-1)*AntGrpFac+1:(indAntGroup)*AntGrpFac,...
                                                                   NrUlUlschPDUs.nNrOfLayers ) = H_MMSE_slot11;

                                        Y_1((indAntGroup-1)*AntGrpFac+1:(indAntGroup)*AntGrpFac,1) = y_tilda_slot1;


                                    end 
                                    ChanWhite(indtonegrp).data  = (H_MMSE_slot11_new);% size : N_r X N_u

                                    RxdVecWhite(indtone).data = Y_1; %size : N_r X 1
                            end
                            for indtonegrp = 1:NtonesScheduled/CovGrpFac
                                scale(indtonegrp).data = inv((ChanWhite(indtonegrp).data'*ChanWhite(indtonegrp).data+eye(sum(CdmGroup))));
                                filter(indtonegrp).data =  scale(indtonegrp).data*ChanWhite(indtonegrp).data';
                                indt = 1;
                                Y_Hat = zeros(sum(CdmGroup),(toneAvgFac*N_t)-puschPtrsIdx.loc.freq.len);
                                for indtone = datatoneindx(1:CovGrpFac*length(dmrsCdmGWithData)/N_t)
                                    ind1 = (indtonegrp-1)*CovGrpFac+indtone;
                                    switch NrUlUlschPDUs.nResourceAllocType
                                        case 0
                                            Y_Hat(:,indt) = filter(indtonegrp).data*RxdVecWhite(ind1).data.*exp(-1i*TimeOffset*(toneStIdx+toneindx(ind1)-1));
                                        case 1
                                            Y_Hat(:,indt) = filter(indtonegrp).data*RxdVecWhite(ind1).data.*exp(-1i*TimeOffset*(toneStIdx+ind1-1));
                                    end
                                    indt = indt+1;
                                end
                                EqualizedData = [EqualizedData (Y_Hat*exp(-1i*freqOffsetAngle*(indsymb-1)))];
                            end
                                EqualizedData((ind22-1)*NtonesScheduled+1:ind22*NtonesScheduled) = ifft(EqualizedData((ind22-1)*NtonesScheduled+1:ind22*NtonesScheduled),NtonesScheduled,2);
                                ind22 = ind22+1;
%                         end
                        
                    end
                    
                end

            else 
%% without IRC           
          
           EqualizedData_F = [];
                scalingfactor = zeros(sum(CdmGroup),NtonesScheduled/(N_t*toneAvgFac));
                gamma = zeros(sum(CdmGroup),NtonesScheduled/(N_t*toneAvgFac));
                scale = zeros(sum(CdmGroup),sum(CdmGroup),NtonesScheduled/(N_t*toneAvgFac));
                filter = zeros(sum(CdmGroup),Nr,NtonesScheduled/(N_t*toneAvgFac));
                ind22 = 1;
                    for indsymb=1:NrUlUlschPDUs.nNrOfSymbols  %% MMSE Equalizer is applied on data symbols 
%                         if indsymb ~= puschDmrsSyms+1
                            for indtonegrp = 1:NtonesScheduled/(N_t*toneAvgFac)
                                indtemp = ( indtonegrp-1)*(N_t*toneAvgFac)+1;
                                H_MMSE_slot11_new  = zeros(Nr,NrUlUlschPDUs.nNrOfLayers);
                                for indAnt = 1:Nr
                                    temp16 = zeros(1,NrUlUlschPDUs.nNrOfLayers);
                                    ind = 1;
                                    for ind1 =1:length(CdmGroup)
                                        for ind2 = 1:CdmGroup(ind1)
                                            temp16(1,ind) = puschChEstimates(indAnt).cdm(ind1).layer(ind2).data(indtemp,indsymb,indchunck);%% include antenna dimension in this
                                            ind = ind+1;
                                        end
                                    end 
                                  
                                    H_MMSE_slot11_new(indAnt,:) = temp16;
                                end
%                                 if (indtonegrp <= Exs && NoiseVariance<0.005) || (indtonegrp >= NtonesScheduled-Exs+1 && NoiseVariance<0.005)
%                                     scale(:,:,indtonegrp) = inv(H_MMSE_slot11_new'*H_MMSE_slot11_new+0.001*eye(sum(CdmGroup)));
%                                 else
                                if NrUlUlschPDUs.modOrder == 1 || NrUlUlschPDUs.modOrder == 2 || NrUlUlschPDUs.modOrder == 4
                                    scale(:,:,indtonegrp) = inv(H_MMSE_slot11_new'*H_MMSE_slot11_new+NoiseVariance*eye(sum(CdmGroup))+1e-2);
                                else
                                    scale(:,:,indtonegrp) = inv(H_MMSE_slot11_new'*H_MMSE_slot11_new+NoiseVariance*eye(sum(CdmGroup))+0.*1e-3);
                                end
%                                 end

%                                 scale1(indtonegrp).data = inv(H_MMSE_slot11_new'*inv(NoiseVariance*eye(sum(CdmGroup)))*H_MMSE_slot11_new+eye(sum(CdmGroup)));
                                
                                filter(:,:,indtonegrp) = scale(:,:,indtonegrp)*(H_MMSE_slot11_new');
%                                 filter(indtonegrp).data = (H_MMSE_slot11_new');
                                
                            Y_Hat = zeros(sum(CdmGroup),N_t*toneAvgFac-puschPtrsIdx.loc.freq.len);
                                reCount = 1;
                                for ind1 = (indtonegrp-1)*N_t*toneAvgFac+1:indtonegrp*toneAvgFac*N_t
                                    if(~(sum(indsymb == puschPtrsIdx.loc.time.data+1) && sum(ind1 == puschPtrsIdx.loc.freq.data+1)))
                                         switch NrUlUlschPDUs.nResourceAllocType
                                            case 0
                                                Y_Hat(:,reCount) = filter(:,:,indtonegrp)*RxedDataPerTone(indsymb).data(:,ind1).*exp(-1i*TimeOffset*(toneStIdx+toneindx(ind1)-1));
                                            case 1
                                                Y_Hat(:,reCount) = filter(:,:,indtonegrp)*RxedDataPerTone(indsymb).data(:,ind1).*exp(-1i*TimeOffset*(toneStIdx+ind1-1));
                                                %RxedDataPerTone specfolded
                                                %data
                                             
                                        end
                                        reCount = reCount+1;
%                                         Y_Hat(reCount,:) = filter(indtonegrp).data*RxedDataPerTone(indsymb).data(:,ind1).*exp(-1i*TimeOffset*(toneStIdx+ind1-1));
%                                         reCount = reCount+1;
                                    end
                                end
                                EqualizedData_F=[EqualizedData_F (Y_Hat*exp(-1i*freqOffsetAngle*(indsymb-1)))];
                            end
                             EqualizedData_T(:,(ind22-1)*NtonesScheduled+1:ind22*NtonesScheduled) = ifft(EqualizedData_F(:,(ind22-1)*NtonesScheduled+1:ind22*NtonesScheduled),NtonesScheduled,2);                            
                            
                            
                            EqualizedData = [ EqualizedData_T ]; 
%                             EqualizedData = [EqualizedData_T(1,Exs+(1:Exs)) EqualizedData_T(2*Exs+1:dftsize) EqualizedData_T(1,Exs+dftsize-(Exs-1:-1:0))]; 
                            ind22 = ind22+1;
                            if indsymb == symbscaindx
                                for indtonegrp = 1:NtonesScheduled/(N_t*toneAvgFac)
                                    scalingfactor(:,indtonegrp) = diag(NoiseVariance*scale(:,:,indtonegrp));
                                       %scalingfactor(:,indtonegrp) = diag(scale1(indtonegrp).data);
                                            gamma(:,indtonegrp) = (1./scalingfactor(:,indtonegrp))-1;
                                end 
                            end 
%                         elseif DataInterleaving == 1
% %                             for indcdm = dmrsCdmGWithData
%                                 for indtonegrp = 1:NtonesScheduled/(N_t*toneAvgFac)
%                                     indtemp = ( indtonegrp-1)*(N_t*toneAvgFac)+1;
%                                     H_MMSE_slot11_new = zeros(Nr,NrUlUlschPDUs.nNrOfLayers);
%                                     for indAnt = 1:Nr
%                                         ind = 1;
%                                         temp16 = zeros(1,NrUlUlschPDUs.nNrOfLayers);
%                                         for ind1 =1:length(CdmGroup)
%                                             for ind2 = 1:CdmGroup(ind1)
%                                                 temp16(1,ind) = puschChEstimates(indAnt).cdm(ind1).layer(ind2).data(indtemp,indsymb);%% include antenna dimension in this
%                                                 ind = ind+1;
%                                             end
% 
%                                         end 
% 
%                                         H_MMSE_slot11_new(indAnt,:) = temp16;
%                                     end
%                                 Y_Hat = zeros(sum(CdmGroup),(toneAvgFac*(length(dmrsCdmGWithData))/N_t)-puschPtrsIdx.loc.freq.len);
%                                     scale(:,:,indtonegrp) = inv(H_MMSE_slot11_new'*H_MMSE_slot11_new+NoiseVariance*eye(sum(CdmGroup)));
%                                     filter(:,:,indtonegrp) = scale(:,:,indtonegrp)*(H_MMSE_slot11_new');
%                                     indt = 1;
%                                     for ind1 = datatoneindx(((indtonegrp-1)*toneAvgFac*(length(dmrsCdmGWithData))+1):indtonegrp*toneAvgFac*(length(dmrsCdmGWithData)))
% 
%                                         switch NrUlUlschPDUs.nResourceAllocType
%                                             case 0
%                                                 Y_Hat(:,indt) = filter(:,:,indtonegrp)*RxedDataPerTone(indsymb).data(:,ind1).*exp(-1i*TimeOffset*(toneStIdx+toneindx(ind1)-1));
%                                             case 1
%                                                 Y_Hat(:,indt) = filter(:,:,indtonegrp)*RxedDataPerTone(indsymb).data(:,ind1).*exp(-1i*TimeOffset*(toneStIdx+ind1-1));
%                                         end
%                                        indt = indt+1;
%                                     end
%                                     EqualizedData=[EqualizedData (Y_Hat*exp(-1i*freqOffsetAngle*(indsymb-1)))];
%                                 end 
%                                 EqualizedData((ind22-1)*NtonesScheduled+1:ind22*NtonesScheduled) = ifft(EqualizedData((ind22-1)*NtonesScheduled+1:ind22*NtonesScheduled),NtonesScheduled,2)*sqrt(NtonesScheduled);
%                                 ind22 = ind22+1;
% %                             end
%                         end
                         
                    end  
     
            end
end
% EqualizedData = EqualizedData.';ata.';