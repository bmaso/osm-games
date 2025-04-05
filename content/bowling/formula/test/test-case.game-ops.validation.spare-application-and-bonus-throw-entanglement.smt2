#include "game-ops.smt2"
#include "frame-ops.smt2"
;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; Prove that:
;; - Game ops validation of a scratch throw producing a spare conforms to expectations
;;   - where:
;;     - frame X in the range 1-10 has a single scratch throw
;;     - the throw applied has points that bring the frame total to 10
;;   - will always yield a post game where:
;;     - the frame at the same position in the post game is a spare
;;     - the second bonus throw is unused in the same frame in the post game
;;     - the first bonus throw is incomplete in the same frame in the post game
;;   - this is proven below using a "not exists" assertion
;; - Game ops validation of bonus entanglement expectations for spare frames
;;   - where:
;;     - frame X in the range 1-9 is a spare
;;     - frame X+1 is the empty-frame
;;   - will always yield a post game where:
;;     - the bonus_1 field of frame X is equal to the op throw
;;;;;;;;;;

(assert (! (not (exists ((op Game.ApplyThrowOp))
  (and
    (game.apply-throw-op.validation op)
    (or
      (and
        (< (points (throw_1 (frame_1 (prior_game op)))) 10)
        (not (incomplete (throw_1 (frame_1 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_1 (prior_game op))))
        (= (+ (points (throw_1 (frame_1 (prior_game op)))) (points (throw op))) 10)
        (or
          (not (spare (frame_1 (post_game op))))
          (not (unused (bonus_2 (frame_1 (post_game op)))))
          (not (incomplete (bonus_1 (frame_1 (post_game op)))))))
      (and
        (< (points (throw_1 (frame_2 (prior_game op)))) 10)
        (not (incomplete (throw_1 (frame_2 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_2 (prior_game op))))
        (= (+ (points (throw_1 (frame_2 (prior_game op)))) (points (throw op))) 10)
        (or
          (not (spare (frame_2 (post_game op))))
          (not (unused (bonus_2 (frame_2 (post_game op)))))
          (not (incomplete (bonus_1 (frame_2 (post_game op)))))))
      (and
        (< (points (throw_1 (frame_3 (prior_game op)))) 10)
        (not (incomplete (throw_1 (frame_3 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_3 (prior_game op))))
        (= (+ (points (throw_1 (frame_3 (prior_game op)))) (points (throw op))) 10)
        (or
          (not (spare (frame_3 (post_game op))))
          (not (unused (bonus_2 (frame_3 (post_game op)))))
          (not (incomplete (bonus_1 (frame_3 (post_game op)))))))
      (and
        (< (points (throw_1 (frame_4 (prior_game op)))) 10)
        (not (incomplete (throw_1 (frame_4 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_4 (prior_game op))))
        (= (+ (points (throw_1 (frame_4 (prior_game op)))) (points (throw op))) 10)
        (or
          (not (spare (frame_4 (post_game op))))
          (not (unused (bonus_2 (frame_4 (post_game op)))))
          (not (incomplete (bonus_1 (frame_4 (post_game op)))))))
      (and
        (< (points (throw_1 (frame_5 (prior_game op)))) 10)
        (not (incomplete (throw_1 (frame_5 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_5 (prior_game op))))
        (= (+ (points (throw_1 (frame_5 (prior_game op)))) (points (throw op))) 10)
        (or
          (not (spare (frame_5 (post_game op))))
          (not (unused (bonus_2 (frame_5 (post_game op)))))
          (not (incomplete (bonus_1 (frame_5 (post_game op)))))))
      (and
        (< (points (throw_1 (frame_6 (prior_game op)))) 10)
        (not (incomplete (throw_1 (frame_6 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_6 (prior_game op))))
        (= (+ (points (throw_1 (frame_6 (prior_game op)))) (points (throw op))) 10)
        (or
          (not (spare (frame_6 (post_game op))))
          (not (unused (bonus_2 (frame_6 (post_game op)))))
          (not (incomplete (bonus_1 (frame_6 (post_game op)))))))
      (and
        (< (points (throw_1 (frame_7 (prior_game op)))) 10)
        (not (incomplete (throw_1 (frame_7 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_7 (prior_game op))))
        (= (+ (points (throw_1 (frame_7 (prior_game op)))) (points (throw op))) 10)
        (or
          (not (spare (frame_7 (post_game op))))
          (not (unused (bonus_2 (frame_7 (post_game op)))))
          (not (incomplete (bonus_1 (frame_7 (post_game op)))))))
      (and
        (< (points (throw_1 (frame_8 (prior_game op)))) 10)
        (not (incomplete (throw_1 (frame_8 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_8 (prior_game op))))
        (= (+ (points (throw_1 (frame_8 (prior_game op)))) (points (throw op))) 10)
        (or
          (not (spare (frame_8 (post_game op))))
          (not (unused (bonus_2 (frame_8 (post_game op)))))
          (not (incomplete (bonus_1 (frame_8 (post_game op)))))))
      (and
        (< (points (throw_1 (frame_9 (prior_game op)))) 10)
        (not (incomplete (throw_1 (frame_9 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_9 (prior_game op))))
        (= (+ (points (throw_1 (frame_9 (prior_game op)))) (points (throw op))) 10)
        (or
          (not (spare (frame_9 (post_game op))))
          (not (unused (bonus_2 (frame_9 (post_game op)))))
          (not (incomplete (bonus_1 (frame_9 (post_game op)))))))
      (and
        (< (points (throw_1 (frame_10 (prior_game op)))) 10)
        (not (incomplete (throw_1 (frame_10 (prior_game op)))))
        (= incomplete-throw (throw_2 (frame_10 (prior_game op))))
        (= (+ (points (throw_1 (frame_10 (prior_game op)))) (points (throw op))) 10)
        (or
          (not (spare (frame_10 (post_game op))))
          (not (unused (bonus_2 (frame_10 (post_game op)))))
          (not (incomplete (bonus_1 (frame_10 (post_game op)))))))))
)) :named test-case.game-ops.validation.apply-throw-producing-spare-invariants ))

(check-sat)

(assert (! (not (exists ((op Game.ApplyThrowOp))
  (and
    (game.apply-throw-op.validation op)
    (or
      (and
        (spare (frame_1 (prior_game op)))
        (incomplete (bonus_1 (frame_1 (prior_game op))))
        (= empty-frame (frame_2 (prior_game op)))
        (not (= (bonus_1 (frame_1 (post_game op))) (throw_1 (frame_2 (post_game op))))))
      (and
        (spare (frame_2 (prior_game op)))
        (incomplete (bonus_1 (frame_2 (prior_game op))))
        (= empty-frame (frame_3 (prior_game op)))
        (not (= (bonus_1 (frame_2 (post_game op))) (throw_1 (frame_3 (post_game op))))))
      (and
        (spare (frame_3 (prior_game op)))
        (incomplete (bonus_1 (frame_3 (prior_game op))))
        (= empty-frame (frame_4 (prior_game op)))
        (not (= (bonus_1 (frame_3 (post_game op))) (throw_1 (frame_4 (post_game op))))))
      (and
        (spare (frame_4 (prior_game op)))
        (incomplete (bonus_1 (frame_4 (prior_game op))))
        (= empty-frame (frame_5 (prior_game op)))
        (not (= (bonus_1 (frame_4 (post_game op))) (throw_1 (frame_5 (post_game op))))))
      (and
        (spare (frame_5 (prior_game op)))
        (incomplete (bonus_1 (frame_5 (prior_game op))))
        (= empty-frame (frame_6 (prior_game op)))
        (not (= (bonus_1 (frame_5 (post_game op))) (throw_1 (frame_6 (post_game op))))))
      (and
        (spare (frame_6 (prior_game op)))
        (incomplete (bonus_1 (frame_6 (prior_game op))))
        (= empty-frame (frame_7 (prior_game op)))
        (not (= (bonus_1 (frame_6 (post_game op))) (throw_1 (frame_7 (post_game op))))))
      (and
        (spare (frame_7 (prior_game op)))
        (incomplete (bonus_1 (frame_7 (prior_game op))))
        (= empty-frame (frame_8 (prior_game op)))
        (not (= (bonus_1 (frame_7 (post_game op))) (throw_1 (frame_8 (post_game op))))))
      (and
        (spare (frame_8 (prior_game op)))
        (incomplete (bonus_1 (frame_8 (prior_game op))))
        (= empty-frame (frame_9 (prior_game op)))
        (not (= (bonus_1 (frame_8 (post_game op))) (throw_1 (frame_9 (post_game op))))))
      (and
        (spare (frame_9 (prior_game op)))
        (incomplete (bonus_1 (frame_9 (prior_game op))))
        (= empty-frame (frame_10 (prior_game op)))
        (not (= (bonus_1 (frame_9 (post_game op))) (throw_1 (frame_10 (post_game op))))))))
)) :named test-case.game-ops.validation.spare-bonus-throw-entanglements ))

(check-sat)
