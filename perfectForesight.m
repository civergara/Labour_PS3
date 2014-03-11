Labour_PS3
==========
function [experience wage]=perfectForesight(PS3_data)

ddelta=.95;

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
   
aalpha1=initialGuess(1);
aalpha2=initialGuess(2);
ggamma0=initialGuess(3);
ggamma1=initialGuess(4); 
ggamma2=initialGuess(5);
ggamma3=initialGuess(6); 
ggamma4=initialGuess(7);  
ssigmaXi=initialGuess(8);  

%% Take exogenous data from database

n=1000;
periods=50;

education=zeros(n,1);
race=zeros(n,1);

i=1;
while i<n+1
    education(i)=PS3_data(1+15*(i-1),7);
    race(i)=PS3_data(1+15*(i-1),8);
    i=i+1;
end

%% Generate data

rng(10086)

% Income 
% To predict income regress income just use mean=mean(PS3_data(:,5)) and
% std=std(PS3_data(:,5))

income=7.4146*ones(n,50)+normrnd(0,0.8486,n,50);
% income=(6.0+0.04*education-0.0063*race)*ones(1,50)+normrnd(0,0.8486,n,50)

% Income Shocks
shocksXi=normrnd(0,ssigmaXi,n,50);

%% Simulation

decision=zeros(n,periods);
experience=zeros(n,periods);
wage=-ones(n,periods);

nGridExperience=periods;
i=1;

while i<n+1
%Previously constructed matrices

experienceGrid=linspace(0,nGridExperience-1,nGridExperience);
meanWage=ggamma0+ggamma1*education(i)+ggamma2*experienceGrid+ggamma3*experienceGrid.^2+ggamma4*race(i);
thresholdXi=zeros(nGridExperience);
utility=zeros(nGridExperience);
pdf3=zeros(nGridExperience);
pdf4=zeros(nGridExperience);

ttau=.7;
limitWage=20;

pdf1=normcdf(ssigmaXi-(log(limitWage)-meanWage)/ssigmaXi);
pdf2=normcdf((log(limitWage)-meanWage)/ssigmaXi);

% Last Period Decision 

if aalpha1+aalpha2*income(i,periods)<limitWage
    thresholdXi(:,nGridExperience)=log(aalpha1+aalpha2*income(i,periods))*ones(1,nGridExperience)-meanWage;
else
    thresholdXi(:,nGridExperience)=(log(max(aalpha1+aalpha2*income(i,periods)-30*ttau,10^-6))...
        -log(1-ttau))*ones(1,nGridExperience)-meanWage;
end

pdf3(:,nGridExperience)=normcdf(thresholdXi(:,nGridExperience)/ssigmaXi);
pdf4(:,nGridExperience)=normcdf(ssigmaXi-thresholdXi(:,nGridExperience)/ssigmaXi);

A=PS3_data(i+14,5)+(aalpha1+aalpha2*income(i,periods))*pdf3(:,nGridExperience);

B=zeros(nGridExperience,1);
C=zeros(nGridExperience,1);

for j=1:nGridExperience
    if thresholdXi(j,nGridExperience)<log(limitWage)-meanWage(j)
        B(j)=exp(meanWage(j)+ssigmaXi^2/2).*(pdf1(j)-pdf4(j,nGridExperience));
        C(j)=(1-ttau)*exp(meanWage(j)+ssigmaXi^2/2).*pdf1(j)+30*ttau*(1-pdf2(j));
    else
        C(j)=(1-ttau)*exp(meanWage(j)+ssigmaXi^2/2).*pdf4(j,nGridExperience)...
            +30*ttau*(1-pdf3(j,nGridExperience));
    end
end

utility(:,nGridExperience)=A+B+C;
            
% Periods 8-49
t=1;

while t<nGridExperience-7
    
A=zeros(nGridExperience,1);
B=zeros(nGridExperience,1);
C=zeros(nGridExperience,1);

