function [NrOffsetCorrectEstimates,dataStartIdx] = NrTimeOffsetCorrection(puschModRemvd, ...
                                                             CdmToneIndx, ...
                                                             dmrsCdmG,...
                                                             dmrsSymIndex,...
                                                             timeOffsetAngle,...
                                                             fftSize, ...
                                                             NrUlUlschPDUs, ...
                                                             toneindx1)
    switch NrUlUlschPDUs.nResourceAllocType 
        case 1
            dataStartIdx = (fftSize - NrUlUlschPDUs.nBwSize*12)/2 + 12*NrUlUlschPDUs.nBWPStart+NrUlUlschPDUs.nRBStart*12;
            % de-rotation of channel estimates
                for indcdm = (find(dmrsCdmG~=0))
                    for indsymb = 1:length(dmrsSymIndex)
                        offset_vector = repmat(exp(-1i*timeOffsetAngle*(dataStartIdx+(CdmToneIndx(indcdm,:)-1))).',1,dmrsCdmG(indcdm));
                        NrOffsetCorrectEstimates(indsymb).cdm(indcdm).data = ...
                                puschModRemvd(indsymb).cdm(indcdm).data.*offset_vector;
                    end
                end
        case 0
            dataStartIdx = (fftSize - NrUlUlschPDUs.nBwSize*12)/2 + 12*NrUlUlschPDUs.nBWPStart;
            for indcdm = (find(dmrsCdmG~=0))
                for indsymb = 1:length(dmrsSymIndex)
                    offset_vector = repmat(exp(-1i*timeOffsetAngle*(dataStartIdx+(toneindx1(indcdm,:)-1))).',1,dmrsCdmG(indcdm));
                    NrOffsetCorrectEstimates(indsymb).cdm(indcdm).data = ...
                                                    puschModRemvd(indsymb).cdm(indcdm).data.*offset_vector;
                end 
                        
            end  
    end
