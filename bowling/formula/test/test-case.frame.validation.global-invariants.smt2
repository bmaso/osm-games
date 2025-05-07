#include "frame.smt2"
;; || __FILE__ || __LINE__ ||

;;;;
;; Prove that:
;; * the empty frame is valid
;; * you cannot have a valid frame with any invalid throws
;; * there are no valid complete frames with any incomplete throws
;; * there are no valid frames where the sum of the throw points is not equal to the frame points
;;;;

(assert (! (frame.valid empty-frame)
  :named test-case.frame.valid.empty-frame-is-valid ))

(assert (! (not (exists ((f Frame))
  (and
    (frame.valid f)
    (or
      (not (throw.valid (throw_1 f)))
      (not (throw.valid (throw_2 f)))
      (not (throw.valid (bonus_1 f)))
      (not (throw.valid (bonus_2 f)))))
)) :named test-case.frame.validation.frame-validation-consist-with-all-throws ))

(assert (! (forall ((f Frame))
  (=>
    (and
      (frame.valid f)
      (frame.is-incomplete f))
    (or
      (incomplete (throw_1 f))
      (incomplete (throw_2 f))
      (incomplete (bonus_1 f))
      (incomplete (bonus_2 f))))
) :named test-case.frame.validation.frame-incompletion-consistent-with-throws ))

(assert (! (forall ((f Frame))
  (=>
    (frame.valid f)
    (=
      (frame.points f)
      (+
        (throw.points (throw_1 f))
        (throw.points (throw_2 f))
        (throw.points (bonus_1 f))
        (throw.points (bonus_2 f)))))
) :named test-case.frame.validation.frame-score-consistent-with-throws ))

(check-sat)
