# Backgammon OSM Model

[Backgammon](https://en.wikipedia.org/wiki/Backgammon) is the most popular of a family of game known as _"tables games"_ whose history goes back at least 1,700 years. The [World
Backgammon Federation](https://wbgf.info/) oversees international tournaments today, and its [definition](https://wbgf.info/tournament-rules/) of backgammon can be taken as "standard" for the
purposes of authoring an OSM model of the game process.

The OSM model in this module follows the same general OSM model structure described in [project README](../README.md). A sequence of _operations_ models each game process as. Each operation instance relates a _prior game_ state to an _post game_ state, along with operation input
and output describing the change made to the prior state that resulted in the post state.

The post state of one operation is the prior state of the subsequent operation. The game process can be considered a DAG of game states, more
specifically a linked list, with the operation instances as directed vectors linking one game state to the next, which are nodes in the DAG.
The "head" of this structure is the initial game state in each game process -- the "new board" with pieces arranged as required by the official
rules. The final element of each game is a terminal state, in which one of the two players has "borne off their 15 pieces from the inner table" in
the argot of backgammon enthusiasts, ie in which one of two players has won.

This model employs the `smtlib2` language to define the model datatypes and logical rules defining a valid game process.

## Domain Datatypes and Validation Functions

### Domain Datatypes

The `Board` datatype serves as the game state. A `Board` is comprised of: 24 `Point` values, a `Bar` value, and an integer doubling value which
is stored in the game state as a log base 2 value -- so that the game's cube value is 2 raised to the doubling value. 0 means the
cube value is 1, 1 --> 2, 2 --> 4, 3 --> 8, and so on.

A `Point` consists of a `Color` value and an integer count of pieces, representing a count of pieces of one player or the other.
The `Color` sort has 3 values: `{ Red, Black, Neutral }`, where `Neutral` serves as a special indicator that a `Point` is unoccupied by
either player.

A `Bar` consists of just 2 integers: a `Red` count and a `Black` count, indicating the number of pieces of each player occupying the game bar.

### Validation Functions

