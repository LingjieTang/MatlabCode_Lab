classdef Point2D < handle
    properties
        x
        y 
    end
    properties(Dependent)
        r
    end
    events
        changed
    end
    
    methods
        function obj = Point2D(x,y)
            obj.x = x;
            obj.y = y;
        end
        function r = get.r(obj)
           r = obj.x * obj.y;
        end
        function obj = DataChanged(obj)
            obj.notify('changed',TimeStamp());
        end
        function obj = addx1(obj,scr)
            disp(['Listener called at',num2str(scr.ts)]);
            scr.Source.x = scr.Source.x + 1;
        end
    end
end
