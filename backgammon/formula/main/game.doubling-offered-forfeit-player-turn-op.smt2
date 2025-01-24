#include "game.smt2"
#include "cube-op.smt2"
#include "cube.smt2"

;; || __FILE__ || __LINE__ ||

#ifndef BACKGAMMON_OPS_DOUBLINGOFFEREDFORFEIT
#define BACKGAMMON_OPS_DOUBLINGOFFEREDFORFEIT

;;;;;;;;;;
;; The `DoublingOfferedForfeitPlayerTurnOp` represents a very specific type of player turn, one in which there is _no dice roll_. This represents
;; player turns in which the current player offers to double the doubling cube, and the opponent forfeits in response. Absense of any dice roll
;; makes this turn fundamentally different in structure to two-roll player turns, so we define a different structure and set of validation rules
;; for it. The operation is comprised of:
;;
;; - prior and post `Game` values
;;
;; The alternative would be to define a "special" type of die roll value, one representing the _absence_ of a die roll. This option, which is
;; the logical equivalent of having a "nil" roll value or of a Haskell `Maybe X` value type, seems unnecessarily complex to me.

(declare-datatype DoublingOfferedForfeitPlayerTurnOp (
  (doubling-offered-forfeit-player-turn-op 
    (prior_game Game)
    (post_game Game))
))

;;;;
;; A _valid_ `DoublingOfferedForfeitPlayerTurnOp` instance has htese restrictions:
;; - the members are valid
;; - the `cube-op.validation` restrictions are satisfied when passing `double-offered-forfeit` as the cube operation param,
;;   the prior and post game cubes, and the prior game current player as the remaining params
;; - the post game state fields are equal to the prior state fields, with the exception on the `complete` flag. The `complete`
;;   flag is _true_ in the post game state

(declare-fun game.double-offered-forfeit-play-turn-op.validation (DoublingOfferedForfeitPlayerTurnOp) Bool)
(assert (! (forall ((op DoublingOfferedForfeitPlayerTurnOp))
  (=
    (and
      (game.validation (prior_game op))
      (game.validation (post_game op))
      (cube-op.validation double-offered-forfeit (cube (prior_game op)) (cube (post_game op)) (next_player (prior_game op)))
      (= (post_game op) ((_ update-field complete) (prior_game op) true)))
    (game.double-offered-forfeit-play-turn-op.validation op))
) :named game.double-offered-forfeit-play-turn-op.validation ))

#endif
