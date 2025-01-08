# The Bowling Game: An Example of Equational Theory Development

**Engineer's Notebook: An Equational Thinking Episode**

| "The person who says he knows what he thinks but cannot express it usually does not know what he thinks.""
    ― Mortimer J. Adler, How to Read a Book: The Classic Guide to Intelligent Reading

## Introduction

In 2000 Robert "Uncle Bob" Martin published [_The Bowling Game: An example of test-first pair programming_](https://sites.google.com/site/unclebobconsultingllc/uncle-bob-consulting-llc/articles/the-bowling-game-an-example-of-test-first-pair-programming?authuser=0),
memorializing a TDD pair-programming session between Bob Koss and Bob Martin, during which the Bobs endeavor to
implement a set of Java classes were that combine to score a game of bowling.

Distinctly missing from the narrative: any actual definition of "the game of bowling". Here's Bob Martin's description
of what they set out to build, which is the best indication of what they were trying to accomplish:

| RCM: "It seems to me that the inputs are simply a sequence of throws. A throw is just an integer that tells how
| many pins were knocked down by the ball. The output is the data on a standard bowling score card, a set of frames
| populated with the pins knocked down by each throw, and marks denoting spares and strikes. The most important
| number in each frame is the current game score."

What's missing is any "standard" that the solution can be verified against. In effect what the Bobs end up doing is defining their own axiomatic standard -- their code _is_ the standard, so of course it does what it is supposed
to do. Does it correctly score the definition of "the game of bowling" that the Bobs were trying to implement?
We don't know. Neither actor produces a definition of "bowling". Bob Martin refers to _"a standard bowling score
card"_, but fails to reference an actual standard that he is working from.

What's missing is a logical definition of the bowling standard that Bob alludes to. Armed with such a tool, the
development process in the narrative would have gone more smoothly and quickly, and it would have produced a
provably correct (or provably incorrect) final software package. I imagine they also would have identified possible
failures of the software they produced (described below).

Instead of a provably correct result, what the Bobs produced is _some_ integer sequence reduce function,
implemented internally by a set of inter-reliant Java classes. Most of the narrative concerns incremental development
of the Java classes. Ignoring the internal intricacies and nitty-gritty of the Bobs' domain and problem space
exploration, the final work product is effecitvely a reduce function `bowling_score`:

```smtlib2
; smtlib2 declaration of a reducing function that produces a Game from a sequence of integer "throws"

declare_fun(bowling (throws (Array Int Int)) Game)
```

As with most produced software, there's no way to determine whether the final product actually fulfills its
specification, because the specification is imprecise, collectively assumed, or perhaps never really existed in the
first place. There's no way to verify that such software conforms with the standard it is intended to
implement.

And like many software projects, this one ends at the terminus of exhaustion rather than at the provable completion of
its stated task. Such projects end when the stakeholders are exhausted of resources, and someone with adequate
authority can persuasively argue that the project is complete. In this case, the Bobs and the reader stand in for
stakeholders, and the resource that is exhausted is creative imagination (and attention span). The end of the
narrative expresses this state:

| RSK: "That pretty much covers it. Can you think of any more meaningful test cases?"
|
| RCM: "No, I think that's the set. There aren't any there that I'd be comfortable removing at this point."
| 
| RSK: "Then we're done."
| 
| RCM: "I'd say so. Thanks a lot for you help."
|
| RSK: "No problem, it was fun."

A much more convincing TDD episode would have started with a logical, objectively provable definition of
the target algorithm, and incrementally developed a Java implementation with individual test cases proven to meet the
standard. In this article we will first develop a logical definition of "bowling". We will then utilize this logical definition
to explore how the Bob's TDD episode may have evolved differently if the original goal had been to provably meet this definition.

### The Bowling Score Card Standard

The governing body for bowling in the US is the United States Bowling Congress ([USBC](https://bowl.com)). This
organization publishes [a standard for scoring a game of bowling](./assets/ScoreHowto.2024-11-11.pdf), which somewhat
matches the Bobs' internal understanding of the game, with some key differences:

1. The official version does not support the concept of an _incomplete_ game. A game consists of all necessary
  throws [^1] to complete 10 frames: up to 2 throws for the first 9 frames, and two throws plus one or two bonus 
  throws for the tenth frame. Legal games can be produced from as few as 12 throws (12 consecutive strikes), and
  as many as 21 throws (any sequence of 21 throws that includes no strikes).

  The TDD narrative's technique for developing a test suite, by constructing partially-complete games and testing
  the state of those games, coincidentally mimics the way that the USBC official scoring standard is written. This is
  a constructivist pattern, describing how to incrementally accumulate a single throw into a game in progress. The
  standard also implies a terminal condition which ends the process, producing a completed game. The constructivist
  description ensures that if you apply the incremental accumulation rules to a sufficient number of throws, you will
  end up with a valid, completed game.

  In the TDD narrative, most of the Bobs' test cases score incomplete games -- games in progress. We can see Bob
  Martin briefly wrestle with the issue of game incompleteness at one point:

| RSK: "Hmmmm... if we call add(10) to represent a strike, what should getScore return? I don't know how to write
| the assertion, so maybe we're asking the wrong question. Or we're asking the right question to the wrong object."
|
| RCM: "When you call add(10), or add(3) followed by add(7), then calling getScore on the Frame is meaningless. The
| frame would have to look ahead at later frames to calculate its score. If those later frames don't exist, then it
| would have to return something ugly like -1. I don't want to return -1."

  To a software engineer, this incremental, constructivist style of algorithm implies a _reduction_. A game is
  the product of a reduce operation on a sequence of throws. The computation receives a sequence of throws, and
  produces a single completed game by repeated incremental accumulation of each throw to an accumulator -- a "game in
  progress".

  Typically an iterative reduce operation can be isomorphically translated to an iterative "scan" operation,
  where the intermediate result of applying the "next" element to an accumulator object are retained. These
  intermediate states are the incompleted games that the Bobs' test cases are concerned with.

  The accumulator type is often a slightly more "relaxed" version of the final reduce operation product type, because
  it needs to have the flexibility to represent a computation "in progress", not just valid and completed values. In
  our case, the "game in progress" needs to be able to represent missing values, such as the "meaningless" frame
  value that Bob indicates above. The "game" model produced by the USBC bowling definition cannot have "missing"
  or incomplete frames, but the "game in progress" (the intermediate accumulator model) can.

  This article develops the bowling standard as a reduce operation. A reduce can be translated to a scan without loss
  of information, which means it will be easy to create test cases on partially completed games that can be proven
  to conform to the standard by a logic verifier. That is, we can prove candidate software implements the exact
  same test cases the Bobs' develop -- but a lot faster and with absolute confidence our test case expectations are correct.

1. In the official version of bowling, a throw cannot be represented by a single integer. In the TDD narrative,
  Robert Koss and Bob Martin quickly convince themselves, incorrectly, that a single integer is sufficient to store
  the information of throw. Here's Bob Martin's words from above, again repeated to show where the unchallenged
  assertion is made very early in the narrative:

| RCM: "It seems to me that the inputs are simply a sequence of throws. A throw is just an integer that tells how
| many pins were knocked down by the ball. The output is the data on a standard bowling score card, a set of frames
| populated with the pins knocked down by each throw, and marks denoting spares and strikes. The most important
| number in each frame is the current game score."

Again a little later, the assumption is reinforced:

| RSK: "Do you have a clue what the behavior of a Throw object should be?"
|
| RCM: "It holds the number of pins knocked down by the player."

  The USBC standard supports a legal throw, for which the number of pins knocked down would be a valid
  representation. The standard also says that a throw may be a _foul_, recorded on the score card with the letter
  "F", and adding no pins the the accumulate score. The Bobs' model is inadequate to produce a score card for all
  valid bowling games, because some valid games include fouls.

  This may seem like persnickety special-casery, and perhaps it is, but it is evidence that the Bobs' were
  not developing any objectively provable implementation of a standard, but instead were simply encoding a
  subjectively-derived psuedostandard. This will be the case with all software developed without an objectively
  verifiable logical model, such as the smtlib2 model developed below.

1. In addition to fouls, the USBC standard also supports recording "split" throws: throws which leave pins standing
  in certain patterns. A split throw is recorded as a integer number of pins with the tag letter "S" next to it.
  Splits only occur in the first throw in a frame. So again, the final implementation created by the Bobs cannot be
  used to generate a correct "standard score card" for all legal games.

## Developing Equations for a bowling score card

The missing piece in Bob Martin's TDD narrative is a verifiable logic model. Armed with such a model, any input
and any output of the system can be verified using a logic solver. Smtlib2 is a very capable language for logic
modeling, readily understandable to software professionals becuase it is very Lisp-like. Several logic solvers exist
that accept smtlib2 models, such as [Microsoft's Z3](https://github.com/Z3Prover/z3/wiki),
[CVC4](http://cs.nyu.edu/acsys/cvc4/), and several [others](https://smt-lib.org/solvers.shtml).

Let's start by reviewing a bowling score card, and develop logical model of a bowling game from it.

![./assets/example-bowling-scorecard.svg]

The score card reflects how the game of bowling structured: there are 10 "frames", or what might be called "turns" in
other games. A player scores from 0-30 points in each frame. The score card represents each frame in the game as
one of 10 squares, read from left to right.

In the square for each frame we write the _accumlated total points_ (the sum of points in all previous frames plus
the points scored in the current frame) rather than the points scored in each frame individually. 

There are areas towards the top of each frame's square for representing the 1 or 2 throws that are part of each
frame.

The rules and traditions for where and how to display each throw in a frame, as well as the tradition of displaying a
running sum, are _visualization_ rules. The formal logical model we now develop is easily transformed into this
kind of representation, but is actually a bit simpler. We will define the model of a "game in progress" -- a more
relaxed model than a "completed game" model. We can that add restrictions on the relaxed model to define the
completed game model.

### Representing a Throw

While a game is in progress, throws can take on one of 4 values: a _delivery_ or a _foul_, and also a couple special
case values `incomplete` and `open` who's utility will be more obvious later.

TODO: Throw definition and description
```smtlib2
```

TODO: assertions on intra-throw constraints

### Representing a Frame and a Frame in Progress

A game is comprised of 10 frames with 2 throws each, and two "bonus" throws for use when the frame includes a
strike or a spare.

Here is an algebraic data type for a bowling frame. In addition to the throw values, the definition includes
indicator flags for strike and spare, and a field for the computed score.

> Note: this is not how you usually think of a bowling frame, which is typically described as including "one or two
> throws, except in the case of the tenth frame which has 2 or 3 throws". _That_ definition is how frames are
> represented in the _score card visualization_. The definition above is a lot simpler, and is what we use
> to define the _bowling algorithm_, which is different that the visualization.

- TODO: datatype definition
```smtlib2
```

-- TODO constraints for the consistency of strike and spare flags, the throws, and the frame score value
```smtlib2
```

#### A frame's score

 A frame's score can be computed by summing the values of the frame's throws using the score-summing function
 `score.sum`. If any of the frame's throws are `incomplete`, then the frame's score will also be `incomplete`.

 ```smtlib2
 (define-fun frame.score ((f frame)) score
   (
     (score.sum
     	 (throw.score (_ throw1 frame))
       (throw.score (_ throw2 frame))
       (throw.score (_ bonus1 frame))
       (throw.score (_ bonus2 frame)))
   )
 )
 ```

#### Applying a throw to a frame

The initial state of all game frames includes `incomplete` throw and bonus fields. As the game
progresses, these fields will be assigned values corresponding to the player's throws while playing.

We define a function `frame.apply-throw` that applies a throw to a frame below. Let's walk through the logic of
this method by listing the cases that must be considered.

##### Throwing less than 10 pins the first throw

Initially in all frames `throw1` and `throw2` are `incomplete`, and the bonus throws are also `incomplete`. After
applying a throw of < 10 pins:
* The `throw1` field captures the throw
* The `throw2` field remains `incomplete`. We need at least 1 more throw to complete this frame.
* `bonus1` remains `incomplete`, and `bonus2` field becomes `open` (unused). The frame _may_ ultimately contain a
spare, in which case `bonus1` will need to get filled in. But we know for sure at this point that `bonus2` will be
unused.

```plantuml
@startuml

object FramePrior as "Frame[prior]" {
  throw1: incomplete
  throw2: incomplete
  bonus1: incomplete
  bonus2: incomplete
}

object FrameSubsequent as "Frame[subsequent]" {
  **throw1: pins 3**
  throw2: incomplete
  bonus1: incomplete
  **bonus2: open**
}

object Throws {
  throws: [\n\t(pins 3)\n]
}

FramePrior --> FrameSubsequent: apply (pins 3) throw

@enduml
```

##### An _open frame_ -- a second throw without a spare

The frame is initially in a state with `throw1` having a `(pins n)` value, `throw2` is `incomplete`, `bonus1` is `incomplete` and `bonus2` is `open` (unused). After a second throw _not_ knocking down the remaining pins, which is termed an "open" frame:
* `throw2` takes on a `(pins n)` value
* `bonus1` becomes `unused`

```plantuml
@startuml

object FramePrior as "Frame[prior]" {
  throw1: pins 3
  throw2: incomplete
  bonus1: incomplete
  bonus2: open
}

object FrameSubsequent as "Frame[subsequent]" {
  throw1: pins 3
  **throw2: pins 5**
  **bonus1: open**
  bonus2: open
}

object Throws {
  throws: [\n\t(pins 3),\n\t(pins 5)\n]
}

FramePrior --> FrameSubsequent: apply (pins 5) throw
@enduml
```

In the subsequent state the frame's score is 8.

```
(frame.score frame)

=> (sum
  (throw.score (pins 3))
  (throw.score (pins 5))
  (throw.score open)
  (throw.score open))

=> 3 + 5 + 0 + 0
=> 8
```

##### A second throw ending in a spare

Just as in previous case, the frame is initially in a state with `throw1` having a `(pins n)` value,
`throw2` incomplete, `bonus1` is `incomplete`, and `bonus2` is `open`. After a second throw the knocks down the
remaining pins, which is termed an "spare", the states of the frame prior and subsequent to the throw can be represented like this:

```plantuml
@startuml

object FramePrior as "Frame[prior]" {
  throw1: pins 3
  throw2: incomplete
  bonus1: incomplete
  bonus2: open
}

object FrameSubsequent as "Frame[subsequent]" {
  throw1: pins 3
  **throw2: pins 7**
  bonus1: incomplete
  bonus2: open
}

object Throws {
  throws: [\n\t(pins 3),\n\t(pins 7)\n]
}

FramePrior --> FrameSubsequent: apply (pins 7) throw
@enduml
```

The frame's score is still `incomplete` after the spare is thrown, because `bonus1` is incomplete. That is, we need to apply one more throw, the bonus throw awarded with a spare.

##### Completing a spare

Immediately after the second throw creates a spare the frame components include: `throw1` and `throw2` have values `(pin n)`, where the two throws add to 10. `bonus1` is `incomplete` and `bonus2` is `open` because we need to score a single bonus throw when a spare is completed.

A third throw is applied to the frame to complete `bonus1`.

```plantuml
@startuml

object FramePrior as "Frame[prior]" {
  throw1: pins 3
  throw2: pins 7
  bonus1: incomplete
  bonus2: open
}

object FrameSubsequent as "Frame[subsequent]" {
  throw1: pins 3
  throw2: pins 7
  **bonus1: pins 7**
  bonus2: open
}

object Throws {
  throws: [\n\t(pins 3),\n\t(pins 7),\n\t(pins 7)\n]
}

@enduml
```

The score for this frame is the sum of the throws and bonuses in the frame, 17:

```
(frame.score frame)

=> (sum
  (throw.score (pins 3))
  (throw.score (pins 7))
  (throw.score (pins 7))
  (throw.score open))

=> 3 + 7 + 7 + 0
=> 17
```

##### A strike and bonus throws completing a strike frame

The first throw in a strike frame is always `(pins 10)`. A new frame with `(pins 10)` applied yields a frame
where `throw2` si `open`m, because a second throw is not necessary wen all 10 pins are knocked down in the first
throw. A strike is awarded thw value of the next 2 balls throwsn, so after applying the throw `bonus1` and `bonus2`
are both `incomplete`.

```plantuml
@startuml

object FramePrior as "Frame[prior]" {
  throw1: incomplete
  throw2: incomplete
  bonus1: incomplete
  bonus2: incomplete
}

object FrameSubsequent as "Frame[subsequent]" {
  **throw1: pins 10**
  **throw2: open**
  bonus1: incomplete
  bonus2: incomplete
}

object Throws {
  throws: [\n\t(pins 10)\n]
}

FramePrior --> FrameSubsequent: apply (pins 10) throw
@enduml
```

Let's say the throw is a `foul`. This value will be stored in `bonus1`, the first `incomplete` throw position in the frame.

```plantuml
@startuml

object FramePrior as "Frame[prior]" {
  throw1: pins 10
  throw2: open
  bonus1: incomplete
  bonus2: incomplete
}

object FrameSubsequent as "Frame[subsequent]" {
  throw1: pins 10
  throw2: open
  **bonus1: foul**
  bonus2: incomplete
}

object Throws {
  throws: [\n\t(pins 10),\n\tfoul\n]
}

FramePrior --> FrameSubsequent: apply foul throw

@enduml
```

And let's further say in the second bonus throw the player knocks down 9 pins (`(pins 9)`). This is stored
in the `bonus2` field, the final remaining `incomplete` field. Now the frame is complete, and the score (19) can be
calculated.

```plantuml
@startuml

object FramePrior as "Frame[prior]" {
  throw1: pins 10
  throw2: open
  bonus1: foul
  bonus2: incomplete
}

object FrameSubsequent as "Frame[subsequent]" {
  throw1: pins 10
  throw2: open
  bonus1: foul
  **bonus2: pins 9**
}

object Throws {
  throws: [\n\t(pins 10),\n\tfoul,\n\t(pins 9)\n]
}

FramePrior --> FrameSubsequent: apply (pins 9) throw

@enduml
```

```
(frame.score frame)

=> (sum
  (throw.score (pins 10))
  (throw.score open)
  (throw.score foul)
  (throw.score (pins 9)))

=> 10 + 0 + 0 + 9
=> 19
```
#### Complete implementation of `frame.apply-throw`

The `frame.apply-throw` function implements the logic for all the cases described above. It takes 2 arguments: the
frame's initial state and a throw to apply to the frame. The function returns a copy of the input frame with the
input throw replacing one of the frame's `incomplete`-valued throw fields (`throw1`, `throw2`, `bonus1` or `bonus2`),
if there are any. The function also returns an indication of whether or not the throw was assigned to one of the
bonus throw fields. (The utility of this extra boolean return value will be made obvious below when we write a
recursive function to score an entire game.)

```smtlib2
(define-fun frame.apply-throw ((f frame) (t throw)) (Pair frame Bool)
  (
    (match f (

      ; We always apply the throw to the first throw in a new frame. The state of throw2 and bonus2
      ; are different if the first throw is a strike than they are in all other cases.

      ((frame incomplete i0 i1 i2)
        (let (
          (t2 (ite (= (pins t) 10) open incomplete))
          (b2 (ite (= (pins t) 10) incomplete open))
          (f_out (frame t t2 (bonus 1 f) b2)))

            (pair f3 false)) ; the applied throw is stored in throw1, not either of the bonus fields, so use false value

      ; If the second throw is incomplete, we will apply the incoming throw to throw2. The state of bonus1
      ; will be open unless this is a spare, in which case it will be incomplete. bonus2 will be open in all cases.

      ((frame i0 incomplete i1 i2)
        (let f1
          ((_update-field throw2) f t))
        (let b1 (ite (= (sum (throw.score (throw1 f1)) (throw.score (throw2 f1))) 10) incomplete open))
        (let f2
          ((_ update-field bonus1 f1 b1)))
        (let f3
          ((_ update-field bonus2 f2 open)))

        (pair f3 false) ; the applied throw is stored in throw1, not either of the bonus fields, so use false value

      ; throw1 and throw2 are complete, so apply the throw to bonus1 if it is incomplete

      ((frame i0 i1 incomplete i2)
        (pair ((_ update-field bonus1) f t) true)) ; the throw is stored in a bonus field so use true value

      ; throw1m throw2 and bonus1 are complete, so apply the throw to bonus2 if it is incomplete

      ((frame i0 i1 i2 incomplete)
        (pair ((_ update-field bonus2) f t) true)) ; the throw is stored in a bonus field so use true value
    ))
  )
)
```

##### Does the `frame.apply-throw` function actually work?

The smt2 test set included in `frame-function-tests.smt2` verifies example test cases of the following scenarios:
- A frame's score should be `incomplete` if it has a single throw, whether that throw is < 10 pins, a strike, or a foul
- A frame's score should be the sum of two throws if the frame is not a strike or a spare
- A frame's score should be `incomplete` if the first throw is a strike no matter what the second (bonus) throw is
- A frame's score should be a sum of 10 + both bonus throws if the frame is a strike and 2 bonus throws are applied
- A frame's score should be `incomplete` if the first two throws yield a spare
- A frame's score should be 10 + the bonus throw if the frame is a spare and a bonus throw is applied
- In all cases of a completed frame (an _open_ frame, a spare with a bonus throw, or a strike with 2 bonus throws), applying
  an additional throw does not yield an altered frame

### Representing a game and a game in progress

A game is just a list of frames. A valid game has exactly 10 frames. The constant `empty-game` is a game with exactly
10 `empty-frame`s.

```smtlib2
(declare-datatype Game (
  (game (frames (List Frame)))
))

(define-const empty-game Game
  (game
    (insert empty-frame
      (insert empty-frame
        (insert empty-frame
          (insert empty-frame
            (insert empty-frame
              (insert empty-frame
                (insert empty-frame
                  (insert empty-frame
                    (insert empty-frame
                      (insert empty-frame nil))))))))))))
```
#### Incrementally accululating throws in a game

##### Does the `game.apply-throws` function actually work? Unit testing using `game.score`


## Footnotes

[^1]: The standard uses the term _delivery_, and the Bobs' apparently replace this with the term _throw_. This
  article uses the Bobs' term _throw_ throughout, but the correct term from the standard is _delivery_.

[^2]: This is similar to unit testing or property testing the bowling definition functions. But rather that "executing" the functions
  and examining that the outputs match expectations in pecific cases, we define the properties we expect the function to have and ask a theorem
  prover to prove the property assertions are true. We don't care what techniques the prover employs, we just need to know the
  assertions are true.

