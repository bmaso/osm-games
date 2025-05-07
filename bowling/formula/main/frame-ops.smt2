#include "frame.smt2"

#ifndef BOWLING_FRAME_OPERATIONS
#define BOWLING_FRAME_OPERATIONS

;; __FILE__ || __LINE__ ||

;;;;;;;;;;
;; There's one atomic, state-changing operation applied to a frame during a game of bowling: applying a throw.
;; A throw application is comprised of
;; - a _prior_ `Frame` value, which is the state of the frame before the operation is applied
;; - a _post_ `Frame` value, is the state of the frame after the operation is applied
;; - a `Throw` value, which is the throw applied to the prior state, and which produces the post state
;;;;;;;;;;

(declare-datatype Frame.ApplyThrowOp (
  (frame.apply-throw
    (prior_frame Frame)
    (post_frame Frame)
    (throw Throw))))

;;;;
;; In order to be a _valid_ application of a throw to a frame, the following rules must be satisfied:
;; - the prior frame must be valid
;; - the post frame must be valid
;; - the throw must be valid a not incomplete and not unused
;; - and one of these rules must be satisfied
;;   - prior frame throw_1 is incomplete and
;;     - post frame throw_1 is equal to the operation's throw
;;   - prior frame throw_2 is incomplete and
;;     - post frame throw_2 is equal to the operation's throw and
;;     - post frame throw_1 and prior frame throw_1 are equal
;;   - prior frame bonus_1 is incomplete and
;;     - post frame bonus_1 is equal to the operation's throw and
;;     - post frame {throw_1, throw_2} are equal to prior frame {throw_1, throw_2} respectively
;;   - prior frame bonus_2 is incomplete and
;;     - post frame bonus_2 is equal to the operation's throw and
;;     - post frame {throw_1, throw_2, bonus_1} are equal to prior frame {throw_1, throw_2, bonus_1} respectively
;;;;

(define-fun frame.apply-throw.valid ((op Frame.ApplyThrowOp)) Bool
  (and
    (frame.valid (prior_frame op))
    (frame.valid (post_frame op))
    (throw.valid (throw op))
    (not (incomplete (throw op)))
    (not (unused (throw op)))
    (or
      (and
        (incomplete (throw_1 (prior_frame op)))
        (= (throw_1 (post_frame op)) (throw op))
        (=>
          (not (= strike-throw (throw op)))
          (and
            (incomplete (throw_2 (post_frame op)))
            (incomplete (bonus_1 (post_frame op)))
            (unused (bonus_2 (post_frame op)))))
        (=>
          (= strike-throw (throw op))
          (and
            (unused (throw_2 (post_frame op)))
            (incomplete (bonus_1 (post_frame op)))
            (incomplete (bonus_2 (post_frame op))))))
      (and
        (incomplete (throw_2 (prior_frame op)))
        (= (throw_2 (post_frame op)) (throw op))
        (= (throw_1 (prior_frame op)) (throw_1 (post_frame op)))
        (=>
          (= #b1111111111 (bvor (pins (throw_1 (post_frame op))) (pins (throw_2 (post_frame op)))))
          (and
            (incomplete (bonus_1 (post_frame op)))
            (unused (bonus_2 (post_frame op)))))
        (=>
          (not (= #b1111111111 (bvor (pins (throw_1 (post_frame op))) (pins (throw_2 (post_frame op))))))
          (and
            (unused (bonus_1 (post_frame op)))
            (unused (bonus_2 (post_frame op))))))
      (and
        (incomplete (bonus_1 (prior_frame op)))
        (= (bonus_1 (post_frame op)) (throw op))
        (= (throw_1 (prior_frame op)) (throw_1 (post_frame op)))
        (= (throw_2 (prior_frame op)) (throw_2 (post_frame op)))
        (= (bonus_2 (prior_frame op)) (bonus_2 (post_frame op))))
      (and
        (incomplete (bonus_2 (prior_frame op)))
        (= (bonus_2 (post_frame op)) (throw op))
        (= (throw_1 (prior_frame op)) (throw_1 (post_frame op)))
        (= (throw_2 (prior_frame op)) (throw_2 (post_frame op)))
        (= (bonus_1 (prior_frame op)) (bonus_1 (post_frame op)))))))

#endif

