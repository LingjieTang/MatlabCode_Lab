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
        ControlObj
    end
    properties(Dependent)
        Input;
    end
    
    methods
        function obj = View(ModelObj)
            obj.ModelObj = ModelObj;
            obj.ViewSize = [100, 100, 300, 300];
            obj.BuildUI();
            obj.ModelObj.addlistener('BalanceChanged',@obj.UpdateBalance);
            obj.ControlObj = obj.MakeController();
            obj.AttachToController(obj.ControlObj);
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
            obj.Text = uicontrol('Parent', obj.hFig, 'Style', 'text', 'Position', [20 142 60 28] ...
                , 'Tag', 'Text', 'String', 'Balance');
            obj.BalanceBox = uicontrol('Parent', obj.hFig, 'Style', 'text', 'Position', [180 142 60 28] ...
                , 'Tag', 'BalanceBox', 'String', obj.ModelObj.Balance);
            obj.NumBox =  uicontrol('Parent', obj.hFig, 'Style', 'edit', 'Position', [100 85 180 28] ...
                , 'Tag', 'NumBox');
            %obj.UpdateBalance();
        end
        function UpdateBalance(obj,scr,data)
            set(obj.BalanceBox, 'String',num2str(obj.ModelObj.Balance));
        end
        function ControlObj = MakeController(obj)
            ControlObj = Controller(obj, obj.ModelObj);
        end
        function AttachToController(obj,controller)
            funcH = @controller.callback_WithdrawButton;
            set(obj.WithdrawButton,'callback',funcH);
            funcH = @controller.callback_DepositButton;
            set(obj.DepositButton, 'callback',funcH);
        end
        
    end
end