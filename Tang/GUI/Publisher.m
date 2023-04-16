classdef Publisher < handle
    events
        changed
    end
    methods
        function DataChanged(obj)
            obj.notify('changed', TimeStamp(obj.x));
        end
    end
end