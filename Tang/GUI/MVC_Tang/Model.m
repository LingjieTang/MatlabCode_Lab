classdef Model < handle

    properties
        Balance
    end

    events
        BalanceChanged
    end

    methods
        function obj = Model(Balance)
            validateattributes(Balance, {'numeric'}, {'>=', 0});
            obj.Balance = Balance;
        end

        function Deposit(obj, val)
            obj.Balance = obj.Balance + val;
            obj.notify('BalanceChanged');
        end

        function Withdraw(obj, val)
            obj.Balance = obj.Balance - val;
            obj.notify('BalanceChanged');
        end
    end

end

