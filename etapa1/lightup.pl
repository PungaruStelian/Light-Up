:- dynamic detailed_mode_disabled/0.
:- dynamic debug_moves/0.
:- ensure_loaded('files.pl').

% ETAPA 1

%% set_empty_board/2
set_empty_board(Size, board(Size, Rows)) :-
    length(Rows, Size),
    create_empty_rows(Size, Rows).

create_empty_rows(_, []).
create_empty_rows(Size, [Row|Rows]) :-
    length(Row, Size),
    maplist(=(empty), Row),
    create_empty_rows(Size, Rows).

%% set_pos/4
set_pos(board(Size, BoardIn), (X, Y), Cell, board(Size, BoardOut)) :-
    replace_at_pos(BoardIn, X, Y, Cell, BoardOut).

replace_at_pos(Rows, X, Y, Cell, NewRows) :-
    nth0(Y, Rows, Row),
    replace_element(Row, X, Cell, NewRow),
    replace_element(Rows, Y, NewRow, NewRows).

replace_element(List, Index, NewElem, Result) :-
    length(Before, Index),
    append(Before, [_|After], List),
    append(Before, [NewElem|After], Result).

%% set_walls/3
set_walls(Board, [], Board).
set_walls(BoardIn, [(Pos, Number)|Rest], BoardOut) :-
    set_pos(BoardIn, Pos, wall(Number), BoardTemp),
    set_walls(BoardTemp, Rest, BoardOut).

%% get_board_size/2
get_board_size(board(Size, _), Size).

%% get_pos/3
get_pos(board(Size, Rows), (X, Y), Cell) :-
    X >= 0, X < Size,
    Y >= 0, Y < Size,
    nth0(Y, Rows, Row),
    nth0(X, Row, Cell).

%% is_wall/2
is_wall(Board, Pos) :-
    get_pos(Board, Pos, wall(_)).

%% is_free/2
is_free(Board, Pos) :-
    get_board_size(Board, Size),
    Pos = (X, Y),
    X >= 0, X < Size,
    Y >= 0, Y < Size,
    get_pos(Board, Pos, Cell),
    Cell = empty.

%% is_light/2
is_light(Board, Pos) :-
    get_pos(Board, Pos, light).

%% get_number/3
get_number(Board, Pos, Number) :-
    get_pos(Board, Pos, wall(Number)),
    number(Number).

%% add_light/3
add_light(BoardIn, Pos, BoardOut) :-
    set_pos(BoardIn, Pos, light, BoardOut).

%% is_pos/2
is_pos(Board, (X, Y)) :-
    get_board_size(Board, Size),
    ( (var(X), var(Y)) ->          % Folosește -> în loc de →
        between(0, Size-1, X),
        between(0, Size-1, Y)
    ;
        X >= 0, X < Size,
        Y >= 0, Y < Size
    ).

%% is_lit/2
is_lit(Board, Pos) :-
    is_free(Board, Pos),            % Doar pozițiile libere pot fi luminare
    (direction(Dir),                % Verifică toate direcțiile (n, s, e, w)
     light_in_direction(Board, Pos, Dir)
    ), !.                           % O singură direcție validă este suficientă

light_in_direction(Board, Pos, Dir) :-
    neighbor(Pos, Dir, NextPos),
    check_light_path(Board, NextPos, Dir).

check_light_path(Board, Pos, Dir) :-
    (is_light(Board, Pos) -> true    % Dacă există lumină, pozitia este luminată
    ;
     (is_wall(Board, Pos) -> false   % Pereții blochează lumina
     ;
      neighbor(Pos, Dir, NextPos),   % Continuă în aceeași direcție
      check_light_path(Board, NextPos, Dir)
     )
    ).

%% get_lights_around_wall/3
get_lights_around_wall(Board, Pos, N) :-
    directions(Dirs),
    findall(
        NPos,
        (
            member(Dir, Dirs),
            neighbor(Pos, Dir, NPos),
            is_pos(Board, NPos),
            is_light(Board, NPos)
        ),
        Lights
    ),
    length(Lights, N).

%% can_add_light/2
can_add_light(Board, Pos) :-
    \+ is_wall(Board, Pos),
    \+ is_lit(Board, Pos),
    \+ is_light(Board, Pos),
    directions(Dirs),
    forall(
        (
            member(Dir, Dirs),
            neighbor(Pos, Dir, NPos),
            is_pos(Board, NPos),
            is_wall(Board, NPos),
            get_pos(Board, NPos, wall(Number)),
            number(Number)
        ),
        (
            get_lights_around_wall(Board, NPos, LightCount),
            LightCount < Number
        )
    ).

