classdef ComplexSingleSamplesUDPSender
    properties
        udpSender
        samplesPerFrame
    end

    methods
        function self = ComplexSingleSamplesUDPSender(ipAddress, ipPort, samplesPerFrame)
            self.samplesPerFrame = samplesPerFrame;
            if coder.target('MATLAB')
                self.udpSender = dsp.UDPSender( ...
                                    'RemoteIPAddress',      ipAddress, ...
                                    'RemoteIPPort',         ipPort, ...
                                    'SendBufferSize',       samplesPerFrame * 2 * 4); % Two singles/floats = 2 * 4 bytes;
            else
                coder.cinclude('udp.h');
                coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
                udpSender = int32(0);
                udpSender = coder.ceval('udpSenderSetup', ipPort);
                self.udpSender = udpSender;
                if self.udpSender <= 0
                    error('udpSenderSetup failed');
                end
            end
        end

        function send(self, complexData)
            if coder.target('MATLAB')
                self.udpSender(complexData);
            else
                assert(numel(complexData) == self.samplePerFrame);
                coder.cinclude('udp.h');
                coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
                coder.ceval('udpSenderSendComplex', self.udpSender, coder.wref(complexData), self.samplesPerFrame);
            end 
        end

        function release(self)
            udpRelease(self.udpSender);
        end
    end
end