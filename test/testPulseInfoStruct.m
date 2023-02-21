function testPulseInfoStruct()
    pulseInfoStruct = PulseInfoStruct();

    structFieldNames = fieldnames(pulseInfoStruct);
    for i = 1 : numel(structFieldNames)
        curFieldName = string(structFieldNames{i});
        curFieldValue = pulseInfoStruct.(curFieldName);
        assert(isa(curFieldValue, 'double'), "field %1 is not double", curFieldName);
        assert(isnan(curFieldValue), "field %1 is not NaN", curFieldName)
    end

    pulseInfoStruct.tag_id = uint8(0);
    bytes = pulseInfoStruct.toBytes();
    expectedByteCount = numel(fieldnames(pulseInfoStruct)) * 8;
    actualByteCount = numel(bytes);
    assert(expectedByteCount == actualByteCount, "expected %d actual %d", expectedByteCount, actualByteCount);

    udpSender = udpPulseInfoStructSenderSetup("127.0.0.1", 1000);
    pulseInfoStruct.sendOverUDP(udpSender);
end