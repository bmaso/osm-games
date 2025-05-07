#include "game-ops.smt2"
#include "frame-ops.smt2"
;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; Prove strike bonuses and subsequent frame throw entanglement:
;; - Verifying entanglement of bonus_1 and the next frame's first regular throw when frame is a strike
;;   - where in the prior game:
;;     - frame X in the range 1-9 is already a strike with bonus_1 incomplete
;;     - frame X+1 is the empty-frame
;;   - will always yield a post game where:
;;     - frame X bonus_1 throw is equal to the operation's throw
;;     - frame X+1 throw_1 is equal to the operation's throw
;;     - both frame X and frame X+1 are incomplete
;; - Verifyng entanglement of bonus_2 and the next frame's second regular throw
;;   in cases where the next frame is not a strike, first frame is a strike, and throw does not produce a spare
;;   - where:
;;     - frame X in the range 1-9 is already a strike with bonus_2 incomplete
;;     - frame X+1 is a frame with throw_1 a scratch throw
;;     - frame X+1 throw_2 is incomplete
;;     - the sum of the operation's throw + frame X+1 throw_1 < 10
;;  - will always yield a post game where:
;;     - frame X bonus_2 throw is equal to the operation's throw
;;     - frame X+1 throw_2 is equal to the operation's throw
;;     - both frame X and frame X+1 are complete
;;  - this is proven below using a "not exists" assertion
;; - Verifyng entanglement of bonus_2 and the next frame's second regular throw
;;   in cases where the next frame is not a strike, first frame is a strike, and throw produces a spare
;;   - where:
;;     - frame X in the range 1-9 is already a strike with bonus_2 incomplete
;;     - frame X+1 is a frame with throw_1 a scratch throw
;;     - frame X+1 throw_2 is incomplete
;;     - the sum of the operation's throw + frame X+1 throw_1 = 10
;;  - will always yield a post game where:
;;     - frame X bonus_2 throw is equal to the operation's throw
;;     - frame X+1 throw_2 is equal to the operation's throw
;;     - frame X is complete
;;     - frame X+1 is an incomplete spare frame
;;  - this is proven below using a "not exists" assertion
;; - Verifying entanglement of bonus_2 and the second-next frame's first regular throw
;;   in cases where both the first and next frames are strikes
;;   - where:
;;     - frame X in the range 1-8 is already a strike
;;     - frame X+1 is also a strike
;;     - frame X+2 is the empty-frame
;;   - will always yield a post game where:
;;     - frame X bonus_2 throw is equal to the operation's throw, which is strike-throw
;;     - frame X+1 bonus_1 is also equal to the operation's throw, which is a strike-throw
;;     - frame X is complete
;;     - frame X+1 is incomplete
;;     - frame X+1 bonus_2 is incomplete
;;;;;;;;;;

