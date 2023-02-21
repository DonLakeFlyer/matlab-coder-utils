#include "rtwtypes.h"

int 	udpReceiverSetup(int ipPort);
void 	udpReceiverReadComplex(int fdSocket, creal32_T* complexBuffer, int cComplex);
void    udpReceiverReadBytes(int fdSocket, uint8_T* bytes, int cBytes);
void	udpReceiverClear(int fdSocket);
int 	udpSenderSetup(int ipPort);
int 	udpSenderSendBytes(int fdSocket, uint8_T* bytes, int cBytes);
void 	udpSocketRelease(int fdSocket);