%%
% Copyright (c) 2016-2018, WiSig Networks Pvt Ltd. All rights reserved.
% www.wisig.com
% 
% All information contained herein is property of WiSig Networks Pvt Ltd. 
% unless otherwise explicitly mentioned.
% 
% The intellectual and technical concepts in this file are proprietary 
% to WiSig Networks and may be covered by granted or in process national
% and international patents and are protect by trade secrets and       
% copyright law.
% 
% Redistribution and use in source and binary forms of the content in  
% this file, with or without modification are not permitted unless     
% permission is explicitly granted by WiSig Networks.                   
% If WiSig Networks permits this source code to be used as a part of 
% open source project, the terms and conditions of CC-By-ND (No Derivative) license
% (https://creativecommons.org/licenses/by-nd/4.0/legalcode) shall apply.

%function [nr_pn_seq] = wnNrPhyPuschDmrsSeqGen(NrUlUlschPDUs, sym_number, length_dmrs)
%%%%%%%%%%%%%%% Base sequence genration for PUSCH DMRS %%%%%%%%%%%%%%%

% % getting the NIDSCID depending on n_SCID
% if NrUlUlschPDUs.nSCID == 0
%     nNIDnSCID = NrUlUlschPDUs.nNIDnSCID0;
% elseif NrUlUlschPDUs.nSCID == 1
%     nNIDnSCID = NrUlUlschPDUs.nNIDnSCID1;
% end
% 
% % slot number
% ns = NrUlUlschPDUs.slotNum;
% 
% % NR cell id
% nr_cell_id = nNIDnSCID;
% 
% % higher-layer parameter UL-DMRS-Scrambling-ID
% % if provided by higher layer use that
% % otherwise use below
% 
% n_id_scid = nr_cell_id;
% 
% % PN sequence length
% pn_seq_len = length_dmrs;
% 
% Cinit = mod(((2^17)*(NrUlUlschPDUs.nSymsPrSlot*ns + sym_number + 1)*(2*n_id_scid + 1) + 2*n_id_scid + NrUlUlschPDUs.nSCID), 2^31); 
% 
% % PN sequence generation function
% [nr_pn_seq] = wnNrPhyPnSeq(Cinit, pn_seq_len);
% 
% % % DMRS for PUSCH
% % nr_pdsch_dmrs_data = zeros(length_dmrs,1);
% % for index01 = 1:1:pn_seq_len/2
% %     nr_pdsch_dmrs_data(index01,1) = 0.707*(1 - 2*nr_pn_seq(2*index01-1)) + 1i*0.707*(1 - 2*nr_pn_seq(2*index01));
% % end
% % dmrs = nr_pdsch_dmrs_data;
%% pusch dmrs sequnce generation function ,if the higher-layer parameter dmrs-UplinkTransformPrecoding-r16 is configured,
function [r]=wnNrPhyPuschDmrsSeqGen(M,nscid,nidnscid,group_hopping,seq_hopping,nidrs,nsf,l,dmrs_UplinkTransformPrecoding_r16)
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
    %Low-PAPR sequence generation type 2:-rbuv-->rbar u,v
    r=rptbpsk;
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