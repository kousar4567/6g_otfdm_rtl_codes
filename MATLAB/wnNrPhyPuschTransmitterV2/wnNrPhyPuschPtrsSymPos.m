function[PtrsSymIdx]=wnNrPhyPuschPtrsSymPos(NrUlUlschPDUs, dmrs_sym_indices)
nNrOfSymbols,nPTRSTimeDensity,nNrofDMRSSymbols
    % Initialization
    PtrsSymIdx = [];

    % Index of symbols allocated to PDSCH
    puschLastSymIdx = NrUlUlschPDUs.nNrOfSymbols-1;

    tempCounter = 0;
    L_ref = 0;
    
    ptrsAllocated = 1;

    % For drms symbol indices
    dmrsSymCounter = 1; 

    while (1)
        while (1)
      
            % Calculating the symbol indices to check overlapping with DMRS
            start_index = max(L_ref+((tempCounter-1)*NrUlUlschPDUs.nPTRSTimeDensity)+1, L_ref);
            indices = start_index:1:(L_ref+(tempCounter*NrUlUlschPDUs.nPTRSTimeDensity));
  
            % To find intersection b/w ptrs and dmrs sym indices
            overlap = 0;
            
            for i = 1:length(indices)
                for j = 1:length(dmrs_sym_indices)
                    if indices(i) == dmrs_sym_indices(j)
                        overlap = 1;
                        break;
                    end
                end
                if (overlap == 1)
                    break;
                end
            end

            % If there is any overlap of PTRS symbol with DMRS symbols
            if (overlap == 1) 
                tempCounter = 1;
                L_ref = dmrs_sym_indices(dmrsSymCounter);
      
                % In case of Double symbol DMRS 2nd symbol of DMRS will be the reference symbol
                % Otherwise the first symbol will be the reference
                if NrUlUlschPDUs.nNrofDMRSSymbols == 2
                    L_ref = L_ref+1;
                    dmrsSymCounter = dmrsSymCounter + 2;  
                else
                    dmrsSymCounter = dmrsSymCounter + 1;
                end
    
                % PTRS Symbol index should not exceed the PDSCH allocation boundary
                if (L_ref+(tempCounter*NrUlUlschPDUs.nPTRSTimeDensity) > puschLastSymIdx)
                     break;
                end
            
            % If there is no overlap with DMRS symbols    
            else
                break;
            end
            
        end % End of 2nd while loop
  
        % When the PTRS symbol is inside the PDSCH symbol boundary and
        % there is no overlap with DMRS symbols then it will be allocated
        % to PTRS
        if (L_ref + tempCounter*NrUlUlschPDUs.nPTRSTimeDensity <= puschLastSymIdx)
            PtrsSymIdx(ptrsAllocated) = L_ref + tempCounter*NrUlUlschPDUs.nPTRSTimeDensity;
            ptrsAllocated = ptrsAllocated + 1;
            
        end
  
        % Moving to the next SC
        tempCounter = tempCounter + 1;
  
        % If PTRS exceeds the PDSCH symbol boundary
        if L_ref+(tempCounter*NrUlUlschPDUs.nPTRSTimeDensity) > puschLastSymIdx
            break;
        end
        
    end % End of 1st while loop
    
end %end of function