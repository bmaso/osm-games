# osm-games

A demonstration of operation-state modeling (OSM, pronounced "awesome"). This repo defines operation-state models of a few
popular games: [Connect Four](./connect4), [bowling](./bowling), backgammon (TBD), and spades (a card game, also
TBD). This repo also demonstrates the tools and techniques for rigorously and unambiguously verifing the expected
behavior of a game sequence. That is, how to verify a game sequence is provably within the game's rules through the use of
an SMT solver. The intention is to show that OSM is a powerful and practical technique for defining complex, multi-party, &
distributed system behavior, and that the tools for creating software behavior validators out of OSM descriptions are
freely available and fairly easy to work with.

## OSM Specs in SMTLIB2

This OSM repo uses the `smtlib2` language to describe game "rules". `smtlib2` is a Lisp-like language designed to express
propositional logic -- that is, equational math. Multiple freely available software packages known as "SMT solvers" read and
automatically solve equational systems written in `smtlib2`: [Z3 from Microsoft]() and [CVC5]() are two popular examples. An SMT solver
makes OSM specs written in `smtlib2` usable. With an SMT solver we can:

- **Verify a game sequence conforms to an operation-state model**. This is _the_ key goal of OSM. Most software "specs"
  are unverifiable. They are generally comprised of words and drawings, which sometimes are incredibly detailed (though often not).
  But there is no tool or mechanism on Earth able to objectively verify observed system behavior actually conforms to words and
  drawings, no matter how detailed. With OSM and an SMT solver, it becomes possible to prove observed behavior does not conflict with
  a software spec using an automated, objective, repeatable mechanism.

- **Unambiguously answer novel and unanticipated questions about expected system behavior**. Using all the power of mathematical
  refactoring and symbolic logic, we can answer some questions whose answers are not detailed in a specification. Where a spec based
  on words and visualizations would typically require time-consuming and expensive human interactions and inconsistent reasoning and
  "judgement calls" to answer novel and unanticipated questions, a logical description of behavior can be refactored and
  subjected to mathematical and logical operations (deduction, induction, etc.) to restate facts, and prove novel lemmas about the
  expectations of a system. Someone implementing the software package for scoring a game of bowling, for example, need not consult
  an "expert" to answer questions about the finer points of the game he might not be familiar with if he has an OSM model of the
  game available.

- **Generate test data**. An interesting feature of SMT solvers is that they are quite good at generating values for free variables
  that solve a matrix of equations. For example, given an equational description of bowling, it is possible (and relatively
  easy in fact) to ask an SMT solver to generate a complete valid game of bowling that includes a string of 3 strikes in subsequent
  frames. There's no need to for an engineer to laboriously "make up" data that matches a specific test-case when such data is
  needed, so we can avoid this time-consuming and error prone part of software development.

[Practical SMTLIB2 Advice for OSM] covers the tools and techniques I've figured out so far for developing OSM models in SMTLIB2.

## Operation-state Models

An _operation-state model_ is a logical description of the _behavior_ of a finite-state system or process. The description is
comprised of:

* A state model - At any one point in time, the state of the system can be fully described by a single instance of the state model.
  A graph of algebraic data values with tuples as graph vectors forms a system's state.

  In the game of bowling, for example, individual _throws_ are groupled into _frames_, and _frames_ are grouped into a _game_.
  Each throw includes a count of _points_ and some additional flags, such as _foul_ and _split_. Each frame is comprise of up to
  two regular throws and up to two bonus throws. Each game is comprised of a sequence of 10 frames. Every possible bowling game,
  at any point of play up to and including completion can be completely described by an instance of this state model.

* Operations - The system proceeds through its lifecycle by the sequential application _operations_. An operation is simply a
  tuple that relates a _prior state_ with a _post state_ (which are each instances of the state model), and also with
  _operation input_ values and _operation output_ values. Algbraic data types describe the shapes of input and output values,
  just like the state model.

  In bowling there's only one type of operation: "apply throw". An apply throw operation value will be
  a tuple comprised of:
  * **a _prior game_**: the state of the game before the throw is applied
  * **a _post game_**: the state of the game after the throw is applied
  * and **a _throw_ value**: which is the throw that took the game from its prior state to its post state.

  There is no "output" to a throw operation in bowling, so the operation output model is effectively a nil value.

  A game sequence is comprised of a chain of operation applications. Each operation application entangles a prior game state
  and a post game state. And a prior operation's output state becomes the next operation's input state. Thus the game sequence
  is a chain of operation applications bound together by shared state instances. The game's operation-state model defines what
  makes a _valid_ operation application. An OSM can also be thought of as a operation sequence schema, in the same way that a
  regex expression can be thought of as a "string schema". A regex describes a class of _valid_ strings that conform to the regex's
  pattern. Similarly, the OSM describes a class of _valid_ operation application sequences (a specific type of DAG) that conform to
  the OSM.

  ![An Operation related prior and post states with operation intput and output](./assets/bowling-operation-illustration.svg)

