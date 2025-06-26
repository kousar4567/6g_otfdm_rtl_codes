function   [puschCbgs,ldpcTempDecode_t,deRateMatchOut,puschDecodedLlrs,DecodedCbg_index,reTxCbg_index,nOfCbgs,llrCount,decodedMathworks] =  wnNrPhyPuschReTxCbgDecod(NrUlUlschPDUs, ...
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
                                                                                                                                                    filler_bit)
                                                      
                                                      
                                                      
      global reTxCount                                                
 % LLR load check 
     [puschLlrs,puschDecodedLlrs,DecodedCbg_index,reTxCbg_index,nOfCbgs] = wnNrPhyPuschLLRsload(NrUlUlschPDUs, ...
                                                                                                puschCbgs, ...
                                                                                                ldpcDecoderInpLen, ...
                                                                                                llrCount);                                                     
     if(NrUlUlschPDUs.cbgTransmission==0)
         NrUlUlschPDUs.maxCBGsPerTB = length(puschCbgs);
     end
    
                                                                                            
% puschCbConcatout=0;
cbReTxIdx = 1;
 for cbgIdx = 1:1:nOfCbgs 
     for cbInCbgIdx = 1:1:puschCbgs(reTxCbg_index(cbgIdx)).len           

        %% load the previously stored decoded CBs 
          
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Processing for Bit Deinterleaver   

        [deInterleavedOut] = wnNrPhyPuschDeinterleaver(cbReTxIdx, ...
                                                       NrUlUlschPDUs.modOrder, ...
                                                       cbDeConcatOut, ...
                                                       puschRmlen);                                                                 
% 
%         LLRs_name = strcat('deInterleavedOut','_reTx',num2str(reTxCount),num2str,'_RV',num2str(NrUlUlschPDUs.nRV), ...
%                             '_CBG',num2str(reTxCbg_index(cbgIdx)),'_CBinCBG',num2str(cbInCbgIdx),'.txt');
%         writematrix(deInterleavedOut,LLRs_name);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Processing for Soft Combining or Rate De-matching                                                        

        % De-rate match with combining the LLRs
            
            [reTxedCbgsCbs] = wnNrPhyPuschCbgCbFinder(puschCbgs, ...
                                                      NrUlUlschPDUs.cbgTransmitInfo(1,:), ...
                                                      NrUlUlschPDUs.maxCBGsPerTB);
            nCodeblks = length(reTxedCbgsCbs);
%             [temp1,temp2] = size(cbDeConcatOut);
%             puschRmlen(1,1) = (temp1*temp2)/puschCbgs(end).data(end,end);
            [deRateMatchOut,llrCount] = wnNrPhyPuschSoftCombiner(puschLlrs((cbgIdx)).cb(:,cbInCbgIdx), ...   %previous Stored LLRs
                                                                 deRateMatchOut, ...
                                                                 deInterleavedOut, ...
                                                                 NrUlUlschPDUs, ...
                                                                 ldpcBaseGraph, ...
                                                                 puschRmlen(cbReTxIdx), ...
                                                                 ldpcDecoderInpLen, ...
                                                                 ldpcDecoderOutLen, ...
                                                                 nCodeblks, ...
                                                                 Zc_min, ...
                                                                 cbReTxIdx, ...
                                                                 eachCblen, ...
                                                                 filler_bit, ...
                                                                 llrCount, ...
                                                                 puschCbgs(reTxCbg_index(cbgIdx)).data(cbInCbgIdx), ...
                                                                 NrUlUlschPDUs.nRV);         
                                                
        clear deInterleavedOut;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                 
        % Processing for LDPC Decoding

        if ldpcBaseGraph == 1
            ldpcDecoderOutLen = ldpcDecoderInpLen/3;
            ldpcCodeRate = 1/3;
        elseif ldpcBaseGraph == 2
            ldpcDecoderOutLen = ldpcDecoderInpLen/5;
            ldpcCodeRate = 1/5;
        end
  % maximum Decoder Iterations
        maxitrs = 32;

