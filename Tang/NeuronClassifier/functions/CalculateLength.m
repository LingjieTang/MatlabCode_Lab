function Length = CalculateLength(Dendrite, varargin)
p = inputParser();
DefaultMethod = 'perimeter';
p.addParameter('Method', DefaultMethod);

% [r,c] = find(bwmorph(Dendrite,'endpoints'));
% p.addParameter('Seed', [c(1),r(1)]);
DefaultSeed = [0 0];
p.addParameter('Seed', DefaultSeed);

p.parse(varargin{:});

PixelNum = nnz(Dendrite);
if(PixelNum == 0)
    Length = 0;
else
    switch p.Results.Method
        case 'perimeter'
            Length = regionprops(Dendrite,'Perimeter');
            Length = [Length(:).Perimeter]./2;

        case 'geodesic'
            Length = bwdistgeodesic(Dendrite,p.Results.Seed(2), p.Results.Seed(1),'quasi-euclidean');
            Length = Length(~isinf(Length));
            Length = max(max(Length));
        case 'pixel'
            Length = PixelNum;
    end
end

end

