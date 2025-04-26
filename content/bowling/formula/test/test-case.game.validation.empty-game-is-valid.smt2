#include "game.smt2"
;; || __FILE__ || __LINE__ ||

;;;;
;; Prove that the empty game is valid
;;;;

(assert (! (game.valid empty-game)
:named test-case.game.validation.empty-game-is-valid))

(check-sat)
