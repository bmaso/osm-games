#include "color.smt2"
#include "cube.smt2"

;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; Prove that
;; - There are no valid cubes with a negative doubling value
;; - There are no valid cubes that are unowned that aren't 0 in value

(assert (! (not (exists ((c DoublingCube))
  (and
    (cube.validation c)
    (or
      (< (log_value c) 0)
      (and
        (= Neutral (owner c))
        (not (= (log_value c) 0)))))
)) :named test-case.cube.validation ))

(check-sat)
