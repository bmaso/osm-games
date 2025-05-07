#include "frame-ops.smt2"
;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; Witness examples of throws applied to frames:
;; - applying a single throw to an empty frame
;; - applying 2 throws to an empty frame to create a scratch
;; - applying 3 throws to an empty frame yielding a spare + a bonus throw
;; - applying 3 throws to an empty frame yielding a strike + 2 bonus throws
;;;;;;;;;;

(declare-const op.apply-scratch Frame.ApplyThrowOp)
(assert
  (=>
    (and
      (frame.apply-throw.valid op.apply-scratch)
      (= empty-frame (prior_frame op.apply-scratch))
      (= (throw #b1010101010 false false false) (throw op.apply-scratch)))
    (and
      (= (throw_1 (post_frame op.apply-scratch)) (throw #b1010101010 false false false))
      (= (throw_2 (post_frame op.apply-scratch)) incomplete-throw)
      (incomplete (bonus_1 (post_frame op.apply-scratch)))
      (unused (bonus_2 (post_frame op.apply-scratch))))))

(check-sat)

(declare-const op.apply-scratch-1 Frame.ApplyThrowOp)
(declare-const op.apply-scratch-2 Frame.ApplyThrowOp)
(assert
  (=>
    (and
      (frame.apply-throw.valid op.apply-scratch-1)
      (frame.apply-throw.valid op.apply-scratch-2)
      (= empty-frame (prior_frame op.apply-scratch-1))
      (= (post_frame op.apply-scratch-1) (prior_frame op.apply-scratch-2))
      (= (throw #b1010101010 false false false) (throw op.apply-scratch-1))
      (= (throw #b0000000101 false false false) (throw op.apply-scratch-2)))
    (and
      (= (throw_1 (post_frame op.apply-scratch-2)) (throw #b1010101010 false false false))
      (= (throw_2 (post_frame op.apply-scratch-2)) (throw #b0000000101 false false false))
      (unused (bonus_1 (post_frame op.apply-scratch-2)))
      (unused (bonus_2 (post_frame op.apply-scratch-2)))
      (= 7 (frame.points (post_frame op.apply-scratch-2))))))

(check-sat)

(declare-const op.apply-spare-1 Frame.ApplyThrowOp)
(declare-const op.apply-spare-2 Frame.ApplyThrowOp)
(declare-const op.apply-spare-3 Frame.ApplyThrowOp)
(assert
  (=>
    (and
      (frame.apply-throw.valid op.apply-spare-1)
      (frame.apply-throw.valid op.apply-spare-2)
      (frame.apply-throw.valid op.apply-spare-3)
      (= empty-frame (prior_frame op.apply-spare-1))
      (= (post_frame op.apply-spare-1) (prior_frame op.apply-spare-2))
      (= (post_frame op.apply-spare-2) (prior_frame op.apply-spare-3))
      (= (throw #b1010101010 false false false) (throw op.apply-spare-1))
      (= (throw #b0101010101 false false false) (throw op.apply-spare-2))
      (= (throw #b0000011111 false false false) (throw op.apply-spare-3)))
    (and
      (= (throw_1 (post_frame op.apply-spare-3)) (throw #b1010101010 false false false))
      (= (throw_2 (post_frame op.apply-spare-3)) (throw #b0101010101 false false false))
      (= (bonus_1 (post_frame op.apply-spare-3)) (throw #b0000011111 false false false))
      (unused (bonus_2 (post_frame op.apply-spare-3)))
      (= 15 (frame.points (post_frame op.apply-spare-3))))))

(check-sat)

(declare-const op.apply-strike-1 Frame.ApplyThrowOp)
(declare-const op.apply-strike-2 Frame.ApplyThrowOp)
(declare-const op.apply-strike-3 Frame.ApplyThrowOp)
(assert
  (=>
    (and
      (frame.apply-throw.valid op.apply-strike-1)
      (frame.apply-throw.valid op.apply-strike-2)
      (frame.apply-throw.valid op.apply-strike-3)
      (= empty-frame (prior_frame op.apply-strike-1))
      (= (post_frame op.apply-strike-1) (prior_frame op.apply-strike-2))
      (= (post_frame op.apply-strike-2) (prior_frame op.apply-strike-3))
      (= (throw #b1111111111 false false false) (throw op.apply-strike-1))
      (= (throw #b1110000000 false false false) (throw op.apply-strike-2))
      (= (throw #b0000000111 false false false) (throw op.apply-strike-3)))
    (and
      (= (throw_1 (post_frame op.apply-strike-3)) strike-throw)
      (= (throw_2 (post_frame op.apply-strike-3)) unused-throw)
      (= (bonus_1 (post_frame op.apply-strike-3)) (throw #b1110000000 false false false))
      (= (bonus_2 (post_frame op.apply-strike-3)) (throw #b0000000111 false false false))
      (= 16 (frame.points (post_frame op.apply-strike-3))))))

(check-sat)


