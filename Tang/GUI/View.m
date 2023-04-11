classdef View < handle
    properties
        hFig
        hEdit
    end
     properties (Dependent)
       text
    end
    methods
        function obj = View
            obj.hFig = figure;
            obj.hEdit = uicontrol('Parent',obj.hFig,'Style','edit');
        end
        function str = get.text(obj)
            str = get(obj.hEdit, 'String');
        end
    end
end