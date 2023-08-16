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
        group_seq_counter           (1, 1) double = NaN;
        group_ind                   (1, 1) double = NaN;
        group_snr                   (1, 1) double = NaN;
        noise_psd                   (1, 1) double = NaN;
        detection_status            (1, 1) double = NaN;
        confirmed_status            (1, 1) double = NaN;
        udpSender                   (1, 1)
        udpReceiver                 (1, 1)
        cDoubles                    (1, 1) uint32 = 11;     % Must match the number of double sent/received over udp in a single packet
    end

    methods
        function udpSenderSetup(self, ipAddress, ipPort)
            if coder.target('MATLAB')
                self.udpSender = dsp.UDPSender( ...
                                    'RemoteIPAddress',      ipAddress, ...
                                    'RemoteIPPort',         ipPort, ...
                                    'SendBufferSize',       self.cDoubles * 8);
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
            if coder.target('MATLAB')
                % For some reason ReceiveBufferSize must be arbitrarily large than the size of the packet received!
                actualByteCount = self.cDoubles * 8;
                receiveBufferSize = max(8192, actualByteCount * 2);
                self.udpReceiver = dsp.UDPReceiver( ...
                                            'RemoteIPAddress',      ipAddress, ...
                                            'LocalIPPort',          ipPort, ...
                                            'ReceiveBufferSize',    receiveBufferSize, ...
                                            'MaximumMessageLength', self.cDoubles, ...
                                            'MessageDataType',      'double', ...
                                            'IsMessageComplex',     false);
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
            doublesBuffer = self.toDoubles();
            if coder.target('MATLAB')
                self.udpSender(doublesBuffer);
            else
                coder.cinclude('udp.h');
                coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
                coder.ceval('udpSenderSendDoubles', self.udpSender, coder.ref(doublesBuffer), self.cDoubles);
            end
        end

        function sendHeartbeatOverUDP(self, tagId)
            doublesBuffer = self.heartbeatDoubles(tagId);
            if coder.target('MATLAB')
                self.udpSender(doublesBuffer);
            else
                coder.cinclude('udp.h');
                coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
                coder.ceval('udpSenderSendDoubles', self.udpSender, coder.ref(doublesBuffer), self.cDoubles);
            end
        end

        function dataAvailable = receiveOverUDP(self)
            if coder.target('MATLAB')
                doublesBuffer  = self.udpReceiver();
            else
                cBytesRead      = int32(0);
                doublesBuffer   = zeros(1, self.cDoubles, 'double');

                coder.cinclude('udp.h');
                coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
                cBytesRead = coder.ceval('udpReceiverReadDoubles', self.udpReceiver, coder.wref(doublesBuffer), self.cDoubles);
                assert(cBytesRead == self.cDoubles * 8, ...
                    "PulseInfoStruct:receiveOverUDP byte count mismatch: expected %d actual %d", ...
                    self.cDoubles * 8, cBytesRead);               
            end
            dataAvailable = ~isempty(doublesBuffer);
            if dataAvailable
                self.fromDoubles(doublesBuffer);
            end
        end

        function release(self)
            udpRelease(self.udpSender);
        end

        function doublesBuffer = toDoubles(self)
            doublesBuffer = [ self.tag_id ...
                                self.frequency_hz ...
                                self.start_time_seconds ...
                                self.predict_next_start_seconds ...
                                self.snr ...
                                self.stft_score ...
                                self.group_seq_counter ...
                                self.group_ind ...
                                self.group_snr ...
                                self.noise_psd ...
                                self.detection_status ...
                                self.confirmed_status ...
                            ];
        end

        function doublesBuffer = heartbeatDoubles(self, tagId)
            doublesBuffer = [ double(tagId) ...
                                0.0 ... % self.frequency_hz ...
                                0.0 ... % self.start_time_seconds ...
                                0.0 ... % self.predict_next_start_seconds ...
                                0.0 ... % self.snr ...
                                0.0 ... % self.stft_score ...
                                0.0 ... % self.group_seq_counter ...
                                0.0 ... % self.group_ind ...
                                0.0 ... % self.group_snr ...
                                0.0 ... % self.noise_psd ...
                                0.0 ... % self.detection_status ...
                                0.0 ... % self.confirmed_status ...
                            ];
        end

        function fromDoubles(self, doublesBuffer)
            self.tag_id                      = doublesBuffer(1);
            self.frequency_hz                = doublesBuffer(2);
            self.start_time_seconds          = doublesBuffer(3);
            self.predict_next_start_seconds  = doublesBuffer(4);
            self.snr                         = doublesBuffer(5);
            self.stft_score                  = doublesBuffer(6);
            self.group_seq_counter           = doublesBuffer(7);
            self.group_ind                   = doublesBuffer(8);
            self.group_snr                   = doublesBuffer(9);
            self.noise_psd                   = doublesBuffer(10);
            self.detection_status            = doublesBuffer(11);
            self.confirmed_status            = doublesBuffer(12);
        end
    end
end