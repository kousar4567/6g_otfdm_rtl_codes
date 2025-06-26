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



function [BlockDiagMtx,CdmToneIndx,nDmrsPrb] = DmrsBlockDiagonalMatrix(puschDmrsMap,...
                                                                        dmrsCdmG, ...
                                                                        dmrsSymIndex, ...
                                                                        NrUlUlschPDUs)


    %% calculating the number of tones in the allocation
if NrUlUlschPDUs.nDMRSConfigType == 0
    nDmrsPrb = 6*NrUlUlschPDUs.nPrbAllocated;
    CdmToneIndx = zeros(2,nDmrsPrb);
    for indcdm = 1:2
        CdmToneIndx(indcdm,:) = indcdm:2:2*nDmrsPrb;
    end
else
    nDmrsPrb = 4*NrUlUlschPDUs.nPrbAllocated;
    CdmToneIndx = zeros(3,nDmrsPrb);
    CdmToneIndx(1,:) = [1 2 7 8 zeros(1,4*(NrUlUlschPDUs.nPrbAllocated-1))];

    for ind = 1:NrUlUlschPDUs.nPrbAllocated-1
        CdmToneIndx(1,4*ind+1:4*(ind)+4) = CdmToneIndx(1,1:4)+(ind)*12;
    end
    CdmToneIndx(2,:) = CdmToneIndx(1,:)+2;
    CdmToneIndx(3,:) = CdmToneIndx(2,:)+2;
end

    for indcdm = find(dmrsCdmG~=0)
        for indsymb = 1:length(dmrsSymIndex)
%        Form Block diagonal matrix for odd tones
            DMRS1 = zeros(nDmrsPrb,nDmrsPrb*dmrsCdmG(indcdm));
            for ind1 = 1:dmrsCdmG(indcdm)
                DMRS1(:,(ind1-1)*nDmrsPrb+1:(ind1)*nDmrsPrb) = [diag(puschDmrsMap(indsymb).cdm(indcdm).data(CdmToneIndx(indcdm,:),ind1))];
            end
            BlockDiagMtx(indsymb).CDM(indcdm).data = DMRS1; 
        end
    end