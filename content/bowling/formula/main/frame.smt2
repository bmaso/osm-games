#include "throw.smt2"

#ifndef BOWLING_FRAME_DOMAIN
#define BOWLING_FRAME_DOMAIN

; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; A frame is comprised of 2 throws and 2 bonus throws. The frame state includes `strike` and `spare` flags, a
;; an `incomplete` field, and a function for computing frame points. In a _valid_ frame, the consistency between
;; the mark flags, the frame `incomplete` flag, and the individual throw values is maintained by the
;; definition of the `frame.valid` function.
;;;;;;;;;;

(declare-datatype Frame (
  (frame
    (throw_1 Throw)
    (throw_2 Throw)
    (bonus_1 Throw)
    (bonus_2 Throw)
    (strike Bool)
    (spare Bool)
    (points Int)
    (incomplete Bool))
))

;;;;
;; `empty-frame` is a convenience constant representing the state of a frame without any throws applied to it. During a game
;; in progress, any future frame is represented by this value.
;;;;

(define-const empty-frame Frame
  (frame
    incomplete-throw      ; throw_1
    incomplete-throw      ; throw_2
    incomplete-throw      ; bonus_1
    incomplete-throw      ; bonus_2
    false                 ; strike flag
    false                 ; spare flag
    0                     ; points
    true)                 ; incomplete flag
)

;;
;; convenience function: indicates whether or not at least one of the frame's regular throws is incomplete
;;
(define-fun frame.incomplete-regular-throws ((f Frame)) Bool
  (or
    (incomplete (throw_1 f))
    (incomplete (throw_2 f))))

;;;;
;; Validation rules for frames:
;; - the member throws must be valid
;; - the frame is incomplete iff any of the the throws are incomplete
;; - the frame's score is consistent with the sum of the throw scores iff the frame is complete
;; - the throws must be in-order -- later throws cannot be completed before earlier throws within the same frame
;;   - if second regular throw is complete then the first regular throw is also complete
;;   - if the first bonus throw is complete the the second regular throw is also complete
;;   - if the second bonus throw is complete then either
;;     - the first regular throw is complete and not a strike
;;     - OR the first regular throw is a strike and the first bonus throw is also complete
;; - one of the following rules as well
;;   - the frame is a valid strike frame
;;     - the strike flag is true
;;     - the spare flag is false
;;     - the first throw is a strike
;;     - the second throw is unused
;;     - the first and second bonus throws are not unused
;;   - the frame is a valid spare frame
;;     - the strike flag is false and the spare flag is true
;;     - the first and second throws are not incomplete, and the first throw is not a strike throw
;;     - the sum of the first and second throws is 10
;;     - the second regular throw and the first bonus throw are not unused
;;     - the second bonus throw is unused
;;   - the frame is a valid scratch frame
;;     - the strike and spare flags are false
;;     - the sum of the point values of the first and second throws is less than 10
;;     - the first and second throws are not unused
;;     - if first throw is incomplete, then the second bonus throw is incomplete, else the second bonus throw is unused
;;     - if the second throw is incomplete, then first bonus throw is incomplete, else the first bonus throw is unused
;;;;

(declare-fun frame.validation.member-throws-valid (Frame) Bool)
(assert (! (forall ((f Frame))
  (=
    (and
      (throw.validation (throw_1 f))
      (throw.validation (throw_2 f))
      (throw.validation (bonus_1 f))
      (throw.validation (bonus_2 f)))
    (frame.validation.member-throws-valid f))
) :named frame.validation.member-throws-valid))

(declare-fun frame.validation.frame-complete-consistent-with-throws (Frame) Bool)
(assert (! (forall ((f Frame))
  (=
    (=
      (incomplete f)
      (or
        (incomplete (throw_1 f))
        (incomplete (throw_2 f))
        (incomplete (bonus_1 f))
        (incomplete (bonus_2 f))))
    (frame.validation.frame-complete-consistent-with-throws f))
) :named frame.validation.frame-complete-consistent-with-throws))

(declare-fun frame.validation.score-consistent-with-throws (Frame) Bool)
(assert (! (forall ((f Frame))
  (=
    (=
      (points f)
      (+
        (points (throw_1 f))
        (points (throw_2 f))
        (points (bonus_1 f))
        (points (bonus_2 f))))
    (frame.validation.score-consistent-with-throws f))
) :named frame.validation.score-consistent-with-throws))

(declare-fun frame.validation.is-valid-strike-frame (Frame) Bool)
(assert (! (forall ((f Frame))
  (=
    (and
      (strike f)
      (not (spare f))
      (= strike-throw (throw_1 f))
      (unused (throw_2 f))
      (not (unused (bonus_1 f)))
      (not (unused (bonus_2 f))))
    (frame.validation.is-valid-strike-frame f))
) :named frame.validation.is-valid-strike-frame ))

(declare-fun frame.validation.throws-in-order (Frame) Bool)
(assert (! (forall ((f Frame))
  (=
    (and
      (=> (not (incomplete (throw_2 f))) (not (incomplete (throw_1 f))))
      (=> (not (incomplete (bonus_1 f))) (not (incomplete (throw_2 f))))
      (=> (not (incomplete (bonus_2 f)))
        (or
          (and
            (not (= strike-throw (throw_1 f)))
            (not (incomplete (throw_1 f))))
          (and
            (= strike-throw (throw_1 f))
            (not (incomplete (bonus_1 f)))))))
    (frame.validation.throws-in-order f))
) :named frame.validation.throws-in-order ))

(declare-fun frame.validation.is-valid-spare-frame (Frame) Bool)
(assert (! (forall ((f Frame))
  (=
    (and
      (not (strike f))
      (spare f)
      (not (incomplete (throw_1 f)))
      (not (= strike-throw (throw_1 f)))
      (not (incomplete (throw_2 f)))
      (= 10 (+ (points (throw_1 f)) (points (throw_2 f))))
      (not (unused (throw_2 f)))
      (not (unused (bonus_1 f)))
      (unused (bonus_2 f)))
    (frame.validation.is-valid-spare-frame f))
) :named frame.validation.is-valid-spare-frame ))

(declare-fun frame.validation.is-valid-scratch-frame (Frame) Bool)
(assert (! (forall ((f Frame))
  (=
    (and
      (not (strike f))
      (not (spare f))
      (< (+ (points (throw_1 f)) (points (throw_2 f))) 10)
      (not (unused (throw_1 f)))
      (not (unused (throw_2 f)))
      (ite (incomplete (throw_1 f)) (incomplete (bonus_2 f)) (unused (bonus_2 f)))
      (ite (incomplete (throw_2 f)) (incomplete (bonus_1 f)) (unused (bonus_1 f))))
    (frame.validation.is-valid-scratch-frame f))
) :named frame.validation.is-valid-scratch-frame))

(define-fun frame.validation ((f Frame)) Bool
  (and
    (frame.validation.member-throws-valid f)
    (frame.validation.frame-complete-consistent-with-throws f)
    (frame.validation.score-consistent-with-throws f)
    (frame.validation.throws-in-order f)
    (or
      (frame.validation.is-valid-strike-frame f)
      (frame.validation.is-valid-spare-frame f)
      (frame.validation.is-valid-scratch-frame f)))
)

#endif