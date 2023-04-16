function obj = addx1(obj,scr)
    disp(['Listener called at',num2str(scr.ts)]);
    scr.Source.x = scr.Source.x + 1;
end