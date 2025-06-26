
function [ue, channel, maxChDelay, pnoise] = MatlabWrapper(NrUlUlschPDUs,...
                                                   NrPhySimParam,...
                                                   bwFftCp,...
                                                    ChannelDelaySpread, ChannelModel)

    simParameters = [];             % Clear simParameters variable
    simParameters.NFrames = NrPhySimParam.totalItr;      % Number of 10ms frames

   
    %% UE and PUSCH Configuration
    % Set the key parameters of the simulation. These include:
    % 
    % * The bandwidth in resource blocks (12 subcarriers per resource block)
    % * Subcarrier spacing: 15, 30, 60, 120, 240 (kHz)
    % * Cyclic prefix length: normal or extended
    % * Cell ID
    % * Number of transmit and receive antennas
    % 
    % A substructure containing the UL-SCH and PUSCH parameters is also
    % specified. This includes:
    % 
    % * Target code rate
    % * Allocated resource blocks (PRBSet)
    % * Modulation scheme: 'pi/2-BPSK', 'QPSK', '16QAM', '64QAM', '256QAM'
    % * Number of layers
    % * Transform precoding (enable/disable)
    % * PUSCH transmission scheme and MIMO precoding matrix indication (TPMI)
    % * Number of antenna ports
    % * PUSCH mapping type
    % * DM-RS configuration parameters
    % 
    % Other simulation wide parameters are:
    % 
    % * Propagation channel model: 'TDL' or 'CDL'
    %
    % Note that if transform precoding is enabled, the number of layers should
    % be set to 1.

    % Bandwidth, numerology (SCS and CP type) and other general parameters
     simParameters.NRB = NrUlUlschPDUs.nBWPSize;                % Bandwidth in number of resource blocks (52RBs at 15kHz SCS for 10MHz BW)
    simParameters.SubcarrierSpacing = 15*2^(NrUlUlschPDUs.nSubcSpacing);  % 15, 30, 60, 120, 240 (kHz)
    simParameters.CyclicPrefix = 'Normal'; % 'Normal' or 'Extended'
    simParameters.NCellID = NrUlUlschPDUs.nPhyCellId;             % Cell identity
    simParameters.NTxAnts = NrPhySimParam.nRxant;             % Number of transmit antennas
    simParameters.NRxAnts = NrUlUlschPDUs.nNrOfLayers;             % Number of receive antennas

    % UL-SCH/PUSCH parameters
    % simParameters.PUSCH.TargetCodeRate = 658 / 1024;      % Code rate used to calculate transport block sizes
    % simParameters.PUSCH.PRBSet = (0:simParameters.NRB-1); % PUSCH PRB allocation
    % simParameters.PUSCH.SymbolSet = 0:13;            % PUSCH symbol allocation in each slot
    % simParameters.PUSCH.NohPRB = 0;                  % Additional RE overhead per PRB
    % simParameters.PUSCH.EnableHARQ = true;           % Enable/disable HARQ, if disabled, single transmission with RV=0, i.e. no retransmissions
    % simParameters.PUSCH.Modulation = '16QAM';         % 'pi/2-BPSK', 'QPSK', '16QAM', '64QAM', '256QAM'
    % simParameters.PUSCH.NLayers = 1;                 % Number of PUSCH layers
    % simParameters.PUSCH.RNTI = 1;                    % Radio Network Temporary Identifier
    % simParameters.PUSCH.TransformPrecoding = false;  % Enable/disable transform precoding
    % simParameters.PUSCH.TxScheme = 'nonCodebook';    % Transmission scheme ('nonCodebook','codebook')
    % simParameters.PUSCH.NAntennaPorts = 1;           % Number of antenna ports for codebook based precoding
    % simParameters.PUSCH.TPMI = 0;                    % Precoding matrix indicator for codebook based precoding
    % % PUSCH DM-RS configuration
    % simParameters.PUSCH.PUSCHMappingType = 'A';      % PUSCH mapping type ('A'(slot-wise),'B'(non slot-wise))
    % simParameters.PUSCH.DMRSTypeAPosition = 2;       % Mapping type A only. First DM-RS symbol position (2,3)
    % simParameters.PUSCH.DMRSLength = 1;              % Number of front-loaded DM-RS symbols (1(single symbol),2(double symbol))
    % simParameters.PUSCH.DMRSAdditionalPosition = 1;  % Additional DM-RS symbol positions (max range 0...3)
    % simParameters.PUSCH.DMRSConfigurationType = 1;   % DM-RS configuration type (1,2)
    % simParameters.PUSCH.NumCDMGroupsWithoutData = 2; % CDM groups without data
    % simParameters.PUSCH.NIDNSCID = 0;                % Scrambling identity (0...65535)
    % simParameters.PUSCH.NSCID = 0;                   % Scrambling initialization (0,1)
    % simParameters.PUSCH.NRSID = 0;                   % Scrambling ID for low-PAPR sequences (0...1007)
    % simParameters.PUSCH.GroupHopping = 'Disable';    % Hopping type ('Enable','Disable')

    % Define the propagation channel type
    simParameters.ChannelType = 'TDL'; % 'CDL' or 'TDL'


    %% Propagation Channel Model Configuration
    % Create the channel model object. Both CDL and TDL channel models are
    % supported [ <#14 5> ].
    if strcmpi(simParameters.ChannelType,'CDL')

        channel = nrCDLChannel;
        channel.DelayProfile = 'CDL-A';
        [txsize,rxsize] = hArrayGeometry(NrUlUlschPDUs.nNrOfLayers,NrPhySimParam.nRxant,'uplink');
        channel.TransmitAntennaArray.Size = txsize;
        channel.ReceiveAntennaArray.Size = rxsize;

    else

        channel = nrTDLChannel;
        channel.DelayProfile = ChannelModel;
        channel.NumTransmitAntennas = NrUlUlschPDUs.nNrOfLayers;
        channel.NumReceiveAntennas = NrPhySimParam.nRxant;
        channel.MIMOCorrelation = 'Low';%'Low';% 'High';
%           channel.SpatialCorrelationMatrix = eye(2);%[1 ];%0.9; 0.9 1];
        channel.Polarization = 'Cross-Polar';
