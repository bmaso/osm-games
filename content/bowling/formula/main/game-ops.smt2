#include "game.smt2"
#include "frame-ops.smt2"

#ifndef BOWLING_GAME_OPERATIONS
#define BOWLING_GAME_OPERATIONS

;; __FILE__ || __LINE__ ||

;;;;;;;;;;
;; There's only one atomic, state-changing operation in a game of bowling: applying a throw. A throw application is comprised of
;; - a _prior_ `Game` value, which is the state of the game before the operation is applied
;; - a _post_ `Game` value, is the state of the game after the operation is applied
;; - a `Throw` value, which is the throw applied to the prior state, and which produces the post state
;;;;;;;;;;

(declare-datatype Game.ApplyThrowOp (
  (game.apply-throw-op
    (prior_game Game)
    (post_game Game)
    (throw Throw))
))

;;;;
;; In order to be a _valid_ throw application, the following rules must be satisfied:
;; - the prior state must be valid
;; - the post state must be valid
;; - the throw must be valid and not incomplete or unused
;; - the post game state is an updated version of the prior game state
;;   - in the post state, the frame corresponding to the "current" frame `f_prior` in the prior state is equal to a
;;     `Frame` value `f_post` that would satisfy the `frame.apply-throw-op.validation` rule (with a
;;     `Frame.ApplyThrowOp` value with `f_prior`, `f_post`, and the throw as arguments).
;;;;

(declare-fun game.apply-throw-op.validation.members-valid (Game.ApplyThrowOp) Bool)
(assert (! (forall ((op Game.ApplyThrowOp))
  (=
    (and
      (game.validation (prior_game op))
      (game.validation (post_game op))
      (throw.validation (throw op)))
    (game.apply-throw-op.validation.members-valid op))
) :named game.apply-throw-op.validation.members-valid ))

(declare-fun game.apply-throw-op.validation.completion-consistency (Game.ApplyThrowOp) Bool)
(assert (! (forall ((op Game.ApplyThrowOp))
  (=
    (and
      (incomplete (prior_game op))
      (not (incomplete (throw op))))
    (game.apply-throw-op.validation.completion-consistency op))
) :named game.apply-throw-op.validation.completion-consistency ))

;; convenience function used below -- two frames are "fully entangled" if the regular throws of both frames are equal
(define-fun game.apply-throw-op.validation.fully-entangled-frames ((f1 Frame) (f2 Frame)) Bool
  (and
    (= (throw_1 f1) (throw_1 f2))
    (= (throw_2 f1) (throw_2 f2)))
)

