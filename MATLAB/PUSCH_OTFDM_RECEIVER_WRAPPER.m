clc;
clear all;


addpath('wnNrPhyPuschReceiver');
addpath('wnNrPhyPuschTransmitterV2');

load("tx_data.mat","cp_addition_matlab");
% load("cp_removal_out_new.dat","cp_r_data.mat")

  rng(20);

Inputvector = {1,...testCasesTable.mcs_index(z),...      % MCS[4 10 19 27] table2
    120,...    % RBsize
    01,....     % Tx shaping flag
    'SQRC',... % Tx shaping filter % 'RC' 'SQRC' '3tap' '2tap' '2tap_gmsk' 'GMSK' 'SQRC_fold'
    01,...      % Rx shaping flag
    'SQRC',....% Rx shaping filter % 'RC' 'SQRC' '3tap' '2tap' '2tap_gmsk' 'GMSK' 'SQRC_fold'
    1/15,......% Fraction of RS size for a given M = 12*NPRB
    1/15,......% Fraction of CP size for a given M = 12*NPRB
    1 ,......% Total number of iteration per SNR
    30,...testCasesTable.SNR(z),......% SNR values for a given modulation
    0,.........% Timing offset value
    0,...testCasesTable.Velocity(z),.........% Speed in Kmph
    'TDL-C',...% Channel model
    30e-9,....testCasesTable.DelaySpread(z)*1e-9,........% Delay spread
    3,.............%number of symbols
    0,..........%exe_prb
    };
[NrPhySimParam] = wnNrPhySimParamInit();
[NrUlUlschPDUs] = wnNrPhyPuschInit();
NrPhySimParam.chanType=1;    %[0---->awgn 1---->multipath 2--->Y=x]

NrUlUlschPDUs.nMCS = Inputvector{1};
NrUlUlschPDUs.nPrbAllocated=Inputvector{2};%excluding exe (dft_size/12...1440/12=120)
mcsCRnti=0;
[NrUlUlschPDUs.modOrder,NrUlUlschPDUs.codingRate,spectralEff,table] = wnNrPhyPuschMCS(NrUlUlschPDUs,mcsCRnti);



numPRBs=Inputvector{2};        %9 bits
numSymbols=Inputvector{15};      %4 bits
exe_prb=Inputvector{16};
% dmrs config values
N_dft = (NrUlUlschPDUs.nPrbAllocated*12);       % 11 bits
NrUlUlschPDUs.nDMRSpSymb =N_dft*Inputvector{7};
NrUlUlschPDUs.nNrOfSymbols=Inputvector{15};
NrUlUlschPDUs.nCpsam =NrUlUlschPDUs.nDMRSpSymb;

[ NrUlUlschPDUs.nTBSize] = wnNrPhyPuschTbsCal(NrUlUlschPDUs,table,NrUlUlschPDUs.modOrder,NrUlUlschPDUs.codingRate);
tbsize=NrUlUlschPDUs.nTBSize;
%  NrUlUlschPDUs.nTBSize=6400;
% tbsize=6400;
%% RB size
NrUlUlschPDUs.nRBSize = Inputvector{2};
%% Rx shaping filter
RxFilt = Inputvector{6};
%% Total iterations
NrPhySimParam.totalItr = Inputvector{9};
%% SNR values
NrPhySimParam.sinr = Inputvector{10};
%% Timing offset
TOoffset = ceil(Inputvector{11}/8);
%% Speed
Speed = Inputvector{12};
%% Channel model
ChannelModel = Inputvector{13};
%% Channel Delay Spread
ChannelDelaySpread = Inputvector{14};

bwFftCp = nrBwFftCpConfig(NrUlUlschPDUs.nrOperatingFreqBand,... % Operating Band FR1 vs FR2
            (NrUlUlschPDUs.numerology),... % Subcarrier spacing
            NrUlUlschPDUs.maxTxBwInMHz); % Max. frequency in MHz
        NrUlUlschPDUs.nBwSize = bwFftCp.bwInPrbs;
        NrUlUlschPDUs.nBWPSize = bwFftCp.bwInPrbs;

        NrPhySimParam.doppler = NrPhySimParam.fc*Speed*5/(3e8*18);
        [ue, channel, maxChDelay, pnoise] = MatlabWrapper(NrUlUlschPDUs, NrPhySimParam,bwFftCp, ChannelDelaySpread, ChannelModel);
        info = hOFDMInfo(ue);

