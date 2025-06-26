

function [output_bits] = wnNrPhyPuschCbDeSeg(ldpcTempDecode, ...
                                             nCodeblks, ...
                                             eachCblen)

index03 = 1;
output_bits = zeros(1,nCodeblks*(eachCblen - 24));
if(nCodeblks > 1)
    for index01 = 1:1:nCodeblks  
        index02 = 1;
        while index02 <= eachCblen - 24
            output_bits(1,index03) = ldpcTempDecode(index01, index02);
            index03 = index03 + 1;
            index02 = index02 + 1;
        end
    end

end % End of the function
