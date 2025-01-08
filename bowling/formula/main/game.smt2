#include "frame.smt2"
#include "throw.smt2"

#ifndef BOWLING_GAME_DOMAIN
#define BOWLING_GAME_DOMAIN

;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; A game represents a game of bowling, from "initial state", while in progress, or completed. A game is comprised of:
;; - 10 frames
;; - an incomplete flag, indicating that the game is in progress
;; - a score integer
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
    (frame_10 Frame)
    (incomplete Bool)
    (score Int))
))

;;;;
;; `empty-game` is a convenience constant representing the state of a game without any throws applied to it. This is
;; the state used when starting a new game. The game is incomplete, and the initial score is zero.
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
    empty-frame      ; frame_10
    true             ; incomplete flag
    0)               ; score
)

;;;;
;; A valid game is comprised of valid frames. The state of sequential the frames are entangled.
;; - The frames are completed sequentially; if frame X has either regular throw incomplete, then frame X+1 is
;;   is the empty-frame -- this rule applies to frames 1-9
;; - For member frames that are "mark" frames (strike or spare):
;;   - The first bonus throw is equal to the first normal throw of the next frame -- this rule applies to frames 1-9
;; - For member frames that are strike frames and the next frame is _not_ a strike frame
;;   - the second bonus throw is equal to the second normal throw of the next frame -- this rule applies to frames 1-9
;; - For member frames that are strike frames and the next frame is also a strike frame
;;   - the second bonus throw is equal to the first bonus throw of the next frame, which is also equal to the
;;     first normal throw of the second frame seqentially forward, because of the "mark" frame rule above -- this rule
;;     applies to frames 1-9
;; - The game's incomplete flag is consistent with the completion state of the 10th frame; the game is complete when the
;;   10th frame is complete
;; - The score is the sum of the point values of all the frames
;;;;

(declare-fun game.validation.member-frames-valid (Game) Bool)
(assert (! (forall ((g Game))
  (=
    (and
      (frame.validation (frame_1 g))
      (frame.validation (frame_2 g))
      (frame.validation (frame_3 g))
      (frame.validation (frame_4 g))
      (frame.validation (frame_5 g))
      (frame.validation (frame_6 g))
      (frame.validation (frame_7 g))
      (frame.validation (frame_8 g))
      (frame.validation (frame_9 g))
      (frame.validation (frame_10 g)))
    (game.validation.member-frames-valid g))
) :named game.validation.member-frames-valid ))

(declare-fun game.validation.sequential-frames (Game) Bool)
(assert (! (forall ((g Game))
  (=
    (and
      (=> (frame.incomplete-regular-throws (frame_1 g)) (= empty-frame (frame_2 g)))
      (=> (frame.incomplete-regular-throws (frame_2 g)) (= empty-frame (frame_3 g)))
      (=> (frame.incomplete-regular-throws (frame_3 g)) (= empty-frame (frame_4 g)))
      (=> (frame.incomplete-regular-throws (frame_4 g)) (= empty-frame (frame_5 g)))
      (=> (frame.incomplete-regular-throws (frame_5 g)) (= empty-frame (frame_6 g)))
      (=> (frame.incomplete-regular-throws (frame_6 g)) (= empty-frame (frame_7 g)))
      (=> (frame.incomplete-regular-throws (frame_7 g)) (= empty-frame (frame_8 g)))
      (=> (frame.incomplete-regular-throws (frame_8 g)) (= empty-frame (frame_9 g)))
      (=> (frame.incomplete-regular-throws (frame_9 g)) (= empty-frame (frame_10 g))))
    (game.validation.sequential-frames g))
) :named game.validation.sequental-frames ))

(declare-fun game.validation.mark-frames-first-bonus-consistency-with-next-throw (Game) Bool)
(assert (! (forall ((g Game))
  (=
    (and
      (=>
        (or (strike (frame_1 g)) (spare (frame_1 g)))
        (= (bonus_1 (frame_1 g)) (throw_1 (frame_2 g))))
      (=>
        (or (strike (frame_2 g)) (spare (frame_2 g)))
        (= (bonus_1 (frame_2 g)) (throw_1 (frame_3 g))))
      (=>
        (or (strike (frame_3 g)) (spare (frame_3 g)))
        (= (bonus_1 (frame_3 g)) (throw_1 (frame_4 g))))
      (=>
        (or (strike (frame_4 g)) (spare (frame_4 g)))
        (= (bonus_1 (frame_4 g)) (throw_1 (frame_5 g))))
      (=>
        (or (strike (frame_5 g)) (spare (frame_5 g)))
        (= (bonus_1 (frame_5 g)) (throw_1 (frame_6 g))))
      (=>
        (or (strike (frame_6 g)) (spare (frame_6 g)))
        (= (bonus_1 (frame_6 g)) (throw_1 (frame_7 g))))
      (=>
        (or (strike (frame_7 g)) (spare (frame_7 g)))
        (= (bonus_1 (frame_7 g)) (throw_1 (frame_8 g))))
      (=>
        (or (strike (frame_8 g)) (spare (frame_8 g)))
        (= (bonus_1 (frame_8 g)) (throw_1 (frame_9 g))))
      (=>
        (or (strike (frame_9 g)) (spare (frame_9 g)))
        (= (bonus_1 (frame_9 g)) (throw_1 (frame_10 g)))))
    (game.validation.mark-frames-first-bonus-consistency-with-next-throw g))
) :named game.validation.mark-frames-first-bonus-consistency-with-next-throw ))

