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
            obj = obj.permutations();
            obj = obj.components();
            obj = obj.planar();
            obj.closure = Knot(obj.diagram);
        end
        function obj = permutations(obj)
            length = size(obj.word,2);
            obj.p = zeros(length+1,obj.strands);
            obj.p(1,:) = 1:obj.strands;
            for i = 1:length
                t = abs(obj.word(i));
                temp = obj.p(i,:);
                temp(t:t+1) = flip(temp(t:t+1));
                obj.p(i+1,:) = temp;
            end
        end
        function obj = components(obj)
            ref = [obj.p(end,:);obj.p(1,:)].';
            [~,id] = sort(ref(:,1));
            ref = ref(id,:);
            seen = zeros(1,obj.strands);
            obj.cycles = cell(0);
            for i = 1:obj.strands
                if seen(i) == 0
                    t = i;
                    cycle = zeros(0);
                    while seen(t) == 0
                        cycle(end+1) = t;
                        seen(t) = 1;
                        t = ref(t,2);
                    end
                    obj.cycles{end+1} = cycle;
                end
            end
        end
        function obj = planar(obj)
            obj.diagram = zeros(size(obj.word,2),4);
            i = 1;
            for cycle = obj.cycles
                t = i;
                for k = cycle{1}
                    for j = 1:size(obj.word,2)
                        w = obj.word(j);
                        pair = obj.p(j,abs(w):abs(w)+1);
                        f = find(pair==k);
                        id = f + sign(w);
                        if size(f,2) == 0
                        elseif id == 0
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
                obj.diagram(obj.diagram==i) = t;
            end
        end
    end
end