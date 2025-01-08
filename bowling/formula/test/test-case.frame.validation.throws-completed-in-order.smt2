#include "frame.smt2"
;; || __FILE__ || __LINE__ ||

;;
;; Prove that throws must be completed in-order:
;; * there are no valid frames where the second throw is complete and the first throw is not complete
;; * there are no valid frames where the first bonus throw is complete and the second regular throw is not
;; * there are no valid strike frames where the second bonus throw is complete and the first bonus throw is not complete
;; * there are no valid non-strike frames where the second bonus throw is incomplete and the first regular throw is incomplete

(assert (! (not (exists ((f Frame))
  (and
    (frame.validation f)
    (or
      (and (not (incomplete (throw_2 f))) (incomplete (throw_1 f)))
      (and (not (incomplete (bonus_1 f))) (incomplete (throw_2 f)))
      (and (not (incomplete (bonus_2 f)))
        (or
          (and
            (= strike-throw (throw_1 f))
            (incomplete (bonus_1 f)))
          (and
            (not (= strike-throw (throw_1 f)))
            (incomplete (throw_1 f)))))))
)) :named test-case.frame.validation.throws-completed-in-order ))

(check-sat)
