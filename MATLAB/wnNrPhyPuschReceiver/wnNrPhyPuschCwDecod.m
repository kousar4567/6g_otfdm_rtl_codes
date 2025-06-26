    

function [puschRxOut,NrUlUlschPDUs, decoded,cbDeConcatOut] = wnNrPhyPuschCwDecod(NrUlUlschPDUs, ...
                                                              puschDescramblerOut, ...
                                                              dmrsPrPrb, ...
                                                              nPtrsSyms, ...
                                                              nPrbAllocated, ...
                                                              NrPhySimParam, ...
                                                              puschCbgs,...
                                                              dmrsCdmGWithData,...
                                                             dmrsCdmGWithoutData)

   
   global mcsChangeFlag
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Processing for LDPC Base Graph Select
   
     % Calculation of Modulation order and Code Rate for the selected code word 
         mcsCRnti = 0;
    % [NrUlUlschPDUs.modOrder,NrUlUlschPDUs.codingRate,spectralEff,table] = wnNrPhyPuschMCS(NrUlUlschPDUs,mcsCRnti);

       if ((NrUlUlschPDUs.nTBSize <= 292) || ...
               (NrUlUlschPDUs.nTBSize <= 3824 && NrUlUlschPDUs.codingRate <= 0.67) || ...
               (NrUlUlschPDUs.codingRate <= 0.25))
           
           ldpcBaseGraph = 2;
       else
           ldpcBaseGraph = 1;
       end
        if(mcsChangeFlag)
              mcsCRnti = 1;
            [NrUlUlschPDUs.modOrder,NrUlUlschPDUs.codingRate,spectralEff,table] = wnNrPhyPuschMCS(NrUlUlschPDUs,mcsCRnti);

    
       end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    puschRatematchLen=(12*NrUlUlschPDUs.nPrbAllocated-2*NrUlUlschPDUs.nDMRSpSymb)*NrUlUlschPDUs.nNrOfSymbols.*NrUlUlschPDUs.modOrder;
                                                                                         
    clear dmrsPrPrb;
    clear nPtrsSyms;
    clear nPrbAllocated;
    
    
    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                     
    
   clear codeWordData;
   
                                            
                                                                                            
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Processing for Code BLock De-concatenation  
   
   %FIXME : Below Parameters
   CBGTI = 0;
   [cbDeConcatOut, nCodeblks, Zc_min, puschRmlen, eachCblen] = wnNrPhyPuschCbDeconcat(puschDescramblerOut, ...
                                                                                      puschRatematchLen, ...
                                                                                      ldpcBaseGraph, ...
                                                                                      NrUlUlschPDUs, ...
                                                                                      puschCbgs, ...
                                                                                      CBGTI);
%    fprintf('\n------Processing for decoding------\n');
%    fprintf('Rate Matching Len:- %d || Rate Matching length of Each Code Blocks :- %d\n',puschRatematchLen,puschRmlen(1,1));
%    fprintf('Total Code Blocks:- %d\n',nCodeblks);
    clear puschDescramblerOut;
    
    % calculation on LDPC Decoder input and output lengths
    if ldpcBaseGraph == 1
        ldpcDecoderInpLen = 66*Zc_min;
        ldpcDecoderOutLen = 22*Zc_min;
    elseif ldpcBaseGraph == 2
