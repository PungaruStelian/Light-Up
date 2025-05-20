# Light-up

# Description

Jocul Light Up se joacă pe o tablă rectangulară – pentru simplitate vom presupune în această temă că tabla este întotdeauna pătrată – unde pot exista o serie de celule indisponibile – le vom numi pereți. Unii pereți pot avea asociate numere între 0 și 4.

În celulele unde nu sunt pereți se pot plasa becuri (lumini). O lumină plasată într-o celulă va lumina pe toate celulele pe aceeași verticală și pe aceeași orizontală cu poziția becului până la primul perete în fiecare direcție.

Obiectivul jocului este ca toate celulele fără pereți de pe tabla de joc să fie luminate, fără ca vreun bec să fie pe o celulă luminată de un alt bec. Dacă un perete are un număr, atunci pe pozițiile vecine rectangular (nu și diagonal) cu peretele trebuie să existe exact acel număr de becuri, nu mai multe, nu mai puține. O variantă rezolvată a tablei din imaginea anterioară poate fi văzută mai jos.

În această temă, trebuie să acoperiți următoarele puncte:

- să dezvoltați o reprezentare proprie pentru o tablă de joc.
- să implementați predicate care să modifice și să acceseze o reprezentare a tablei jocului.
- să implementați elemente din mecanica jocului – plasarea corectă a becurilor și calculul celulelor luminate.
- să folosiți mecanismul de backtracking din Prolog pentru a rezolva jocul.

# Stage 1

În etapa 1 ne interesează reprezentarea tablei de joc, accesul și modificarea acestei reprezentări, și calculul celulelor luminate.

În ambele etape veți lucra numai în fișierul `lightup.pl`.

Nu folosiți predicatele intern_* și tt*, nu aveți nevoie de ele.

Faceți o implementare cât mai generală, **nu hardcodați lucruri**. De principiu, fiecare predicat ar trebui să aibă 1-2-3 reguli, și cele mai multe din această etapă se pot implementa nerecursiv.

## Reprezentare

În prima parte trebuie să dezvoltați o **reprezentare** a tablei de joc. Această reprezentare poate fi construită cum doriți. Ea trebuie să conțină informații despre:

- dimensiunea tablei de joc
- pozițiile pereților și numerele de pe pereți, dacă există
- pozițiile becurilor
- în funcție de cum doriți, dacă o celulă este luminată sau nu

Reprezentarea va fi construită și accesată **numai prin intermediul predicatelor pe care le scrieți voi**. Testerul va considera reprezentarea unei table ca fiind opacă și nu va parsa reprezentarea în niciun fel. Puteți alege ce reprezentare doriți. De exemplu, puteți folosi liste de liste (ca să reprezentați ca o matrice), sau o listă de tupluri care conțin poziția și informațiile despre o celulă. Sau orice altă reprezentare doriți.

În testarea unui nivel, vor exista două faze:

1. checkerul va apela predicatele `empty_state` și `set_walls` pentru a construi reprezentarea unei table B;
2. checkerul va verifica corectitudinea reprezentării prin apelul, pe tabla B rezultată, a predicatelor `get_board_size`, `is_wall`, și `get_number`;
3. checkerul va verifica implementarea corectă a mecanicii jocului prin apelul predicatelor `add_light` și `is_lit`.

**Important**: nu citiți direct reprezentarea nivelurilor din levels.pl. Reprezentările corespunzătoare fiecărei table vor fi construite element cu element de către checker prin apeluri ale predicatelor corespunzătoare implementate de voi.

Reprezentăm o poziție pe tablă, în argumentele predicatelor, ca o pereche `(X, Y)`, cu X și Y coordonatele corespunzătoare, 0-based, cu poziția `(0, 0)` în colțul din stânga-sus al hărții.

Descrierea fiecărui predicat, împreună cu specificațiile sale, se găsește în schelet.

## Hints

- Aveți o serie de predicate utile în fișierul util.pl
- Dacă construiți o reprezentare bazată pe o matrice (o listă de liste), vă pot fi utile predicatele
  - make_repeat_list/3 și set_list_index/4 din util.pl.
  - nth0/3 din prolog, care poate fi folosit și pentru a afla ce element se află la un anumit index într-o listă, dar și pentru a afla la ce index se află un element într-o listă.