%         if channel.DelayProfile == 'TDL-D'
%             channel.KFactorScaling = 1;
%             channel.KFactor = 9;
%         end
%         channel.TransmitPolarizationAngles = [-45 45];
%         channel.ReceivePolarizationAngles = [90];% 90];
% 
%         channel.ReceiveCorrelationMatrix = eye(NrPhySimParam.nRxant);
        channel.TransmissionDirection = 'Uplink';
    end

    channel.DelaySpread = ChannelDelaySpread; % in seconds
    channel.MaximumDopplerShift = NrPhySimParam.doppler; % in Hz

    %%
    % The sampling rate for the channel model is set using the value returned 
    % from hOFDMInfo.
    ue = simParameters;

    waveformInfo = hOFDMInfo(ue);
%     Info = hOFDMInfo(ue);
    channel.SampleRate = waveformInfo.SamplingRate;

    %%
    % Get the maximum number of delayed samples by a channel multipath
    % component. This is calculated from the channel path with the largest
    % delay and the implementation delay of the channel filter. This is
    % required later to flush the channel filter to obtain the received signal.

    chInfo = info(channel);
    maxChDelay = ceil(max(chInfo.PathDelays*channel.SampleRate));
    maxChDelay = maxChDelay + chInfo.ChannelFilterDelay;
    simParameters.Fc = NrPhySimParam.fc;
     simParameters.PNModel = 'C'; % 'A' (TDoc R1-163984 Set A), 'B' (TDoc R1-163984 Set B), 'C' (TR 38.803)
    % Phase noise level
    foffsetLog = (4:0.2:log10(channel.SampleRate/2)); % Model offset from 1e4 Hz to sr/2 Hz
    foffset = 10.^foffsetLog;         % Linear frequency offset
    pn_PSD = hPhaseNoisePoleZeroModel(foffset,simParameters.Fc,simParameters.PNModel); % dBc/Hz

    % Set phase noise level
    pnoise = comm.PhaseNoise('FrequencyOffset',foffset,'Level',pn_PSD,'SampleRate',channel.SampleRate);
    pnoise.RandomStream = "mt19937ar with seed";
    
