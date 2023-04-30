classdef OverlaysModel < handle

    properties
        ShowPoints = false;
        ShowLegend = false;
        Legend = "";
        PartialLegend = 1;
        ShowError = false;
        ShowSignificance = false;
        OutlierRemove = 'none';
        ShowpValue = false;
    end

    properties(Hidden)
        OverlaysParser;
    end

    events
        OverlaysChanged;
    end

    methods
        function obj = OverlaysModel()
            obj.CreateOverlaysParser();
        end

        function ChangeOverlays(obj, varargin)
            p = obj.OverlaysParser;
            p.parse(varargin{:});

            ChangedResult = rmfield(p.Results, p.UsingDefaults);
            ChangedField = fields(ChangedResult);
            obj.(ChangedField{:}) = ChangedResult.(ChangedField{:});

            obj.notify('OverlaysChanged');
        end

        function CreateOverlaysParser(obj)
            obj.OverlaysParser = inputParser();
            OverlaysPropertiesName = properties(obj);
            for ii = 1:length(OverlaysPropertiesName)
                DataPropertiesDefault = obj.(OverlaysPropertiesName{ii});
                obj.OverlaysParser.addParameter(OverlaysPropertiesName{ii}, DataPropertiesDefault);
            end
        end
    end

end

