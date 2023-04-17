classdef View < handle
    properties
        ModelObj;
        ControllerObj;
        ViewSize;
        hFig;
        WithdrawButton;
        DepositButton;
        BalanceText;
        BalanceBox;
        InputText;
        InputBox;
    end

    methods(Access = private)
        function obj = View(ModelObj)
            if(nargin == 0)
                 obj.ModelObj = Model(100);
            else
                 obj.ModelObj = ModelObj;
            end
            obj.ControllerObj = obj.MakeController();
            obj.BuildUI();
            obj.ModelObj.addlistener('BalanceChanged', @obj.UpdateBalanceBox);
            obj.AttachToController();
        end
    end
    methods(Static)
        function obj = GetView(ModelObj)
            persistent LocalViewObj;
            if isempty(LocalViewObj)||~isvalid(LocalViewObj)
                LocalViewObj = View(ModelObj); 
            end
                obj = LocalViewObj;            
        end
    end
    
    methods
        function obj = MakeController(obj)
            obj = Controller(obj);
        end

        function BuildUI(obj)
            obj.ViewSize = [100, 100, 300, 300];
            obj.hFig = figure('pos',obj.ViewSize);
            obj.WithdrawButton = uicontrol('Parent', obj.hFig,  'Position', [60 28 60 28] ...
                , 'Tag', 'WithdrawButton', 'string', 'Withdraw');
             obj.DepositButton = uicontrol('Parent', obj.hFig, 'Position', [180 28 60 28] ...
                , 'Tag', 'DepositButton', 'string', 'Deposit');
             obj.BalanceText = uicontrol('Parent', obj.hFig, 'Style', 'text', 'Position', [20 142 60 28] ...
                , 'Tag', 'Text', 'String', 'Balance');
            obj.BalanceBox = uicontrol('Parent', obj.hFig, 'Style', 'text', 'Position', [180 142 60 28] ...
                , 'Tag', 'BalanceBox', 'String', obj.ModelObj.Balance);
            obj.InputText = uicontrol('Parent', obj.hFig, 'Style', 'text', 'Position', [20 85 60 28] ...
                , 'Tag', 'InputText', 'String', 'Input');
            obj.InputBox =  uicontrol('Parent', obj.hFig, 'Style', 'edit', 'Position', [100 85 180 28] ...
                , 'Tag', 'InputBox');
        end
        
        function  UpdateBalanceBox(obj, src, event)
                 obj.BalanceBox.String =  obj.ModelObj.Balance;
        end

        function  AttachToController(obj)
            controller = obj.ControllerObj;
            set(obj.DepositButton, 'callback', @controller.DepositCallback);
            set(obj.WithdrawButton, 'callback', @controller.WithdrawCallback);
         end

    end
end

