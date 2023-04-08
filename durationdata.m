%%
% <http://www.mathworks.com MathWorks> clc
clear all
close all 

%Input the latest 6-month OAD data from Bloomberg 
data = readtable('durationdata.xlsx');
port = data.Port;
benchmark = data.Benchmark;
diff = data.difference;

% plot(diff)

% Create dates just for the final plot 
year = data.Year;
m = data.Month;
d = data.Days;
dates = datenum(year,m,d);

%Construct the ARMA Garch model
Mdl = arima('ARLags',1,'MALags',1, 'Variance',garch(1,1));
[DurMdl,EstParamCov] = estimate(Mdl,diff);
[DurInnovations, DurVariances] = infer(DurMdl, diff);

% DurSI = DurInnovations ./ sqrt(DurVariances);
%%Check whether the model fit with the data
% figure
% qqplot(diff)
% title('QQ plot for duration difference')
% figure 
% qqplot(DurSI)
% title('QQ plot for model innovations')

%Simulate 10000 times with the ARMA Garch model 
[RF, EF, VF] = simulate(DurMdl, 5, 'NumPaths', 10000, 'E0', DurInnovations, 'V0', DurVariances);
DiffM = repmat(diff,1,10000);

%plot the historical and simulation on the same graph
DiffT = [DiffM' RF']';
yearF = [2022 2022 2022 2022 2022]';
mF = [12 12 12 12 12]';%input month
dF = [1 2 5 6 7]';%input first week trading days
datesF = datenum(yearF, mF, dF);

figure
plot([dates' datesF']', DiffT, 'LineWidth',1)
datetick
title('1-Week Forward Active Duration Forecasting','FontSize',20)

%counting the number of times breaches in 10000 simulations
s=0;
for i=1:10000
    if RF(i) >=  1 || RF(i) <=  -1
        s = s+1;
    end
end

%Probability that breach the IPS
probbreach = s/10000
