

function [pdsch_scrambler_out,pdsch_pn_seq,Cinit,pn_seq_len] = wnNrPhyPuschScrambler(puschlIn, nRNTI, n_ID)


Cinit = nRNTI*2^15 +n_ID;

pn_seq_len = length(puschlIn);

% NR PN Sequence Generation function
[pdsch_pn_seq] = wnNrPhyPnSeq (Cinit, pn_seq_len);                                       
    
pdsch_scrambler_out = mod(puschlIn + pdsch_pn_seq, 2);

end 
