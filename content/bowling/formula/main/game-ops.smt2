#include "game.smt2"
#include "frame-ops.smt2"

#ifndef BOWLING_GAME_OPERATIONS
#define BOWLING_GAME_OPERATIONS

;; __FILE__ || __LINE__ ||

;;;;;;;;;;
;; There's only one atomic, state-changing operation in a game of bowling: applying a throw. A throw application
;; is comprised of
;; - a _prior_ `Game` value, which is the state of the game before the operation is applied
;; - a _post_ `Game` value, is the state of the game after the operation is applied
;; - a `Throw` value, which is the throw applied to the prior state, and which produces the post state
;;;;;;;;;;

(declare-datatype Game.ApplyThrowOp (
  (game.apply-throw-op
    (prior_game Game)
    (post_game Game)
    (throw Throw))))

;;;;
;; convenience function that computes whether on not a _valid_ function is incomplete.
;;;;

;;;;
;; In order to be a _valid_ throw application, the following rules must be satisfied:
;; - the prior state must be valid
;; - the post state must be valid
;; - the throw must be valid and not incomplete or unused
;; - the post game state is an updated version of the prior game state
;;   - in the post state, the frame corresponding to the "current" frame value `f_prior` in the prior state is equal to a
;;     frame value `f_post` that would satisfy the `frame.apply-throw.valid` rule (with a
;;     `Frame.ApplyThrowOp` value with `f_prior`, `f_post`, and the throw as arguments).
;;   - Other than the "current" frame, all frames in the post game are equal their corresponding frames in the post state
;;   - Note: the "current" frame is the first frame for which `frame.incomplete-normal-throws` is true.
;;;;

(define-fun game.apply-throw-op.valid.members-valid ((op Game.ApplyThrowOp)) Bool
  (and
    (game.valid (prior_game op))
    (game.valid (post_game op))
    (throw.valid (throw op))))

(define-fun game.apply-throw-op.valid.completion-consistency ((op Game.ApplyThrowOp)) Bool
  (and
    (game.is-incomplete (prior_game op))
    (not (incomplete (throw op)))
    (not (unused (throw op)))))

