function [] = Test(Matrix)

for ii = 1:1024
    for jj = 1:1024
        if(Matrix(1025-jj, ii))
            scatter(ii, jj, 5, "blue")
            hold on
        end
    end
end
xlim([0 1024])
ylim([0 1024])

end


