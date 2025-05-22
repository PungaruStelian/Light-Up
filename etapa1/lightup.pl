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

% Rows = matricea; aici length seteaza numarul de randuri
set_empty_board(Size, board(Size, Rows)) :-
    length(Rows, Size), set_empty_rows(Size, Rows).
% din linia de cod de mai sus imi dau seama ca board/matricea este outputul
% length initializeaza o lista cu size elemente neinstantiate, mai sus creez vectorul si apoi
% fiecare element este un vector/rand; make_repeat_list e definit in util.pl
% empty este un atom care trebuie folosit mai departe la fel, insa putea avea orice nume
set_empty_rows(_, []).
set_empty_rows(Size, [Row|Rows]) :-
    make_repeat_list(empty, Size, Row), set_empty_rows(Size, Rows).

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

% atat timp cat folosesc functia asta corect, puteam pos(X,Y) in loc de (X,Y) de ex
set_pos(board(Size, BoardIn), (X, Y), Cell, board(Size, BoardOut)) :-
    % leaga Row la lista; fiind elementrul de la pozitia Y din BoardIn
    nth0(Y, BoardIn, Row),
    set_list_index(Row, X, Cell, NewRow),
    set_list_index(BoardIn, Y, NewRow, BoardOut).

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
    set_pos(BoardIn, Pos, Number, BoardAcc),
    set_walls(BoardAcc, Rest, BoardOut).

%% TODO
% get_board_size(+Board, -Size)
% Leagă Size la dimensiunea laturii tablei Board.

% cum variabila Size se repeta inseamna ca la interogare sunt legate
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
get_pos(board(_, Rows), (X, Y), Cell) :-
    nth0(Y, Rows, Row), nth0(X, Row, Cell).

%% TODO
% is_wall/2
% is_wall(+Board, +Pos)
%
% Întoarce adevărat dacă la poziția Pos din tabla Board este un perete
% (indiferent dacă este cu număr sau fără). Întoarce fals dacă la
% poziția pos nu este un perete.

% cum orice variabila e locala, cell este intial nelegat
% apoi se leaga la valoarea matricii pe Pos si se verifica/unifica cu Wall
is_wall(Board, Pos) :-
    get_pos(Board, Pos, Cell), (number(Cell) ; Cell = '').

%% TODO
% is_free/2
% is_free(+Board, +Pos)
%
% Întoarce adevărat dacă poziția Pos din tabla Board este liberă (nu
% este perete și nu este deja o lumină acolo). Întoarce fals dacă
% poziția nu este în interiorul tablei, dacă este un perete sau dacă

% cum empty este un atom el nu poate fi legat la altceva asa ca doar
% se verifica cu valoarea matricii de la pozitia Pos
is_free(Board, Pos) :-
    get_pos(Board, Pos, empty).

%% TODO
% is_light/2
% is_light(+Board, +Pos)
%
% Întoarce adevărat dacă la poziția Pos din tabla Board este un bec (o
% lumină)

% cum light este un atom el nu poate fi legat la altceva asa ca doar
% se verifica cu valoarea matricii de la pozitia Pos
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
    get_pos(Board, Pos, Number), number(Number).

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
is_pos(board(Size, _), (X, Y)) :-
    % var(x) = true daca x este o variabila neinstantiata
    % daca ambele variabile sunt instantiate, atunci intram pe ramura 2: verificam coord.
    % (Cond -> Then ; Else)
    % between(0, Size, X) = true/false daca X este legat si in [0, Size)
    % ---||--- = leaga succesiv pe X cu toate valorile din [0, Size)
    % is calculeaza in dreapta si o leaga in stanga
    (var(X); var(Y)) ->  Max is Size - 1,
    between(0, Max, X), between(0, Max, Y);
    X >= 0, X < Size, Y >= 0, Y < Size.

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

is_lit(Board, (X, Y)) :-
    % Celula nu este un perete
    \+ is_wall(Board, (X, Y)),
    % iau in Xi tot randul de la Y
    is_pos(Board, (Xi, Y)),
    % verific daca celula de la pozitia Xi Y este un bec
    is_light(Board, (Xi, Y)),
    % Folosesc sorted pentru a obține min/max între X și Xi
    sorted(X, Xi, MinX, MaxX),
    % Verific să nu existe pereți între cele două poziții
    \+ (between(MinX, MaxX, Xbetween), is_wall(Board, (Xbetween, Y)));
    
    \+ is_wall(Board, (X, Y)),
    % iau in Yi tot randul de la X
    is_pos(Board, (X, Yi)),
    % verific daca celula de la pozitia X Yi este un bec
    is_light(Board, (X, Yi)),
    % Folosesc sorted pentru a obține min/max între Y și Yi
    sorted(Y, Yi, MinY, MaxY),
    % Verific să nu existe pereți între cele două poziții
    \+ (between(MinY, MaxY, Ybetween), is_wall(Board, (X, Ybetween))).
