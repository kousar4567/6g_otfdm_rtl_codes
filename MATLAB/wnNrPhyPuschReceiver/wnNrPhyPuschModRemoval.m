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

function [puschModRemoved,CdmToneIndx,nDmrsPrb] = wnNrPhyPuschModRemoval(dmrsCdmG, ...
                                                    puschDmrsMap, ...
                                                    dmrsSymIndex,...
                                                    DemappedData, ...
                                                    NrUlUlschPDUs,...
                                                    scale)
% Inputs : 1.CdmGroup
%          2.NrPuschDmrsSymbols
%          3.DemappedData on one receive antenna
%          4.BlockDiagonalDmrs
%          5.tonecdm
%          6.NDmrsPrb
% Output : NrPuschModulationRemoved


%%

    %% calculating the number of tones in the allocation with respect to CDM group
switch NrUlUlschPDUs.nDMRSConfigType 
    case 0
        nDmrsPrb = 6*NrUlUlschPDUs.nPrbAllocated;
        CdmToneIndx = zeros(2,nDmrsPrb);
        for indcdm = 1:2
            CdmToneIndx(indcdm,:) = indcdm:2:2*nDmrsPrb;
        end
    case 1
        nDmrsPrb = 4*NrUlUlschPDUs.nPrbAllocated;
        CdmToneIndx = zeros(3,nDmrsPrb);
        CdmToneIndx(1,:) = [1 2 7 8 zeros(1,4*(NrUlUlschPDUs.nPrbAllocated-1))];

        for ind = 1:NrUlUlschPDUs.nPrbAllocated-1
            CdmToneIndx(1,4*ind+1:4*(ind)+4) = CdmToneIndx(1,1:4)+(ind)*12;
        end
        CdmToneIndx(2,:) = CdmToneIndx(1,:)+2;
        CdmToneIndx(3,:) = CdmToneIndx(2,:)+2;
end
%%
    for indcdm = (find(dmrsCdmG~=0))
        for indsymb = 1:length(dmrsSymIndex)
%        Least squares for all the layers/users scheduled
            for indlayer = 1:dmrsCdmG(indcdm)
                temp = (puschDmrsMap(indsymb).cdm(indcdm).data(CdmToneIndx(indcdm,:),indlayer)').'.*DemappedData(CdmToneIndx(indcdm,:) ,dmrsSymIndex(indsymb)+1);
                puschModRemoved(indsymb).cdm(indcdm).data(:,indlayer) = temp/(scale^2);
            
            end 
        end  
    end 
end