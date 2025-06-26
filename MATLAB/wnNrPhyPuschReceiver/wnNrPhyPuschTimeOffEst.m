        
% Calculation of NrPuschTimeOffset
function [TimeOffset] = wnNrPhyPuschTimeOffEst(dmrsCdmG, ...
                                                    puschModRemvd, ...
                                                    NtonesScheduled, ...
                                                    dmrsSymIndex, ...
                                                    NDmrsTonesPrb, ...
                                                    SRbg, ...
                                                    NrUlUlschPDUs)
switch NrUlUlschPDUs.nResourceAllocType
    case 1
        timeoffset = 0;
        for indcdm = find(dmrsCdmG~=0)
            angle1 = 0;
            for indlayer = 1:dmrsCdmG(indcdm)
                angle_symb = 0;
                for indsymb = 1:length(dmrsSymIndex)
                    angle_1 = 0;
                    angle_2 = 0;
                    for ii = 1:2:(NtonesScheduled/NDmrsTonesPrb)-2
                %         dimension of each vector is (N_sc/(2*NDmrsTonesPrb))-1
                        angle_1 =  angle_1+((puschModRemvd(indsymb).cdm(indcdm).data(ii,indlayer)'*...
                                                 puschModRemvd(indsymb).cdm(indcdm).data(ii+2,indlayer)));
                        angle_2 =  angle_2+((puschModRemvd(indsymb).cdm(indcdm).data(ii+1,indlayer)'*...
                                                 puschModRemvd(indsymb).cdm(indcdm).data(ii+3,indlayer)));
                    end
                    angle_symb =  angle_symb+(((angle_1+angle_2)/(NtonesScheduled/NDmrsTonesPrb-2)));
                end
                angle1 = angle1+((angle_symb)/(length(dmrsSymIndex)));
            end
            timeoffset = timeoffset+((angle1)/dmrsCdmG(indcdm));
        end
        TimeOffset = angle((timeoffset)/(length(find(dmrsCdmG~=0))))/(2*NDmrsTonesPrb);
    case 0
        %% for allocation type 0
        timeoffset = 0;
        for indcdm = find(dmrsCdmG~=0)
            angle1 = 0;
            for indlayer = 1:dmrsCdmG(indcdm)
                angle_symb = 0;
                for indsymb = 1:length(dmrsSymIndex)
                    angletemp = 0;
                    for ind = find(NrUlUlschPDUs.nRBGIndex~=0)
                        angle_1 = 0;
                        angle_2 = 0;
                        for ii = 1:2:(SRbg(ind)*12/NDmrsTonesPrb)-2
                            angle_1 =  angle_1+((puschModRemvd(indsymb).cdm(indcdm).data(ii,indlayer)'*...
                                                 puschModRemvd(indsymb).cdm(indcdm).data(ii+2,indlayer)));
                            angle_2 =  angle_2+((puschModRemvd(indsymb).cdm(indcdm).data(ii+1,indlayer)'*...
                                                 puschModRemvd(indsymb).cdm(indcdm).data(ii+3,indlayer)));
                        end 
                        angletemp = angletemp + (((angle_1+angle_2)/(SRbg(ind)*12/NDmrsTonesPrb-2)));
                    end
                    angle_symb = angle_symb + angletemp/(length(SRbg));
                end
                angle1 = angle1 + angle_symb/(length(dmrsSymIndex));
            end
            timeoffset = timeoffset+((angle1)/dmrsCdmG(indcdm));
        end
        TimeOffset = angle((timeoffset)/(length(find(dmrsCdmG~=0))))/(2*NDmrsTonesPrb);                            
        
end