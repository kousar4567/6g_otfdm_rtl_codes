
function [ModOrder,Rate,spectralEff,table] = wnNrPhyPuschMCS(NrUlUlschPDUs,mcsCRnti,tempMCS)
global mcsChangeFlag
if mcsChangeFlag
    NrUlUlschPDUs.nMCS = tempMCS;
end

% calculation of Modulation order and Coding rate

q = [];

switch NrUlUlschPDUs.nTransPrecode
    case 1
        % Transform precoding is disabled
        if NrUlUlschPDUs.nMcsTable == 1 
            % use table 5.1.3.1-2 from 38.214
            table = 51312;
        elseif NrUlUlschPDUs.nMcsTable == 0
            % use table 5.1.3.1-3
            table = 51313;
        elseif mcsCRnti == 1 % pusch scheduled by PDCCH and CRC is scrambled with mcs-c-rnti
            % use table 5.1.3.1-3
            table = 51313;
        else
            % use table 5.1.3.1-1
            table = 51311;
        end
        [mcsrow] = wnNrPhyPuschMcsTables(table,NrUlUlschPDUs.nMCS,q);
        
    case 0
    % Transform precoding is enabled
        if NrUlUlschPDUs.tppi2BPSK == 1
            q = 1;
        else
            q = 2;
        end
        if NrUlUlschPDUs.nmcsTableTransPrecode == 1
            % use table 5.1.3.1-2
            table = 51312;
        elseif NrUlUlschPDUs.nmcsTableTransPrecode == 0
            % use table 6.1.4.1-2
            table = 61312;
        elseif mcsCRnti == 1 % pusch scheduled by PDCCH and CRC is scrambled with mcs-c-rnti
            % use table 6.1.4.1-2
            table = 61312;
        else
            % use table 6.4.1.1-1
            table = 61311;
        end
        
        [mcsrow]    = wnNrPhyPuschMcsTables(table,NrUlUlschPDUs.nMCS,q);
        
end

ModOrder    = mcsrow(1);
Rate        = mcsrow(2)/1024;
spectralEff = mcsrow(3);
