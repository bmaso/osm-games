;; || __FILE__ || __LINE__ ||
#include "bowling.smt2"

;;;;;;;;;;
;; Verification tests for frame.apply-throw and frame.score
;; covering examplars of the following cases:
;; - single non-strike throw in a frame
;; - open frame (two throws without a mark)
;; - strike prior to bonus throws
;; - strike with bonus throws
;; - spare without bonus throw
;; - spare with bonus throw
;;;;;;;;;;

(push 1)
;;
;; adding a scratch throw to the empty frame
;;
(define-const one-throw-scratch-frame Frame
  (first (frame.apply-throw empty-frame (delivery 5 false)))
)

(assert (=
  one-throw-scratch-frame
  (frame (delivery 5 false) (as incomplete Throw) (as incomplete Throw) open)
))

(assert (= (frame.score one-throw-scratch-frame) (as incomplete Score)))


;;
;; adding a throw to make a scratch frame
;;
(define-const scratch-frame Frame
  (first (frame.apply-throw one-throw-scratch-frame (delivery 4 false)))
)

(assert (=
  scratch-frame
  (frame (delivery 5 false) (delivery 4 false) open open)
))

(assert (= (frame.score scratch-frame) (points 9)))


;;
;; strike on first throw to an empty frame
;;
(define-const one-throw-strike-frame Frame
  (first (frame.apply-throw empty-frame strike-throw))
)

(assert (=
  one-throw-strike-frame
  (frame strike-throw open (as incomplete Throw) (as incomplete Throw))
))

(assert (= (frame.score one-throw-strike-frame) (as incomplete Score)))


;;
;; first bonus throw after a strike
;;
(define-const two-throw-strike-frame Frame
  (first (frame.apply-throw one-throw-strike-frame (delivery 8 false)))
)

(assert (=
  two-throw-strike-frame
  (frame strike-throw open (delivery 8 false) (as incomplete Throw))
))

(assert (= (frame.score two-throw-strike-frame) (as incomplete Score)))


;;
;; second bonus throw after a strike
;;
(define-const strike-frame Frame
  (first (frame.apply-throw two-throw-strike-frame strike-throw))
)

(assert (=
  strike-frame
  (frame strike-throw open (delivery 8 false) strike-throw)
))

(assert (= (frame.score strike-frame) (points 28)))


;;
;; spare on second throw to an empty frame
;;
(define-const two-throw-spare-frame Frame
  (first (frame.apply-throw one-throw-scratch-frame (delivery 5 false)))
)

(assert (=
  two-throw-spare-frame
  (frame (delivery 5 false) (delivery 5 false) (as incomplete Throw) open)
))

(assert (= (frame.score two-throw-spare-frame) (as incomplete Score)))


;;
;; bonus throw after a spare
;;
(define-const spare-frame Frame
  (first (frame.apply-throw two-throw-spare-frame foul))
)

(assert (=
  spare-frame
  (frame (delivery 5 false) (delivery 5 false) foul open)
))

(assert (= (frame.score spare-frame) (points 10)))

;;;;
;; Single foul
;;
(define-const one-foul-frame-pair (Pair Frame Bool)
  (frame.apply-throw empty-frame foul)
)

(assert (= one-foul-frame-pair (pair (frame foul (as incomplete Throw) (as incomplete Throw) open) false)))

;(assert (= (frame.score (first (one-foul-frame-pair))) (as incomplete Score)))

(echo "Frame function tests")
(check-sat)

(get-value (one-foul-frame-pair))

(pop 1)
