
% Function for Code Block Concatenation for NR-PUSCH

function [pusch_cb_concat_out] = wnNrPhyPuschCbConCat(pusch_ratematch_out, pusch_rm_len, nPuschCodeBlks)

pusch_cb_concat_out = zeros(1,sum(pusch_rm_len));

index01 = 1;
index03 = 1;

while index01 <= nPuschCodeBlks
    index02 = 1;
    
    while index02 <= pusch_rm_len(index01)
        pusch_cb_concat_out(1,index03) = pusch_ratematch_out(index01, index02);
        index03 = index03 + 1;
        index02 = index02 + 1;
    end
    index01 = index01 + 1;
end

end
