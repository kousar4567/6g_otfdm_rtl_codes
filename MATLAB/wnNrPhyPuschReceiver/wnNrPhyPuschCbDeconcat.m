
% Function for Code Block De-concatenation for NR LDPC

function [cbdeconcatOut, nCodeblks, Zc_min, puschRmlen, eachCblen] = wnNrPhyPuschCbDeconcat(cbDeconcatinp, ...
                                                                                            ratematchLen, ...
                                                                                            baseGraph, ...
                                                                                            NrUlUlschPDUs, ...
                                                                                            pdschCbgs, ...
                                                                                            CBGTI)

global reTxCount                                                                                        
% If Transport block size is less than 3824 use CRC16 otherwise CRC24A
if NrUlUlschPDUs.nTBSize < 3824
    pdschCrcLen = 16;
else
    pdschCrcLen = 24;
end
    
    
[nCodeblks, Zc_min, eachCblen] = wnNrPhyPuschCbSeg(baseGraph, ...
                                                   NrUlUlschPDUs.nTBSize+pdschCrcLen);


% When there is one codeword
pdschTxLayer(1) = NrUlUlschPDUs.nNrOfLayers;

% When there are two codewords    
                                               
%%%%%%%% Rate match output length calculations %%%%%%%%
%% re-Calculate No. of codeblocks for retransmission 
if(reTxCount>1)
   nCodeblks = 0;
   CBGTI = 1;
   for cbgIdx = 1:1:length(pdschCbgs)
       nCodeblks =nCodeblks+ NrUlUlschPDUs.cbgTransmitInfo(1,cbgIdx)*pdschCbgs(cbgIdx).len;
   end
end
puschRmlen = zeros(nCodeblks,1);

% C_prime = pdsch_total_code_blocks if CBGTI is not present in 
% the DCI scheduling the transport block and C_prime is the number
% of scheduled code blocks of the transport block 
% if CBGTI is present in the DCI scheduling the transport block
C_prime = nCodeblks;
j = 0;
for cbIdx = 1:1:nCodeblks
        % if the r -th coded block is not for transmission as 
        % indicated by CBGTI according to Subclause X.X in [6, TS38.214]
        if (0)
            puschRmlen(cbIdx) = 0;
        else
            if (j <= C_prime - mod(ratematchLen/(pdschTxLayer*NrUlUlschPDUs.modOrder), C_prime) - 1)
                puschRmlen(cbIdx,1) = (pdschTxLayer*NrUlUlschPDUs.modOrder) ...
                                                  *floor(ratematchLen/(pdschTxLayer*NrUlUlschPDUs.modOrder*C_prime));
            else
                puschRmlen(cbIdx,1) = (pdschTxLayer*NrUlUlschPDUs.modOrder) ...
                                                  *ceil(ratematchLen/(pdschTxLayer*NrUlUlschPDUs.modOrder*C_prime));
            end
            j = j + 1;
        end
end                                   
                                                                                              
%% All the code blocks are de-concatenated in the following loop

cbdeconcatOut = zeros(puschRmlen(1), nCodeblks);

index01 = 1;
index03 = 1;
while index01 <= nCodeblks
    index02 = 1;
    while index02 <= puschRmlen(index01)
        cbdeconcatOut(index02, index01) = cbDeconcatinp(1,index03);
        index03 = index03 + 1;
        index02 = index02 + 1;
    end
    index01 = index01 + 1;
end
                                                   
end % End of the function   
