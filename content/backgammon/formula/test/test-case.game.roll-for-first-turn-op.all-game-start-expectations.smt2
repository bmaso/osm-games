#include "game.roll-for-first-turn-op.smt2"
#include "game.smt2"

;;;;;;;;;;
;; Prove that: there is no valid roll for first turn where the following aren't true:
;; - the next player is the player with the higher roll
;; - both player's boards are in the "new game" state
;; - the cube is in the "new game" state

(declare-const op RollForFirstTurnOp)
(assert (! (not (exists ((op RollForFirstTurnOp))
  (let (
    (winning_player (ite (> (value (red_roll op)) (value (black_roll op))) Red Black)))

    (and
      (game.roll-for-first-turn-op.validation op)
      (or
        (not (= (next_player (post_game op)) winning_player))
        (not (= (new-game-board Red) (red_board (post_game op))))
        (not (= (new-game-board Black) (black_board (post_game op))))
        (not (= new-game-cube (cube (post_game op)))))))
)) :named test-case.game.roll-for-first-turn-op.all-game-start-expectations ))

(check-sat)
