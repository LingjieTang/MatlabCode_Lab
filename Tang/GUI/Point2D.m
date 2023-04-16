classdef Point2D < handle
    properties
        x
        y 
    end
    properties(Dependent)
        r
    end
    
    methods
        function obj = Point2D(x,y)
            obj.x = x;
            obj.y = y;
        end
        function r = get.r(obj)
           r = obj.x * obj.y;
        end
        function obj = add2x(obj)
            Pub = Publisher();
            Pub.addlistener('changed', @addx1)
            Pub.DataChanged(obj.x);
        end
    end
end
