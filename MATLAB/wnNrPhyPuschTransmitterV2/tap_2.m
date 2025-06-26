 function shape = tap_2(size)
            Filttap = [1 ;-1]/sqrt(2);
            shape = (fft(Filttap,size));
 end