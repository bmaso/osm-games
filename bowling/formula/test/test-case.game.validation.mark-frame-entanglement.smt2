#include "game.smt2"
;; || __FILE__ || __LINE__ ||

;;
;; Prove that:
;; * there are no valid games where a strike frame's first bonus throw isn't equal to the next frame's first normal throw
;; * there are no valid games where a spare frame's first bonus throw isn't equal to the next frame's first normal throw
;; * there are no valid games where two sequential frames (X0 and X1) are strikes, and where X0's second bonus throw isn't
;;   equal to X1's first bonus throw
;; * there are no valid games where a strike frame (X) is followed by a non-strike frame (X1), and where X's second bonus throw isn't
;;   equal to X1's second normal throw
;;

(assert (! (not (exists ((g Game))
  (and
    (game.validation g)
    (or
      (and (strike (frame_1 g)) (not (= (bonus_1 (frame_1 g)) (throw_1 (frame_2 g)))))
      (and (strike (frame_2 g)) (not (= (bonus_1 (frame_2 g)) (throw_1 (frame_3 g)))))
      (and (strike (frame_3 g)) (not (= (bonus_1 (frame_3 g)) (throw_1 (frame_4 g)))))
      (and (strike (frame_4 g)) (not (= (bonus_1 (frame_4 g)) (throw_1 (frame_5 g)))))
      (and (strike (frame_5 g)) (not (= (bonus_1 (frame_5 g)) (throw_1 (frame_6 g)))))
      (and (strike (frame_6 g)) (not (= (bonus_1 (frame_6 g)) (throw_1 (frame_7 g)))))
      (and (strike (frame_7 g)) (not (= (bonus_1 (frame_7 g)) (throw_1 (frame_8 g)))))
      (and (strike (frame_8 g)) (not (= (bonus_1 (frame_8 g)) (throw_1 (frame_9 g)))))
      (and (strike (frame_9 g)) (not (= (bonus_1 (frame_9 g)) (throw_1 (frame_10 g)))))))
)) :named test-case.game.validation.strike-frame-first-bonus-throw))

(assert (! (not (exists ((g Game))
  (and
    (game.validation g)
    (or
      (and (spare (frame_1 g)) (not (= (bonus_1 (frame_1 g)) (throw_1 (frame_2 g)))))
      (and (spare (frame_2 g)) (not (= (bonus_1 (frame_2 g)) (throw_1 (frame_3 g)))))
      (and (spare (frame_3 g)) (not (= (bonus_1 (frame_3 g)) (throw_1 (frame_4 g)))))
      (and (spare (frame_4 g)) (not (= (bonus_1 (frame_4 g)) (throw_1 (frame_5 g)))))
      (and (spare (frame_5 g)) (not (= (bonus_1 (frame_5 g)) (throw_1 (frame_6 g)))))
      (and (spare (frame_6 g)) (not (= (bonus_1 (frame_6 g)) (throw_1 (frame_7 g)))))
      (and (spare (frame_7 g)) (not (= (bonus_1 (frame_7 g)) (throw_1 (frame_8 g)))))
      (and (spare (frame_8 g)) (not (= (bonus_1 (frame_8 g)) (throw_1 (frame_9 g)))))
      (and (spare (frame_9 g)) (not (= (bonus_1 (frame_9 g)) (throw_1 (frame_10 g)))))))
)) :named test-case.game.validation.spare-frame-first-bonus-throw))

(assert (! (not (exists ((g Game))
  (and
    (game.validation g)
    (or
      (and (strike (frame_1 g)) (strike (frame_2 g))  (not (= (bonus_2 (frame_1 g)) (bonus_1 (frame_2 g)))))
      (and (strike (frame_2 g)) (strike (frame_3 g))  (not (= (bonus_2 (frame_2 g)) (bonus_1 (frame_3 g)))))
      (and (strike (frame_3 g)) (strike (frame_4 g))  (not (= (bonus_2 (frame_3 g)) (bonus_1 (frame_4 g)))))
      (and (strike (frame_4 g)) (strike (frame_5 g))  (not (= (bonus_2 (frame_4 g)) (bonus_1 (frame_5 g)))))
      (and (strike (frame_5 g)) (strike (frame_6 g))  (not (= (bonus_2 (frame_5 g)) (bonus_1 (frame_6 g)))))
      (and (strike (frame_6 g)) (strike (frame_7 g))  (not (= (bonus_2 (frame_6 g)) (bonus_1 (frame_7 g)))))
      (and (strike (frame_7 g)) (strike (frame_8 g))  (not (= (bonus_2 (frame_7 g)) (bonus_1 (frame_8 g)))))
      (and (strike (frame_8 g)) (strike (frame_9 g))  (not (= (bonus_2 (frame_8 g)) (bonus_1 (frame_9 g)))))
      (and (strike (frame_9 g)) (strike (frame_10 g)) (not (= (bonus_2 (frame_9 g)) (bonus_1 (frame_10 g)))))))
)) :named test-case.game.validation.strike-then-strike-frame-second-bonus-throw))

(assert (! (not (exists ((g Game))
  (and
    (game.validation g)
    (or
      (and (strike (frame_1 g)) (not (strike (frame_2 g)))   (not (= (bonus_2 (frame_1 g)) (throw_2 (frame_2 g)))))
      (and (strike (frame_2 g)) (not (strike (frame_3 g)))   (not (= (bonus_2 (frame_2 g)) (throw_2 (frame_3 g)))))
      (and (strike (frame_3 g)) (not (strike (frame_4 g)))   (not (= (bonus_2 (frame_3 g)) (throw_2 (frame_4 g)))))
      (and (strike (frame_4 g)) (not (strike (frame_5 g)))   (not (= (bonus_2 (frame_4 g)) (throw_2 (frame_5 g)))))
      (and (strike (frame_5 g)) (not (strike (frame_6 g)))   (not (= (bonus_2 (frame_5 g)) (throw_2 (frame_6 g)))))
      (and (strike (frame_6 g)) (not (strike (frame_7 g)))   (not (= (bonus_2 (frame_6 g)) (throw_2 (frame_7 g)))))
      (and (strike (frame_7 g)) (not (strike (frame_8 g)))   (not (= (bonus_2 (frame_7 g)) (throw_2 (frame_8 g)))))
      (and (strike (frame_8 g)) (not (strike (frame_9 g)))   (not (= (bonus_2 (frame_8 g)) (throw_2 (frame_9 g)))))
      (and (strike (frame_9 g)) (not (strike (frame_10 g)))  (not (= (bonus_2 (frame_9 g)) (throw_2 (frame_10 g)))))))
)) :named test-case.game.validation.strike-then-not-strike-frame-second-bonus-throw))

(check-sat)
