function testComplexSamplesSender()    
    udpSender = ComplexSingleSamplesUDPSender("127.0.0.1", 10000, 3);
    
    packetCount = 1;
    
    while true
        fprintf("Sending packet %d\n", packetCount);
        complexSamples = [ complex(single(packetCount), single(0)) complex(single(2), single(0)) complex(single(3), single(0)) ];
        udpSender.send(complexSamples);
        packetCount = packetCount + 1;
        pause(0.1);
    end
end