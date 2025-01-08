#include "frame.smt2"
;; || __FILE__ || __LINE__ ||

;;
;; Prove that:
;; * the empty frame is valid
;; * you cannot have a valid frame with any invalid throws
;; * there are no valid complete frames with any incomplete throws
;; * there are no valid complete frames without all throws complete
;; * there are no valid frames where the sum of the throw points is not equal to the frame points
;;

(assert (! (frame.validation empty-frame)
:named test-case.frame.validation.empty-frame-is-valid ))

(assert (! (not (exists ((f Frame))
  (and
    (frame.validation f)
    (or
      (not (throw.validation (throw_1 f)))
      (not (throw.validation (throw_2 f)))
      (not (throw.validation (bonus_1 f)))
      (not (throw.validation (bonus_2 f)))))
)) :named test-case.frame.validation.frame-validation-consist-with-all-throws ))

(assert (! (not (exists ((f Frame))
  (and
    (frame.validation f)
    (not (incomplete f))
    (or
      (incomplete (throw_1 f))
      (incomplete (throw_2 f))
      (incomplete (bonus_1 f))
      (incomplete (bonus_2 f))))
)) :named test-case.frame.validation.frame-incompletion-consistent-with-throws ))

(assert (! (not (exists ((f Frame))
  (and
    (frame.validation f)
    (incomplete f)
    (and
      (not (incomplete (throw_1 f)))
      (not (incomplete (throw_2 f)))
      (not (incomplete (bonus_1 f)))
      (not (incomplete (bonus_2 f)))))
)) :named test-case.frame.validation.frame-completion-consistent-with-throws))

(assert (! (not (exists ((f Frame))
  (and
    (frame.validation f)
    (not (=
      (points f)
      (+
        (points (throw_1 f))
        (points (throw_2 f))
        (points (bonus_1 f))
        (points (bonus_2 f))))))
)) :named test-case.frame.validation.frame-score-consistent-with-throws ))

(check-sat)
