classdef NonCallbackModel
    properties
        Resolution = 1200;
        SaveFormat = 'tif';
    end

    properties(Hidden)
        NonCallbackParser;
    end

    methods
        function obj = NonCallbackModel()
            obj.CreateNonCallbackParser();
        end

        function ChangeNonCallback(obj, varargin)
            p = obj.NonCallbackParser;
            p.parse(varargin{:});
            ChangedResult = rmfield(p.Results, p.UsingDefaults);
            ChangedField = fields(ChangedResult);
            obj.(ChangedField{:}) = ChangedResult.(ChangedField{:});
        end

        function CreateNonCallbackParser(obj)
            obj.NonCallbackParser = inputParser();
            NonCallbackPropertiesName = properties(obj);
            for ii = 1:length(NonCallbackPropertiesName)
                DataPropertiesDefault = obj.(NonCallbackPropertiesName{ii});
                obj.NonCallbackParser.addParameter(NonCallbackPropertiesName{ii}, DataPropertiesDefault);
            end
        end

        function SaveFigures(obj)
            FigPath = strcat('Exported_', string(datetime), '. ', obj.SaveFormat);
            FigPath = strrep(FigPath, ':', '_');
            FigPath = strrep(FigPath, '/', '_');
            exportgraphics(gcf, FigPath, 'Resolution', obj.Resolution)

            %TabPath = strcat('Analysis/', string(ii), '. ', Title,
            %'_Mean_and_Sem.xlsx'); writetable(ResultT, TabPath);
        end

    end

end

