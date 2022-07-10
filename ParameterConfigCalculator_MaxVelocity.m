close all;
clear all;
clc;

%MaxRange=300;%300m
FrequencySlope=10; %MHz/us
C=3e8;% m/s
f=80e9;
lamda=C/f;
ADCSamplingFrequency= 6250;% in ksps    MAX Value is 6250
ADCSamples=64; %for Complex mode ADC and 4 Rx Antenna Max Value is 1024
ADCStartTime=3;%(us)
TXStartTime=1;%(us)
IdleTime=3;%(us)
NumberofUniqeChirps=1;
NumberofLoops=252;
NumberofChirpsPerFrame=NumberofLoops*NumberofUniqeChirps;
NumberofRxChannels=4;
NumberofTxChannels=1;
%IntegrationTime=150e-3; %350ms

%% Integration Time Calculation
IntegrationTime=(ADCSamples*NumberofChirpsPerFrame)/ADCSamplingFrequency;
%NumberofChirpsPerFrame=(IntegrationTime*ADCSamplingFrequency*1e3)/ADCSamples;
%ADCSamplingFrequency=(ADCSamples/IntegrationTime)*NumberofChirpsPerFrame;
fprintf('Integration Time is in (ms) %d \n\r',IntegrationTime);
%fprintf('ADC Sampling Frequency is %d \n\r',ADCSamplingFrequency);
%fprintf('Number of Chirps Per Frame is %d \n\r',NumberofChirpsPerFrame);
%% Frequency Slope
F_IF=ADCSamplingFrequency*0.8;
%FrequencySlope=(C* F_IF*1000)/(2*MaxRange);
MaxRange=(C* F_IF*1000)/(2*FrequencySlope*1e12);
fprintf('Maximum Range is %d(m) \n\r',MaxRange);

%% ADC Sampling Time
ADCSamplingTime=ADCSamples/ADCSamplingFrequency;
fprintf('ADC Sampling Time in mili second is %d \r\n',ADCSamplingTime);
ADCSamplingTime=ADCSamplingTime*1000;%(us)

%% Chirp Cycle Time
eps=0;
RampEndTime=ADCSamplingTime+ADCStartTime+eps;
fprintf('Ramp End Time in micro second is %d \r\n',RampEndTime);
ChirpCycleTime=IdleTime+RampEndTime;%us

%% Range Resolution
BandWidth = RampEndTime * FrequencySlope;% in MHz
BandWidth=BandWidth*1e6;
RangeRes= C/(2*BandWidth);% in m
fprintf('Range Resulotion is %d (cm) \n\r',RangeRes*100);

%% Frame Active Time
FrameActiveTime=NumberofChirpsPerFrame*ChirpCycleTime;%us
fprintf('Frame Active Time(ms) is %d \n\r',FrameActiveTime/1000);

%% Memory Size

MemorySize=ADCSamples*4*NumberofChirpsPerFrame*NumberofRxChannels*NumberofTxChannels;
fprintf('Required Memory Size is %d(KB)\n\r',MemorySize/1024);

%% Range Index to meter

rangeIndexToMeter=(ADCSamplingFrequency*1000*C)/(ADCSamples*2*FrequencySlope*1e12);
fprintf('Range Index To Meter is %d\n\r',rangeIndexToMeter);


%% Max Velocity
maxVelocity=(lamda*1e6)/(4*ChirpCycleTime);
fprintf('Maximum Velocity is %d(Km/h)\n\r',maxVelocity*3.6);

%% Velocity Resolution
VelocityRes=(lamda*1e6)/(2*NumberofChirpsPerFrame*ChirpCycleTime);
fprintf('Velocity Resolution is %d(Km/h)\n\r',VelocityRes*3.6);



