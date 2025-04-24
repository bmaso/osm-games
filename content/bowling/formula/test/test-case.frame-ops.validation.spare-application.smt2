#include "frame-ops.smt2"
;; || __FILE__ || __LINE__ ||

;;;;
;; Prove that for every application of 3 valid throws, the first and second of which form a spare (which implies the
;; first is not a strike), to an empty frame yields a final op post frame where:
;; - the frame is complete
;; - throw_1 and throw_2 form a spare
;; - bonus_1 is neither incomplete nor unused
;; - bonus_2 unused
;;;;

(assert (forall ((op1 Frame.ApplyThrowOp) (op2 Frame.ApplyThrowOp) (op3 Frame.ApplyThrowOp))
  (=>
    (and
      (frame.apply-throw.valid op1)
      (frame.apply-throw.valid op2)
      (frame.apply-throw.valid op3)
      (= empty-frame (prior_frame op1))
      (= (post_frame op1) (prior_frame op2))
      (= (post_frame op2) (prior_frame op3))
      (not (= strike-throw (throw op1)))
      (= #b1111111111 (bvor (pins (throw op1)) (pins (throw op2)))))
    (and
      (not (frame.is-incomplete (post_frame op3)))
      (= #b1111111111 (bvor (pins (throw_1 (post_frame op3))) (pins (throw_2 (post_frame op3)))))
      (not (incomplete (bonus_1 (post_frame op3))))
      (not (unused (bonus_1 (post_frame op3))))
      (unused (bonus_2 (post_frame op3)))))))

(check-sat)
