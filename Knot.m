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
            if nargin == 0 % edge case for empty knot
                obj.crossings = 0;
                obj.writhe = 0;
                obj.kbracket = 0;
                obj.jones = 0;
                return;
            end
            obj.diagram = diagram;
            obj.crossings = size(diagram,1);
            obj = obj.w(); % calculate the writhe
            obj = obj.kauffman(); % calulcate the kauffman bracket and jones polynomial
        end
        function obj = w(obj)
            obj.writhe = 0;
            L = max(max(obj.diagram));
            for i = 1:obj.crossings
                if isequal([obj.diagram(i,2),obj.diagram(i,4)],[L,1])     % edge case
                    obj.writhe = obj.writhe-1;
                elseif isequal([obj.diagram(i,2),obj.diagram(i,4)],[1,L]) % edge case
                    obj.writhe = obj.writhe+1;
                elseif obj.diagram(i,2)<obj.diagram(i,4) % negative crossing
                    obj.writhe = obj.writhe-1;
                else                                     % positive crossing
                    obj.writhe = obj.writhe+1;
                end
            end
        end
        function obj = kauffman(obj)
            L = size(obj.diagram,1);
            i = 1;
            obj.paths = cell(L,2); % preallocate memory for resolved crossings
            for crossing = obj.diagram.'
                obj.paths{i,1} = Path([1,0],[crossing(1),crossing(2);crossing(3),crossing(4)]); % A resolution 
                obj.paths{i,2} = Path([-1,0],[crossing(1),crossing(4);crossing(2),crossing(3)]); % A^-1 resolution
                i = i+1;
            end
            
            resolved = {obj.paths{1,1},obj.paths{1,2}}; % initialise combination of resolutions
            
            % finds every combination of resolved crossing
            for i = 2:L
                k = 1;
                newresolved = cell(1,2^i); % preallocate memory for new resolved cell array
                for path = resolved
                    for j = 1:2
                        c = path{1}.coefficients + obj.paths{i,j}.coefficients; % new coefficients
                        p = [path{1}.path;obj.paths{i,j}.path];                 % new path
                        newresolved{k} = Path(c,p);
                        k = k + 1;
                    end
                end
                resolved = newresolved;
            end
            
            syms A
            obj.kbracket = 0; % initialise kauffman bracket
            B = -(A^2+A^-2);  % <OUD> = B*<D>
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