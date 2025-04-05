#include "game.smt2"
;; || __FILE__ || __LINE__ ||

;;
;; Prove that:
;; * there are no valid, completed games where frame 10 is not complete
;; * there are no valid games that are not complete where the 10th frame is complete
;;

(assert (! (not (exists ((g Game))
  (and
    (game.validation g)
    (not (incomplete g))
    (incomplete (frame_10 g)))
)) :named test-case.game.validation.complete-games-have-10th-frame-complete ))

(assert (! (not (exists ((g Game))
  (and
    (game.validation g)
    (incomplete g)
    (not (incomplete (frame_10 g))))
)) :named test-case.game.validation.incomplete-games-have-10th-frame-complete ))

(check-sat)
