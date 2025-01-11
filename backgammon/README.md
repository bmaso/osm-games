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

## WBGF Rules

The WBGF rules follow the description of the game rules clearly described in [Wikipedia's Backgammon article's Rules section](https://en.wikipedia.org/wiki/Backgammon#Rules). The variant defined in this module incudes these options to the game:

1. _Physical restrictions on game play elided._ Obviously this is a mathematical description of the game process, so physical requirements
   of the game are not addressed. The size of the game board, composition and behavior of dice, use of a "Baffle Box" (a dice-rolling
   device), Game Clocks, and other physical/temporal aspects of human game play aren't addressed.

1. _Doubling cube._ this module includes _beavering_ and _racooning_, which are optional aspects of the doubling cube. (See
   [Wikipedia's description](https://en.wikipedia.org/wiki/Backgammon#Doubling_cube).)

   This module defines beavering and racooning as game operations. Prior to rolling a player who has the right to double may choose to
   double, which is an applied game operation (because it changes the state of the game). In the resultant game state the opposing player
   is obligated to perform one of 3 operations before "normal" game play recommences with the original doubling player's dice roll:
   - Accept the doubling, after which the original doubling player would recommence game play with a dice roll
   - Foreit the game, after which the game is over an the original doubling player is the winner
   - Beaver (redouble), after which the game enters a substate during which one of two operations must follow:
     - The original doubling player recommences game play with a dice roll
     - The original doubling player raccoons (doubles again), after which the same player would recommence game play with a dice roll

   All operations except the forfeiture eventually lead to the original doubling player recommencing game play in a state that in which
   only a dice roll operation can be applied, and in which the game state has been updated by
   - a change in the doubling value, which will be raised by 1, 2 (beaver), or 3 (racoon) powers of 2 vs the state prior to the
     original doubling
   - a change in the ownership of the doubling cube to the opposing player

1. _Acceptance of guaranteed outcome._ This module does not support the WBGF rule that allows players to agree on match result (single game,
   gammon, or backgammon). The WBGF rule [^1] states that players may terminate a game and declare the result if it is impossible for any
   other outcome to occur given the state of the game. Note however that the inclusion of this operation leads to exponentially greater
   possible outcomes of a game all with the same result, which can greatly impede an SMT solver's ability to generate game states when
   asked to do so (ie test-cases). [^2]

1. _Scorekeeping._ WBDF rules encourage and can require players to report match scores, declare game options, and make other informative
   declarations prior to game commencement. This module does not implement these obligations, as they are really outside the scope of
   actual game play.

1. _"Incorrect match length" rule._ Interpretation of the WBGF "Incorrect match length" rule as stated in the official rules is an
indecidable proposition (in the Godel sense), as there is no reference to what "match length" is or what a "correct" match length would
be throughout the entire rule corpus. This module makes no attempt to impose an iterpretation.

## Domain Datatypes and Validation Functions

### Domain Datatypes

The `Board` datatype serves as the game state. A `Board` is comprised of: 24 `Point` values, a `Bar` value, an integer doubling value,
a doubling cube ownership indicator, and a field indicating doubling substate (whether beavering or raccooning is available). The
doubling value is stored in the game state as a log base 2 value -- so that the game's cube value is 2 raised to the doubling value. 0 means the
cube value is 1, 1 --> 2, 2 --> 4, 3 --> 8, and so on.

A `Point` consists of a `Color` value and an integer count of pieces, representing a count of pieces of one player or the other.
The `Color` sort has 3 values: `{ Red, Black, Neutral }`, where `Neutral` serves as a special indicator that a `Point` is unoccupied by
either player. `Color` values are also used to indicate wich player's turn is next.

A `Bar` consists of just 2 integers: a `Red` count and a `Black` count, indicating the number of pieces of each player occupying the game bar.

### Validation Functions

----

[^1] See [WBGF Rules](https://wbgf.info/tournament-rules/) section 4.5 "Completion"
[^2] I'd be really impressed with a contributed PR encoding this rule!
