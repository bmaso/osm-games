#include "frame.smt2"
;; || __FILE__ || __LINE__ ||

;;
;; Prove that:
;; * There are no valid scratch frames where
;; * the first throw is a strike
;; * the first two throws add up to 10
;; * either of the first two throws are unused
;; * either the first throw is complete AND the second bonus throw is not unused, or the first throw
;;   is incomplete AND the second bonus throw is not incomplete
;; * either the second throw is complete AND the first bonus throw is not unused, or the second throw
;;   is incomplete AND the first bonus throw is not incomplete
;;

(assert (! (not (exists ((f Frame))
  (and
    (frame.validation f)
    (not (strike f))
    (not (spare f))
    (or
      (= strike-throw (throw_1 f))
      (= 10 (+ (points (throw_1 f)) (points (throw_2 f))))
      (unused (throw_1 f))
      (unused (throw_2 f))
      (or
        (and
          (not (incomplete (throw_1 f)))
          (not (unused (bonus_2 f))))
        (and
          (incomplete (throw_1 f))
          (not (incomplete (bonus_2 f)))))
      (or
        (and
          (not (incomplete (throw_2 f)))
          (not (unused (bonus_1 f))))
        (and
          (incomplete (throw_2 f))
          (not (incomplete (bonus_1 f)))))))
)) :named test-case.frame.validation.scratch-invariants ))

(check-sat)
