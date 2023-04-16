classdef View < handle
    properties
        hFig
        ViewSize
        WithdrawButton
        DepositButton
        BalanceBox
        NumBox
        Text
        ModelObj
        ControllObj
    end
    properties(Dependent)
        Input;
    end
    
    methods
        function obj = View(ModelObj)
            obj.ModelObj = ModelObj;
            obj.ViewSize = [100, 100, 300, 300];
            obj.ModelObj.addlistener('BalanceChanged',@obj.UpdateBalance);
        end
        function Input = get.Input(obj)
            Input = get(obj.NumBox, 'string');
            Input = str2double(Input);
        end
        function BuildUI(obj)
            obj.hFig = figure('pos',obj.ViewSize);
            obj.WithdrawButton = uicontrol('Parent', obj.hFig,  'Position', [60 28 60 28] ...
      , 'Tag', 'WithdrawButton', 'string', 'withdraw');
            obj.DepositButton = uicontrol('Parent', obj.hFig, 'Position', [180 28 60 28] ...
      , 'Tag', 'DepositButton', 'string', 'deposit');
            obj.Text = uicontrol('Parent', hFig, 'Style', 'text', 'Position', [20 142 60 28] ...
      , 'Tag', 'BalanceBoxText', 'String', 'Balance');
        end
    end
end