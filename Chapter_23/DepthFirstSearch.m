%% Depth first and breadth first searches of a tree

clear A

% Adjacency table
s = [1 1 2 2 3 3 4 4 6];
t = [2 3 4 5 5 6 5 8 7];

% Create the graph
G = digraph(s,t);
G.Edges

adjacency(G)

% Draw the graph
NewFig('Graph')
p = plot(G,'Layout','layered');

disp('Depth First Search')
T = dfsearch(G,1,'allevents')

disp('Breadth First Search')
T = bfsearch(G,1,'allevents')


