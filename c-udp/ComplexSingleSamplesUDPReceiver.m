classdef ComplexSingleSamplesUDPReceiver
    properties
        udpReceiver
        samplesPerFrame
    end

    methods
        function self = ComplexSingleSamplesUDPReceiver(ipAddress, ipPort, samplesPerFrame)
            self.samplesPerFrame = samplesPerFrame;
            if coder.target('MATLAB')
                % The values for ReceiveBufferSize and MaximuMessageLength are somewhat mysterious.
                % The values below are what seem to work without dropping packets.
                self.udpReceiver = dsp.UDPReceiver( ...
                                            'RemoteIPAddress',      ipAddress, ...
                                            'LocalIPPort',          ipPort, ...
                                            'ReceiveBufferSize',    2^19, ...
                                            'MaximumMessageLength', self.samplesPerFrame * 2, ...
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