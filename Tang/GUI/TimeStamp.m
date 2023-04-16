classdef TimeStamp < event.EventData
    properties
        ts
        data
    end
    methods
        function obj = TimeStamp(Point)
            obj.ts = clock;
            obj.data = Point;
        end
    end
end