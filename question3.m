Labour_PS3
==========
%% Problem Set 2 Labor Economics
%  Question 3: Contrafactual Experiments

clear all
close all

%% (1) Baseline

[experienceBaseline wageBaseline]=baseline(30,.5,PS3_data);

%% (2) Imposing the new tax system from initial period; 

[experienceContrafactual1 wageContrafactual1]=baseline(20,.7,PS3_data);


%% (3) Imposing the new tax system from period eight, with perfect foresight; 

[experienceContrafactual2 wageContrafactual2]=perfectForesight(PS3_data);

%% and (4) Imposing the new tax system from period 8, with static expectations.

[experienceContrafactual3 wageContrafactual3]=staticExpectations(PS3_data);

%% Plots

% Experience

plot(linspace(16,65,50),mean(experienceBaseline),'-g')
hold on
plot(linspace(16,65,50),mean(experienceContrafactual1),'-b')
plot(linspace(16,65,50),mean(experienceContrafactual2),'-r')
plot(linspace(16,65,50),mean(experienceContrafactual3),'-y')
xlabel('Age')
ylabel('Mean Experience')
legend('Baseline','Initial Period','Perfect Foresight','Static Expectations','Location','SouthEast')
hold off


wage1Baseline=zeros(50,1);
wage1Contrafactual1=zeros(50,1);
wage1Contrafactual2=zeros(50,1);
for i=1:50
    wage1Baseline(i)=(sum(wageBaseline(:,i))+sum(wageBaseline(:,i)==-1))/...
        (length(wageBaseline(:,i))-sum(wageBaseline(:,i)==-1));
    wage1Contrafactual1(i)=(sum(wageContrafactual1(:,i))+sum(wageContrafactual1(:,i)==-1))/...
        (length(wageContrafactual1(:,i))-sum(wageContrafactual1(:,i)==-1));
    wage1Contrafactual2(i)=(sum(wageContrafactual2(:,i))+sum(wageContrafactual2(:,i)==-1))/...
        (length(wageContrafactual2(:,i))-sum(wageContrafactual2(:,i)==-1));
    wage1Contrafactual3(i)=(sum(wageContrafactual3(:,i))+sum(wageContrafactual3(:,i)==-1))/...
        (length(wageContrafactual3(:,i))-sum(wageContrafactual3(:,i)==-1));
end

plot(linspace(16,65,50),wage1Baseline,'-g')
hold on
plot(linspace(16,65,50),wage1Contrafactual1,'-b')
plot(linspace(16,65,50),wage1Contrafactual2,'-r')
plot(linspace(16,65,50),wage1Contrafactual3,'-y')
xlabel('Age')
ylabel('Mean Wage')
legend('Baseline','Initial Period','Perfect Foresight','Static Expectations','Location','NorthEast')
hold off
