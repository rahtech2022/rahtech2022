import matplotlib; matplotlib.use("TkAgg")
import socket
import numpy as np
import struct
import time
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

DISPLAY_HOST = ""

DISPLAY_PORT = 36000

FRAME_PERIOD = 0.05

plt.style.use('fivethirtyeight')


def animate(i):
    global firstConnectionStablished
    global ConnectionNOtEstablished
    global client
    global displaySocket

    if firstConnectionStablished == 0:
        displaySocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        displaySocket.bind((DISPLAY_HOST, DISPLAY_PORT))
        displaySocket.listen()
        print("1")
        try:
            client, address = displaySocket.accept()
            client.settimeout(FRAME_PERIOD)
            firstConnectionStablished = 1
            ConnectionNOtEstablished = 0
            print("2")

        except socket.error:
            firstConnectionStablished = 0
            ConnectionNOtEstablished = 1
            print("3")

    if ConnectionNOtEstablished:
        try:
            client, address = displaySocket.accept()
            client.settimeout(FRAME_PERIOD)
            ConnectionNOtEstablished = 0
            print("4")
        except socket.error:
            ConnectionNOtEstablished = 1
            print("5")
    if (firstConnectionStablished==1) and (ConnectionNOtEstablished==0):
        try:
            #print("6")
            frame_raw = client.recv(1024)  ####TCP
            frame_raw_len = len(frame_raw)
            frame_raw_len /= 4
            numberOfTargets = frame_raw_len/4
            dataPackString = '<' + str(int(frame_raw_len)) + 'f'
            data_list = list( struct.unpack(dataPackString, frame_raw) )
            data =np.array(data_list)
            y = data[0::4]
            x = data[1::4]
            vy = data[2::4]
            vx = data[3::4]
            colors = np.linspace(0.0,1.0,int(numberOfTargets))
            plt.cla()
            dx = 0.25
            dy = 0.25
            for i,velocity in enumerate(list(vy)):
                plt.text(x[i]+dx,y[i]+dy,"{:.2f}".format(velocity))
            plt.scatter(x, y,c=colors,
                        edgecolor='black', linewidth=1)
            plt.xlim([-10, 10])
            plt.ylim([0, 50])
        except socket.timeout as e:
            #print("7")
            pass
        except socket.error:
            print("8")
            ConnectionNOtEstablished = 1
            client.close()


if __name__ == '__main__':
    firstConnectionStablished=0
    ConnectionNOtEstablished=1
    client = 0
    displaySocket = 0



    ani = FuncAnimation(plt.gcf(), animate, interval=1)

    plt.tight_layout()
    plt.show()