%% Function to correct the OFDM symbol based on the centre Frequency of the gNB as per sec 5.4 of 38.211
% Phase Post compensation is being done in the frequency domain

% exp(j*2*pi*f0 (t_mu_start_l + N_mu_cp_l *Tc))
% l is the number of symbols in a subframe
% Tc is the sampling rate
% N_u_cp_l is the CP length of each symbol
% t_mu_start_l is the starting location of each symbol
% t_mu_start_l = 0                   for l = 0
%             = t_mu_start_l-1 + (N_mu_u + N_mu_CP_l-1)Tc  

function [postCompensatedData] = wnNrPhyPhasePostCompensation(fftCpOut,  ... % Mapper output (1 slot)
                                                         bwFftCp, ... 
                                                         carrierFrequency, ... % UE centre frequency
                                                         numerology, ...  % subcarreir spacing
                                                         slotIndex   ...  % slot Index
                                                         )

  % sample Rate 
  sampleRate = bwFftCp.fftSize * 15*2^numerology* 1e3;
   
  % Additional CP samples for (7*2^mu)th symbol of the slot 
  nAddCpSamples = 16*((64*15*bwFftCp.fftSize)/(480*4096))*(2^numerology);
     
  % Calculating the CP lengths for each symbol in a subframe and
  % also accumulating the length of symbols for a subframe to know the
  % starting location of a symbol wrt to symbol 0 
 count =0;
 for symIdx = 1:14*(2^numerology)
     
     if (mod(symIdx - 1, 7*(2^numerology)) == 0)
        cpLength(symIdx) = bwFftCp.cpSyms + nAddCpSamples;
        nSample(symIdx) = bwFftCp.fftSize + bwFftCp.cpSyms + nAddCpSamples;
       
     else
        cpLength(symIdx) = bwFftCp.cpSyms;
        nSample(symIdx) = bwFftCp.fftSize + bwFftCp.cpSyms;
     end
     N_mu_start(symIdx) = count;
     count = count + nSample(symIdx);
 end
 
 N_mu_CP    = cpLength; % CP length of each symbol
 N_mu_u     = bwFftCp.fftSize; % fft size
 t_u_cp     = cpLength./sampleRate; 
 t_mu_start = N_mu_start./sampleRate; % for a subframe
 
 slotsPerSubframe = 2^numerology;
 slotNumber = mod(slotIndex,slotsPerSubframe);
 
 % based on the slot number in a subframe
 t_mu_startSlot = t_mu_start(slotNumber*14 + 1 : (slotNumber+1)*14); 
 symbolPhases = 2* pi * (t_mu_startSlot + t_u_cp(slotNumber*14 + (1:14))); 
 
 % Phase Post Compensation
  for symIdx = 1:14
     postCompensatedData(:,symIdx) = fftCpOut(:,symIdx).* ....
         exp(1i *carrierFrequency* symbolPhases(symIdx));
  end
                                                    
 end