classdef myclass
    properties (Dependent)
     a
    end % methods
    methods
        function val=get.a(obj)
            disp("This is the get.a of "+class(obj))  %common step
            
            val=obj.customizedValues;
        end
    end
    methods (Abstract)
        val=customizedValues(obj)
    end
end

