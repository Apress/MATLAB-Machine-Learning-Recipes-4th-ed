%% Blocks world

% First do a simple problem for which we hard code the edges

states = {'AB' 'BA' 'A|B'};

goal    = states{2};
initial = states{1};

edges   = [1 3;3 2;3 1];

G = digraph(edges(:,1),edges(:,2),[],states);

figure
plot(G,'Layout','layered')
title('Blocks World with Two Blocks');
dfpath = dfsearch(G,initial,goal);
disp(dfpath)