(declare-fun game.validation.strike-then-not-strike-bonus-2-consistency (Game) Bool)
(assert (! (forall ((g Game))
  (=
    (and
      (=> (strike (frame_1 g)) (not (strike (frame_2 g)))  (= (bonus_2 (frame_1 g)) (throw_2 (frame_2 g))))
      (=> (strike (frame_2 g)) (not (strike (frame_3 g)))  (= (bonus_2 (frame_2 g)) (throw_2 (frame_3 g))))
      (=> (strike (frame_3 g)) (not (strike (frame_4 g)))  (= (bonus_2 (frame_3 g)) (throw_2 (frame_4 g))))
      (=> (strike (frame_4 g)) (not (strike (frame_5 g)))  (= (bonus_2 (frame_4 g)) (throw_2 (frame_5 g))))
      (=> (strike (frame_5 g)) (not (strike (frame_6 g)))  (= (bonus_2 (frame_5 g)) (throw_2 (frame_6 g))))
      (=> (strike (frame_6 g)) (not (strike (frame_7 g)))  (= (bonus_2 (frame_6 g)) (throw_2 (frame_7 g))))
      (=> (strike (frame_7 g)) (not (strike (frame_8 g)))  (= (bonus_2 (frame_7 g)) (throw_2 (frame_8 g))))
      (=> (strike (frame_8 g)) (not (strike (frame_9 g)))  (= (bonus_2 (frame_8 g)) (throw_2 (frame_9 g))))
      (=> (strike (frame_9 g)) (not (strike (frame_10 g))) (= (bonus_2 (frame_9 g)) (throw_2 (frame_10 g)))))
    (game.validation.strike-then-not-strike-bonus-2-consistency g))
) :named game.validation.strike-then-not-strike-bonus-2-consistency ))

(declare-fun game.validation.strike-then-strike-bonus-2-consistency (Game) Bool)
(assert (! (forall ((g Game))
  (=
    (and
      (=> (strike (frame_1 g)) (strike (frame_2 g))  (= (bonus_2 (frame_1 g)) (bonus_1 (frame_2 g))))
      (=> (strike (frame_2 g)) (strike (frame_3 g))  (= (bonus_2 (frame_2 g)) (bonus_1 (frame_3 g))))
      (=> (strike (frame_3 g)) (strike (frame_4 g))  (= (bonus_2 (frame_3 g)) (bonus_1 (frame_4 g))))
      (=> (strike (frame_4 g)) (strike (frame_5 g))  (= (bonus_2 (frame_4 g)) (bonus_1 (frame_5 g))))
      (=> (strike (frame_5 g)) (strike (frame_6 g))  (= (bonus_2 (frame_5 g)) (bonus_1 (frame_6 g))))
      (=> (strike (frame_6 g)) (strike (frame_7 g))  (= (bonus_2 (frame_6 g)) (bonus_1 (frame_7 g))))
      (=> (strike (frame_7 g)) (strike (frame_8 g))  (= (bonus_2 (frame_7 g)) (bonus_1 (frame_8 g))))
      (=> (strike (frame_8 g)) (strike (frame_9 g))  (= (bonus_2 (frame_8 g)) (bonus_1 (frame_9 g))))
      (=> (strike (frame_9 g)) (strike (frame_10 g)) (= (bonus_2 (frame_9 g)) (bonus_1 (frame_10 g)))))
    (game.validation.strike-then-strike-bonus-2-consistency g))
) :named game.validation.strike-then-strike-bonus-2-consistency ))

(declare-fun game.validation.completion-consistent-with-frame-10 (Game) Bool)
(assert (! (forall ((g Game))
  (=
    (= (incomplete g) (incomplete (frame_10 g)))
    (game.validation.completion-consistent-with-frame-10 g))
) :named game.validation.completion-consistent-with-frame-10 ))

(declare-fun game.validation.score-consistent-with-frames-point-total (Game) Bool)
(assert (! (forall ((g Game))
  (=
    (=
      (score g)
      (+
        (points (frame_1 g))
        (points (frame_2 g))
        (points (frame_3 g))
        (points (frame_4 g))
        (points (frame_5 g))
        (points (frame_6 g))
        (points (frame_7 g))
        (points (frame_8 g))
        (points (frame_9 g))
        (points (frame_10 g))))
    (game.validation.score-consistent-with-frames-point-total g))
) :named game.validation.score-consistent-with-frames-point-total ))

(define-fun game.validation ((g Game)) Bool
  (and
    (game.validation.member-frames-valid g)
    (game.validation.sequential-frames g)
    (game.validation.mark-frames-first-bonus-consistency-with-next-throw g)
    (game.validation.strike-then-not-strike-bonus-2-consistency g)
    (game.validation.strike-then-strike-bonus-2-consistency g)
    (game.validation.completion-consistent-with-frame-10 g)
    (game.validation.score-consistent-with-frames-point-total g))
)

#endif


