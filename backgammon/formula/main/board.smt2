#include "color.smt2"
#include "point.smt2"
#include "bar.smt2"

#ifndef BACKGAMMON_DOMAIN_BOARD
#define BACKGAMMON_DOMAIN_BOARD

;;;;;;;;;;
;; A `Board` value is a static game state of backgammon. A `Board` is comprised of
;; - 24 `Point` values; I opt to use an array to represent these values
;;   - the alternative to an array would be 24 separate `Point` instances, which I believe might be easier for the SMT solver to work with,
;;     but would be incredibly verbose in the validation rules -- there would need to be assertions for each (dice role, point)
;;     combination -- at least 18 * 24; this would obligate me to use macros to generate large numbers of assertions, and that just seems
;;     like the wrong way to go
;;   - there are _exactly_ 24 members of the array; an assertion is declared on _all_ `Board` values ensuring there are no `Point`
;;     values associated with indexes outside the 1-24 range
;; - a `Bar` value
;; - a `Color` representing which player goes _next_
;; - a `doublingValue` integer value, representing the log base-2 value of the doubling cube

(declare-datatype Board (
  (board
    (points (Array Int Point))
    (bar Bar)
    (next_player Color)
    (doubling_value Int))
))

;;;;
;; The empty board state. This is the state _prior_ to game play, before the first player has been chosen. This is the _only_ valid
;; game state where the `next_player` is `Neutral`. A special operation to pick the first player is the only valid operation that can
;; be applied to this game state.

(declare-const new-board-empty-points (Array Int Point))
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

(define-const new-empty-board (Board)
  (board
    new-board-empty-points
    empty-bar
    Neutral
    0)
)

