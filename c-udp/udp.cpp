#include "udp.h"

#include <memory.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <cerrno>
#include <stdlib.h>

int udpReceiverSetup(int ipPort)
{
    int fdSocket = socket(AF_INET, SOCK_DGRAM, 0);
    if (fdSocket < 0 ) {
        printf("Receiver socket creation failed. Port: %d. Error: %s\n", ipPort, strerror(errno));
        exit(0);        
    } 

    struct sockaddr_in  servaddr;   

    memset(&servaddr, 0, sizeof(servaddr)); 
        
    servaddr.sin_family = AF_INET; 
    servaddr.sin_port = htons(ipPort); 
    servaddr.sin_addr.s_addr = inet_addr("127.0.0.1");

    if (bind(fdSocket, (struct sockaddr*)&servaddr, sizeof(servaddr)) < 0) {
        printf("Receiver socket bind failed. Port: %d. Error: %s\n", ipPort, strerror(errno));
        close(fdSocket);
        exit(0);        
    }

    return fdSocket;
}

int udpSenderSetup(int ipPort)
{
    int fdSocket = socket(AF_INET, SOCK_DGRAM, 0);
    if (fdSocket < 0 ) {
        printf("Sender socket creation failed. Port: %d. Error: %s\n", ipPort, strerror(errno));
        exit(0);        
    } 

    struct sockaddr_in  servaddr;   

    memset(&servaddr, 0, sizeof(servaddr)); 
        
    servaddr.sin_family = AF_INET; 
    servaddr.sin_port = htons(ipPort); 
    servaddr.sin_addr.s_addr = inet_addr("127.0.0.1");

    if (connect(fdSocket, (struct sockaddr *)&servaddr, sizeof(servaddr)) < 0) {
        printf("Sender socket connect failed. Port: %d. Error: %s\n", ipPort, strerror(errno));
        close(fdSocket);
        exit(0);        
    }

    return fdSocket;
}

void udpReceiverReadComplex(int fdSocket, creal32_T* complexBuffer, int cComplex)
{
    int cBytesLeft = cComplex * sizeof(creal32_T);
    uint8_T* writePtr = (uint8_T*)&complexBuffer[0];

    while (cBytesLeft) {
        int cBytesRead = recvfrom(
                            fdSocket, 
                            writePtr, cBytesLeft, 
                            0, 
                            (struct sockaddr *)NULL, 
                            NULL);
        if (cBytesRead > 0) {
            cBytesLeft -= cBytesRead;
            writePtr += cBytesRead;
        } else {
            printf("Error udpReceiverReadComplex: %s\n", strerror(errno));
        }
    }
}

void udpReceiverReadDouble(int fdSocket, double* doubleBuffer, int cDouble)
{
    int         cBytesLeft  = cDouble * sizeof(double);
    uint8_T*    writePtr    = (uint8_T*)&doubleBuffer[0];

    while (cBytesLeft) {
        int cBytesRead = recvfrom(
                            fdSocket, 
                            writePtr, cBytesLeft, 
                            0, 
                            (struct sockaddr *)NULL, 
                            NULL);
        if (cBytesRead > 0) {
            cBytesLeft -= cBytesRead;
            writePtr += cBytesRead;
        } else {
            printf("Error udpReceiverReadDouble: %s\n", strerror(errno));
        }
    }    
}

void udpReceiverClear(int fdSocket)
{
    uint8_T buffer[1024];
    size_t  szBuffer = sizeof(buffer);

    while (true) {
        int cBytesRead = recvfrom(
                            fdSocket, 
                            buffer, szBuffer, 
                            MSG_DONTWAIT, 
                            (struct sockaddr *)NULL, 
                            NULL);
        if (cBytesRead != szBuffer) {
            break;
        }
    }
}

int udpSenderSendBytes(int fdSocket, uint8_T* bytes, int cBytes)
{
    return send(fdSocket, bytes, cBytes, 0);
}

int udpSenderSendComplex(int fdSocket, creal32_T* complexBuffer, int cComplex)
{
    int cBytes = cComplex * sizeof(creal32_T);

    return udpSenderSendBytes(fdSocket, (uint8_t*)complexBuffer, cBytes);
}

int udpSenderSendDoubles(int fdSocket, double* doubleBuffer, int cDouble)
{
    int cBytes = cDouble * sizeof(double);

    return udpSenderSendBytes(fdSocket, (uint8_t*)doubleBuffer, cBytes);    
}

void udpReceiverSenderRelease(int fdSocket)
{
	close(fdSocket);
}