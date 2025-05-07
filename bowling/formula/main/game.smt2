#include "frame.smt2"
#include "throw.smt2"

#ifndef BOWLING_GAME_DOMAIN
#define BOWLING_GAME_DOMAIN

;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; A game represents a game of bowling, from "initial state", while in progress, or completed. A game is comprised of
;; 10 frames.
;;;;;;;;;;

(declare-datatype Game (
  (game
    (frame_1 Frame)
    (frame_2 Frame)
    (frame_3 Frame)
    (frame_4 Frame)
    (frame_5 Frame)
    (frame_6 Frame)
    (frame_7 Frame)
    (frame_8 Frame)
    (frame_9 Frame)
    (frame_10 Frame))))

;;;;
;; `empty-game` is a convenience constant representing the state of a game without any throws applied to it. This is
;; the state used when starting a new game.
;;;;

(define-const empty-game Game
  (game
    empty-frame      ; frame_1
    empty-frame      ; frame_2
    empty-frame      ; frame_3
    empty-frame      ; frame_4
    empty-frame      ; frame_5
    empty-frame      ; frame_6
    empty-frame      ; frame_7
    empty-frame      ; frame_8
    empty-frame      ; frame_9
    empty-frame))    ; frame_10

;;;;
;; A valid game is:
;; - comprised of valid frames
;; - the frames are completed sequentially
;;   - if frame X has an incomplete and unused normal throw (throw_1 or throw_2), then frame X+1 must be the empty frame
;; - member frames that are "mark" frames (strike or spare):
;;   - The first bonus throw is equal to the first normal throw of the next frame -- this rule applies to frames 1-9
;; - For member frames that are strike frames:
;;   - if the next frame is a strike, then the second bonus throw is equal to the next frame's first bonus throw
;;   - if the next frame is not a strike, then the second bonus throw is equal to the next frame's second normal throw
;;   - this rule applied to frames 1-9
;;;;

(define-fun game.valid.member-frames-valid ((g Game)) Bool
  (and
    (frame.valid (frame_1 g))
    (frame.valid (frame_2 g))
    (frame.valid (frame_3 g))
    (frame.valid (frame_4 g))
    (frame.valid (frame_5 g))
    (frame.valid (frame_6 g))
    (frame.valid (frame_7 g))
    (frame.valid (frame_8 g))
    (frame.valid (frame_9 g))
    (frame.valid (frame_10 g))))

(define-fun frame.incomplete-normal-throws ((f Frame)) Bool
  (or
    (incomplete (throw_1 f))
    (incomplete (throw_2 f))))

(define-fun game.valid.sequential-frames ((g Game)) Bool
  (and
    (=> (frame.incomplete-normal-throws (frame_1 g)) (= empty-frame (frame_2 g)))
    (=> (frame.incomplete-normal-throws (frame_2 g)) (= empty-frame (frame_3 g)))
    (=> (frame.incomplete-normal-throws (frame_3 g)) (= empty-frame (frame_4 g)))
    (=> (frame.incomplete-normal-throws (frame_4 g)) (= empty-frame (frame_5 g)))
    (=> (frame.incomplete-normal-throws (frame_5 g)) (= empty-frame (frame_6 g)))
    (=> (frame.incomplete-normal-throws (frame_6 g)) (= empty-frame (frame_7 g)))
    (=> (frame.incomplete-normal-throws (frame_7 g)) (= empty-frame (frame_8 g)))
    (=> (frame.incomplete-normal-throws (frame_8 g)) (= empty-frame (frame_9 g)))
    (=> (frame.incomplete-normal-throws (frame_9 g)) (= empty-frame (frame_10 g)))))

