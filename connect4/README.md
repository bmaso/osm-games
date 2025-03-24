# Connect Four OSM Model

[Connect Four](https://en.wikipedia.org/wiki/Connect_Four) is a simple table-top strategy game, originally created by Howard
Wexler and sold by Milton Bradley. The game is played on a vertical 6 row by 7 column board. Players first choose a color
(red or black), and then choose a first player. Players take turns placing a single colored marker on the board. Game play
continues until one player wins by placing 4 of their markers in a continuous row, column, or diagonal configuration, or until
a draw occurs when there are no more valid plays.

A player places a marker by picking a column. The piece "falls" to the lowest position in the column. If the column is full
then it cannot be played. Thus each player has at most 7 possible plays -- one for each column.

The Connect Four OSM model follows the basic structure described in the [project's README](../README.md). The game state is
represented by a 6x7 matrix of _`Position`_ values. Each `Position` has a `Row` and `Column` value -- which are _not_ integers,
but rather a custom value type, which we use to logically define adjacency between positions. The `color` value of each position
is Red, Black, or Neutral.

A `Board` is made up of a 6x7 matrix of `Position` values, and a `current-player` color value. During the initial game ceremony
of choosing a first player, the `current_player` value is `Neutral`. Once a player is chosne, then the player color alternates
between `Red` and `Black` each turn.

There is one operation for choosing a first player. This operation can only be applied to an empty board with a `current_player`
value of `Neutral`. This operation application is the first of a valid game sequence, and is the only time this operation is applied
in a valid game sequence.

There are just 2 more operations in the game:

* **A player turn**. The initial game state indicates which color marker will be played, and the `winner` value must be
  `Neutral`. A `Column` value indicates the column where the marker is placed. The `curent-player` value must not be `Neutral`.
  The final state of the board after play has the current player color updated, and the lowest
  unoccupied `Position` in the chosen `Column` updated to the player's color.
* **A player is declared winner**. The initial game state for this operation is any `Board` where the `winner` value is `Neutral`.
  The operation input also includes four row and column pair values, which must be adjacent and in a row, column, or diagonal from
  each other. These row and column pairs refer to `Position` values in the `Board`. The `Position` values must all have the same
  color in the `Board`. The final `Board` state after successful application of this operation has  `winner` value set to the color
  of the winning player -- the same color as all the `Position` values refered to by the input row, column pairs.

