classdef Knot
    properties
        diagram
        crossings
        writhe
        kbracket
        jones
        paths
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
            L = max(max(obj.diagram));
            for i = 1:obj.crossings
                if isequal([obj.diagram(i,2),obj.diagram(i,4)],[L,1])
                    obj.writhe = obj.writhe-1;
                elseif isequal([obj.diagram(i,2),obj.diagram(i,4)],[1,L])
                    obj.writhe = obj.writhe+1;
                elseif obj.diagram(i,2)<obj.diagram(i,4)
                    obj.writhe = obj.writhe-1;
                else
                    obj.writhe = obj.writhe+1;
                end
            end
        end
        function obj = kauffman(obj)
            L = size(obj.diagram,1);
            i = 1;
            obj.paths = cell(L,2);
            for crossing = obj.diagram.'
                obj.paths{i,1} = Path([1,0],[crossing(1),crossing(2);crossing(3),crossing(4)]);
                obj.paths{i,2} = Path([-1,0],[crossing(1),crossing(4);crossing(2),crossing(3)]);
                i = i+1;
            end
            
            resolved = {obj.paths{1,1},obj.paths{1,2}};
            
            for i = 2:L
                k = 1;
                newresolved = cell(1,2^i);
                for path = resolved
                    for j = 1:2
                        c = path{1}.coefficients + obj.paths{i,j}.coefficients;
                        p = [path{1}.path;obj.paths{i,j}.path];
                        newresolved{k} = Path(c,p);
                        k = k + 1;
                    end
                end
                resolved = newresolved;
            end
            
            syms A
            obj.kbracket = 0;
            B = -(A^2+A^-2);
            for i = 1:2^L
                obj.kbracket = obj.kbracket + A^(resolved{i}.coefficients(1)) * B^(resolved{i}.coefficients(2)-1);
            end
            obj.kbracket = simplify(obj.kbracket);
            jpoly = (-A^3)^-obj.writhe*obj.kbracket;
            syms t
            obj.jones = simplify(subs(jpoly,A,t^(-1/4)));
        end
    end
end