txWaveform = cp_addition_matlab(1:30816,1);
                %% adding channel
                if (NrPhySimParam.chanType==1)
                     txWaveform = [txWaveform; zeros(maxChDelay,size(txWaveform,2))]; %#ok<AGROW>
                    [rxWaveform,pathGains,sampleTimes] = channel(txWaveform);

                    Tx_power=1;
                    n0=(Tx_power/bwFftCp.fftSize)/10^(NrPhySimParam.sinr/10);
                    noise = sqrt(n0/2)*complex(randn(size(rxWaveform)),randn(size(rxWaveform)));
                    rxWaveform = rxWaveform + noise;
                    rxWaveform1 = [zeros(TOoffset,NrPhySimParam.nRxant);rxWaveform];
                    rxWaveform = rxWaveform1(1:length(rxWaveform1),1:size(rxWaveform1,2));
                    % Perfect synchronization. Use information provided by the channel
                    % to find the strongest multipath component
                    pathFilters = getPathFilters(channel);
                    [offset,mag] = nrPerfectTimingEstimate(pathGains,pathFilters);
                    rxWaveform = rxWaveform(1+offset:end,:);
                elseif (NrPhySimParam.chanType==2)
                    rxWaveform=txWaveform;
                    n0=0;
                else
                    Tx_power=1;
                    n0=(Tx_power/bwFftCp.fftSize)/10^(NrPhySimParam.sinr/10);
                    noise = sqrt(n0/2)*complex(randn(size(txWaveform)),randn(size(txWaveform)));
                    rxWaveform = txWaveform + noise;
                end


                %% storing  cp data in 2.14 format
size = 16; %16bit input
 sf = 2^14; %scaling factor
 channel_cp_real=real(rxWaveform);
 channel_cp_imag=imag(rxWaveform);
 %conversion of the input samples to binary 16-bit format
channel_cp_real_int = round(channel_cp_real.*sf);
channel_cp_real_binary =  dec2bin(mod((channel_cp_real_int),2^size),size);
channel_cp_real_hex = (dec2hex(bin2dec(channel_cp_real_binary)));

channel_cp_imag_int = round(channel_cp_imag.*sf);
channel_cp_imag_binary =  dec2bin(mod((channel_cp_imag_int),2^size),size);
channel_cp_imag_hex =  (dec2hex(bin2dec(channel_cp_imag_binary)));
channel_cp_fixed=cellstr(horzcat([channel_cp_imag_binary,channel_cp_real_binary]));

% %writing the binary 16bit output in a file
 fid = fopen('channel_cp_fixed.mem','wt');
 fprintf(fid,'%8s \n',channel_cp_fixed{:});
%% storing noise in 2.14
 NV=10^(-NrPhySimParam.sinr/10); 
 sf_n = 2^14; %scaling factor
 %conversion of the input samples to binary 16-bit format
noise_real_int = round(NV.*sf_n);
noise_real_binary =  dec2bin(mod((noise_real_int),2^size),size);
noise_real_hex = (dec2hex(bin2dec(noise_real_binary)));
noise_fixed=cellstr(noise_real_binary);
% %writing the binary 16bit output in a file

 fid = fopen('../channels/rx/script/noise.mem','wt');
 fprintf(fid,'%8s \n',noise_fixed{:});
%%
 slotIndex=1;
                [fftCpOut,cpRmvedData] = wnNrPhyfftCpRemoval (rxWaveform(:, 1),  ...
                    bwFftCp, ...
                    3, ...
                    slotIndex);
               
                [postCompensatedData] = wnNrPhyPhasePostCompensation(fftCpOut,  ... % Mapper output (1 slot)
                    bwFftCp, ...
                    NrPhySimParam.fc, ... % UE centre frequency
                    NrUlUlschPDUs.numerology, ...  % subcarreir spacing
                    slotIndex   ...  % slot Index
                    );



                %% Receiver function
                rxGrid = postCompensatedData;
                Exs=(12*exe_prb)/2;
                indExtfac=((12*exe_prb)/N_dft)*100;
                [puschRxOut,NrUlUlschPDUs,MSE_out,ser,ber,FinalEquadata,puschCbpDemap,puschDemodOut_true,puschDescramblerOut,cbDeConcatOut,rx_mod,rx_dmrs,puschChEstimate,equalizedData,rx_rbdemap,tempchan_test,est_data_verify,M_point_estimation_out,interpolation_data,rx_spec_shape,CRC,weigth] =wnNrPhyPuschReceiver_layupd(NrUlUlschPDUs, ...
                    1,1,rxWaveform,NrPhySimParam,bwFftCp,[],[],NrPhySimParam.sinr,1,[],rxGrid,0,[],[],[],Exs,1,1,indExtfac,0.1,RxFilt,0,0,0,n0);

                
                
        %%   
        simulation=0;
  if (simulation==1)              
for i=1:1
%    % subplot(3,3,i);
    plot(real(cp_removal_out_new(1:2048,i)),'g'); 
    hold on;
    stem(real(cpRmvedData(:,i)));%     title(['Samples of Symbol ', num2str(i)]);
