%%%%%%%% Bit De-Interleaving %%%%%%%%


function [deInterleavedOut] = wnNrPhyPuschDeinterleaver(cbIdx, ...
                                                        modOrder, ...
                                                        puschCbDeConcatOut, ...
                                                        puschRmlen)


for index01 = 1:1:puschRmlen(cbIdx)/modOrder
   for index02 = 1:1:modOrder
       deInterleavedOut((index02-1)*(puschRmlen(cbIdx)/modOrder) + index01,1) ...
                    = puschCbDeConcatOut(index02+(index01-1)*modOrder, cbIdx);
   end

end

end % End of the function
