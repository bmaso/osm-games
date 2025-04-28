#include "throw.smt2"

#ifndef BOWLING_FRAME_DOMAIN
#define BOWLING_FRAME_DOMAIN

; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; A frame is comprised of 2 throws and 2 bonus throws, and an `incomplete` field.
;;
;; There are computation functions to determine if a frame is a strike frame or a spare frame, and
;; the number of points scored in a frame.
;;;;;;;;;;

(declare-datatype Frame (
  (frame
    (throw_1 Throw)
    (throw_2 Throw)
    (bonus_1 Throw)
    (bonus_2 Throw))
))

;;;;
;; `empty-frame` is a convenience constant representing the state of a frame without any throws applied to it.
;;;;

(define-const empty-frame Frame
  (frame
    incomplete-throw      ; throw_1
    incomplete-throw      ; throw_2
    incomplete-throw      ; bonus_1
    incomplete-throw))    ; bonus_2

;; Convenience function defining a frame that is a strike. Only applies to valid frames.

(define-fun frame.is-strike ((f Frame)) Bool
  (= #b1111111111 (pins (throw_1 f))))

;; Convenience function defining a frame that is a spare (and not a strike). Only applies to valid frames.

(define-fun frame.is-spare ((f Frame)) Bool
  (and
    (not (= #b1111111111 (pins (throw_1 f))))
    (= #b1111111111 (bvor (pins (throw_1 f)) (pins (throw_2 f))))))

;;;;
;; Validation rules for frames:
;; - the member throws must be valid
;; - the pins knocked down by throws must be consistent
;;   - the same pin can't be knocked down in the first and second normal throws
;;   - unless the first bonus throw is a strike, the same pin can't be knocked down in the
;;     first and second bonus throw
;; - one of the following rules must be met, which ensure consistency for scratch, strike, and spare frames
;;   - all 4 throws in the frame are incomplete
;;   - throw 1 is a strike and throw 2 is unused; both bonus throws are not unused
;;   - throw 1 is a not strike and throw 2 is incomplete; bonus 1 and bonus 2 are also incomplete
;;   - throw 1 is not a strike, throw 2 is not incomplete and together throw 1 and throw 2 form a spare; bonus 1
;;     is not unused and bonus 2 is unused
;;   - throw 1 is not a strike and together throw 1 and throw 2 form a scratch (not a spare); bonus 1
;;     and bonus 2 are both unused 
;; - the throws must be in-order -- later throws cannot be completed before earlier throws within the same frame
;;   - if second regular throw is complete then the first regular throw is also complete
;;   - if the first bonus throw is complete the the second regular throw is also complete
;;   - if the second bonus throw is complete then either
;;     - the first regular throw is complete and not a strike
;;     - OR the first regular throw is a strike and the first bonus throw is also complete
;;;;

(define-fun frame.valid.member-throws-valid ((f Frame)) Bool
  (and
    (throw.valid (throw_1 f))
    (throw.valid (throw_2 f))
    (throw.valid (bonus_1 f))
    (throw.valid (bonus_2 f))))

;; The pins knocked down by the 1st and 2nd normal throws must be distinct -- you can't knock the
;; same pin down twice. Unless the first bonus throw is a strike, same restriction exists for the
;; 1st and 2nd bonus throws as well.
(define-fun frame.valid.throw-pins-consistency ((f Frame)) Bool
  (and
    (= #b0000000000 (bvand (pins (throw_1 f)) (pins (throw_2 f))))
    (or
      (= #b1111111111 (pins (bonus_1 f)))
      (= #b0000000000 (bvand (pins (bonus_1 f)) (pins (bonus_2 f)))))))

;; this rule ensures that the consistency between throws for scratch, spare, and strike frames. There are 5
;; valid cases; in all cases throw 1 cannot be unused:
;; - all 4 throws in the frame are incomplete
;; - throw 1 is a strike and throw 2 is unused; both bonus throws are not unused
;; - throw 1 is a not strike and throw 2 is incomplete; bonus 1 and bonus 2 are also incomplete
;; - throw 1 is not a strike, throw 2 is not incomplete and together throw 1 and throw 2 form a spare; bonus 1
;;   is not unused and bonus 2 is unused
;; - throw 1 is not a strike and together throw 1 and throw 2 form a scratch (not a spare); bonus 1
;;   and bonus 2 are both unused

(define-fun frame.valid.throw-mark-consistency ((f Frame)) Bool
  (and
    (or
      (and
        (incomplete (throw_1 f))
        (incomplete (throw_2 f))
        (incomplete (bonus_1 f))
        (incomplete (bonus_2 f)))
      (and
        (= #b1111111111 (pins (throw_1 f)))
        (unused (throw_2 f))
        (not (unused (bonus_1 f)))
        (not (unused (bonus_2 f))))
      (and
        (not (incomplete (throw_1 f)))
        (not (unused (throw_1 f)))
        (not (= #b1111111111 (pins (throw_1 f))))
        (incomplete (throw_2 f))
        (incomplete (bonus_1 f))
        (unused (bonus_2 f)))
      (and
        (not (incomplete (throw_1 f)))
        (not (unused (throw_1 f)))
        (not (= #b1111111111 (pins (throw_1 f))))
        (not (incomplete (throw_2 f)))
        (not (unused (throw_2 f)))
        (= #b1111111111 (bvor (pins (throw_1 f)) (pins (throw_2 f))))
        (not (unused (bonus_1 f)))
        (unused (bonus_2 f)))
      (and
        (not (incomplete (throw_1 f)))
        (not (unused (throw_1 f)))
        (not (= #b1111111111 (pins (throw_1 f))))
        (not (incomplete (throw_2 f)))
        (not (unused (throw_2 f)))
        (not (= #b1111111111 (bvor (pins (throw_1 f)) (pins (throw_2 f)))))
        (unused (bonus_1 f))
        (unused (bonus_2 f))))))

(define-fun frame.valid.throws-in-order ((f Frame)) Bool
  (and
    (=> (not (incomplete (throw_2 f))) (not (incomplete (throw_1 f))))
    (=> (not (incomplete (bonus_1 f))) (not (incomplete (throw_2 f))))
    (=> (not (incomplete (bonus_2 f)))
      (or
        (and
          (not (= #b1111111111 (pins (throw_1 f))))
          (not (incomplete (throw_1 f))))
        (and
          (= #b1111111111 (pins (throw_1 f)))
          (not (incomplete (bonus_1 f))))))))

(define-fun frame.valid ((f Frame)) Bool
  (and
    (frame.valid.member-throws-valid f)
    (frame.valid.throw-pins-consistency f)
    (frame.valid.throw-mark-consistency f)
    (frame.valid.throws-in-order f)))

;;;;
;; A frame is incomplete if any of its throws are incomplete
;;;;

(define-fun frame.is-incomplete ((f Frame)) Bool
  (or
    (incomplete (throw_1 f))
    (incomplete (throw_2 f))
    (incomplete (bonus_1 f))
    (incomplete (bonus_2 f))))

;;;;
;; A Frame's point value is just the sum of the Frame's throw's point values.
;;;;

(define-fun frame.points ((f Frame)) Int
  (+
    (throw.points (throw_1 f))
    (throw.points (throw_2 f))
    (throw.points (bonus_1 f))
    (throw.points (bonus_2 f))))

#endif