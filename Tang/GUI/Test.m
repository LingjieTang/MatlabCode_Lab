Balance = 500;
Input = 0;

hFig = figure('Position',[100, 100, 300, 300]);

BalanceBox = uicontrol('Parent', hFig, 'Style', 'text', 'Position', [180 142 60 28] ...
      , 'Tag', 'BalanceBox', 'String', Balance);
BalanceBoxText = uicontrol('Parent', hFig, 'Style', 'text', 'Position', [20 142 60 28] ...
      , 'Tag', 'BalanceBoxText', 'String', 'Balance');
InputBox =  uicontrol('Parent', hFig, 'Style', 'edit', 'Position', [100 85 180 28] ...
      , 'Tag', 'InputBox', 'String', Input);
InputBoxText =  uicontrol('Parent', hFig, 'Style', 'text', 'Position', [20 85 60 28] ...
      , 'Tag', 'InputBoxText', 'String', 'Input');
WithdrawButton = uicontrol('Parent', hFig,  'Position', [60 28 60 28] ...
      , 'Tag', 'WithdrawButton', 'String', 'withdraw');
DepositButton = uicontrol('Parent', hFig, 'Position', [180 28 60 28] ...
      , 'Tag', 'DepositButton', 'String', 'deposit');

set(WithdrawButton, 'Callback', @(o,e)Withdraw_Callback(o,e));
set(DepositButton, 'Callback', @(o,e)Deposit_Callback(o,e));

function Withdraw_Callback(o,~)
    hFig = o.Parent;
    InputBox = findobj(hFig, 'Tag', 'InputBox');
    Input = str2double(InputBox.String);
    BalanceBox =  findobj(hFig, 'Tag', 'BalanceBox');
    Balance = str2double(BalanceBox.String);
    Balance = Balance - Input;
    BalanceBox.String = Balance;
end