function test()
    pulseInfoStruct = PulseInfoStruct();

    pulseInfoStruct.tag_id = uint8(0);
    assert(isa(pulseInfoStruct.tag_id, 'double'));
    bytes = pulseInfoStruct.toBytes();
    expectedByteCount = 10 * 8;
    actualByteCount = numel(bytes);
    assert(expectedByteCount == actualByteCount, "expected %d actual %d", expectedByteCount, actualByteCount);

    pulseInfoStruct.udpSenderSetup('127.0.0.1', 10000);
    pulseInfoStruct.udpReceiverSetup('127.0.0.1', 10000);

    pulseInfoStruct.tag_id          = 1;
    pulseInfoStruct.frequency_hz    = 146000000;

    pulseInfoStruct.sendOverUDP();

    udpReceiver = ComplexSamplesUDPReceiver('127.0.0.1', 20000, 2048);
    udpReceiver.read();
end