function [pusch_ptrs] = wnNrPhyPuschPtrs(NrUlUlschPDUs,...
                                         dmrsSymIndex, ...
                                         dmrsAssAntPort) 


%% Sub_carrier indices of PTRS
pusch_ptrs.loc.freq.data = wnNrPhyPuschPtrsScIndxs(NrUlUlschPDUs, ...
                                                   dmrsAssAntPort);
    
% Number of subcarriers for PTRS mapping
pusch_ptrs.loc.freq.len = length(pusch_ptrs.loc.freq.data);

%% Symbol indices of PTRS
pusch_ptrs.loc.time.data = wnNrPhyPuschPtrsSymPos(NrUlUlschPDUs, dmrsSymIndex);

% Number of symbols used for PTRS mapping
pusch_ptrs.loc.time.len = length(pusch_ptrs.loc.time.data);

% Scaling Factor for PTRS
pusch_ptrs.scalingFac = wnNrPhyPuschPtrsSFac(NrUlUlschPDUs.nTransPrecode,NrUlUlschPDUs.modOrder);

end