function [G,newRows] = BlocksWorldGraph(initial,target)

%% Generates the graph
% G is composed of edges and Nodes. We need to compute the edges and states.
% Each edge has the start and destination state.
% A state is a block configuration

% Demo
if( nargin < 1 )
  initial = "AB|C";
  target  = "ABC";
  G = BlocksWorldGraph(initial,target);
  plot(G)
  title('Blocks World Graph');
  clear G
  return
end

row    = initial;
states = initial;
j   = 1;
while(all(strcmp(target,row)==0))
  rowNew = [];
  for k = 1:length(row)
    rowK   = NextStates(row(k));
    rowNew = [rowNew, rowK];
  end
  row = rowNew;
  states = [states rowNew];
  j = j + 1;
end
states = unique(states);

% Now fine the edges
row    = initial;
edges  = [];
while(all(strcmp(target,row)==0))
  rowNew = [];
  for k = 1:length(row)
    i      = strmatch(row(k),states); % The state
    rowK   = NextStates(row(k));
    for j = 1:length(rowK)
      iN = strmatch(rowK(j),states);
      edges = [edges;i iN];
    end
    rowNew = [rowNew, rowK];
  end
  row = rowNew;
  j = j + 1;
end


G = digraph(edges(:,1),edges(:,2),[],states);
  

