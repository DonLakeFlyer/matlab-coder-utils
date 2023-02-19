function udpPulseSenderSend(udpSender, pulseInfo)
	%#codegen
    pulseInfoBytes = structToBytes(pulseInfo);
	if coder.target('MATLAB')
		udpSender(pulseInfoBytes);
	else
		coder.cinclude('udp.h');
		coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
		coder.ceval('udpSenderSend', udpSender, pulseInfoBytes, numel(pulseInfoBytes));
	end
end
