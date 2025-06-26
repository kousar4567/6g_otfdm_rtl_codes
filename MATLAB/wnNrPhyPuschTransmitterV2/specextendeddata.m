
function [spec_extended_output] = specextendeddata(m_point_dft_out_samples,cp_length_spectrum_extension,N_dft)
        temp=horzcat(m_point_dft_out_samples(N_dft-cp_length_spectrum_extension+1:end),m_point_dft_out_samples);
        spec_extended_output=horzcat(temp,m_point_dft_out_samples(1:cp_length_spectrum_extension));
    %spec_extended_output=[m_point_dft_out_samples(N_dft-cp_length_spectrum_extension+1:end),m_point_dft_out_samples,m_point_dft_out_samples(1:cp_length_spectrum_extension)];
end