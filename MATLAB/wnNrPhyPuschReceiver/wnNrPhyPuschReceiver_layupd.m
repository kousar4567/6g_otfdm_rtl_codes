
% PUSCH Complete receiver function

function [puschRxOut,NrUlUlschPDUs,MSE_out,ser,ber,FinalEquadata,puschCbpDemap,puschDemodOut_true,puschDescramblerOut,cbDeConcatOut,rx_TimeDomain_mod,rx_TimeDomain_dmrs,puschChEstimatedata,equalizedData,pusch_demap,tempchan_test,est_data_verify,M_point_estimation_out,interpolation_data,spectrum_shaping,CRC,weigth] = wnNrPhyPuschReceiver_layupd(NrUlUlschPDUs, ...
    nRxAntPorts, ...
    antGrpFactor, ...
    rxWaveform,...
    NrPhySimParam,...
    bwFftCp,...
    freqchan,...
    puschScramblerOut,...
    snr,...
    LLR,...
    puschCbgs,...
    rxGrid,inditer,...
    puschLayerMappedOut,...
    Mapdata,puschTrsfmPrcdOut,Exs,...
    Txshaping,...
    Rxshaping,...
    indExtfac,...
    beta,...
    Filt,...
    os,...
    B,...
    L,n0)


dmrsPrPrb = 0;
dmrsCdmGWithData = 0;
dmrsCdmGWithoutData = 0;

ntonesScheduled = 12*NrUlUlschPDUs.nPrbAllocated;
dftsize = ntonesScheduled;

%% Rx filter generation
shape=transpose(square_root_raised_cosine_window(dftsize,indExtfac));

%% Processing for reference DMRS Generation

for l = 0: (NrUlUlschPDUs.nNrOfSymbols-1)
    [Gen_TimeDomain_dmrs(:,(l+1))] = wnNrPhyPuschDmrsSeqGen( NrUlUlschPDUs.nDMRSpSymb ,NrUlUlschPDUs.nSCID,NrUlUlschPDUs.nNIDnSCID0,NrUlUlschPDUs.group_hopping,NrUlUlschPDUs.seq_hopping,NrUlUlschPDUs.NIdRS,NrUlUlschPDUs.nsf,l,NrUlUlschPDUs.dmrs_UplinkTransformPrecoding_r16);
end

tempchan = [];
fftCpOut = rxGrid(:,:,1);
alpha=0;
lamda =0;%10^(-snr/10);
%% Processing for RB DEMAPPER
[pusch_demap,SRbg,toneindx1,dataStartIdx] = wnNrPhyPuschCbpDemapping(fftCpOut, ...
    NrUlUlschPDUs,bwFftCp.fftSize,Exs);
if (NrUlUlschPDUs.tppi2BPSK==0)
    %% spectrum shaping
    if Rxshaping == 1 && Txshaping == 1
        spectrum_shaping = pusch_demap.*repmat(shape,1,NrUlUlschPDUs.nNrOfSymbols);
    end
    %% Spectrum folding
    puschCbpDemap(1).data = [spectrum_shaping(Exs+1:dftsize+Exs,1:NrUlUlschPDUs.nNrOfSymbols)] + ...
        [zeros(dftsize-Exs,NrUlUlschPDUs.nNrOfSymbols) ;spectrum_shaping(1:Exs,1:NrUlUlschPDUs.nNrOfSymbols)] + ...
        [spectrum_shaping(dftsize+2*Exs-(Exs-1:-1:0),1:NrUlUlschPDUs.nNrOfSymbols);zeros(dftsize-Exs,NrUlUlschPDUs.nNrOfSymbols) ];
else puschCbpDemap(1).data=pusch_demap;
    spectrum_shaping=0;
    lamda=1;
end
%%  channel estimation
rxTimeDomain=(ifft((puschCbpDemap(1).data))).*(sqrt(dftsize));

rx_TimeDomain_mod=rxTimeDomain(193:end,:);

rx_TimeDomain_dmrs=rxTimeDomain(1:2*NrUlUlschPDUs.nDMRSpSymb,:);
               
rec_fft=[];
conj_mul=[];
tempchan_test=[];


