function [rc_filtered_out] = raised_cosine_filter(spec_extended_output,N_dft,cp_length_spectrum_extension)
    rc_coeff=raised_cosine_window(N_dft,2*cp_length_spectrum_extension);
    rc_filtered_out=spec_extended_output.*rc_coeff;
        
end