function pulseInfoStruct = createPulseInfoStruct()

pulseInfoStruct.tag_id                      = uint32(0);
pulseInfoStruct.frequency_hz                = uint32(0);
pulseInfoStruct.start_time_seconds          = 0;
pulseInfoStruct.predict_next_start_seconds  = 0;
pulseInfoStruct.snr                         = 0;
pulseInfoStruct.stft_score                  = 0;
pulseInfoStruct.group_ind                   = uint16(0);
pulseInfoStruct.group_snr                   = 0;
pulseInfoStruct.detection_status            = uint8(0);
pulseInfoStruct.confirmed_status            = uint8(0);
pulseInfoStruct.position_x                  = 0;
pulseInfoStruct.position_y                  = 0;
pulseInfoStruct.position_z                  = 0;
pulseInfoStruct.orientation_x               = 0;
pulseInfoStruct.orientation_y               = 0;
pulseInfoStruct.orientation_z               = 0;
pulseInfoStruct.orientation_w               = 0;

end