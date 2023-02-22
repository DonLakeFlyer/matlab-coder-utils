classdef ComplexSingleSamplesUDPReceiver
    properties
        udpReceiver
        samplesPerFrame
    end

    methods
        function self = ComplexSingleSamplesUDPReceiver(ipAddress, ipPort, samplesPerFrame)
            self.samplesPerFrame = samplesPerFrame;
            if coder.target('MATLAB')
                % For some reason ReceiveBufferSize must be arbitrarily large than the size of the packet received!
                actualByteCount = samplesPerFrame * 2 * 4; % Two floats = 2 * 4 bytes;
                receiveBufferSize = max(8192, actualByteCount * 2);
                self.udpReceiver = dsp.UDPReceiver( ...
                                            'RemoteIPAddress',      ipAddress, ...
                                            'LocalIPPort',          ipPort, ...
                                            'ReceiveBufferSize',    receiveBufferSize, ...
                                            'MaximumMessageLength', self.samplesPerFrame, ...
                                            'MessageDataType',      'single', ...
                                            'IsMessageComplex',     true);
                setup(self.udpReceiver);
            else
                coder.cinclude('udp.h');
                coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
                self.udpReceiver = int32(0);
                self.udpReceiver = coder.ceval('udpReceiverSetup', ipPort);
                if self.udpReceiver <= 0
                    error('udpReceiverSetup failed');
                end
            end
        end

        function complexData = receive(self)
            if coder.target('MATLAB')
                complexData     = self.udpReceiver();
            else
                cComplexRead    = int32(0);
                complexBuffer   = complex(zeros(1, self.samplesPerFrame, 'single'), zeros(1, self.samplesPerFrame, 'single'));

                coder.cinclude('udp.h');
                coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
                cComplexRead = coder.ceval('udpReceiverReadComplex', self.udpReceiver, coder.wref(complexBuffer), self.samplesPerFrame);
                complexData = complexBuffer(:);
            end 
        end

        function clear(self)
            if coder.target('MATLAB')
                complexData = self.udpReceiver();
                while ~isempty(complexData)
                    complexData = self.udpReceiver();
                end
                complexData = [];
            else
                coder.cinclude('udp.h');
                coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
                coder.ceval('udpReceiverClear', self.udpReceiver);
            end 
        end

        function release(self)
            udpRelease(self.udpReceiver);
        end
    end
end