%     legend("matlab output","rtl output");
%     hold off;
  end

                %% cp removal
% rtl_cp_rem=readmatrix('../channels/rx/script/cp_removal_out.dat','Delimiter','tab');
% sgtitle('idft matlab and rtl output symbols real values');
% for i=1:1
% %     subplot(3,3,i);
%     plot(real((cpRmvedData(:,i))),'g');
%     hold on;
%     stem(real(rtl_cp_rem(1+(i-1)*(2048):i*(2048),1)));
%     title(['Samples of Symbol ', num2str(i)]);
%     legend("matlab output","rtl output");
%     hold off;
% end
%% post phase compensation
% rtl_post_pc=readmatrix('../channels/rx/script/phase_compensation_rx.dat','Delimiter','tab');
% sgtitle('post pc matlab and rtl output symbols real values');
% for i=1:1
%     %subplot(3,3,i);
%     plot(imag((postCompensatedData(:,i))),'g');
%     hold on;
%     stem(imag(rtl_post_pc(1+(i-1)*(1584):i*(1584),1)));
%     title(['Samples of Symbol ', num2str(i)]);
%     legend("matlab output","rtl output");
%     hold off;
% end
 %% demapper
% rtl_rb_demap=readmatrix('../channels/rx/script/RB_demapper_out.dat','Delimiter','tab');
% % rtl_rb_demap=readmatrix('/home/lena/KARTHIK_GIT/OTFDM_IITH-dev_all_qam_working/OTFDM_IITH-dev_all_qam_working_without_fifo/channels/rx/script/RB_demapper_out.dat','Delimiter','tab');
% sgtitle('rbdemap matlab and rtl output symbols real values');
% for i=3:3
%     %subplot(3,3,i);
%     plot(imag((rx_rbdemap(:,i))),'g');
%     hold on;
%     stem(imag(rtl_rb_demap(1+(i-1)*(1512):i*(1512),1)));
%     title(['Samples of Symbol ', num2str(i)]);
%     legend("matlab output","rtl output");
%     hold off;
% end
% 
% 
% len_rb=1512;
% for i=1:3
%  diff_rb = ((rx_rbdemap(:,i))-(rtl_rb_demap(1+(i-1)*(len_rb):i*(len_rb))));
% %Compute the squared magnitude of the difference
% squaredMagnitude = abs(diff_rb).^2;
% for k=1:len_rb
%     if (squaredMagnitude(k)>(10e-5))
%         disp("failed");
%         disp(squaredMagnitude(k));
%         disp(k);
%    % else disp("passed");
%     end
% end
% end
  %% spec_fold
% spec_fold_matlab=puschCbpDemap(1).data;
% spec_fold_rtl=readmatrix('../channels/rx/script/spec_out.dat','Delimiter','tab');
% sgtitle('spec_fold matlab and rtl output symbols real values');
% for i=3:3
%     %subplot(3,3,i);
%     plot(imag((spec_fold_matlab(:,i))),'g');
%     hold on;
%     stem(imag(spec_fold_rtl(1+(i-1)*(N_dft):i*(N_dft))));
%     title(['Samples of Symbol ', num2str(i)]);
%     legend("matlab output","rtl output");
%     hold off;
% end
 %% received dmrs
%  estOffset=96/4;
% matlab_rx_dmrs=rx_dmrs((ceil(NrUlUlschPDUs.nDMRSpSymb*0.5)+1+estOffset:ceil(NrUlUlschPDUs.nDMRSpSymb*.5)+NrUlUlschPDUs.nDMRSpSymb+estOffset),:).*sqrt(1440);
% rtl_rx_dmrs=readmatrix('../channels/rx/script/DMRS_out.dat','Delimiter','tab');
% sgtitle('dmrs matlab and rtl output symbols real values');
% for i=12:12
%     %subplot(3,3,i);
%     plot(imag((matlab_rx_dmrs(:,i))),'g');
%     hold on;
%     stem(imag(rtl_rx_dmrs(1+(i-1)*(96):i*(96))));
%     title(['Samples of Symbol ', num2str(i)]);
%     legend("matlab output","rtl output");
%     hold off;
% end
%% channel estimation(complex_div)
matlab_est_data=est_data_verify;
rtl_est_data=readmatrix('../channels/rx/script/dft_ntrl.dat','Delimiter','tab');
sgtitle('estimation matlab and rtl output symbols real values');
for i=8:8
 %   subplot(3,3,i);
    hold on;    
    plot(imag((matlab_est_data(:,i))),'g');
    stem(imag(rtl_est_data(1+(i-1)*(96):i*(96),1)));
    title(['Samples of Symbol ', num2str(i)]);
    legend("matlab output","rtl output");
    hold off;
end

