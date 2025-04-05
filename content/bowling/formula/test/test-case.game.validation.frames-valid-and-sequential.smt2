#include "game.smt2"
;; || __FILE__ || __LINE__ ||

;;
;; Prove that:
;; * there are no valid games with a non-empty frame following each frame that can accept a throw
;; * there are no valid completed games where frame 10 is not complete
;;

(assert (! (not (exists ((g Game))
  (and
    (game.validation g)
    (or
      (and
        (frame.incomplete-regular-throws (frame_1 g))
        (or
          (not (= empty-frame (frame_2 g)))
          (not (= empty-frame (frame_3 g)))
          (not (= empty-frame (frame_4 g)))
          (not (= empty-frame (frame_5 g)))
          (not (= empty-frame (frame_6 g)))
          (not (= empty-frame (frame_7 g)))
          (not (= empty-frame (frame_8 g)))
          (not (= empty-frame (frame_9 g)))
          (not (= empty-frame (frame_10 g)))))
      (and
        (frame.incomplete-regular-throws (frame_2 g))
        (or
          (not (= empty-frame (frame_3 g)))
          (not (= empty-frame (frame_4 g)))
          (not (= empty-frame (frame_5 g)))
          (not (= empty-frame (frame_6 g)))
          (not (= empty-frame (frame_7 g)))
          (not (= empty-frame (frame_8 g)))
          (not (= empty-frame (frame_9 g)))
          (not (= empty-frame (frame_10 g)))))
      (and
        (frame.incomplete-regular-throws (frame_3 g))
        (or
          (not (= empty-frame (frame_4 g)))
          (not (= empty-frame (frame_5 g)))
          (not (= empty-frame (frame_6 g)))
          (not (= empty-frame (frame_7 g)))
          (not (= empty-frame (frame_8 g)))
          (not (= empty-frame (frame_9 g)))
          (not (= empty-frame (frame_10 g)))))
      (and
        (frame.incomplete-regular-throws (frame_4 g))
        (or
          (not (= empty-frame (frame_5 g)))
          (not (= empty-frame (frame_6 g)))
          (not (= empty-frame (frame_7 g)))
          (not (= empty-frame (frame_8 g)))
          (not (= empty-frame (frame_9 g)))
          (not (= empty-frame (frame_10 g)))))
      (and
        (frame.incomplete-regular-throws (frame_5 g))
        (or
          (not (= empty-frame (frame_6 g)))
          (not (= empty-frame (frame_7 g)))
          (not (= empty-frame (frame_8 g)))
          (not (= empty-frame (frame_9 g)))
          (not (= empty-frame (frame_10 g)))))
      (and
        (frame.incomplete-regular-throws (frame_6 g))
        (or
          (not (= empty-frame (frame_7 g)))
          (not (= empty-frame (frame_8 g)))
          (not (= empty-frame (frame_9 g)))
          (not (= empty-frame (frame_10 g)))))
      (and
        (frame.incomplete-regular-throws (frame_7 g))
        (or
          (not (= empty-frame (frame_8 g)))
          (not (= empty-frame (frame_9 g)))
          (not (= empty-frame (frame_10 g)))))
      (and
        (frame.incomplete-regular-throws (frame_8 g))
        (or
          (not (= empty-frame (frame_9 g)))
          (not (= empty-frame (frame_10 g)))))
      (and
        (frame.incomplete-regular-throws (frame_9 g))
        (not (= empty-frame (frame_10 g))))))
)) :named test-case.game.validation.sequential-frame-completion ))

(assert (! (not (exists ((g Game))
  (and
    (game.validation g)
    (not (incomplete g))
    (incomplete (frame_10 g)))
)) :named test-case.game.validation.game-completion-consistent-with-frame-10 ))

(check-sat)

