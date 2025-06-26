% Scaling factor
function[sf] = wnNrPhyPuschPtrsSFac(tsf_precdg,modulation_order)

%transform precoding
% tsf_precdg=1 :  disabled
% tsf_precdg=0 :  enabled

if tsf_precdg==0
    
    switch modulation_order
        case 0
            sf=1;
        case 1
            sf=1;
        case 2
            sf=1.2;
        case 3
            sf=0.6667;
        case 4
            sf=0.3529;
    end %end of switch case
    
else
    %doubt 
    % spec 214 pg.no 91 ;table 6.2.3.1-3
%     alp_ptrs=[0 3 4.7 6;0 3 4.77 6]

    sf=1;
end %end of if
        
end %end of function