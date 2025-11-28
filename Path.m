classdef Path
    properties
        coefficients
        path
    end
    methods
        function obj = Path(coefficients,path)
            if nargin == 0
                return;
            end
            obj.coefficients = coefficients;
            obj.path = path;
            obj = obj.optimise();
        end
        function obj = optimise(obj)
            l = max(max(obj.path));
            ref = zeros(l);
            
            for p = obj.path.'
                ref(p(1),p(2)) = 1;
                ref(p(2),p(1)) = 1;
            end
            seen = zeros(1,l);
            seeds = zeros(1,l);
            for i = 1:l
                count = sum(ismember(obj.path,i),'all');
                if count == 0
                    seen(i) = 1;
                elseif mod(count,2) == 1
                    seeds(i) = 1;
                end
            end
            
            % Finds all open paths
            L = sum(seeds)/2;
            newpaths = zeros(L,2);
            j = 1;
            for i = 1:l
                t0 = 0;
                t1 = i;
                if seeds(t1) == 1
                    seeds(t1) = 0;
                    seen(t1) = 1;
                    while seeds(t1) == 0
                        t2 = find(ref(t1,:)==1);
                        if size(t2) == 1 & t0 ~=0
                        elseif ref(t1,t2(1)) == 1 && t2(1) ~= t0
                            t0 = t1;
                            t1 = t2(1);
                            seen(t1) = 1;
                        elseif ref(t1,t2(2)) == 1
                            t0 = t1;
                            t1 = t2(2);
                            seen(t1) = 1;
                        end
                    end
                    seeds(t1) = 0;
                    newpaths(j,:) = [i,t1];
                    j = j + 1;
                end
            end

            obj.path = newpaths;
            
            % Finds all closed cycles
            for i = 1:l
                if seen(i) == 0
                    t0 = 0;
                    t1 = i;
                    while seen(t1) == 0
                        seen(t1) = 1;
                        t2 = find(ref(t1,:) == 1);
                        if size(t2) == 1
                            seen(t2) = 1;
                        elseif ref(t1,t2(1)) == 1 && t2(1) ~= t0
                            t0 = t1;
                            t1 = t2(1);
                        else
                            t0 = t1;
                            t1 = t2(2);
                        end
                    end
                    obj.coefficients(2) = obj.coefficients(2) + 1;
                end
            end
        end
    end
end