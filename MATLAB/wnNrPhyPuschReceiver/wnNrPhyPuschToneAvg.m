

function [puschToneAvg,toneAvgfactor] = wnNrPhyPuschToneAvg(puschModRemvd,...
                                                              toneAvgfactor,...
                                                              dmrsCdmG, ...
                                                              dmrsSymIndex, ...
                                                              NDmrsPrb, ...
                                                              C,...
                                                              grp2)

% defining tone averaging factor 
% if NrUlUlschPDUs.nDMRSConfigType == 0
%     toneAvgfactor = 6;
% elseif NrUlUlschPDUs.nDMRSConfigType == 1
%     toneAvgfactor = 4;
% end
        for indcdm = (find(dmrsCdmG~=0))
            for indsymb = 1:length(dmrsSymIndex)
                tempcdm0 = zeros(C*NDmrsPrb,dmrsCdmG(indcdm));

                         % separating with respect to CDM groups

                        for indgroup = 1:floor(NDmrsPrb/toneAvgfactor)
                            temp = mean(puschModRemvd(indsymb).cdm(indcdm).data((indgroup-1)*toneAvgfactor+1 : (indgroup)*toneAvgfactor,:));
                            tempcdm0((indgroup-1)*C*toneAvgfactor+1:(indgroup)*C*toneAvgfactor,1:dmrsCdmG(indcdm)) = repmat(temp,C*toneAvgfactor,1);
                        end 
                        puschToneAvg(indsymb).cdm(indcdm).data = tempcdm0; 
            end
            if grp2 == 1    
%                  further averaging over symbols to get the good estimates
                for indsymb = 1:length(NrPuschDmrsSymbols)*0.5
                    temp12 = (puschToneAvg(2*indsymb-1).cdm(indcdm).data + puschToneAvg(2*indsymb).cdm(indcdm).data)*0.5;
                    puschToneAvg(2*indsymb-1).cdm(indcdm).data = temp12;
                    puschToneAvg(2*indsymb).cdm(indcdm).data = temp12;                     
                end  
            end
        end
end           