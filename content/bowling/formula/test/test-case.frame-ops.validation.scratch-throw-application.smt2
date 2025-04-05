#include "frame-ops.smt2"
;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; Prove that:
;; - A valid application of a scratch throw to an empty frame yields a frame that always
;;   - is incomplete
;;   - has the first throw assigned the applied throw
;;   - is neither a strike nor a spare
;;   - has the second normal throw and first bonus throw incomplete
;;   - has the second bonus throw unused
;; - A valid application of a second scratch throw to a frame with a first scratch throw such that the 2 throws sum to less than 10 yields
;;   a frame that always:
;;   - is not incomplete
;;   - is not a strike nor a spare
;;   - has the same first normal throw as the first normal throw in the prior frame
;;   - has the applied throw as the second normal throw
;;   - has both the first and second bonus throws unused
;;   - has a score equal to the sum of the first normal throws
;;;;;;;;;;

(assert (! (not (exists ((op Frame.ApplyThrowOp))
  (and
    (frame.apply-throw-op.validation op)
    (= empty-frame (prior_frame op))
    (< (points (throw op)) 10)
    (or
      (not (incomplete (post_frame op)))
      (not (= (throw op) (throw_1 (post_frame op))))
      (strike (post_frame op))
      (spare (post_frame op))
      (not (incomplete (throw_2 (post_frame op))))
      (not (incomplete (bonus_1 (post_frame op))))
      (not (unused (bonus_2 (post_frame op))))))
)) :named test-case.frame-ops.validation.scratch-throw-applied-to-empty-frame ))

(assert (! (not (exists ((op Frame.ApplyThrowOp))
  (and
    (frame.apply-throw-op.validation op)
    (not (incomplete (throw_1 (prior_frame op))))
    (< (+ (points (throw_1 (prior_frame op))) (points (throw op))) 10)
    (or
      (incomplete (post_frame op))
      (strike (post_frame op))
      (spare (post_frame op))
      (not (= (throw_1 (prior_frame op)) (throw_1 (post_frame op))))
      (not (= (throw op) (throw_2 (post_frame op))))
      (not (unused (bonus_1 (post_frame op))))
      (not (unused (bonus_2 (post_frame op))))))
)) :named test-case.frame-ops.validation.second-throw-creates-scratch-frame ))

(check-sat)