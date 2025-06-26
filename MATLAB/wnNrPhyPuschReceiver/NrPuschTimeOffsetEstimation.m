        
% Calculation of NrPuschTimeOffset
function [TimeOffset] = NrPuschTimeOffsetEstimation(CdmGroup,NrPuschModulationRemoved,NtonesScheduled,NrPuschDmrsSymbols,NDmrsTonesPrb)

        for indcdm = 1:find(CdmGroup~=0)
            for indlayer = 1:CdmGroup(indcdm)

                for indsymb = 1:length(NrPuschDmrsSymbols)
                    angle_1 = 0;
                    angle_2 = 0;
                    for ii = 1:2:(NtonesScheduled/NDmrsTonesPrb)-2
                %         dimension of below vector is (N_sc/4)-1
                        angle_1((ii+1)/2) =  ((NrPuschModulationRemoved(indsymb).cdm(indcdm).data(ii,indlayer)'*...
                                                 NrPuschModulationRemoved(indsymb).cdm(indcdm).data(ii+2,indlayer)));
                        angle_2((ii+1)/2) =  ((NrPuschModulationRemoved(indsymb).cdm(indcdm).data(ii+1,indlayer)'*...
                                                 NrPuschModulationRemoved(indsymb).cdm(indcdm).data(ii+3,indlayer)));
                    end
                    angle_symb(indsymb) =  0.5*(mean(angle_1+angle_2));
                end
                angle1(indlayer) = mean(angle_symb);
            end
            timeoffset(indcdm) = mean(angle1);
        end
        TimeOffset = angle(mean(timeoffset))/(2*NDmrsTonesPrb);

        