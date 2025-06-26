%% CRC Generation and Attaching block Function 
% Inputs:
% input_bits = Input bits 
% crc_polynomial : It can be any one of these
% CRC24A = [1,1,0,0,0,0,1,1,0,0,1,0,0,1,1,0,0,1,1,1,1,1,0,1,1];
% CRC24B = [1,1,0,1,1,0,0,1,0,1,0,0,1,0,0,0,1,0,0,0,1,0,1,1,1];
% CRC16  = [1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1];

% Outputs:
% input_attached_crc: random number input with remainder
% remainder: Remainder after dividing with polynomial 

%%

function [input_attached_crc, remainder] = wnNrPhyCrcGenAttach(input_bits, ...
                                                               crc_polynomial)

% Polynomial Length
len_polynomial = size(crc_polynomial, 2);

crc_input = [input_bits, zeros(1, len_polynomial-1)];


len_input = size(crc_input, 2);
crc_input_size = len_input;
% CRC Generating
count_temp = 0;
% crc_temp = zeros(1,len_input);
while ((len_input - count_temp) >= len_polynomial)
    crc_input_s = crc_input(1:len_polynomial);
    remainder = mod((crc_input_s + crc_polynomial), 2); % Mod 2 operation with polynomial
    crc_input(1:len_polynomial) = remainder;
    
    j = 1; shft = 0;
%     crc_input;
%     remainder
    % If the remainder is zero than increase the counter and move ahead
    % with the next bit else divide again
    while (j <= len_polynomial)
        if(remainder(j) ~= 0)
            break;
        else
            shft = j;
            j = j + 1;
        end
    end
%     size(crc_input,2)
%     crc_input_size
    shft;
%     diff=len_input-count_temp;
%     if shft == 4
%         shft=3;
%     end
       
%     crc_temp = [];
    count_temp = count_temp + shft;
    if (crc_input_size - shft) <= (len_polynomial - 1)
        shft = crc_input_size - (len_polynomial - 1);
%         crc_input(1:shft) = []
        crc_temp = [crc_input(shft+1:length(crc_input)) zeros(1,shft)];
%         crc_input = crc_temp(1:len_input-shft);
        crc_input = crc_temp(1:len_input) ;
        crc_input_size = crc_input_size - shft;
%         crc_input = crc_input(shft+1:length(crc_input));

    else
%         crc_input(1:shft) = []
        
       crc_temp = [crc_input(shft+1:length(crc_input)) zeros(1,shft)];
        crc_input = crc_temp(1:len_input) ;
%         crc_input = crc_temp(1:len_input-shft);
        crc_input_size = crc_input_size - shft;
%         crc_input = crc_input(shft+1:length(crc_input));
    end
    
end

% remainder = crc_input;
% crc_input_size
% size(remainder)
% shft
remainder = crc_input(1:crc_input_size);
% remainder
input_attached_crc = [input_bits, remainder]; % CRC attaching 

% size(input_attached_crc)
end % End of the function













% 
% function [input_attached_crc, remainder] = wnNrPhyCrcGenAttach(input_bits, ...
%                                                                crc_polynomial)
% 
% % Polynomial Length
% len_polynomial = size(crc_polynomial, 2);
% 
% crc_input = [input_bits, zeros(1, len_polynomial-1)];
% 
% 
% len_input = size(crc_input, 2);
% 
% % CRC Generating
% count_temp = 0;
% while ((len_input - count_temp) >= len_polynomial)
%     crc_input_s = crc_input(1:len_polynomial);
%     remainder = mod((crc_input_s + crc_polynomial), 2); % Mod 2 operation with polynomial
%     crc_input(1:len_polynomial) = remainder;
%     remainder
%     j = 1; shft = 0;
%     
%     % If the remainder is zero than increase the counter and move ahead
%     % with the next bit else divide again
%     while (j <= len_polynomial)
%         if(remainder(j) ~= 0)
%             j
%             break;
%         else
%             shft = j;
%             j = j + 1;
%         end
%     end
%     shft
%     count_temp = count_temp + shft;
%     if (size(crc_input,2) - shft) <= (len_polynomial - 1)
%         size(crc_input,2)
%         shft = size(crc_input,2) - (len_polynomial - 1)
%         crc_input(1:shft) = [];size(crc_input,2)
%     else
%         crc_input(1:shft) = [];
%     end
%     
% end
% shft
% remainder = crc_input
% 
% input_attached_crc = [input_bits, remainder]; % CRC attaching 
% 
% end % End of the function
