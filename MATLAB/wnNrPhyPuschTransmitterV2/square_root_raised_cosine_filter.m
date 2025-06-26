

function [sqrc_filtered_out] = square_root_raised_cosine_filter(spec_extended_output,dftsize,indExtfac,numSymbols)
    sqrc_coeff=(square_root_raised_cosine_window(dftsize,indExtfac));
    y=transpose(repmat(sqrc_coeff,1,numSymbols));
    sqrc_filtered_out=spec_extended_output.*y;
    %% @karthik added
    q_factor = 2^14;
    sqrc_coeff_q2_14 = round(sqrc_coeff * q_factor);

    % Convert to binary and ensure 16-bit representation
    bin_values = cell(size(sqrc_coeff_q2_14));
    for i = 1:length(sqrc_coeff_q2_14)
        % Convert each value to a 16-bit binary string, handling negative values
        if sqrc_coeff_q2_14(i) < 0
            % For negative numbers, convert to signed 16-bit two's complement
            bin_values{i} = transpose(dec2bin(typecast(int16(sqrc_coeff_q2_14(i)), 'uint16'), 16));
        else
            % For positive numbers, convert directly to 16-bit binary
            bin_values{i} = transpose(dec2bin(sqrc_coeff_q2_14(i), 16));
        end
    end

    % Save binary values to file
    % fid = fopen(filename, 'w');
    % for i = 1:length(bin_values)
    %     fprintf(fid, '%s\n', bin_values{i});
    % end
    % fclose(fid);    
end