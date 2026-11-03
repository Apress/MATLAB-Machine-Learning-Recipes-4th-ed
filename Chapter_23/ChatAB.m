% Blocks World using dfsearch

% Define all possible states (for 2 blocks: A, B)
states = { ...
    'AonB', ...       % A on B
    'BonA', ...       % B on A
    'AonT_BonT', ...  % Both on table
    'AonT_BonA', ...  % B on A, A on table
    'BonT_AonB' ...   % A on B, B on table
    };

% Define valid transitions between states
edges = [ ...
    1 3;  % AonB -> AonT_BonT
    3 1;  % AonT_BonT -> AonB
    2 3;  % BonA -> AonT_BonT
    3 2;  % AonT_BonT -> BonA
    4 2;  % AonT_BonA -> BonA
    2 4;  % BonA -> AonT_BonA
    5 1;  % BonT_AonB -> AonB
    1 5;  % AonB -> BonT_AonB
    ];

% Create a directed graph
G = digraph(edges(:,1), edges(:,2), [], states);

% Visualize the state-space graph
figure;
plot(G, 'Layout', 'layered');
title('Blocks World State-Space Graph');

% Perform Depth-First Search starting from a state
startState = 'AonB';
goalState = 'BonA';

disp('Depth-First Search traversal:');
dfpath = dfsearch(G, startState, 'edgetonew');
disp(dfpath);

% Optional: Find path to goal
pathToGoal = dfsearch(G, startState, 'goal', @(n) strcmp(n, goalState));
disp('Path from start to goal:');
disp(pathToGoal);
