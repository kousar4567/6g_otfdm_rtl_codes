
function shape = square_root_raised_cosine_window(dftsize,indExtfac)
            beta = 1/(100/indExtfac);
            M_modif = dftsize+ceil(dftsize*beta);
            Exs = (M_modif-dftsize)/2;
            shape = sqrt(raised_cosine_window(dftsize,2*Exs));
            os = 0;
            B = 0;
            L = 0;
end
