classdef Braid
    properties
        word
        diagram
        strands
        cycles
        p
        closure
    end
    methods
        function obj = Braid(word)
            obj.word = word;
            obj.strands = max(abs(obj.word))+1;
            obj = obj.permutations(); % determine the positions of each strand after every permutation
            obj = obj.components(); % determine the cycles present in the word
            obj = obj.planar(); % create planar diagram
            obj.closure = Knot(obj.diagram); % create knot object using previously calculated planar diagram
        end
        function obj = permutations(obj)
            length = size(obj.word,2);
            obj.p = zeros(length+1,obj.strands);
            obj.p(1,:) = 1:obj.strands; % initialise permutation array
            for i = 1:length % perform each permutation
                t = abs(obj.word(i));
                temp = obj.p(i,:);
                temp(t:t+1) = flip(temp(t:t+1));
                obj.p(i+1,:) = temp;
            end
        end
        function obj = components(obj)
            ref = [obj.p(end,:);obj.p(1,:)].';
            [~,id] = sort(ref(:,1)); % sort left column of reference array to line up 1-n without disturbing relations
            ref = ref(id,:);
            seen = zeros(1,obj.strands); % preallocate memory
            obj.cycles = cell(0); % create empty cell array, no preallocation because we cant determine how many cycles there are
            for i = 1:obj.strands
                if seen(i) == 0 % so we don't double count cycles
                    t = i;
                    cycle = zeros(0);
                    while seen(t) == 0 % go through reference array until looped back to original element
                        cycle(end+1) = t;
                        seen(t) = 1;
                        t = ref(t,2);
                    end
                    obj.cycles{end+1} = cycle;
                end
            end
        end
        function obj = planar(obj)
            obj.diagram = zeros(size(obj.word,2),4); % preallocate memory
            i = 1;
            for cycle = obj.cycles % loop over each component of the link
                t = i;
                for k = cycle{1} % loop over each strand of the component
                    for j = 1:size(obj.word,2) % loop over each transposition
                        w = obj.word(j);
                        pair = obj.p(j,abs(w):abs(w)+1);
                        f = find(pair==k); % determine the position of the current strand after the transposition
                        id = f + sign(w); % each case is identified by this id, {1,2} x {-1,1} = {0,1,2,3}, saves one comparison
                        if size(f,2) == 0 % pass if the strand is not affected by current transposition
                        elseif id == 0 % label diagram accordingly
                            obj.diagram(j,1:2:3) = i:i+1;
                            i = i + 1;
                        elseif id == 1
                            obj.diagram(j,4:-2:2) = i:i+1;
                            i = i + 1;
                        elseif id == 2
                            obj.diagram(j,2:2:4) = i:i+1;
                            i = i + 1;
                        elseif id == 3
                            obj.diagram(j,1:2:3) = i:i+1;
                            i = i + 1;
                        end
                    end
                end
                obj.diagram(obj.diagram==i) = t; % fix the last crossing
            end
        end
    end
end