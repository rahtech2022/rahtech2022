close all;
clear;
clc;
t = tcpip('0.0.0.0',36000,'NetworkRole','server');
set(t, 'ByteOrder', 'littleEndian');
fopen(t);
frameNotReceivedCounter=100;
x=0;
y=0;
v=0;

while(1)
    if(t.BytesAvailable)
        bufferLen=t.BytesAvailable;
        bufferLen=bufferLen/4;
        frame=fread(t,bufferLen,'single');        
        numberOfTargets=bufferLen/4;
        x=zeros(numberOfTargets,1);
        y=zeros(numberOfTargets,1);
        v=zeros(numberOfTargets,1);
        y=frame(1:4:end);
        x=frame(2:4:end);
        v=frame(3:4:end);
        str=sprintf('number of Targets:%d\n\r',numberOfTargets);
        fprintf(str);
        frameNotReceivedCounter=0;
    else
        frameNotReceivedCounter = frameNotReceivedCounter +1;
    end
    
    if frameNotReceivedCounter==100
        x=0;
        y=0;
        v=0;
    end
    c = linspace(1,10,length(x));
    sz = 25;
    scatter(x,y,sz,c,'filled');
    v_str=num2str(v);
    v_str_2=cellstr(v_str);
    dx=0.1;
    dy=0.1;
    text(x+dx, y+dy, v_str_2);
    xlim([-10 10]);
    ylim([0 50]);
    xlabel('meter');
    ylabel('meter');
    title('Processed Data');
    grid on;
    drawnow;
end
