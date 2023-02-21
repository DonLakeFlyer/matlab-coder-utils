classdef ComplexSamplesUDPReceiver
    properties
        udpReceiver
        bufferSizeBytes
    end

    methods
        function self = ComplexSampleUDPReceiver(ipPort, samplesPerFrame)
            self.bufferSizeBytes = samplesPerFrame * 2 * 4; % Two floats = 2 * 4 bytes;
            if coder.target('MATLAB')
                self.udpReceiver = dsp.UDPReceiver( ...
                                            'RemoteIPAddress',      ipAddress, ...
                                            'LocalIPPort',          ipPort, ...
                                            'ReceiveBufferSize',    self.bufferSizeBytes, ...
                                            'MaximumMessageLength', samplesPerFrame, ...
                                            'MessageDataType',      'single', ...
                                            'IsMessageComplex',     true);
                setup(self.udpReceiver);
            else
                coder.cinclude('udp.h');
                coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
                self.udpReceiver = int32(0);
                self.udpReceiver = coder.ceval('udpReceiverSetup', ipPort);
                if udpReceiver <= 0
                    error('udpReceiverSetup failed');
                end
            end
        end

        function complexData = read(self)
            if coder.target('MATLAB')
                complexData     = self.udpReceiver();
            else
                cComplexRead    = int32(0);
                complexBuffer   = complex(zeros(1, receiveBufferSize, 'single'), zeros(1, receiveBufferSize, 'single'));

                coder.cinclude('udp.h');
                coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
                cComplexRead = coder.ceval('udpReceiverReadComplex', self.udpReceiver, coder.wref(complexBuffer), self.bufferSizeBytes);
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