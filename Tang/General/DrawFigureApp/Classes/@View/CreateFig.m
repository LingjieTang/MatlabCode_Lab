function CreateFig(obj)
%Create a main frame
obj.hFig = figure('Name', "Drawn Figure");

%Callback function of the main frame
obj.hFig.CloseRequestFcn = @(src,event) obj.MyCloseRequest(src);
end

