classdef Knot
    properties
        diagram
        crossings
        writhe
        kbracket
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
            i = 1;
            obj.paths = cell(3,2);
            for crossing = obj.diagram.'
                obj.paths{i,1} = Path(1,[crossing(1),crossing(2);crossing(3),crossing(4)]);
                obj.paths{i,2} = Path(-1,[crossing(1),crossing(4);crossing(2),crossing(3)]);
                i = i+1;
            end
        end
    end
end