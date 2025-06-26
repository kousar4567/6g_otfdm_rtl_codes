%%%%% Soft Decision Demodulation of M-QAM symbols %%%%%

function [demodOut,pi2BpskDerotData] = wnNrPhySoftDemodulation(data, modulationType)

demodOut = zeros(1,modulationType*size(data,2));
pi2BpskDerotData = [];
for n = 0:1:length(data)-1
    if modulationType == 1
        pi2BpskDerotData(n+1) = data(n+1).*exp( -1i * pi * (mod([n],2))/2 );
        demodOut(n + 1) = (real(pi2BpskDerotData(n+1))+imag(pi2BpskDerotData(n+1))); 

    else
        
        if modulationType == 2
            demodOut(modulationType*n + 1) = real(data(n+1));
            demodOut(modulationType*n + 2) = imag(data(n+1));
        %for any mocdulation scheme the first two bits have the same expression
        else
            demodOut(modulationType*n + 1) = real(data(n+1));
            demodOut(modulationType*n + 2) = imag(data(n+1));


            if(modulationType == 4)
                %16QAM -> 4 bits per symbol
                demodOut(modulationType*n + 3) = -abs(real(data(n+1)))+(2/sqrt(10));
                demodOut(modulationType*n + 4) = -abs(imag(data(n+1)))+(2/sqrt(10));

            elseif(modulationType == 6)
                %64QAM -> 6 bits per symbol
                demodOut(modulationType*n + 3) = -abs(real(data(n+1)))+(4/sqrt(42));
                demodOut(modulationType*n + 4) = -abs(imag(data(n+1)))+(4/sqrt(42));

        %         demodOut(modulationType*n + 5) = sign(-abs(real(data(n+1)) - (4/sqrt(42))) + (2/sqrt(42)))*abs(real(data(n+1)));
        %         demodOut(modulationType*n + 6) = sign(-abs(imag(data(n+1)) - (4/sqrt(42))) + (2/sqrt(42)))*abs(imag(data(n+1)));

                if(abs(real(data(n+1))) < 4/sqrt(42))
                    demodOut(modulationType*n + 5) = abs(real(data(n+1))) - 2/sqrt(42);
                else
                    demodOut(modulationType*n + 5) = 6/sqrt(42) - abs(real(data(n+1)));
                end

                if(abs(imag(data(n+1))) < 4/sqrt(42))
                    demodOut(modulationType*n + 6) = abs(imag(data(n+1))) - 2/sqrt(42);
                else
                    demodOut(modulationType*n + 6) = 6/sqrt(42) - abs(imag(data(n+1)));
                end


        %         if (abs(real(data(n+1)))<(6/sqrt(42)) && abs(real(data(n+1)))>(2/sqrt(42)))
        %             demodOut(modulationType*n + 5) = +abs(real(data(n+1)));
        %         else
        %             demodOut(modulationType*n + 5) = -abs(real(data(n+1)));
        %         end

        %         if (abs(imag(data(n+1)))<(6/sqrt(42)) && abs(imag(data(n+1)))>(2/sqrt(42)))
        %             demodOut(modulationType*n + 6) = +abs(imag(data(n+1)));
        %         else
        %             demodOut(modulationType*n + 6) = -abs(imag(data(n+1)));
        %         end

            elseif(modulationType == 8)
                %256QAM -> 8 bits per symbol
                demodOut(modulationType*n + 3) = -abs(real(data(n+1)))+(8/sqrt(170));
                demodOut(modulationType*n + 4) = -abs(imag(data(n+1)))+(8/sqrt(170));

        %         if (abs(real(data(n+1)))<(12/sqrt(170)) && abs(real(data(n+1)))>(4/sqrt(170)))
        %             demodOut(modulationType*n + 5) = +abs(real(data(n+1)));
        %         else
        %             demodOut(modulationType*n + 5) = -abs(real(data(n+1)));
        %         end

                if(abs(real(data(n+1))) < 8/sqrt(170))
                    demodOut(modulationType*n + 5) = +abs(real(data(n+1))) - (4/sqrt(170));
                else
                    demodOut(modulationType*n + 5) = (12/sqrt(170)) - abs(real(data(n+1)));
                end

        %         if (abs(imag(data(n+1)))<(12/sqrt(170)) && abs(imag(data(n+1)))>(4/sqrt(170)))
        %             demodOut(modulationType*n + 6) = +abs(imag(data(n+1)));
        %         else
        %             demodOut(modulationType*n + 6) = -abs(imag(data(n+1)));
        %         end

                if(abs(imag(data(n+1))) < 8/sqrt(170))
                    demodOut(modulationType*n + 6) = +abs(imag(data(n+1))) - (4/sqrt(170));
                else
                    demodOut(modulationType*n + 6) = (12/sqrt(170)) - abs(imag(data(n+1)));
                end

        %         if( abs(real(data(n+1))) < 2/sqrt(170) || abs(real(data(n+1))) > 14/sqrt(170) ...
        %                 || (abs(real(data(n+1))) > 6/sqrt(170) && abs(real(data(n+1))) < 10/sqrt(170)))
        %             demodOut(modulationType*n + 7) = -abs(real(data(n+1)));
        %         else
        %             demodOut(modulationType*n + 7) = +abs(real(data(n+1)));
        %         end

                if( abs(real(data(n+1))) < 4/sqrt(170))
                    demodOut(modulationType*n + 7) = abs(real(data(n+1))) - (2/sqrt(170));
                elseif( abs(real(data(n+1))) < 8/sqrt(170) )
                    demodOut(modulationType*n + 7) = (6/sqrt(170)) - abs(real(data(n+1)));
                elseif( abs(real(data(n+1))) < 12/sqrt(170) )
                     demodOut(modulationType*n + 7) = abs(real(data(n+1))) - (10/sqrt(170));
                else
                    demodOut(modulationType*n + 7) = (14/sqrt(170)) - abs(real(data(n+1)));
                end

        %         if( abs(imag(data(n+1))) < 2/sqrt(170) || abs(imag(data(n+1))) > 14/sqrt(170) ...
        %                 || (abs(imag(data(n+1))) > 6/sqrt(170) && abs(imag(data(n+1))) < 10/sqrt(170)))
        %             demodOut(modulationType*n + 8) = -abs(imag(data(n+1)));
        %         else
        %             demodOut(modulationType*n + 8) = +abs(imag(data(n+1)));
        %         end

                if( abs(imag(data(n+1))) < 4/sqrt(170))
                    demodOut(modulationType*n + 8) = abs(imag(data(n+1))) - (2/sqrt(170));
                elseif( abs(imag(data(n+1))) < 8/sqrt(170) )
                    demodOut(modulationType*n + 8) = (6/sqrt(170)) - abs(imag(data(n+1)));
                elseif( abs(imag(data(n+1))) < 12/sqrt(170) )
                     demodOut(modulationType*n + 8) = abs(imag(data(n+1))) - (10/sqrt(170));
                else
                    demodOut(modulationType*n + 8) = (14/sqrt(170)) - abs(imag(data(n+1)));
                end




            end
        end 
    end 
end
end