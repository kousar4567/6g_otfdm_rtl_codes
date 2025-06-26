clc;
clear all;

addpath('wnNrPhyPuschTransmitterV2');
% rng(20);

Inputvector = {1,...testCasesTable.mcs_index(z),...      % MCS[4 10 19 27] table2
    120,...    % RBsize
    01,....     % Tx shaping flag
    'SQRC',... % Tx shaping filter % 'RC' 'SQRC' '3tap' '2tap' '2tap_gmsk' 'GMSK' 'SQRC_fold'
    01,...      % Rx shaping flag
    'SQRC',....% Rx shaping filter % 'RC' 'SQRC' '3tap' '2tap' '2tap_gmsk' 'GMSK' 'SQRC_fold'
    1/15,......% Fraction of RS size for a given M = 12*NPRB
    1/15,......% Fraction of CP size for a given M = 12*NPRB
    1 ,......% Total number of iteration per SNR
    10,...testCasesTable.SNR(z),......% SNR values for a given modulation
    0,.........% Timing offset value
    50,...testCasesTable.Velocity(z),.........% Speed in Kmph
    'TDL-C',...% Channel model
    300e-9,....testCasesTable.DelaySpread(z)*1e-9,........% Delay spread
    3,............%number of symbols
    0,..........%exe_prb
    };
