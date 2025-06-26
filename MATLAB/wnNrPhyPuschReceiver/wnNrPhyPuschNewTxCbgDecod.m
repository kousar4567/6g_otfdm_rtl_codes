function [puschCbgs,ldpcTempDecode_t,deRateMatchOut,nOfCbgs,llrCount,decodedMathworks] = wnNrPhyPuschNewTxCbgDecod(NrDlDlschPDUs, ...
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
                                                                                                          filler_bit)
 
       global reTxCount                                                                                                      
 %% ----- Initial Transmission ---- 
       %delete *.dat;
       %cd 'wnNrPhyPuschReceiver/'
%         delete *.dat;
       % cd '../';
       for cbgIdx = 1:1:nOfCbgs 
             for cbInCbgIdx = 1:1:puschCbgs(cbgIdx).len      
%                   puschCbgs(cbgIdx).data(cbInCbgIdx)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Processing for Bit Deinterleaver   

        [deInterleavedOut] = wnNrPhyPuschDeinterleaver(puschCbgs(cbgIdx).data(cbInCbgIdx), ...
                                                       NrDlDlschPDUs.modOrder, ...
                                                       cbDeConcatOut, ...
                                                       puschRmlen);                                                                 
%         LLRs_name = strcat('deInterleavedOut','_reTx',num2str(reTxCount(cwIdx)),num2str(cwIdx),'_RV',num2str(NrDlDlschPDUs.nRV(cwIdx)), ...
%                             '_CBG',num2str((cbgIdx)),'_CBinCBG',num2str(cbInCbgIdx),'.txt');
%         writematrix(deInterleavedOut,LLRs_name);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Processing for Soft Combining or Rate De-matching                                                         
            [deRateMatchOut,llrCount] = wnNrPhyPuschDeRateMatch(deInterleavedOut, ...
                                                       deRateMatchOut, ...
                                                       NrDlDlschPDUs, ...
                                                       ldpcBaseGraph, ...
                                                       puschRmlen(puschCbgs(cbgIdx).data(cbInCbgIdx)), ...
                                                       ldpcDecoderInpLen, ...
                                                       nCodeblks, ...
                                                       Zc_min, ...
                                                       puschCbgs(cbgIdx).data(cbInCbgIdx), ...
                                                       filler_bit, ...
                                                       llrCount, ...
                                                       NrDlDlschPDUs.nRV); 
                                                
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
%               tempDecoderInp = deRateMatchOut(:,puschCbgs(cbgIdx).data(cbInCbgIdx));
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
                
             end % End of for loop : CB in CBG 
             
       end %End of for loop : CBG Index
        deRateMatchOutMathworksLdpc = deRateMatchOut;
        deRateMatchOutMathworksLdpc((eachCblen + 1) - 2*Zc_min : ldpcDecoderOutLen - 2*Zc_min,:) = -1;
         % LDPC decoding: set to early terminate, within max iterations
        obj.MaximumLDPCIterationCount = 500;
        obj.LDPCDecodingAlgorithm = 'Normalized min-sum';
        obj.ScalingFactor = 1;
        decodedMathworks = nrLDPCDecode(deRateMatchOutMathworksLdpc,ldpcBaseGraph, ...
                           obj.MaximumLDPCIterationCount,'Algorithm',obj.LDPCDecodingAlgorithm, ...
                           'ScalingFactor',obj.ScalingFactor);
       decodedMathworks= double(decodedMathworks(1:eachCblen,:))';        
       
   clear deInterleavedOuttemp;
   clear ldpcTempDecode;
%    clear ldpcTempDecode_t;
   clear ldpcDecoderOutLen;
   clear ldpcDecoderInpLen;
   clear ldpcBaseGraph;
        
   
end       