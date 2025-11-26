classdef Knot
    properties
        diagram
        crossings
        writhe
        kbracket
    end
    methods
        function obj = Knot(diagram)
            obj.diagram = diagram;
            obj.crossings = size(diagram,1);
            obj = obj.w();
            obj = obj.kauffman();
        end
        function obj = w(obj)
            obj.writhe = 0;
            temp = mod(obj.diagram,obj.crossings*2);
            for i = 1:obj.crossings
                if temp(i,2)<temp(i,4)
                    obj.writhe = obj.writhe+1;
                else
                    obj.writhe = obj.writhe-1;
                end
            end
        end
        function obj = kauffman(obj)
        end
    end
    methods (Static)
        function path = optimise(path)
            l = max(max(path));

            b = zeros(l,2);
            b(:,1) = 1:l;

            for i = 1:size(path,1)
                if path(i,1) > path(i,2)
                    path(i,:) = flip(path(i,:));
                end
            end

            j = 1;
            for i = path(:,1).'
                b(i,2) = path(j,2);
                j = j + 1;
            end
            
            flags = zeros(1,l);
            for i = 1:l
                flags(i) = mod(sum(ismember(path,i),'all'),2);
            end
            
            npaths = sum(flags)/2;
            path = zeros(npaths,2);
            
            k = 1;
            for i = 1:l
                if flags(i) == 1
                    t = b(i,2);
                    path(k,1) = i;
                    flags(i) = 0;
                    while flags(t) == 0
                        t = b(t,2);
                    end
                    path(k,2) = t;
                    flags(t) = 0;
                    k = k+1;
                end
            end
        end
    end
end