(assert (! (not (exists ((op Game.ApplyThrowOp))
  (and
    (game.apply-throw-op.valid op)
    (or
      (and
        (frame.is-strike (frame_1 (prior_game op)))
        (incomplete (bonus_1 (frame_1 (prior_game op))))
        (= empty-frame (frame_2 (prior_game op)))
        (or
          (not (= (bonus_1 (frame_1 (post_game op))) (throw op)))
          (not (= (throw_1 (frame_2 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_1 (post_game op))))
          (not (frame.is-incomplete (frame_2 (post_game op))))))
      (and
        (frame.is-strike (frame_2 (prior_game op)))
        (incomplete (bonus_1 (frame_2 (prior_game op))))
        (= empty-frame (frame_3 (prior_game op)))
        (or
          (not (= (bonus_1 (frame_2 (post_game op))) (throw op)))
          (not (= (throw_1 (frame_3 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_2 (post_game op))))
          (not (frame.is-incomplete (frame_3 (post_game op))))))
      (and
        (frame.is-strike (frame_3 (prior_game op)))
        (incomplete (bonus_1 (frame_3 (prior_game op))))
        (= empty-frame (frame_4 (prior_game op)))
        (or
          (not (= (bonus_1 (frame_3 (post_game op))) (throw op)))
          (not (= (throw_1 (frame_4 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_3 (post_game op))))
          (not (frame.is-incomplete (frame_4 (post_game op))))))
      (and
        (frame.is-strike (frame_4 (prior_game op)))
        (incomplete (bonus_1 (frame_4 (prior_game op))))
        (= empty-frame (frame_5 (prior_game op)))
        (or
          (not (= (bonus_1 (frame_4 (post_game op))) (throw op)))
          (not (= (throw_1 (frame_5 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_4 (post_game op))))
          (not (frame.is-incomplete (frame_5 (post_game op))))))
      (and
        (frame.is-strike (frame_5 (prior_game op)))
        (incomplete (bonus_1 (frame_5 (prior_game op))))
        (= empty-frame (frame_6 (prior_game op)))
        (or
          (not (= (bonus_1 (frame_5 (post_game op))) (throw op)))
          (not (= (throw_1 (frame_6 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_5 (post_game op))))
          (not (frame.is-incomplete (frame_6 (post_game op))))))
      (and
        (frame.is-strike (frame_6 (prior_game op)))
        (incomplete (bonus_1 (frame_6 (prior_game op))))
        (= empty-frame (frame_7 (prior_game op)))
        (or
          (not (= (bonus_1 (frame_6 (post_game op))) (throw op)))
          (not (= (throw_1 (frame_7 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_6 (post_game op))))
          (not (frame.is-incomplete (frame_7 (post_game op))))))
      (and
        (frame.is-strike (frame_7 (prior_game op)))
        (incomplete (bonus_1 (frame_7 (prior_game op))))
        (= empty-frame (frame_8 (prior_game op)))
        (or
          (not (= (bonus_1 (frame_7 (post_game op))) (throw op)))
          (not (= (throw_1 (frame_8 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_7 (post_game op))))
          (not (frame.is-incomplete (frame_8 (post_game op))))))
      (and
        (frame.is-strike (frame_8 (prior_game op)))
        (incomplete (bonus_1 (frame_8 (prior_game op))))
        (= empty-frame (frame_9 (prior_game op)))
        (or
          (not (= (bonus_1 (frame_8 (post_game op))) (throw op)))
          (not (= (throw_1 (frame_9 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_8 (post_game op))))
          (not (frame.is-incomplete (frame_9 (post_game op))))))
      (and
        (frame.is-strike (frame_9 (prior_game op)))
        (incomplete (bonus_1 (frame_9 (prior_game op))))
        (= empty-frame (frame_10 (prior_game op)))
        (or
          (not (= (bonus_1 (frame_9 (post_game op))) (throw op)))
          (not (= (throw_1 (frame_10 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_9 (post_game op))))
          (not (frame.is-incomplete (frame_10 (post_game op))))))))
)) :named test-case.game-ops.validation.first-bonus-throw-entanglement ))

(check-sat)

(assert (! (not (exists ((op Game.ApplyThrowOp))
  (and
    (game.apply-throw-op.valid op)
    (or
      (and
        (frame.is-strike (frame_1 (prior_game op)))
        (not (incomplete (bonus_1 (frame_1 (prior_game op)))))
        (incomplete (bonus_2 (frame_1 (prior_game op))))
        (incomplete (throw_2 (frame_2 (prior_game op))))
        (not (frame.is-strike (frame_2 (prior_game op))))
        (or
          (not (= (bonus_2 (frame_1 (post_game op))) (throw op)))
          (not (= (throw_2 (frame_2 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_1 (post_game op))))
          (frame.is-incomplete (frame_2 (post_game op)))))
      (and
        (frame.is-strike (frame_2 (prior_game op)))
        (not (incomplete (bonus_1 (frame_2 (prior_game op)))))
        (incomplete (bonus_2 (frame_2 (prior_game op))))
        (incomplete (throw_2 (frame_3 (prior_game op))))
        (not (frame.is-strike (frame_3 (prior_game op))))
        (or
          (not (= (bonus_2 (frame_2 (post_game op))) (throw op)))
          (not (= (throw_2 (frame_3 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_2 (post_game op))))
          (frame.is-incomplete (frame_3 (post_game op)))))
      (and
        (frame.is-strike (frame_3 (prior_game op)))
        (not (incomplete (bonus_1 (frame_3 (prior_game op)))))
        (incomplete (bonus_2 (frame_3 (prior_game op))))
        (incomplete (throw_2 (frame_4 (prior_game op))))
        (not (frame.is-strike (frame_4 (prior_game op))))
        (or
          (not (= (bonus_2 (frame_3 (post_game op))) (throw op)))
          (not (= (throw_2 (frame_4 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_3 (post_game op))))
          (frame.is-incomplete (frame_4 (post_game op)))))
      (and
        (frame.is-strike (frame_4 (prior_game op)))
        (not (incomplete (bonus_1 (frame_4 (prior_game op)))))
        (incomplete (bonus_2 (frame_4 (prior_game op))))
        (incomplete (throw_2 (frame_5 (prior_game op))))
        (not (frame.is-strike (frame_5 (prior_game op))))
        (or
          (not (= (bonus_2 (frame_4 (post_game op))) (throw op)))
          (not (= (throw_2 (frame_5 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_4 (post_game op))))
          (frame.is-incomplete (frame_5 (post_game op)))))
      (and
        (frame.is-strike (frame_5 (prior_game op)))
        (not (incomplete (bonus_1 (frame_5 (prior_game op)))))
        (incomplete (bonus_2 (frame_5 (prior_game op))))
        (incomplete (throw_2 (frame_6 (prior_game op))))
        (not (frame.is-strike (frame_6 (prior_game op))))
        (or
          (not (= (bonus_2 (frame_5 (post_game op))) (throw op)))
          (not (= (throw_2 (frame_6 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_5 (post_game op))))
          (frame.is-incomplete (frame_6 (post_game op)))))
      (and
        (frame.is-strike (frame_6 (prior_game op)))
        (not (incomplete (bonus_1 (frame_6 (prior_game op)))))
        (incomplete (bonus_2 (frame_6 (prior_game op))))
        (incomplete (throw_2 (frame_7 (prior_game op))))
        (not (frame.is-strike (frame_7 (prior_game op))))
        (or
          (not (= (bonus_2 (frame_6 (post_game op))) (throw op)))
          (not (= (throw_2 (frame_7 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_6 (post_game op))))
          (frame.is-incomplete (frame_7 (post_game op)))))
      (and
        (frame.is-strike (frame_7 (prior_game op)))
        (not (incomplete (bonus_1 (frame_7 (prior_game op)))))
        (incomplete (bonus_2 (frame_7 (prior_game op))))
        (incomplete (throw_2 (frame_8 (prior_game op))))
        (not (frame.is-strike (frame_8 (prior_game op))))
        (or
          (not (= (bonus_2 (frame_7 (post_game op))) (throw op)))
          (not (= (throw_2 (frame_8 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_7 (post_game op))))
          (frame.is-incomplete (frame_8 (post_game op)))))
      (and
        (frame.is-strike (frame_8 (prior_game op)))
        (not (incomplete (bonus_1 (frame_8 (prior_game op)))))
        (incomplete (bonus_2 (frame_8 (prior_game op))))
        (incomplete (throw_2 (frame_9 (prior_game op))))
        (not (frame.is-strike (frame_9 (prior_game op))))
        (or
          (not (= (bonus_2 (frame_8 (post_game op))) (throw op)))
          (not (= (throw_2 (frame_9 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_8 (post_game op))))
          (frame.is-incomplete (frame_9 (post_game op)))))
      (and
        (frame.is-strike (frame_9 (prior_game op)))
        (not (incomplete (bonus_1 (frame_9 (prior_game op)))))
        (incomplete (bonus_2 (frame_9 (prior_game op))))
        (incomplete (throw_2 (frame_10 (prior_game op))))
        (not (frame.is-strike (frame_10 (prior_game op))))
        (or
          (not (= (bonus_2 (frame_9 (post_game op))) (throw op)))
          (not (= (throw_2 (frame_10 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_9 (post_game op))))
          (frame.is-incomplete (frame_10 (post_game op)))))))
)) :named test-case.game-ops.validation.second-bonus-throw-entanglement-without-second-strike ))

(check-sat)

(assert (! (not (exists ((op Game.ApplyThrowOp))
  (and
    (game.apply-throw-op.valid op)
    (or
      (and
        (frame.is-strike (frame_1 (prior_game op)))
        (not (incomplete (bonus_1 (frame_1 (prior_game op)))))
        (incomplete (bonus_2 (frame_1 (prior_game op))))
        (incomplete (throw_2 (frame_2 (prior_game op))))
        (frame.is-strike (frame_2 (prior_game op)))
        (or
          (not (= (bonus_2 (frame_1 (post_game op))) (throw op)))
          (not (= (bonus_1 (frame_2 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_1 (post_game op))))
          (frame.is-incomplete (frame_2 (post_game op)))))
      (and
        (frame.is-strike (frame_2 (prior_game op)))
        (not (incomplete (bonus_1 (frame_2 (prior_game op)))))
        (incomplete (bonus_2 (frame_2 (prior_game op))))
        (incomplete (throw_2 (frame_3 (prior_game op))))
        (frame.is-strike (frame_3 (prior_game op)))
        (or
          (not (= (bonus_2 (frame_2 (post_game op))) (throw op)))
          (not (= (bonus_1 (frame_3 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_2 (post_game op))))
          (frame.is-incomplete (frame_3 (post_game op)))))
      (and
        (frame.is-strike (frame_3 (prior_game op)))
        (not (incomplete (bonus_1 (frame_3 (prior_game op)))))
        (incomplete (bonus_2 (frame_3 (prior_game op))))
        (incomplete (throw_2 (frame_4 (prior_game op))))
        (frame.is-strike (frame_4 (prior_game op)))
        (or
          (not (= (bonus_2 (frame_3 (post_game op))) (throw op)))
          (not (= (bonus_1 (frame_4 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_3 (post_game op))))
          (frame.is-incomplete (frame_4 (post_game op)))))
      (and
        (frame.is-strike (frame_4 (prior_game op)))
        (not (incomplete (bonus_1 (frame_4 (prior_game op)))))
        (incomplete (bonus_2 (frame_4 (prior_game op))))
        (incomplete (throw_2 (frame_5 (prior_game op))))
        (frame.is-strike (frame_5 (prior_game op)))
        (or
          (not (= (bonus_2 (frame_4 (post_game op))) (throw op)))
          (not (= (bonus_1 (frame_5 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_4 (post_game op))))
          (frame.is-incomplete (frame_5 (post_game op)))))
      (and
        (frame.is-strike (frame_5 (prior_game op)))
        (not (incomplete (bonus_1 (frame_5 (prior_game op)))))
        (incomplete (bonus_2 (frame_5 (prior_game op))))
        (incomplete (throw_2 (frame_6 (prior_game op))))
        (frame.is-strike (frame_6 (prior_game op)))
        (or
          (not (= (bonus_2 (frame_5 (post_game op))) (throw op)))
          (not (= (bonus_1 (frame_6 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_5 (post_game op))))
          (frame.is-incomplete (frame_6 (post_game op)))))
      (and
        (frame.is-strike (frame_6 (prior_game op)))
        (not (incomplete (bonus_1 (frame_6 (prior_game op)))))
        (incomplete (bonus_2 (frame_6 (prior_game op))))
        (incomplete (throw_2 (frame_7 (prior_game op))))
        (frame.is-strike (frame_7 (prior_game op)))
        (or
          (not (= (bonus_2 (frame_6 (post_game op))) (throw op)))
          (not (= (bonus_1 (frame_7 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_6 (post_game op))))
          (frame.is-incomplete (frame_7 (post_game op)))))
      (and
        (frame.is-strike (frame_7 (prior_game op)))
        (not (incomplete (bonus_1 (frame_7 (prior_game op)))))
        (incomplete (bonus_2 (frame_7 (prior_game op))))
        (incomplete (throw_2 (frame_8 (prior_game op))))
        (frame.is-strike (frame_8 (prior_game op)))
        (or
          (not (= (bonus_2 (frame_7 (post_game op))) (throw op)))
          (not (= (bonus_1 (frame_8 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_7 (post_game op))))
          (frame.is-incomplete (frame_8 (post_game op)))))
      (and
        (frame.is-strike (frame_8 (prior_game op)))
        (not (incomplete (bonus_1 (frame_8 (prior_game op)))))
        (incomplete (bonus_2 (frame_8 (prior_game op))))
        (incomplete (throw_2 (frame_9 (prior_game op))))
        (frame.is-strike (frame_9 (prior_game op)))
        (or
          (not (= (bonus_2 (frame_8 (post_game op))) (throw op)))
          (not (= (bonus_1 (frame_9 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_8 (post_game op))))
          (frame.is-incomplete (frame_9 (post_game op)))))
      (and
        (frame.is-strike (frame_9 (prior_game op)))
        (not (incomplete (bonus_1 (frame_9 (prior_game op)))))
        (incomplete (bonus_2 (frame_9 (prior_game op))))
        (incomplete (throw_2 (frame_10 (prior_game op))))
        (frame.is-strike (frame_10 (prior_game op)))
        (or
          (not (= (bonus_2 (frame_9 (post_game op))) (throw op)))
          (not (= (bonus_1 (frame_10 (post_game op))) (throw op)))
          (not (frame.is-incomplete (frame_9 (post_game op))))
          (frame.is-incomplete (frame_10 (post_game op)))))))
)) :named test-case.game-ops.validation.second-bonus-throw-entanglement-with-second-strike ))

(check-sat)