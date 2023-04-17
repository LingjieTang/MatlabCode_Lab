classdef Controller < handle

    properties
        ModelObj;
        ViewObj;
    end

    methods
        function obj = Controller(ViewObj)
            obj.ViewObj = ViewObj;
            obj.ModelObj = obj.ViewObj.ModelObj;
        end

        function obj = DepositCallback(obj, src, event)
            Input = str2double(obj.ViewObj.InputBox.String);
            validateattributes(Input, {'numeric'}, {'>=', 0}, 'DepositCallback', 'InputNum');
            obj.ModelObj.Deposit(Input);
        end

        function obj = WithdrawCallback(obj, src, event)
            Input = str2double(obj.ViewObj.InputBox.String);
            validateattributes(Input, {'numeric'}, {'>=', 0}, 'DepositCallback', 'InputNum');
            obj.ModelObj.Withdraw(Input);
        end

    end

end


