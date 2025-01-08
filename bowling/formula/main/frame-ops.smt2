#include "frame.smt2"

#ifndef BOWLING_FRAME_OPERATIONS
#define BOWLING_FRAME_OPERATIONS

;; __FILE__ || __LINE__ ||

;;;;;;;;;;
;; There's only one atomic, state-changing operation applied to a frame during a game of bowling: applying a throw. A throw application is comprised of
;; - a _prior_ `Frame` value, which is the state of the frame before the operation is applied
;; - a _post_ `Frame` value, is the state of the frame after the operation is applied
;; - a `Throw` value, which is the throw applied to the prior state, and which produces the post state
;;;;;;;;;;

(declare-datatype Frame.ApplyThrowOp (
  (frame.apply-throw-op
    (prior_frame Frame)
    (post_frame Frame)
    (throw Throw))
))

;;;;
;; In order to be a _valid_ frame throw application, the following rules must be satisfied:
;; - the prior frame must be valid
;; - the post frame must be valid
;; - the throw must be valid a not incomplete and not unused
;; - and one of these two rules must be satisfied
;;   - prior frame throw_1 is incomplete and
;;     - post frame throw_1 is equal to the operation's throw
;;     - it is necessary to initialize throw_2 and the bonus throws in the post frame
;;       - if post frame is not a strike, post frame throw_2 and bonus_1 are incomplete
;;       - if post frame is a strike, post frame bonus_1 and bonus_2 are incomplete
;;   - prior frame throw_2 is incomplete and
;;     - post frame throw_2 is equal to the operation's throw and
;;     - post frame throw_1 and prior frame throw_1 are equal
;;     - it is necessary to initialize the bonus throws in the post frame
;;       - if post frame is a spare, post frame bonus_1 is incomplete
;;;;

(declare-fun frame.apply-throw-op.validation (Frame.ApplyThrowOp) Bool)
(assert (! (forall ((op Frame.ApplyThrowOp))
  (=
    (and
      (frame.validation (prior_frame op))
      (frame.validation (post_frame op))
      (throw.validation (throw op))
      (not (incomplete (throw op)))
      (or
        (and
          (incomplete (throw_1 (prior_frame op)))
          (= (throw_1 (post_frame op)) (throw op))
          (=>
            (not (strike (post_frame op)))
              (and
                (incomplete (throw_2 (post_frame op)))
                (incomplete (bonus_1 (post_frame op)))))
          (=>
            (strike (post_frame op))
            (and
              (incomplete (bonus_1 (post_frame op)))
              (incomplete (bonus_2 (post_frame op))))))
        (and
          (not (incomplete (throw_1 (prior_frame op))))
          (incomplete (throw_2 (prior_frame op)))
          (= (throw_2 (post_frame op)) (throw op))
          (= (throw_1 (prior_frame op)) (throw_1 (post_frame op)))
          (=>
            (spare (post_frame op))
            (incomplete (bonus_1 (post_frame op)))))))
    (frame.apply-throw-op.validation op))
) :named frame.apply-throw-op.validation ))

#endif

