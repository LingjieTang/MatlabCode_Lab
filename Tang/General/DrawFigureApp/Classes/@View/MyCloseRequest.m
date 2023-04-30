function MyCloseRequest(obj, src)
%The callback function of closing the main frame
delete(src); %Delete the figure

%Delete listeners
delete(obj.hDataListener); 
delete(obj.hOverlaysListener); 
delete(obj.hParametersListener);
end