[NrPhySimParam] = wnNrPhySimParamInit();
[NrUlUlschPDUs] = wnNrPhyPuschInit();
for index=1:length(Inputvector{1})
    % Create folder name from the current index
    folder_name = sprintf("MCS_%d", Inputvector{1}(index));
      % Create the folder if it doesn't exist
        if ~exist(folder_name, 'dir')
            mkdir(folder_name);
        end
    for no_sym=1:length(Inputvector{15})
        rng(20);
        NrUlUlschPDUs.nMCS = Inputvector{1}(index);
        NrUlUlschPDUs.nPrbAllocated=Inputvector{2};%excluding exe (dft_size/12...1440/12=120)
        mcsCRnti=0;
        [NrUlUlschPDUs.modOrder,NrUlUlschPDUs.codingRate,spectralEff,table] = wnNrPhyPuschMCS(NrUlUlschPDUs,mcsCRnti);



        numPRBs=Inputvector{2};        %9 bits
        numSymbols=Inputvector{15}(no_sym);      %4 bits
        exe_prb=Inputvector{16};
        % dmrs config values
        N_dft = (NrUlUlschPDUs.nPrbAllocated*12);       % 11 bits
        NrUlUlschPDUs.nDMRSpSymb =N_dft*Inputvector{7};
        NrUlUlschPDUs.nNrOfSymbols=Inputvector{15}(no_sym);
        NrUlUlschPDUs.nCpsam =NrUlUlschPDUs.nDMRSpSymb;

        [ NrUlUlschPDUs.nTBSize] = wnNrPhyPuschTbsCal(NrUlUlschPDUs,table,NrUlUlschPDUs.modOrder,NrUlUlschPDUs.codingRate);
        tbsize=NrUlUlschPDUs.nTBSize;
        % NrUlUlschPDUs.nTBSize=9304;
        % tbsize=9304;
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TB Data

        inputTbs = zeros(1,1000000);
        Tbs_user = zeros(1,31250);
        Tbs_valid_no = ceil(tbsize/32);
        inputTbs(1:tbsize) = randi([0,1],1, tbsize);
        Tbs_user(1:Tbs_valid_no) = ones(1,Tbs_valid_no) *32;
        if(mod(tbsize,32) ~= 0)
            Tbs_user(Tbs_valid_no) = mod(tbsize,32);
        end
        % Splitting the tb data into 32-bit elements
        tb_data = bi2de(reshape(inputTbs', 32, [])', 'right-msb');
        tbData = uint32(tb_data);

        %% rtl input data
        rtl_data=[];
        target_bits=512;
        for ii=1:ceil((ceil(tbsize/32))/16)
            temp_data=reshape((dec2bin(flip(tb_data(1+(ii-1)*16:ii*16))))',1,[]);
            if length(temp_data) < target_bits
                temp_data = [ repmat('0', 1, target_bits - length(temp_data)),temp_data];
            end
            rtl_data=vertcat(rtl_data,temp_data);
            filename=  fullfile(folder_name, sprintf("rtl_input_data_MCS%d_%d_%d.dat", Inputvector{1}(index),numSymbols, tbsize));
            writematrix(rtl_data, filename, 'Delimiter', 'tab');
        end
        %%
        [cp_addition_matlab,RB_MAPPER,phase_com,ifft_matlab,dmrssamples,multiplexed_samples,m_point_dft_out_samples,spec_extended_output,rc_filtered_out,PuschModOut,puschScramblerOut,puschRatematchOut,puschWithCrc,nrPuschCbsOut]=PUSCH_OTFDM_Transmitter(tbData,Tbs_user,Tbs_valid_no,exe_prb,NrUlUlschPDUs);
     
        % Save to .mat file
        txWaveform = cp_addition_matlab;

        % Set the file name inside the respective folder
        mat_filename = fullfile(folder_name, sprintf("tx_data_MCS%d_%d_%d.mat", Inputvector{1}(index),numSymbols, tbsize));

        save(mat_filename, "txWaveform");
        % save to .dat file
        size_cp = 16; %16bit input
        sf = 2^14; %scaling factor
        channel_cp_real=real(txWaveform(1:30688, 1));
        channel_cp_imag=imag(txWaveform(1:30688, 1));
        %conversion of the input samples to binary 16-bit format
        channel_cp_real_int = round(channel_cp_real.*sf);
        channel_cp_real_binary =  dec2bin(mod((channel_cp_real_int),2^size_cp),size_cp);
        channel_cp_real_hex = (dec2hex(bin2dec(channel_cp_real_binary)));

        channel_cp_imag_int = round(channel_cp_imag.*sf);
        channel_cp_imag_binary =  dec2bin(mod((channel_cp_imag_int),2^size_cp),size_cp);
        channel_cp_imag_hex =  (dec2hex(bin2dec(channel_cp_imag_binary)));
        channel_cp_fixed=cellstr(horzcat([channel_cp_imag_binary,channel_cp_real_binary]));
        channel_cp_fixed_hex=cellstr(horzcat([channel_cp_imag_hex,channel_cp_real_hex]));
        filename =  fullfile(folder_name, sprintf("tx_data_MCS%d_%d_%d.dat", Inputvector{1}(index),numSymbols, tbsize));
        fid = fopen(filename, 'wt');
        writematrix(txWaveform, filename, 'Delimiter', 'tab');
        % fprintf(fid, '%s\n', channel_cp_fixed{:});
        fclose(fid);
    end
end
%    simulation=0;
%   if (simulation==1)
% %% spec shape
% rc_filtered_out_matlab=rc_filtered_out;
% rc_filtered_out_rtl=readmatrix('../channels/tx/script/spec_shape_data_new.dat','Delimiter','tab');
% sgtitle('matlab and rtl output symbols real values');
% for i=3:3
%    % subplot(3,3,i);
%     plot(real((rc_filtered_out_matlab(1+(i-1)*(1512):i*(1512)))),'g');
%     hold on;
%     stem(real(rc_filtered_out_rtl(1+(i-1)*1512:i*1512)));
%     title(['Samples of Symbol ', num2str(i)]);
%     legend("matlab output","rtl output");
%     hold off;
% end
%
% %% spec exetension
% if (NrUlUlschPDUs.tppi2BPSK==0)
%     spec_extended_output_matlab=transpose(spec_extended_output);
%     spec_extended_output_rtl=readmatrix('../channels/tx/script/spec_exe_data_new.dat','Delimiter','tab');
%     sgtitle('matlab and rtl output symbols real values');
%     for i=1:1
%         % subplot(3,3,i);
%         plot(real((spec_extended_output_matlab(:,i))),'g');    hold on;
%         stem(real(spec_extended_output_rtl(1+(i-1)*1512:i*1512)));
%         title(['Samples of Symbol ', num2str(i)]);
%         legend("matlab output","rtl output");
%         hold off;
%     end
% else
%     rtl_exe_data=readmatrix('../channels/tx/script/spec_exe_data_new.dat','Delimiter','tab');
%     matlab_exe_data=transpose(m_point_dft_out_samples);
%     sgtitle('matlab and rtl output symbols real values');
%     for i=3:3
%         % subplot(3,3,i);
%         plot(real(matlab_exe_data(:,i)),'g');
%         hold on;
%         stem(real(rtl_exe_data(1+(i-1)*1440:i*1440)));
%         title(['Samples of Symbol ', num2str(i)]);
%         legend("matlab output","rtl output");
%         hold off;
%     end
% end
% %%
% mux_out_matlab=multiplexed_samples;
% mux_out_rtl=readmatrix('../channels/tx/script/mux_data_new.dat','Delimiter','tab');
% sgtitle('matlab and rtl output symbols real values');
% for i=2:2
%    % subplot(3,3,i);
%     plot(imag(mux_out_matlab(i,:)),'g');
%     hold on;
%     stem(imag(mux_out_rtl(1+(i-1)*1440:i*1440)));
%     title(['Samples of Symbol ', num2str(i)]);
%     legend("matlab output","rtl output");
%     hold off;
% end
%
% %% modulation
% mod_out_matlab=PuschModOut;
% mod_out_rtl=readmatrix('../channels/tx/script/modulation_data_new.dat','Delimiter','tab');
% sgtitle('matlab and rtl output symbols real values');
% for i=4:4
%    % subplot(3,3,i);
%     plot(imag(mod_out_matlab(1+(i-1)*1248:i*1248)),'g');
%     hold on;
%     stem(imag(mod_out_rtl(1+(i-1)*1248:i*1248)));
%     title(['Samples of Symbol ', num2str(i)]);
%     legend("matlab output","rtl output");
%     hold off;
% end
% %% RB_MAPPER
% RB_MAPPER_matlab=RB_MAPPER;
% RB_MAPPER_rtl=readmatrix('../channels/tx/script/RB_mapper.dat','Delimiter','tab');
% sgtitle('matlab and rtl output symbols real values');
% for i=1:1
%    % subplot(3,3,i);
%     plot(real((RB_MAPPER(1+(i-1)*(1584):i*(1584)))),'g');
%     hold on;
%     stem(real(RB_MAPPER_rtl(1+(i-1)*1584:i*1584)));
%     title(['Samples of Symbol ', num2str(i)]);
%     legend("matlab output","rtl output");
%     hold off;
% end
%
% %% ifft
% ifftSize=2048;
% ifft_matlab_out=ifft_matlab;
% ifft_rtl=readmatrix('../channels/tx/script/ifft_out.dat','Delimiter','tab');
% sgtitle('ifft matlab and rtl output symbols real values');
% for i=2:2
%     %subplot(3,3,i);
%     plot(real((ifft_matlab_out(1+(i-1)*(ifftSize):i*(ifftSize)))),'g');
%     hold on;
%     stem(real(ifft_rtl(1+(i-1)*(ifftSize):i*(ifftSize))));
%     title(['Samples of Symbol ', num2str(i)]);
%     legend("matlab output","rtl output");
%     hold off;
% end
% %%
%    dmrs_out_rtl=readmatrix('../channels/tx/script/DMRS_data.dat','Delimiter','tab');
%    sgtitle('matlab and rtl output symbols real values');
%    for i=2:2
%        % subplot(3,3,i);
%        plot(real(dmrssamples(i,:)),'g');
%        hold on;
%        stem(real(dmrs_out_rtl(1+(i-1)*96:i*96)));
%        title(['Samples of Symbol ', num2str(i)]);
%        legend("matlab output","rtl output");
%        hold off;
%    end
%    %%
%    % phase_out_matlab=phase_com_fi;
%  phase_out_matlab=phase_com;
%    phase_out_rtl=readmatrix('../channels/tx/script/phase_compensation.dat','Delimiter','tab');
%    sgtitle('matlab and rtl output symbols real values');
%    for i=4:4
%        % subplot(3,3,i);
%        plot(imag(phase_out_matlab(:,i)),'g');
%        hold on;
%        stem(imag(phase_out_rtl(1+(i-1)*1584:i*1584)));
%        % title(['Samples of Symbol ', num2str(i)]);
%        legend("matlab output","rtl output");
%        hold off;
%    end
%
% %% %%
% ifftSize=2048;
% cp_length=144;
% %
% cp_addition_rtl=readmatrix('../channels/tx/script/cp_addition_out.dat','Delimiter','tab');
% sgtitle('cp_addition matlab and rtl output symbols real values');
% for i=2:2
%     %subplot(3,3,i);
%     plot(real((cp_addition_matlab(1+(i-1)*(ifftSize+cp_length):i*(ifftSize+cp_length)))),'g');
%     hold on;
%     stem(real(cp_addition_rtl(1+(i-1)*(ifftSize+cp_length):i*(ifftSize+cp_length))));
%     title(['Samples of Symbol ', num2str(i)]);
%     legend("matlab output","rtl output");
%     hold off;
% end
%  %%
% diff = (cp_addition_rtl(1:((2048+144)*numSymbols)+128,1)-cp_addition_matlab(1:((2048+144)*numSymbols)+128,1));
% squaredMagnitude = abs(diff).^2;
% for k=1:length(diff)
%     if (squaredMagnitude(k)>(10e-4))
%         disp("failed");
%         disp(squaredMagnitude(k));
%         disp(k);
%     %else disp("passed");
%     end
%
% end
% end
% save("tx_data.mat","cp_addition_matlab");
