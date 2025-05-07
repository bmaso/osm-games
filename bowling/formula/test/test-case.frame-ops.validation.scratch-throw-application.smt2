#include "frame-ops.smt2"
;; || __FILE__ || __LINE__ ||

;;;;
;; Prove that a valid application of a scratch throw (not unused or incomplete and not a strike) to an empty frame
;; yields a frame that always:
;; - is incomplete
;; - has the first throw assigned the applied throw
;; - has the second normal throw and first bonus throw incomplete
;; - has the second bonus throw unused
;;;;

(assert (forall ((op Frame.ApplyThrowOp))
  (=>
    (and
      (frame.apply-throw.valid op)
      (= empty-frame (prior_frame op))
      (not (incomplete (throw op)))
      (not (unused (throw op)))
      (not (= strike-throw (throw op))))
    (and
      (frame.is-incomplete (post_frame op))
      (= (throw op) (throw_1 (post_frame op)))
      (incomplete (throw_2 (post_frame op)))
      (incomplete (bonus_1 (post_frame op)))
      (unused (bonus_2 (post_frame op)))))))

(check-sat)

;;;;
;; Prove that a valid application of 2 throws to an empty frame forming neither a strike nor a spare
;; yields a final post frame that always:
;; - is not incomplete
;; - has the first applied throw as the first normal throw
;; - has the second applied throw as the second normal throw
;; - has both the first and second bonus throws unused
;; - has a point value equal to the sum of the point values of the 2 applied throws
;;;;

(assert (forall ((op1 Frame.ApplyThrowOp) (op2 Frame.ApplyThrowOp))
  (=>
    (and
      (frame.apply-throw.valid op1)
      (frame.apply-throw.valid op2)
      (= empty-frame (prior_frame op1))
      (= (post_frame op1) (prior_frame op2))
      (not (= #b1111111111 (bvor (pins (throw op1)) (pins (throw op2))))))  ; <-- throws do not form a mark (strike or spare)
    (and
      (not (frame.is-incomplete (post_frame op2)))
      (= (throw op1) (throw_1 (post_frame op2)))
      (= (throw op2) (throw_2 (post_frame op2)))
      (unused (bonus_1 (post_frame op2)))
      (unused (bonus_2 (post_frame op2)))
      (= (frame.points (post_frame op2)) (+ (throw.points (throw op1)) (throw.points (throw op2))))))))

(check-sat)