%         if ((data_len_pusch_in + puschCrcLen) > 640)
%             LDPC_Kb = 10;
%         elseif ((data_len_pusch_in + puschCrcLen) > 560)
%             LDPC_Kb = 9;
%         elseif ((data_len_pusch_in + puschCrcLen) > 192)
%             LDPC_Kb = 8;
%         else
%             LDPC_Kb = 6;
%         end
        ldpcDecoderInpLen = 50*Zc_min;
        ldpcDecoderOutLen = 10*Zc_min;
    end  

    filler_bit = -1;
    
    
    % Initial the LLR buffer                                                          
    deRateMatchOut = zeros(ldpcDecoderInpLen, nCodeblks);
    deRateMatchOut((eachCblen + 1) - 2*Zc_min : ldpcDecoderOutLen - 2*Zc_min, :) = filler_bit;
    mainCrcCheckflag = 0;
    persistent llrCount
    if(isempty(llrCount))
          llrCount = zeros(ldpcDecoderInpLen, nCodeblks);
    end
   
       if(NrUlUlschPDUs.nNDI==1)
            
          % For Code Block Group Based transmission    
          [puschCbgs, nOfCbgs] = wnNrPhyPuschCbgTrans(NrUlUlschPDUs.cbgTransmission, ...      % If a UE is configured to receive CBG based transmissions
                                                      NrUlUlschPDUs.maxCBGsPerTB, ...  % Maximum number of CBGs per transport block
                                                      nCodeblks);  
          
          llrCount = zeros(ldpcDecoderInpLen, nCodeblks);
          [puschCbgs,ldpcDecodeOut,deRateMatchOut,nOfCbgs,llrCount,decoded]=wnNrPhyPuschNewTxCbgDecod(NrUlUlschPDUs, ...
                                                                                              cbDeConcatOut, ...
                                                                                              puschRmlen, ...
                                                                                              deRateMatchOut, ...
                                                                                              ldpcBaseGraph, ...
                                                                                              Zc_min, ...
                                                                                              ldpcDecoderInpLen, ...
                                                                                              eachCblen, ...
                                                                                              nCodeblks, ...
                                                                                              puschCbgs, ...
                                                                                              nOfCbgs, ...
                                                                                              llrCount, ...
                                                                                              filler_bit);
             
          for idx = 1:1:nOfCbgs
               reTxCbg_index0(idx) = idx;
    %            DecodedCbg_index0(idx) = idx;
          end
           reTxFlagset = 0;
      
       else    %Retransmission 
            %save information of retransmitted CBG
            reTxFlagset = 1;
           [puschCbgs,ldpcDecodeOut,deRateMatchOut,puschDecodedLlrs, ...
               DecodedCbg_index0,reTxCbg_index0,nOfCbgs,llrCount,decoded] =  wnNrPhyPuschReTxCbgDecod(NrUlUlschPDUs, ...              
                                                                                            puschCbgs, ...
                                                                                            cbDeConcatOut, ...
                                                                                            puschRmlen, ...
                                                                                            deRateMatchOut, ...
                                                                                            ldpcBaseGraph, ...
                                                                                            Zc_min, ...
                                                                                            ldpcDecoderInpLen, ...
                                                                                            ldpcDecoderOutLen, ...
                                                                                            eachCblen, ...
                                                                                            llrCount, ...
                                                                                            filler_bit);
          
       end    %End of if statement :: Initial transmission 
         
     for cbgIdx = 1:1:nOfCbgs 
        for cbInCbgIdx = 1:1:puschCbgs(reTxCbg_index0(cbgIdx)).len     
          ldpcTempDecode_t =  decoded(puschCbgs(cbgIdx).data(cbInCbgIdx), :);
          if (puschCbgs(end).data(end,end)>1)             %(nCodeblks > 1)
            %Polynomial for CRC24B
            CRC24B = [1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1];
            [puschCbOut(puschCbgs(reTxCbg_index0(cbgIdx)).data(cbInCbgIdx), :), cb_remainder] = wnNrPhyCrcRemoval(ldpcTempDecode_t, ...
                                                                                                  CRC24B);
            puschCbgs(reTxCbg_index0(cbgIdx)).cbCrcCheck(cbInCbgIdx) = cb_remainder; 
          else
            puschCbConcatout = ldpcTempDecode_t;
             puschCbOut = ldpcTempDecode_t;
          end       
       end % End of for loop : CB in CBG 
          
       if(sum(puschCbgs(reTxCbg_index0(cbgIdx)).cbCrcCheck)~=0)
           puschCbgs(reTxCbg_index0(cbgIdx)).nACK = 1;    % Need to retransmission 
           mainCrcCheckflag = 1;
       else 
           puschCbgs(reTxCbg_index0(cbgIdx)).nACK = 0;    % Decoded Successfully 
       end             
     end  %End of for loop : CBG Index
     
     
    %% ----------- load Decoded LLRs for CB concatenation  
    if(reTxFlagset ==1)
       for cbgIdx = 1:1:length(DecodedCbg_index0)
           for cbInCbgIdx = 1:1:puschCbgs(DecodedCbg_index0(cbgIdx)).len
              puschCbOut(puschCbgs(DecodedCbg_index0(cbgIdx)).data(1,cbInCbgIdx),:) = puschDecodedLlrs(cbgIdx).cb(:,cbInCbgIdx);
           end
       end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                 
    % This won't run final CRC check if any one of the Code Block CRC fails
    % Processing for Code Block Concatenation
     nCodeblks = puschCbgs(end).data(end,end);
    if(mainCrcCheckflag ==0)
        if (nCodeblks > 1)
            [puschCbConcatout] = wnNrPhyPuschCbDeSeg(puschCbOut, ...
                                                     nCodeblks, ...
                                                     eachCblen);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                 
        % Processing for CRC Removal
    
        % Polynomial for CRC24A
        CRC24A = [1,1,0,0,0,0,1,1,0,0,1,0,0,1,1,0,0,1,1,1,1,1,0,1,1];
        % Polynomial for CRC16
        CRC16 = [1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1];

        % If Transport block size is less than 3824 use CRC16 otherwise CRC24A
        if NrUlUlschPDUs.nTBSize < 3824
            CRC = CRC16;
        else
            CRC = CRC24A;
        end
    
        %Transport Block CRC removal
        [puschRxOut.data, puschRxOut.mainCrcCheck] = wnNrPhyCrcRemoval(puschCbConcatout, CRC);
    
        %All Code Blocks are not decoded    
    else
        puschRxOut.data = 0;
        puschRxOut.mainCrcCheck = 1;        
    end
    
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% If CBG CRC Passes and TB Level CRC failed :- Retransmit all CBG 
    if(mainCrcCheckflag==0&&puschRxOut.mainCrcCheck ==1)
      for cbgIdx = 1:1:length(puschCbgs)
        puschCbgs(cbgIdx).nACK = 1;
      end
