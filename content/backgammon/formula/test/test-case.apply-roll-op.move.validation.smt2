#include "apply-roll-op.smt2"
#include "board.smt2"
#include "die-roll.smt2"
#include "point.smt2"

;;;;;;;;;;
;; Test cases proving expectations about valid `move` roll applications.

;;;;
;; Proves that the player bar must be empty for a `move` roll application to be valid

(assert (! (not (exists (
  (prior_board Board)
  (post_board Board)
  (from_index Int)
  (roll DieRoll))

  (and
    (apply-roll-op.move.validation prior_board post_board from_index roll)
    (> (player_bar_count prior_board) 0))
)) :named test-case.apply-roll-op.move.validation.bar-must-be-empty ))

(check-sat)

;;;;
;; Proves that there are no valid `move` roll applications where the target point is controlled by the opponent

(assert (! (not (exists (
  (prior_board Board)
  (post_board Board)
  (from_index Int)
  (roll DieRoll))

  (and
    (apply-roll-op.move.validation prior_board post_board from_index roll)

    (let (
      (prior_target_point (select (points prior_board) (- 25 (value roll))))
      (opponent (ite (= Red (player prior_board)) Black Red)))

      (and
        (= opponent (color prior_target_point))
        (> (count prior_target_point) 1))))
)) :named test-case.apply-roll-op.move.validation.target-point-not-controlled-by-opponent ))

(check-sat)
