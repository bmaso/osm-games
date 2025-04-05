#include "color.smt2"

#ifndef BACKGAMMON_DOMAIN_CUBE
#define BACKGAMMON_DOMAIN_CUBE

;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; At the beginning of each player's turn the dobuling cube state may be modified. Each board state has an associated cube state,
;; which has just two field values:
;; - A value, representing the current log 2 value of the cube. 0 means the value of the cube is 1, 1 means the value
;;   of the cube is 2, 2 means the value of the cube is 4, and so on.
;; - the player who currently owns the right to double the cube, stored as a player `Color`. At the begnning of the game
;;   the cube is unowned, and may initially be doubled by either player.
;;
;; See [Wikipedia's description](https://en.wikipedia.org/wiki/Backgammon#Doubling_cube) of the backgammon doubling cube.

(declare-datatype DoublingCube (
  (cube
    (log_value Int)
    (owner Color))
))

;;;;
;; The initial cube state at the beginning of the game process

(define-const new-game-cube DoublingCube
  (cube
    0         ; log_value
    Neutral)  ; owner
)

;;;;
;; A _valid_ cube has these invariant restrictions:
;; - the log value is >= 0
;; - IF the cube is unowned, THEN the value of the cube must be 1 (ie the log value must be 0)

(declare-fun cube.validation.doubling-value-nonnegative (DoublingCube) Bool)
(assert (! (forall ((c DoublingCube))
  (=
    (>= (log_value c) 0)
    (cube.validation.doubling-value-nonnegative c))
) :named cube.validation.doubling-value-nonnegative ))

(declare-fun cube.validation.unowned-cube-is-zero (DoublingCube) Bool)
(assert (! (forall ((c DoublingCube))
  (=
    (=
      (= (log_value c) 0)
      (= (owner c) Neutral))
    (cube.validation.unowned-cube-is-zero c))
) :named unowned-cube-is-zero ))

(define-fun cube.validation ((c DoublingCube)) Bool
  (and
    (cube.validation.doubling-value-nonnegative c)
    (cube.validation.unowned-cube-is-zero c))
)

#endif
