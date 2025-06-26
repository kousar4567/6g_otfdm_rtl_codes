% Layer Mapping
%  it takes modualted symbols as input and map to the specified layers

% Inputs: Number of Layers (v)  - Scalar
%         Modulated Symbols (d) - Vector of some length
% Upto 4 layers is supported in uplink means from table 7.3.1.2-1
% Number of supported code words is '1'.

% Output: Modulated Symbols for the layers specified

function [llrInput] = wnNrPhyPuschLayerDemapper_updt(equalizedData, nLayers,modOrder)

      inpSeqLen = size(equalizedData, 2)/modOrder;

      % layer_mapping_outdata = zeros(v,length_inp_seq/v);
      count = 0;
      for ii = 0:(inpSeqLen)-1
        for ind_layer = 0:nLayers-1
            llrInput(modOrder*count+1:modOrder*(count+1)) = ...
                    equalizedData(ind_layer+1,modOrder*ii+1:modOrder*(ii+1));
                count = count+1;
        end 
      end 
end