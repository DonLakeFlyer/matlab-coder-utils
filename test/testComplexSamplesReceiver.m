function testComplexSamplesReceiver()

udpReceiver = ComplexSingleSamplesUDPReceiver("127.0.0.1", 10000, 3);
packetCount = 1;

while true
    complexData = udpReceiver.receive();
    if ~isempty(complexData)
        fprintf("Received packet %d\n", packetCount);
        assert(numel(complexData) == 3, "actual %d expected %d", numel(complexData), 3);
        assert(real(complexData(1)) == packetCount, "actual %d expected %d", real(complexData(1)), packetCount);
        assert(imag(complexData(1)) == 0);
        assert(real(complexData(2)) == 2);
        assert(imag(complexData(2)) == 0);
        assert(real(complexData(3)) == 3);
        assert(imag(complexData(3)) == 0);
        packetCount = packetCount + 1;
    end
end