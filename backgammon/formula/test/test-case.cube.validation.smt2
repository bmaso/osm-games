#include "color.smt2"
#include "cube.smt2"

;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; Prove that
;; - There are no valid cubes with a negative doubling value
;; - There are no valid cubes that are unowned and in any state except `Active`

(assert (! (not (exists ((c Cube))
  (and
    (cube.validation c)
    (or
      (< (doubling_value c) 0)
      (and
        (= Neutral (owner c))
        (not (= Active (state c))))))
)) :named test-case.cube.validation))

(check-sat)
