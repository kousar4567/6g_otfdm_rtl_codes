%%%%%% Common Function for 5G NR DL Modulation Techniques %%%%%%%%

%% 38.211 (Release 15) Section 5.1

%%%%%%%%% Modulation type mapping %%%%%%%%%%%%
% modulation_type = 1 => BPSK                %
% modulation_type = 2 => QPSK         1       %
% modulation_type = 4 => 16-QAM      2        %
% modulation_type = 6 => 64-QAM       3       %
% modulation_type = 8 => 256-QAM     4        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ mod_out ] = wnNrPhyModulation(mod_inp, ...     % Input data to be modulated
                                         inp_len, ...     % Length of the input stream
                                         modulation_type) % Type of the modulation

    % Size of modulation output
    mod_size = length(mod_inp)/modulation_type;

    % Initializing modulation output variable
    p = 0+0i;
    mod_out = zeros(1,mod_size,'like',p);

    % BPSK Modulation
    switch (modulation_type)
        case (1)

        for j = 1:length(mod_out)
            mod_out(j) = exp(1i * pi / 2 * mod(j-1, 2))*(1/sqrt(2)) * (1+1i)*(1-2*mod_inp(j));
        end

    % QPSK Modulation
        case (2)

         k=1;
        for j = 1:2:length(mod_inp)
            mod_out(k) = (1/sqrt(2)) * ((1-2*mod_inp(j))+ 1i*(1-2*mod_inp(j+1)));
            k=k+1;
        end

    % 16QAM Modulation
        case (4)
        
        k=1;
        for j = 1:4:length(mod_inp)
            mod_out(k) = (1/sqrt(10)) * ( (1-2*mod_inp(j)) .* (2 - (1-2*mod_inp(j+2))) ...
                                 + 1i*(1-2*mod_inp(j+1)) .* (2 - (1-2*mod_inp(j+3))));
            k=k+1;
        end
    

    % 64QAM Modulation
        case (6)         

        k=1;
        for j = 1:6:length(mod_inp)
            re_part =  (1-2*mod_inp(j)) .* (4 - (1-2*mod_inp(j+2)) ...
                                     .* (2 - (1-2*mod_inp(j+4))));
            im_part =  (1-2*mod_inp(j+1)) .* (4 - (1-2*mod_inp(j+3)) ...
                                     .* (2 - (1-2*mod_inp(j+5))));
            mod_out(k) = (1/sqrt(42)) * (re_part + 1i*im_part);
            k=k+1;
        end

    
    % 256QAM Modulation
        case (8)

        k=1;
        for j = 1:8:length(mod_inp)
            re_part =  (1-2*mod_inp(j)) .* (8 - (1-2*mod_inp(j+2)) .* ...
                  (4 - (1-2*mod_inp(j+4)) .* (2 - (1-2*mod_inp(j+6)))));

            im_part =  (1-2*mod_inp(j+1)) .* (8 - (1-2*mod_inp(j+3)) .* ...
                  (4 - (1-2*mod_inp(j+5)) .* (2 - (1-2*mod_inp(j+7))))); 

            mod_out(k) = (1/sqrt(170)) * (re_part + 1i*im_part);

            k=k+1;
        end
        
        case 0
        
        fprintf('ERROR : NR_Modulation :: Modulation not supported\n');
        
        
    end


end





