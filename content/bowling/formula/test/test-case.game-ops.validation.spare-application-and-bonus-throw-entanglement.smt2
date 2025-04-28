#include "game-ops.smt2"
#include "frame-ops.smt2"
;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; Prove that:
;; - Game ops validation of a scratch throw producing a spare conforms to expectations
;;   - where:
;;     - frame X in the range 1-10 has a single scratch throw
;;     - the throw applied has points that knocks all remaining pins down
;;   - will always yield a post game where:
;;     - the frame at the same position in the post game is a spare
;;     - the first bonus throw is incomplete in the same frame in the post game
;;     - the second bonus throw is unused in the same frame in the post game
;; - Game ops validation of bonus entanglement expectations for spare frames
;;   - where:
;;     - frame X in the range 1-9 is a spare
;;     - frame X+1 is the empty-frame
;;     - the op throw knocks at least 1 pin down
;;   - will always yield a post game where:
;;     - the bonus_1 field of frame X is equal to the op throw
;;;;;;;;;;

(assert (! (not (exists ((op Game.ApplyThrowOp))
  (and
    (game.apply-throw-op.valid op)
    (or
      (and
        (not (frame.is-strike (frame_1 (prior_game op))))
        (not (incomplete (throw_1 (frame_1 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_1 (prior_game op))))
        (= #b1111111111 (bvor (pins (throw_1 (frame_1 (prior_game op)))) (pins (throw op))))
        (or
          (not (frame.is-spare (frame_1 (post_game op))))
          (not (unused (bonus_2 (frame_1 (post_game op)))))
          (not (incomplete (bonus_1 (frame_1 (post_game op)))))))
      (and
        (not (frame.is-strike (frame_2 (prior_game op))))
        (not (incomplete (throw_1 (frame_2 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_2 (prior_game op))))
        (= #b1111111111 (bvor (pins (throw_1 (frame_2 (prior_game op)))) (pins (throw op))))
        (or
          (not (frame.is-spare (frame_2 (post_game op))))
          (not (unused (bonus_2 (frame_2 (post_game op)))))
          (not (incomplete (bonus_1 (frame_2 (post_game op)))))))
      (and
        (not (frame.is-strike (frame_3 (prior_game op))))
        (not (incomplete (throw_1 (frame_3 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_3 (prior_game op))))
        (= #b1111111111 (bvor (pins (throw_1 (frame_3 (prior_game op)))) (pins (throw op))))
        (or
          (not (frame.is-spare (frame_3 (post_game op))))
          (not (unused (bonus_2 (frame_3 (post_game op)))))
          (not (incomplete (bonus_1 (frame_3 (post_game op)))))))
      (and
        (not (frame.is-strike (frame_4 (prior_game op))))
        (not (incomplete (throw_1 (frame_4 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_4 (prior_game op))))
        (= #b1111111111 (bvor (pins (throw_1 (frame_4 (prior_game op)))) (pins (throw op))))
        (or
          (not (frame.is-spare (frame_4 (post_game op))))
          (not (unused (bonus_2 (frame_4 (post_game op)))))
          (not (incomplete (bonus_1 (frame_4 (post_game op)))))))
      (and
        (not (frame.is-strike (frame_5 (prior_game op))))
        (not (incomplete (throw_1 (frame_5 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_5 (prior_game op))))
        (= #b1111111111 (bvor (pins (throw_1 (frame_5 (prior_game op)))) (pins (throw op))))
        (or
          (not (frame.is-spare (frame_5 (post_game op))))
          (not (unused (bonus_2 (frame_5 (post_game op)))))
          (not (incomplete (bonus_1 (frame_5 (post_game op)))))))
      (and
        (not (frame.is-strike (frame_6 (prior_game op))))
        (not (incomplete (throw_1 (frame_6 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_6 (prior_game op))))
        (= #b1111111111 (bvor (pins (throw_1 (frame_6 (prior_game op)))) (pins (throw op))))
        (or
          (not (frame.is-spare (frame_6 (post_game op))))
          (not (unused (bonus_2 (frame_6 (post_game op)))))
          (not (incomplete (bonus_1 (frame_6 (post_game op)))))))
      (and
        (not (frame.is-strike (frame_7 (prior_game op))))
        (not (incomplete (throw_1 (frame_7 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_7 (prior_game op))))
        (= #b1111111111 (bvor (pins (throw_1 (frame_7 (prior_game op)))) (pins (throw op))))
        (or
          (not (frame.is-spare (frame_7 (post_game op))))
          (not (unused (bonus_2 (frame_7 (post_game op)))))
          (not (incomplete (bonus_1 (frame_7 (post_game op)))))))
      (and
        (not (frame.is-strike (frame_8 (prior_game op))))
        (not (incomplete (throw_1 (frame_8 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_8 (prior_game op))))
        (= #b1111111111 (bvor (pins (throw_1 (frame_8 (prior_game op)))) (pins (throw op))))
        (or
          (not (frame.is-spare (frame_8 (post_game op))))
          (not (unused (bonus_2 (frame_8 (post_game op)))))
          (not (incomplete (bonus_1 (frame_8 (post_game op)))))))
      (and
        (not (frame.is-strike (frame_9 (prior_game op))))
        (not (incomplete (throw_1 (frame_9 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_9 (prior_game op))))
        (= #b1111111111 (bvor (pins (throw_1 (frame_9 (prior_game op)))) (pins (throw op))))
        (or
          (not (frame.is-spare (frame_9 (post_game op))))
          (not (unused (bonus_2 (frame_9 (post_game op)))))
          (not (incomplete (bonus_1 (frame_9 (post_game op)))))))
      (and
        (not (frame.is-strike (frame_10 (prior_game op))))
        (not (incomplete (throw_1 (frame_10 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_10 (prior_game op))))
        (= #b1111111111 (bvor (pins (throw_1 (frame_10 (prior_game op)))) (pins (throw op))))
        (or
          (not (frame.is-spare (frame_10 (post_game op))))
          (not (unused (bonus_2 (frame_10 (post_game op)))))
          (not (incomplete (bonus_1 (frame_10 (post_game op)))))))))
)) :named test-case.game-ops.validation.apply-throw-producing-spare-invariants ))

(check-sat)

(assert (! (not (exists ((op Game.ApplyThrowOp))
  (and
    (game.apply-throw-op.valid op)
    (or
      (and
        (frame.is-spare (frame_1 (prior_game op)))
        (incomplete (bonus_1 (frame_1 (prior_game op))))
        (= empty-frame (frame_2 (prior_game op)))
        (not (= (bonus_1 (frame_1 (post_game op))) (throw_1 (frame_2 (post_game op))))))
      (and
        (frame.is-spare (frame_2 (prior_game op)))
        (incomplete (bonus_1 (frame_2 (prior_game op))))
        (= empty-frame (frame_3 (prior_game op)))
        (not (= (bonus_1 (frame_2 (post_game op))) (throw_1 (frame_3 (post_game op))))))
      (and
        (frame.is-spare (frame_3 (prior_game op)))
        (incomplete (bonus_1 (frame_3 (prior_game op))))
        (= empty-frame (frame_4 (prior_game op)))
        (not (= (bonus_1 (frame_3 (post_game op))) (throw_1 (frame_4 (post_game op))))))
      (and
        (frame.is-spare (frame_4 (prior_game op)))
        (incomplete (bonus_1 (frame_4 (prior_game op))))
        (= empty-frame (frame_5 (prior_game op)))
        (not (= (bonus_1 (frame_4 (post_game op))) (throw_1 (frame_5 (post_game op))))))
      (and
        (frame.is-spare (frame_5 (prior_game op)))
        (incomplete (bonus_1 (frame_5 (prior_game op))))
        (= empty-frame (frame_6 (prior_game op)))
        (not (= (bonus_1 (frame_5 (post_game op))) (throw_1 (frame_6 (post_game op))))))
      (and
        (frame.is-spare (frame_6 (prior_game op)))
        (incomplete (bonus_1 (frame_6 (prior_game op))))
        (= empty-frame (frame_7 (prior_game op)))
        (not (= (bonus_1 (frame_6 (post_game op))) (throw_1 (frame_7 (post_game op))))))
      (and
        (frame.is-spare (frame_7 (prior_game op)))
        (incomplete (bonus_1 (frame_7 (prior_game op))))
        (= empty-frame (frame_8 (prior_game op)))
        (not (= (bonus_1 (frame_7 (post_game op))) (throw_1 (frame_8 (post_game op))))))
      (and
        (frame.is-spare (frame_8 (prior_game op)))
        (incomplete (bonus_1 (frame_8 (prior_game op))))
        (= empty-frame (frame_9 (prior_game op)))
        (not (= (bonus_1 (frame_8 (post_game op))) (throw_1 (frame_9 (post_game op))))))
      (and
        (frame.is-spare (frame_9 (prior_game op)))
        (incomplete (bonus_1 (frame_9 (prior_game op))))
        (= empty-frame (frame_10 (prior_game op)))
        (not (= (bonus_1 (frame_9 (post_game op))) (throw_1 (frame_10 (post_game op))))))))
)) :named test-case.game-ops.validation.spare-bonus-throw-entanglements ))

(check-sat)
