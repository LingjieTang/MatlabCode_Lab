function CreateDataParser(obj)
    %Creat a data inputparser for all teh properties that are neither
    %hidden nor GetAccess == private
    
    obj.DataParser = inputParser();
    DataPropertiesName = properties(obj);
    for ii = 1:length(DataPropertiesName)
        DataPropertiesDefault = obj.(DataPropertiesName{ii});
        obj.DataParser.addParameter(DataPropertiesName{ii}, DataPropertiesDefault);
    end
end

