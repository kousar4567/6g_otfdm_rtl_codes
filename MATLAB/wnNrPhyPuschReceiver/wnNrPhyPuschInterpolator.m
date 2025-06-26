% clc;clear;

% Interpolation for Nrpusch

function [puschChEstimate] = wnNrPhyPuschInterpolator(puschToneAvg,NrUlUlschPDUs,dmrsSymIndex,dmrsCdmG,...
                                                      Dopplerflag)
%% getting the starting symbol for interpolation
% in mapping type A, PUSCH starts form 0th symbol, DMRS position is given
% by higher layers.
% in mapping type B, PUSCH starting position and DMRS starting position
% matches.
dctone = NrUlUlschPDUs.nBWPSize*6;
% Dopplerflag = 1;
% switch NrUlUlschPDUs.nMappingType 
%     case 0
    startsympos = 0;
%     case 1
%     startsympos = dmrsSymIndex(1);
% end    

if (length(dmrsSymIndex) == 1 ) || (length(dmrsSymIndex) == 2 && NrUlUlschPDUs.nNrofDMRSSymbols == 2 )
    %% LOW DOPPLER
    %considering that only one DMRS symbol is present
    for ind1 = 1:length(dmrsCdmG)
        for ind2 = 1:dmrsCdmG(ind1)
            for indsymb = startsympos+1:(NrUlUlschPDUs.nNrOfSymbols)
                puschChEstimate.cdm(ind1).layer(ind2).data(:,indsymb) = puschToneAvg(1).cdm(ind1).layer(ind2).data(:,dmrsSymIndex(1)+1);
                
            end
        end
    end
elseif NrUlUlschPDUs.nNrofDMRSSymbols == 1
    % for single front loaded
    if Dopplerflag == 0  
        if length(dmrsSymIndex)>1       %% Need to update for RS symbols more than 1 and less than total number of allocated symbols   
            for ind1 = find(dmrsCdmG~=0)
                for ind2 = 1:dmrsCdmG(ind1)
                    % from initial symbol to symbol previous to 
                    % second DMRS symbol
                    for indsymb = startsympos+1:dmrsSymIndex(2)-2
                        puschChEstimate.cdm(ind1).layer(ind2).data(:,indsymb) = puschToneAvg(1).cdm(ind1).layer(ind2).data(:,dmrsSymIndex(1)+1);
                    end
                    % from second symbol to symbol previous to last
                    % DMRS symbol
                    for ind = 2:length(dmrsSymIndex)-1
                        for indsymb = dmrsSymIndex(ind)-1:dmrsSymIndex(ind+1)-1
                            puschChEstimate.cdm(ind1).layer(ind2).data(:,indsymb) = puschToneAvg(1).cdm(ind1).layer(ind2).data(:,dmrsSymIndex(ind)+1);
                        end 
                    end 
                    % from last DMRS symbol to last symbol in allocation                    
                    for indsymb = dmrsSymIndex(end)-1:NrUlUlschPDUs.nNrOfSymbols
                        puschChEstimate.cdm(ind1).layer(ind2).data(:,indsymb) = puschToneAvg(1).cdm(ind1).layer(ind2).data(:,dmrsSymIndex(end)+1);
                    end
                end
            end            
        else 
            for ind1 = find(dmrsCdmG~=0)
                for ind2 = 1:dmrsCdmG(ind1)
                    % from initial symbol to symbol previous to second DMRS symbol
                    for indsymb = startsympos+1:NrUlUlschPDUs.nNrOfSymbols
                        puschChEstimate.cdm(ind1).layer(ind2).data(:,indsymb) = (puschToneAvg(1).cdm(ind1).data(:,ind2)+puschToneAvg(2).cdm(ind1).data(:,ind2))*0.5;
                    end
                end
            end
        end
    else % Need to change for pre-DFT-system
        for ind1 = find(dmrsCdmG~=0)
            for ind2 = 1:dmrsCdmG(ind1)
                firstsymb = 1;
                puschChEstimate.cdm(ind1).layer(ind2).data = zeros(12*NrUlUlschPDUs.nPrbAllocated,14);
                for inddmrssymb = 2:length(dmrsSymIndex)
                    if inddmrssymb == length(dmrsSymIndex)
                        temp3_slot1 = puschToneAvg(inddmrssymb-1).cdm(ind1).data(:,ind2);
                        temp3_slot2 = puschToneAvg(inddmrssymb).cdm(ind1).data(:,ind2);
                          location2 = dmrsSymIndex(inddmrssymb)+1;
                          location1 = dmrsSymIndex(inddmrssymb-1)+1;
%                           firstsymb = firstsymb;
                          lastsymb  = 14;
                        puschChEstimate.cdm(ind1).layer(ind2).data(:,firstsymb:lastsymb) = wnNrPhyLinInterpo(location1,...
                                                                                    location2,...
                                                                                    temp3_slot1,...
                                                                                    temp3_slot2,...
                                                                                    firstsymb,...
                                                                                    lastsymb);

                    else
                        temp3_slot1 = NrPuschChannelEstimates(inddmrssymb-1).cdm(ind1).data(:,ind2);
                        temp3_slot2 = NrPuschChannelEstimates(inddmrssymb).cdm(ind1).data(:,ind2);
                          location2 = dmrsSymIndex(inddmrssymb)+1;
                          location1 = dmrsSymIndex(inddmrssymb-1)+1;
%                           firstsymb = symbidx;
                          lastsymb  = dmrsSymIndex(inddmrssymb);
                        puschChEstimate.cdm(ind1).layer(ind2).data(:,firstsymb:lastsymb) = wnNrPhyLinInterpo(location1,...
                                                                                    location2,...
                                                                                    temp3_slot1,...
                                                                                    temp3_slot2,...
                                                                                    firstsymb,...
                                                                                    lastsymb);
                        firstsymb = lastsymb;
                    end
                end
                
            end
        end
                
    end

elseif NrUlUlschPDUs.nNrofDMRSSymbols == 2
   % for double front loaded
        for ind1 = find(dmrsCdmG~=0)
            for ind2 = 1:dmrsCdmG(ind1)
                for indsymb = startsympos+1:1:dmrsSymIndex(3)
                     puschChEstimate(ind1).layer(ind2).data(:,indsymb) = (puschToneAvg(1).cdm(ind1).data(:,ind2)+puschToneAvg(2).cdm(ind1).data(:,ind2))*0.5;
                end

                for indsymb = dmrsSymIndex(3)+1:1:NrUlUlschPDUs.nNrOfSymbols
                     puschChEstimate(ind1).layer(ind2).data(:,indsymb) = (puschToneAvg(3).cdm(ind1).data(:,ind2)+puschToneAvg(4).cdm(ind1).data(:,ind2))*0.5;
                end
            end
        end
end 
end%function end