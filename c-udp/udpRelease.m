function udpRelease(udpSenderReceiver)
	%#codegen
	if coder.target('MATLAB')
		release(udpSenderReceiver);
	else
		coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
		coder.ceval('udpSocketRelease', udpRecudpSenderReceivereiver);
	end
end
