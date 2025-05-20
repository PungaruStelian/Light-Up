:- dynamic detailed_mode_disabled/0.
:- dynamic debug_moves/0.
:- ensure_loaded('files.pl').

% ETAPA 1

%% TODO
% set_empty_board/2
% set_empty_board(+Size, -BoardOut)
%
% Leagă Board la o tablă de joc goală, cu latura de dimensiune Size.
%
% Vedeți Hints din enunț legat de posibilitățile de reprezentare.
set_empty_board(Size, board(Size, Rows)) :-
    length(Rows, Size),
    create_empty_rows(Size, Rows).

create_empty_rows(_, []).
create_empty_rows(Size, [Row|Rows]) :-
    length(Row, Size),
    maplist(=(empty), Row),
    create_empty_rows(Size, Rows).

%% TODO, opțional
% set_pos/4
% set_pos(+BoardIn, +Pos, +Cell, -BoardOut)
%
% Aceasta este un predicat ajutător, opțional, care NU este testat
% și pe care nu este obligatoriu să îl implementați.
% Predicatul leagă BoardOut la o tablă identică cu BoardIn, dar care la
% poziția Pos conține informațiile date în Cell.
%
% Vedeți Hints din enunț legat de posibilitățile de reprezentare.
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

%% TODO
% set_walls/3
% set_walls(+BoardIn, +Walls, -BoardOut)
%
% Leagă BoardOut la o tablă de joc care conține toate elementele din
% BoardIn, și de aceeași dimensiune, la care se adaugă toți pereții
% din Walls.
% Walls este o listă de perechi Poziție - Număr (e.g. (Pos, Number)),
% unde Number poate fi un număr sau valoarea ''.
% Pentru a ști dacă o valoare este număr, folosiți predicatul number/1.
% Puteți presupune că BoardIn este o tablă goală sau conține doar
% pereți, pe alte poziții decât cele specificate în Walls.
set_walls(Board, [], Board).
set_walls(BoardIn, [(Pos, Number)|Rest], BoardOut) :-
    set_pos(BoardIn, Pos, wall(Number), BoardTemp),
    set_walls(BoardTemp, Rest, BoardOut).

%% TODO
% get_board_size(+Board, -Size)
% Leagă Size la dimensiunea laturii tablei Board.
get_board_size(board(Size, _), Size).

%% TODO, opțional
% get_pos/3
% get_pos(+Board, +Pos, -Cell)
%
% Aceasta este un predicat ajutător, opțional, care NU este testat
% și pe care nu este obligatoriu să îl implementați.
% Predicatul leagă Cell la informația legată de poziția Pos, în
% tabla BoardIn.
%
% Vedeți Hints din enunț legat de posibilitățile de reprezentare.
get_pos(board(Size, Rows), (X, Y), Cell) :-
    X >= 0, X < Size,
    Y >= 0, Y < Size,
    nth0(Y, Rows, Row),
    nth0(X, Row, Cell).

%% TODO
% is_wall/2
% is_wall(+Board, +Pos)
%
% Întoarce adevărat dacă la poziția Pos din tabla Board este un perete
% (indiferent dacă este cu număr sau fără). Întoarce fals dacă la
% poziția pos nu este un perete.
is_wall(Board, Pos) :-
    get_pos(Board, Pos, wall(_)).

%% TODO
% is_free/2
% is_free(+Board, +Pos)
%
% Întoarce adevărat dacă poziția Pos din tabla Board este liberă (nu
% este perete și nu este deja o lumină acolo). Întoarce fals dacă
% poziția nu este în interiorul tablei, dacă este un perete sau dacă
is_free(Board, Pos) :-
    get_board_size(Board, Size),
    Pos = (X, Y),
    X >= 0, X < Size,
    Y >= 0, Y < Size,
    get_pos(Board, Pos, Cell),
    Cell = empty.

%% TODO
% is_light/2
% is_light(+Board, +Pos)
%
% Întoarce adevărat dacă la poziția Pos din tabla Board este un bec (o
% lumină)
is_light(Board, Pos) :-
    get_pos(Board, Pos, light).

%% TODO
% get_number/3
% get_number(+Board, +Pos, -Number)
% Leagă Number la numărul de pe peretele de la poziția Pos pe tabla
% Board.
% Întoarce false dacă la poziția Pos nu este un perete.
% Întoarce false dacă la poziția Pos este un perete fără număr.
get_number(Board, Pos, Number) :-
    get_pos(Board, Pos, wall(Number)),
    number(Number).

%% TODO
% add_light/3
% add_light(+BoardIn, +Pos, -BoardOut)
%
% Leagă BoardOut la o tablă identică cu BoardIn, doar că la poziția Pos
% se adaugă un bec (o lumină).
% Nu sunt necesare verificări aici dacă Pos este liberă sau dacă este o
% poziție legală pentru un bec.
add_light(BoardIn, Pos, BoardOut) :-
    set_pos(BoardIn, Pos, light, BoardOut).

%% TODO
% is_pos/2
% is_pos(+Board, ?Pos)
%
% Dacă Pos este o variabilă legată la o pereche de coordonate, atunci
% predicatul întoarce adevărat dacă poziția este o poziție din
% interiorul hărții (X și Y sunt între 0 și Size - 1, inclusiv).
% Dacă Pos este o variabilă nelegată, atunci predicatul leagă Pos la o
% poziție validă de pe tablă. Soluții succesive vor lega Pos la toate
% pozițiile de pe tablă (Size * Size poziții).
%
% Hint: predicatul between/3 predefinit în prolog.
is_pos(Board, (X, Y)) :-
    get_board_size(Board, Size),
    (   (var(X); var(Y))
    ->  SizeMinus1 is Size - 1,  % Calcul explicit al limitei
        between(0, SizeMinus1, X),
        between(0, SizeMinus1, Y)
    ;   X >= 0, X < Size,        % Verificare pentru X și Y legate
        Y >= 0, Y < Size
    ).

