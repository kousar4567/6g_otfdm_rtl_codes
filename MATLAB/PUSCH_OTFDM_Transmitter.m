

function [cp_addition_matlab,RB_MAPPER,phase_com,ifft_matlab,dmrssamples,multiplexed_samples,m_point_dft_out_samples,spec_extended_output,rc_filtered_out,PuschModOut,puschScramblerOut,puschRatematchOut,puschWithCrc,nrPuschCbsOut]=PUSCH_OTFDM_Transmitter(tbData,Tbs_user,Tbs_valid_no,exe_prb,NrUlUlschPDUs)

numSymbols=NrUlUlschPDUs.nNrOfSymbols;
Tbs_valid_no = uint16(Tbs_valid_no); % no. of valid elements in the tb data array

cp_length=144;
extra_cp_samples = 128;
ifftSize=2048;
grid_size=132;
num_sym_slot=14;
num_slot=1;
%%% transmitter
[dmrssamples,multiplexed_samples,m_point_dft_out_samples,spec_extended_output,rc_filtered_out,PuschModOut,puschScramblerOut,puschRatematchOut,puschWithCrc,nrPuschCbsOut] = ...
    wnNrPhyPuschTxWrapper(tbData,Tbs_valid_no,exe_prb,NrUlUlschPDUs);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% karthik -added to verify output
% Example binary data (1x3744 bits, as a string or array)
% Sample data: 1x3744 bits of binary data in string format
% Sample data: 1x3744 array of type double with binary values (0s and 1s)
%puschRatematchOut = randi([0 1], 1, 3744);  % Replace with your actual 1x3744 data

% Number of bits per group
group_size = 32;

% Number of groups
num_groups = length(puschScramblerOut) / group_size;

% Preallocate cell arrays for hex and decimal results
hex_values = cell(1, num_groups);
decimal_values = zeros(1, num_groups);

% Loop through each 32-bit group
for i = 1:num_groups
    % Extract each 32-bit group as a subarray
    chunk =( puschScramblerOut((i-1)*group_size + 1 : i*group_size));
   
    % Convert the 32-bit group to a binary string
    binary_str = flip(num2str(chunk));       % Convert numbers to characters
    binary_str = strrep(binary_str, ' ', '');  % Remove spaces to get pure binary string

    % Convert binary string to decimal and hexadecimal
    decimal_values(i) = bin2dec(binary_str);      % Convert to decimal
    hex_values{i} = dec2hex(decimal_values(i));   % Convert to hex
end

% Display the results
% disp('Hexadecimal values:');
% disp(hex_values);
% 
% disp('Decimal values:');
% disp(decimal_values);



%% RB mapper
rc_data=rc_filtered_out; 
padding_needed = (grid_size*12) - (((NrUlUlschPDUs.nRBSize)+exe_prb)*12);
RB_MAPPER=zeros(grid_size*12, num_sym_slot*num_slot);
[rows, cols] = size(rc_data);

% Create a zero matrix for padding
padding = zeros(padding_needed,cols);

% Concatenate the original data with the padding
padded_data = [rc_data ;padding];

% Now assign the padded data to RB_MAPPER
RB_MAPPER(:,1:numSymbols) = padded_data;%transpose(padded_data);
% RB_MAPPER(:,1:numSymbols)= transpose(padarray(rc_data, [0 padding_needed], 'post'));
%% PHASE COMPENSATION
phase_com=zeros(grid_size*12, num_sym_slot*num_slot);
 bwFftCp.fftSize = ifftSize;%4096;
     bwFftCp.cpSyms  = cp_length;%288;
     numerology = 3;
     carrierFrequency = 7e9;%3.34992e6;%3.35082e9;%3381.6e6;
     slotIndex =1;
     temp=0;
     for pc=1:num_slot
            test=RB_MAPPER(:,pc+temp:temp+14);
[phase_com(:,((pc-1)*14)+1:(pc)*14),phase2]=wnNrPhyPhasePreCompensation(RB_MAPPER(:,((pc-1)*14)+1:(pc)*14),  ... % Mapper output (1 slot)
                                                            bwFftCp, ...
                                                            carrierFrequency, ... % centre frequency
                                                            numerology, ...  % subcarreir spacing
                                                            slotIndex   ...  % slot Index
                                                            );
    temp=temp+14;
     end
%% fft sequencer 
 fft_sequncer_matlab = zeros(ifftSize, num_sym_slot*num_slot);

for col = 1:numSymbols
    fft_seq_zeros=ifftSize-(grid_size*12);
    fft_seq_out1=vertcat(zeros(fft_seq_zeros/2,1),phase_com(:,col),zeros(fft_seq_zeros/2,1));
    fft_sequncer_matlab(:,col)=vertcat(fft_seq_out1((ifftSize/2)+1:end),fft_seq_out1(1:(ifftSize/2)));
end
%% ifft and cp addition
   ifft_matlab=ifft(fft_sequncer_matlab);
cp_addition_matlab = [];
for col = 1:num_sym_slot*num_slot
  %  if (col == 1)
    %    cp_addition_matlab = [cp_addition_matlab; ifft_matlab(ifftSize-cp_length-extra_cp_samples+1:end, col);ifft_matlab(:,col)];
   % else
        cp_addition_matlab = [cp_addition_matlab; ifft_matlab(ifftSize-cp_length+1:end, col);ifft_matlab(:,col)];
  %  end
end
end
