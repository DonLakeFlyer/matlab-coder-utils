function bytes = structToBytes(myStruct)

bytes = uint8.empty;

structFieldNames = fieldnames(myStruct);
for i = 1 : numel(structFieldNames)
    curFieldName = string(structFieldNames(i));
    curFieldValue = myStruct.(curFieldName);
    bytes = [bytes typecast(curFieldValue, "uint8")];
end

end