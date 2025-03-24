#include "game.doubling-offered-forfeit-player-turn-op.smt2"
#include "game.smt2"

;;;;;;;;;;
;; Prove that there are no valid applications of doubling-offered-player-turn-op where the following aren't true
;; - the prior cube is not owned by the prior state opponent
;; - the post game is equal to the prior game except for the complete flag (which is true)

(assert (! (not (exists ((op DoublingOfferedForfeitPlayerTurnOp))
  (and
    (game.double-offered-forfeit-play-turn-op.validation op)
    (or
      (= (color.opponent-of (next_player (prior_game op))) (owner (cube (prior_game op))))
      (not (= (post_game op) ((_ update-field complete) (prior_game op) true)))))
)) :named test-case.game.doubling-offered-forfeit-player-turn-op.all-expectations ))

(check-sat)
