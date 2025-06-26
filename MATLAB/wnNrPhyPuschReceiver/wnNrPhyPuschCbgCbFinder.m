

function [reTxedCbgsCbs] = wnNrPhyPuschCbgCbFinder(puschCbgs, ...
                                                   cbgTransmitInfo, ...
                                                   maxCbsPerTbs)
                                                             

nCbgReTransmitted = sum(cbgTransmitInfo);

idx = 1;
for cbgIdx = 1:1:maxCbsPerTbs
    if(cbgTransmitInfo(cbgIdx) == 1)
        cbgArray(idx) = cbgIdx;
        idx = idx + 1;
    end
end

cbCount = 1;
for cbgIdx = 1:1:nCbgReTransmitted
   for cbIdx = 1:1:puschCbgs(cbgArray(cbgIdx)).len
       reTxedCbgsCbs(cbCount).cbg = cbgArray(cbgIdx);
       reTxedCbgsCbs(cbCount).cb  = cbIdx;
       cbCount = cbCount + 1;
   end
end



end % End of the function