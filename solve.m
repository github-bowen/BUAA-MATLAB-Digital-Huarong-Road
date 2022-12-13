function path=solve(numbers, qType)
%numbers为一维数组,0代表空格,qType为3和4时分别求解3*3和4*4的,返回path为路径,-1代表左移,1代表右移.-3/-4代表上移,3/4代表下移
    if hasSolve(numbers) == false
        path = false;
        return;
    end
    if qType == 3
        path = solve3(numbers);
    end
    if qType == 4
        path = solve4(numbers);
    end
end

function res=hasSolve(numbers)
% 传入一维数组numbers
revCnt = 0;
for i = 1:16
    for j = i + 1:16
        if (numbers(i) > numbers(j) && numbers(i) * numbers(j) ~= 0)
            revCnt =revCnt + 1;
        end
    end
end

if length(numbers) == 16
    revCnt = revCnt + 3 - floor((find(numbers==0) - 1) / 4);
end
if mod(revCnt, 2) == 0
    res = true;
else
    res = false;
end
end

function enqueue(element)
    global dataStore;
    if (queueIsEmpty())
        dataStore(1) = element;
        return;
    else
        flag = false;
        for i = 1 : length(dataStore)
            if element.priority < dataStore(i).priority
                dataStore = insert(dataStore, i, element);
                flag = true;
                break;
            end
        end
        if flag == false
            dataStore(length(dataStore) + 1) = element;
        end
    end
end

function data=insert(mat,ind,num)
    n=length(mat);
    data(ind)=num;
    data(1:ind-1)=mat(1:ind-1);
    data(ind+1:n+1)=mat(ind:n);
end

function res=queueIsEmpty()
    global dataStore;
    if isempty(dataStore)
        res = true;
    else
        res = false;
    end
end

function res=deque()
    global dataStore;
    res = dataStore(1);
    dataStore(1) = [];
end

function res=calDistance(node, w)
    res = 0;
    for i = 1 : length(node)
        if (node(i) == 0)
            continue;
        end
        res = res + abs(floor((i - 1) / w) - floor((node(i) - 1) / w)) + abs(mod(i - 1, w) - mod(node(i) - 1, w));
    end
end

function path=solve4(board)
    global dataStore;
    target = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0];
    dir = [-1,1,-4,4];
    s0 = newState(calDistance(board,4), board, find(board==0) - 1, 0, []);
    dataStore = [struct(s0)];
    seen = [st2Str(board)];
    while queueIsEmpty() == false
        state1 = deque();
        if st2Str(state1.board) == st2Str(target)
            path = state1.process;
            return;
        end
        for i = 1:4
            nei = state1.pos0 + dir(i);
            if abs(floor(nei / 4) - floor(state1.pos0 / 4)) + abs(mod(nei, 4) - mod(state1.pos0, 4)) ~= 1
                continue;
            end
            if nei >= 0 && nei < 16
                newboard = state1.board;
                temp = newboard(nei + 1);
                newboard(nei + 1) = newboard(state1.pos0 + 1);
                newboard(state1.pos0 + 1) = temp;
                if isempty(find(seen==st2Str(newboard), 1))
                    new_state = newState(state1.depth+1+0.5 * calDistance(newboard,4), newboard, nei, state1.depth+1, [state1.process, dir(i)]);
                    enqueue(new_state);
                    seen = [seen, st2Str(new_state.board)];
                end
            end
        end
    end
    path = [];
end

function path=solve3(board)
    global dataStore;
    target = [1, 2, 3, 4, 5, 6, 7, 8, 0];
    dir = [-1,1,-3,3];
    s0 = newState(calDistance(board,3), board, find(board==0) - 1, 0, []);
    dataStore = [struct(s0)];
    seen = [st2Str(board)];
    while queueIsEmpty() == false
        state1 = deque();
        if st2Str(state1.board) == st2Str(target)
            path = state1.process;
            return;
        end
        for i = 1:4
            nei = state1.pos0 + dir(i);
            if abs(floor(nei / 3) - floor(state1.pos0 / 3)) + abs(mod(nei, 3) - mod(state1.pos0, 3)) ~= 1
                continue;
            end
            if nei >= 0 && nei < 9
                newboard = state1.board;
                temp = newboard(nei + 1);
                newboard(nei + 1) = newboard(state1.pos0 + 1);
                newboard(state1.pos0 + 1) = temp;
                if isempty(find(seen==st2Str(newboard), 1))
                    new_state = newState(state1.depth+1+0.9 * calDistance(newboard,3), newboard, nei, state1.depth+1, [state1.process, dir(i)]);
                    enqueue(new_state);
                    seen = [seen, st2Str(new_state.board)];
                end
            end
        end
    end
    path = [];
end

function res=newState(priority, board, pos0, depth, process)
    res = struct;
    res.priority = priority;
    res.board = board;
    res.pos0 = pos0;
    res.depth = depth;
    res.process = process;
end

function res=st2Str(board)
    res = num2str(board);
    res = strrep(res, ' ', '');
    res = string(res);
end