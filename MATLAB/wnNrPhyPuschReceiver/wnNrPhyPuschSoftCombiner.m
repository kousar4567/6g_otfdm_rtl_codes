


function [deRateMatchOut,llrCount] = wnNrPhyPuschSoftCombiner(llrStoredData, ...
                                                     deRateMatchOut, ...
                                                     deintrlvedOut, ...
                                                     NrUlUlschPDUs, ...
                                                     ldpcBaseGraph, ...
                                                     pdschRmLen, ....
                                                     ldpcDecoderInpLen, ...
                                                     ldpcDecoderOutLen, ...
                                                     nCodeBlks, ...
                                                     Zc_min, ...
                                                     cbIdx, ...
                                                     eachCblen, ...
                                                     filler_bit, ...
                                                     llrCount, ...
                                                     trueCBidx, ...
                                                     Rv)


   
    % I_LBRM is fixed in NR PDSCH Rate matching specifications
    I_LBRM = 1;

    % R_LBRM is fixed in NR PDSCH Rate matching specifications
    R_LBRM = 2/3;

    %Check RV Index 
    switch Rv
        case 0
            rvIdx = 1;
        case 1
            rvIdx = 4;
        case 2
            rvIdx = 2;
        case 3
            rvIdx = 3;
    end
    
    %----calculating size of the block------%

    % TBS_LBRM calculation
    [TBS_LBRM] = wnNrPhyPuschTbsLbrm(NrUlUlschPDUs);

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
     deRateMatchOut(:,cbIdx) = llrStoredData;
     deRateMatchOut((eachCblen + 1) - 2*Zc_min : ldpcDecoderOutLen - 2*Zc_min, :) = filler_bit;
    
    %Count the  
     
    %llrCount
    tempLlrCount = zeros(pdschRmLen,1);
    index02 = 1;
   
    fillerBitCount = length(find(deRateMatchOut(:,cbIdx)==filler_bit));
    for index01 = 0:1:pdschRmLen-1+2*fillerBitCount
        if (deRateMatchOut(mod((startPos + index01),N_cb)+1, cbIdx) == filler_bit)
            index01 = index01 + 1;
        else
            % When the rate match output is lower than rate match input
            % Zero padding is done in this situation
            if (index02 <= pdschRmLen)
                llrCount(mod((startPos + index01),N_cb)+1,trueCBidx) = llrCount(mod((startPos + index01),N_cb)+1,trueCBidx)+1;
%                 tempLlrCount(mod((startPos + index01),N_cb)+1,1) =  tempLlrCount(mod((startPos + index01),N_cb)+1,1)+1;
                
            end
            index02 = index02 + 1;
        end
    end
   
    
      %add repeat LLRs
      if(N_cb<pdschRmLen)
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
      
     
    % Combine the LLRs with previously stored LLRs
%     index02 = 1;
%     for index01 = 0:1:N_cb
%         if (deRateMatchOut(mod((startPos + index01),N_cb)+1, cbIdx) == filler_bit)
%             index01 = index01 + 1;
%         else
%             % When the rate match output is lower than rate match input
%             % Zero padding is done in this situation
%             if (index02 <= pdschRmLen)
%                 deRateMatchOut(mod((startPos + index01),N_cb)+1, cbIdx) = ...
%                       (1/llrCount(mod((startPos + index01),N_cb)+1, trueCBidx))*(llrStoredData(mod((startPos + index01),N_cb)+1, 1) + deintrlvedOut(index02));
%             end
%             index02 = index02 + 1;
%         end
%     end
    
     index02 = 1;
    for index01 = 0:1:N_cb-1
        if (deRateMatchOut(mod((startPos + index01),N_cb)+1, cbIdx) == filler_bit)
            index01 = index01 + 1;
        else
            % When the rate match output is lower than rate match input
            % Zero padding is done in this situation
            if (index02 <= pdschRmLen)
                deRateMatchOut(mod((startPos + index01),N_cb)+1, cbIdx) = (llrStoredData(mod((startPos + index01),N_cb)+1, 1) + deintrlvedOut(index02));
            end
            index02 = index02 + 1;
        end
    end
    
    %Averaging
    for index01 = 0:1:N_cb-1
        if ((deRateMatchOut( index01+1, cbIdx) == filler_bit)||llrCount( index01+1, trueCBidx)==0)
            index01 = index01 + 1;
        else
            % When the rate match output is lower than rate match input
            % Zero padding is done in this situation
            deRateMatchOut(index01+1, cbIdx)=  (1/llrCount( index01+1, trueCBidx))*deRateMatchOut(index01+1, cbIdx);
        end
    end
                 
end % End of the function