;; This is the soul of the `Game.ApplyThrowOp` operation. The post game is constrained to be an updated version of the prior game
;; by this validation. The focus of the logic is termed the "current frame" popularly: the first sequential frame in which
;; one of the regular throws is incomplete is the "current frame"; this is the frame that the operation's throw will be copied to.
;; - For all all prior frames to the "current" one, the post game frame is fully entangled with the prior frame -- the regular throws
;;   of the post frame are equal to the regular throws of the prior frame. The convenience function
;;   `game.apply-throw-op.validation.fully-entangled-frames` encapulates this logic.
;; - For the "current" frame, the `Frame.ApplyThrowOp` validation entangles the state of the prior and post frames
;; - For all frames after the "current" frame in the frame sequence, the post game frame is simply the `empty-frame`, since no
;;   regular throws have been applied to that frame yet in a valid game sequence
(declare-fun game.apply-throw-op.validation.first-applicable-frame-updated (Game.ApplyThrowOp) Bool)
(assert (! (forall ((op Game.ApplyThrowOp))
  (=
    (ite (frame.incomplete-regular-throws (frame_1 (prior_game op)))
      (and
        (frame.apply-throw-op.validation (frame.apply-throw-op (frame_1 (prior_game op)) (frame_1 (post_game op)) (throw op)))
        (= empty-frame (frame_2 (post_game op)))
        (= empty-frame (frame_3 (post_game op)))
        (= empty-frame (frame_4 (post_game op)))
        (= empty-frame (frame_5 (post_game op)))
        (= empty-frame (frame_6 (post_game op)))
        (= empty-frame (frame_7 (post_game op)))
        (= empty-frame (frame_8 (post_game op)))
        (= empty-frame (frame_9 (post_game op)))
        (= empty-frame (frame_10 (post_game op))))
      (ite (frame.incomplete-regular-throws (frame_2 (prior_game op)))
        (and
          (game.apply-throw-op.validation.fully-entangled-frames (frame_1 (prior_game op)) (frame_1 (post_game op)))
          (frame.apply-throw-op.validation (frame.apply-throw-op (frame_2 (prior_game op)) (frame_2 (post_game op)) (throw op)))
          (= empty-frame (frame_3 (post_game op)))
          (= empty-frame (frame_4 (post_game op)))
          (= empty-frame (frame_5 (post_game op)))
          (= empty-frame (frame_6 (post_game op)))
          (= empty-frame (frame_7 (post_game op)))
          (= empty-frame (frame_8 (post_game op)))
          (= empty-frame (frame_9 (post_game op)))
          (= empty-frame (frame_10 (post_game op))))
        (ite (frame.incomplete-regular-throws (frame_3 (prior_game op)))
          (and
            (game.apply-throw-op.validation.fully-entangled-frames (frame_1 (prior_game op)) (frame_1 (post_game op)))
            (game.apply-throw-op.validation.fully-entangled-frames (frame_2 (prior_game op)) (frame_2 (post_game op)))
            (frame.apply-throw-op.validation (frame.apply-throw-op (frame_3 (prior_game op)) (frame_3 (post_game op)) (throw op)))
            (= empty-frame (frame_4 (post_game op)))
            (= empty-frame (frame_5 (post_game op)))
            (= empty-frame (frame_6 (post_game op)))
            (= empty-frame (frame_7 (post_game op)))
            (= empty-frame (frame_8 (post_game op)))
            (= empty-frame (frame_9 (post_game op)))
            (= empty-frame (frame_10 (post_game op))))
          (ite (frame.incomplete-regular-throws (frame_4 (prior_game op)))
            (and
              (game.apply-throw-op.validation.fully-entangled-frames (frame_1 (prior_game op)) (frame_1 (post_game op)))
              (game.apply-throw-op.validation.fully-entangled-frames (frame_2 (prior_game op)) (frame_2 (post_game op)))
              (game.apply-throw-op.validation.fully-entangled-frames (frame_3 (prior_game op)) (frame_3 (post_game op)))
              (frame.apply-throw-op.validation (frame.apply-throw-op (frame_4 (prior_game op)) (frame_4 (post_game op)) (throw op)))
              (= empty-frame (frame_5 (post_game op)))
              (= empty-frame (frame_6 (post_game op)))
              (= empty-frame (frame_7 (post_game op)))
              (= empty-frame (frame_8 (post_game op)))
              (= empty-frame (frame_9 (post_game op)))
              (= empty-frame (frame_10 (post_game op))))
            (ite (frame.incomplete-regular-throws (frame_5 (prior_game op)))
              (and
                (game.apply-throw-op.validation.fully-entangled-frames (frame_1 (prior_game op)) (frame_1 (post_game op)))
                (game.apply-throw-op.validation.fully-entangled-frames (frame_2 (prior_game op)) (frame_2 (post_game op)))
                (game.apply-throw-op.validation.fully-entangled-frames (frame_3 (prior_game op)) (frame_3 (post_game op)))
                (game.apply-throw-op.validation.fully-entangled-frames (frame_4 (prior_game op)) (frame_4 (post_game op)))
                (frame.apply-throw-op.validation (frame.apply-throw-op (frame_5 (prior_game op)) (frame_5 (post_game op)) (throw op)))
                (= empty-frame (frame_6 (post_game op)))
                (= empty-frame (frame_7 (post_game op)))
                (= empty-frame (frame_8 (post_game op)))
                (= empty-frame (frame_9 (post_game op)))
                (= empty-frame (frame_10 (post_game op))))
              (ite (frame.incomplete-regular-throws (frame_6 (prior_game op)))
                (and
                  (game.apply-throw-op.validation.fully-entangled-frames (frame_1 (prior_game op)) (frame_1 (post_game op)))
                  (game.apply-throw-op.validation.fully-entangled-frames (frame_2 (prior_game op)) (frame_2 (post_game op)))
                  (game.apply-throw-op.validation.fully-entangled-frames (frame_3 (prior_game op)) (frame_3 (post_game op)))
                  (game.apply-throw-op.validation.fully-entangled-frames (frame_4 (prior_game op)) (frame_4 (post_game op)))
                  (game.apply-throw-op.validation.fully-entangled-frames (frame_5 (prior_game op)) (frame_5 (post_game op)))
                  (frame.apply-throw-op.validation (frame.apply-throw-op (frame_6 (prior_game op)) (frame_6 (post_game op)) (throw op)))
                  (= empty-frame (frame_7 (post_game op)))
                  (= empty-frame (frame_8 (post_game op)))
                  (= empty-frame (frame_9 (post_game op)))
                  (= empty-frame (frame_10 (post_game op))))
                (ite (frame.incomplete-regular-throws (frame_7 (prior_game op)))
                  (and
                    (game.apply-throw-op.validation.fully-entangled-frames (frame_1 (prior_game op)) (frame_1 (post_game op)))
                    (game.apply-throw-op.validation.fully-entangled-frames (frame_2 (prior_game op)) (frame_2 (post_game op)))
                    (game.apply-throw-op.validation.fully-entangled-frames (frame_3 (prior_game op)) (frame_3 (post_game op)))
                    (game.apply-throw-op.validation.fully-entangled-frames (frame_4 (prior_game op)) (frame_4 (post_game op)))
                    (game.apply-throw-op.validation.fully-entangled-frames (frame_5 (prior_game op)) (frame_5 (post_game op)))
                    (game.apply-throw-op.validation.fully-entangled-frames (frame_6 (prior_game op)) (frame_6 (post_game op)))
                    (frame.apply-throw-op.validation (frame.apply-throw-op (frame_7 (prior_game op)) (frame_7 (post_game op)) (throw op)))
                    (= empty-frame (frame_8 (post_game op)))
                    (= empty-frame (frame_9 (post_game op)))
                    (= empty-frame (frame_10 (post_game op))))
                  (ite (frame.incomplete-regular-throws (frame_8 (prior_game op)))
                    (and
                      (game.apply-throw-op.validation.fully-entangled-frames (frame_1 (prior_game op)) (frame_1 (post_game op)))
                      (game.apply-throw-op.validation.fully-entangled-frames (frame_2 (prior_game op)) (frame_2 (post_game op)))
                      (game.apply-throw-op.validation.fully-entangled-frames (frame_3 (prior_game op)) (frame_3 (post_game op)))
                      (game.apply-throw-op.validation.fully-entangled-frames (frame_4 (prior_game op)) (frame_4 (post_game op)))
                      (game.apply-throw-op.validation.fully-entangled-frames (frame_5 (prior_game op)) (frame_5 (post_game op)))
                      (game.apply-throw-op.validation.fully-entangled-frames (frame_6 (prior_game op)) (frame_6 (post_game op)))
                      (game.apply-throw-op.validation.fully-entangled-frames (frame_7 (prior_game op)) (frame_7 (post_game op)))
                      (frame.apply-throw-op.validation (frame.apply-throw-op (frame_8 (prior_game op)) (frame_8 (post_game op)) (throw op)))
                      (= empty-frame (frame_9 (post_game op)))
                      (= empty-frame (frame_10 (post_game op))))
                    (ite (frame.incomplete-regular-throws (frame_9 (prior_game op)))
                      (and
                        (game.apply-throw-op.validation.fully-entangled-frames (frame_1 (prior_game op)) (frame_1 (post_game op)))
                        (game.apply-throw-op.validation.fully-entangled-frames (frame_2 (prior_game op)) (frame_2 (post_game op)))
                        (game.apply-throw-op.validation.fully-entangled-frames (frame_3 (prior_game op)) (frame_3 (post_game op)))
                        (game.apply-throw-op.validation.fully-entangled-frames (frame_4 (prior_game op)) (frame_4 (post_game op)))
                        (game.apply-throw-op.validation.fully-entangled-frames (frame_5 (prior_game op)) (frame_5 (post_game op)))
                        (game.apply-throw-op.validation.fully-entangled-frames (frame_6 (prior_game op)) (frame_6 (post_game op)))
                        (game.apply-throw-op.validation.fully-entangled-frames (frame_7 (prior_game op)) (frame_7 (post_game op)))
                        (game.apply-throw-op.validation.fully-entangled-frames (frame_8 (prior_game op)) (frame_8 (post_game op)))
                        (frame.apply-throw-op.validation (frame.apply-throw-op (frame_9 (prior_game op)) (frame_9 (post_game op)) (throw op)))
                        (= empty-frame (frame_10 (post_game op))))
                      (ite (frame.incomplete-regular-throws (frame_10 (prior_game op)))
                        (and
                          (game.apply-throw-op.validation.fully-entangled-frames (frame_1 (prior_game op)) (frame_1 (post_game op)))
                          (game.apply-throw-op.validation.fully-entangled-frames (frame_2 (prior_game op)) (frame_2 (post_game op)))
                          (game.apply-throw-op.validation.fully-entangled-frames (frame_3 (prior_game op)) (frame_3 (post_game op)))
                          (game.apply-throw-op.validation.fully-entangled-frames (frame_4 (prior_game op)) (frame_4 (post_game op)))
                          (game.apply-throw-op.validation.fully-entangled-frames (frame_5 (prior_game op)) (frame_5 (post_game op)))
                          (game.apply-throw-op.validation.fully-entangled-frames (frame_6 (prior_game op)) (frame_6 (post_game op)))
                          (game.apply-throw-op.validation.fully-entangled-frames (frame_7 (prior_game op)) (frame_7 (post_game op)))
                          (game.apply-throw-op.validation.fully-entangled-frames (frame_8 (prior_game op)) (frame_8 (post_game op)))
                          (game.apply-throw-op.validation.fully-entangled-frames (frame_9 (prior_game op)) (frame_9 (post_game op)))
                          (frame.apply-throw-op.validation (frame.apply-throw-op (frame_10 (prior_game op)) (frame_10 (post_game op)) (throw op))))

                        ;; if the prior game is complete, then there is no possible post game value that satifies the restrictions

                        false))))))))))
    (game.apply-throw-op.validation.first-applicable-frame-updated op))
) :named game.apply-throw-op.validation.first-applicable-frame-updated ))

(define-fun game.apply-throw-op.validation ((op Game.ApplyThrowOp)) Bool
  (and
    (game.apply-throw-op.validation.members-valid op)
    (game.apply-throw-op.validation.completion-consistency op)
    (game.apply-throw-op.validation.first-applicable-frame-updated op))
)

#endif