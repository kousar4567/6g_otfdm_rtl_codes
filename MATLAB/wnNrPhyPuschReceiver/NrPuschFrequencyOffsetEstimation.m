
% Doppler shift + CarrierFrequency offset calculation 

function [FrequencyOffset] = NrPuschFrequencyOffsetEstimation(CdmGroup, NrPuschModulationRemoved, NrPuschDmrsSymbols,bwFftCp)

FrequencyOffset = 0;

if length(NrPuschDmrsSymbols) > 1
    for indcdm = (find(CdmGroup~=0))
        for indlayer = 1:CdmGroup(indcdm)

            for indsymb = 1:length(NrPuschDmrsSymbols)-1
                
                temp_phase = mean( NrPuschModulationRemoved(indsymb+1).cdm(indcdm).data(:,indlayer)  .*...
                            conj(  NrPuschModulationRemoved(indsymb).cdm(indcdm).data(:,indlayer)) ) ;  % calculating the phase error

                    phase_err(indlayer,indsymb) = temp_phase;
            end
        end
        temp(indcdm,:) = (mean((phase_err),2));
    end
    temp2 = mean(temp);
    temp3 = (angle(temp2));
    
    FrequencyOffset = (temp3)/( (bwFftCp.fftSize+bwFftCp.cpSyms)*(NrPuschDmrsSymbols(indsymb+1)-NrPuschDmrsSymbols(indsymb)));
else
    fprintf('only one DMRS symbol, can not estimate the offset');
end