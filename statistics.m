Labour_PS3
==========
%% Problem Set 3 Labor Economics
% Question 2: Model Fit
% Statistics

%% Data Transformation

experience_data=zeros(n,15);
income_data=zeros(n,15);
decision_data=zeros(n,15);

i=1;
while i<15001
    j=1;
    while j<16
        experience_data(PS3_data(i,1),j)=PS3_data(i,6);
        income_data(PS3_data(i,1),j)=PS3_data(i,5);
        decision_data(PS3_data(i,1),j)=PS3_data(i,3);
        i=i+1;
        j=j+1;
    end
end

%% Income Comparison

plot(linspace(36,50,15),mean(income(:,36:50)),linspace(36,50,15),mean(income_data))
xlabel('Years')
ylabel('Income of the Husband')
ylim([7 8])
legend('simulated data','real data')

%% Experience Comparison

plot(linspace(36,50,15),mean(experience(:,36:50)),linspace(36,50,15),mean(experience_data))
xlabel('Years')
ylabel('Experience')
legend('simulated data','real data','Location','SouthEast')

%% i) Periods Worked
% The average number of period working over the sample period overall and by whether or not the woman has less
% than 12 years of schooling, exactly 12, 13–15 and 16+. 

% Average number of periods worked over the sample
mean(grpstats(PS3_data(:,3),PS3_data(:,1))*15)
mean(grpstats(PS3_data(:,3),PS3_data(:,1))*15)-1.96*std((grpstats(PS3_data(:,3),PS3_data(:,1))*15))/sqrt(n)
mean(grpstats(PS3_data(:,3),PS3_data(:,1))*15)+1.96*std((grpstats(PS3_data(:,3),PS3_data(:,1))*15))/sqrt(n)

% Average number of periods worked over the simulated data
mean(sum(decision(:,35:50),2))
mean(sum(decision(:,35:50),2))-1.96*std(sum(decision(:,35:50),2))/sqrt(n)
mean(sum(decision(:,35:50),2))+1.96*std(sum(decision(:,35:50),2))/sqrt(n)

% Average number of periods worked by education classes

educationClasses=zeros(n,1);

for i=1:n
    if education(i)<12
        educationClasses(i)=1;
    elseif education(i)==12
        educationClasses(i)=2;
    elseif education(i)<16
        educationClasses(i)=3;
    else
        educationClasses(i)=4;
    end
end


[simMeanEducation simIntervalEducation] = grpstats(sum(decision(:,36:50),2),educationClasses,{'mean','meanci'})
[realMeanEducation realIntervalEducation] = grpstats(sum(decision_data,2),educationClasses,{'mean','meanci'})


%% ii) The fraction of women working at each age; 

% Data
[realMeanAge realIntervalAge]=grpstats(PS3_data(:,3),PS3_data(:,2),{'mean','meanci'})

% Simulated

simMeanAge=zeros(15,1);
simStdAge=zeros(15,1);

for i=36:50
    simMeanAge(i-35)=mean(decision(:,i));
    simStdAge(i-35)=std(decision(:,i));
end

simLowIntAge=simMeanAge-1.96*simStdAge/sqrt(n);
simHighIntAge=simMeanAge+1.96*simStdAge/sqrt(n);

% Plots
plot(linspace(51,65,15),realMeanAge,'-g')
hold on
plot(linspace(51,65,15),simMeanAge,'-b')
plot(linspace(51,65,15),simLowIntAge,':b')
plot(linspace(51,65,15),simHighIntAge,':b')
xlabel('Age')
ylabel('Fraction of Women Working')
ylim([0.6 0.9])
legend('real data','simulated data','Location','SouthEast')
hold off

%% iii) The fraction of women working by work experience levels 

% Data
experienceClassesReal=zeros(n*15,1);

for i=1:n*15
    if PS3_data(i)<11
        experienceClassesReal(i)=1;
    elseif PS3_data(i)<21
        experienceClassesReal(i)=2;
    else
        experienceClassesReal(i)=3;
    end
end

[realMeanExperience realIntervalExperience]=grpstats(PS3_data(:,3),experienceClassesReal,{'mean','meanci'})

% Simulated

experience_sim=zeros(n*15,1);
decision_sim=zeros(n*15,1);

i=1;
j=1;
while i<n*15+1
    while j<n+1
        experience_sim(i:i+14)=experience(j,36:50);
        decision_sim(i:i+14)=decision(j,36:50);
        j=j+1;
        i=i+15;
    end
end

experienceClassesSim=zeros(n*15,1);

for i=1:n*15
    if experience_sim(i)<11
        experienceClassesSim(i)=1;
    elseif experience_sim(i)<21
        experienceClassesSim(i)=2;
    else
        experienceClassesSim(i)=3;
    end
end

[simMeanExperience simIntervalExperience]=grpstats(decision_sim,experienceClassesSim,{'mean','meanci'})

%% iv). The mean wage of working women overall, by the four education classes in (i) above and by age.

% Overall Data
nn=sum(PS3_data(:,3)==1);
data=zeros(nn,8);

j=1;
for i=1:15000
    if PS3_data(i,3)==1
        data(j,:)=PS3_data(i,:);
        j=j+1;
    end
end

realMeanWage=mean(data(:,4))
realLowIntWage=realMeanWage-1.96*std(data(:,4))/sqrt(nn)
realHighIntWage=realMeanWage+1.96*std(data(:,4))/sqrt(nn)

%Simulated

j=1;
for i=1:1000
    for s=36:50
    if decision(i,s)==1
        wage1(j)=wage(i,s);
        education1(j)=education(i);
        age(j)=s;
        j=j+1;
    end
    end
end

NN=length(wage1);

simMeanWage=mean(wage1)
simLowIntWage=simMeanWage-1.96*std(wage1)/sqrt(NN)
simHighIntWage=simMeanWage+1.96*std(wage1)/sqrt(NN)

% By Education Level

% Data
educationClassesRealRestricted=zeros(nn,1);

for i=1:nn
    if data(i,6)<12
        educationClassesRealRestricted(i)=1;
    elseif data(i,6)==12
        educationClassesRealRestricted(i)=2;
    elseif data(i,6)<16
        educationClassesRealRestricted(i)=3;
    else
        educationClassesRealRestricted(i)=4;
    end
end

[realMeanWageEducation realIntervalWageEducation] = grpstats(data(:,4),educationClassesRealRestricted,{'mean','meanci'})

% Simulated
educationClassesSimRestricted=zeros(NN,1);

for i=1:NN
    if education1(i)<11
        educationClassesSimRestricted(i)=1;
    elseif education1(i)==12
        educationClassesSimRestricted(i)=2;
    elseif education1(i)<16
        educationClassesSimRestricted(i)=3;
    else
        educationClassesSimRestricted(i)=4;
    end
end

[simMeanWageEducation simIntervalWageEducation] = grpstats(wage1,educationClassesSimRestricted,{'mean','meanci'})

% By Age

[realMeanWageAge realIntervalWageAge] = grpstats(data(:,4),data(:,2),{'mean','meanci'})
[simMeanWageAge simIntervalWageAge] = grpstats(wage1,age,{'mean','meanci'})


plot(linspace(51,65,15),realMeanWageAge,'-g')
hold on
plot(linspace(51,65,15),simMeanWageAge,'-b')
plot(linspace(51,65,15),simIntervalWageAge,':b')
xlabel('Age')
ylabel('Mean Wage')
ylim([3.5 5])
legend('real data','simulated data','Location','SouthEast')
hold off

