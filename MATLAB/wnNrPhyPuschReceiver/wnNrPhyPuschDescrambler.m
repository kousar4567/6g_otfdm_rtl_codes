
% Descrambling the received sequence from LLR module
% Inputs:1.LLR_output - output of the LLR Module which preceding DeScrambler
%        2.     nRNTI - Radio Network Temporary Identifier
%        3.      n_ID - {0-1023} or cellid
%        4.  tot_bits - length of the LLR module output

% output: De-Scrambled LLR values

function [puschDescramblerOut] = wnNrPhyPuschDescrambler (descramblerInp, ...
                                                          NrUlUlschPDUs, ...
                                                          inplength)

    % Calculate the initial seed for PN Sequence generation
    Cinit = NrUlUlschPDUs.nRNTI*2^15 + NrUlUlschPDUs.nNid;

    % Call the PN Sequence generation function
    pnSeq = wnNrPhyPnSeq(Cinit, inplength);

    % Descrambling for bipolar
    puschDescramblerOut = (1-2*pnSeq).*descramblerInp;

end
