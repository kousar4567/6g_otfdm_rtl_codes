

function bwFftCp = nrBwFftCpConfig(nrOperatingFreqBand,... % Operating Band FR1 vs FR2
                                   subcarSpacing, ...      % Subcarrier spacing
                                   maxTxBwInMHz)           % Max. frequency in MHz

    if (nrOperatingFreqBand == 0)         % When the Frequency band is FR1
        if subcarSpacing == 0             % 15 kHz Subcarrier spacing 
            if maxTxBwInMHz == 5
                bwFftCp.bwInPrbs = 25;
                bwFftCp.fftSize = 512;
                bwFftCp.cpSyms = 36;
            elseif maxTxBwInMHz == 10
                bwFftCp.bwInPrbs = 52;
                bwFftCp.fftSize = 1024;
                bwFftCp.cpSyms = 72;
            elseif maxTxBwInMHz == 15
                bwFftCp.bwInPrbs = 79;
                bwFftCp.fftSize = 1536;
                bwFftCp.cpSyms = 108;
            elseif maxTxBwInMHz == 20
                bwFftCp.bwInPrbs = 106;
                bwFftCp.fftSize = 2048;
                bwFftCp.cpSyms = 144;
            elseif maxTxBwInMHz == 25
                bwFftCp.bwInPrbs = 133;
                bwFftCp.fftSize = 2048;
                bwFftCp.cpSyms = 144;
            elseif maxTxBwInMHz == 30
                bwFftCp.bwInPrbs = 160;
                bwFftCp.fftSize = 3072;
                bwFftCp.cpSyms = 216;
            elseif maxTxBwInMHz == 40
                bwFftCp.bwInPrbs = 216;
                bwFftCp.fftSize = 4096;
                bwFftCp.cpSyms = 288;
            elseif maxTxBwInMHz == 50
                bwFftCp.bwInPrbs = 270;
                bwFftCp.fftSize = 4096;
                bwFftCp.cpSyms = 288;
            else
                fprintf('Allocated bandwidth is not supported for this configuration');
            end
        elseif subcarSpacing == 1          % 30 kHz Subcarrier spacing
            if maxTxBwInMHz == 5
                bwFftCp.bwInPrbs = 11;
                bwFftCp.fftSize = 256;
                bwFftCp.cpSyms = 18;
            elseif maxTxBwInMHz == 10
                bwFftCp.bwInPrbs = 24;
                bwFftCp.fftSize = 512;
                bwFftCp.cpSyms = 36;
            elseif maxTxBwInMHz == 15
                bwFftCp.bwInPrbs = 38;
                bwFftCp.fftSize = 768;
                bwFftCp.cpSyms = 54;
            elseif maxTxBwInMHz == 20
                bwFftCp.bwInPrbs = 51;
                bwFftCp.fftSize = 1024;
                bwFftCp.cpSyms = 72;
            elseif maxTxBwInMHz == 25
                bwFftCp.bwInPrbs = 65;
                bwFftCp.fftSize = 1024;
                bwFftCp.cpSyms = 72;
            elseif maxTxBwInMHz == 30
                bwFftCp.bwInPrbs = 78;
                bwFftCp.fftSize = 1536;
                bwFftCp.cpSyms = 108;
            elseif maxTxBwInMHz == 40
                bwFftCp.bwInPrbs = 106;
                bwFftCp.fftSize = 2048;
                bwFftCp.cpSyms = 144;
            elseif maxTxBwInMHz == 50
                bwFftCp.bwInPrbs = 133;
                bwFftCp.fftSize = 2048;
                bwFftCp.cpSyms = 144;
            elseif maxTxBwInMHz == 60
                bwFftCp.bwInPrbs = 162;
                bwFftCp.fftSize = 3072;
                bwFftCp.cpSyms = 216;
            elseif maxTxBwInMHz == 80
                bwFftCp.bwInPrbs = 217;
                bwFftCp.fftSize = 4096;
                bwFftCp.cpSyms = 288;
            elseif maxTxBwInMHz == 90
                bwFftCp.bwInPrbs = 245;
                bwFftCp.fftSize = 4096;
                bwFftCp.cpSyms = 288;
            elseif maxTxBwInMHz == 100
                bwFftCp.bwInPrbs = 273;
                bwFftCp.fftSize = 4096;
                bwFftCp.cpSyms = 288;
            else
                fprintf('Allocated bandwidth is not supported for this configuration');
            end
        elseif subcarSpacing == 2          % 60 kHz Subcarrier spacing
            if maxTxBwInMHz == 10
                bwFftCp.bwInPrbs = 11;
                bwFftCp.fftSize = 256;
                bwFftCp.cpSyms = 18;
            elseif maxTxBwInMHz == 15
                bwFftCp.bwInPrbs = 18;
                bwFftCp.fftSize = 384;
                bwFftCp.cpSyms = 27;
            elseif maxTxBwInMHz == 20
                bwFftCp.bwInPrbs = 24;
                bwFftCp.fftSize = 512;
                bwFftCp.cpSyms = 36;
            elseif maxTxBwInMHz == 25
                bwFftCp.bwInPrbs = 31;
                bwFftCp.fftSize = 512;
                bwFftCp.cpSyms = 36;
            elseif maxTxBwInMHz == 30
                bwFftCp.bwInPrbs = 38;
                bwFftCp.fftSize = 768;
                bwFftCp.cpSyms = 54;
            elseif maxTxBwInMHz == 40
                bwFftCp.bwInPrbs = 51;
                bwFftCp.fftSize = 1024;
                bwFftCp.cpSyms = 72;
            elseif maxTxBwInMHz == 50
                bwFftCp.bwInPrbs = 65;
                bwFftCp.fftSize = 1024;
                bwFftCp.cpSyms = 72;
            elseif maxTxBwInMHz == 60
                bwFftCp.bwInPrbs = 79;
                bwFftCp.fftSize = 1536;
                bwFftCp.cpSyms = 108;
            elseif maxTxBwInMHz == 80
                bwFftCp.bwInPrbs = 107;
                bwFftCp.fftSize = 2048;
                bwFftCp.cpSyms = 144;
            elseif maxTxBwInMHz == 90
                bwFftCp.bwInPrbs = 121;
                bwFftCp.fftSize = 2048;
                bwFftCp.cpSyms = 144;
            elseif maxTxBwInMHz == 100
                bwFftCp.bwInPrbs = 135;
                bwFftCp.fftSize = 2048;
                bwFftCp.cpSyms = 144;
            else
                fprintf('Allocated bandwidth is not supported for this configuration');
            end
        end

    elseif (nrOperatingFreqBand == 1)      % When the Frequency band is FR2
        if subcarSpacing == 2              % 60 kHz Subcarrier spacing 
            if maxTxBwInMHz == 50
                bwFftCp.bwInPrbs = 66;
                bwFftCp.fftSize = 1024;
                bwFftCp.cpSyms = 72;
            elseif maxTxBwInMHz == 100
                bwFftCp.bwInPrbs = 132;
                bwFftCp.fftSize = 2048;
                bwFftCp.cpSyms = 144;
            elseif maxTxBwInMHz == 200
                bwFftCp.bwInPrbs = 264;
                bwFftCp.fftSize = 4096;
                bwFftCp.cpSyms = 288;
            else
                fprintf('Allocated bandwidth is not supported for this configuration');
            end
        elseif subcarSpacing == 3          % 120 kHz Subcarrier spacing
            if maxTxBwInMHz == 50
                bwFftCp.bwInPrbs = 32;
                bwFftCp.fftSize = 512;
                bwFftCp.cpSyms = 36;
            elseif maxTxBwInMHz == 100
                bwFftCp.bwInPrbs = 66;
                bwFftCp.fftSize = 1024;
                bwFftCp.cpSyms = 72;
            elseif maxTxBwInMHz == 200
                bwFftCp.bwInPrbs = 132;
                bwFftCp.fftSize = 2048;
                bwFftCp.cpSyms = 144;
            elseif maxTxBwInMHz == 400
                bwFftCp.bwInPrbs = 264;
                bwFftCp.fftSize = 4096;
                bwFftCp.cpSyms = 288;
            else
                fprintf('Allocated bandwidth is not supported for this configuration');
            end
        end
    end
end