%% TODO
% is_lit/2
% is_lit(+Board, +Pos)
%
% Întoarce adevărat dacă poziția Pos de pe tabla Board este luminată.
% O poziție Pos este luminată dacă se află pe acceași linie sau coloană
% cu un bec de pe hartă, și între Pos și bec nu se află niciun perete.
% Mai precis, nu există nicio poziție WP pe hartă, pe aceeași linie /
% coloană cu Pos și cu becul (două cazuri, aceeași linie și aceeași
% coloană), astfel încât poziția WP să fie între Pos și poziția becului,
% iar la poziția WP să fie un perete.
%
% Hint: predicatul sorted/4, din util.pl, și operatorul de
% negare din Prolog, \+
is_lit(Board, Pos) :-
    is_light(Board, Pos).
is_lit(Board, Pos) :-
    is_free(Board, Pos),
    directions(Dirs),
    member(Dir, Dirs),
    light_in_direction(Board, Pos, Dir).

light_in_direction(Board, Pos, Dir) :-
    neighbor(Pos, Dir, NextPos),
    check_light_path(Board, NextPos, Dir).

check_light_path(Board, Pos, Dir) :-
    is_pos(Board, Pos),  % Check position is valid
    (
        is_light(Board, Pos)  % We found a light
    ;
        \+ is_wall(Board, Pos),  % Not a wall, continue in same direction
        neighbor(Pos, Dir, NextPos),
        check_light_path(Board, NextPos, Dir)
    ).

%% TODO
% get_lights_around_wall/3
% get_lights_around_wall(+Board, +Pos, -N)
%
% Leagă N la numărul de lumini din jurul peretelui de la poziția Pos
% (doar pe direcții ortogonale (nord, sud, est, vest).
%
% Hint: predicatele din prolog member/2, findall/3 și predicatele din
% utils.pl directions/1, neighbor/3
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

%% TODO
% can_add_light/2
% can_add_light(+Board, +Pos)
%
% Întoarce adevărat dacă
% - poziția nu este un perete
% - poziția nu este deja luminată
% - pentru toți pereții aflați pe poziții vecine (ortogonal), numărul de
% pe perete, dacă există, este mai mare decât numărul de lumini deja
% aflate în jurul peretelui.
%
% Hint: forall/2, directions/1, neighbor/3
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

%% TODO
% is_valid_solution/1
% is_valid_solution(Board)
%
% Întoarce adevărat dacă Board este o soluție validă a problemei.
% Trebuie verificate 3 elemente:
%
% 1) Toate pozițiile de pe tablă, care nu sunt pereți, sunt luminate.
% 2) Pentru toți pereții cu numere, pe pozițiile lor vecine ortogonal se
% află exact numărul necesar de lumini (nici mai mult, nici mai puțin).
% 3) Toate becurile sunt pe poziții care, dacă nu ar fi fost acel bec
% acolo, nu ar fi fost luminate.
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

%% TODO
% solve/2
% solve(+Board, -Solution)
%
% Leagă Solution la o tablă cu aceeași pereți ca și Board, și cu lumini
% adăugate în așa fel încât Solution să fie o soluție a jocului
% (is_valid_solution să fie adevărat pentru Solution).
%
% Hint:
% - dacă Board este o tablă validă, atunci aceasta este soluția.
% - dacă găsesc o poziție (is_pos) în Board unde pot plasa o lumină, o
% plasez acolo și dau rezultatul unui nou apel de solve.
%
% Folosiți capacitatea generativă a lui is_pos, care să întoarcă
% posibile soluții de pe hartă la încercări succesive.
solve(Board, Board) :-
    is_valid_solution(Board), !.
solve(BoardIn, Solution) :-
    is_pos(BoardIn, Pos),
    can_add_light(BoardIn, Pos),
    add_light(BoardIn, Pos, BoardTemp),
    solve(BoardTemp, Solution).

%% TODO
% solve_plus/3
% solve_plus(+Board, -Solution, -Light_Order)
%
% La fel ca și solve/2, dar leagă Light_Order la o listă de poziții unde
% au fost plasate lumini pentru a rezolva tabla, în ordinea în care au
% fost adăugate (prima poziție din Light_Order este prima care a fost
% adăugată). Trebuie folosită o ordine optimă a adăugării, în scopul
% obținerii mai rapid a unei soluții. Astfel, la fiecare încercare de
% plasare a unei lumini se vor lua în considerare următoarele criterii:
%
% - Se vor plasa lumini în jurul pereților cu numere unde numărul de
% poziții disponibile vecine cu peretele, plus numărul de lumini deja
% plasate lângă perete, este egal cu numărul de pe perete. În aceste
% cazuri, se pot plasa toate luminile în aceeași iterație.
%
% - Se vor plasa lumini în spațiile de o celulă neluminată care nu are
% nicio altă poziție pe verticală sau pe orizontală unde ar putea fi
% pusă o lumină, care să lumineze celula.
%
% Pentru fiecare dintre cele două criterii, dacă sunt mai multe situații
% pe tablă care îndeplinesc un criteriu, se va rezolva prima situația
% cea mai de sus, și cea mai din stânga.
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