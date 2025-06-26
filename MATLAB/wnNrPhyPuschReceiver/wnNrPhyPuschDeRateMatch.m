


function [deRateMatchOut,llrCount] = wnNrPhyPuschDeRateMatch(deintrlvedOut, ...
                                                    deRateMatchOut, ...
                                                    NrUlUlschPDUs, ...
                                                    ldpcBaseGraph, ...
                                                    pdschRmLen, ....
                                                    ldpcDecoderInpLen, ...
                                                    nCodeBlks, ...
                                                    Zc_min, ...
                                                    cbIdx, ...
                                                    filler_bit, ...
                                                    llrCount, ...
                                                    Rv)



                                                
    % I_LBRM is fixed in NR PDSCH Rate matching specifications
    I_LBRM = 1;

    % R_LBRM is fixed in NR PDSCH Rate matching specifications
    R_LBRM = 2/3;

    %----calculating size of the block------%

    % TBS_LBRM calculation
     [TBS_LBRM] = wnNrPhyPuschTbsLbrm_rx(NrUlUlschPDUs);
%     TBS_LBRM = NrDlDlschPDUs.nTBSize;
    deintrlvedOut = reshape(deintrlvedOut,1,[]);

    if I_LBRM == 0
        N_cb = ldpcDecoderInpLen;
    else
        N_ref = floor(TBS_LBRM/(nCodeBlks*R_LBRM));
        N_cb = min(ldpcDecoderInpLen, N_ref);
    end
     
    
    % if redundancy version is 0
    if (Rv == 0)
        startPos = 0;

    % if redundancy version is 1
    elseif (Rv == 1)
        if (ldpcBaseGraph == 1)
            startPos = Zc_min * floor((17*N_cb)/(66*Zc_min));
        elseif (ldpcBaseGraph == 2)
            startPos = Zc_min * floor((13*N_cb)/(50*Zc_min));
        end

    % if redundancy version is 2
    elseif (Rv == 2)
        if (ldpcBaseGraph == 1)
            startPos = Zc_min * floor((33*N_cb)/(66*Zc_min));
        elseif (ldpcBaseGraph == 2)
            startPos = Zc_min * floor((25*N_cb)/(50*Zc_min));
        end


    % if redundancy version is 3
    elseif (Rv == 3)
        if (ldpcBaseGraph == 1)
            startPos = Zc_min * floor((56*N_cb)/(66*Zc_min));
        elseif (ldpcBaseGraph == 2)
            startPos = Zc_min * floor((43*N_cb)/(50*Zc_min));
        end

    end

    % Then put the data symbols according to the RVs excluding filler bits
    index02 = 1; 
    index03 = 1;
    fillerBitCount = length(find(deRateMatchOut(:,cbIdx)==filler_bit));
    fillerBitLocation = (find(deRateMatchOut(:,cbIdx)==filler_bit));
%     for index01 = 0:1: pdschRmLen-1+fillerBitCount*floor(pdschRmLen/(ldpcDecoderInpLen-fillerBitCount))  
%         if (deRateMatchOut(mod((startPos + index01),N_cb)+1, cbIdx) == filler_bit)
%             index01 = index01 + 1;
%         else
%             % When the rate match output is lower than rate match input
%             % Zero padding is done in this situation
% %             if (index02 <= pdschRmLen)
%                llrCount(mod((startPos + index01),N_cb)+1, cbIdx) =llrCount(mod((startPos + index01),N_cb)+1, cbIdx)+ 1;
% %             end
%             index02 = index02 + 1;
%         end
% %         if index01 == N_cb*index03
% %             keyboard;
% %             index03=index03+1;
% %         end
%     end
    
    templlrCount = zeros(N_cb-fillerBitCount,1);
    for index01 = 0:1: pdschRmLen-1
       
      templlrCount(mod((startPos + index01),N_cb-fillerBitCount)+1, 1) =templlrCount(mod((startPos + index01),N_cb-fillerBitCount)+1, 1)+ 1;

    end
    index02 = 1;
    idxfiller = 1;
    for index01 = 1:1:N_cb
        if (sum(index01==fillerBitLocation(:))==1)
            index01 = index01 +1;
        else
             llrCount(index01, cbIdx) =templlrCount(index02,1);
             index02 = index02 + 1;
        end

    end
    
      %add repeat LLRs
      if(N_cb-fillerBitCount<pdschRmLen)
     for idx_01=1:1:(N_cb-fillerBitCount)
          repeatSum = 0;
          idx_02 = idx_01;
          while(idx_02<=pdschRmLen)
              repeatSum = repeatSum+deintrlvedOut(idx_02);
              deintrlvedOut(idx_02) = 0;
              idx_02 = idx_02+(N_cb-fillerBitCount);
          end
          deintrlvedOut(idx_01) = repeatSum;     
     end
      end
    % Then put the data symbols according to the RVs excluding filler bits
    index02 = 1; 
    for index01 = 0:1: pdschRmLen-1+fillerBitCount 
        if (deRateMatchOut(mod((startPos + index01),N_cb)+1, cbIdx) == filler_bit)
            index01 = index01 + 1;
        else
            % When the rate match output is lower than rate match input
            % Zero padding is done in this situation
            if (index02 <= (N_cb-fillerBitCount))
                deRateMatchOut(mod((startPos + index01),N_cb)+1, cbIdx) = deintrlvedOut(index02);
            end
            index02 = index02 + 1;
        end
    end
    
     %Averaging
    for index01 = 0:1:N_cb-1
        if ((deRateMatchOut( index01+1, cbIdx) == filler_bit)||llrCount( index01+1, cbIdx)==0)
            index01 = index01 + 1;
        else
            % When the rate match output is lower than rate match input
            % Zero padding is done in this situation
            deRateMatchOut(index01+1, cbIdx)=  deRateMatchOut(index01+1, cbIdx);%(1/llrCount( index01+1, cbIdx))*
        end
    end
               
end % End of the function

