function blocks_world_dfs()
    % Define initial and goal states
    initial_state = {'A', 'table'; 'B', 'table'; 'C', 'A'};
    goal_state    = {'A', 'B';     'B', 'C';     'C', 'table'};

    % Initialize DFS stack with initial state
    stack = {initial_state};
    visited = {};
    found = false;

    while ~isempty(stack)
        % Pop from stack (LIFO)
        current = stack{end};
        stack(end) = [];

        % Check if goal is reached
        if isequal(sortrows(current), sortrows(goal_state))
            disp('Goal reached!');
            disp('Final state:');
            disp(current);
            found = true;
            break;
        end

        % Avoid revisiting states
        if ismember_state(current, visited)
            continue;
        end
        visited{end+1} = current;

        % Generate successors
        children = generate_successors(current);

        % Push children to stack
        stack = [stack, children];
    end

    if ~found
        disp('Goal not found.');
    end
end

function children = generate_successors(state)
    % Generates all valid moves (one block moved at a time)
    blocks = {'A', 'B', 'C'};
    children = {};

    for i = 1:length(blocks)
        block = blocks{i};

        % Get current support of this block
        from = get_support(block, state);

        % Determine clear blocks (no other block on them)
        clear_blocks = get_clear_blocks(state);

        for j = 1:length(clear_blocks)
            to = clear_blocks{j};

            % Skip if moving onto itself or same place
            if strcmp(to, block) || strcmp(from, to)
                continue;
            end

            % Create new state
            new_state = move_block(state, block, to);
            children{end+1} = new_state;
        end

        % Also try moving to table
        if ~strcmp(from, 'table')
            new_state = move_block(state, block, 'table');
            children{end+1} = new_state;
        end
    end
end

function support = get_support(block, state)
    support = '';
    for i = 1:size(state,1)
        if strcmp(state{i,1}, block)
            support = state{i,2};
            return;
        end
    end
end

function clear_blocks = get_clear_blocks(state)
    blocks = {'A', 'B', 'C'};
    clear_blocks = blocks;

    % Remove blocks that have something on top
    for i = 1:length(blocks)
        for j = 1:size(state,1)
            if strcmp(state{j,2}, blocks{i})
                clear_blocks{strcmp(clear_blocks, blocks{i})} = [];
                break;
            end
        end
    end
end

function new_state = move_block(state, block, new_support)
    new_state = state;
    for i = 1:size(state,1)
        if strcmp(state{i,1}, block)
            new_state{i,2} = new_support;
            break;
        end
    end
end

function exists = ismember_state(state, state_list)
    exists = false;
    for i = 1:length(state_list)
        if isequal(sortrows(state), sortrows(state_list{i}))
            exists = true;
            return;
        end
    end
end