%% is_valid_solution/1
is_valid_solution(Board) :-
    % 1. All positions that are not walls are lit or have lights
    forall(
        (is_pos(Board, Pos), \+ is_wall(Board, Pos), \+ is_light(Board, Pos)),
        is_lit(Board, Pos)
    ),
    % 2. All walls with numbers have exactly that many lights around
    forall(
        (is_pos(Board, Pos), get_number(Board, Pos, Number)),
        (get_lights_around_wall(Board, Pos, Number))
    ),
    % 3. All lights are on positions that would not be lit without them
    forall(
        (is_pos(Board, Pos), is_light(Board, Pos)),
        (
            % Temporarily remove the light
            set_pos(Board, Pos, empty, TempBoard),
            % Check that the position is not lit
            \+ is_lit(TempBoard, Pos)
        )
    ).

%% solve/2
solve(Board, Board) :-
    is_valid_solution(Board), !.
solve(BoardIn, Solution) :-
    is_pos(BoardIn, Pos),
    can_add_light(BoardIn, Pos),
    add_light(BoardIn, Pos, BoardTemp),
    solve(BoardTemp, Solution).

%% solve_plus/3
solve_plus(Board, Board, []) :-
    is_valid_solution(Board), !.
solve_plus(BoardIn, Solution, [Pos|RestLights]) :-
    find_best_move(BoardIn, Pos),
    add_light(BoardIn, Pos, BoardTemp),
    solve_plus(BoardTemp, Solution, RestLights).

find_best_move(Board, Pos) :-
    % First try walls with exact number of spaces left
    (
        find_wall_with_exact_spaces(Board, WallPos),
        find_free_neighbor(Board, WallPos, Pos)
    );
    % Then try isolated cells
    (
        find_isolated_cell(Board, Pos)
    );
    % Otherwise, use regular cell selection
    (
        is_pos(Board, Pos),
        can_add_light(Board, Pos)
    ).

find_wall_with_exact_spaces(Board, WallPos) :-
    is_pos(Board, WallPos),
    get_number(Board, WallPos, Number),
    get_lights_around_wall(Board, WallPos, LightCount),
    FreeNeeded is Number - LightCount,
    FreeNeeded > 0,
    count_free_neighbors(Board, WallPos, FreeNeeded).

count_free_neighbors(Board, Pos, Count) :-
    directions(Dirs),
    findall(
        NPos,
        (
            member(Dir, Dirs),
            neighbor(Pos, Dir, NPos),
            is_pos(Board, NPos),
            is_free(Board, NPos)
        ),
        FreeNeighbors
    ),
    length(FreeNeighbors, Count).

find_free_neighbor(Board, WallPos, FreePos) :-
    directions(Dirs),
    member(Dir, Dirs),
    neighbor(WallPos, Dir, FreePos),
    is_pos(Board, FreePos),
    is_free(Board, FreePos).

find_isolated_cell(Board, Pos) :-
    is_pos(Board, Pos),
    is_free(Board, Pos),
    \+ is_lit(Board, Pos),
    Pos = (X, Y),
    % Check if no other position can illuminate this position
    \+ (
        % Check all positions in the same row
        get_board_size(Board, Size),
        between(0, Size-1, X2),
        X2 \= X,
        is_free(Board, (X2, Y)),
        no_walls_between(Board, (X, Y), (X2, Y))
    ),
    \+ (
        % Check all positions in the same column
        get_board_size(Board, Size),
        between(0, Size-1, Y2),
        Y2 \= Y,
        is_free(Board, (X, Y2)),
        no_walls_between(Board, (X, Y), (X, Y2))
    ).

no_walls_between(Board, (X1, Y1), (X2, Y2)) :-
    X1 =:= X2, !,  % Same column
    MinY is min(Y1, Y2),
    MaxY is max(Y1, Y2),
    \+ (
        between(MinY, MaxY, Y),
        Y \= Y1, Y \= Y2,
        is_wall(Board, (X1, Y))
    ).
no_walls_between(Board, (X1, Y1), (X2, Y2)) :-
    Y1 =:= Y2, !,  % Same row
    MinX is min(X1, X2),
    MaxX is max(X1, X2),
    \+ (
        between(MinX, MaxX, X),
        X \= X1, X \= X2,
        is_wall(Board, (X, Y1))
    ).