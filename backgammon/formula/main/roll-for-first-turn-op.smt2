#include "board.smt2"
#include "cube.smt2"
#include "color.smt2"
#include "die-roll.smt2"

;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; Operation representing the initial roll to choose the player who gets the first turn in backgammon. The
;; operation's input is two single-die rolls, one called `red-roll` and one classed `black-roll`.

(declare-datatype RollForFirstTurnOp (
  (roll-for-first-turn-op
    (prior_board Board)
    (post_board Board)
    (red_roll DieRoll)
    (black_roll DieRoll))
))

;;;;
;; A _valid_ roll for first turn operation has these restrictions:
;; - all members must be valid
;; - the prior board's points must all be in the "empty" state (Neutral and with no checkers), empty bar, and
;;   standard initial state of the doubling cube (no owner, value is 0)
;; - in all cases, the post board has these invariant restrictions:
;;   - the post board points are the standard start points
;;   - the post board bar is empty
;;   - the post board cube state is in standard initial state (no owner, value is 0)
;; - in all cases, the red and black rolls have these restrictions:
;;   - the red die roll must be made by the `Red` player and the black die roll must be made by the `Black` player
;;   - IF the red roll is higher than the back roll, THEN the post board next player is `Red`
;;   - IF the black roll is higher than the red roll, THEN the post board is next plyer is `Black`
;;   - the red and black rolls cannot be equal
;;
;;   WBGF rules state that if the initial rolls are equal then the roll to decide the first player must be repeated.
;;   I interpret this to mean a roll to decide the first player is invalid unless the two values are unequal.
;;   This interpretation avoids the SMT solver having the option of instantiating a (potentially infinite) sequence
;;   of equal equal when deducing the initial operation sequence of a valid backgammon game process.

(declare-fun roll-for-first-turn-op.validation.members-valid (RollForFirstTurnOp) Bool)
(assert (! (forall ((op RollForFirstTurnOp))
  (=
    (and
      (board.validation (prior_board op))
      (board.validation (post_board op))
      (die-roll.validation (red_roll op))
      (die-roll.validation (black_roll op)))
    (roll-for-first-turn-op.validation.members-valid op))
) :named roll-for-first-turn-op.validation.members-valid ))

(declare-fun roll-for-first-turn-op.validation.empty-prior-board (RollForFirstTurnOp) Bool)
(assert (! (forall ((op RollForFirstTurnOp))
  (=
    (and
      (= new-board-empty-points (points (prior_board op)))
      (= empty-bar (bar (prior_board op)))
      (= new-game-cube (cube (prior_board op))))
    (roll-for-first-turn-op.validation.empty-prior-board op))
) :named roll-for-first-turn-op.validation.empty-prior-board ))

(declare-fun roll-for-first-turn-op.validation.standard-post-board (RollForFirstTurnOp) Bool)
(assert (! (forall ((op RollForFirstTurnOp))
  (=
    (and
      (= new-game-points (points (post_board op)))
      (= empty-bar (bar (post_board op)))
      (= new-game-cube (cube (post_board op))))
    (roll-for-first-turn-op.validation.standard-post-board op))
) :named roll-for-first-turn-op.validation.standard-post-board ))


(declare-fun roll-for-first-turn-op.validation.red-and-black-rolls-by-each-player-and-unequal (RollForFirstTurnOp) Bool)
(assert (! (forall ((op RollForFirstTurnOp))
  (=
    (and
      (= Red (player (red_roll op)))
      (= Black (player (black_roll op)))
      (not (= (value (red_roll op)) (value (black_roll op))))
      (= (next_player (post_board op))
        (ite (> (value (red_roll op)) (value (black_roll op))) Red Black)))
    (roll-for-first-turn-op.validation.red-and-black-rolls-by-each-player-and-unequal op))
) :named roll-for-first-turn-op.validation.red-and-black-rolls-by-each-player-and-unequal ))

(define-fun roll-for-first-turn-op.validation ((op RollForFirstTurnOp)) Bool
  (and
    (roll-for-first-turn-op.validation.members-valid op)
    (roll-for-first-turn-op.validation.empty-prior-board op)
    (roll-for-first-turn-op.validation.standard-post-board op)
    (roll-for-first-turn-op.validation.red-and-black-rolls-by-each-player-and-unequal op))
)

