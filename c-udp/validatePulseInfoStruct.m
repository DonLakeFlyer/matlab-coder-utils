function retStruct = validatePulseInfoStruct(pulseInfoStruct)

typeStruct  = createPulseInfoStruct();
retStruct   = pulseInfoStruct;

fields = fieldnames(pulseInfoStruct); 

for i = 1:numel(fields)
    curField = fields{i};
    curValue = pulseInfoStruct.(curField);
    correctType = class(typeStruct.(curField));
    curType = class(curValue);
    if correctType ~= curType
        switch correctType
            case "double"
                curValue = double(curValue);
            case "uint8"
                curValue = uint8(curValue);
            case "uint16"
                curValue = uint16(curValue);
            case "uint32"
                curValue = uint32(curValue);
            otherwise
                error("validatePulseInfoStruct: unsupported type %s", correctType);
        end
        retStruct.(curField) = curValue;
    end
end

end