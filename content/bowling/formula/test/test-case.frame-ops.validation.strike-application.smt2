#include "frame-ops.smt2"
;; || __FILE__ || __LINE__ ||

;;;;
;; Prove that every application of a strike throw to the empty frame yields a final post frame that always:
;; - is incomplete
;; - has throw_2 unused
;; - bonus_1 is incomplete
;; - bonus_2 is incomplete
;;;;

(assert (forall ((op1 Frame.ApplyThrowOp))
  (=>
    (and
      (= empty-frame (prior_frame op1))
      (= strike-throw (throw op1)))
    (and
      (not (frame.is-incomplete (post_frame op3)))
      (unused (throw_2 (post_frame op3)))
      (incomplete (bonus_1 (post_frame op3)))
      (incomplete (bonus_2 (post_frame op3)))))))

(check-sat)

;;;;
;; Prove that for every application of a strike throw and another throw to the empty frame yields a final post frame
;; that always:
;; - is incomplete
;; - has throw_2 unused
;; - bonus_1 is neither incomplete nor unused
;; - bonus_2 is incomplete
;;;;

(assert (forall ((op1 Frame.ApplyThrowOp) (op2 Frame.ApplyThrowOp))
  (=>
    (and
      (frame.apply-throw.valid op1)
      (frame.apply-throw.valid op2)
      (= empty-frame (prior_frame op1))
      (= (post_frame op1) (prior_frame op2))
      (= strike-throw (throw op1)))
    (and
      (not (frame.is-incomplete (post_frame op3)))
      (unused (throw_2 (post_frame op3)))
      (not (incomplete (bonus_1 (post_frame op3))))
      (not (unused (bonus_1 (post_frame op3))))
      (incomplete (bonus_2 (post_frame op3)))))))

(check-sat)

;;;;
;; Prove that for every application of 3 valid throws, the first of which is a strike throw, to an empty frame yields a
;; final op post frame that always:
;; - is complete
;; - has throw_2 unused
;; - bonus_1 is neither incomplete nor unused
;; - bonus_2 is neither incomplete nor unused
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
      (= strike-throw (throw op1)))
    (and
      (not (frame.is-incomplete (post_frame op3)))
      (unused (throw_2 (post_frame op3)))
      (not (incomplete (bonus_1 (post_frame op3))))
      (not (unused (bonus_1 (post_frame op3))))
      (not (incomplete (bonus_2 (post_frame op3))))
      (not (unused (bonus_2 (post_frame op3))))))))

(check-sat)
