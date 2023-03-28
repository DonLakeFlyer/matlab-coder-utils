function testPulseInfoStructSender()
    pulseInfoStruct = PulseInfoStruct();

    pulseInfoStruct.tag_id = uint8(0);
    assert(isa(pulseInfoStruct.tag_id, 'double'));

    pulseInfoStruct.udpSenderSetup('127.0.0.1', 10000);

    packetCount                                 = uint32(1);
    pulseInfoStruct.frequency_hz                = 146000000;
    pulseInfoStruct.start_time_seconds          = 0;
    pulseInfoStruct.predict_next_start_seconds  = 0;
    pulseInfoStruct.snr                         = 0;
    pulseInfoStruct.stft_score                  = 0;
    pulseInfoStruct.group_ind                   = 0;
    pulseInfoStruct.group_snr                   = 0;
    pulseInfoStruct.detection_status            = 0;
    pulseInfoStruct.confirmed_status            = 0;

    while true
        fprintf("Sending packet %ud\n", packetCount);
        pulseInfoStruct.tag_id = packetCount;
        pulseInfoStruct.sendHeartbeatOverUDP(2);
        pulseInfoStruct.sendOverUDP();
        packetCount = packetCount + 1;
        pause(0.1);
    end
end