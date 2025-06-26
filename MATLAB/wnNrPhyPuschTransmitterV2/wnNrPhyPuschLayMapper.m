% Layer Mapping
%  it takes modualted symbols as input and map to the specified layers

% Inputs: Number of Layers (v)  - Scalar
%         Modulated Symbols (d) - Vector of some length
% Upto 4 layers is supported in uplink means from table 7.3.1.2-1
% Number of supported code words is '1'.

% Output: Modulated Symbols for the layers specified


function [layer_mapping_outdata] = wnNrPhyPuschLayMapper(Modulation_outdata, nNrOfLayers)

    % Layer Mapping output size
    layer_mapping_length = length(Modulation_outdata)/nNrOfLayers;

    % Initializing Output data
    p=0+0i;
    layer_mapping_outdata = zeros(nNrOfLayers,layer_mapping_length,'like',p);
    
    % Evaluating Output data
    for ii = 0:(layer_mapping_length)-1
        for ind_layer = 0:nNrOfLayers-1
            layer_mapping_outdata(ind_layer+1,ii+1) = Modulation_outdata(nNrOfLayers*ii+1+ind_layer);
        end 
    end 
end