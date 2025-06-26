function [shape]=tx_rx_filter(Rxshaping,Txshaping,Filt,indExtfac,dftsize)
if Rxshaping == 1 || Txshaping == 1
    switch Filt
        case 'RC'
            %% sqrt raised cosine pulse
            beta = 1/(100/indExtfac);
            M_modif1 = dftsize+dftsize*beta+2;
            for k=1:dftsize*(1-beta)/2
                Fsqrc(k)=1;
            end;
            fd=1/dftsize;
            q=(1-beta)/2;
            for k=dftsize*(1-beta)/2+1:dftsize*(1+beta)/2+1
                k = round(k);  %%% remove
                Fsqrc(k)=(0.5*(1+cos((pi/beta)*((k-1)*fd-q))));
            end
            shape1(:,1)=[fliplr(Fsqrc) Fsqrc];
            Exs1 = (M_modif1-dftsize)/2;
            M_modif = M_modif1-2;
            shape = shape1(2:end-1);
            shape_noexs = [shape(Exs1:dftsize+Exs1-1,:)] + [zeros(dftsize-Exs1,1) ;shape(1:Exs1,:)] + [shape(dftsize+2*Exs1-2-(Exs1-2:-1:0),:);zeros(dftsize-Exs1+1,1) ];

            Exs = Exs1-1;
            os = 0;
            B = 0;
            L = 0;
        case 'SQRC'
            %% sqrt raised cosine pulse
            beta = 1/(100/indExtfac);
            M_modif = dftsize+ceil(dftsize*beta);
            Exs = (M_modif-dftsize)/2;
            shape = sqrt(raised_cosine_window(dftsize,2*Exs));
            os = 0;
            B = 0;
            L = 0;
        case '2tap'
            Exs = 0;
            Filttap = [1 ;1]/sqrt(2);
            shape = 0+fftshift(fft(Filttap,12*NrUlUlschPDUs.nPrbAllocated+2*Exs));
            M_modif = 12*NrUlUlschPDUs.nPrbAllocated+2*Exs;
            beta = 0;
            os = 0;
            B = 0;
            L = 0;
        case '3tap'
            Exs = 0;
            Filttap = [-0.28; 1;-0.28]/sqrt((0.28^2+1+0.28^2));
            shape = fftshift(fft(Filttap,12*NrUlUlschPDUs.nPrbAllocated+2*Exs));
            M_modif = 12*NrUlUlschPDUs.nPrbAllocated+2*Exs;
            beta = 0;
            os = 0;
            B = 0;
            L = 0;

        case '2tap_gmsk'
            Exs = 30;
            Filttap = [zeros(1,1); 1 ;1]/sqrt(2);
            shape = fftshift(fft(Filttap,12*NrUlUlschPDUs.nPrbAllocated+2*Exs));
            M_modif = 12*NrUlUlschPDUs.nPrbAllocated+2*Exs;
            beta = 0;
            os = 0;
            B = 0;
            L = 0;
        case '3tap_gmsk'
            Exs = 30;
            Filttap = [0;0.2596;0.93;0.2596;0];
            shape = fftshift(fft(Filttap,12*NrUlUlschPDUs.nPrbAllocated+2*Exs));
            M_modif = 12*NrUlUlschPDUs.nPrbAllocated+2*Exs;
            beta = 0;
            os = 0;
            B = 0;
            L = 0;
        case 'GMSK'
            os=2;
            B=0.3;
            L=3;
            offset=0.0; %offset 0 is no sampling time offset, 0.5 is equal to T/2 offset
            xxp3=lgmskPulse(os,B,L, offset);
            Filttap = xxp3.'/sqrt(xxp3*xxp3');
            Exs = 30;
            shape = fftshift(fft(Filttap,12*NrUlUlschPDUs.nPrbAllocated+2*Exs));
            M_modif = 12*NrUlUlschPDUs.nPrbAllocated+2*Exs;
            beta = 0;

        case  'SQRC_fold'
            %% sqrt raised cosine pulse
            beta = 1/10;
            M_modif1 = dftsize+dftsize*beta+2;
            for k=1:dftsize*(1-beta)/2
                Fsqrc(k)=1;
            end;
            fd=1/dftsize;
            q=(1-beta)/2;
            for k=dftsize*(1-beta)/2+1:dftsize*(1+beta)/2+1
                k = round(k);  %%% remove
                Fsqrc(k)=sqrt(0.5*(1+cos((pi/beta)*((k-1)*fd-q))));
            end
            shape1(:,1)=[fliplr(Fsqrc) Fsqrc];
            Exs1 = (M_modif1-dftsize)/2;

            shape_Exs = shape1(2:end-1);
            Exs = Exs1-1;
            shape = [shape_Exs(Exs+1:12*NrUlUlschPDUs.nPrbAllocated+Exs,:)]...
                + [zeros(12*NrUlUlschPDUs.nPrbAllocated-Exs,1) ;shape_Exs(1:Exs,:,:)]...
                + [shape_Exs(12*NrUlUlschPDUs.nPrbAllocated+2*Exs-(Exs-1:-1:0),:);zeros(12*NrUlUlschPDUs.nPrbAllocated-Exs,1) ];
            M_modif = dftsize;
            Exs = 0;
            os = 0;
            B = 0;
            L = 0;

    end
else
    Exs = 0;
    M_modif = dftsize;
    M_modif1 = dftsize;
    shape = 1;
    beta = 0;
end
