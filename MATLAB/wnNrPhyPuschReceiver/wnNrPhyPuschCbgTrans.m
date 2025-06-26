

function [cbgs, nOfCbgs] = wnNrPhyPuschCbgTrans(cbgTransmission, ... % If a UE is configured to receive code block group (CBG) based transmissions
                                                maxCbsPerTbs, ...    % Maximum number of CBGs per transport block
                                                nOfCodeBlks)         % Number of code blocks 
                                   
% If Code block based group transmission is enabled                                       
if (cbgTransmission == 1)

    % Number of Code Blocks     
    %M
    nOfCbgs = min(maxCbsPerTbs, nOfCodeBlks); 

    %M1
    nOfCbgs01 = mod(nOfCodeBlks, nOfCbgs); 

    k1 = ceil(nOfCodeBlks/nOfCbgs);
    k2 = floor(nOfCodeBlks/nOfCbgs);

    if (nOfCbgs01 > 0)
        for idx01 = 1:1:nOfCbgs01
            for idx02 = 1:1:k1
                cbgs(idx01).data(idx02) = (idx01-1) * k1 + idx02;
            end
            cbgs(idx01).len = k1;
            
        end

        for idx01 = nOfCbgs01+1:1:nOfCbgs
            for idx02 = 1:1:k2
                cbgs(idx01).data(idx02) = nOfCbgs01*k1 + (idx01-nOfCbgs01-1)*k2 + idx02;
            end
            cbgs(idx01).len = k2;
           
        end
    else   %M1 = 0   %% ------------ FIXME-------------- %%
        for idx01 = nOfCbgs01+1:1:nOfCbgs
            for idx02 = 1:1:k2
                cbgs(idx01).data(idx02) = nOfCbgs01*k1 + (idx01-nOfCbgs01-1)*k2 + idx02;
            end
            cbgs(idx01).len = k2;
           
        end
    end
    

% If code block group based transmission is disabled then ACK/NACK will 
% be sent for each code-block. So here each code bock group is equivalent
% to code block.
else
    for idx01 = 1:1:nOfCodeBlks
        cbgs(idx01).data(1) = idx01; 
        cbgs(idx01).len = 1;
         cbgs(idx01).nACK = 0;
    end
    nOfCbgs = nOfCodeBlks;
end

%% ------------- FIXME------------------------    
    for idx01= 1:1:nOfCbgs       
        for idx02 = 1:1:cbgs(idx01).len
            cbgs(idx01).cbCrcCheck(idx02) = 0;
        end
        cbgs(idx01).nACK = 0;
    end
%% --------------------------------------------------


end % End of the function