* Validation propositional logic - these are logical, mathematical assertions that a) define _valid_ system state requirements
  in the form of invariant assertions on the system state data types; and b) cleanly define _valid_ operation applications in the
  form of logical assertions relating the operation input, output, prior state, and post state values.

  In the game of bowling, there are multiple assertions that distinguish a valid throw application from an invalid one:
  - the sum of two throws in the same frame can't be more than 10
  - any single throw can't have a negative number of pins knocked down either
  - the frame and game total score in the post game state must reflect the number of pins knocked down by the throw
  - most importantly, a valid throw must reference a _valid_ prior game state and a _valid_ post game state

  Operation validation includes invariant assertions on the game state:
  - frames must be completed in sequential order in both the prior and post game states
  - complex assertions define the entanglment between sequential frames when the prior frame is a strike or spare
  - and so on -- lot's of individual boolean assertions form a system of predicates relating a throw operation's member
    values (the prior state, the post state, and the throw being applied)

  The assertions are expressed as a set of predicate (ie, boolean) functions on the domain of game operations. Note that an
  _equation_ is actually a boolean statement: _if_ the left side of the equation is mathematically identical or reducible to the
  right side (or vice versa), _then_ the equation is "true"; _if_ the  left side of the equation is proveably non-identical to the
  right, then the equation is "false". An OSM model expresses validation logic as a set of equations which must all be _true_ in
  order for an operation application to be valid.

![Game sequence conformance and string regex conformance illustration]()

## Connect Four, Bowling, Backgammon, and Spades in This Repo

The [bowling folder]() defines the game of bowling as a system of equations relating `Throw`, `Frame` and `Game` algebraic datatypes,
and the game process is defined by an "apply throw" operation comprised of those data constructs. I authored the bowling example to be
the premier OSM example in this repo. It is designed to mirror [the "Extreme Programming Episode"](https://sites.google.com/site/unclebobconsultingllc/uncle-bob-consulting-llc/articles/the-bowling-game-an-example-of-test-first-pair-programming)
by Robert Martin and Robert Koss, which has introduced generations of professional developer's to Test-Driven Development practices
since its publication some 20 years prior to the words you are reading now were written. As influential and entertaining as that piece
is, it's of some significance to recognize that the version of "bowling" that Martin & Koss develop during the "Episode" is in fact
_not in conformance with any standard version of "bowling"_. The reputational popularity of  Martin & Koss's episode, coupled with the
fact that it technically fails at its actual stated goal [^1], makes the game of bowling a great focus for an OSM demonstration.

[Connect Four folder]() is meant to be a gentle and yet non-trivial example of OSM applied to a game OSM. Connect Four is a
childrens' table-top game exhibiting very few constraints on a simple domain. The Connect Four OSM describes this game with
a single initial operation "choose first player", a repeated "played takes turn" operation, and a terminal "declare winner" operation.
The game model consists of just an array storing the game table position -> checker color relationship, and couple other
fields to store the current player and the winning player.

Studying the Connect Four OSM is a good way to get an introduction to `smtlib2`. Effectively representing a 6x7 2D game grid, for
example, is surprisingly different in `smtlib2` than in a traditional programming language.

The [backgammon folder]() defines the game of backgammon as a system of equations relating `Point`, `Bar`, `DiceThrow`, and `Board` algebraic
datatypes. The game proceeds throw "apply player turn" operations, which are comprised of these data constructs. I included backgammon because
it is a turn-based game with non-trivial rules for turn play, especially in cases where one player's pieces "block" the other's.

The [spades folder]() defines the game of spages as a system of equations relating several algebraic datatypes, including `Hand`, `Trick`,
`Bid`, etc. Spades is a trick-playing card game played with 4 players arranged into teams. I consider this an interesting example game for
OSM for two reasons:
- the multiple phases each trick and each hand must pass through to complete a game make for an interesting study in game state representation
- the universe of card games is huge; laying down the mechanics of how to represent cards, hands, "dealing", and other
  common card game features opens up a wide set of non-trivial games to practice and perfect OSM techniques

----

[^1] Im not trying to throw shade on Martin & Koss by pointing out they missed their _stated_ goal while demonstrating the tools
and techniques of TDD. In fact history has a few exalted examples of books and works that introduce powerful intellectual tools to the world,
while _technically_ missing the original goals of the work. Artistotle himself introduced the essential operators of boolean logic and set
theory to the world in his "Organon": the AND, OR, NOT operators an the existential and universal quanitifiers all were introduced to the world
in this book. But Aristotle actually failed at his _indended_ purpose, which was to rigorously define the exact logical meaning of
Koine Greek words and phrases. (Turns out spoken language is fundamentally incompatible with logic.) Niccolo Tartaglia intended to equate classical geometry with then-nescent algebraic and "sum of infinity"
techniques in his 1556 work "Questi et Inventioni Diversi", which he technically failed to do. But he did succeed in introducing the world to
the validity of many techniques subsummed in what we call integral calculus today.