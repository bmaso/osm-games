#include "game.smt2"
;; || __FILE__ || __LINE__ ||

;;;;
;; Prove that:
;; * there are no valid games where a strike frame's first bonus throw isn't equal to the next frame's first normal throw
;; * there are no valid games where a spare frame's first bonus throw isn't equal to the next frame's first normal throw
;; * there are no valid games where two sequential frames (X0 and X1) are strikes, and where X0's second bonus throw isn't
;;   equal to X1's first bonus throw
;; * there are no valid games where a strike frame (X) is followed by a non-strike frame (X1), and where X's second bonus throw isn't
;;   equal to X1's second normal throw
;;;;

;; Convenience function defining a frame that is a strike. Only applies to valid frames.

(define-fun frame.is-strike ((f Frame)) Bool
  (= #b1111111111 (pins (throw_1 f))))

;; Convenience function defining a frame that is a spare (and not a strike. Only applies to valid frames.

(define-fun frame.is-spare ((f Frame)) Bool
  (and
    (not (= #b1111111111 (pins (throw_1 f))))
    (= #b1111111111 (bvor (pins (throw_1 f)) (pins (throw_2 f))))))


(assert (! (not (exists ((g Game))
  (and
    (game.valid g)
    (or
      (and (frame.is-strike (frame_1 g)) (not (= (bonus_1 (frame_1 g)) (throw_1 (frame_2 g)))))
      (and (frame.is-strike (frame_2 g)) (not (= (bonus_1 (frame_2 g)) (throw_1 (frame_3 g)))))
      (and (frame.is-strike (frame_3 g)) (not (= (bonus_1 (frame_3 g)) (throw_1 (frame_4 g)))))
      (and (frame.is-strike (frame_4 g)) (not (= (bonus_1 (frame_4 g)) (throw_1 (frame_5 g)))))
      (and (frame.is-strike (frame_5 g)) (not (= (bonus_1 (frame_5 g)) (throw_1 (frame_6 g)))))
      (and (frame.is-strike (frame_6 g)) (not (= (bonus_1 (frame_6 g)) (throw_1 (frame_7 g)))))
      (and (frame.is-strike (frame_7 g)) (not (= (bonus_1 (frame_7 g)) (throw_1 (frame_8 g)))))
      (and (frame.is-strike (frame_8 g)) (not (= (bonus_1 (frame_8 g)) (throw_1 (frame_9 g)))))
      (and (frame.is-strike (frame_9 g)) (not (= (bonus_1 (frame_9 g)) (throw_1 (frame_10 g)))))))
)) :named test-case.game.validation.strike-frame-first-bonus-throw))

(assert (! (not (exists ((g Game))
  (and
    (game.valid g)
    (or
      (and (frame.is-spare (frame_1 g)) (not (= (bonus_1 (frame_1 g)) (throw_1 (frame_2 g)))))
      (and (frame.is-spare (frame_2 g)) (not (= (bonus_1 (frame_2 g)) (throw_1 (frame_3 g)))))
      (and (frame.is-spare (frame_3 g)) (not (= (bonus_1 (frame_3 g)) (throw_1 (frame_4 g)))))
      (and (frame.is-spare (frame_4 g)) (not (= (bonus_1 (frame_4 g)) (throw_1 (frame_5 g)))))
      (and (frame.is-spare (frame_5 g)) (not (= (bonus_1 (frame_5 g)) (throw_1 (frame_6 g)))))
      (and (frame.is-spare (frame_6 g)) (not (= (bonus_1 (frame_6 g)) (throw_1 (frame_7 g)))))
      (and (frame.is-spare (frame_7 g)) (not (= (bonus_1 (frame_7 g)) (throw_1 (frame_8 g)))))
      (and (frame.is-spare (frame_8 g)) (not (= (bonus_1 (frame_8 g)) (throw_1 (frame_9 g)))))
      (and (frame.is-spare (frame_9 g)) (not (= (bonus_1 (frame_9 g)) (throw_1 (frame_10 g)))))))
)) :named test-case.game.validation.spare-frame-first-bonus-throw))

(assert (! (not (exists ((g Game))
  (and
    (game.valid g)
    (or
      (and (frame.is-strike (frame_1 g)) (frame.is-strike (frame_2 g))  (not (= (bonus_2 (frame_1 g)) (bonus_1 (frame_2 g)))))
      (and (frame.is-strike (frame_2 g)) (frame.is-strike (frame_3 g))  (not (= (bonus_2 (frame_2 g)) (bonus_1 (frame_3 g)))))
      (and (frame.is-strike (frame_3 g)) (frame.is-strike (frame_4 g))  (not (= (bonus_2 (frame_3 g)) (bonus_1 (frame_4 g)))))
      (and (frame.is-strike (frame_4 g)) (frame.is-strike (frame_5 g))  (not (= (bonus_2 (frame_4 g)) (bonus_1 (frame_5 g)))))
      (and (frame.is-strike (frame_5 g)) (frame.is-strike (frame_6 g))  (not (= (bonus_2 (frame_5 g)) (bonus_1 (frame_6 g)))))
      (and (frame.is-strike (frame_6 g)) (frame.is-strike (frame_7 g))  (not (= (bonus_2 (frame_6 g)) (bonus_1 (frame_7 g)))))
      (and (frame.is-strike (frame_7 g)) (frame.is-strike (frame_8 g))  (not (= (bonus_2 (frame_7 g)) (bonus_1 (frame_8 g)))))
      (and (frame.is-strike (frame_8 g)) (frame.is-strike (frame_9 g))  (not (= (bonus_2 (frame_8 g)) (bonus_1 (frame_9 g)))))
      (and (frame.is-strike (frame_9 g)) (frame.is-strike (frame_10 g)) (not (= (bonus_2 (frame_9 g)) (bonus_1 (frame_10 g)))))))
)) :named test-case.game.validation.strike-then-strike-frame-second-bonus-throw))

(assert (! (not (exists ((g Game))
  (and
    (game.valid g)
    (or
      (and
        (frame.is-strike (frame_1 g))
        (not (frame.is-strike (frame_2 g)))
        (not (= (bonus_2 (frame_1 g)) (throw_2 (frame_2 g)))))
      (and
        (frame.is-strike (frame_2 g))
        (not (frame.is-strike (frame_3 g)))
        (not (= (bonus_2 (frame_2 g)) (throw_2 (frame_3 g)))))
      (and
        (frame.is-strike (frame_3 g))
        (not (frame.is-strike (frame_4 g)))
        (not (= (bonus_2 (frame_3 g)) (throw_2 (frame_4 g)))))
      (and
        (frame.is-strike (frame_4 g))
        (not (frame.is-strike (frame_5 g)))
        (not (= (bonus_2 (frame_4 g)) (throw_2 (frame_5 g)))))
      (and
        (frame.is-strike (frame_5 g))
        (not (frame.is-strike (frame_6 g)))
        (not (= (bonus_2 (frame_5 g)) (throw_2 (frame_6 g)))))
      (and
        (frame.is-strike (frame_6 g))
        (not (frame.is-strike (frame_7 g)))
        (not (= (bonus_2 (frame_6 g)) (throw_2 (frame_7 g)))))
      (and
        (frame.is-strike (frame_7 g))
        (not (frame.is-strike (frame_8 g)))
        (not (= (bonus_2 (frame_7 g)) (throw_2 (frame_8 g)))))
      (and
        (frame.is-strike (frame_8 g))
        (not (frame.is-strike (frame_9 g)))
        (not (= (bonus_2 (frame_8 g)) (throw_2 (frame_9 g)))))
      (and
        (frame.is-strike (frame_9 g))
        (not (frame.is-strike (frame_10 g)))
        (not (= (bonus_2 (frame_9 g)) (throw_2 (frame_10 g)))))))
)) :named test-case.game.validation.strike-then-not-strike-frame-second-bonus-throw))

(check-sat)
