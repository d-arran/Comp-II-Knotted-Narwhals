% This is how a knot is coded into a computer X being the left handed
% trefoil and Y being the figure 8 knot.
X = {[1,4,2,5],[5,2,6,3],[3,6,4,1]};
Y = {[1,6,2,7],[5,2,6,3],[7,5,8,4],[3,1,4,8]};
Z = {[1,2,2,3],[8,4,9,3],[4,8,5,7],[5,1,6,10],[9,7,10,6]}
% A function to find the first even number lower than the input, used later
% to find how many times to multiply the branch of the Kauffman bracket by
% A.
function z = downeven(x)
z=x;
if mod(x,2)==1
    z=x-1;
end
end
%A function that helps with smoothing as it replaces any values in the knot
%crossings array with others after a smoothing has been implemented.
function Nodes = Replacment(rep1,rep2,with1,with2,Y)
for w = 1:length(Y)
    for e = 1:4
        if Y{w}(e) == rep1
            Y{w}(e) = with1;
        end
        if Y{w}(e) == rep2
            Y{w}(e) = with2;
        end
    end
end
Nodes=Y;
end
% A function that finds the smoothing of a knot so it outputs the two
% smoothings after evaluating one crossing
function S = Smoothing(Y)
pos11=Y{1}(2);
pos12=Y{1}(1);
pos21=Y{1}(3);
pos22=Y{1}(4);
neg11=Y{1}(4);
neg12=Y{1}(1);
neg21=Y{1}(3);
neg22=Y{1}(2);
posex=[pos11,pos12,pos21,pos22];
negex=[neg11,neg12,neg21,neg22];
% The above sets the values that have been exchanged so that later a check
% can be done to see if an unknot has come off if any two changed values
% where changed to themselves and if two uneque numbers where set to the
% same number.
if length(Y)>1
    pos=0
    neg=0
    Y
    S=Y
    S(1)=[]
    S(end)=[]

    if pos11==pos21
        Spos=Replacment(pos12,pos22,pos11,pos11,S)
        pos=1
        posex=[pos12,pos11,pos22,pos11]
    end
    if pos11==pos22
        Spos=Replacment(pos12,pos21,pos11,pos11,S)
        pos=1
        posex=[pos12,pos11,pos21,pos11]
    end
    if pos12==pos21
        Spos=Replacment(pos11,pos22,pos12,pos12,S)
        pos=1
        posex=[pos11,pos12,pos22,pos12]
    end
    if pos12==pos22
        Spos=Replacment(pos11,pos21,pos12,pos12,S)
        pos=1
        posex=[pos11,pos12,pos21,pos12]
    end

    if neg11==neg21
        Sneg=Replacment(neg12,neg22,neg11,neg11,S)
        neg=1
        negex=[neg12,neg11,neg22,neg11]
    end
    if neg11==neg22
        Sneg=Replacment(neg12,neg21,neg11,neg11,S)
        neg=1
        negex=[neg12,neg11,neg21,neg11]
    end
    if neg12==neg21
        Sneg=Replacment(neg11,neg22,neg12,neg12,S)
        neg=1
        negex=[neg11,neg12,neg22,neg12]
    end
    if neg12==neg22
        Sneg=Replacment(neg11,neg21,neg12,neg12,S)
        neg=1
        negex=[neg11,neg12,neg21,neg12]
    end


    if neg ==0
        Sneg=Replacment(Y{1}(4),Y{1}(3),Y{1}(1),Y{1}(2),S);
    end
    if pos ==0
        Spos=Replacment(Y{1}(2),Y{1}(3),Y{1}(1),Y{1}(4),S);
    end
S={[Spos,posex],[Sneg,negex]};
% The above checks if any number is being matched to two different numbers
% e.g. 2 -> 3 and 2-> 4 implyng that both 3 and 4 can be set to 2 whitch
% without this section could cause errors if done in the wrong order.
end
end
% A function that finds the Kauffman bracket of a knot.
function K = KauffBracket(X)
len=length(X);
X{end+1}=[];
Kind=cell(1,2*2^(len)-1);
Kind{1}=X;
full=1;
% Below sets up an array with all the different smoothings that the first
% knot can be broken down into, this prevents the need for a recursive
% function.
for q = 1:len
    previouslen=(full+1)/2;
    add=2^q;
    for w = 1:previouslen
        S=Smoothing(Kind{full-previouslen+w});
        Kind{full+2*w-1}=S{1};
        Kind{full+2*w}=S{2};
    end
    full=full+add;
end
% Below sets up the array for the kaufman bracket for each smoothing later
% to be combined.
syms A B
Kpoly=repmat(B,1,2*2^(len)-1);
Kpoly(:)=Kpoly(:)/B;
place=num2cell(1:2*2^(len)-1);
for o = 1:length(place)
    list=[place(o)];
    last=list{end};
    while last ~= 1
        if mod(last,2)==1
            work=downeven(last);
            work=work/2;
            list=[list,work];
            last=work;
        else
            list=[list,(last/2)];
            last=last/2;
        end
    end
    place{o}=list;
end
% Above and below figures out the 'path' that each smoothing took as to figure out
% what power of A to multiply it by.
Kval=zeros(1,2*2^(len)-1);
for j = 1:length(place)
    sum=1;
    for k = 1:length(place{j})
        if mod(place{j}{k},2) == 1
            sum = sum-1;
        else
            sum=sum+1;
        end
    end
    Kval(j)=sum;
end
for k = 1:length(Kval)
    Kpoly(k)=Kpoly(k)*A^(Kval(k));
end
positive=2:2:2*2^(len)-1;
negative=1:2:2*2^(len)-1;
for l = 1:length(positive)
    U=Kind{positive(l)}(end);
    I=U{1};
    if I(1)==I(2) || I(3)==I(4)
        Total=positive(l);
        Working=positive(l);
        for k = 1:len
            next = zeros(1, 2*length(Working));
            update = 1;
            for x = Working
                next(update) = 2*x;
                next(update+1) = 2*x + 1;
                update = update + 2;
            end
            Total = [Total, next];
            Working = next;
        end
        for w=1:length(Total)
            if Total(w)<2*2^(len)
                Kpoly(Total(w))=Kpoly(Total(w))*(-A^2-A^(-2));
            end
        end
    end
end
for l = 2:length(negative)
    U=Kind{negative(l)}(end);
    I=U{1};
    if I(1)==I(2) || I(3)==I(4)
        Total2=negative(l);
        Working=negative(l);
        for k = 1:len
            next = zeros(1, 2*length(Working));
            update = 1;
            for x = Working
                next(update) = 2*x;
                next(update+1) = 2*x + 1;
                update = update + 2;
            end
            Total2 = [Total2, next];
            Working = next;
        end
        for w=1:length(Total2)
            if Total2(w)<2*2^(len)+1
                Kpoly(Total2(w))=Kpoly(Total2(w))*(-A^2-A^(-2));
            end
        end
            
        
    end
end
K=0;
for h = 0:2^len-1
    K=K+Kpoly(end-h);
end
K=simplify(K);
K=simplify(K);
end
function writhe = Writhe(Crossings)
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

function J = JohnesPoly(X)
syms A t
K=KauffBracket(X);
W=Writhe(X);
J=subs(((-A^3)^(-W))*K,A,t^(-1/4));
J=simplify(J);
end
JohnesPoly(X)
