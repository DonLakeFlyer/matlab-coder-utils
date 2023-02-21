% This class is used to create a matlab struct which can be converted to bytes to send over udp.
% All values must be double to make conversion to bytes consistent. Also in general the properties
% should somewhat match the TunnelProtocol::PulseInfo_t structure naming and values.

classdef PulseInfoStruct

properties
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
end

methods
    function bytes = toBytes(self)
        bytes = [];
        structFieldNames = fieldnames(self);
        for i = 1 : numel(structFieldNames)
            curFieldName = string(structFieldNames{i});
            curFieldValue = self.(curFieldName);
            curFieldValue = double(curFieldValue);
            bytes = [bytes typecast(curFieldValue, "uint8")];
        end
    end

    function sendOverUDP(self, udpSender)
        pulseInfoBytes = self.toBytes();
        if coder.target('MATLAB')
            udpSender(pulseInfoBytes);
        else
            coder.cinclude('udp.h');
            coder.updateBuildInfo('addSourceFiles', 'udp.cpp');
            coder.ceval('udpSenderSend', udpSender, pulseInfoBytes, numel(pulseInfoBytes));
        end
    end
end

end