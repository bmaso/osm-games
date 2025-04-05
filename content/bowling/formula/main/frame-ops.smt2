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
;;
;; There's also another special-case operation, which is used only to populate the bonus throws of the 10th frame
;; when the 10th frame is a "mark" frame (strike or spare). This operation re-use the same datatype, but will utilize
;; a different validation function because the rules are a it different -- unlike frames 1-9, the 10th frame's
;; bonus throws are not identical to succesive frame normal throws.
;;;;;;;;;;

(declare-datatype Frame.ApplyThrowOp (
  (frame.apply-throw-op
    (prior_frame Frame)
    (post_frame Frame)
    (throw Throw))))

;;;;
;; In order to be a _valid_ frame throw application for frames 1-9, the following rules must be satisfied:
;; - the prior frame must be valid
;; - the post frame must be valid
;; - the throw must be valid a not incomplete and not unused
;; - and one of these two rules must be satisfied
;;   - prior frame throw_1 is incomplete and
;;     - post frame throw_1 is equal to the operation's throw
;;     - it is necessary to initialize throw_2 and the bonus throws in the post frame
;;       - if post frame is not a strike, post frame throw_2 and bonus_1 are incomplete, and bonus_2 is unused
;;       - if post frame is a strike, post frame bonus_1 and bonus_2 are incomplete, and throw_2 is unused
;;   - prior frame throw_2 is incomplete and
;;     - post frame throw_2 is equal to the operation's throw and
;;     - post frame throw_1 and prior frame throw_1 are equal
;;     - it is necessary to initialize the bonus throws in the post frame
;;       - if post frame is a spare, post frame bonus_1 is incomplete
;;       - if post frame is not a space, bonus_1 is unused
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
              (incomplete (bonus_1 (post_frame op)))
              (unused (bonus_2 (post_frame op)))))
          (=>
            (strike (post_frame op))
            (and
              (incomplete (bonus_1 (post_frame op)))
              (incomplete (bonus_2 (post_frame op)))
              (unused (throw_2 (post_frame op))))))
        (and
          (not (incomplete (throw_1 (prior_frame op))))
          (incomplete (throw_2 (prior_frame op)))
          (= (throw_2 (post_frame op)) (throw op))
          (= (throw_1 (prior_frame op)) (throw_1 (post_frame op)))
          (=>
            (not (spare (post_frame op)))
            (unused (bonus_1 (post_frame op))))          
          (=>
            (spare (post_frame op))
            (incomplete (bonus_1 (post_frame op)))))))
    (frame.apply-throw-op.validation op))
) :named frame.apply-throw-op.validation ))

;;;;
;; In order to be a _valid_ frame throw application for frame 10, the rules are slightly different than frames 1-9.
;; The following rules must be satisfied, which are an expandion of the rules for frame 1-9, with additional rules
;; for assigning values to the frame 10 bonus fields. (It isnlt necessary to assign values to bonus fields for frames 1-9,
;; because the bonus fields in those frames are poplated from subsequent normal throw field values.)
;; - the prior frame must be valid
;; - the post frame must be valid
;; - the throw must be valid a not incomplete and not unused
;; - and one of these four rules must be satisfied
;;   - prior frame throw_1 is incomplete and
;;     - post frame throw_1 is equal to the operation's throw
;;     - it is necessary to initialize throw_2 and the bonus throws in the post frame
;;       - if post frame is not a strike, post frame throw_2 and bonus_1 are incomplete, and bonus_2 is unused
;;       - if post frame is a strike, post frame bonus_1 and bonus_2 are incomplete, and throw_2 is unused
;;   - prior frame throw_2 is incomplete and
;;     - post frame throw_2 is equal to the operation's throw and
;;     - post frame throw_1 and prior frame throw_1 are equal
;;     - it is necessary to initialize the bonus throws in the post frame
;;       - if post frame is a spare, post frame bonus_1 is incomplete
;;       - if post frame is not a space, bonus_1 is unused
;;   - prior frame bonus_1 is incomplete and
;;     - post frame bonus_1 is equal to the operation's throw and
;;     - post frame throw_2 and prior frame throw_2 are equal
;;     - post frame throw_1 and prior frame throw_1 are equal
;;   - prior frame bonus_2 is incomplete and
;;     - post frame bonus_2 is equal to the operation's throw and
;;     - post frame bonus_1 and prior frame bonus_1 are equal
;;     - post frame throw_2 and prior frame throw_2 are equal
;;     - post frame throw_1 and prior frame throw_1 are equal
;;;;

(declare-fun frame.apply-throw-op-frame-10.validation (Frame.ApplyThrowOp) Bool)
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
                (incomplete (bonus_1 (post_frame op)))
                (unused (bonus_2 (post_frame op)))))
          (=>
            (strike (post_frame op))
            (and
              (incomplete (bonus_1 (post_frame op)))
              (incomplete (bonus_2 (post_frame op)))
              (unused (throw_2 (post_frame op))))))
        (and
          (not (incomplete (throw_1 (prior_frame op))))
          (incomplete (throw_2 (prior_frame op)))
          (= (throw_2 (post_frame op)) (throw op))
          (= (throw_1 (prior_frame op)) (throw_1 (post_frame op)))
          (=>
            (spare (post_frame op))
            (incomplete (bonus_1 (post_frame op))))
          (not (=>
            (spare (post_frame op))
            (unused (bonus_1 (post_frame op))))))
        (and
          (not (incomplete (throw_1 (prior_frame op))))
          (not (incomplete (throw_2 (prior_frame op))))
          (incomplete (bonus_1 (prior_frame op)))
          (= (bonus_1 (post_frame op)) (throw op))
          (= (bonus_2 (post_frame op)) (bonus_2 (prior_frame op))))
        (and
          (not (incomplete (throw_1 (prior_frame op))))
          (not (incomplete (throw_2 (prior_frame op))))
          (not (incomplete (bonus_1 (prior_frame op))))
          (incomplete (bonus_2 (prior_frame op)))
          (= (bonus_2 (post_frame op)) (throw op)))))
    (frame.apply-throw-op-frame-10.validation op))
) :named frame.apply-throw-op-frame-10.validation ))

#endif

