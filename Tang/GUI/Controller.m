classdef Controller < handle
    properties
        ViewObj;
        ModelObj;
    end
    methods
        function obj = Controller(ViewObj, ModelObj)
            obj.ViewObj = ViewObj;
            obj.ModelObj = ModelObj;
        end
        function callback_WithdrawButton(obj,src,event)
            obj.ModelObj.Withdraw(obj.ViewObj.Input);
        end
         function callback_DepositButton(obj,src,event)
            obj.ModelObj.Deposit(obj.ViewObj.Input);
        end
    end
end