for indsymb = 1:NrUlUlschPDUs.nNrOfSymbols
    estOffset = ceil(NrUlUlschPDUs.nDMRSpSymb/4); % inf for 30KHz; 6 for 60Khz; 4 for 120KHz.
    Gen_FreqDomain_dmrs = fft((Gen_TimeDomain_dmrs([ceil(NrUlUlschPDUs.nDMRSpSymb*0.5)+1+estOffset:ceil(NrUlUlschPDUs.nDMRSpSymb) 1:ceil(NrUlUlschPDUs.nDMRSpSymb*0.5)+estOffset],indsymb)))./sqrt(NrUlUlschPDUs.nDMRSpSymb);
    rx_FreqDomain_dmrs  = fft(rx_TimeDomain_dmrs((ceil(NrUlUlschPDUs.nDMRSpSymb*0.5)+1+estOffset:ceil(NrUlUlschPDUs.nDMRSpSymb*.5)+NrUlUlschPDUs.nDMRSpSymb+estOffset),indsymb))./sqrt(NrUlUlschPDUs.nDMRSpSymb);
    tempchan =  rx_FreqDomain_dmrs.*conj(Gen_FreqDomain_dmrs)./(abs(Gen_FreqDomain_dmrs).^2+lamda);
    TimeDomain_tempchan = ifft(tempchan);

    % rtl implementation logic
    Gen_FreqDomain_dmrs2 = fft((Gen_TimeDomain_dmrs(:,indsymb)));
    rx_FreqDomain_dmrs2  = fft(rx_TimeDomain_dmrs(:,indsymb));
    tempchan2 =  rx_FreqDomain_dmrs2(1:96).*conj(Gen_FreqDomain_dmrs2)./(abs(Gen_FreqDomain_dmrs2).^2+(lamda.*(NrUlUlschPDUs.nDMRSpSymb))); 


    %mapping 96 to 1440 lenght 
    halfIndex = floor(NrUlUlschPDUs.nDMRSpSymb/2);
    A = TimeDomain_tempchan(1:halfIndex);
    B = TimeDomain_tempchan(halfIndex+1:NrUlUlschPDUs.nDMRSpSymb);
    temp3= zeros(1,dftsize);
    zero_padding= zeros((dftsize-NrUlUlschPDUs.nDMRSpSymb),1);
    if(alpha>0)
        temp3(1:length(B(halfIndex-alpha:end))) = B(halfIndex-alpha:end);
        temp3(length(B(halfIndex-alpha:end)) + (1:length(A))) = A(1:end);
        temp3(length(B(halfIndex-alpha:end)) + length(A) + length(zero_padding):end) = B(1:halfIndex-alpha);
    else
        temp3(1:length(A))=A(1:end);
        temp3(length(A) +length(zero_padding) +1 :end)=B(1:end);
    end


    puschChEstimate(1).cdm.layer.data(:,indsymb,1)= fft(temp3,dftsize);
    %%%%%%%%rtl implemented logic to verify output
    est_data_verify(:,indsymb)=tempchan;
    rec_fft(:,indsymb)=fft(rxTimeDomain(97:192,indsymb));
    conj_mul(:,indsymb)=rx_FreqDomain_dmrs.*conj(Gen_FreqDomain_dmrs);
    tempchan_test(:,indsymb)=TimeDomain_tempchan*96;%conj_mul(:,indsymb)./(Gen_FreqDomain_dmrs.*conj(Gen_FreqDomain_dmrs));
    interpolation_data(:,indsymb)=temp3;
    M_point_estimation_out(:,indsymb)=fft(temp3,dftsize);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%% Processing for PTRS Generation
