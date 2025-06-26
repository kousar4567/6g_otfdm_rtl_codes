function [c]=pn(cinit,M)
    % RB=10;%number of resource block
    % M=RB*12/2;
    Nc=1600;
    k=M+Nc;
 x1(1)=1;
    for i = 2 : 32
            x1(i)=0;
    end
    x2=fliplr(dec2bin(cinit,31));
    for n=1:k
      x1(n+31)=mod((x1(n+3)+x1(n)),2);
      x2(n+31)=mod((x2(n+3)+x2(n+2)+x2(n+1)+x2(n)),2);
    end
    for n=1:M
       c(n)=mod((x1(n+Nc)+x2(n+Nc)),2);
    end
end