#include "color.smt2"
#include "point.smt2"
#include "cube.smt2"

#ifndef BACKGAMMON_DOMAIN_BOARD
#define BACKGAMMON_DOMAIN_BOARD

;;;;;;;;;;
;; A `Board` value is 1 player's view of the game state of backgammon, so that a full `Game` is comprised of 2 entangled `Board` values
;; oriented in reverse direction from each other. A `Board` is comprised of
;; - 24 `Point` values; I opt to use an array to represent these values
;;   - the alternative to an array would be 24 separate `Point` instances, which I believe might be easier for the SMT solver to work with,
;;     but would be incredibly verbose in the validation rules -- there would need to be assertions for each (dice role, point)
;;     combination -- at least 18 * 24; this would obligate me to use macros to generate large numbers of assertions, and that just seems
;;     like the wrong way to go
;;   - there are _exactly_ 24 members of the array; all rules _only_ reference points within this range, so the SMT solver
;;     isn't lead to even explore point values for other board index values
;; - a `bar_count` integer value, representing the number of checkers the current player has on the bar
;; - a `Color` representing the `self` player, and another representing the `opponent`
;; - a `DoublingState` value, representing the doubling cube

(declare-datatype Board (
  (board
    (points (Array Int Point))
    (bar_count Int)
    (self Color))
))

