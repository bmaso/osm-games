#include "apply-roll-op.smt2"
#include "board.smt2"
#include "die-roll.smt2"
#include "point.smt2"
#include "color.smt2"

;; || __FILE__ || __LINE__ ||

;;;;
;; `re-enter` roll applications
;;
;; Prove that there are no valid `re-enter` roll applications where:
;; - the player bar is empty
;; - the target point in the opponent's inner table is controlled by the opponent

(assert (! (not (exists (
  (prior_board Board)
  (post_board Board)
  (roll DieRoll))

  (and
    (apply-roll-op.re-enter.validation prior_board post_board roll)

    (or
      (= 0 (player_bar_count prior_board))
      (not (point.can-target (board.get-point prior_board (value roll)) (player prior_board)))))

)) :named test-case.apply-roll-op.re-enter.meets-expectations ))