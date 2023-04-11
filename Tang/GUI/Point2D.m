classdef Point2D
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
           r = sqrt(obj.x^2+obj.y^2);
           disp('get.r called');
        end
    end
end
