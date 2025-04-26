#include "game.smt2"
;; || __FILE__ || __LINE__ ||

;;;;
;; Prove that:
;; * there are no valid games with a non-empty frame following each frame that can accept a throw
;;;;

(assert (! (not (exists ((g Game))
  (and
    (game.valid g)
    (or
      (and
        (frame.incomplete-normal-throws (frame_1 g))
        (not (= empty-frame (frame_2 g))))
      (and
        (frame.incomplete-normal-throws (frame_2 g))
        (not (= empty-frame (frame_3 g))))
      (and
        (frame.incomplete-normal-throws (frame_3 g))
        (not (= empty-frame (frame_4 g))))
      (and
        (frame.incomplete-normal-throws (frame_4 g))
        (not (= empty-frame (frame_5 g))))
      (and
        (frame.incomplete-normal-throws (frame_5 g))
        (not (= empty-frame (frame_6 g))))
      (and
        (frame.incomplete-normal-throws (frame_6 g))
        (not (= empty-frame (frame_7 g))))
      (and
        (frame.incomplete-normal-throws (frame_7 g))
        (not (= empty-frame (frame_8 g))))
      (and
        (frame.incomplete-normal-throws (frame_8 g))
        (not (= empty-frame (frame_9 g))))
      (and
        (frame.incomplete-normal-throws (frame_9 g))
        (not (= empty-frame (frame_10 g))))))
)) :named test-case.game.validation.sequential-frame-completion ))

(check-sat)
