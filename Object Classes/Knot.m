classdef Knot
    properties
        diagram
        crossings
        components
        linknumbers
        writhe
        kbracket
        jones
        paths
    end
    methods
        function obj = Knot(diagram)
            obj.diagram = diagram;
            obj.crossings = size(diagram,1);
            obj = obj.lk(); % calculate the linking number
            obj = obj.w(); % calculate the writhe
            obj = obj.kauffman(); % calulcate the kauffman bracket and jones polynomial
        end
        function obj = w(obj)
            obj.writhe = 0;
            for i = 1:obj.crossings
                if abs(obj.diagram(i,2)-obj.diagram(i,4)) == 1
                    if obj.diagram(i,2)<obj.diagram(i,4) % negative crossing
                        obj.writhe = obj.writhe - 1;
                    else                                 % positive crossing
                        obj.writhe = obj.writhe + 1;
                    end
                else                                     % edge cases
                    for component = obj.components
                        if ismember(obj.diagram(i,2),component{1})
                            L = [component{1}(1), component{1}(end)];
                        end
                    end
                    if isequal([obj.diagram(i,2),obj.diagram(i,4)],L) % final crossing in the link
                        obj.writhe = obj.writhe + 1;
                    else
                        obj.writhe = obj.writhe - 1;
                    end
                end
            end
        end
        function obj = lk(obj)
            m = max(max(obj.diagram));
            under = obj.diagram(:,1:2:3);
            over = obj.diagram(:,2:2:4);
            cross = [under; over];
            ref = zeros(m); % preallocate memory
            for c = cross.' % create adjacency matrix
                ref(c(1),c(2)) = 1;
                ref(c(2),c(1)) = 1;
            end
            obj.components = cell(0); % create empty cell array, no preallocation because we don't know how many components there are
            i = 0;
            while i ~= m
                i = i + 1;
                f = find(ref(i,:)==1); 
                if size(f,2) == 0                 % edge case
                    obj.components{end+1} = i;
                elseif size(f,2) == 1             % edge case
                    obj.components{end+1} = i:f;
                    i = f;
                else
                    obj.components{end+1} = i:f(2); % this is the end of the cycle, we know that the arcs increment by 1 each time so we can use this as a shortcut
                    i = f(2);
                end
            end
            l = size(obj.components,2);
            links = cell(0);
            for i = 1:l % loop over each crossing to find which crossings are part of links
                incross = [ismember(under(:,1),obj.components{i}),ismember(over(:,1),obj.components{i})];
                t = mod(sum(ismember(incross,1),2),2).';
                f = find(t==1);
                links{end+1} = f; % store the rows for each link crossing (with the respective component number)
            end
            obj.linknumbers = zeros(l);
            for i = 1:l-1
                for j = i+1:l
                    clinks = intersect(links{i},links{j}); % link crossings containing both components in question
                    linknumber = 0;
                    for link = clinks
                        if abs(obj.diagram(link,2)-obj.diagram(link,4)) == 1
                            if obj.diagram(link,2)<obj.diagram(link,4) % negative crossing
                                linknumber = linknumber-1;
                            else                                       % positive crossing
                                linknumber = linknumber+1;
                            end
                        else                                           % edge cases
                            for component = obj.components
                                if ismember(obj.diagram(link,2),component{1})
                                    L = [component{1}(1),component{1}(end)];
                                end
                            end
                            if isequal([obj.diagram(link,2),obj.diagram(link,4)],L)
                                linknumber = linknumber + 1;
                            else
                                linknumber = linknumber - 1;
                            end
                        end
                    end
                    obj.linknumbers(i,j) = linknumber;
                    obj.linknumbers(j,i) = linknumber; % fill in the linking number matrix
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