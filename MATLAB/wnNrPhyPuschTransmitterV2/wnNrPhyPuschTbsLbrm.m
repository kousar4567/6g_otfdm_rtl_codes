% calculation of TBS_LBRM

function [TBS_LBRM] = wnNrPhyPuschTbsLbrm(nBWPSize)

% if max number of layers is specified by upper layers take N_max_layers
% specified by higher layers
% Check it once again
N_L_max = 2;

% if max modulation order is specified by upper layers take N_max_layers
% specified by higher layers
% Check it once again
Q_m_max = 6;

% max coding rate
R_max = 948/1024;

% calculating n_PRB_LBRM from table 5.4.2.1-1
if (nBWPSize < 33)
    n_PRB_LBRM = 32;
elseif (33 <= nBWPSize && nBWPSize <= 66)
    n_PRB_LBRM = 66;
elseif (67 <= nBWPSize && nBWPSize<= 107)
    n_PRB_LBRM = 107;
elseif (108 <= nBWPSize && nBWPSize<= 135)
    n_PRB_LBRM = 135;
elseif (136 <= nBWPSize && nBWPSize<= 162)
    n_PRB_LBRM = 162;
elseif (163 <= nBWPSize && nBWPSize<= 217)
    n_PRB_LBRM = 217;
elseif 217 < nBWPSize
    n_PRB_LBRM = 273;
end

% Calculate N_RE
  N_RE = 156 * n_PRB_LBRM;
N_info = N_RE * R_max * Q_m_max * N_L_max ;

if N_info <= 3824
%         use step 3 for calculation of TBS
                      n = max(3,floor(log2(N_info))-6);
           N_info_prime = max(24,2^n * floor(N_info/(2^n)));
%            N_info_prime = 2000;
    TBS_N_info_Less3824 = [24,32,40,48,56,64,72,80,88,96,104,112,120,128,136,144,152,160,168,176,184,...
                           192,208,224,240,256,272,288,304,320,336,352,368,384,408,432,456,480,504,528,...
                           552,576,608,640,672,704,736,768,808,848,888,928,984,1032,1064,1128,1160,1192,...
                           1224,1256,1288,1320,1352,1416,1480,1544,1608,1672,1736,1800,1864,1928,2024,2088,...
                           2152,2216,2280,2408,2472,2536,2600,2664,2728,2792,2856,2976,3104,3240,3368,3496,...
                           3624,3752,3824];

                   temp = (N_info_prime-TBS_N_info_Less3824)<0;

                    TBS_LBRM = TBS_N_info_Less3824(min(find(temp>0)));    

else 
%         use step 4 for calculation of TBS
               n = floor(log2(N_info-24))-5;
    N_info_prime = (2^n)*round((N_info-24)/(2^n));

        if N_info_prime > 8424
            C = ceil((N_info_prime+24)/(8424));
          TBS_LBRM = 8*C*ceil((N_info_prime+24)/(8*C));
        end
        
end