(define-fun game.valid.mark-frames-first-bonus-consistent-with-next-frame ((g Game)) Bool
  (and
    (=>
      (= #b1111111111 (bvor (pins (throw_1 (frame_1 g))) (pins (throw_2 (frame_1 g)))))
      (= (bonus_1 (frame_1 g)) (throw_1 (frame_2 g))))
    (=>
      (= #b1111111111 (bvor (pins (throw_1 (frame_2 g))) (pins (throw_2 (frame_2 g)))))
      (= (bonus_1 (frame_2 g)) (throw_1 (frame_3 g))))
    (=>
      (= #b1111111111 (bvor (pins (throw_1 (frame_3 g))) (pins (throw_2 (frame_3 g)))))
      (= (bonus_1 (frame_3 g)) (throw_1 (frame_4 g))))
    (=>
      (= #b1111111111 (bvor (pins (throw_1 (frame_4 g))) (pins (throw_2 (frame_4 g)))))
      (= (bonus_1 (frame_4 g)) (throw_1 (frame_5 g))))
    (=>
      (= #b1111111111 (bvor (pins (throw_1 (frame_5 g))) (pins (throw_2 (frame_5 g)))))
      (= (bonus_1 (frame_5 g)) (throw_1 (frame_6 g))))
    (=>
      (= #b1111111111 (bvor (pins (throw_1 (frame_6 g))) (pins (throw_2 (frame_6 g)))))
      (= (bonus_1 (frame_6 g)) (throw_1 (frame_7 g))))
    (=>
      (= #b1111111111 (bvor (pins (throw_1 (frame_7 g))) (pins (throw_2 (frame_7 g)))))
      (= (bonus_1 (frame_7 g)) (throw_1 (frame_8 g))))
    (=>
      (= #b1111111111 (bvor (pins (throw_1 (frame_8 g))) (pins (throw_2 (frame_8 g)))))
      (= (bonus_1 (frame_8 g)) (throw_1 (frame_9 g))))
    (=>
      (= #b1111111111 (bvor (pins (throw_1 (frame_9 g))) (pins (throw_2 (frame_9 g)))))
      (= (bonus_1 (frame_9 g)) (throw_1 (frame_10 g))))))

(define-fun game.valid.strike-then-strike-bonus-2-consistency ((g Game)) Bool
  (and
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_1 g))))
        (= #b1111111111 (pins (throw_1 (frame_2 g)))))
      (= (bonus_2 (frame_1 g)) (bonus_1 (frame_2 g))))
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_2 g))))
        (= #b1111111111 (pins (throw_1 (frame_3 g)))))
      (= (bonus_2 (frame_2 g)) (bonus_1 (frame_3 g))))
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_3 g))))
        (= #b1111111111 (pins (throw_1 (frame_4 g)))))
      (= (bonus_2 (frame_3 g)) (bonus_1 (frame_4 g))))
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_4 g))))
        (= #b1111111111 (pins (throw_1 (frame_5 g)))))
      (= (bonus_2 (frame_4 g)) (bonus_1 (frame_5 g))))
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_5 g))))
        (= #b1111111111 (pins (throw_1 (frame_6 g)))))
      (= (bonus_2 (frame_5 g)) (bonus_1 (frame_6 g))))
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_6 g))))
        (= #b1111111111 (pins (throw_1 (frame_7 g)))))
      (= (bonus_2 (frame_6 g)) (bonus_1 (frame_7 g))))
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_7 g))))
        (= #b1111111111 (pins (throw_1 (frame_8 g)))))
      (= (bonus_2 (frame_7 g)) (bonus_1 (frame_8 g))))
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_8 g))))
        (= #b1111111111 (pins (throw_1 (frame_9 g)))))
      (= (bonus_2 (frame_8 g)) (bonus_1 (frame_9 g))))
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_9 g))))
        (= #b1111111111 (pins (throw_1 (frame_10 g)))))
      (= (bonus_2 (frame_9 g)) (bonus_1 (frame_10 g))))))

(define-fun game.valid.strike-then-not-strike-bonus-2-consistency ((g Game)) Bool
  (and
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_1 g))))
        (not (= #b1111111111 (pins (throw_1 (frame_2 g))))))
      (= (bonus_2 (frame_1 g)) (throw_2 (frame_2 g))))
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_2 g))))
        (not (= #b1111111111 (pins (throw_1 (frame_3 g))))))
      (= (bonus_2 (frame_2 g)) (throw_2 (frame_3 g))))
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_3 g))))
        (not (= #b1111111111 (pins (throw_1 (frame_4 g))))))
      (= (bonus_2 (frame_3 g)) (throw_2 (frame_4 g))))
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_4 g))))
        (not (= #b1111111111 (pins (throw_1 (frame_5 g))))))
      (= (bonus_2 (frame_4 g)) (throw_2 (frame_5 g))))
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_5 g))))
        (not (= #b1111111111 (pins (throw_1 (frame_6 g))))))
      (= (bonus_2 (frame_5 g)) (throw_2 (frame_6 g))))
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_6 g))))
        (not (= #b1111111111 (pins (throw_1 (frame_7 g))))))
      (= (bonus_2 (frame_6 g)) (throw_2 (frame_7 g))))
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_7 g))))
        (not (= #b1111111111 (pins (throw_1 (frame_8 g))))))
      (= (bonus_2 (frame_7 g)) (throw_2 (frame_8 g))))
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_8 g))))
        (not (= #b1111111111 (pins (throw_1 (frame_9 g))))))
      (= (bonus_2 (frame_8 g)) (throw_2 (frame_9 g))))
    (=>
      (and
        (= #b1111111111 (pins (throw_1 (frame_9 g))))
        (not (= #b1111111111 (pins (throw_1 (frame_10 g))))))
      (= (bonus_2 (frame_9 g)) (throw_2 (frame_10 g))))))

(define-fun game.valid ((g Game)) Bool
  (and
    (game.valid.member-frames-valid g)
    (game.valid.sequential-frames g)
    (game.valid.mark-frames-first-bonus-consistent-with-next-frame g)
    (game.valid.strike-then-strike-bonus-2-consistency  g)
    (game.valid.strike-then-not-strike-bonus-2-consistency g)))

;;;;
;; `game.is-incomplete` convenience function. Only useful when input `Game` is valid per `game.valid`.
;;;;

(define-fun game.is-incomplete ((g Game)) Bool
  (frame.is-incomplete (frame_10 g)))

;;;;
;; The the total game score is just the sum of all frames.
;;;;

(define-fun game.points ((g Game)) Int
  (+
    (frame.points (frame_1 g))
    (frame.points (frame_2 g))
    (frame.points (frame_3 g))
    (frame.points (frame_4 g))
    (frame.points (frame_5 g))
    (frame.points (frame_6 g))
    (frame.points (frame_7 g))
    (frame.points (frame_8 g))
    (frame.points (frame_9 g))
    (frame.points (frame_10 g))))

#endif