%             M = 2;
%             N = 4;
%             MAXPOS = 31/16;
%               tempDecoderInp = deRateMatchOut(:,cbReTxIdx);
%             
%             tempDecoderInp((eachCblen + 1) - 2*Zc_min : ldpcDecoderOutLen - 2*Zc_min, 1) = 0;
%             
%             tempDecoderInp(:, 1) = tempDecoderInp(:, 1) ./ max(abs(tempDecoderInp(:, 1)));
%             
%             tempDecoderInp((eachCblen + 1) - 2*Zc_min : ldpcDecoderOutLen - 2*Zc_min, 1) = MAXPOS;%(L_max_int-1);% Initalize the filler bits with some high values
% 
%              tempDecoderInp(:, 1) = round((tempDecoderInp(:, 1) * 2^N));
%             
%             deInterleavedOuttemp(:, 1) = [zeros(2*Zc_min,1);  tempDecoderInp(:, 1)];
% 
%         % First go to LDPC Mex directory                                                              
%             cd 'Decoder'        
% 
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                 
%         % Processing for 2nd CRC removal and CRC check for each Code Block
% 
%             % First go to LDPC Mex directory                                                              
% 
%             % Compile the code
% %              mex COPTIMFLAGS="-O3 -DNDEBUG" mex_decoder.c -I. -L. encoder.c decoder.c setup.c utility.c
%             deInterleavedOuttemp(:, 1) = deInterleavedOuttemp(:, 1)+0;
%             % mex_decoder(bg_no msg_len rate SNRdB is_layered maxitrs NBlocks Lmax bw_L offset LLrs)
% %             ldpcTempDecodeTemp(1,:) = mex_decoder(puschLdpcBaseGraph,eachCblen,Rate,0,0,maxitrs,1,L_max_real,bw_L,offset,(deInterleavedOuttemp(:, 1)).'); 
%                ldpcTempDecodeTemp(1,:) = wnXilnixLDPCDec(ldpcBaseGraph, eachCblen, maxitrs, (deInterleavedOuttemp(:, 1)));
%             % Come Back from that directory
%             cd '../'; 
% 
%             % Collect the decoder output
%             ldpcTempDecode_t(puschCbgs(cbgIdx).data(cbInCbgIdx), :) = double(ldpcTempDecodeTemp(1,1:eachCblen));
            ldpcTempDecode_t = [];
%         % maximum Decoder Iterations
%         maxItrs = 32;
%         L_max_real = 3; %12; %3
%         bw_L = 7; %12; %7
%         L_max_int = 2^(bw_L-1);
%         offset = 1; %2
% 
%         tempDecoderInp = deRateMatchOut(:,cbReTxIdx);
%         
%         tempDecoderInp((eachCblen + 1) - 2*Zc_min : ldpcDecoderOutLen - 2*Zc_min, 1) = 0;
% 
%         tempDecoderInp(find(tempDecoderInp(:, 1)>L_max_real), 1) = L_max_real;
%         tempDecoderInp(find(tempDecoderInp(:, 1)<-L_max_real), 1) = -L_max_real;
%         tempDecoderInp(:, 1) = (L_max_int-1)*(tempDecoderInp(:, 1)./L_max_real);
%         deInterleavedOuttemp(:, 1) = [zeros(2*Zc_min,1);  tempDecoderInp(:, 1)];
% 
%         % First go to LDPC Mex directory                                                              
% %         cd 'wnNrPhypuschReceiver/wnNrPhyLdpcMexDecoderC';          
%         cd 'wnNrPhypuschReceiver/wnNrPhyLdpcMexDecoderC'
%         % Compile the code
% %         mex COPTIMFLAGS="-O3 -DNDEBUG" mex_decoder.c -I. -L. encoder.c decoder.c setup.c utility.c
%         ldpcTempDecode(1,:)  = mex_decoder(ldpcBaseGraph, ldpcDecoderOutLen, ldpcCodeRate, 0, 0, maxItrs, 1, L_max_real, bw_L, offset, (deInterleavedOuttemp(:, 1).')); 
% %         void ldpc_comm_link(              int bg_no,    int msg_len,       double rate,   double SNRdB,   int maxitrs,int Nblocks,double L_max_real,int bw_L,int offset,int is_layered,int *L0,int *dec_cword);
%         
%         % Come Back from that directory
%         cd '../../'; 
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                 
%         % Processing for 2nd CRC removal and CRC check for each Code Block
% 
%         ldpcTempDecode_t(puschCbgs(cbgIdx).data(cbInCbgIdx), :) = double(ldpcTempDecode(1,1:eachCblen));
        cbReTxIdx = cbReTxIdx+1;
     end   % End of for loop : CB in CBG 
 end  %End of for loop : CBG Index
 deRateMatchOutMathworksLdpc = deRateMatchOut;
        deRateMatchOutMathworksLdpc((eachCblen + 1) - 2*Zc_min : ldpcDecoderOutLen - 2*Zc_min,:) = Inf;
         % LDPC decoding: set to early terminate, within max iterations
        obj.MaximumLDPCIterationCount = 32;
        obj.LDPCDecodingAlgorithm = 'Normalized min-sum';
        obj.ScalingFactor = 0.75;
        obj.Offset = 0.5;
        decodedMathworks = nrLDPCDecode(deRateMatchOutMathworksLdpc,ldpcBaseGraph, ...
                           obj.MaximumLDPCIterationCount,'Algorithm',obj.LDPCDecodingAlgorithm, ...
                           'ScalingFactor',obj.ScalingFactor,'Offset',obj.Offset);
       decodedMathworks= double(decodedMathworks(1:eachCblen,:))';      
                                                      
   clear deInterleavedOuttemp;
   clear ldpcTempDecode;
   clear ldpcDecoderOutLen;
   clear ldpcDecoderInpLen;
   clear ldpcBaseGraph;
                                                    
end