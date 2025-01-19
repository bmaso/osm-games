#include "cube.smt2"
#include "color.smt2"

;; || __FILE_ || __LINE__ ||

#ifndef BACKGAMMON_OPS_CUBE
#define BACKGAMMON_OPS_CUBE

;;;;;;;;;;
;; The first part of each player's turn involves an optional state change in the doubling cube. The WBGF rules support doubling, "beavering",
;; and "raccooning", which is a little complicated to explain. See [Wikipedia's description](https://en.wikipedia.org/wiki
;; Backgammon#Doubling_cube) of the backgammon doubling cube.
;;
;; There are 5 possible outcomes of cube doubling at the beginning of each player's turn, represented here with
;; different constructors of a `DoublingOp` datatype:
;; - `noop`, representing scenarios where the doubling cube remains static. Either the opposing player owns the cube, in which case
;;   the cube cannot be modified, or the current player declines to double the cube; in any event, there's no restriction on
;;   the cube owner for this operation to be valid. The prior and post state of the doubling cube are identical in a valid appication
;;   of this operation.
;; - `double-offered-forfeit`, representing scenarios where the current player proposes to double the cube, and the opposing
;;   player chooses to forfeit the game. There is no difference between the prior and post cube state in these scenarios.
;; - `double-offered-accepted`, representing scenarios where the current player proposes to double the cube, which is accepted without
;;   further change. The difference between the prior and post cube states in these scenarios are:
;;   - the cube log value is raised by 1
;;   - cube ownership passes to the opposing player
;; - `beaver`, representing scenarios where the current player proposes to double the cube, the opposing player accepts and
;;   re-doubles, without further change. This is known as a "beaver". The difference between the prior and post cube states in these
;;   scenarios are:
;;   - the cube value is raised by 2
;;   - cube ownership passes to the opposing player
;; - `raccoon`, representing scenarios where the current player proposes to double the cube, the opposing player accepts and
;;   re-doubles, and the current plyer re-doubles again. The difference between the prior and post cube states in these
;;   scenarios are:
;;   - the cube value is raised by 3
;;   - cube ownership passes to the opposing player
;;
;; The `cube-op.validation` function returns `true` when the param values represent valid cube state transitions of the indicated
;; `DoublingOp` type. This validation function is used as part of game operation validation.
;;
;; The `double-offered-forfeit` cube operation is one of the 2 terminal operations of a backgammon game process. The game validation
;; logic entangles this operation with the game completion flag in the post game state.

(declare-datatype DoublingOp (
  (noop)
  (double-offered-forfeit)
  (double-offered-accepted)
  (beaver)
  (raccoon)
))

(declare-fun cube-op.noop.validation (DoublingCube DoublingCube) Bool)
(assert (! (forall ((prior_cube DoublingCube) (post_cube DoublingCube))
  (=
    (= prior_cube post_cube)
    (cube-op.noop.validation prior_cube post_cube))
) :named cube-op.noop.validation ))

(declare-fun cube-op.double-offered-forfeit.validation (DoublingCube DoublingCube Color) Bool)
(assert (! (forall ((prior_cube DoublingCube) (post_cube DoublingCube) (current_player Color))
  (=
    (and
      (= prior_cube post_cube)
      (or
        (= (owner prior_cube) current_player)
        (= (owner prior_cube) Neutral)))
    (cube-op.double-offered-forfeit.validation prior_cube post_cube current_player))
) :named cube-op.double-offered-forfeit.validation ))

(declare-fun cube-op.double-offered-accepted.validation (DoublingCube DoublingCube Color) Bool)
(assert (! (forall ((prior_cube DoublingCube) (post_cube DoublingCube) (current_player Color))
  (=
    (and
      (= (+ 1 (log_value prior_cube)) (log_value post_cube))
      (= (owner post_cube) (ite (= Red (owner prior_cube)) Black Red))
      (or
        (= (owner prior_cube) current_player)
        (= (owner prior_cube) Neutral)))
    (cube-op.double-offered-accepted.validation prior_cube post_cube current_player))
) :named cube-op.double-offered-accepted.validation ))

(declare-fun cube-op.beaver.validation (DoublingCube DoublingCube Color) Bool)
(assert (! (forall ((prior_cube DoublingCube) (post_cube DoublingCube) (current_player Color))
  (=
    (and
      (= (+ 2 (log_value prior_cube)) (log_value post_cube))
      (= (owner post_cube) (ite (= Red (owner prior_cube)) Black Red))
      (or
        (= (owner prior_cube) current_player)
        (= (owner prior_cube) Neutral)))
    (cube-op.beaver.validation prior_cube post_cube current_player))
) :named cube-op.beaver.validation ))

(declare-fun cube-op.raccoon.validation (DoublingCube DoublingCube Color) Bool)
(assert (! (forall ((prior_cube DoublingCube) (post_cube DoublingCube) (current_player Color))
  (=
    (and
      (= (+ 3 (log_value prior_cube)) (log_value post_cube))
      (= (owner post_cube) (ite (= Red (owner prior_cube)) Black Red))
      (or
        (= (owner prior_cube) current_player)
        (= (owner prior_cube) Neutral)))
    (cube-op.raccoon.validation prior_cube post_cube current_player))
) :named cube-op.racoon.validation ))

(define-fun cube-op.validation ((op DoublingOp) (prior_cube DoublingCube) (post_cube DoublingCube) (current_player Color)) Bool
  (match op (
    (noop
      (cube-op.noop.validation prior_cube post_cube))

    (double-offered-forfeit
      (cube-op.double-offered-forfeit.validation prior_cube post_cube current_player))

    (double-offered-accepted
      (cube-op.double-offered-accepted.validation prior_cube post_cube current_player))

    (beaver
      (cube-op.beaver.validation prior_cube post_cube current_player))

    (raccoon
      (cube-op.raccoon.validation prior_cube post_cube current_player))))
)

#endif