;;;;
;; A new game board points.
;; - each player has 15 checkers, distributed the standard way (see https://en.wikipedia.org/wiki/Backgammon#Setup)
;; - red checkers are oriented and travel from point 1 -> point 24
;; - black checkers are oriented and travel from point 24 -> point 1

(declare-const new-game-points (Array Int Point))
(assert
  (and
    (= (select new-board-empty-points 1) (point Red 2))
    (= (select new-board-empty-points 2) empty-point)
    (= (select new-board-empty-points 3) empty-point)
    (= (select new-board-empty-points 4) empty-point)
    (= (select new-board-empty-points 5) empty-point)
    (= (select new-board-empty-points 6) (point Black 5))
    (= (select new-board-empty-points 7) empty-point)
    (= (select new-board-empty-points 8) (point Black 3))
    (= (select new-board-empty-points 9) empty-point)
    (= (select new-board-empty-points 10) empty-point)
    (= (select new-board-empty-points 11) empty-point)
    (= (select new-board-empty-points 12) (point Red 5))
    (= (select new-board-empty-points 13) (point Black 5))
    (= (select new-board-empty-points 14) empty-point)
    (= (select new-board-empty-points 15) empty-point)
    (= (select new-board-empty-points 16) empty-point)
    (= (select new-board-empty-points 17) (point Red 3))
    (= (select new-board-empty-points 18) empty-point)
    (= (select new-board-empty-points 19) (point Red 5))
    (= (select new-board-empty-points 20) empty-point)
    (= (select new-board-empty-points 21) empty-point)
    (= (select new-board-empty-points 22) empty-point)
    (= (select new-board-empty-points 23) empty-point)
    (= (select new-board-empty-points 24) (point Black 2))
  )
)

;;;;
;; Convenience function to generate a new game with `first_player` color going first. This is always the first state to which player
;; turn operations can be applied (dice roll and doubling) in a valid game process.

(define-fun new-game ((first_player Color)) Board
  (board
    new-game-points
    empty-bar
    first_player
    0)
)

;;;;
;; Convenience accessor function to retrieve reference to the N-th point in a board

(define-fun board-point ((b Board) (n Int)) Point
  (select (points b) n)
)

;;;;
;; Assertion that a board's points array only has 24 indexed values. Note that the `forall` test's unbound variables match the
;; parameters of the `board-point` accessor function above, which I suspect will make it easier for an SMT solver to instantiate this
;; quantifier where it is going to be applied most often.

(assert (! (forall ((b Board) (n Int))
  (=>
    (or
      (< n 1)
      (> n 24))
    (not (exists ((p Point)) (= p (board-point b n)))))
) :named board.invariate.there-are-only-24-board-points))

;;;;;;;;;;
;; A _valid_ board has these constraints:
;; - all points 1-24 are valid
;; - the bar field is valid
;; - it must be _somebody's_ turn once play gets under way
;;   - that is: the `next_player` field is `Neutral` IFF there are no checkers on any point nor on the bar
;; - the doubling value is not negative
;; - the double value must be 0 at the beginning of the game
;;   - that is: IF the `next_player` field is `Neutral`, THEN the doubling value is 0
;; - there are no more than 15 red checkers and there are no more than 15 black checkers on the board (ie, summed across all
;;   points and the bar)
;; - there must be at least 1 checker on the board blonging to the player whose turn it is
;;   - even at the end of the game, when it is technically the loser's turn, this is true -- the loser has at least one
;;     checker on the board


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

(declare-fun board.validation.red-or-black-turn-consistent-with-game-commencement (Board) Bool)
(assert (! (forall ((b Board))
  (=
    (= 
      (and
        (= (count (board-point b 1)) 0)
        (= (count (board-point b 2)) 0)
        (= (count (board-point b 3)) 0)
        (= (count (board-point b 4)) 0)
        (= (count (board-point b 5)) 0)
        (= (count (board-point b 6)) 0)
        (= (count (board-point b 7)) 0)
        (= (count (board-point b 8)) 0)
        (= (count (board-point b 9)) 0)
        (= (count (board-point b 10)) 0)
        (= (count (board-point b 11)) 0)
        (= (count (board-point b 12)) 0)
        (= (count (board-point b 13)) 0)
        (= (count (board-point b 14)) 0)
        (= (count (board-point b 15)) 0)
        (= (count (board-point b 16)) 0)
        (= (count (board-point b 17)) 0)
        (= (count (board-point b 18)) 0)
        (= (count (board-point b 19)) 0)
        (= (count (board-point b 20)) 0)
        (= (count (board-point b 21)) 0)
        (= (count (board-point b 22)) 0)
        (= (count (board-point b 23)) 0)
        (= (count (board-point b 24)) 0)
        (= (red-count (bar b)) 0)
        (= (black-count (bar b)) 0))
      (= (next_player b) Neutral))
  (board.validation.red-or-black-turn-consistent-with-game-commencement b))
) :named board.validation.red-or-black-turn-consistent-with-game-commencement))

(declare-fun board.validation.doubling-value-consistent-with-game-commencement (Board) Bool)
(assert (! (forall ((b Board))
  (=
    (=>
      (= (next_player b) Neutral)
      (= (doubling_value b) 0))
    (board.validation.doubling-value-consistent-with-game-commencement b))
) :named board.validation.doubling-value-consistent-with-game-commencement ))

(declare-fun board.validation.no-more-than-15-checkers-per-player (Board) Bool)
(assert (! (forall ((b Board))
 (=
   (and
     (<=
       (+
         (ite (= (color (board-point b 1)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 2)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 3)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 4)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 5)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 6)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 7)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 8)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 9)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 10)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 11)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 12)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 13)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 14)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 15)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 16)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 17)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 18)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 19)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 20)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 21)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 22)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 23)) Red) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 24)) Red) (count (board-point b 1)) 0)
         (red-count (bar b)))
       15)
     (<=
       (+
         (ite (= (color (board-point b 1)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 2)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 3)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 4)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 5)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 6)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 7)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 8)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 9)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 10)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 11)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 12)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 13)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 14)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 15)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 16)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 17)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 18)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 19)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 20)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 21)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 22)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 23)) Black) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 24)) Black) (count (board-point b 1)) 0)
         (black-count (bar b)))
       15))
   (board.validation.no-more-than-15-checkers-per-player b))
) :named board.validation.no-more-than-15-checkers-per-player ))

(declare-fun board.validation.current-player-has-at-least-one-checker (Board) Bool)
(assert (! (forall ((b Board))
  (=
    (=>
      (not (= Neutral (next_player b)))
      (>
        (+
         (ite (= (color (board-point b 1)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 2)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 3)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 4)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 5)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 6)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 7)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 8)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 9)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 10)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 11)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 12)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 13)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 14)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 15)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 16)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 17)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 18)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 19)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 20)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 21)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 22)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 23)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (color (board-point b 24)) (next_player b)) (count (board-point b 1)) 0)
         (ite (= (next_player b) Red) (red-count (bar b)) (black-count (bar b))))
        0))
    (board.validation.current-player-has-at-least-one-checker b))
) :named board.validation.current-player-has-at-least-one-checker ))

(define-fun board.validation ((b Board)) Bool
  (and
    (board.validation.members-valid b)
    (board.validation.red-or-black-turn-consistent-with-game-commencement b)
    (board.validation.doubling-value-consistent-with-game-commencement b)
    (board.validation.no-more-than-15-checkers-per-player b)
    (board.validation.current-player-has-at-least-one-checker b))
)

#endif

