%%
% Copyright (c) 2016-2018, WiSig Networks Pvt Ltd. All rights reserved.
% www.wisig.com
% 
% All information contained herein is property of WiSig Networks Pvt Ltd. 
% unless otherwise explicitly mentioned.
% 
% The intellectual and technical concepts in this file are proprietary 
% to WiSig Networks and may be covered by granted or in process national
% and international patents and are protect by trade secrets and       
% copyright law.
% 
% Redistribution and use in source and binary forms of the content in  
% this file, with or without modification are not permitted unless     
% permission is explicitly granted by WiSig Networks.                   
% If WiSig Networks permits this source code to be used as a part of 
% open source project, the terms and conditions of CC-By-ND (No Derivative) license
% (https://creativecommons.org/licenses/by-nd/4.0/) shall apply.


%% Function for PN Sequence Generation for NR

function [nr_PN_seq] = wnNrPhyPnSeq (Cinit, pn_seq_len)

%% Input parameters 
% cinit has to be initialized based on the channel or signal requirement
% pn_seq_len is the output length needed

% Initializing scrambler parameters 
Nc = 1600;

x1(1:31) = zeros(1,31);
x2(1:31) = zeros(1,31);
x1(1) = 1;

x2(1:31) = de2bi(Cinit,31);

for n=1:1:pn_seq_len+Nc-31
    x1(n+31) = mod(x1(n+3)+x1(n),2);
    x2(n+31) = mod(x2(n+3)+x2(n+2)+x2(n+1)+x2(n),2);
end
nr_PN_seq = zeros(1,pn_seq_len);

for n=1:1:pn_seq_len
    nr_PN_seq(n) = mod(x1(n+Nc)+x2(n+Nc),2);
end 




