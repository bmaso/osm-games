# OSM Specs in smtlib2

`smtlib2` is a single-source language. There is no version of "import" or "using", and no concept of modules or re-usable
source. An `smtlib2` solver is given a single source file containing equations and assertions, known as a _formula_, and the
solver does it's best to find bindings for the formula's unbound variables that make the assertions _true_. The latest
standard version is [2.7](https://smt-lib.org/papers/smt-lib-reference-v2.7-r2025-02-05.pdf).

## Flash Intro to Using an SMT Solver

There are 3 things you need to know to start using an SMT solver:

1. An SMT Solver's job is to solve a system of assertions. Assertions can be any boolean predicate. Equations, inequalities, or
  any other expression that resolves to a boolean value can be a valid assertion.
1. An SMT solver will find _exactly one_ solution to a system of assertions. The solution is known as a _model_ in `smtlib2` parlance. A
  model is just a set of name -> value pairs for all unbound variables and functions you have declared, where the values are consistent
  with the assertions you've defined. Variables are usually known as "constants" in `smtlib2` parlance.
1. In case you didn't catch it in the previous point, SMT solvers will find solutions for unbound _functions_, not just unbound
  constants. In fact a "constant" is just a synonym for a function with zero parameters. (Discussed more below.)

### Finding a Model for a System of Assertions in `smtlib2`

Let's do a very quick illustrative example. Imagine I want to identify an integer value for \(x\) that satisfies
the following system of inequalities:

\[
0 \lt x < 5
\]

\[
21x + 4 > 60
\]

\[
101x^2 < 40^2
\]

Here's the encoding in `smtlib2`:

```
(declare-const x Int)           ;; declare in unbound integer variable "x"

(assert                         ;; defining each constraint on x as a boolean assertion
    (and
        (< 0 x)
        (< x 5)))
(assert
    (> (+ (* 21 x) 4)))

(assert
    (< (* 101 x x) (* 40 40)))

(check-sat)                     ;; This command means "find a model that satisfies all my assertions"
```

When I feed this to an SMT solver, it replies immediately with

```
> sat
```

which simply means that is was able to satisfy the assertions. Once it has found a model we can interrogate it:

```
(get-value (x))
> ((x 1))
```

In fact there are 3 solutions to this system of equations. All bindings \(x=\{ 1, 2, 3\} \) are valid solutions. All an SMT solver does
is find _one_ solution that satisfies all assertions. It won't natively find all of them for you. That's all the SMT solver is designed
to do: find a _single_ solution to a system of assertions.

An OSM spec in `smtlib2` is a system of equations (assertions) you can apply to unbound variables, where the types of the unbound variables
are algebraic datatypes representing game states. You validate a specific game sequence by invoking `(check-sat)` in an SMT solver.
If the game sequence is valid the SMT solver will return `sat`, and if it is invalid it will return `unsat`.

### Zero-entry Models, I.e. No Unbound Constants or Functions

An SMT solver will validate a set of assertions containing _no_ unbound constants or functions just fine. When we do
this we are really just asking the SMT solver to verify the assertions are internally consistent.

For example I can use an SMT Solver to prove the conjecture _for every integer there is an even higher integer_. In symbolic
logic we would write this as:

\[
\forall n \in I. \exists m \in I. m > n
\]

(which admittedly is Vulcan to most people. Read this as "For every integer \(n\), there exists another integer \(m\) such that \(m \gt n\)".)

```
(assert
    (forall ((n Int))
      (exists ((m Int))
        (> m n))))

(check-sat)
> sat
```

I haven't declared any unbound constants or functions here. I've just made a universal assertion, which indeed is true. The SMT
solver has found a model consistent with this assertion: the empty model. The SMT solver known all the fundamenta theories of
arithmetic and algebra, and is able to verify this assertion from the first principals that it knows.

### Interrogating the Model

Once you have successfully generated a model using the `check-sat` directive, you can then use the `get-value` directive to
print out the value of expressions. `get-value` actually can be used to print out _any_ computable expression. It's the equivalent
to a "println" statement in most programming languages.

```
(declare-const x Int)

(check-sat)
> sat

(get-value (x))
> ((x 0))

(get-value ((* 20 (+ x 5))))
> (((* 20 (+ x 5)) 100))
```

* I asked an SMT solver to find a model for an integer \(x\) with no restrictions
* the solver picked the number "0". The solver could have picked 1, 42, or -867,329. I'm guessing zero is one of this solver's
  "go to" integer values, but it could have been any integer.

The `get-value` directive takes a single argument: a _list_ of expressions to evaluate. A list in `smtlib2` is just a parentheses-delimited,
whitespace-separated sequence of terms. `get-value` results are a list of term -> value pairs. Here are a couple more
examples:

```
(get-value (x x x))
> ((x 0)
   (x 0)
   (x 0))

(get-value ((+ x 1) (+ x x) (= 0 (mod x 2))))
> (((+ x 1) 1)
   ((+ x x) 0)
   ((= 0 (mod x 2)) true))

```

### Bound constants

In addition to unbound constants you can also define, well, _constant_ constants. That is, symbols with a fixed, bound value. Use
the `define-const` directive to do this:

```
(define-const inches-per-foot Int
    12)

(check-sat)
> sat

(get-value (inches-per-foot))
> ((inches-per-foot 12))
```

## Tools and Project Layout for Creating OSMs

I re-use the C pre-processor to modularize a
non-trivial `smtlib2` project into separate, semantically partitioned source files [^1], which is key to making mangeable, modularized
formulas. `cpp` is a standard command-line C development tool freely and easily available. I use well-known `#include`, `#ifndef`, `#define` directives to reference one dependent source file within another, exactly like you would in a C-language project.

I like to organize a project's source base into `main` and `test` folders, like so:

```
index.md
formula/
  |-- main/
  |   |-- board.smt2
  |   |-- board-ops.smt2
  |   |-- ...
  |- test/
  |   |-- test.board.validation.empty-board-before-first-turn.smt2
  |   |-- test.board.validation.player-turn-forfeitures.smt2
  |   |-- ...
```

Important features:

* The `main` folder contains the OSM: the domain and operation definitions, and the validation predicates describing a valid game
  sequence. These files don't contain any assertions, only definitions of what makes valid domain values and operations in the game
  I'm defining.
* The `test` folder contains formulas proving properties about my OSM. These test formulas ensure the
  validation predicates actually mean what I expect them to mean [^2]. A test is going to prove assertions such as:
  _in checkers, every valid "jump" operation has the space opposite the jumping checker empty_.
* `index.md` is just a markdown documentation source file. What you are reading now is stored in markdown format within the
  [`osm-game` repo](https://github.com/bmaso/osm-games). 

To prove a test's assertions are true, I pipe the pre-processed test `smt2` file through `cpp` and then on to my chosen SMT solver (usually
Z3 for reasons I won't go in to here). To prove a test formula `test/test.validation.example.smt2` I execute the following
command-line from the root project folder [^3]:

```
> (cpp -w -P -iquote./formula/main ./formula/test/test.validation.example.smt2 && cat) | \
    z3 -smt2 -in
```

Explanation:

* `cpp -w -P -iquote./formula/main ./formula/test/test.validation.example.smt2` -- pre-process the named `smt2` file. Search in the
  `./formula/main` folder for files referenced in any `#include` directives.
* `... && cat` -- after sending the pre-processed `smt2` file to Z3's input, also keep Z3's stdin open, appending everything I type
  to the formula. This let's me type in extra `smtlib2` directives, like additional assertions, constant
  definitions, etc. as additional formula content. This let's me do REPL-like development and experimentation. Since there is no
  `smtlib2` IDE, this is the old school next-best-thing for rapid development.
* `z3 -in -smt2` -- pipe the output of the pre-processed `smt2` file (appending anything I type on the keyboard), to Z3's direct input.

During a game formula development session I will have two windows open: a text editor open to the project root folder; and a
terminal with my chosen shell (I like `zsh`), with the project root as the current dir. 

## Values and Validation

An OSM spec defines the universe of valid state change sequences a system can undergo during its lifecycle, from
initial state to terminal state. It does not define _how_ the system progresses from one state to the next, but
rather merely what is allowed.

We define an `smtlib2`-language OSM by defining two sets of datatypes, each with validation predicates:

* **_domain_ datatypes** describing state values, operation inputs, and operation outputs (where the model calls for them)
* **_operation_ datatypes** describing the individual atomic state changes the model can undergo

Operation values are comprised completely of domain datatype values. Every operation references at least two
domain values: a **prior state** and a **post state**. Together these two values define the change that the system undergoes.

### Defining Domain Datatypes

The `define-datatype` directive is used to define new datatypes, as the name implies. There are four distinct use-cases:

1. **Define an enumeration type**. This is just a collection of nominal identity values. Each value has a unique symbolic name,
  with no other properties. There is no implicit ordering to the type members. It's just a set of distinct, nominal values.
  I use this to define finite collections of values. For example, here's an enumeration of card suits:

    ```
    (define-datatype Suit (
      spades
      clubs
      hearts
      diamonds))
    ```

    Reference members simply by their symbolic name in other expressions where a `Suit` is expected or allowed.

    All we can do with `Suit` value is check equality. There is no ranking or ordering. There are a few ways to define
    an ordering, which I'll cover just below.

1. **Define a record type (aka tuple type)**. This is a collection of fields, with a symbolic name given to a "constructor"
    value used to create record instances.

    ```
    (define-datatype Card (
      (card
        (suit Suit)
        (rank Int))))
    ```

    Here I've defined a record type `Card` with two fields: `suit` of type `Suit`, and `rank` of type `Int`. The symbol `card` is
    a constructor, used to define `Card` values. For example, here I create a `Card` constant value named `ace-of-spades` using the `card`
    constructor function, with `spades` and `1` as the `suit` and `rank` field values, respectively. (Note the field values are provided positionally, in the same order the fields are declared in the type definition.)

    ```
    (define-const ace-of-spaces Card
        (card spades 1))
    ```

    I can extract the `suit` and `rank` field values from a given `Card` value using field "extractor" functions, which have the same
    symbolic name as the field. For example, here is a boolean function that determines whether or not two `Card` parameter values
    (named `c1` and `c2`) have the same `suit` field value.

    ```
    (define-fun is-same-suit ((c1 Card) (c2 Card)) Bool
        (= (suit c1) (suit c2)))
    ```

1. **Define a sum type (aka "typed union", "disjoint union", or "variant type")**. This is a collection of constructors, a kind
    of closed collection of subtypes. This is equivalent to a Haskell `data` type, or sealed trait subtype set in Scala. Each
    constructor produces a value with its own set of fields. All values are instances of the parent type. In this contrived example
    I create a set of types representing different types of furntiture:

      ```
      (define-datatype Furniture (
          (chair
              (seat-depth Int)
              (seat-width Int))

          (couch
              (profile-width Int)
              (profile-depth Int))

          (credenza
              (drawer-count Int)
              (height Int))))
      ```

    Each constructor produces a `Furniture` instance. In addition to the constructor and field extractor functions, `smtlib2` also
    provides a couple ways to identify whether a given `Furniture` instance is a `chair`, `couch` or `credenza`:

    * **a `match` statement**. A weaker version of Scala's `match` and Haskell's `case .. of`. It doesn't support nested pattern
       matching. Here, for example, is a function that maps a `Furniture` value to a descriptive string value:

       ```
       (define-fun furniture-description ((f Furniture)) String
         (match f (
            ((chair d w) "A chair")
            ((couch w d) "A couch")
            ((credenza c h) "A credenza"))))
       ```

    * **the `is` parameterized predicate**. I'm not going to take the time to explain much about this, because the syntax is a
        bit complicated, and I don't use this construct often. Here is a function that tells you whether or not a `Furniture`
        instance is intended to be sat upon:

        ```
        (define-fun should-be-sat-upon ((f Furniture))
          (not ((_ is credenza) f)))  ;; you shouldn't sit on a credenza, and you can sit on anything else
        ```

        The structure `(_ is <constructor>)` produces a function of type `<datatype> -> Bool`. That is, it determines whether or
        not a `Datatype` instance is an instance of a particular constructor.

1. **Define a parameterized sum type**. Let's say you want to define a list of Ints, or a set of strings. That is, a type parameterized
    by another type. Here for example is a parameterized `Maybe` type, similar to the standard Haskell `Maybe x` and the Scala
    `Option[X]` types:

    ```
    (declare-datatype Maybe (par (T) (
      (none)
      (some (value T)))))
    ```

    This defines a whole class of datatypes: `(Maybe Int)`, `(Maybe Bool)`, etc. It can be applied recursively: `(Maybe (Maybe String))`
    for example.

    The datatype `(Maybe Int)` has two constructors: `none` and `(some (value Int))`. It can be used to represent a "nullable" value type.

    `smtlib2` parameterized types are _not_ as useful as you would think, because they often imply recursive graphs and recursive
    functions. Think cons lists, finger tries, etc. SMT solvers abhor recursion, because they avoid exploring repetative loops when
    solving systems of equations. This is a fairly constraining restriction especially for programmers with a functional mindset, who
    instinctually reach for a tool like this first. They will need to learn new representational skills and use alternative constructs
    to represent domain values and validation rules.

    SMT solvers have internal special cases for a few common recursive datatypes, such as `List` and `Set`. These are known as
    _theories_, and is beyond the scope of this explanation.

    The OSM examples in this repository avoid recursive structures altogether, both custom ones and those provided natively in theories.
    I find the solvers have very unpredictable results with even recursive type built-in to solvers, such as `List`, or `Set`;
    often assertions you would think are simple turn out to confound solvers, and other assertions you would think are way too
    complex get solved easily.

    There are a cases where parameterized types are useful for representing domain concepts. The `Maybe` type above, for example,
    is not recursive. It works predictably as part of formula proofs.

### Arrays

An array in `smtlib2` is an _associative array_. It is not necessarily integer indexed, and it is not a contiguous portion
of memory (like in C and related languages).

The `Array` type is parameterized on both the index type and the value type. So you can define an array indexed by integer. You can also
create an array indexed by strings, booleans, or even your custom type like the `Furniture` datatype above. For each index, the
`Array` maps a value.

In `smtlib2` arrays must cover their entire index space. An array indexed by integer has a value for _every_ integer, meaning the array is
infinite. An array indexed by boolean values will only have 2 entries: one for `true` and `false` index values.

For all solvers I've used, an array value is just a linked list of index -> value pairs. There are two contructors for making
arrays: `store` and `const`, which are kind of like cons list's `car` and `cdr` structures.

`const` creates an array that is constant for all index values. You have to "cast" a `const` value to the correct array type whenever
you use it. (The `smtlib2` language needs a type hint to know what kind of array you want to create.) For example, here is an integer-indexed
array with the value 7 for all indexes:

```
(define-const all-sevens (Array Int Int)
    ((as const (Array Int Int)) 7))
```

The `select` function retrieves an array value given a specific index value. 

```
(check-sat)
> sat

(get-value (
    (select all-sevens 0)
    (select all-sevens 42)
    (select all-sevens -876322)))
> (((select all-sevens 0) 7)
   ((select all-sevens 42) 7)
   ((select all-sevens -876322) 7)
```

The `store` function creates a new array from an existing array by replacing just one of the existing array's index -> value tuples. Here
I create a new array from `all-sevens` where the value at index 1 is 77. All other indexes in the new array will be 7.

```
(define-const all-sevens-but-index-1 (Array Int Int)
    (store all-sevens 1 77))
```

### Unbound Functions

Witness me try to get an SMT solver to figure out the function \(f(x) = x^2\) from example values:

```
(declare-fun squared (Int) Int)

(assert
    (= 0 (squared 0)))

(assert
    (= 1 (squared 1)))

(assert
    (= 4 (squared 2)))

(assert
    (= 9 (squared 3)))

(check-sat)
> sat

(get-value ((squared 1) (squared 2) (squared 3)))
> (((squared 1) 1)
   ((squared 2) 4)
   ((squared 3) 9))
```

That looks promising! But things start to fall apart quickly...

```
(get-value ((squared 5) (squared 6) (squared 100)))
> (((squared 5) 0)
   ((squared 6) 0)
   ((squared 100) 0))
```

Huh? It did great figuring out the square values of for the examples I gave it, but seems to think every other square value is 0.

Let's look behind the curtain on what the solver has decided about `squared`:

```
(get-value (squared))
> ((squared (store (store (store ((as const (Array Int Int)) 0) 1 1) 2 4) 3 9)))
```

This SMT solver is simply picking all input function parameter -> result pairs, and making an array out of them. For every other
parameter than the ones I've provided, the function result will be 0.

This is the state of the art of SMT solvers right now. They treat unbound functions as just a set of parameter -> value tuples,
and implement them with an array. Watch what happens when I ask the solver to create a `squared` function that is correct at
_every_ integer:

```
(declare-fun squared (Int) Int)

(assert (forall ((x Int))
  (= (squared x) (* x x))))

(check-sat)
> unknown
```

The `unknown` result will only appear after a very long pause and heavy CPU and memory consumption by the SMT solver process. The solver is
trying to generate an _infinite_ array graph, computing the value `(* x x)` for every integer. Eventually it runs out of time or resources,
returning `unknown`. This response is what the solver generates when it can't decide whether a set of assertions is satisfiable (`sat`)
or unsatisfiable (`unsat`), always because the problem just takes too many resources for it to solve.

Honestly I haven't found a use for unbound functions in OSMs yet. They are useful for other SMT solver use-cases, but not
so much when designing an operation-state model. I stick to unbound arrays with finite index types.

### Validation Predicates for Game Sequence Values

Let's define a two-die `DiceRoll` datatype. My first attempt is to make a type with two integer values representing each die.

```
(declare-datatype DiceRoll (
    (roll
        (die1 Int)
        (die2 Int))))
```

And now I'm going to assert that each die can only be between 1 and 6:

```
(assert
    (forall ((d DiceRoll))
      (and
        (<= 1 (die1 d))
        (<= (die1 d) 6)
        (<= 1 (die1 d))
        (<= (die1 d) 6))))

(check-sat)
> unsat
```

Oh no! What happened? All I did was make a make an obvious assertion about dice rolls, and the solver says the assertion is unsolvable!

The issue here is that ***you can't make universal constraints on datatypes***. A more obvious example: you can't say something
like "all integers are divisible by two". That just doesn't make sense. We know some integers that are not divisible by
two. So that assertion should always produce an `unsat` response from the solver.

Similarly you can't say "all `DiceRoll` instances have a `die1` value greater than 0". We know some `DiceRoll` values _do_ have a
`die1` value less than or equal to zero. For example: `(roll -100 -100)` is a `DiceRoll` value that breaks this rule. So the
assertion not universally satisfiable.

Instead we can define a predicate function that returns `true` for `DiceRoll` values that are "valid" in our problem domain,
and returns `false` for all others (which are by definition "invalid" in our problem domain):

```
(define-fun diceroll.valid.range ((d DieRoll)) Bool
    (and
        (<= 1 (die1 d))
        (<= (die1 d) 6)
        (<= 1 (die1 d))
        (<= (die1 d) 6)))

(check-sat)
> sat
```

I create validation predicate functions like this for each domain datatype in a game. These validation functions define the
invariate constraints on domain values that appear in any valid game sequences. When validating an entire game sequence, I will
ensure that each domain object in the game sequence graph passes all applicable validation functions. Thus all domain objects
in a valid game sequence graph are automatically valid.

### Domain Optimization Using Finite Datatypes

The `DiceRoll` datatype above has an infinite number of values, which stems from the fact that there are an infinite number
of values for each field.

An alternative to this definition of `DiceRoll` is a finite type, one in which the only values that exist are valid.

```
(declare-datatype DieRoll (
    roll_one
    roll_two
    roll_three
    roll_four
    roll_five
    roll_six))

(declare-datatype FiniteDiceRoll (
    (roll
        (die1 DieRoll)
        (die2 DieRoll))))
```

All `DieRoll` values are "valid". Each die roll can only represent a roll of one through six, because those are the only die rolls
that exist. There are therefore only 36 possible `FiniteDiceRoll` values, and all of them are "valid" as well.

Of course I've lost the association of a `DieRoll` to any actual number. There's nothing saying a `roll_one` represents
the number 1. I can't add two `DieRoll` values together either; I have no way to know what the total pip value of
a `FiniteDiceRoll` is, since there is no number associated with constituent values. This is easy to solve though. Since 
`FiniteDiceRoll` is finite in size, we can create an array and associated function that maps each `FiniteDiceRoll` to a total
pip value:

```
(define-const dieroll.pips.array (Array DieRoll Int)
  (store
  (store
  (store
  (store
  (store
  (store ((as const (Array DieRoll Int)) 0)
    roll_one 1)
    roll_two 2)
    roll_three 3)
    roll_four 4)
    roll_five 5)
    roll_six 6))

(define-fun dieroll.pips ((d DieRoll)) Int
  (select dieroll.pips.array d))

(define-fun diceroll.pips ((d FiniteDiceRoll)) Int
  (+ (dieroll (die1 d)) (dieroll (die2 d))))
```

The key goal is avoiding quantifying over infinite datatypes in order to define constraints over finite ranges. This
is an optmization to help your solver figuring things out in finite time. It's going to take some practice to understand
the payoffs and benefits of different domain design decisions when creating your own smtlib2 OSMs. Experience with
imperative and functional computing languages sometimes leads you astray.

### Defining Operation Datatypes

An OSM operation value represents an atomic state change in the system being modeled. In a table-top game this would typically
be a "move". In a multi-step distributed function, this would be the state change associated with processing an event. In a time-sequenced
system, this might just be a state change associated with the passage of a unit of time.

All operation datatypes are tuples with these common features:

* **a `prior_state` member**. This is a domain value representing the full state of the system prior to the operation application.
* **a `post_state` member**. This is a domain value representing the full state of the system after the operation application.
* zero or more **operation input values**. These are parameters to the type of operation being performed.
* zero or more **operation output values**. When defining a larger OSM from smaller component OSMs, these values
  communicate information between sub-components. (Beyond the scope of this repo.)


Consider a game of bowling. The only operation in this system is a "throw": the act of rolling a ball down an alley and (hopefully)
knocking some pins over. Imagine I've already defined a `Game` domain datatype representing a snapshot of game state, and a
`Throw` datatype representing a single throw. I would have an `ApplyThrowOp` datatype defined like so describing the act
of updating a game with the result of a throw:

```
(declare-datatype Game.ApplyThrowOp (
    game.apply-throw-op (
      (prior_game Game)
      (post_game Game)
      (throw Throw))))
```

The definition of the mechanics of the game are all inside the operation validation predicate. This is the validation function that
defines a "valid" throw operation. This function returns `true` when:

* **`prior_game` is valid**. This is, the validation function I've defined for `Game` objects applied to the `prior_game` value is `true`.
* **`post_game` is valid**. The same validation function applied to the `post_game` value is `true`.
* **`throw` is valid**. The validation function I've defined for `Throw` objects applied to the `throw` value is `true`.
* **the post_game value is equal to the prior_game value with the throw applied**. This is where the mechanics of game play are encoded.
  This is a validation function that "entangles" the prior and post game states through a set of equations, equating specific
  frame and throw values in the post game state to values in the prior game state, and also equating the "latest" throw space
  in the post game state to the `throw` value.

The initial few lines of the `ApplyThrowOp` value validation function are going to look like this:

```
(define-fun game.apply-throw-op.valid ((op Game.ApplyThrowOp)) Bool
    (and
        (game.valid (prior_game op))
        (game.valid (post_game op))
        (throw.valid (throw op))
        ... additional validation function references, validating the throw applied
            to the prior game is equal to the post game ...
        ))
```

[^1]: It is mildly surprising to realize C is a "single source" language. The C compiler can actually only compile a single,
    monolithic source file at a time. The C pre-processor is key to enabling C language code to be modularized into separate files
    and re-used in functional pieces.

[^2]: I try to use TDD when developing an OSM. I will often first write test assertions proving the properies I want in the OSM, then
    write the OSM domain objects, operations, and predicates that make the property assertions satisfiable by an SMT solver.

[^3]: This example demonstrates my preferred `smtlib2` style. I use newlines and indentation in inter-term whitespace to mimic the
    indentation style of languages like Scala 3 and Python. I place the closing parens of each parens-enclosed expression
    immediately after the final term to keep the indented style.