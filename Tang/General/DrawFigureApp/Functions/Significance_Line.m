%% Information
%Aim: Draw draw asterisks representing significance. Horizontal and side
%line are optional.
%
%Prerequisite: two data, and also the position to draw horizontal line
%
%Output: Automatically draw the asterisks. A YMax that indicates the max
%y-value of the asterisk can be output for the purpose of adjusting the
%ylim of the figure
%
%Author: Tang Lingjie
%
%Version: 2023/03/14
%
%Email: tanglj0222@gmail.com; wasdiojk@126.com

function [YMax] = Significance_Line(x1, x2, data1, data2, p, c, FontName, FontSize, Side, ShowpValue)
hold on
x = mean([x1; x2]);
ShowHorizontalLine = true;

ylim auto
LimitY = ylim;
if (x1 ~= x2)
    y1 = max(max(data1), mean(data1) + std(data1) / sqrt(length(data1)));
    y2 = max(max(data2), mean(data2) + std(data2) / sqrt(length(data2)));
    y3 = max(y1, y2) + 0.05 * (LimitY(2) - LimitY(1)); %The y position to draw
else %For linechart
    y1 = mean(data1) + std(data1) / sqrt(length(data1));
    y2 = mean(data2) + std(data2) / sqrt(length(data2));
    y3 = max(y1, y2) + 0.01 * (LimitY(2) - LimitY(1));
end


%horizontal line
y = y3 + 0.02 * (LimitY(2) - LimitY(1)); %The y position to draw asterisks

LineWidth = 1;

if(~ShowpValue)
    if p < 0.001
        Text = '***';
    elseif (0.001 <= p) && (p < 0.01)
        Text = '**';
    elseif (0.01 <= p) && (p < 0.05)
        Text = '*';
    elseif ((0 <= p) && (p <= 1) && (x1 ~= x2))
        %Text = 'n.s.';
        %y = y + 0.01 * (LimitY(2) - LimitY(1));
        ShowHorizontalLine = false;
    end
else
    Text = ['p = ', num2str(p, 3)];
end

if (exist('Text', 'var'))
    text(x, y, Text, 'Fontname', FontName, 'FontSize', FontSize, 'Color', ...
        c, 'HorizontalAlignment', 'center', 'HandleVisibility', 'on')
end

if ((x1 ~= x2) && ShowHorizontalLine)
    plot([x1; x2], [1; 1] * y3, '-', 'Color', c, 'LineWidth', LineWidth); % Horizontal line
end

if (Side)
    plot([1; 1] * x1, [y1 + 0.025 * (LimitY(2) - LimitY(1)); y3], '-', 'Color', c, 'LineWidth', LineWidth); % Left line
    plot([1; 1] * x2, [y2 + 0.025 * (LimitY(2) - LimitY(1)); y3], '-', 'Color', c, 'LineWidth', LineWidth); % Right line
end

hold off
YMax = y;
end
