function [r_n] = wnNrPhyPuschScfdmaDmrs(NrUlUlschPDUs,gh,sh,symindx,dmrsseqleng)

load phi.mat phi
load Phi2.mat phi2

delta = 1;
N_sc  = dmrsseqleng;
M_zc  = N_sc;

if gh == 0 && sh == 0
    f_gh = 0;
    v    = 0;
elseif gh ~= 0 && sh == 0
    c_init = floor(NrUlUlschPDUs.NIdRS/30);
%     generate pn sequence???
    temp  = 0;
    len   = 8*(NrUlUlschPDUs.NSymbSlot*NrUlUlschPDUs.SlotNumber+symindx)+8;
    pnseq = wnNrPhyPnSeq(c_init,len);
    for ii = 1:8
        temp = temp+(2^ii)*pnseq(8*(NrUlUlschPDUs.NSymbSlot*NrUlUlschPDUs.SlotNumber+symindx)+ii);
    end
    f_gh = mod(temp,30);
    v    = 0;
elseif gh == 0 && sh ~= 0
    f_gh = 0;
    
%     generate pn sequence??
    if NrUlUlschPDUs.nPrbAllocated >= 5
       c_init = NrUlUlschPDUs.NIdRS;
          len = NrUlUlschPDUs.NSymbSlot*NrUlUlschPDUs.SlotNumber+symindx;
        pnseq = wnNrPhyPnSeq(c_init,len);
            v = pnseq(NrUlUlschPDUs.NSymbSlot*NrUlUlschPDUs.SlotNumber+symindx);
    else
        v = 0;
    end
end

u = mod((f_gh+NrUlUlschPDUs.NIdRS),30);
  
if ceil(NrUlUlschPDUs.nDMRSpSymb/6)>0
         N_zc = max(primes(M_zc));
        q_bar = N_sc*(u+1)/31;
            q = floor(q_bar+0.5)+v*(-1)^(floor(2*q_bar));
            m = 0:(N_zc-1);
    r_bar_u_n = exp(-1j.*pi.*q.*m.*(m+1)/N_zc);
     r_n(:,1) = r_bar_u_n(mod((0:M_zc-1),N_zc)+1); 
elseif ceil(NrUlUlschPDUs.nDMRSpSymb/6) <5
    if NrUlUlschPDUs.nDMRSpSymb >5
%         r_bar_u_n = exp(1i*phi(NrUlUlschPDUs.nDMRSpSymb/6).data(u+1,2:end)*pi/4);
        r_bar_u_n = (sqrt(0.5)*(1+1i))*exp(1i*pi*(mod(0:NrUlUlschPDUs.nDMRSpSymb-1,2))/2).*(1-2*phi2{NrUlUlschPDUs.nDMRSpSymb/6}(u+1,1:end));
%         r_n(:,1) = ifft(r_bar_u_n)*sqrt(length(r_bar_u_n));
        r_n(:,1) = (r_bar_u_n);

    elseif NrUlUlschPDUs.nDMRSpSymb == 1
        r_n(:,1) = (1+1i)/sqrt(2);
    elseif NrUlUlschPDUs.nDMRSpSymb == 2
        r_n(:,1) = [(1+1i)/sqrt(2) (1-1i)/sqrt(2)];
    elseif NrUlUlschPDUs.nDMRSpSymb == 3
        r_n(:,1) = [(1+1i)/sqrt(2) (1-1i)/sqrt(2) (-1-1i)/sqrt(2)];
    elseif NrUlUlschPDUs.nDMRSpSymb == 4
        r_n(:,1) = [(1+1i)/sqrt(2) (1-1i)/sqrt(2) (-1-1i)/sqrt(2) (-1+1i)/sqrt(2)];
    end
else
    r_n(:,1) = exp(-1i*(u+1)*((0:M_zc-1)+1).*((0:M_zc-1)+2)/31);    
end
%     load Huawei_6
% temp=huawei_6_comb1(1,:);
% temp1=exp(1i*pi/8*temp);
% temp3=1/sqrt(length(temp1))*fft(temp1);
% r_n = temp3;