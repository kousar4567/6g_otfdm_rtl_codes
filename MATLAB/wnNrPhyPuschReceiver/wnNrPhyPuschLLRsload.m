function [puschLlrs,puschDecodedLlrs,DecodedCbg_index,reCbg_index,nOfCbgs] = wnNrPhyPuschLLRsload(NrUlUlschPDUs, ...
                                                                                                  puschCbgs, ...
                                                                                                  ldpcDecoderOutLen, ...
                                                                                                  llrCount)       
    
    rvSequence = [0 2 3 1];
    global reTxCount
    global maxReTx
    %Check RV Index 
    switch NrUlUlschPDUs.nRV
        case 0
            rvIdx = 1;
        case 1
            rvIdx = 4;
        case 2
            rvIdx = 2;
        case 3
            rvIdx = 3;
    end
    
    puschLlrs = [];
    puschDecodedLlrs = [];
    DecodedCbg_index = [];
    reCbg_index = [];
    index_00  = 1;
    index_01  = 1;
    nOfCbgs = 0;
    for idx = 1:1:length(puschCbgs)
        if(puschCbgs(idx).nACK==1)
          nOfCbgs = nOfCbgs+1;
          reCbg_index(index_00) = idx;
          index_00 = index_00+1;
        elseif(puschCbgs(idx).nACK==0)
            DecodedCbg_index(index_01) = idx;
            index_01 = index_01+1;
        end        
    end
    
    
    % If New data arrives with same HARQ ID or Flush Indicator is set
    % Delete the previous saved LLRs
    if (NrUlUlschPDUs.nNDI == 1 || NrUlUlschPDUs.cbgFlushIndicator == 0||reTxCount>maxReTx)
        delete *.dat;
        llrCombine = 0;
        for cbgIdx = 1:1:nOfCbgs
                for cbInCbgIdx = 1:1:puschCbgs(cbgIdx).len
                    puschLlrs(cbgIdx).cb(1:ldpcDecoderOutLen,cbInCbgIdx) = 0;
                end
        end
        
    % If Phy received CBG data for combining and Flush indicator is not set
    else
             %failed CBGs
            for cbgIdx = 1:1:nOfCbgs          
               for cbInCbgIdx = 1:1:puschCbgs(reCbg_index(cbgIdx)).len
                    LLRs_name = strcat('puschRxLlrs_harq',num2str(NrUlUlschPDUs.nHARQID), ... 
                                       '_CBG',num2str(reCbg_index(cbgIdx)),'_CBinCBG',num2str(cbInCbgIdx),'.dat');
                    puschLlrs(cbgIdx).cb(:,cbInCbgIdx) = llrCount(:,puschCbgs(reCbg_index(cbgIdx)).data(cbInCbgIdx)).*readmatrix(LLRs_name);
               end
            end 
            %Successfully Decoded CBGs
            for cbgIdx = 1:1:length(DecodedCbg_index)
                for cbInCbgIdx = 1:1:puschCbgs(DecodedCbg_index(cbgIdx)).len
                     LLRs_name = strcat('puschRxDecodedLlrs_harq',num2str(NrUlUlschPDUs.nHARQID), ...
                                        '_CBG',num2str(DecodedCbg_index(cbgIdx)),'_CBinCBG',num2str(cbInCbgIdx),'.dat');
                     puschDecodedLlrs(cbgIdx).cb(:,cbInCbgIdx) = readmatrix(LLRs_name);
                end
            end %cbgIdx       
    end

end