classdef Point3D < Point2D
    properties
        z
    end
    
    methods
        function obj = Point3D(x,y,z)
            obj @ Point2D(x, y);
            obj.z = z;
        end
        function r = get.r()
            r = 2;
        end
    end
end