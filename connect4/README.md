# Connect Four

[Connect Four](https://en.wikipedia.org/wiki/Connect_Four) is a simple table-top strategy game, originally created by Howard
Wexler and sold by Milton Bradley. The game is played on a vertical 6 row by 7 column board. Players first choose a color
(red or black), and then choose a first player. Players take turns placing a single colored marker on the board. Game play
continues until one player wins by placing 4 of their markers in a continuous row, column, or diagonal configuration, or until
a draw occurs when there are no more valid plays.

A player places a marker by picking a column. The piece "falls" to the lowest position in the column. If the column is full
then it cannot be played. Thus each player has at most 7 possible plays in each turn -- one for each column.

## OSM Model

The game state is represented by a 6x7 matrix of _`Coordinate`_ values. Each `Coordinate` has a
`RowId` and `ColId` value -- which are _not_ integers, but rather a custom value type. We use an array as a "look up table" to
define adjacency sufficient to determine when 4 pieces have been place in a row.

The `color` value of each coordinate is `red`, `black`, or `neutral`.

A `Board` is comprised of:
* a 6x7 array of `Coordinate` to `Color` values, called the `table`
* a `current-player` color value. During the initial game ceremony of choosing a first player, the `current_player` value
  is `neutral`. Once a player is chosen, then the player color alternates between `Red` and `Black` each turn.
* a `winner` color value. This value remains `neutral` until a winner is declared.

There is one operation for **choosing a first player**. This operation application is the first of a valid game sequence, and is
the only time this operation is applied in a valid game sequence.

There are just 2 more operations in the game:

* **Player turn**. A checker the same color as the current player is placed in a coordinate with a `neutral` value. Additional
  rule guarantees the checker "falls" to the lowest unoccupied position in its column. The final state of the board after
  application of this operation switches the current player from `red` -> `black` or vice versa.

* **Declare winner**. The initial game state for this operation is any `Board` where the `winner` value is `neutral`.
  The operation input also includes a root coordinate and a direction (horizontal, vertical, diagonal down-right or diagonal
  down-left). The table positions indicated by the root coordinate an the direction must have a sequence of 4 checkers of the same
  color as the declared winner. The final `Board` state after successful application of this operation has  `winner` value set
  to the color of the winning player.

## Notes

### On Not Using Integers as Indexes

Instead of using integers to index columns and rows, this model uses `ColId` and `RowId` custom datatypes to define
positions within the table. Integers _seem_ like the right choice to the software-engineer side of my brain. Why not
number the rows 1-6 the columns 1-7? Simply because SMT solvers don't reason well with infinite types, such as Integer.

Consider the rule that there are no "floating" checkers on a Connect Four table. That is, when a player "drops" a piece
into a column, under the force of gravity the piece falls to the lowest position. The way a software engineer would code
this logic would be in a for-comprehension (a for loop), or recursively:
1. Starting with the highest row test whether or not the _next lowest_ position has `neutral` color, which indicates it
   is unoccupied.
1. If the next lowest row is _not_ occupied, then decrement the "current row" value, and start again with step 1.
1. If the next lowest row _is_ occupied, then the current row is the lowest position that is unoccupied -- this is
   there the piece should go.

(I'm deliberately eliding the condition where the whole column is occupied for the sake of brevity.)

But SMTLIB2 solvers don't reason recursively, and there is no for loop construct in SMTLLIB2. Instead we have the
_universal quantifier_ logical statement. This statement verifies a predicate is true for _all_ member of a type. One
could try writing the "no floating checkers" rule like so:
* for all valid game boards _b_, and all table (row, column) coordinates (_r_, _c_):
  * IF the position at (_r_, _c_) in _b_'s table is occupied, THEN _r_ must be 1 OR the position at (_r_-1, _c_) is also occupied

This production perfectly states the rule that no "floating" checkers exist in any valid game board.

**However**, SMT solvers can't prove statements like this. The issue is that the domain of the quanitifier is infinite. The domain
is all possible combinations of a game board and integer coordinate pairs. The size of this domain is (Board x Integer x Integer),
which is infinite. An SMT solver is not going to be able to prove this statement is true across the infinite domain of all
integers.

Of course we aren't really interested in _all_ integers. We're really only interested in row indexes 1-6 and column indexes 1-7. But
SMT solvers don't know that, so they try to prove the quanitifier across _all_ (Ineger x Integer) pairs and across all posible board
combinations. The set of all possible boards is finite, but the set of all (Integer x Integer) pairs is finite.

Instead of yielding a `sat` response when asked to prove this quanitifier, the best a solver can yield is `unknown`, meaning that
the domain is just too big for the SMT solver to cover exhaustively.

### Using Finitely valued types instead

Instead of using Integers, we define a finite type called `Coordinate`, which only has 6x7=42 possible members. SMT solvers
have no problem exhaustively proving a predicate is true across 42 possible values.

There's some extra info we need to provide with the finite value types: the "above" relationships between rows. Integers
are attractive because they come with "previous" and "successor" relationships which software engineers instictively equate to "before"
and "after" relationships between indexes in arrays and matrices. Our custom enumerated types don't automatically have these
relationships so we have to create them.

There's another issue: logic for determining the coordinates of a sequence-of-4 positions on a table can be highly nested or
recursive. This will be true whether using Integer or our custom type as index types. Persnickety, repetitive logic tends to
confound SMT solvers -- these solvers are designed to avoiding repetative steps, preferring breadth-first as opposed to
depth-first search of the proof space. We greatly simplify the solver's job by precomputing all possible sequence-of-4 coordinate
tuples.

In my Connect Four formula I have predefined arrays that associate each coordinate on the board with sequence-of-4 coordinates
in the horizontal, vertical, and diagonal directions (see `formula/main/winning.smt2`). These arrays are pretty voluminous. Most
software engineers are going to see the presence of huge structure like that in the codebase as a "code smell". Another option
would be to generate these arrays using pre-processor macros. (This is how C and C++ projects generate pre-compiled structures
that are wasteful or unnecessary to generate at runtime.) I've explicitly listed the arrays to keep the project simple, but in
a real-world project Id lean on preprocessor macros to lighten the coding load.
