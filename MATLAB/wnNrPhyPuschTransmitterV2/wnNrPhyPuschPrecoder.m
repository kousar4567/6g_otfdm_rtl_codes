% PRE-CODING

function [puschPrecodingMatrix] = wnNrPhyPuschPrecoder(TPMI_index, ...
                                                          Antenne_ports, ...
                                                     Layers)

puschPrecodingMatrix = []; 
    switch Antenne_ports
        case 2
            switch Layers
                case 1
                    switch TPMI_index
                        case 0
                            puschPrecodingMatrix = 1/sqrt(2)*[1;0];
                        case 1
                            puschPrecodingMatrix = 1/sqrt(2)*[0;1];
                        case 2
                            puschPrecodingMatrix = 1/sqrt(2)*[1;1];
                        case 3
                            puschPrecodingMatrix = 1/sqrt(2)*[1;-1];
                        case 4
                            puschPrecodingMatrix = 1/sqrt(2)*[1;1j];
                        case 5
                            puschPrecodingMatrix = 1/sqrt(2)*[1;-1j];
                    end 
                case 2
                    switch TPMI_index
                        case 0
                            puschPrecodingMatrix = 1/sqrt(2)*[1 0;0 1];
                        case 1
                            puschPrecodingMatrix = 1/2*[1 1;1 -1];
                        case 2
                            puschPrecodingMatrix = 1/2*[1 1;1j -1j];
                    end
            end 
        case 4
            switch Layers
                case 1
                    switch TPMI_index
                        case 0
                            puschPrecodingMatrix = 0.5*[1;0;0;0];                           
                        case 1
                            puschPrecodingMatrix = 0.5*[0;1;0;0]; 
                        case 2
                            puschPrecodingMatrix = 0.5*[0;0;1;0]; 
                        case 3
                            puschPrecodingMatrix = 0.5*[0;0;0;1]; 
                        case 4
                            puschPrecodingMatrix = 0.5*[1;0;1;0];
                        case 5
                            puschPrecodingMatrix = 0.5*[1;0;-1;0];
                        case 6
                            puschPrecodingMatrix = 0.5*[1;0;1j;0]; 
                        case 7
                            puschPrecodingMatrix = 0.5*[1;0;-1j;0]; 
                        case 8
                            puschPrecodingMatrix = 0.5*[0;1;0;1];
                        case 9
                            puschPrecodingMatrix = 0.5*[0;1;0;-1]; 
                        case 10
                            puschPrecodingMatrix = 0.5*[0;1;0;1j];
                        case 11
                            puschPrecodingMatrix = 0.5*[0;1;0;-1j];
                        case 12
                            puschPrecodingMatrix = 0.5*[1;1;1;1];
                        case 13
                            puschPrecodingMatrix = 0.5*[1;1;1j;1j];
                        case 14
                            puschPrecodingMatrix = 0.5*[1;1;-1;-1];
                        case 15
                            puschPrecodingMatrix = 0.5*[1;1;-1j;-1j];
                        case 16
                            puschPrecodingMatrix = 0.5*[1;1j;1;1j];
                        case 17
                            puschPrecodingMatrix = 0.5*[1;1j;1j;-1];
                        case 18
                            puschPrecodingMatrix = 0.5*[1;1j;-1;-1j];
                        case 19
                            puschPrecodingMatrix = 0.5*[1;1j;-1j;1];
                        case 20
                            puschPrecodingMatrix = 0.5*[1;-1;1;-1];
                        case 21
                            puschPrecodingMatrix = 0.5*[1;-1;1j;-1j];
                        case 22
                            puschPrecodingMatrix = 0.5*[1;-1;-1;1];
                        case 23
                            puschPrecodingMatrix = 0.5*[1;-1;-1j;1j];
                        case 24
                            puschPrecodingMatrix = 0.5*[1;-1j;1;-1j];
                        case 25
                            puschPrecodingMatrix = 0.5*[1;-1j;1j;1];
                        case 26
                            puschPrecodingMatrix = 0.5*[1;-1j;-1;1j];
                        case 27
                            puschPrecodingMatrix = 0.5*[1;-1j;-1j;-1];
                    end
                case 2
                    switch TPMI_index
                        case 0
                            puschPrecodingMatrix = (0.5)*[1 0;0 1;0 0;0 0];
                        case 1
                            puschPrecodingMatrix = (0.5)*[1 0;0 0;0 1;0 0];
                        case 2
                            puschPrecodingMatrix = (0.5)*[1 0;0 0;0 0;0 1];
                        case 3
                            puschPrecodingMatrix = (0.5)*[0 0;1 0;0 1;0 0];
                        case 4
                            puschPrecodingMatrix = (0.5)*[0 0;1 0;0 0;0 1];
                        case 5
                            puschPrecodingMatrix = (0.5)*[0 0;0 0;1 0;0 1];
                        case 6
                            puschPrecodingMatrix = (0.5)*[1 0;0 1;1 0;0 -1j];
                        case 7
                            puschPrecodingMatrix = (0.5)*[1 0;0 1;1 0;0 1j];
                        case 8
                            puschPrecodingMatrix = (0.5)*[1 0;0 1;-1j 0;0 1];
                        case 9
                            puschPrecodingMatrix = (0.5)*[1 0;0 1;-1j 0;0 -1];
                        case 10
                            puschPrecodingMatrix = (0.5)*[1 0;0 1;-1 0;0 -1j];
                        case 11
                            puschPrecodingMatrix = (0.5)*[1 0;0 1;-1 0;0 1j];
                        case 12
                            puschPrecodingMatrix = (0.5)*[1 0;0 1;1j 0;0 1];
                        case 13
                            puschPrecodingMatrix = (0.5)*[1 0;0 1;1j 0;0 -1];
                        case 14
                            puschPrecodingMatrix = sqrt(0.125)*[1 1;1 1;1 -1;1 -1];
                        case 15
                            puschPrecodingMatrix = sqrt(0.125)*[1 1;1 1;1j -1j;1j -1j];
                        case 16
                            puschPrecodingMatrix = sqrt(0.125)*[1 1;1j 1j;1 -1;1j -1j];
                        case 17
                            puschPrecodingMatrix = sqrt(0.125)*[1 1;1j 1j;1j -1j;-1 1];
                        case 18
                            puschPrecodingMatrix = sqrt(0.125)*[1 1;-1 -1;1 -1;-1 1];
                        case 19
                            puschPrecodingMatrix = sqrt(0.125)*[1 1;-1 -1;1j -1j;-1j 1j];
                        case 20
                            puschPrecodingMatrix = sqrt(0.125)*[1 1;-1j -1j;1 -1;-1j 1j];
                        case 21
                            puschPrecodingMatrix = sqrt(0.125)*[1 1;-1j -1j;1j -1j;1 -1];
                    end
                case 3
                    switch TPMI_index
                        case 0
                            puschPrecodingMatrix = (0.5)*[1 0 0;0 1 0;0 0 1;0 0 0];
                        case 1
                            puschPrecodingMatrix = (0.5)*[1 0 0;0 1 0;1 0 0;0 0 1];
                        case 2
                            puschPrecodingMatrix = (0.5)*[1 0 0;0 1 0;-1 0 0;0 0 1];
                        case 3
                            puschPrecodingMatrix = 0.5*sqrt(1/3)*[1 1 1;1 -1 1;1 1 -1;1 -1 -1];
                        case 4
                            puschPrecodingMatrix = 0.5*sqrt(1/3)*[1 1 1;1 -1 1;1j 1j -1j;1j -1j -1j];
                        case 5
                            puschPrecodingMatrix = 0.5*sqrt(1/3)*[1 1 1;-1 1 -1;1 1 -1;-1 1 1];
                        case 6
                            puschPrecodingMatrix = 0.5*sqrt(1/3)*[1 1 1;-1 1 -1;1j 1j -1j;-1j 1j 1j];
                    end
                case 4
                    switch 4
                        case 0
                            puschPrecodingMatrix = 0.5*(eye(4));
                        case 1
                            puschPrecodingMatrix = sqrt(0.125)*[1 1 0 0;0 0 1 1;1 -1 0 0;0 0 1 -1];
                        case 2
                            puschPrecodingMatrix = sqrt(0.125)*[1 1 0 0;0 0 1 1;1j -1j 0 0;0 0 1j -1j];
                        case 3
                            puschPrecodingMatrix = (0.25)*[1 1 1 1;1 -1 1 -1;1 1 -1 -1;1 -1 -1 1];
                        case 4
                            puschPrecodingMatrix = (0.25)*[1 1 1 1;1 -1 1 -1;1j 1j -1j -1j;1j -1j -1j 1j];
                    end
            end
            
         otherwise
            puschPrecodingMatrix = 0;
    end
    
end % End of the function
    
                            
          