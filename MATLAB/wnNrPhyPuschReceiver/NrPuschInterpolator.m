%%
%% Copyright (c) 2016-2018, WiSig Networks Pvt Ltd. All rights reserved.
%% www.wisig.com
%% 
%% All information contained herein is property of WiSig Networks Pvt Ltd. 
%% unless otherwise explicitly mentioned.
%% 
%% The intellectual and technical concepts in this file are proprietary 
%% to WiSig Networks and may be covered by granted or in process national
%% and international patents and are protect by trade secrets and       
%% copyright law.
%% 
%% Redistribution and use in source and binary forms of the content in  
%% this file, with or without modification are not permitted unless     
%% permission is explicitly granted by WiSig Networks.                   
%% If WiSig Networks permits this source code to be used as a part of 
%% open source project, the terms and conditions of CC-By-ND (No Derivative) license
%% (https://creativecommons.org/licenses/by-nd/4.0/legalcode) shall apply.


% clc;clear;

% Interpolation for Nrpusch

function [NrPuschdurationChannelEstimates] = NrPuschInterpolator(NrPuschChannelEstimates,NrUlschPduPusch,NrPuschDmrsSymbols,CdmGroup)

if length(NrPuschDmrsSymbols) == 1 
%% LOW DOPPLER
    for ind1 = 1:length(CdmGroup)
        for ind2 = 1:CdmGroup(ind1)
            for indsymb = 1:(NrUlschPduPusch.nNrOfSymbols)%considering that only single front loaded DMRS is present
                NrPuschdurationChannelEstimates(ind1).layer(ind2).data(:,indsymb) = NrPuschChannelEstimates(1).cdm(ind1).data(:,ind2);
            end
        end
    end
else
% LINEAR INTERPOLATION
if (NrUlUlschPDUs.nMappingType == 1)
    for ind1 = 1:length(CdmGroup)
        for ind2=1:CdmGroup(ind1)
            for indsymb = 1:length(NrPuschDmrsSymbols)-1
                temp3_slot1 = NrPuschChannelEstimates(indsymb).cdm(ind1).data(:,ind2);
                temp3_slot2 = NrPuschChannelEstimates(indsymb+1).cdm(ind1).data(:,ind2);
                  location2 = NrPuschDmrsSymbols(indsymb+1)+1;
                  location1 = NrPuschDmrsSymbols(indsymb)+1;
                  
                  
                  if NrPuschDmrsSymbols(indsymb+1) == NrPuschDmrsSymbols(end)
                      for k=1:NrUlschPduPusch.nPrb*12
                    
                        for l =  NrPuschDmrsSymbols(indsymb)+1:NrUlschPduPusch.nNrOfSymbols
                            Channel_subframe(k,l)=((temp3_slot2(k)-temp3_slot1(k))/(location2-location1))*(l-location1)+temp3_slot1(k);
                        end 
                      end
                  else 
                      for k=1:NrUlschPduPusch.nPrb*12
                        for l =  NrPuschDmrsSymbols(indsymb)+1:NrPuschDmrsSymbols(indsymb+1)+1
                            Channel_subframe(k,l)=((temp3_slot2(k)-temp3_slot1(k))/(location2-location1))*(l-location1)+temp3_slot1(k);
                        end 
                      end 
                  end 
            end    
                NrPuschdurationChannelEstimates(ind1).layer(ind2).data = Channel_subframe;
        end 
    end  
    
elseif (NrUlUlschPDUs.nMappingType == 0)
    for ind1 = 1:length(CdmGroup)
        for ind2=1:CdmGroup(ind1)
            for indsymb = 1:length(NrPuschDmrsSymbols)-1
                temp3_slot1 = NrPuschChannelEstimates(indsymb).cdm(ind1).data(:,ind2);
                temp3_slot2 = NrPuschChannelEstimates(indsymb+1).cdm(ind1).data(:,ind2);
                  location2 = NrPuschDmrsSymbols(indsymb+1)+1;
                  location1 = NrPuschDmrsSymbols(indsymb)+1;
                  
                  
                  if NrPuschDmrsSymbols(indsymb+1) == NrPuschDmrsSymbols(end)
                      for k=1:NrUlschPduPusch.nPrb*12
                    
                        for l =  NrPuschDmrsSymbols(indsymb)+1:NrUlschPduPusch.nNrOfSymbols
                            Channel_subframe(k,l)=((temp3_slot2(k)-temp3_slot1(k))/(location2-location1))*(l-location1)+temp3_slot1(k);
                        end 
                      end
                  else 
                      for k=1:NrUlschPduPusch.nPrb*12
                        for l = 1:NrPuschDmrsSymbols(indsymb+1)+1
                            Channel_subframe(k,l)=((temp3_slot2(k)-temp3_slot1(k))/(location2-location1))*(l-location1)+temp3_slot1(k);
                        end 
                      end 
                  end 
            end    
                NrPuschdurationChannelEstimates(ind1).layer(ind2).data = Channel_subframe;
        end 
    end  
end 
end
            