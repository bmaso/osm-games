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
;; - a player bar count, representing the number of checkers the current player has on the bar
;; - an opponent bar count, representing the number of checkers the current player has on the bar

(declare-datatype Board (
  (board
    (points (Array Int Point))
    (player_bar_count Int)
    (opponent_bar_count Int)
    (player Color))
))

;;;;
;; convenience function `new-game-points`: new game board points set up in the standard board initial state, with points
;; 1-6 as the nput player's inner table, 7-12 as the input player's outer table, 13-18 as the opponent player's
;; outer table, and 19-24 as the opponent play'ers inner table.
;;
;; - each player has 15 checkers, distributed the standard way (see https://en.wikipedia.org/wiki/Backgammon#Setup)
;; - target player's checkers travel from point 24 -> point 1
;; - opponent player's checkers travel from point 1 -> point 24

(define-fun new-game-points ((player Color)) (Array Int Point)
  (let (
    (opponent (color.opponent-of player))
    (base_array ((as const (Array Int Point)) empty-point)))

    (store
      (store
        (store
          (store
            (store
              (store
                (store
                  (store base_array 1  (point player 2))
                                    6  (point opponent 5))
                                    8  (point opponent 3))
                                    12 (point player 5))
                                    13 (point opponent 5))
                                    17 (point player 3))
                                    19 (point player 5))
                                    24 (point opponent 2)))
)

;;;;
;; conveneicen function `new-game-board`: generates a new game board with the given player having inner table in point range 1-6, and
;; opposing player having inner table in point range 19-24.
(define-fun new-empty-board ((player Color)) Board
  (board
    (new-game-points player)      ; board points
    0                             ; player bar count
    0                             ; opponent bar count
    player)                       ; player color
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
;; - total checkers of the target player is <= 15 and >= 0, counting across all points and the bar
;; - player is `Red` or `Black`
;;
;; I'm assuming that 2 boards are going to be entangled at a higher level, so it is unnecesary to guarantee that the
;; opposing player has 15 or fewer checkers, as that will be verified when validating the opposing player's board.

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

(declare-fun board.validation.0-15-total-checkers (Board) Bool)
(assert (! (forall ((b Board))
  (let (
    (total_count (+
        (ite (= (color (board.get-point b 1))  (player b)) (count (board.get-point b 1))  0)
        (ite (= (color (board.get-point b 2))  (player b)) (count (board.get-point b 2))  0)
        (ite (= (color (board.get-point b 3))  (player b)) (count (board.get-point b 3))  0)
        (ite (= (color (board.get-point b 4))  (player b)) (count (board.get-point b 4))  0)
        (ite (= (color (board.get-point b 5))  (player b)) (count (board.get-point b 5))  0)
        (ite (= (color (board.get-point b 6))  (player b)) (count (board.get-point b 6))  0)
        (ite (= (color (board.get-point b 7))  (player b)) (count (board.get-point b 7))  0)
        (ite (= (color (board.get-point b 8))  (player b)) (count (board.get-point b 8))  0)
        (ite (= (color (board.get-point b 9))  (player b)) (count (board.get-point b 9))  0)
        (ite (= (color (board.get-point b 10)) (player b)) (count (board.get-point b 10)) 0)
        (ite (= (color (board.get-point b 11)) (player b)) (count (board.get-point b 11)) 0)
        (ite (= (color (board.get-point b 12)) (player b)) (count (board.get-point b 12)) 0)
        (ite (= (color (board.get-point b 13)) (player b)) (count (board.get-point b 13)) 0)
        (ite (= (color (board.get-point b 14)) (player b)) (count (board.get-point b 14)) 0)
        (ite (= (color (board.get-point b 15)) (player b)) (count (board.get-point b 15)) 0)
        (ite (= (color (board.get-point b 16)) (player b)) (count (board.get-point b 16)) 0)
        (ite (= (color (board.get-point b 17)) (player b)) (count (board.get-point b 17)) 0)
        (ite (= (color (board.get-point b 18)) (player b)) (count (board.get-point b 18)) 0)
        (ite (= (color (board.get-point b 19)) (player b)) (count (board.get-point b 19)) 0)
        (ite (= (color (board.get-point b 20)) (player b)) (count (board.get-point b 20)) 0)
        (ite (= (color (board.get-point b 21)) (player b)) (count (board.get-point b 21)) 0)
        (ite (= (color (board.get-point b 22)) (player b)) (count (board.get-point b 22)) 0)
        (ite (= (color (board.get-point b 23)) (player b)) (count (board.get-point b 23)) 0)
        (ite (= (color (board.get-point b 24)) (player b)) (count (board.get-point b 24)) 0)
        (player_bar_count b))))
    (=
      (and
        (<= total_count 15)
        (>= total_count 0))
    (board.validation.0-15-total-checkers b)))
) :named board.validation.0-15-total-checkers ))

(declare-fun board.validation.player-is-red-or-black (Board) Bool)
(assert (! (forall ((b Board))
  (=
    (not (= Neutral (player b)))
    (board.validation.player-is-red-or-black b))
) :named board.validation.player-is-red-or-black ))

(define-fun board.validation ((b Board)) Bool
  (and
    (board.validation.members-valid b)
    (board.validation.0-15-total-checkers b)
    (board.validation.player-is-red-or-black b))
)

#endif

