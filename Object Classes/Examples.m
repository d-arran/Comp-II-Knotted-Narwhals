%========================================================================%

% Examples demonstrating the ideas from the written report for the
% Computational Mathematics II Knots group project. Running the name of the
% knot/braid in the command window will print the properties of the
% knot/braid to the command window. You can then use commands such as
% Knotbook.closure to view the properties of the object. Some of these
% properties did not strictly need to be properties, however it simplified
% the data processing.

%========================================================================%



% example for section 2.2.1 - only prime knot of 3 crossings
trefoil = [1,4,2,5;5,2,6,3;3,6,4,1];
Trefoil = Knot(trefoil);

% example for section 3.2.2 - the linking number is, however, trivially 0
linkedtrefoils = [1,6,2,7;3,8,4,1;12,5,13,4;5,14,6,13;7,2,8,3;9,15,10,14;11,9,12,16;15,11,16,10];
LinkedTrefoils = Knot(linkedtrefoils);

% example for section 4.1.1 - only prime knot of 4 crossings
figure8 = [1,6,2,7;5,2,6,3;3,1,4,8;7,5,8,4];
Figure8 = Knot(figure8);

% example for section 5.1.1 - this is the first knot in braid form
trefoilbraid = [1,1,1];
Trefoilbraid = Braid(trefoilbraid);

% example for section 5.2 - from the knot book
knotbook = [1,2,3,-4,2,-1];
Knotbook = Braid(knotbook);