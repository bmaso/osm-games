#include "game.smt2"
#include "cube-op.smt2"
#include "apply-roll-op.smt2"

;;;;;;;;;;
;; A `TwoRollPlayerTurnOp` represents a single player's turn in a game of backgammon that involves 2 die roll applications,
;; which covers turns where doubles are not rolled. There are different operations when doubles are rolled, as they apply
;; 4 die rolls applications. A two roll player turn is composed of:
;; - a prior and a post game
;; - a `DoublingOp` field, which describes any interactions with the doubling cube that occur at the beginning of the turn
;; - two `DieRoll` values `roll_1` and `roll_2`, which are the user's die rolls
;;
;;   > There are some backgammon game states where a roll is really unnecessary; specifically, when a user has one or
;;   > more checkers on the bar, but the opponent's inner table is completely blocked. WBGF rules state that in such
;;   > cases the user is still obliged to roll both dice.
;;
;; - two `ApplyRollOp` values, applying `roll_1` and `roll_2` to the game, respectively
;; - the `post_game` state is the result of applying `doubling_op`, `apply_roll_1_op` and `apply_roll_2_op` to the
;;   prior game

(declare-datatype TwoRollPlayerTurnOp (
  (prior_game Game)
  (post_game Game)
  (doubling_op DoublingOp)
  (roll_1 DieRoll)
  (apply_roll_1_op ApplyRollOp)
  (roll_2 DieRoll)
  (apply_roll_2_op ApplyRollOp)
))

;;;;;;;;
;; All _valid_ two roll player turn have these requirements:
;; - the current player is either `Red` or `Black`
;;   - ie, not Neutral, which would indicate the initial roll for first turn operation
;;     has not been applied
;; - all members must be valid
;; - the prior game is not in a terminal state (the `complete` flag must be false)
;; - `cube-op.validation` entangles the state of the `doubling_op`, the `prior_game`'s cube, and the `post_game`'s cube.
;;   - The `doubling_op` value cannot be `double-offered-forfeit`; the `DoublingOfferedForfeitPlayerTurnOp`
;;     datatype specifically is used to represent this operation, as this type of turn does _not_ involve any die rolls
;; - The two die roll values must be different
;;   - there's a who separate set of parallel validation rules to apply for double, which involve 4 apply roll operations

;;;;
;; Validation function `game.two-roll-player-turn-op.validation.invariant-expectations` proves that:
;; - the current player is either `Red` or `Black`
;;   - ie, not Neutral, which would indicate the initial roll for first turn operation
;;     has not been applied
;; - the prior game is not in a terminal state (the `complete` flag must be false)
;; - The two die roll values must be different
;;   - there's a who separate set of parallel validation rules to apply for double, which involve 4 apply roll operations

(declare-fun game.two-roll-player-turn-op.validation.invariant-expectations (TwoRollPlayerTurnOp) Bool)
(assert (! (forall ((op TwoRollPlayerTurnOp))
  (=
    (and
      (not (= Neutral (next_player (prior_game op))))
      (not (complete (prior_game op)))
      (not (= (value (roll_1 op)) (value (roll_2 op)))))
    (game.two-roll-player-turn-op.validation.game-initiated op))
)) :named game.two-roll-player-turn-op.validation.game-initiated )

;;;;
;; Validation function `game.two-roll-player-turn-op.validation.members-valid` proves that:
;; - all members must be valid

(declare-fun game.two-roll-player-turn-op.validation.members-valid (TwoRollPlayerTurnOp) Bool)
(assert (! (forall ((op PlayerTurnOp))
  (=
    (and
      (game.validation (prior_game op))
      (game.validation (post_game op))
      (cube-op.validation (doubling_op op))
      (die-roll.validation (roll_1 op))
      (game.apply-roll-op.validation (apply_roll_1 op))
      (die-roll.validation (roll_2 op))
      (game.apply-roll-op.validation (apply_roll_2 op)))
    (game.two-roll-player-turn-op.validation.members-valid op))
) :named game.two-roll-player-turn-op.validation.members-valid ))

;;;;
;; Validation function `game.two-roll-player-turn-op.validation.cube-entanglement` proves that:
;; - `cube-op.validation` entangles the state of the `doubling_op`, the `prior_game`'s cube, and the `post_game`'s cube.
;;   - The `doubling_op` value cannot be `double-offered-forfeit`; the `DoublingOfferedForfeitPlayerTurnOp`
;;     datatype specifically is used to represent this operation, as this type of turn does _not_ involve any die rolls

(declare-fun game.two-roll-player-turn-op.validation.cube-entanglement (TwoRollPlayerTurnOp) Bool)
(assert (! (forall ((op TwoRollPlayerTurnOp))
  (=
    (and
      (not (= double-offered-forfeit (doubling_op op)))
      (cube-op.validation (doubling_op op) (cube (prior_game op)) (cube (post_game op)) (player (prior_game op))))
    (game.two-roll-player-turn-op.validation.cube-entanglement op))
)

;;;;
;; Convenience validation function `game.two-roll-player-turn-op.validation.common-invariants`: logical conjunction
;; of following 3 validation functions -- these are the common validation rules for all 2 roll player turn operations:
;; `game.two-roll-player-turn-op.validation.invariant-expectations`, `game.two-roll-player-turn-op.validation.members-valid`,
;; `game.two-roll-player-turn-op.validation.cube-entanglement`

(define-fun game.two-roll-player-turn-op.validation.common-invariants ((op TwoRollPlayerTurnOp)) Bool
  (and
    (game.two-roll-player-turn-op.validation.invariant-expectations op)
    (game.two-roll-player-turn-op.validation.members-valid op)
    (game.two-roll-player-turn-op.validation.cube-entanglement op))
)

;;;;;;;;
;; All _valid_ two roll player turn applications that involve applying both rolls (as opposed to declaring
;; either or both rolls "inadmissible") have these requirements:
;; - all requirements covered by `game.two-roll-player-turn-op.validation.common-invariants`
;; - neither `apply_roll_1` not `apply_roll_2` can be "inapplicable"
;; - post game and prior game are entangled by applying `apply_roll_1` and then `apply_roll_2`

(declare-fun game.two-roll-player-turn-op.validation.both-rolls-game-entanglement (TwoRollPayerTurnOp) Bool)
(assert (! (forall ((op game.two-roll-player-turn-op.validation.both-rolls-game-entanglement))
  (=
    (and
      (game.two-roll-player-turn-op.validation.common-invariants op)
      (not (= inapplicable (apply_roll_1 op)))
      (not (= inapplicable (apply_roll_2 op)))
      (let (
        (prior_player_board
          (ite (= Red (next_player (prior_game op)))
            (red_board (prior_game op))
            (black_board (prior_game op))))
        (post_player_board
          (ite (= Red (next_player (post_game op)))
            (red_board (post_game op))
            (black_board (post_game op)))))

        (and
          (exists ((medi_player_board Board))
            (and
              (apply-roll-op.validation prior_player_board medi_player_board (roll_1 op))
              (apply-roll-op.validation medi_player_board post_player_board (roll_2 op))))

          (let (
            (game_complete (> (board.count-player-checkers post_player_board 0))))

            (and
              (= (complete (post_game op)) game_complete)
              (=
                (next_player (post_game op))
                (ite game_complete
                  (next_player (prior_game op))
                  (color.opponent-of (next_player (prior_game op))))))))))
    (game.two-roll-player-turn-op.validation.both-rolls-game-entanglement op))
) :named game.two-roll-player-turn-op.validation.both-rolls-game-entanglement ))


