function [udpReceiver, bufferSizeBytes] = udpSamplesReceiverSetup(ipAddress, ipPort, samplesPerFrame)
	%#codegen
    bufferSizeBytes = samplesPerFrame * 2 * 4; % Two floats = 2 * 4 bytes;
	if coder.target('MATLAB')
		udpReceiver = dsp.UDPReceiver( ...
									'RemoteIPAddress', 		ipAddress, ...
							    	'LocalIPPort',			ipPort, ...
							    	'ReceiveBufferSize',	bufferSizeBytes, ...
							    	'MaximumMessageLength',	samplesPerFrame, ...
							    	'MessageDataType',		'single', ...
							    	'IsMessageComplex',		true);
	    setup(udpReceiver);
	else
		coder.cinclude('udp.h');
		coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
		udpReceiver = int32(0);
		udpReceiver = coder.ceval('udpReceiverSetup', ipPort);
		if udpReceiver <= 0
			error('udpReceiverSetup failed');
		end
	end
end
