X = {[1,4,2,5],[5,2,6,3],[3,6,4,1]}

function writhe = WritheCalc(Crossings)
%Extract the 2nd and 4th values and compare them to see if the crossing is
%left or right.
writhe = 0;
for i = 1:length(Crossings)
    x=Crossings{i};
    diff=x(2)-x(4);
    if (x(2)+x(4))==(2*(length(Crossings))+1)
        % If the Crossing is the one with the start and end of the arc labeling then the inverse is true.
        diff = -diff;
    end
    if diff > 0
        writhe = writhe+1;
    end
    if diff < 0
        writhe = writhe-1;
    end
end
end
WritheCalc(X)