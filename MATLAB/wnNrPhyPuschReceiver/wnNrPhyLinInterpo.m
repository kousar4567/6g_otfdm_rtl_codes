%% Function to lineatly interpolate two points
function [Channel_subframe] = wnNrPhyLinInterpo(location1,...
                                                location2,...
                                                temp3_slot1,...
                                                temp3_slot2,...
                                                firstsymb,...
                                                lastsymb)


% temp3_slot1 = NrPuschChannelEstimates(indsymb).cdm(ind1).data(:,ind2);
% temp3_slot2 = NrPuschChannelEstimates(indsymb+1).cdm(ind1).data(:,ind2);
%   location2 = NrPuschDmrsSymbols(indsymb+1)+1;
%   location1 = NrPuschDmrsSymbols(indsymb)+1;

  Channel_subframe = zeros(size(temp3_slot1,1),lastsymb-firstsymb+1);
  idx = 1;
  for l = firstsymb:lastsymb
      Channel_subframe(:,idx)=((temp3_slot2-temp3_slot1)/(location2-location1))*(l-location1)+temp3_slot1;
      idx = idx+1;
  end 