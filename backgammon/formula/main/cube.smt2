#include "color.smt2"

;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; The state of the doubling cube is perhaps the most persnickety part of backgammon state management.
;; See [Wikipedia's description](https://en.wikipedia.org/wiki/Backgammon#Doubling_cube) of the backgammon doubling cube.
;;
;; Summary:
;; - in this module the cube's current value is represented by a log-2 value called doubling value
;;   - initial value is 0
;;   - when "doubled", 1 is added to the value
;;   - the game cube value value should be interpreted as a power of 2, so the value 0 --> 1, 1 --> 2, 2 --> 4, etc.
;; - the initial state of the doubling cube is called "active"
;; - the cube is initially unowned, which this module represents using the `Color` value `Neutral`; once the cube
;;   is doubled by one player or the other, ownership of the cube passes back-and-forth during game play as a consequence
;;   of further doubling
;; - at the beginning of either player's turn and when the cube is in "active" state and if the player owns the cube or if the
;;   cube is unowned, the player may double the value of the doubling cube; at this point the cube's state is "doubling-offered"
;; - when in this state the opposing player must either _accept_ the doubling, _forfeit_, or _beaver_
;;   - if the opposing player _accepts_ the doubling, the opposing player gains cube ownership and the cube state is updated
;;     to "static" -- meaning it cannot be doubled or changed until at least one player turn has passed
;;   - if the opposing player _foreits_ the doubling, the cube ownership passes to the opposing player and the cube state is
;;     updated to "foreit"
;;   - if the opposing player _beavers_ (ie, redoubles), the cube vaue is doubled, cube ownership passes to the opposing player,
;;     and the cube state is updated to "beaver"
;; - when the cube state is "beaver", the original doubling player must either _proceeed_ or _racoon_
;;   - if the player chooses to _proceed_, the cube state changes to "static" -- meaning it cannot be changed until at least one
;;     player turn has passed
;;   - if the player chooses to _raccoon_, the cube value is doubled and the cube state changes to "static" -- meaning it cannot
;;     be changed until at least one player's turn has passed
;; - at the end of a turn, (ie, dice roll and checker move) the cube state always changesback to "active"
;;
;; The cube state is comprised of the following values:
;; - A doubling_value integer, interpreted as a value of 2
;; - an owner `Color`, which is initially `Neutral` and may proceed to be either `Red` or `Black`
;; - a state `CubeState` value, which is one of `Active`, `Static`, `DoubleOffered`, `Forfeit`, or `Beaver`

(declare-datatype CubeState (
  Active
  Static
  DoubleOffered
  Forfeit
  Beaver
))

(declare-datatype Cube (
  (cube
    (doubling_value Int)
    (owner Color)
    (state CubeState))
))

;;;;
;; The initial cube state at the beginning of the game process

(define-const new-game-cube Cube
  (cube
    0         ; doubling_value
    Neutral   ; owner
    Active)   ; cube state
)

;;;;
;; A _valid_ cube has these invariant restrictions:
;; - the doubling value is >= 0
;; - IF the cube is unowned, the cube state must be `Active`

(declare-fun cube.validation.doubling-value-nonnegative (Cube) Bool)
(assert (! (forall ((c Cube))
  (=
    (>= (doubling_value c) 0)
    (cube.validation.doubling-value-nonnegative c))
) :named cube.validation.doubling-value-nonnegative ))

(declare-fun cube.validation.unowned-cube-is-active (Cube) Bool)
(assert (! (forall ((c Cube))
  (=
    (=>
      (= Neutral (owner c))
      (= Active (state c)))
    (cube.validation.unowned-cube-is-active c))
) :named cube.validation.unowned-cube-is-active ))

(define-fun cube.validation ((c Cube)) Bool
  (and
    (cube.validation.doubling-value-nonnegative c)
    (cube.validation.unowned-cube-is-active c))
)
