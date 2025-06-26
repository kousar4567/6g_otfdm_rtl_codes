
% Following Function estimate the phase using PTRS signals

function [ptrsPhaseEstimated] = wnNrPhyPuschPhaseEstimator(puschPtrsIdx, ...
                                                           puschPtrsSyms, ...
                                                           NrUlUlschPDUs)
                                      
     % Initializing Phase Estimate
     AvgPhaseDiffTemp = zeros(puschPtrsIdx.loc.time.len,2) + 1i*zeros(puschPtrsIdx.loc.time.len,2);

    for freIdx = 1:1:puschPtrsIdx.loc.freq.len  
        for timeIdx = 1:1:puschPtrsIdx.loc.time.len
            % At PTRS locations -> H2 = Y2/X2 :: H3 = Y3/X3 and so on
            Hothers(freIdx, timeIdx) = puschPtrsSyms.rx(freIdx, timeIdx) / puschPtrsSyms.tx(freIdx,1);
            
            % now this expression should give exp(theta_2 - theta_1) for
            % all the PTRS locations
            AvgPhaseDiffTemp(timeIdx,1) = AvgPhaseDiffTemp(timeIdx,1) + Hothers(freIdx, timeIdx);
            AvgPhaseDiffTemp(timeIdx,2) = AvgPhaseDiffTemp(timeIdx,2) + puschPtrsSyms.hMatrix(freIdx, timeIdx);
        end
    end
    for timeIdx = 1:1:puschPtrsIdx.loc.time.len
        AvgPhaseDiff(timeIdx,1) = angle(AvgPhaseDiffTemp(timeIdx,1)/AvgPhaseDiffTemp(timeIdx,2));
    end
    
    NewTimeIdx = puschPtrsIdx.loc.time.data;
    % Interpolate the phase over complete data
    interpoltdData(1,1) =  AvgPhaseDiff(1,1);
        
    for idx = 2:1:puschPtrsIdx.loc.time.len
        diffPhase = AvgPhaseDiff(idx,1) - AvgPhaseDiff(idx-1,1);
        diffSym = NewTimeIdx(1,idx) - NewTimeIdx(1,idx-1);
            
        interpolValue = diffPhase/diffSym;
            
        for idxDif = 1:1:diffSym
            interpoltdData(NewTimeIdx(1,idx-1)+idxDif+1,1) = AvgPhaseDiff(idx-1,1) + interpolValue*idxDif;
        end
    end 
    
    % Interpolating for the last OFDM symbols
    for idx = NewTimeIdx(puschPtrsIdx.loc.time.len)+2 : 1 : NrUlUlschPDUs.nNrOfSymbols
        interpoltdData(idx) = interpoltdData(idx-1);
    end
    
    ptrsPhaseEstimated = interpoltdData;
    
  
 end % End of the function
