function  FillNaN(obj)
%Fill the NaN data in the cell fomat "RawDataset" to NaN table
[r, c] = find(cellfun(@isempty, obj.RawDataset));
EmptyCell = NaN(1, length(obj.RawDataVariableNames));
EmptyTable = array2table(EmptyCell);
EmptyTable.Properties.VariableNames = obj.RawDataVariableNames;

for ii = 1:length(r)
    obj.RawDataset{r(ii), c(ii)} = EmptyTable;
end

end

