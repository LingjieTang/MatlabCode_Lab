classdef TimeStamp < event.EventData
    properties
        ts
    end
    methods
        function obj = TimeStamp()
            obj.ts = clock;
        end
    end
end