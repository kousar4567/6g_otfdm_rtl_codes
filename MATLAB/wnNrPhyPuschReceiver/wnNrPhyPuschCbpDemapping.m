% Mapping from Virtual to Physical resource blocks
% Reference 38.211 - f10 release 15 section 7.3.1.6

function [pusch_cbp_demap,SRbg,toneindx1,dataStartIdx] = wnNrPhyPuschCbpDemapping(pusch_demapper_in, ...    % Output after virtual resource block mapping
                                                      NrUlUlschPDUs,fftSize,Exs)      
                                            
rePrPrb = 12;

%% PUSCH Virtual Resource Blocks (VRB) Index Calculation

% PRB index in allocated BWP
[prbFinalIdx,SRbg,toneindx1,dataStartIdx] = wnNrPhyPuschVrbMapping (NrUlUlschPDUs, ...          % Structure for the configuration parameters
                                             NrUlUlschPDUs.nPrbAllocated,fftSize);

% Final PRB index with respect to reference point A
prbFinalIdx = prbFinalIdx + NrUlUlschPDUs.nBWPStart;
                                    
% Now De-mapping the PUSCH data
srartSym = NrUlUlschPDUs.nStartSymbolIndex+1;
endSym = NrUlUlschPDUs.nStartSymbolIndex+NrUlUlschPDUs.nNrOfSymbols;

pusch_cbp_demap = pusch_demapper_in(1:12*NrUlUlschPDUs.nPrbAllocated+Exs*2, srartSym : endSym);


% for prb_index = 1:1:NrUlUlschPDUs.nPrbAllocated
%        for re = 1:1:rePrPrb
%            pusch_cbp_demap((prb_index-1)*rePrPrb + re,:) = pusch_demapper_in((prbFinalIdx(prb_index)-1)*rePrPrb + re, srartSym : endSym);
%        end
% end
  
   
end % End of the function
    
    
