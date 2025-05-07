#include "game-ops.smt2"
#include "frame-ops.smt2"
;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; Prove that:
;; - Applying a non-strike throw to a prior game where frame 1-10 is empty yields a post game where the frame in the same position is always
;;   - incomplete
;;   - the first throw matches the operation's throw
;;   - the second throw is incomplete
;;   - the 1st bonus throw is incomplete
;;   - the 2nd bonus throw is unused
;; - Applying a non-strike throw to a prior game where frame 1-10 has a single scratch throw aleady applied, where the two throws add up to less than ten (ie not a spare frame), yields a post game where the frame in the same position is always
;;   - complete
;;   - not a strike or a spare
;;   - the second throw matches the operation's throw
;;   - the 1st bonus throw is unused
;;   - the 2nd bonus throw is unused
;;

(assert (! (not (exists ((op Game.ApplyThrowOp))
  (and
    (game.apply-throw-op.valid op)
    (not (= #b1111111111 (pins (throw op))))
    (or
      (and
        (= empty-frame (frame_1 (prior_game op)))
        (or
          (not (frame.is-incomplete (frame_1 (post_game op))))
          (not (= (throw op) (throw_1 (frame_1 (post_game op)))))
          (not (incomplete (throw_2 (frame_1 (post_game op)))))
          (not (incomplete (bonus_1 (frame_1 (post_game op)))))
          (not (unused (bonus_2 (frame_1 (post_game op)))))))
      (and
        (not (frame.incomplete-normal-throws (frame_1 (prior_game op))))
        (= empty-frame (frame_2 (prior_game op)))
        (or
          (not (frame.is-incomplete (frame_2 (post_game op))))
          (not (= (throw op) (throw_1 (frame_2 (post_game op)))))
          (not (incomplete (throw_2 (frame_2 (post_game op)))))
          (not (incomplete (bonus_1 (frame_2 (post_game op)))))
          (not (unused (bonus_2 (frame_2 (post_game op)))))))
      (and
        (not (frame.incomplete-normal-throws (frame_2 (prior_game op))))
        (= empty-frame (frame_3 (prior_game op)))
        (or
          (not (frame.is-incomplete (frame_3 (post_game op))))
          (not (= (throw op) (throw_1 (frame_3 (post_game op)))))
          (not (incomplete (throw_2 (frame_3 (post_game op)))))
          (not (incomplete (bonus_1 (frame_3 (post_game op)))))
          (not (unused (bonus_2 (frame_3 (post_game op)))))))
      (and
        (not (frame.incomplete-normal-throws (frame_3 (prior_game op))))
        (= empty-frame (frame_4 (prior_game op)))
        (or
          (not (frame.is-incomplete (frame_4 (post_game op))))
          (not (= (throw op) (throw_1 (frame_4 (post_game op)))))
          (not (incomplete (throw_2 (frame_4 (post_game op)))))
          (not (incomplete (bonus_1 (frame_4 (post_game op)))))
          (not (unused (bonus_2 (frame_4 (post_game op)))))))
      (and
        (not (frame.incomplete-normal-throws (frame_4 (prior_game op))))
        (= empty-frame (frame_5 (prior_game op)))
        (or
          (not (frame.is-incomplete (frame_5 (post_game op))))
          (not (= (throw op) (throw_1 (frame_5 (post_game op)))))
          (not (incomplete (throw_2 (frame_5 (post_game op)))))
          (not (incomplete (bonus_1 (frame_5 (post_game op)))))
          (not (unused (bonus_2 (frame_5 (post_game op)))))))
      (and
        (not (frame.incomplete-normal-throws (frame_5 (prior_game op))))
        (= empty-frame (frame_6 (prior_game op)))
        (or
          (not (frame.is-incomplete (frame_6 (post_game op))))
          (not (= (throw op) (throw_1 (frame_6 (post_game op)))))
          (not (incomplete (throw_2 (frame_6 (post_game op)))))
          (not (incomplete (bonus_1 (frame_6 (post_game op)))))
          (not (unused (bonus_2 (frame_6 (post_game op)))))))
      (and
        (not (frame.incomplete-normal-throws (frame_6 (prior_game op))))
        (= empty-frame (frame_7 (prior_game op)))
        (or
          (not (frame.is-incomplete (frame_7 (post_game op))))
          (not (= (throw op) (throw_1 (frame_7 (post_game op)))))
          (not (incomplete (throw_2 (frame_7 (post_game op)))))
          (not (incomplete (bonus_1 (frame_7 (post_game op)))))
          (not (unused (bonus_2 (frame_7 (post_game op)))))))
      (and
        (not (frame.incomplete-normal-throws (frame_7 (prior_game op))))
        (= empty-frame (frame_8 (prior_game op)))
        (or
          (not (frame.is-incomplete (frame_8 (post_game op))))
          (not (= (throw op) (throw_1 (frame_8 (post_game op)))))
          (not (incomplete (throw_2 (frame_8 (post_game op)))))
          (not (incomplete (bonus_1 (frame_8 (post_game op)))))
          (not (unused (bonus_2 (frame_8 (post_game op)))))))
      (and
        (not (frame.incomplete-normal-throws (frame_8 (prior_game op))))
        (= empty-frame (frame_9 (prior_game op)))
        (or
          (not (frame.is-incomplete (frame_9 (post_game op))))
          (not (= (throw op) (throw_1 (frame_9 (post_game op)))))
          (not (incomplete (throw_2 (frame_9 (post_game op)))))
          (not (incomplete (bonus_1 (frame_9 (post_game op)))))
          (not (unused (bonus_2 (frame_9 (post_game op)))))))
      (and
        (not (frame.incomplete-normal-throws (frame_9 (prior_game op))))
        (= empty-frame (frame_10 (prior_game op)))
        (or
          (not (frame.is-incomplete (frame_10 (post_game op))))
          (not (= (throw op) (throw_1 (frame_10 (post_game op)))))
          (not (incomplete (throw_2 (frame_10 (post_game op)))))
          (not (incomplete (bonus_1 (frame_10 (post_game op)))))
          (not (unused (bonus_2 (frame_10 (post_game op)))))))))
)) :named test-case.game-ops.validation.scratch-throw-applied-to-empty-frame ))

(check-sat)

(assert (! (not (exists ((op Game.ApplyThrowOp))
  (and
    (game.apply-throw-op.valid op)
    (not (= #b1111111111 (pins (throw op))))
      (or
        (and
          (not (incomplete (throw_1 (frame_1 (prior_game op)))))
          (incomplete (throw_2 (frame_1 (prior_game op)))) 
          (not (= #b1111111111 (bvor (pins (throw_1 (frame_1 (prior_game op)))) (pins (throw op)))))
          (or
            (frame.is-incomplete (frame_1 (post_game op)))
            (frame.is-strike (frame_1 (post_game op)))
            (frame.is-spare (frame_1 (post_game op)))
            (not (= (throw op) (throw_2 (frame_1 (post_game op))))))
            (not (unused (bonus_1 (frame_1 (post_game op)))))
            (not (unused (bonus_2 (frame_1 (post_game op))))))
        (and
          (not (incomplete (throw_1 (frame_2 (prior_game op)))))
          (incomplete (throw_2 (frame_2 (prior_game op)))) 
          (not (= #b1111111111 (bvor (pins (throw_1 (frame_2 (prior_game op)))) (pins (throw op)))))
          (or
            (frame.is-incomplete (frame_2 (post_game op)))
            (frame.is-strike (frame_2 (post_game op)))
            (frame.is-spare (frame_2 (post_game op)))
            (not (= (throw op) (throw_2 (frame_2 (post_game op))))))
            (not (unused (bonus_1 (frame_2 (post_game op)))))
            (not (unused (bonus_2 (frame_2 (post_game op))))))
        (and
          (not (incomplete (throw_1 (frame_3 (prior_game op)))))
          (incomplete (throw_2 (frame_3 (prior_game op)))) 
          (not (= #b1111111111 (bvor (pins (throw_1 (frame_3 (prior_game op)))) (pins (throw op)))))
          (or
            (frame.is-incomplete (frame_3 (post_game op)))
            (frame.is-strike (frame_3 (post_game op)))
            (frame.is-spare (frame_3 (post_game op)))
            (not (= (throw op) (throw_2 (frame_3 (post_game op))))))
            (not (unused (bonus_1 (frame_3 (post_game op)))))
            (not (unused (bonus_2 (frame_3 (post_game op))))))
        (and
          (not (incomplete (throw_1 (frame_4 (prior_game op)))))
          (incomplete (throw_2 (frame_4 (prior_game op)))) 
          (not (= #b1111111111 (bvor (pins (throw_1 (frame_4 (prior_game op)))) (pins (throw op)))))
          (or
            (frame.is-incomplete (frame_4 (post_game op)))
            (frame.is-strike (frame_4 (post_game op)))
            (frame.is-spare (frame_4 (post_game op)))
            (not (= (throw op) (throw_2 (frame_4 (post_game op))))))
            (not (unused (bonus_1 (frame_4 (post_game op)))))
            (not (unused (bonus_2 (frame_4 (post_game op))))))
        (and
          (not (incomplete (throw_1 (frame_5 (prior_game op)))))
          (incomplete (throw_2 (frame_5 (prior_game op)))) 
          (not (= #b1111111111 (bvor (pins (throw_1 (frame_5 (prior_game op)))) (pins (throw op)))))
          (or
            (frame.is-incomplete (frame_5 (post_game op)))
            (frame.is-strike (frame_5 (post_game op)))
            (frame.is-spare (frame_5 (post_game op)))
            (not (= (throw op) (throw_2 (frame_5 (post_game op))))))
            (not (unused (bonus_1 (frame_5 (post_game op)))))
            (not (unused (bonus_2 (frame_5 (post_game op))))))
        (and
          (not (incomplete (throw_1 (frame_6 (prior_game op)))))
          (incomplete (throw_2 (frame_6 (prior_game op)))) 
          (not (= #b1111111111 (bvor (pins (throw_1 (frame_6 (prior_game op)))) (pins (throw op)))))
          (or
            (frame.is-incomplete (frame_6 (post_game op)))
            (frame.is-strike (frame_6 (post_game op)))
            (frame.is-spare (frame_6 (post_game op)))
            (not (= (throw op) (throw_2 (frame_6 (post_game op))))))
            (not (unused (bonus_1 (frame_6 (post_game op)))))
            (not (unused (bonus_2 (frame_6 (post_game op))))))
        (and
          (not (incomplete (throw_1 (frame_7 (prior_game op)))))
          (incomplete (throw_2 (frame_7 (prior_game op)))) 
          (not (= #b1111111111 (bvor (pins (throw_1 (frame_7 (prior_game op)))) (pins (throw op)))))
          (or
            (frame.is-incomplete (frame_7 (post_game op)))
            (frame.is-strike (frame_7 (post_game op)))
            (frame.is-spare (frame_7 (post_game op)))
            (not (= (throw op) (throw_2 (frame_7 (post_game op))))))
            (not (unused (bonus_1 (frame_7 (post_game op)))))
            (not (unused (bonus_2 (frame_7 (post_game op))))))
        (and
          (not (incomplete (throw_1 (frame_8 (prior_game op)))))
          (incomplete (throw_2 (frame_8 (prior_game op)))) 
          (not (= #b1111111111 (bvor (pins (throw_1 (frame_8 (prior_game op)))) (pins (throw op)))))
          (or
            (frame.is-incomplete (frame_8 (post_game op)))
            (frame.is-strike (frame_8 (post_game op)))
            (frame.is-spare (frame_8 (post_game op)))
            (not (= (throw op) (throw_2 (frame_8 (post_game op))))))
            (not (unused (bonus_1 (frame_8 (post_game op)))))
            (not (unused (bonus_2 (frame_8 (post_game op))))))
        (and
          (not (incomplete (throw_1 (frame_9 (prior_game op)))))
          (incomplete (throw_2 (frame_9 (prior_game op)))) 
          (not (= #b1111111111 (bvor (pins (throw_1 (frame_9 (prior_game op)))) (pins (throw op)))))
          (or
            (frame.is-incomplete (frame_9 (post_game op)))
            (frame.is-strike (frame_9 (post_game op)))
            (frame.is-spare (frame_9 (post_game op)))
            (not (= (throw op) (throw_2 (frame_9 (post_game op))))))
            (not (unused (bonus_1 (frame_9 (post_game op)))))
            (not (unused (bonus_2 (frame_9 (post_game op))))))
        (and
          (not (incomplete (throw_1 (frame_10 (prior_game op)))))
          (incomplete (throw_2 (frame_10 (prior_game op)))) 
          (not (= #b1111111111 (bvor (pins (throw_1 (frame_10 (prior_game op)))) (pins (throw op)))))
          (or
            (frame.is-incomplete (frame_10 (post_game op)))
            (frame.is-strike (frame_10 (post_game op)))
            (frame.is-spare (frame_10 (post_game op)))
            (not (= (throw op) (throw_2 (frame_10 (post_game op))))))
            (not (unused (bonus_1 (frame_10 (post_game op)))))
            (not (unused (bonus_2 (frame_10 (post_game op))))))))))))

(check-sat)
