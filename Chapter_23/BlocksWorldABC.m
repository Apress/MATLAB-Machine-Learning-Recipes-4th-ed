%% Blocks world

% First do a simple problem for which we hard code the edges

initial = "AB|C";
final  = "ABC";
G = BlocksWorldGraph(initial,target);
title('Blocks World with Two Blocks');

T = dfsearch(G, initial, 'allevents', 'Restart', true);

% Check if the target node is reached
if( any(strcmp(T.Node,final)==1) )
  disp(['Target node ', final, ' reached.']);
else
  disp('Target node not reached.');
end

T = bfsearch(G, initial, 'allevents', 'Restart', true);

% Check if the target node is reached
if( any(strcmp(T.Node,final)==1) )
  disp(['Target node ', final, ' reached.']);
else
  disp('Target node not reached.');
end