%       if(reTxFlagset==1)
%          temp_deRateMatchOut = deRateMatchOut;
%          deRateMatchOut = zeros(ldpcDecoderInpLen, nCodeblks);
%          tempCbIdx = 1;
%          %reTransmitted CBGS
%          for cbgIdx = 1:1:length(reTxCbg_index0)
%             for cbInCbgIdx = 1:1:puschCbgs(reTxCbg_index0(cbgIdx)).len
%                 deRateMatchOut(:,puschCbgs(reTxCbg_index0(cbgIdx)).data(cbInCbgIdx)) = temp_deRateMatchOut(:,tempCbIdx);
%                 tempCbIdx = tempCbIdx+1;
%             end         
%          end
%          %Previous Decoded CBGs
%          for cbgIdx = 1:1:length(DecodedCbg_index0)
%             for cbInCbgIdx = 1:1:puschCbgs(DecodedCbg_index0(cbgIdx)).len
%                 LLRs_name = strcat('puschRxLlrsCw',num2str,'_harq',num2str(NrUlUlschPDUs.nHARQID), ...
%                                    '_CBG',num2str(DecodedCbg_index0(cbgIdx)),'_CBinCBG',num2str(cbInCbgIdx),'.dat');
%                deRateMatchOut(:,puschCbgs(DecodedCbg_index0(cbgIdx)).data(cbInCbgIdx)) = readmatrix(LLRs_name);                   
%             end
%         end
%       end
      
    end
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % collect the deRatematch Out 
     if(reTxFlagset==1)
         temp_deRateMatchOut = deRateMatchOut;
         deRateMatchOut = zeros(ldpcDecoderInpLen, nCodeblks);
         tempCbIdx = 1;
         %reTransmitted CBGS
         for cbgIdx = 1:1:length(reTxCbg_index0)
            for cbInCbgIdx = 1:1:puschCbgs(reTxCbg_index0(cbgIdx)).len
                deRateMatchOut(:,puschCbgs(reTxCbg_index0(cbgIdx)).data(cbInCbgIdx)) = temp_deRateMatchOut(:,tempCbIdx);
                tempCbIdx = tempCbIdx+1;
            end         
         end
         %Previous Decoded CBGs
         for cbgIdx = 1:1:length(DecodedCbg_index0)
            for cbInCbgIdx = 1:1:puschCbgs(DecodedCbg_index0(cbgIdx)).len
                LLRs_name = strcat('puschRxLlrsCw',num2str,'_harq',num2str(NrUlUlschPDUs.nHARQID), ...
                                   '_CBG',num2str(DecodedCbg_index0(cbgIdx)),'_CBinCBG',num2str(cbInCbgIdx),'.dat');
               deRateMatchOut(:,puschCbgs(DecodedCbg_index0(cbgIdx)).data(cbInCbgIdx)) = readmatrix(LLRs_name);                   
            end
        end
      end
    
    % If the main CRC doesn't pass 
    % If CBG based CRC check is enabled then 'puschRxOut.cbgCrc' will give CBG based ACK/NACK
    % If CBG based CRC check is disabled then 'puschRxOut.cbgCrc' will give CB based ACK/NACK
   cbReTxIdx = 1;
   if(NrPhySimParam.EnableHARQ==1)
       NrUlUlschPDUs.cbgTransmitInfo(1,:) = 0;
       if puschRxOut.mainCrcCheck == 1
           
           %if TB Based Transmission Disable
            if(NrUlUlschPDUs.cbgTransmission==0)
                for cbgIdx = 1:1:length(puschCbgs)
                    puschCbgs((cbgIdx)).nACK =1;
                end
            end
