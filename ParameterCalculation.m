close all;
clear all;
clc;

maximumVelocity=63.75;% Km/h
velocityResolution = 2; % Km/h

maximumRange = 70; % meter
rangeResolution = 0.28; % meter
C=3e8;% m/s
f=77e9;
lamda=C/f;

ADCStartTime=4;%(us)
TXStartTime=1;%(us)
idleTime=3;%(us)
ExtraRampTime=1;

MAXSAMPLINGFREQUENCY= 6250;% in ksps    MAX Value is 6250
NumberofRxChannels=4;
NumberofTxChannels=2;

samplingFrequency=5500;
%% Duration of One chirp (Chirp Cycle Time)
maximumVelocity = maximumVelocity/3.6; % m/s
Tc=lamda/(4*maximumVelocity); % second
fprintf('Duration of One chirp is (us) %d \n\r',Tc*1e6);
%% Bandwidth Calculation
bandwidth =C/(2*rangeResolution);
fprintf('Required Bandwidth (MHz) %d \n\r',bandwidth*1e-6);
%% IDLE TIME
%if bandwidth < 1e9
    %idleTime=2;%(us)
%elseif 1e9< bandwidth && bandwidth < 2e9
    %idleTime=3.5;%(us)
%elseif 2e9< bandwidth && bandwidth < 3e9
    %idleTime=5;%(us)
%else
    %idleTime=7;%(us)
%end
%fprintf('Idle Time is(us) %d \n\r',idleTime);
%% Slope of LFM
slope = bandwidth / (Tc-(idleTime*1e-6));
fprintf('Frequency Slope (MHz/us) %d \n\r',slope*1e-12);
%% Frame Time
velocityResolution = velocityResolution /3.6; % m/s
Tf = lamda/(2*velocityResolution); % second
fprintf('Frame Time (ms) %d \n\r',Tf * 1e3);

%% Maximum Range Validation
maxSamplingFrequencyRequired=slope*2*maximumRange/C;
fprintf('Maximum Sampling Frequency Required by max Range(KSPS) %d \n\r',maxSamplingFrequencyRequired * 1e-3);

if (maxSamplingFrequencyRequired*1e-3) < MAXSAMPLINGFREQUENCY * 0.8
    fprintf('Maximum Range is Valid \r\n');
else
    fprintf('Maximum Range is Invalid\r\n');
end

if samplingFrequency < (maxSamplingFrequencyRequired *1e-3)
    samplingFrequency = MAXSAMPLINGFREQUENCY;
end
fprintf('Sampling Frequency %d \n\r',samplingFrequency);

%% ADC Sampling Time && Number of Samples
adcSamplingTime=(Tc*1e6)-idleTime-ADCStartTime-ExtraRampTime;%us
numberOfSamples=(adcSamplingTime*1e-6)*(samplingFrequency*1e3);
numberOfSamples=floor(numberOfSamples);
fprintf('Number of Samples %d \n\r',numberOfSamples);
%% Ramp End Time
%ExtraRampTime=0;
RampEndTime=adcSamplingTime+ADCStartTime+ExtraRampTime;%us
fprintf('Ramp End Time is %d \r\n',round(RampEndTime));
%% Number of Chirps in the frame
numberOfChirpsInFrame=Tf/Tc;
fprintf('Number of Chirps in Frame %d \n\r',numberOfChirpsInFrame);
numberOfLoopsInFrame = 2 ^ nextpow2(numberOfChirpsInFrame/2); % each loop contains 2 chirps so division is needed
fprintf('Number of Loops in Frame %d \r\n',numberOfLoopsInFrame);

%% Memory Size
MemorySize=numberOfSamples*4*numberOfChirpsInFrame*NumberofRxChannels*NumberofTxChannels;
fprintf('Required Memory Size is %d(KB)\n\r',MemorySize/1024);
%% Frame Active Time
FrameActiveTime=numberOfChirpsInFrame*Tc;%us
fprintf('Frame Active Time(ms) is %d \n\r',FrameActiveTime*1000);
%% Range Index to meter

rangeIndexToMeter=(samplingFrequency*1000*C)/(numberOfSamples*2*slope);
fprintf('Range Index To Meter is %d\n\r',rangeIndexToMeter);
