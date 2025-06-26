% Subcarrier indices when Transform encoding enabled

function[freqIndxs] = wnNrPhyPuschPtrsScIndxs(NrUlUlschPDUs, ...
                                              dmrsAssAntPort)

nTransPrecode,nPrbAllocated,nGroupPrPtrs,nSamplesPtrsGrp,nDMRSConfigType,nPTRSReOffset,
nRNTI,nPTRSFreqDensity,
% 0: Transform Precoding Enabled
% 1: Transform Precoding Disabled

% if transform precoding enabled
if NrUlUlschPDUs.nTransPrecode == 0 

    % sub carriers in pusch allocation
    nSubcarriers = 12*NrUlUlschPDUs.nPrbAllocated;

    freqIndxs = zeros(1,(NrUlUlschPDUs.nGroupPrPtrs*NrUlUlschPDUs.nSamplesPtrsGrp));

    % Condition based on no. samples per group and no. groups in ptrs
    % to select among the switch cases
    cond = (1*NrUlUlschPDUs.nGroupPrPtrs) + (3*NrUlUlschPDUs.nSamplesPtrsGrp);

    temp_indx = 1;

    switch cond

    % nGroupPrPtrs == 2 && nSamplesPtrsGrp == 2
    case 8
        for s=1:2:3
            for k=0:1
                freqIndxs(temp_indx)=s*floor(nSubcarriers/4)+k-1;
                temp_indx=temp_indx+1;
            end
        end

    % nGroupPrPtrs == 2 && nSamplesPtrsGrp == 4
    case 14
        for s=0:1
            k=-4*s;
            for temp_indx=1:4
                freqIndxs(2*s+temp_indx)=s*floor(nSubcarriers/4)+k-1;
                k=k+1;
            end
        end

    % nGroupPrPtrs == 4 && nSamplesPtrsGrp == 2
    case 10
        for s=1:2:7
            for k=0:1
                freqIndxs(temp_indx)=floor((s*nSubcarriers)/8)+k-1;
                temp_indx=temp_indx+1;
            end
        end

    % nGroupPrPtrs == 4 && nSamplesPtrsGrp == 4
    case 16
        n=0;
        for s=0:4:4
            k=-1*s;
            for temp_indx=1:4
                freqIndxs(3*s+temp_indx)=((s*nSubcarriers)/4)+k+n;
                k=k+1;
            end
        end
        n = floor(nSubcarriers/8);
        temp_indx=5;
        for s=1:2
            for k=-2:1:1
                freqIndxs(temp_indx)=((s*nSubcarriers)/4)+k+n;
                temp_indx=temp_indx+1;
            end
        end

    % nGroupPrPtrs == 8 && nSamplesPtrsGrp == 4
    case 20
        p=0;
        n=0;
        for s=0:8:8
            k=-(1*s)/2;
            for temp_indx=1:4
                freqIndxs(7*p+temp_indx)=(floor((s*nSubcarriers)/8))+k+n;
                k=k+1;
            end
            p=4;
        end
        n=floor(nSubcarriers/16);
        temp_indx=5;
        for s=1:6
            for k=-2:1:1
                freqIndxs(temp_indx)=(floor((s*nSubcarriers)/8))+k+n;
                temp_indx=temp_indx+1;
            end
        end
    end % End of switch case

% Transform precoding disabled
else
    
    K_RE_ref =wnNrPhyPuschPtrsREkRef(NrUlUlschPDUs.nDMRSConfigType, ...
                                     dmrsAssAntPort, ...
                                     NrUlUlschPDUs.nPTRSReOffset);

    % Calculating the PRB reference for PTRS Mapping   
    temp_cond = mod(NrUlUlschPDUs.nPrbAllocated, NrUlUlschPDUs.nPTRSFreqDensity);
    if (temp_cond == 0)
        K_RB_ref = mod(NrUlUlschPDUs.nRNTI, NrUlUlschPDUs.nPTRSFreqDensity);
    else
        K_RB_ref = mod(NrUlUlschPDUs.nRNTI, temp_cond);
    end
    
    % Number of Subcarriers for PTRS transmission
    tempCounter = ceil(NrUlUlschPDUs.nPrbAllocated/NrUlUlschPDUs.nPTRSFreqDensity); 
    
    % Subcarrier indexes where the PTRS will be mapped
    freqIndxs = zeros(1,tempCounter);
    
    for i = 0:tempCounter-1
        freqIndxs(i+1) = K_RE_ref + ((i*NrUlUlschPDUs.nPTRSFreqDensity)+K_RB_ref)*12;
    end

end % transform precoding if condition
end % end of function