for j=1:nGridExperience-t
    thresholdXi(j,nGridExperience-t)=log(max(aalpha1+aalpha2*income(i,periods-t)+...
        ddelta*(utility(j,nGridExperience-t+1)-...
        utility(j+1,nGridExperience-t+1)),10^-6))-meanWage(j);
    if thresholdXi(j,nGridExperience-t)+meanWage(j)>= log(limitWage)
        thresholdXi(j,nGridExperience-t)=log(max(aalpha1+aalpha2*income(i,periods-t)-30*ttau...
            +ddelta*(utility(j,nGridExperience-t+1)-...
        utility(j+1,nGridExperience-t+1)),10^-6))-meanWage(j)-log(1-ttau);
    end
    
    pdf3(j,nGridExperience-t)=normcdf(thresholdXi(j,nGridExperience-t)/ssigmaXi);
    pdf4(j,nGridExperience-t)=normcdf(ssigmaXi-thresholdXi(j,nGridExperience-t)/ssigmaXi);
    
    A(j)=income(i,periods-t)+ddelta*utility(j+1,nGridExperience-t+1)+(aalpha1+aalpha2*income(i,periods-t)+...
        ddelta*(utility(j,nGridExperience-t+1)-utility(j+1,nGridExperience-t+1)))...
        *pdf3(j,nGridExperience-t);
    
    if thresholdXi(j,nGridExperience-t)<log(limitWage)-meanWage(j)
        B(j)=exp(meanWage(j)+ssigmaXi^2/2).*(pdf1(j)-pdf4(j,nGridExperience-t));
        C(j)=(1-ttau)*exp(meanWage(j)+ssigmaXi^2/2).*pdf1(j)+30*ttau*(1-pdf2(j));
    else
        C(j)=(1-ttau)*exp(meanWage(j)+ssigmaXi^2/2).*pdf4(j,nGridExperience-t)...
            +30*ttau*(1-pdf3(j,nGridExperience-t));
    end
    
end

utility(:,nGridExperience-t)=A+B+C;

t=t+1;

end

ttau=.5;
limitWage=30;

pdf1=normcdf(ssigmaXi-(log(limitWage)-meanWage)/ssigmaXi);
pdf2=normcdf((log(limitWage)-meanWage)/ssigmaXi);

while t<nGridExperience

A=zeros(nGridExperience,1);
B=zeros(nGridExperience,1);
C=zeros(nGridExperience,1);

for j=1:nGridExperience-t
    thresholdXi(j,nGridExperience-t)=log(max(aalpha1+aalpha2*income(i,periods-t)+...
        ddelta*(utility(j,nGridExperience-t+1)-...
        utility(j+1,nGridExperience-t+1)),10^-6))-meanWage(j);
    if thresholdXi(j,nGridExperience-t)+meanWage(j)>= log(limitWage)
        thresholdXi(j,nGridExperience-t)=log(max(aalpha1+aalpha2*income(i,periods-t)-30*ttau...
            +ddelta*(utility(j,nGridExperience-t+1)-...
        utility(j+1,nGridExperience-t+1)),10^-6))-meanWage(j)-log(1-ttau);
    end
    
    pdf3(j,nGridExperience-t)=normcdf(thresholdXi(j,nGridExperience-t)/ssigmaXi);
    pdf4(j,nGridExperience-t)=normcdf(ssigmaXi-thresholdXi(j,nGridExperience-t)/ssigmaXi);
    
    A(j)=income(i,periods-t)+ddelta*utility(j+1,nGridExperience-t+1)+(aalpha1+aalpha2*income(i,periods-t)+...
        ddelta*(utility(j,nGridExperience-t+1)-utility(j+1,nGridExperience-t+1)))...
        *pdf3(j,nGridExperience-t);
    
    if thresholdXi(j,nGridExperience-t)<log(limitWage)-meanWage(j)
        B(j)=exp(meanWage(j)+ssigmaXi^2/2).*(pdf1(j)-pdf4(j,nGridExperience-t));
        C(j)=(1-ttau)*exp(meanWage(j)+ssigmaXi^2/2).*pdf1(j)+30*ttau*(1-pdf2(j));
    else
        C(j)=(1-ttau)*exp(meanWage(j)+ssigmaXi^2/2).*pdf4(j,nGridExperience-t)...
            +30*ttau*(1-pdf3(j,nGridExperience-t));
    end
    
end

utility(:,nGridExperience-t)=A+B+C;

t=t+1;

end


if shocksXi(i,1)>=thresholdXi(1,1)
    decision(i,1)=1;
    experience(i,2)=1;
    wage(i,1)=exp(meanWage(1)+shocksXi(i,1));
end

t=2;
while t<50
    if shocksXi(i,t)<thresholdXi(experience(i,t)+1,t)
        experience(i,t+1)=experience(i,t);
    else
        decision(i,t)=1;
        experience(i,t+1)=experience(i,t)+1;
        wage(i,t)=exp(meanWage(experience(i,t)+1)+shocksXi(i,t));
    end
    t=t+1;
end

    if shocksXi(i,t)>=thresholdXi(experience(i,t)+1,t)
        decision(i,t)=1;
        wage(i,t)=exp(meanWage(experience(i,t)+1)+shocksXi(i,t));
    end

i=i+1;

end

end