%             delete *.dat;
            DecodedCbg_index1 = [];
            reTxCbg_index1 = [];
            index_00  = 1;
            index_01  = 1;
            nOfCbgs = 0;
            for idx = 1:1:length(puschCbgs)
               if(puschCbgs(idx).nACK==1)
                  nOfCbgs = nOfCbgs+1;
                  reTxCbg_index1(index_00) = idx;
                  index_00 = index_00+1;
               elseif(puschCbgs(idx).nACK==0)
                  DecodedCbg_index1(index_01) = idx;
                  index_01 = index_01+1;
               end        
            end
            %Store failed LLRs
            for cbgIdx = 1:1:length(puschCbgs) 
                for cbInCbgIdx = 1:1:puschCbgs((cbgIdx)).len
                     puschLlrs(cbgIdx).cb(:,cbInCbgIdx) = deRateMatchOut(:, puschCbgs((cbgIdx)).data(cbInCbgIdx));   
                      LLRs_name = strcat('puschRxLlrs_harq',num2str(NrUlUlschPDUs.nHARQID), ...
                                           '_CBG',num2str((cbgIdx)),'_CBinCBG',num2str(cbInCbgIdx),'.dat');
                      writematrix(puschLlrs(cbgIdx).cb(:,cbInCbgIdx),LLRs_name);                   
                end
                NrUlUlschPDUs.cbgTransmitInfo(1,(cbgIdx))=  puschCbgs((cbgIdx)).nACK;
            end
            %save Decoded LLRs
            for cbgIdx = 1:1:length(DecodedCbg_index1)
                 for cbInCbgIdx = 1:1:puschCbgs(DecodedCbg_index1(cbgIdx)).len
                         LLRs_name = strcat('puschRxDecodedLlrs_harq',num2str(NrUlUlschPDUs.nHARQID), ...
                                            '_CBG',num2str(DecodedCbg_index1(cbgIdx)),'_CBinCBG',num2str(cbInCbgIdx),'.dat');
                         writematrix(puschCbOut(puschCbgs(DecodedCbg_index1(cbgIdx)).data(1,cbInCbgIdx), :),LLRs_name);
                 end
            end
            
