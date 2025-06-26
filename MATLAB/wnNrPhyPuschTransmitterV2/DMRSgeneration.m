%% pusch dmrs sequnce generation function ,if the higher-layer parameter dmrs-UplinkTransformPrecoding-r16 is configured,
function [r]=DMRSgeneration(M,nscid,nidnscid,group_hopping,seq_hopping,nidrs,nsf,l,dmrs_UplinkTransformPrecoding_r16)
Nc=1600;
% RB=10;%number of resource block
% M=RB*12/2;
k=M+Nc;
symbperslot=14;
Nzc=89;%M=720
if dmrs_UplinkTransformPrecoding_r16
    cinit = mod(2^17*(symbperslot*nsf + l + 1)*(2*nidnscid + 1) + 2*nidnscid + nscid,2^31);
    %--------pseudo randomsequnce generator-----------
    c=pn(cinit,M);
    %-------------------pi/2 BPSK modulation:bit c(n) is mapped to complex-valued modulation symbol:-rptbpsk--r(pi/2 bpsk)
    for n=1:M
         rptbpsk(n)=(1/sqrt(2))*(exp(1i*(pi/2).*mod(n-1,2)).*((1-2*c(n))+1i*(1-2*c(n))));
    end    
    r=rptbpsk;
    %Low-PAPR sequence generation type 2:-rbuv-->rbar u,v
    % res=fft(rptbpsk,M)/sqrt(M);
    % for n=1:M
    %     temp=0;
    %     for m=1:M
    %         temp=temp+(rptbpsk(m)*exp((-j*(2*pi*(m-1)*(n-1)))/M));
    %     end
    %     r(n)=(1/sqrt(M))*temp;
    % end
else
    if group_hopping
            cinit=floor(nidrs/30);
            c=pn(cinit,8*(14*nsf+l)+8);
            fgh = mod(sum((2.^(0:7)').*c(8*(14*nsf+l)+1: 8*(14*nsf+l)+8)'),30);
            v=0;          
    elseif seq_hopping
             cinit=nidrs;
             c=pn(cinit,14*nsf+l+1);
             fgh=0;
             v=0;
            if M>=72
                v=c(14*nsf+l+1);
            end    
    else
             fgh=0;
             v=0;            
    end
            u=mod(fgh+nidrs,30);
            qbar=Nzc*(u+1)/31;
            q=floor(qbar+1/2)+(v*power(-1,floor(2*qbar)));
            for m=1:M
                xq(m)=exp((-j*pi*q*(m-1)*m)/Nzc);
            end
            for n=1:M
                temp=mod(n-1,Nzc);
                r(n)=xq(temp+1);
            end
end
end