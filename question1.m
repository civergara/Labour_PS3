Labour_PS3
==========
%% Problem Set 3 Labor Economics
% Question 1: Estimation of Dynamic Labour Supply

clear all
close all


%% Maximization of likelihood

% Data contains the following parameters (1) indicator; (2) age; 
%(3)employment; (4) wage; (5) income ; (6) experience ; (7) education; 
% (8) race
    
% Order of parameters (1) aalpha1; (2) aalpha2; (3) ggamma0; (4) ggamma1; (5) ggamma2; (6) ggamma3
% (7) ggamma4; (8) ssigmaXi; (9) ssigmaEta; 

initialGuess=[ 
   2.500213960028058
   0.037432777629211
   1.088071042762860
   0.010357658878250
   0.000003797134790
   0.000050523797400
   0.007222886186748
   0.332930497020103
   0.188264854889195
    ];
   
% initialGuess=[ 2.500213967947784;0.037432752929087;1.088071036125365;0.010357667265559; -0.000003803224096;...
%    0.000050760326503; 0.007222877900614;0.332930474351535;0.188264864080016];
   
fNewLikelihood=@(parameters) -fLikelihood(PS3_data,parameters);

tic
y=fNewLikelihood(initialGuess)
toc

solution=fminunc(fNewLikelihood,initialGuess)
