
% FFT and CP Removal

function [fftCpOut,cpRmvedData] = wnNrPhyfftCpRemoval(fftIn,  ...
                                          bwFftCp, ...
                                          numerology, ...
                                          slotIndex)
    
    % Additional CP samples for 0th and 7th OFDM symbol of slot
    nAddCpSamples = 16*(64*15*bwFftCp.fftSize/(480*4096))*(2^numerology);
%     
%     % Number of samples in a slot
%     nSamplesPrSlot = (bwFftCp.fftSize + bwFftCp.cpSyms)*14 + nAddCpSamples*2;
    
    % Number of subcarriers
    nSubcarrier = bwFftCp.bwInPrbs*12;     
 
    % CP removal
    cpRmvedData = zeros(bwFftCp.fftSize, 14);
    count = 0;
    for symIdx = 1:14
        
        if (mod(14*slotIndex + symIdx - 1, 7*(2^numerology)) == 0)
            nCpSample = bwFftCp.cpSyms + nAddCpSamples;
            cpRmvedData(:, symIdx) = fftIn( count+nCpSample+1 : count+nCpSample+bwFftCp.fftSize );
            count = count + nCpSample + bwFftCp.fftSize;
            
        else
            nCpSample = bwFftCp.cpSyms;
            cpRmvedData(:, symIdx) = fftIn( count+nCpSample+1 : count+nCpSample+bwFftCp.fftSize );
            count = count + nCpSample + bwFftCp.fftSize;
        end
    end

    % FFT Operation
    fftOut = zeros(bwFftCp.fftSize, 14);
    for symIdx = 1:14
        fftOut(:,symIdx) = fftshift(fft(cpRmvedData(:,symIdx)),1);
    end
    
    % Zeros are padded both sides of the resource mapping output
    zerosPad = (bwFftCp.fftSize - nSubcarrier)/2;
    
    fftCpOut = fftOut(zerosPad+1 : zerosPad+nSubcarrier, :);
    
    
end % End of the function