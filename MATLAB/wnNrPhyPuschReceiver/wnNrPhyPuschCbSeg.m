% calculation of #code blocks and the size of each code block after rate
% matching in the transmitter part

% in the receiver these modules have to be called before code block
% desegmentation and de ratematching

function [nCodeblks, Zc_min, eachCblen] = wnNrPhyPuschCbSeg(baseGraph, ...
                                                            tbsLen)

ldpc_lifting_size_set_Zc = [2,4,8,16,32,64,128,256, ...
                            3,6,12,24,48,96,192,384, ...
                            5,10,20,40,80,160,320, ...
                            7,14,28,56,112,224, ...
                            9,18,36,72,144,288, ...
                            11,22,44,88,176,352, ...
                            13,26,52,104,208, ...
                            15,30,60,120,240];   
                        
  B = tbsLen;
    
    %%----finding the base graph----%%
    switch baseGraph 
        case 2
            K_cb = 3840;
            if B>640
                K_b = 10;
            elseif B>560
                K_b = 9;
            elseif B>192
                K_b = 8;
            else
                K_b = 6;
            end
        case 1
            K_cb = 8448;
            K_b = 22;
    end
       
    if B <= K_cb
        L = 0;
        nCodeblks = 1;
        B_prime = B;
    else
        L = 24;
        nCodeblks = ceil(B/(K_cb-L));
        B_prime = B + nCodeblks*L;
    end
    
    eachCblen = B_prime/nCodeblks;
    
%     if baseGraph == 1
%         K_b = 22;
%     else
%         if B>640
%             K_b = 10;
%         elseif B>560
%             K_b = 9;
%         elseif B>192
%             K_b = 8;
%         else
%             K_b = 6;
%         end
%     end
    %-----Calculating (K)the size of the input code vector------%
    
    temp = K_b.*ldpc_lifting_size_set_Zc;
    Zc_min = min(ldpc_lifting_size_set_Zc(find(temp>=eachCblen)));

end