- Dacă construiți o reprezentare bazată pe o listă de poziții și caracteristici, vă poate fi util predicatul member/2 din prolog. De exemplu, dacă avem o listă L = [(a, 1), (b, 2), (c, 3), (d, 4)] și apelăm member((c, X), L), Prolog va lega X la 3, pentru că a găsit elementul (c, 3) în listă.
- la primirea argumentelor de tip poziție, puteți să faceți pattern-matching ca în Haskell sau puteți unifica ulterior, astfel:
  - is_wall(B, (X, Y)) :- condiții – Prolog îmi va lega X și Y la coordonatele din poziția dată ca argument; sau
  - is_wall(B, Pos) :- Pos = (X, Y), alte condiții – Prolog îmi va lega X și Y la coordonatele din poziția dată ca argument.
- foarte util poate fi predicatul between(A, B, X), care poate fi folosit atât pentru a afla dacă X este între A și B (inclusiv), dar și pentru a genera numere din intervalul [A, B].
- Mai multe hints specifice pentru diversele predicate de implementat găsiți în sursă.

# Stage 2

În etapa a doua veți implementa rezolvarea jocului Light Up. O soluție a jocului are următoarele proprietăți:

1. Toate pozițiile de pe tablă, care nu sunt pereți, sunt luminate.
2. Pentru orice perete cu număr, pe pozițiile vecine ortogonal cu peretele (cele 4 poziții de sus, dreapta, jos, stânga) se află exact numărul necesar de lumini (nici mai mult, nici mai puțin).
3. Toate becurile sunt pe poziții care, dacă nu ar fi fost acel bec acolo, nu ar fi fost luminate (un bec nu trebuie să fie luminat de un alt bec).

Veți avea de implementat predicate pentru:

- determinarea numărului de lumini din jurul unui perete.
- verificarea dacă pe o poziție poate fi adăugată o lumină. Acest lucru este posibil dacă:
  - poziția nu este ocupată de un perete sau de o lumină.
  - poziția nu este luminată de un alt bec.
  - pentru toți pereții cu număr cu care este vecină ortogonal poziția, numărul de lumini din jurul peretelui este mai mic decât numărul de pe perete.
- verificarea dacă o soluție este validă (vedeți cele 3 reguli de mai sus).
- rezolvarea unei table. Aici vom folosi mecanismul de backtracking din Prolog și este suficient să avem două reguli:
  - dacă tabla este o soluție validă, atunci am terminat
  - găsim pe tablă o poziție unde putem pune o lumină, punem o lumină acolo, și căutăm o soluție continuând de la noua tablă. Dacă căutarea eșuează la un moment dat, Prolog se va întoarce și va încerca să pună o lumină într-o altă poziție disponibilă și va continua de acolo, și așa mai departe.
- rezolvarea eficientă a unei table, folosind două euristici simple: alegem să punem lumini în jurul pereților cu numere care au numărul exact egal cu numărul pozițiilor disponibile (unde se pot pune lumini) din jurul peretelui respectiv; și alegem să punem lumini în poziții care nu ar mai putea fi luminate din alte poziții disponibile de pe tablă.


Hints specifice pentru fiecare predicat sunt disponibile în schelet.

## Testare

Încărcați în Prolog fișierul `lightup.pl`. Pentru testare folosiți predicatele `check` sau `vmcheck`. Pentru teste individuale folosiți `vmtest(<nume_test>).`, e.g. `vmtest(b0)`. Vedeți și observația de la începutul fișierului `testing.pl`.

La trimiterea temei, este suficient să puneți în arhivă fișierul lightup.pl.

Testele se află în fișierul `testing.pl`. Tipurile testelor sunt descrise succint la începutul fișierului. Pentru a verifica un test, puteți face o interogarea în consolă care conține scopurile plasate (de obicei) între ghilimele în primul argument al testului.

De exemplu, pentru a replica testul b0|a puteți interoga la consolă:

```prolog
set_empty_board(8, B)
```

iar pentru testul `wall|c`:

```prolog
ttSet(wn1, B)
```

Pentru rezultate mai detaliate ale testării, linia `%detailed_mode_disabled :- !, fail`. din fișierul `testing.pl` este decomentată. Atenție! În acest caz, este posibil ca punctarea să fie diferită decât rezultatul de pe vmchecker, unde linia este comentată. Dacă rezultatele detaliate nu apar, comentați la loc linia, apelați interogarea `make, check`. apoi decomentați din nou și apelați interogarea `make, check` din nou.