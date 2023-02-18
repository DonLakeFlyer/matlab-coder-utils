function udpSenderSend(udpSender, pulseInfo)
	%#codegen
	if coder.target('MATLAB')
		udpSender(pulseInfo);
	else
		coder.cinclude('udp.h');
		coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
		coder.ceval('udpSenderSend', udpSender, pulseInfo);
	end
end
