function [NrOffsetCorrectEstimates] = NrFreqOffsetCorrection(puschModRemvd, ...
                                               dmrsCdmG, ...
                                               dmrsSymIndex, ...
                                               freqOffsetAngle)
                                           
   for indcdm = (find(dmrsCdmG~=0))
        for indsymb = 1:length(dmrsSymIndex)
            offset_vector = exp(-1i*freqOffsetAngle*dmrsSymIndex(indsymb));
            NrOffsetCorrectEstimates(indsymb).cdm(indcdm).data = ...
                    puschModRemvd(indsymb).cdm(indcdm).data.*offset_vector;
        end
   end
end