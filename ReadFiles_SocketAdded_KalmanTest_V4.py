# from matplotlib import pyplot as plt
import socket
import numpy as np
import struct
import time

HOST = "127.0.0.1"  # Standard loopback interface address (localhost)
MATLABHOST = "127.0.0.1"
# PORT = 31000  # Port to listen on (non-privileged ports are > 1023)
TESTPORT = 32000  # Port to listen on (non-privileged ports are > 1023)
MATLABPORT = 37000
FRAME_PERIOD = 0.04

SEND_RAW_DATA=0

# file1 = open('1.txt', 'r')
file1 = open('20220429-035412.txt', 'r')
# file1 = open('MIMO_ON_Kamarbandi.txt', 'r')
Lines = file1.readlines()

count = 0
TargetCounter = 0
Y_List = []
X_List = []
Range_List = []
Velocity_List = []
SNR_Noise_List = []
Target_Noise_List = []
CalculateVelociy_List = []
PrevFrameNumber = 0
numberofobject = 0

mysocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
mysocket.bind((HOST, TESTPORT))
mysocket.listen()
conn, addr = mysocket.accept()

if SEND_RAW_DATA:
    matlabsocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    matlabsocket.connect((MATLABHOST, MATLABPORT))
# while 1:
#    conn.sendall(bytes("1,2,3,4\n",'ascii'))
#    time.sleep(0.5)

mystring = ''
# while 1:
for line in Lines:
    count += 1
    # print("Line{}: {}".format(count, line.strip())) #Debugging

    splitWords = line.split(" ")
    print(splitWords) #Debugging
    if "Frame" in splitWords[0]:
        FrameNumber = float(splitWords[2].replace("is:\t", ""))
        if numberofobject != 0:
            Frame = [1000] + X_List + [2000] + Y_List + [3000] + Velocity_List + [4000] + SNR_Noise_List + [
                5000] + Target_Noise_List
            dataPackString = '<' + str(numberofobject * 5 + 5) + 'f'
            data = struct.pack(dataPackString, *Frame)
            if SEND_RAW_DATA:
                matlabsocket.sendall(data)
            conn.sendall(data)

        numberofobject = 0
        Y_List = []
        X_List = []
        Velocity_List = []
        SNR_Noise_List = []
        Target_Noise_List = []
#        time.sleep(FRAME_PERIOD)

    if "\n" not in splitWords[0]:
        if "Frame" not in splitWords[0]:
            if "Y" not in splitWords[0]:
                if "Target" not in splitWords[0]:
                    if "Time" not in splitWords[0]:
                        TargetY = splitWords[0].replace(",", "")
                        TargetY = float(TargetY.replace("(", ""))
                        TargetX = float(splitWords[1].replace(",", ""))
                        TargetVelocity = float(splitWords[2].replace(",", ""))
                        TargetRange = float(splitWords[3].replace(",", ""))
                        TargetSNR = float(splitWords[4].replace(",", ""))
                        TargetNoise = splitWords[5].replace(")", "")
                        TargetNoise = float(TargetNoise.replace("\n", ""))

                        print(TargetY)
                        print(TargetX)
                        print(TargetVelocity)
                        print(TargetRange)
                        print(TargetSNR)
                        print(TargetNoise)
                        Y_List.append(TargetY)
                        X_List.append(TargetX)
                        Velocity_List.append(TargetVelocity)
                        SNR_Noise_List.append(TargetSNR)
                        Target_Noise_List.append(TargetNoise)
                        numberofobject += 1

mysocket.close()
if SEND_RAW_DATA:
    matlabsocket.close()
