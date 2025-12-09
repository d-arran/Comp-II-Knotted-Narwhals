X = {[1,4,2,5],[5,2,6,3],[3,6,4,1]};
Y = {[1,6,2,7],[5,2,6,3],[7,5,8,4],[3,1,4,8]};
function z = downeven(x)
z=x;
if mod(x,2)==1
    z=x-1;
end
end

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
if length(Y)>1
    pos=0;
    neg=0;
    S=Y;
    S(1)=[];
    S(end)=[];
    if Y{1}(1)==Y{1}(4)
        Spos= Replacment(Y{1}(2),Y{1}(3),Y{1}(1),Y{1}(4),S);
        pos=1;
        posex=[Y{1}(2),Y{1}(1),Y{1}(3),Y{1}(4)];
    end
    if Y{1}(2)==Y{1}(3)
        Spos= Replacment(Y{1}(1),Y{1}(4),Y{1}(2),Y{1}(3),S);
        pos=1;
        posex=[Y{1}(1),Y{1}(2),Y{1}(4),Y{1}(3)];
    end
    if Y{1}(1) == Y{1}(2)
        Sneg = Replacment(Y{1}(3),Y{1}(4),Y{1}(1),Y{1}(2),S);
        neg=1;
        negex=[Y{1}(3),Y{1}(1),Y{1}(4),Y{1}(2)];
    end
    if Y{1}(3) == Y{1}(4)
        Sneg = Replacment(Y{1}(1),Y{1}(2),Y{1}(3),Y{1}(4),S);
        neg=1;
        negex=[Y{1}(1),Y{1}(3),Y{1}(2),Y{1}(4)];
    end
    if neg ==0
        Sneg=Replacment(Y{1}(4),Y{1}(3),Y{1}(1),Y{1}(2),S);
    end
    if pos ==0
        Spos=Replacment(Y{1}(2),Y{1}(3),Y{1}(1),Y{1}(4),S);
    end
S={[Spos,posex],[Sneg,negex]};
end
end

function K = KauffBracket(X)
len=length(X);
X{end+1}=[];
Kind=cell(1,2*2^(len)-1);
Kind{1}=X;
full=1;
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
Kval=zeros(1,2*2^(len)-1);
place{9};
place{9}{1};
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