;;;;
;; convenience function `new-game-points`: new game board points set up in the standard board initial state, with points
;; 1-6 as the nput player's inner table, 7-12 as the input player's outer table, 13-18 as the opponent player's
;; outer table, and 19-24 as the opponent play'ers inner table.
;;
;; - each player has 15 checkers, distributed the standard way (see https://en.wikipedia.org/wiki/Backgammon#Setup)
;; - target player's checkers travel from point 24 -> point 1
;; - opponent player's checkers travel from point 1 -> point 24

(define-fun new-game-points ((self Color)) (Array Int Point)
  (let (
    (opponent (color.opponent-of self))
    (base_array ((as const (Array Int Point)) empty-point)))

    (store
      (store
        (store
          (store
            (store
              (store
                (store
                  (store base_array 1  (point self 2))
                                    6  (point opponent 5))
                                    8  (point opponent 3))
                                    12 (point self 5))
                                    13 (point opponent 5))
                                    17 (point self 3))
                                    19 (point self 5))
                                    24 (point opponent 2)))
)

;;;;
;; conveneicen function `new-game-board`: generates a new game board with the given player having inner table in point range 1-6, and
;; opposing player having inner table in point range 19-24.
(define-fun new-empty-board ((self Color)) Board
  (board
    (new-game-points self)
    0
    self)
)

;;;;
;; Convenience accessor function to retrieve reference to the N-th point in a board. Points outside the range 1-24 are always
;; the empty point. Always use this function to access board points in validation rules.

(define-fun board.get-point ((b Board) (i Int)) Point
  (ite (or (>= i 1) (<= i 24))
    (select (points b) i)
    empty-point)
)

;;;;;;;;;;
;; A _valid_ board has these constraints:
;; - all points 1-24 are valid
;; - total checkers of the target player is <= 15, counting across all points and the bar
;; - self is `Red` or `Black`
;;
;; I'm assuming that 2 boards are going to be entangled at a higher level, so it is unnecesary to guarantee that the
;; opposing player has 15 or fewer checkers, as that will be verified when validating the opopsing player's board.

(declare-fun board.validation.members-valid (Board) Bool)
(assert (! (forall ((b Board))
  (=
    (and
      (point.validation (board.get-point b 1))
      (point.validation (board.get-point b 2))
      (point.validation (board.get-point b 3))
      (point.validation (board.get-point b 4))
      (point.validation (board.get-point b 5))
      (point.validation (board.get-point b 6))
      (point.validation (board.get-point b 7))
      (point.validation (board.get-point b 8))
      (point.validation (board.get-point b 9))
      (point.validation (board.get-point b 10))
      (point.validation (board.get-point b 11))
      (point.validation (board.get-point b 12))
      (point.validation (board.get-point b 13))
      (point.validation (board.get-point b 14))
      (point.validation (board.get-point b 15))
      (point.validation (board.get-point b 16))
      (point.validation (board.get-point b 17))
      (point.validation (board.get-point b 18))
      (point.validation (board.get-point b 19))
      (point.validation (board.get-point b 20))
      (point.validation (board.get-point b 21))
      (point.validation (board.get-point b 22))
      (point.validation (board.get-point b 23))
      (point.validation (board.get-point b 24)))
    (board.validation.members-valid b))
) :named board.validation.members-valid ))

(declare-fun board.validation.no-more-than-15-checkers (Board) Bool)
(assert (! (forall ((b Board))
  (=
    (<=
      (+
        (ite (= (color (board.get-point b 1))  (self b)) (count (board.get-point b 1))  0)
        (ite (= (color (board.get-point b 2))  (self b)) (count (board.get-point b 2))  0)
        (ite (= (color (board.get-point b 3))  (self b)) (count (board.get-point b 3))  0)
        (ite (= (color (board.get-point b 4))  (self b)) (count (board.get-point b 4))  0)
        (ite (= (color (board.get-point b 5))  (self b)) (count (board.get-point b 5))  0)
        (ite (= (color (board.get-point b 6))  (self b)) (count (board.get-point b 6))  0)
        (ite (= (color (board.get-point b 7))  (self b)) (count (board.get-point b 7))  0)
        (ite (= (color (board.get-point b 8))  (self b)) (count (board.get-point b 8))  0)
        (ite (= (color (board.get-point b 9))  (self b)) (count (board.get-point b 9))  0)
        (ite (= (color (board.get-point b 10)) (self b)) (count (board.get-point b 10)) 0)
        (ite (= (color (board.get-point b 11)) (self b)) (count (board.get-point b 11)) 0)
        (ite (= (color (board.get-point b 12)) (self b)) (count (board.get-point b 12)) 0)
        (ite (= (color (board.get-point b 13)) (self b)) (count (board.get-point b 13)) 0)
        (ite (= (color (board.get-point b 14)) (self b)) (count (board.get-point b 14)) 0)
        (ite (= (color (board.get-point b 15)) (self b)) (count (board.get-point b 15)) 0)
        (ite (= (color (board.get-point b 16)) (self b)) (count (board.get-point b 16)) 0)
        (ite (= (color (board.get-point b 17)) (self b)) (count (board.get-point b 17)) 0)
        (ite (= (color (board.get-point b 18)) (self b)) (count (board.get-point b 18)) 0)
        (ite (= (color (board.get-point b 19)) (self b)) (count (board.get-point b 19)) 0)
        (ite (= (color (board.get-point b 20)) (self b)) (count (board.get-point b 20)) 0)
        (ite (= (color (board.get-point b 21)) (self b)) (count (board.get-point b 21)) 0)
        (ite (= (color (board.get-point b 22)) (self b)) (count (board.get-point b 22)) 0)
        (ite (= (color (board.get-point b 23)) (self b)) (count (board.get-point b 23)) 0)
        (ite (= (color (board.get-point b 24)) (self b)) (count (board.get-point b 24)) 0)
        (bar_count b))
      15)
   (board.validation.no-more-than-15-checkers b))
) :named board.validation.no-more-than-15-checkers ))

(declare-fun board.validation.player-is-red-or-black (Board) Bool)
(assert (! (forall ((b Board))
  (=
    (or
      (= Red (self b))
      (= Black (self b)))
    (board.validation.player-is-red-or-black b))
) :named board.validation.player-is-red-or-black ))

(define-fun board.validation ((b Board)) Bool
  (and
    (board.validation.members-valid b)
    (board.validation.no-more-than-15-checkers b)
    (board.validation.player-is-red-or-black b))
)

#endif

