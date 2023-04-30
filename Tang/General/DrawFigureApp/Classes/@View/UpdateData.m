function UpdateData(obj, ~, ~)


%Create tiled layout
if(~isempty(obj.hTiledLayout))
    delete(obj.hTiledLayout);
end
obj.hTiledLayout = tiledlayout('flow','Parent',obj.hFig);

%Analyze each variable
for VariableNow = obj.PartialAnalyze 
    %Find the relative position in the PartialAnalyze
    ActivehAxis = find(obj.PartialAnalyze == VariableNow, 1);

    %Draw specific figure corresponding to FigureType
    obj.DrawSpecificFig(ActivehAxis);
end

%Also update overlays and parameters
obj.UpdateOverlays(); 
obj.UpdateParameters(); 

end
