function ChangeData(obj, varargin)
%The API to set the properties of DataModel object and notify 'DataChanged'

p = obj.DataParser;
p.parse(varargin{:});

%Remove the unchanged properties which use defaults
ChangedResult = rmfield(p.Results, p.UsingDefaults);
ChangedField = fields(ChangedResult);

%Change the correspond property
obj.(ChangedField{:}) = ChangedResult.(ChangedField{:});

if(strcmp(ChangedField{:}, "RawDataset"))
     obj.FillNaN(); %Fill the potential NaN data in the RawDataset
end

%% Some special cares
%If the PartialAnalyze is set to 0, it means analyze all the variables
if(obj.PartialAnalyze == 0)
    obj.PartialAnalyze = 1:obj.RawDataVariableNum;
end
if(obj.LimitedRow == 0)
    obj.LimitedRow = 1:obj.RawDataRows;
end
if(obj.LimitedColumn == 0)
    obj.LimitedColumn = 1:obj.RawDataColumns;
end
%% Notify 'DataChanged' event
obj.notify('DataChanged');
end

