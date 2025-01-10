#include "color.smt2"
#include "point.smt2"
#include "bar.smt2"

;;;;;;;;;;
;; A `Board` value is a static game state of backgammon. A `Board` is comprised of
;; - 24 `Point` values; I opt to use an array to represent these values. The alternative would be 24 separate `Point` instances,
;;   which I believe might be easier for the SMT solver to work with, but would be incredibly verbose in the validation rules -- there
;;   would need to be assertions for each (dice role, point) combination -- at least 18 * 24. This would obligate me to use
;;   macros to generate the assertions, and that just seems like the wrong way to go.
;; - a `Bar` value
;; - a `Color` representing which player goes _next_
;; - a `doublingValue` integer value, representing the log base-2 value of the doubling cube

(declare-datatype Board (
  (board
    (points (Array Int Point))
    (bar Bar)
    (next_player Color)
    (doublingValue Int)
))

;;;;
;; The standard, initial game state. Note this is the _only_ valid game state where the `next_player` is `Neutral`. A special
;; operation to pick the first player is the only valid operation that can be applied to this game state.

(define-const new-board-empty-points (Array Int Point))
(assert
  (and
    (= (select new-board-empty-points 1) empty-point)
    (= (select new-board-empty-points 2) empty-point)
    (= (select new-board-empty-points 3) empty-point)
    (= (select new-board-empty-points 4) empty-point)
    (= (select new-board-empty-points 5) empty-point)
    (= (select new-board-empty-points 6) empty-point)
    (= (select new-board-empty-points 7) empty-point)
    (= (select new-board-empty-points 8) empty-point)
    (= (select new-board-empty-points 9) empty-point)
    (= (select new-board-empty-points 10) empty-point)
    (= (select new-board-empty-points 11) empty-point)
    (= (select new-board-empty-points 12) empty-point)
    (= (select new-board-empty-points 13) empty-point)
    (= (select new-board-empty-points 14) empty-point)
    (= (select new-board-empty-points 15) empty-point)
    (= (select new-board-empty-points 16) empty-point)
    (= (select new-board-empty-points 17) empty-point)
    (= (select new-board-empty-points 18) empty-point)
    (= (select new-board-empty-points 19) empty-point)
    (= (select new-board-empty-points 20) empty-point)
    (= (select new-board-empty-points 21) empty-point)
    (= (select new-board-empty-points 22) empty-point)
    (= (select new-board-empty-points 23) empty-point)
    (= (select new-board-empty-points 24) empty-point)
  )
)

(define-const new-board Board)
  (board
    new-board-empty-points
    empty-bar
    Neutral
    0)
)

;;;;
;; Convenience accessor function to retrieve reference to the N-th point in a board

(define-fun board-point ((b Board) (n Int)) Point
  (select (points b) n)
)

;;;;;;;;;;
;; A _valid_ board has these constraints:
;; - all points 1-24 are valid
;; - the points array outside the range 0 < i < 25 does not exist
;;   - expressed with existential quantifier: there do not exist _any_ point values equal to the point value at array index i < 1 or i > 24
;;   - quantifer's unbound variables match the variables to the `board-point` function, which (hopefully) means it
;;     will be applied efficiently where the function is referenced
;; - the bar field is valid
;; - it must be _somebody's_ turn once play gets under way
;;   - that is: the `next_player` field is `Neutral` IFF there can be no checkers on any point
;; - the doubling value is not negative
;; - the double value must be 0 at the beginning of the game
;;   - that is: IF the `next_player` field is `Neutral`, THEN the doubling value is 0

(declare-fun board.validation.members-valid (Board) Bool)
(assert (! (forall ((b Board))
  (=
    (and
      (point.validation (board-point b 1))
      (point.validation (board-point b 2))
      (point.validation (board-point b 3))
      (point.validation (board-point b 4))
      (point.validation (board-point b 5))
      (point.validation (board-point b 6))
      (point.validation (board-point b 7))
      (point.validation (board-point b 8))
      (point.validation (board-point b 9))
      (point.validation (board-point b 10))
      (point.validation (board-point b 11))
      (point.validation (board-point b 12))
      (point.validation (board-point b 13))
      (point.validation (board-point b 14))
      (point.validation (board-point b 15))
      (point.validation (board-point b 16))
      (point.validation (board-point b 17))
      (point.validation (board-point b 18))
      (point.validation (board-point b 19))
      (point.validation (board-point b 20))
      (point.validation (board-point b 21))
      (point.validation (board-point b 22))
      (point.validation (board-point b 23))
      (point.validation (board-point b 24))
      (bar.validation (bar b)))
    (board.validation.members-valid b))
) :named boad.validation.members-valid ))

(define-fun board.validation.red-or-black-turn-consistent-with-game-commencement (Board) Bool)
(assert (! (forall ((b Board))
  (=
    (= 
      (= 
        (+
          (count (board-point b 1))
          (count (board-point b 2))
          (count (board-point b 3))
          (count (board-point b 4))
          (count (board-point b 5))
          (count (board-point b 6))
          (count (board-point b 7))
          (count (board-point b 8))
          (count (board-point b 9))
          (count (board-point b 10))
          (count (board-point b 11))
          (count (board-point b 12))
          (count (board-point b 13))
          (count (board-point b 14))
          (count (board-point b 15))
          (count (board-point b 16))
          (count (board-point b 17))
          (count (board-point b 18))
          (count (board-point b 19))
          (count (board-point b 20))
          (count (board-point b 21))
          (count (board-point b 22))
          (count (board-point b 23))
          (count (board-point b 24)))
        0)
      (= (next_player b) Neutral))
    (board.validation.red-or-black-turn-consistent-with-game-commencement b))
) :named board.validation.red-or-black-turn-consistent-with-game-commencement))

(define-fun board.validation.doubling-value-consistent-with-game-initialization (Board) Bool)
(assert (! (forall ((b Board))
  (=
    (=>
      (= (next_player) Neutral)
      (= (doubling-value b) 0))
    (board.validation.doubling-value-consistent-with-game-initialization b))
) :named board.validation.doubling-value-consistent-with-game-initialization ))

(define-fun board.validation (Board) Bool)
(assert (forall ((Board b))
  (=>
    (not (or
      (board.validation.members-valid b)
      (board.validation.red-or-black-turn-consistent-with-game-commencement)
      (board.validation.doubling-value-consistent-with-game-initialization)))
    (not (board.validation b)))
))

(assert (! (forall ((b Board) (n Int))
  (and
    (=>
      (or
        (< n 1)
        (> n 24)
      (not (exists ((p Point)) (= p (board-point b n)))))
    (board.validation b)))
) :named board.validation.there-are-no-board-points-except-the-24))
