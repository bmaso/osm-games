#include "game-ops.smt2"
#include "frame-ops.smt2"
;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; Prove that:
;; - A valid application of a strike throw to a prior game
;;   - where:
;;     - frame X in the range 1-10 is empty
;;     - the previous frame to X cannot accept throws
;;   - will always yield a post game where:
;;     - the frame at the same position is a strike
;;     - the second regular throw is unused in the same frame
;;     - the two bonus throws are incomplete in the same frame
;;     - the frame cannot receive any regular throws
;;;;;;;;;;

(assert (! (not ( exists ((op Game.ApplyThrowOp))
  (and
    (game.apply-throw-op.valid op)
    (= strike-throw (throw op))
    (or
      (and
        (= empty-frame (frame_1 (prior_game op)))
        (or
          (not (frame.is-strike (frame_1 (post_game op))))
          (not (unused (throw_2 (frame_1 (post_game op)))))
          (not (incomplete (bonus_1 (frame_1 (post_game op)))))
          (not (incomplete (bonus_2 (frame_1 (post_game op)))))
          (frame.incomplete-normal-throws (frame_1 (post_game op)))))
      (and
        (not (frame.incomplete-normal-throws (frame_1 (prior_game op))))
        (= empty-frame (frame_2 (prior_game op)))
        (or
          (not (frame.is-strike (frame_2 (post_game op))))
          (not (unused (throw_2 (frame_2 (post_game op)))))
          (not (incomplete (bonus_1 (frame_2 (post_game op)))))
          (not (incomplete (bonus_2 (frame_2 (post_game op)))))
          (frame.incomplete-normal-throws (frame_2 (post_game op)))))
      (and
        (not (frame.incomplete-normal-throws (frame_2 (prior_game op))))
        (= empty-frame (frame_3 (prior_game op)))
        (or
          (not (frame.is-strike (frame_3 (post_game op))))
          (not (unused (throw_2 (frame_3 (post_game op)))))
          (not (incomplete (bonus_1 (frame_3 (post_game op)))))
          (not (incomplete (bonus_2 (frame_3 (post_game op)))))
          (frame.incomplete-normal-throws (frame_3 (post_game op)))))
      (and
        (not (frame.incomplete-normal-throws (frame_3 (prior_game op))))
        (= empty-frame (frame_4 (prior_game op)))
        (or
          (not (frame.is-strike (frame_4 (post_game op))))
          (not (unused (throw_2 (frame_4 (post_game op)))))
          (not (incomplete (bonus_1 (frame_4 (post_game op)))))
          (not (incomplete (bonus_2 (frame_4 (post_game op)))))
          (frame.incomplete-normal-throws (frame_4 (post_game op)))))
      (and
        (not (frame.incomplete-normal-throws (frame_4 (prior_game op))))
        (= empty-frame (frame_5 (prior_game op)))
        (or
          (not (frame.is-strike (frame_5 (post_game op))))
          (not (unused (throw_2 (frame_5 (post_game op)))))
          (not (incomplete (bonus_1 (frame_5 (post_game op)))))
          (not (incomplete (bonus_2 (frame_5 (post_game op)))))
          (frame.incomplete-normal-throws (frame_5 (post_game op)))))
      (and
        (not (frame.incomplete-normal-throws (frame_5 (prior_game op))))
        (= empty-frame (frame_6 (prior_game op)))
        (or
          (not (frame.is-strike (frame_6 (post_game op))))
          (not (unused (throw_2 (frame_6 (post_game op)))))
          (not (incomplete (bonus_1 (frame_6 (post_game op)))))
          (not (incomplete (bonus_2 (frame_6 (post_game op)))))
          (frame.incomplete-normal-throws (frame_6 (post_game op)))))
      (and
        (not (frame.incomplete-normal-throws (frame_6 (prior_game op))))
        (= empty-frame (frame_7 (prior_game op)))
        (or
          (not (frame.is-strike (frame_7 (post_game op))))
          (not (unused (throw_2 (frame_7 (post_game op)))))
          (not (incomplete (bonus_1 (frame_7 (post_game op)))))
          (not (incomplete (bonus_2 (frame_7 (post_game op)))))
          (frame.incomplete-normal-throws (frame_7 (post_game op)))))
      (and
        (not (frame.incomplete-normal-throws (frame_7 (prior_game op))))
        (= empty-frame (frame_8 (prior_game op)))
        (or
          (not (frame.is-strike (frame_8 (post_game op))))
          (not (unused (throw_2 (frame_8 (post_game op)))))
          (not (incomplete (bonus_1 (frame_8 (post_game op)))))
          (not (incomplete (bonus_2 (frame_8 (post_game op)))))
          (frame.incomplete-normal-throws (frame_8 (post_game op)))))
      (and
        (not (frame.incomplete-normal-throws (frame_8 (prior_game op))))
        (= empty-frame (frame_9 (prior_game op)))
        (or
          (not (frame.is-strike (frame_9 (post_game op))))
          (not (unused (throw_2 (frame_9 (post_game op)))))
          (not (incomplete (bonus_1 (frame_9 (post_game op)))))
          (not (incomplete (bonus_2 (frame_9 (post_game op)))))
          (frame.incomplete-normal-throws (frame_9 (post_game op)))))
      (and
        (not (frame.incomplete-normal-throws (frame_9 (prior_game op))))
        (= empty-frame (frame_10 (prior_game op)))
        (or
          (not (frame.is-strike (frame_10 (post_game op))))
          (not (unused (throw_2 (frame_10 (post_game op)))))
          (not (incomplete (bonus_1 (frame_10 (post_game op)))))
          (not (incomplete (bonus_2 (frame_10 (post_game op)))))
          (frame.incomplete-normal-throws (frame_10 (post_game op)))))))
)) :named test-case.game-ops.validation.apply-strike-throw-post-state-invariants ))

(check-sat)
