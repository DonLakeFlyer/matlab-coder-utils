#include "rtwtypes.h"

int 	udpReceiverSetup 	(int ipPort);
void 	udpReceiverRead		(int fdSocket, creal32_T* complexBuffer, int bufferSize);
void	udpReceiverClear	(int fdSocket);
int 	udpSenderSetup		(int ipPort);
int 	udpSenderSend		(int fdSocket, uint8_t* bytes, int cBytes);
void 	udpSocketRelease	(int fdSocket);