nPtrsSyms = 0;
puschPtrsIdx.scalingFac = 0;
puschPtrsIdx.loc.freq.data = [];
puschPtrsIdx.loc.freq.len = 0;
puschPtrsIdx.loc.time.data = [];
puschPtrsIdx.loc.time.len = 0;
MSE = 0;
NrPhySimParam.toneavgfac = 1;
NrUlUlschPDUs.nNrofChunks = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Mmse Equalizer
%--------------((1/(H'*H+N0+RF))*H')*spec_folded
puschChEstimatedata=puschChEstimate(1).cdm.layer.data(:,:,1);
spec_folded=puschCbpDemap(1).data;
NoiseVariance =(10^(-snr/10));%n0*2048;%(10^(-snr/10)).*2048;

if NrUlUlschPDUs.modOrder==1 || NrUlUlschPDUs.modOrder ==2 || NrUlUlschPDUs.modOrder == 4
    scale=(1./(conj(puschChEstimatedata).*puschChEstimatedata+NoiseVariance+1e-2));
elseif NrUlUlschPDUs.modOrder == 6
    scale=(1./(conj(puschChEstimatedata).*puschChEstimatedata+NoiseVariance+0.01*1e-3));
else    
    scale=(1./(conj(puschChEstimatedata).*puschChEstimatedata+NoiseVariance));
end


weigth= scale.*(conj(puschChEstimatedata));
equalized_freq =weigth.*spec_folded;
equalized_time=ifft(equalized_freq).*sqrt(dftsize);
equalizedData=(reshape(equalized_time,[],1));
equalizedData=transpose(equalizedData);

FinalEquadata = [];
for i = 1:NrUlUlschPDUs.nNrOfSymbols
    FinalEquadata = [FinalEquadata equalizedData((i-1)*ntonesScheduled+1+(2*NrUlUlschPDUs.nCpsam):(i)*ntonesScheduled)];
end

for indlayer = 1:NrUlUlschPDUs.nNrOfLayers
    % Processing for Soft Demodulation
    if NrUlUlschPDUs.tppi2BPSK == 0
        [puschDemodOut_true,pi2BpskDerotData] = wnNrPhySoftDemodulation( FinalEquadata(indlayer,:), ...
            NrUlUlschPDUs.modOrder );
    elseif NrUlUlschPDUs.tppi2BPSK == 1
        NrUlUlschPDUs.modOrder=1;
         [puschDemodOut_true,pi2BpskDerotData] = wnNrPhySoftDemodulation( FinalEquadata(indlayer,:), ...
            NrUlUlschPDUs.modOrder );
        % indsymb = 01;
        % [puschDemodOut_all,pi2BpskDerotData] = wnNrPhySoftDemodulation( equalizedData(indlayer,:), ...
        %     NrUlUlschPDUs.modOrder );
        % puschDemodOut_true = [puschDemodOut_all((indsymb-1)*ntonesScheduled+(1:ceil(0.5*(ntonesScheduled-NrUlUlschPDUs.nDMRSpSymb))-NrUlUlschPDUs.nCpsam)).....
        %     puschDemodOut_all((indsymb-1)*ntonesScheduled+NrUlUlschPDUs.nCpsam+ceil(0.5*(ntonesScheduled+NrUlUlschPDUs.nDMRSpSymb))+1 :(indsymb)*ntonesScheduled)];

    end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 puschDemodOut(indlayer,:) = puschDemodOut_true.*(31/2); %%(in rtl demod output is sacled with 31/2)

%%
% Processing for Layer Demapper

[puschLLRInput] =puschDemodOut; %due to 1 layer

% Processing for Descrambling
puschTotalBits = length(puschLLRInput);

[puschDescramblerOut] = wnNrPhyPuschDescrambler (puschLLRInput, ...
    NrUlUlschPDUs, ...
    puschTotalBits);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[puschRxOut,NrUlUlschPDUs, decoded,cbDeConcatOut] = wnNrPhyPuschCwDecod(NrUlUlschPDUs, ...
    puschDescramblerOut, ...
    dmrsPrPrb, ...
    nPtrsSyms, ...
    NrUlUlschPDUs.nPrbAllocated, ...
    NrPhySimParam, ...
    puschCbgs,...
    dmrsCdmGWithData,...
    dmrsCdmGWithoutData);
% 
% if puschRxOut.mainCrcCheck == 1
%     keyboard;
% end
if puschRxOut.mainCrcCheck == 1
    CRC=0;
else CRC=1;
end
MSE_out = 0;%MSE(1,1);
ser=0;
ber=0;
end % End of the function