;;
;; Because of the repetative patterns in this function, this is a prime example of code that would be
;; better expressed with a meta-programming macro. 
;;
(define-fun game.apply-throw-op.valid.first-applicable-frame-updated ((op Game.ApplyThrowOp)) Bool
  (or
    (and
      (frame.incomplete-normal-throws (frame_1 (prior_game op)))          ;; current frame is frame_1
      (exists ((frame_op Frame.ApplyThrowOp))
        (and
          (frame.apply-throw.valid frame_op)
          (= (prior_frame frame_op) (frame_1 (prior_game op)))
          (= (post_frame frame_op)  (frame_1 (post_game op)))
          (= (throw frame_op) (throw op))))
      (= (frame_2 (prior_game op))  (frame_2 (post_game op)))
      (= (frame_3 (prior_game op))  (frame_3 (post_game op)))
      (= (frame_4 (prior_game op))  (frame_4 (post_game op)))
      (= (frame_5 (prior_game op))  (frame_5 (post_game op)))
      (= (frame_6 (prior_game op))  (frame_6 (post_game op)))
      (= (frame_7 (prior_game op))  (frame_7 (post_game op)))
      (= (frame_8 (prior_game op))  (frame_8 (post_game op)))
      (= (frame_9 (prior_game op))  (frame_9 (post_game op)))
      (= (frame_10 (prior_game op)) (frame_10 (post_game op))))

    (and
      (not (frame.incomplete-normal-throws (frame_1 (prior_game op))))
      (frame.incomplete-normal-throws (frame_2 (prior_game op)))          ;; current frame is frame_2
      (exists ((frame_op Frame.ApplyThrowOp))
        (and
          (frame.apply-throw.valid frame_op)
          (= (prior_frame frame_op) (frame_2 (prior_game op)))
          (= (post_frame frame_op)  (frame_2 (post_game op)))
          (= (throw frame_op) (throw op))))
      (= (frame_1 (prior_game op))  (frame_1 (post_game op)))
      (= (frame_3 (prior_game op))  (frame_3 (post_game op)))
      (= (frame_4 (prior_game op))  (frame_4 (post_game op)))
      (= (frame_5 (prior_game op))  (frame_5 (post_game op)))
      (= (frame_6 (prior_game op))  (frame_6 (post_game op)))
      (= (frame_7 (prior_game op))  (frame_7 (post_game op)))
      (= (frame_8 (prior_game op))  (frame_8 (post_game op)))
      (= (frame_9 (prior_game op))  (frame_9 (post_game op)))
      (= (frame_10 (prior_game op)) (frame_10 (post_game op))))

    (and
      (not (frame.incomplete-normal-throws (frame_2 (prior_game op))))
      (frame.incomplete-normal-throws (frame_3 (prior_game op)))          ;; current frame is frame_3
      (exists ((frame_op Frame.ApplyThrowOp))
        (and
          (frame.apply-throw.valid frame_op)
          (= (prior_frame frame_op) (frame_3 (prior_game op)))
          (= (post_frame frame_op)  (frame_3 (post_game op)))
          (= (throw frame_op) (throw op))))
      (= (frame_1 (prior_game op))  (frame_1 (post_game op)))
      (= (frame_2 (prior_game op))  (frame_2 (post_game op)))
      (= (frame_4 (prior_game op))  (frame_4 (post_game op)))
      (= (frame_5 (prior_game op))  (frame_5 (post_game op)))
      (= (frame_6 (prior_game op))  (frame_6 (post_game op)))
      (= (frame_7 (prior_game op))  (frame_7 (post_game op)))
      (= (frame_8 (prior_game op))  (frame_8 (post_game op)))
      (= (frame_9 (prior_game op))  (frame_9 (post_game op)))
      (= (frame_10 (prior_game op)) (frame_10 (post_game op))))

    (and
      (not (frame.incomplete-normal-throws (frame_3 (prior_game op))))
      (frame.incomplete-normal-throws (frame_4 (prior_game op)))          ;; current frame is frame_4
      (exists ((frame_op Frame.ApplyThrowOp))
        (and
          (frame.apply-throw.valid frame_op)
          (= (prior_frame frame_op) (frame_4 (prior_game op)))
          (= (post_frame frame_op)  (frame_4 (post_game op)))
          (= (throw frame_op) (throw op))))
      (= (frame_1 (prior_game op))  (frame_1 (post_game op)))
      (= (frame_2 (prior_game op))  (frame_2 (post_game op)))
      (= (frame_3 (prior_game op))  (frame_3 (post_game op)))
      (= (frame_5 (prior_game op))  (frame_5 (post_game op)))
      (= (frame_6 (prior_game op))  (frame_6 (post_game op)))
      (= (frame_7 (prior_game op))  (frame_7 (post_game op)))
      (= (frame_8 (prior_game op))  (frame_8 (post_game op)))
      (= (frame_9 (prior_game op))  (frame_9 (post_game op)))
      (= (frame_10 (prior_game op)) (frame_10 (post_game op))))

    (and
      (not (frame.incomplete-normal-throws (frame_4 (prior_game op))))
      (frame.incomplete-normal-throws (frame_5 (prior_game op)))          ;; current frame is frame_5
      (exists ((frame_op Frame.ApplyThrowOp))
        (and
          (frame.apply-throw.valid frame_op)
          (= (prior_frame frame_op) (frame_5 (prior_game op)))
          (= (post_frame frame_op)  (frame_5 (post_game op)))
          (= (throw frame_op) (throw op))))
      (= (frame_1 (prior_game op))  (frame_1 (post_game op)))
      (= (frame_2 (prior_game op))  (frame_2 (post_game op)))
      (= (frame_3 (prior_game op))  (frame_3 (post_game op)))
      (= (frame_4 (prior_game op))  (frame_4 (post_game op)))
      (= (frame_6 (prior_game op))  (frame_6 (post_game op)))
      (= (frame_7 (prior_game op))  (frame_7 (post_game op)))
      (= (frame_8 (prior_game op))  (frame_8 (post_game op)))
      (= (frame_9 (prior_game op))  (frame_9 (post_game op)))
      (= (frame_10 (prior_game op)) (frame_10 (post_game op))))

    (and
      (not (frame.incomplete-normal-throws (frame_5 (prior_game op))))
      (frame.incomplete-normal-throws (frame_6 (prior_game op)))          ;; current frame is frame_6
      (exists ((frame_op Frame.ApplyThrowOp))
        (and
          (frame.apply-throw.valid frame_op)
          (= (prior_frame frame_op) (frame_6 (prior_game op)))
          (= (post_frame frame_op)  (frame_6 (post_game op)))
          (= (throw frame_op) (throw op))))
      (= (frame_1 (prior_game op))  (frame_1 (post_game op)))
      (= (frame_2 (prior_game op))  (frame_2 (post_game op)))
      (= (frame_3 (prior_game op))  (frame_3 (post_game op)))
      (= (frame_4 (prior_game op))  (frame_4 (post_game op)))
      (= (frame_5 (prior_game op))  (frame_5 (post_game op)))
      (= (frame_7 (prior_game op))  (frame_7 (post_game op)))
      (= (frame_8 (prior_game op))  (frame_8 (post_game op)))
      (= (frame_9 (prior_game op))  (frame_9 (post_game op)))
      (= (frame_10 (prior_game op)) (frame_10 (post_game op))))

    (and
      (not (frame.incomplete-normal-throws (frame_6 (prior_game op))))
      (frame.incomplete-normal-throws (frame_7 (prior_game op)))          ;; current frame is frame_7
      (exists ((frame_op Frame.ApplyThrowOp))
        (and
          (frame.apply-throw.valid frame_op)
          (= (prior_frame frame_op) (frame_7 (prior_game op)))
          (= (post_frame frame_op)  (frame_7 (post_game op)))
          (= (throw frame_op) (throw op))))
      (= (frame_1 (prior_game op))  (frame_1 (post_game op)))
      (= (frame_2 (prior_game op))  (frame_2 (post_game op)))
      (= (frame_3 (prior_game op))  (frame_3 (post_game op)))
      (= (frame_4 (prior_game op))  (frame_4 (post_game op)))
      (= (frame_5 (prior_game op))  (frame_5 (post_game op)))
      (= (frame_6 (prior_game op))  (frame_6 (post_game op)))
      (= (frame_8 (prior_game op))  (frame_8 (post_game op)))
      (= (frame_9 (prior_game op))  (frame_9 (post_game op)))
      (= (frame_10 (prior_game op)) (frame_10 (post_game op))))

    (and
      (not (frame.incomplete-normal-throws (frame_7 (prior_game op))))
      (frame.incomplete-normal-throws (frame_8 (prior_game op)))          ;; current frame is frame_8
      (exists ((frame_op Frame.ApplyThrowOp))
        (and
          (frame.apply-throw.valid frame_op)
          (= (prior_frame frame_op) (frame_8 (prior_game op)))
          (= (post_frame frame_op)  (frame_8 (post_game op)))
          (= (throw frame_op) (throw op))))
      (= (frame_1 (prior_game op))  (frame_1 (post_game op)))
      (= (frame_2 (prior_game op))  (frame_2 (post_game op)))
      (= (frame_3 (prior_game op))  (frame_3 (post_game op)))
      (= (frame_4 (prior_game op))  (frame_4 (post_game op)))
      (= (frame_5 (prior_game op))  (frame_5 (post_game op)))
      (= (frame_6 (prior_game op))  (frame_6 (post_game op)))
      (= (frame_7 (prior_game op))  (frame_7 (post_game op)))
      (= (frame_9 (prior_game op))  (frame_9 (post_game op)))
      (= (frame_10 (prior_game op)) (frame_10 (post_game op))))

    (and
      (not (frame.incomplete-normal-throws (frame_8 (prior_game op))))
      (frame.incomplete-normal-throws (frame_9 (prior_game op)))          ;; current frame is frame_2
      (exists ((frame_op Frame.ApplyThrowOp))
        (and
          (frame.apply-throw.valid frame_op)
          (= (prior_frame frame_op) (frame_9 (prior_game op)))
          (= (post_frame frame_op)  (frame_9 (post_game op)))
          (= (throw frame_op) (throw op))))
      (= (frame_1 (prior_game op))  (frame_1 (post_game op)))
      (= (frame_2 (prior_game op))  (frame_2 (post_game op)))
      (= (frame_3 (prior_game op))  (frame_3 (post_game op)))
      (= (frame_4 (prior_game op))  (frame_4 (post_game op)))
      (= (frame_5 (prior_game op))  (frame_5 (post_game op)))
      (= (frame_6 (prior_game op))  (frame_6 (post_game op)))
      (= (frame_7 (prior_game op))  (frame_7 (post_game op)))
      (= (frame_8 (prior_game op))  (frame_8 (post_game op)))
      (= (frame_10 (prior_game op)) (frame_10 (post_game op))))

    (and
      (not (frame.incomplete-normal-throws (frame_9 (prior_game op))))
      (frame.incomplete-normal-throws (frame_10 (prior_game op)))          ;; current frame is frame_2
      (exists ((frame_op Frame.ApplyThrowOp))
        (and
          (frame.apply-throw.valid frame_op)
          (= (prior_frame frame_op) (frame_10 (prior_game op)))
          (= (post_frame frame_op)  (frame_10 (post_game op)))
          (= (throw frame_op) (throw op))))
      (= (frame_1 (prior_game op)) (frame_1 (post_game op)))
      (= (frame_2 (prior_game op)) (frame_2 (post_game op)))
      (= (frame_3 (prior_game op)) (frame_3 (post_game op)))
      (= (frame_4 (prior_game op)) (frame_4 (post_game op)))
      (= (frame_5 (prior_game op)) (frame_5 (post_game op)))
      (= (frame_6 (prior_game op)) (frame_6 (post_game op)))
      (= (frame_7 (prior_game op)) (frame_7 (post_game op)))
      (= (frame_8 (prior_game op)) (frame_8 (post_game op)))
      (= (frame_9 (prior_game op)) (frame_9 (post_game op))))))

(define-fun game.apply-throw-op.valid ((op Game.ApplyThrowOp)) Bool
  (and
    (game.apply-throw-op.valid.members-valid op)
    (game.apply-throw-op.valid.completion-consistency op)
    (game.apply-throw-op.valid.first-applicable-frame-updated op)))

#endif