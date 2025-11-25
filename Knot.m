classdef Knot
    properties
        diagram
        crossings
        writhe
    end
    methods
        function obj = Knot(diagram)
            obj.diagram = diagram;
            obj.crossings = size(diagram,1);
            obj = obj.w();
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
    end
end