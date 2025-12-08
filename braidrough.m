% word would be input parameter for Braid object
word = [-1,2,-1,2];
% calculated during construction, stored as properties
s = size(word,2);
b = max(abs(word))+1;

% preallocate memory and initialise
p = zeros(s+1,b);
p(1,:) = 1:b;

% loop over every transposition in the word, finding the full permutation
% at each step
for i = 1:s
    np = p(i,:);
    w = abs(word(i));
    np(w:w+1) = flip(np(w:w+1));
    p(i+1,:) = np;
end

% preallocate memory
crossings = zeros(s,4);

% loop over strand
i = 1;
for k = [1,2,3] % this will need to be generalised - it needs to go in the correct order through the braid for each connected component of the braid
for j = 1:s % loop across all transpositions
w = word(j);
pair = p(j,abs(w):abs(w)+1);
% finds where the current strand goes in the next transposition, maybe need
% a check for identity mappings
f = find(pair==k);
id = f + sign(w);
% each scenario is uniquely identified by this id
if id == 0
    crossings(j,1:2:3) = i:i+1;
    i = i + 1;
elseif id == 1
    crossings(j,4:-2:2) = i:i+1; % stupid different case makes this hard to avoid the if else chain, maybe use switch statements if anyone is good at programming (and if they even exist in matlab)
    i = i + 1;
elseif id == 2
    crossings(j,2:2:4) = i:i+1;
    i = i + 1;
elseif id == 3
    crossings(j,1:2:3) = i:i+1;
    i = i + 1;
end
end
end
% this will also need to be generalised because this just fixes one
% component's final entry
crossings(crossings==2*s+1) = 1;
Knot(crossings) % then we can put this diagram into the Knot object, i know this works for figure-8 by looking at the knot invariants listed