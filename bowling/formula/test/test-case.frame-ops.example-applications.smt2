#include "frame-ops.smt2"
;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; Witness examples of throws applied to frames:
;; - applying a strike to an empty frame
;; - applying a scratch to an empty frame
;; - applying a seqeunce of two throws to a frame yielding a scratch 
;; - applying a sequence of two throws to a frame yielding a spare
;;;;;;;;;;

(declare-const op.apply-strike Frame.ApplyThrowOp)
(assert
  (=>
    (and
      (frame.apply-throw-op.validation op.apply-strike)
      (= empty-frame (prior_frame op.apply-strike))
      (= strike-throw (throw op.apply-strike)))
    (and
      (= (throw_1 (post_frame op.apply-strike)) strike-throw)
      (= (throw_2 (post_frame op.apply-strike)) unused-throw)
      (incomplete (bonus_1 (post_frame op.apply-strike)))
      (incomplete (bonus_2 (post_frame op.apply-strike)))))
)

(check-sat)

(declare-const op.apply-scratch Frame.ApplyThrowOp)
(assert
  (=>
    (and
      (frame.apply-throw-op.validation op.apply-scratch)
      (= empty-frame (prior_frame op.apply-scratch))
      (= (throw 5 false false false false) (throw op.apply-strike)))
    (and
      (= (throw_1 (post_frame op.apply-strike)) (throw 5 false false false false))
      (= (throw_2 (post_frame op.apply-strike)) incomplete-throw)
      (incomplete (bonus_1 (post_frame op.apply-strike)))
      (unused (bonus_2 (post_frame op.apply-strike)))))
)

(check-sat)

(declare-const op.apply-scratch-1 Frame.ApplyThrowOp)
(declare-const op.apply-scratch-2 Frame.ApplyThrowOp)
(assert
  (=>
    (and
      (frame.apply-throw-op.validation op.apply-scratch-1)
      (frame.apply-throw-op.validation op.apply-scratch-2)
      (= empty-frame (prior_frame op.apply-scratch-1))
      (= (post_frame op.apply-scratch-1) (prior_frame op.apply-scratch-2))
      (= (throw 5 false false false false) (throw op.apply-scratch-1))
      (= (throw 2 false false false false) (throw op.apply-scratch-2)))
    (and
      (= (throw_1 (post_frame op.apply-scratch-2)) (throw 5 false false false false))
      (= (throw_2 (post_frame op.apply-scratch-2)) (throw 2 false false false false))
      (unused (bonus_1 (post_frame op.apply-scratch-2)))
      (unused (bonus_2 (post_frame op.apply-scratch-2)))
      (not (strike (post_frame op.apply-scratch-2)))
      (not (spare (post_frame op.apply-scratch-2)))))
)

(check-sat)

(declare-const op.apply-spare-1 Frame.ApplyThrowOp)
(declare-const op.apply-spare-2 Frame.ApplyThrowOp)
(assert
  (=>
    (and
      (frame.apply-throw-op.validation op.apply-spare-1)
      (frame.apply-throw-op.validation op.apply-spare-2)
      (= empty-frame (prior_frame op.apply-spare-1))
      (= (post_frame op.apply-spare-1) (prior_frame op.apply-spare-2))
      (= (throw 5 false false false false) (throw op.apply-spare-1))
      (= (throw 5 false false false false) (throw op.apply-spare-2)))
    (and
      (= (throw_1 (post_frame op.apply-spare-2)) (throw 5 false false false false))
      (= (throw_2 (post_frame op.apply-spare-2)) (throw 5 false false false false))
      (incomplete (bonus_1 (post_frame op.apply-spare-2)))
      (unused (bonus_2 (post_frame op.apply-spare-2)))
      (not (strike (post_frame op.apply-spare-2)))
      (spare (post_frame op.apply-spare-2))))
)

(check-sat)