% len_est=96;
% for i=1:numSymbols
%  diff_final_est =((matlab_est_data(:,i))-rtl_est_data(1+(i-1)*(96):i*(96),1));
% %Compute the squared magnitude of the difference
% squaredMagnitude_est = abs(diff_final_est).^2;
% for k=1:len_est
%     if (squaredMagnitude_est(k)>(10e-3))
%         disp("failed");
%         disp(squaredMagnitude_est(k));
%         disp(k);
%    % else disp("passed");
%     end
% end
% end
%% interpolation
interpolation_data_matlab=interpolation_data;
interpolation_data_rtl=readmatrix('../channels/rx/script/interpolation.dat','Delimiter','tab');
sgtitle('after interpolation dft matlab and rtl output symbols real values');
for i=1:1
    %subplot(3,3,i);
    plot(imag((interpolation_data_matlab(:,i))),'g');
    hold on;
    stem(imag(interpolation_data_rtl(1+(i-1)*(1440):i*(1440),1)));
    title(['Samples of Symbol ', num2str(i)]);
    legend("matlab output","rtl output");
    hold off;
end
 %% M point channel estimation output
M_point_estimation_out_matlab=M_point_estimation_out;
M_point_estimation_out_rtl=readmatrix('../channels/rx/script/dft_ntrl_ipn.dat','Delimiter','tab');
sgtitle('after interpolation dft matlab and rtl output symbols real values');
for i=12:12
    %subplot(3,3,i);
    plot(imag((M_point_estimation_out_matlab(:,i))),'g');
    hold on;
    stem(imag(M_point_estimation_out_rtl(1+(i-1)*(1440):i*(1440),1)));
    title(['Samples of Symbol ', num2str(i)]);
    legend("matlab output","rtl output");
    hold off;
end
 %% weight compute
matlab_weight=weigth;
rtl_weight=readmatrix('../channels/rx/script/weight_out.dat','Delimiter','tab');
sgtitle('weight matlab and rtl output symbols real values');
for i=12:12
 %   subplot(3,3,i);
    plot(imag((matlab_weight(:,i))),'g');
    hold on;
    stem(imag(rtl_weight(1+(i-1)*(1440):i*(1440),1)));
    title(['Samples of Symbol ', num2str(i)]);
    legend("matlab output","rtl output");
    hold off;
end
 %% channel equalization
 matlab_eqa=transpose(FinalEquadata);
rtl_eqa=readmatrix('../channels/rx/script/equalized_time_data.dat','Delimiter','tab');
sgtitle('eqa matlab and rtl output symbols real values');
for i=6:6
    %subplot(3,3,i);
    plot(imag((matlab_eqa(1+(i-1)*(1248):i*(1248)))),'g');
    hold on;
    stem(imag(rtl_eqa(1+(i-1)*(1248):i*(1248))));
    title(['Samples of Symbol ', num2str(i)]);
    legend("matlab output","rtl output");
    hold off;
end
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% equalized mod data MSE
len_eq=1248;
for i=1:numSymbols
 diff_final_eq = ((matlab_eqa(1+(i-1)*(len_eq):i*(len_eq)))-(rtl_eqa(1+(i-1)*(len_eq):i*(len_eq))));
%Compute the squared magnitude of the difference
squaredMagnitude = abs(diff_final_eq).^2;
for k=1:len_eq
    if (squaredMagnitude(k)>(10e-1))
        disp("failed");
        disp(squaredMagnitude(k));
        disp(k);
   % else disp("passed");
    end
end
end
 %% soft demod
demod_matlab =transpose(puschDemodOut_true);
demod_rtl=readmatrix('../channels/rx/script/Demod_out.dat','Delimiter','tab');
sgtitle('soft demod matlab and rtl output symbols real values');
for i=1:1
   % subplot(3,3,i);
    plot(((demod_matlab(1+(i-1)*(1248*NrUlUlschPDUs.modOrder):i*(1248*NrUlUlschPDUs.modOrder)))),'g');
    hold on;
    stem((demod_rtl(1+(i-1)*(1248*NrUlUlschPDUs.modOrder):i*(1248*NrUlUlschPDUs.modOrder))));
    title(['Samples of Symbol ', num2str(i)]);
    legend("matlab output","rtl output");
    hold off;
end
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% soft demod MSE
len_data=1248*NrUlUlschPDUs.modOrder;
for i=1:numSymbols
 diff_demod = ((demod_matlab(1+(i-1)*(len_data):i*(len_data)))-(demod_rtl(1+(i-1)*(len_data):i*(len_data))));
%Compute the squared magnitude of the difference
squaredMagnitude = abs(diff_demod).^2;
for k=1:len_data
    if (squaredMagnitude(k)>(10e-1))
        disp("failed");
        disp(squaredMagnitude(k));
        disp(k);
   % else disp("passed");
    end
end
end
end
