% This class is used to create a matlab struct which can be converted to bytes to send over udp.
% All values must be double to make conversion to bytes consistent. Also in general the properties
% should somewhat match the TunnelProtocol::PulseInfo_t structure naming and values.

classdef PulseInfoStruct < handle
    properties
        % IMPORTANT: If you update the number of properties send over the wire update and run the test.m code
        tag_id                      (1, 1) double = NaN
        frequency_hz                (1, 1) double = NaN
        start_time_seconds          (1, 1) double = NaN
        predict_next_start_seconds  (1, 1) double = NaN
        snr                         (1, 1) double = NaN;
        stft_score                  (1, 1) double = NaN;
        group_ind                   (1, 1) double = NaN;
        group_snr                   (1, 1) double = NaN;
        detection_status            (1, 1) double = NaN;
        confirmed_status            (1, 1) double = NaN;
        udpSender                   (1, 1)
        udpReceiver                 (1, 1)
        udpBufferSizeBytes          (1, 1)
    end

    methods
        function udpSenderSetup(self, ipAddress, ipPort)
            if coder.target('MATLAB')
                self.udpBufferSizeBytes = numel(PulseInfoStruct().toBytes());
                self.udpSender = dsp.UDPSender( ...
                                    'RemoteIPAddress',      ipAddress, ...
                                    'RemoteIPPort',         ipPort, ...
                                    'SendBufferSize',       self.udpBufferSizeBytes);
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

        function udpReceiverSetup(self, ipAddress, ipPort)
            self.udpBufferSizeBytes = numel(PulseInfoStruct().toBytes());
            if coder.target('MATLAB')
                self.udpReceiver = dsp.UDPReceiver( ...
                                            'RemoteIPAddress',      ipAddress, ...
                                            'LocalIPPort',          ipPort, ...
                                            'ReceiveBufferSize',    self.udpBufferSizeBytes, ...
                                            'MaximumMessageLength', self.udpBufferSizeBytes, ...
                                            'MessageDataType',      'single', ...
                                            'IsMessageComplex',     true);
                setup(self.udpReceiver);
            else
                coder.cinclude('udp.h');
                coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
                udpReceiver = int32(0);
                udpReceiver = coder.ceval('udpReceiverSetup', ipPort);
                self.udpReceiver = udpReceiver;
                if self.udpReceiver <= 0
                    error('udpReceiverSetup failed');
                end
            end
        end

        function sendOverUDP(self)
            pulseInfoBytes  = self.toBytes();
            expected        = self.udpBufferSizeBytes;
            actual          = numel(pulseInfoBytes);
            assert(expected == actual, ...
                "PulseInfoStruct:sendOverUDP byte count mismatch: expected %d actual %d", ...
                expected, actual);
            if coder.target('MATLAB')
                self.udpSender(pulseInfoBytes);
            else
                coder.cinclude('udp.h');
                coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
                coder.ceval('udpSenderSendBytes', self.udpSender, pulseInfoBytes, self.udpBufferSizeBytes);
            end
        end

        function receiveOverUDP(self)
            if coder.target('MATLAB')
                pulseInfoBytes  = self.udpReceiver();
            else
                cBytesRead      = int32(0);
                pulseInfoBytes  = zeros(1, self.udpBufferSizeBytes, 'uint8');

                coder.cinclude('udp.h');
                coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
                cBytesRead = coder.ceval('udpReceiverReadBytes', self.udpReceiver, coder.wref(pulseInfoBytes), self.bufferSizeBytes);
                assert(cBytesRead == self.udpBufferSizeBytes, ...
                    "PulseInfoStruct:receiveOverUDP byte count mismatch: expected %d actual %d", ...
                    self.udpBufferSizeBytes, cBytesRead);                
                pulseInfoBytes = pulseInfoBytes(:);
            end 
            expected        = self.udpBufferSizeBytes;
            actual          = numel(pulseInfoBytes);
            assert(expected == actual, ...
                "PulseInfoStruct:receiveOverUDP byte count mismatch: expected %d actual %d", ...
                expected, actual);
            self.fromBytes(pulseInfoBytes);
        end

        function release(self)
            udpRelease(self.udpSender);
        end

        function bytes = toBytes(self)
            tag_id_bytes                        = typecast(self.tag_id,                     "uint8");
            frequency_hz_bytes                  = typecast(self.frequency_hz,               "uint8");
            start_time_seconds_bytes            = typecast(self.start_time_seconds,         "uint8");
            predict_next_start_seconds_bytes    = typecast(self.predict_next_start_seconds, "uint8");
            snr_bytes                           = typecast(self.snr,                        "uint8");
            stft_score_bytes                    = typecast(self.stft_score,                        "uint8");
            group_ind_bytes                     = typecast(self.group_ind,                  "uint8");
            group_snr_bytes                     = typecast(self.group_snr,                  "uint8");
            detection_status_bytes              = typecast(self.detection_status,           "uint8");
            confirmed_status_bytes              = typecast(self.confirmed_status,           "uint8");
            bytes = [ tag_id_bytes ...
                        frequency_hz_bytes ...  
                        start_time_seconds_bytes ...
                        predict_next_start_seconds_bytes ...
                        snr_bytes ...
                        stft_score_bytes ...
                        group_ind_bytes ...
                        group_snr_bytes ...
                        detection_status_bytes ...
                        confirmed_status_bytes ...
                        ];
        end
    end

    methods(Static)
        function cBytes = byteCount()
            testStruct = PulseInfoStruct();
            cBytes = numel(testStruct.toBytes());
        end
    end
end