
% Function for Rate Matching for NR-pusch

function [puschRatematchOut, puschRmLen,bit_select_out,start_pos_bit_select] = wnNrPhyPuschRateMatching(puschCodedBits, ...
                                                                    nPuschCbs, ...
                                                                    puschLdpcBaseGraph, ...
                                                                    modOrder, ...
                                                                    Zc_min, ...
                                                                    CBGTI, ...
                                                                    LbrmFbrmSelect, ...
                                                                    BWPSize,nNrOfLayers,nRV, ...
                                                                    PuschRatematchLen, ...
                                                                    filler_bit)
 
start_pos_bit_select = 0;
% LBRM is a higher layer parameter
if   LbrmFbrmSelect  == 1
    I_LBRM = 1;
else
    I_LBRM = 0;
end

R_LBRM = 2/3;

%----calculating size of the block------%
% Output length of data stream after LDPC Encoding according to 
% 5.3.2 in TS 38.212
N = length(puschCodedBits(1,:));

% TBS_LBRM calculation
[TBS_LBRM] = wnNrPhyPuschTbsLbrm(BWPSize);

if I_LBRM == 0
    N_cb = N;
else
    N_ref = floor(TBS_LBRM/(nPuschCbs*R_LBRM));
     N_cb = min(N,N_ref);
end


%%%%%%%% Rate match output length calculations %%%%%%%%

puschRmLen = zeros(1,nPuschCbs);

% C_prime = pusch_total_code_blocks if CBGTI is not present in 
% the DCI scheduling the transport block and C_prime is the number
% of scheduled code blocks of the transport block 
% if CBGTI is present in the DCI scheduling the transport block
if CBGTI == 0
    C_prime = nPuschCbs;

    j = 0;
    for code_block_index = 1:1:nPuschCbs
        
        % if the r -th coded block is not for transmission as 
        % indicated by CBGTI according to Subclause X.X in [6, TS38.214]
        if (0)
            pusch_rm_len(code_block_index) = 0;
        else
            if (j <= C_prime - mod(PuschRatematchLen/(nNrOfLayers*modOrder), C_prime) - 1)
                puschRmLen(code_block_index) = (nNrOfLayers*modOrder) ...
                                                  *floor(PuschRatematchLen/(nNrOfLayers*modOrder*C_prime));
            else
                puschRmLen(code_block_index) = (nNrOfLayers*modOrder) ...
                                                  *ceil(PuschRatematchLen/(nNrOfLayers*modOrder*C_prime));
            end
            j = j + 1;
        end
    
    end
else %//have to add if CBGTI is present in DCI Scheduling the transport block

    %     Number of scheduled code blocks in the DL-DCI
    
end


%%%%%%%% Starting position calculation for bit selection depending on rv_id got in downlink DCI %%%%%%%%

% According TS 38.212 release 15 :  Table 5.4.2.1-2

% if redundancy version is 0
switch (nRV)
    case (0)
        switch (puschLdpcBaseGraph)
            case (1)
            start_pos_bit_select = 0;
            case (2)
            start_pos_bit_select = 0;
        end

% if redundancy version is 1
    case (1)
        switch (puschLdpcBaseGraph)
            case (1)
                start_pos_bit_select = Zc_min * floor((17*N_cb)/(66*Zc_min));
            case (2)
                start_pos_bit_select = Zc_min * floor((13*N_cb)/(50*Zc_min));
        end

% if redundancy version is 2
    case (2)
        switch (puschLdpcBaseGraph)
            case (1)
                start_pos_bit_select = Zc_min * floor((33*N_cb)/(66*Zc_min));
            case (2)
                start_pos_bit_select = Zc_min * floor((25*N_cb)/(50*Zc_min));
        end


% if redundancy version is 3
    case (3)
        switch (puschLdpcBaseGraph)
            case (1)
                start_pos_bit_select = Zc_min * floor((56*N_cb)/(66*Zc_min));
            case (2)
                start_pos_bit_select = Zc_min * floor((43*N_cb)/(50*Zc_min));
        end
    
end


%%%%%%%% Bit selection %%%%%%%%

index01 = 1;
index02 = 0;

bit_select_out = zeros(nPuschCbs, max(puschRmLen));

% Each code block was filled with 'filler bits' (here -2)

for code_block_index = 1:1:nPuschCbs
    while (index01 <=  puschRmLen(code_block_index))
        if (puschCodedBits(code_block_index, mod((start_pos_bit_select+index02),N_cb)+1) ~= filler_bit)
            bit_select_out(code_block_index,index01) = ...
                puschCodedBits(code_block_index, mod((start_pos_bit_select+index02),N_cb)+1);

            index01 = index01 + 1;
        end
        index02 = index02 + 1;
    end
    index01 = 1;
    index02 = 0;
end

%%%%%%%% Bit Interleaving %%%%%%%%

puschRatematchOut = zeros(nPuschCbs,puschRmLen(code_block_index));%/modOrder);
% size(puschRatematchOut)
% puschRmLen
for code_block_index = 1:1:nPuschCbs
    for index01 = 1:1:puschRmLen(code_block_index)/modOrder
        for index02 = 1:1:modOrder
%             temp = bit_select_out(code_block_index, (index02-1)*(pusch_rm_len(code_block_index)/Q_m) + index01)
            puschRatematchOut(code_block_index, index02+(index01-1)*modOrder) = ...
                bit_select_out(code_block_index, (index02-1)*(puschRmLen(code_block_index)/modOrder) + index01);
        end
         
    end
end
% size(puschRatematchOut)
end % End of function



