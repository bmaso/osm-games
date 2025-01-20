#include "game.smt2"
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
    (prior_game Game)
    (post_game Game)
    (red_roll DieRoll)
    (black_roll DieRoll))
))

;;;;
;; A _valid_ roll for first turn operation has these restrictions:
;; - all members must be valid
;; - the prior board's `next_player` must be `Neutral`
;; - the `red_roll` player must be `Red`, and the `black_roll` player must be `Black`
;; - the values of `red_roll` and `black_roll` must not be equal
;; - the post game state is identical to the prior game state in all aspects _except_ the `next_player` must
;;   be equal to the player of the higher of the values of `red_roll` and `black_roll`
;;
;;   WBGF rules state that if the initial rolls are equal then the roll to decide the first player must be repeated.
;;   I interpret this to mean a roll to decide the first player is invalid unless the two values are unequal.
;;   This interpretation avoids the SMT solver having the option of instantiating a (potentially infinite) sequence
;;   of valid `RollForFirstTurnOp` instances as the initial portion of a valid game process graph.

(declare-fun game.roll-for-first-turn-op.validation.members-valid (RollForFirstTurnOp) Bool)
(assert (! (forall ((op RollForFirstTurnOp))
  (=
    (and
      (game.validation (prior_game op))
      (game.validation (post_game op))
      (die-roll.validation (red_roll op))
      (die-roll.validation (black_roll op)))
    (game.roll-for-first-turn-op.validation.members-valid op))
) :named game.roll-for-first-turn-op.validation.members-valid ))

(declare-fun game.roll-for-first-turn-op.validation.prior-next-player-not-choosen (RollForFirstTurnOp) Bool)
(assert (! (forall ((op RollForFirstTurnOp))
  (=
    (= Neutral (next_player (prior_game op)))
    (game.roll-for-first-turn-op.validation.prior-next-player-not-choosen op))
) :named game.roll-for-first-turn-op.validation.prior-next-player-not-choosen ))

(declare-fun game.roll-for-first-turn-op.validation.red-and-black-rolls-by-each-player-and-unequal (RollForFirstTurnOp) Bool)
(assert (! (forall ((op RollForFirstTurnOp))
  (=
    (and
      (= Red (player (red_roll op)))
      (= Black (player (black_roll op)))
      (not (= (value (red_roll op)) (value (black_roll op)))))
    (game.roll-for-first-turn-op.validation.red-and-black-rolls-by-each-player-and-unequal op))
) :named game.roll-for-first-turn-op.validation.red-and-black-rolls-by-each-player-and-unequal ))

(declare-fun game.roll-for-first-turn-op.validation.post-game-is-updated-prior-game (RollForFirstTurnOp) Bool)
(assert (! (forall ((op RollForFirstTurnOp))
  (=
    (= (post_game op) ((_ update-field next_player) (prior_game op) (ite (> (value (red_roll op)) (value (black_roll op))) Red Black)))
    (game.roll-for-first-turn-op.validation.post-game-is-updated-prior-game op))
) :named game.roll-for-first-turn-op.validation.post-game-is-updated-prior-game ))

(define-fun game.roll-for-first-turn-op.validation ((op RollForFirstTurnOp)) Bool
  (and
    (game.roll-for-first-turn-op.validation.members-valid op)
    (game.roll-for-first-turn-op.validation.prior-next-player-not-choosen op)
    (game.roll-for-first-turn-op.validation.red-and-black-rolls-by-each-player-and-unequal op)
    (game.roll-for-first-turn-op.validation.post-game-is-updated-prior-game op))
)

