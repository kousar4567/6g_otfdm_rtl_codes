

function [Tbs] = wnNrPhyPuschTbsCal(NrUlUlschPDUs,table,ModOrder,Rate)


if ( ((NrUlUlschPDUs.nMCS>=0 && NrUlUlschPDUs.nMCS<=27)&& NrUlUlschPDUs.nTransPrecode == 1 && table == 51312)||...
     ((NrUlUlschPDUs.nMCS>=0 && NrUlUlschPDUs.nMCS<=28)&& NrUlUlschPDUs.nTransPrecode == 1 && table ~= 51312)||...
     ((NrUlUlschPDUs.nMCS>=0 && NrUlUlschPDUs.nMCS<=27)&& NrUlUlschPDUs.nTransPrecode == 0) )
    
    % 1. Determine number of REs allocated for PUSCH
    % nREPrime = 12*NrUlUlschPDUs.nNrOfSymbols*NrUlUlschPDUs.nPrbAllocated - ....
    %            NrUlUlschPDUs.nNrofDMRSsymb*(NrUlUlschPDUs.nDMRSpSymb*2)*NrUlUlschPDUs.nNrofChunks-....
    %            NrUlUlschPDUs.NohPrb;
    nREPrime = (12*NrUlUlschPDUs.nPrbAllocated-2*NrUlUlschPDUs.nDMRSpSymb)*NrUlUlschPDUs.nNrOfSymbols;
    nRE = (nREPrime);
    
    % 2. Calculate Ninfo
    nInfo = nRE * Rate * ModOrder * NrUlUlschPDUs.nNrOfLayers;
    if nInfo <=3824
        % step 3 for calculation of TBS size
        n = max( 3 , floor( log2(nInfo) )-6 );
        nInfoPrime = max( 24 , 2^n * floor( nInfo/2^n ) );
        Tbs51321   = [24:8:192 208:16:384 408:24:576....
                     608:32:768 808:40:928 984 1032 1064 1128:32:1352....
                     1416:64:1928 2024:64:2280 2408:64:2856 2976 3104....
                     3240 3368 3496 3624 3752 3824];
        temp       = (Tbs51321-nInfoPrime)>=0;
%         Index      = min(find(temp == 1));
        Index      = find(temp == 1,1);
        Tbs        = Tbs51321(Index);
    else
        % step 4 for calculation of TBS size
        n = floor( log2(nInfo-24) -5 );
        nInfoPrime = max( 3840 , 2^n * round( (nInfo-24)/2^n ) );
        if (Rate) <= 0.25
            C   = ceil( (nInfoPrime+24) / 3816 );
            Tbs = 8*C*ceil( (nInfoPrime+24) / (8*C) ) - 24;
        else
            if nInfoPrime > 8424
                C   = ceil( (nInfoPrime+24) / 8424 );
                Tbs = 8*C*ceil( (nInfoPrime+24) / (8*C) ) - 24;
            else
                Tbs = 8*ceil( (nInfoPrime+24) / (8) ) - 24;
            end
        end
    end
elseif (((NrUlUlschPDUs.nMCS>=28 && NrUlUlschPDUs.nMCS<=31)&& NrUlUlschPDUs.nTransPrecode == 1 && table == 51312)||...
        (NrUlUlschPDUs.nmcsTableTransPrecode>=28 && NrUlUlschPDUs.nmcsTableTransPrecode<=31)&& NrUlUlschPDUs.nTransPrecode == 0)
    % the TBS is assumed to be as determined from the DCI transported in the latest PDCCH for the same transport
    % block using 0<=IMCS<=27 . If there is no PDCCH for the same transport block using 0<=IMCS<=27 , and if
    % the initial PUSCH for the same transport block is transmitted with configured grant,
        % - the TBS shall be determined from configuredGrantConfig for a configured grant Type 1 PUSCH.
        % - the TBS shall be determined from the most recent PDCCH scheduling a configured grant Type 2 PUSCH.
else
%     the TBS is assumed to be as determined from the DCI transported in the latest PDCCH for the same transport
%     block using 0<=IMCS<=28. If there is no PDCCH for the same transport block using 0<=IMCS<=28, and if the
%     initial PUSCH for the same transport block is transmitted with configured grant,
%         - the TBS shall be determined from configuredGrantConfig for a configured grant Type 1 PUSCH.
%         - the TBS shall be determined from the most recent PDCCH scheduling a configured grant Type 2 PUSCH.
    
end