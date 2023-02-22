function testPulseInfoStructReceiver()

pulseInfoStruct = PulseInfoStruct();
pulseInfoStruct.udpReceiverSetup("127.0.0.1", 10000);
packetCount = 1;

while true
    dataAvailable = pulseInfoStruct.receiveOverUDP();
    if dataAvailable
        fprintf("Received packet %d\n", packetCount);
        assert(pulseInfoStruct.tag_id                       == packetCount, "actual %d expected %d", pulseInfoStruct.tag_id, packetCount);
        assert(pulseInfoStruct.frequency_hz                 == 146000000);
        assert(pulseInfoStruct.start_time_seconds           == 0);
        assert(pulseInfoStruct.predict_next_start_seconds   == 0);
        assert(pulseInfoStruct.group_snr                    == 0);
        assert(pulseInfoStruct.stft_score                   == 0);
        assert(pulseInfoStruct.group_ind                    == 0);
        assert(pulseInfoStruct.group_snr                    == 0);
        assert(pulseInfoStruct.detection_status             == 0);
        assert(pulseInfoStruct.confirmed_status             == 0);
        packetCount = packetCount + 1;
    end
end