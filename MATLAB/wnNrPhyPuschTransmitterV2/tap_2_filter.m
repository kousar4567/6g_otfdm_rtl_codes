
function [filtered_out] = tap_2_filter(precoded_out,dftsize,numSymbols)
    tap_2_coeff=(tap_2(dftsize));
    filtered_out=precoded_out.*(repmat(tap_2_coeff,1,numSymbols));
        
end