%             if(length(reTxCbg_index0)~=length(reCbg_index))
%                 keyboard
%              for cbgIdx = 1:1:length(reCbg_index)
%                   for cbInCbgIdx = 1:1:puschCbgs(reCbg_index(cbgIdx)).len
%                        puschLlrs(cbgIdx).cb(:,cbInCbgIdx) = deRateMatchOut(:, cbReTxIdx);                           
%                        LLRs_name = strcat('puschRxLlrsCw',num2str,'_harq',num2str(NrUlUlschPDUs.nHARQID), ...
%                                           '_CBG',num2str(reCbg_index(cbgIdx)),'_CBinCBG',num2str(cbInCbgIdx),'.dat');
% %                        LLRs_name1 = strcat('puschRxLlrsCw',num2str,'_harq',num2str(NrUlUlschPDUs.nHARQID),'_reTx',num2str(reTxCount), ...
% %                                             '_CBG',num2str((cbgIdx)),'_CBinCBG',num2str(cbInCbgIdx),'.txt');               
%                        writematrix(puschLlrs(cbgIdx).cb(:,cbInCbgIdx),LLRs_name);  
% %                        writematrix(puschLlrs(cbgIdx).cb(:,cbInCbgIdx),LLRs_name1);  
%                        cbReTxIdx=cbReTxIdx+1;
%                    end                       
%                    NrUlUlschPDUs.cbgTransmitInfo(,reCbg_index(cbgIdx))=  puschCbgs(reCbg_index(cbgIdx)).nACK;
%              end
% %                  cbgReTxIdx=cbgReTxIdx+1;  
%                  for cbgIdx = 1:1:length(DecodedCbg_index0)
%                      for cbInCbgIdx = 1:1:puschCbgs(DecodedCbg_index0(cbgIdx)).len
%                          LLRs_name = strcat('puschRxDecodedLlrsCw',num2str,'_harq',num2str(NrUlUlschPDUs.nHARQID), ...
%                                             '_CBG',num2str(DecodedCbg_index0(cbgIdx)),'_CBinCBG',num2str(cbInCbgIdx),'.dat');
%                          writematrix(puschCbOut(puschCbgs(DecodedCbg_index0(cbgIdx)).data(1,cbInCbgIdx), :),LLRs_name);
%                      end
%                  end
%              
%             else
%                  for cbgIdx = 1:1:length(reCbg_index)
%                     for cbInCbgIdx = 1:1:puschCbgs(reCbg_index(cbgIdx)).len
%                        puschLlrs(cbgIdx).cb(:,cbInCbgIdx) = deRateMatchOut(:, cbReTxIdx);                           
%                        LLRs_name = strcat('puschRxLlrsCw',num2str,'_harq',num2str(NrUlUlschPDUs.nHARQID), ...
%                                           '_CBG',num2str(reCbg_index(cbgIdx)),'_CBinCBG',num2str(cbInCbgIdx),'.dat');
% %                        LLRs_name1 = strcat('puschRxLlrsCw',num2str,'_harq',num2str(NrUlUlschPDUs.nHARQID),'_reTx',num2str(reTxCount), ...
% %                                             '_CBG',num2str((cbgIdx)),'_CBinCBG',num2str(cbInCbgIdx),'.txt');               
%                        writematrix(puschLlrs(cbgIdx).cb(:,cbInCbgIdx),LLRs_name);  
% %                        writematrix(puschLlrs(cbgIdx).cb(:,cbInCbgIdx),LLRs_name1);  
%                        cbReTxIdx=cbReTxIdx+1;
%                     end 
%                      NrUlUlschPDUs.cbgTransmitInfo(,reCbg_index(cbgIdx))=  puschCbgs(reCbg_index(cbgIdx)).nACK;
%                  end
%             end
           
           % If the main CRC passes
       elseif puschRxOut.mainCrcCheck == 0
           for cbgIdx = 1:1:nOfCbgs
               puschRxOut.cbgCrc(cbgIdx) = 0;
           end
           
           % Delete the stored soft values when all the Code block groups are
           % successfully decoded
           delete *.dat;          
       end
       puschRxOut.reTxCBGsInfo = puschCbgs;
   end
%        if puschRxOut.mainCrcCheck == 1
%           keyboard;
%       end

  
 end % End of the function