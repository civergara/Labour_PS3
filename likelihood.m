Labour_PS3
==========
function l=fLikelihood(PS3_data,parameters)


ttau=.5;
limitWage=30;
ddelta=.95;
nGridExperience=15;

aalpha1=parameters(1);
aalpha2=parameters(2);
ggamma0= parameters(3);
ggamma1= parameters(4);
ggamma2=  parameters(5);
ggamma3= parameters(6);
ggamma4= parameters(7);
ssigmaXi=parameters(8);
ssigmaEta=parameters(9);

likelihood=zeros(1000,1);
i=1;

while i<15000
    
%Previously constructed matrices

experienceGrid=linspace(PS3_data(i,6),PS3_data(i,6)+nGridExperience-1,nGridExperience);
meanWage=ggamma0+ggamma1*PS3_data(i,7)+ggamma2*experienceGrid+ggamma3*experienceGrid.^2+ggamma4*PS3_data(i,8);
thresholdXi=zeros(nGridExperience);
utility=zeros(nGridExperience);
pdf3=zeros(nGridExperience,nGridExperience);
pdf4=zeros(nGridExperience,nGridExperience);

pdf1=normcdf(ssigmaXi-(log(limitWage)-meanWage)/ssigmaXi);
pdf2=normcdf((log(limitWage)-meanWage)/ssigmaXi);

% Last Period Decision 

if aalpha1+aalpha2*PS3_data(i+14,5)<limitWage
    thresholdXi(:,nGridExperience)=log(aalpha1+aalpha2*PS3_data(i+14,5))*ones(1,nGridExperience)-meanWage;
else
    thresholdXi(:,nGridExperience)=(log(max(aalpha1+aalpha2*PS3_data(i+14,5)-30*ttau,10^-6))...
        -log(1-ttau))*ones(1,nGridExperience)-meanWage;
end

pdf3(:,nGridExperience)=normcdf(thresholdXi(:,nGridExperience)/ssigmaXi);
pdf4(:,nGridExperience)=normcdf(ssigmaXi-thresholdXi(:,nGridExperience)/ssigmaXi);

A=PS3_data(i+14,5)+(aalpha1+aalpha2*PS3_data(i+14,5))*pdf3(:,nGridExperience);

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
            
% Rest of Periods
t=1;

while t<nGridExperience
    
A=zeros(nGridExperience,1);
B=zeros(nGridExperience,1);
C=zeros(nGridExperience,1);

for j=1:nGridExperience-t
    thresholdXi(j,nGridExperience-t)=log(max(aalpha1+aalpha2*PS3_data(i+14-t,5)+ddelta*(utility(j,nGridExperience-t+1)-...
        utility(j+1,nGridExperience-t+1)),10^-6))-meanWage(j);
    if thresholdXi(j,nGridExperience-t)+meanWage(j)>= log(limitWage)
        thresholdXi(j,nGridExperience-t)=log(max(aalpha1+aalpha2*PS3_data(i+14-t,5)-30*ttau...
            +ddelta*(utility(j,nGridExperience-t+1)-...
        utility(j+1,nGridExperience-t+1)),10^-6))-meanWage(j)-log(1-ttau);
    end
    
    pdf3(j,nGridExperience-t)=normcdf(thresholdXi(j,nGridExperience-t)/ssigmaXi);
    pdf4(j,nGridExperience-t)=normcdf(ssigmaXi-thresholdXi(j,nGridExperience-t)/ssigmaXi);
    
    A(j)=PS3_data(i+14-t,5)+ddelta*utility(j+1,nGridExperience-t+1)+(aalpha1+aalpha2*PS3_data(i+14-t,5)+...
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

% Likelihood

likelihoodPerson=zeros(nGridExperience,1);

t=1;
while t<16
    if PS3_data(i+t-1,3)==0
        likelihoodPerson(t)=log(max(pdf3(PS3_data(i+t-1,6)-PS3_data(i,6)+1,t),10^-6));
    else
        likelihoodPerson(t)=log(max(1-normcdf((thresholdXi(PS3_data(i+t-1,6)-PS3_data(i,6)+1,t)-...
    (log(PS3_data(i+t-1,4))-meanWage(PS3_data(i+t-1,6)-PS3_data(i,6)+1))*ssigmaXi^2/(ssigmaXi^2+ssigmaEta^2))...
    /sqrt(ssigmaXi^2*(1-ssigmaXi^2/(ssigmaXi^2+ssigmaEta^2)))),10^-6))...
    -log(PS3_data(i+t-1,4)*sqrt(2*pi*(ssigmaXi^2+ssigmaEta^2)))...
    -(log(PS3_data(i+t-1,4))-meanWage(PS3_data(i+t-1,6)-PS3_data(i,6)+1))^2/(2*(ssigmaXi^2+ssigmaEta^2));
    end
t=t+1;
end

likelihood(PS3_data(i,1))=sum(likelihoodPerson);


i=i+15;

end

l=sum(likelihood);

end
