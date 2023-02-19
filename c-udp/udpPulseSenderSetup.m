function udpSender = udpPulseSenderSetup(ipAddress, ipPort)
	%#codegen
	if coder.target('MATLAB')
        sendBufferSize = numel(structToBytes(createPulseInfoStruct()));
		udpSender = dsp.UDPSender( ...
									'RemoteIPAddress', 		ipAddress, ...
							    	'RemoteIPPort',			ipPort, ...
							    	'SendBufferSize',		sendBufferSize);
	else
		coder.cinclude('udp.h');
		coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
		udpSender = int32(0);
		udpSender = coder.ceval('udpSenderSetup', ipPort);
		if udpSender <= 0
			error('udpSenderSetup failed');
		end
	end
end
