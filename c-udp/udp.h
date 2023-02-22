#include "rtwtypes.h"

int     udpReceiverSetup        (int ipPort);
void    udpReceiverReadComplex  (int fdSocket, creal32_T* complexBuffer, int cComplex);
void    udpReceiverReadDoubles  (int fdSocket, double* doubleBuffer, int cDouble);
void    udpReceiverClear        (int fdSocket);
int     udpSenderSetup          (int ipPort);
int     udpSenderSendBytes      (int fdSocket, uint8_T* bytes, int cBytes);
int     udpSenderSendDoubles    (int fdSocket, double* doubleBuffer, int cDouble);
int     udpSenderSendComplex    (int fdSocket, creal32_T* complexBuffer, int cComplex);
void    udpSocketRelease        (int fdSocket);