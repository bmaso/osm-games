#include "frame-ops.smt2"
;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; Prove that:
;; - A valid application of a strike throw to an empty frame yields a frame that always
;;   - is incomplete
;;   - is a strike frame
;;;;;;;;;;

(assert (! (not (exists ((op Frame.ApplyThrowOp))
  (and
    (frame.apply-throw-op.validation op)
    (= empty-frame (prior_frame op))
    (= strike-throw (throw op))
    (or
      (not (incomplete (post_frame op)))
      (not (strike (post_frame op)))))
)) :named test-case.frame-ops.validation.strike-application))

(check-sat)
