classdef A < handle
    properties
        a
    end
    methods
        function set.a(obj,val)
            if val >=0
                obj.a = val;
            else
                error('Must be a positive');
            end
        end
    end
end