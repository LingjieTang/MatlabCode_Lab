classdef Point3D < Point2D
    properties
        z = 0;
    end
    properties(Dependent)
        r
    end
    
    methods
        function obj = Point3D(x,y,z)
            obj @ Point2D(x, y);
            obj.z = z;
        end
    end
end