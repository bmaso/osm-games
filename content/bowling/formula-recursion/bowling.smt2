;; || __FILE__ || __LINE__ ||


; Pair type

(declare-datatype Pair (par (X Y) (
  (pair (first X) (second Y))
)))

;;;;;
;; bowling datatypes, useful functions, and game scoring algorithm
;;;;;

;;
;; A Throw is one of
;; - an "incomplete" throw, meaning a throw that hasn't happened yet
;; - a "delivery", which is a count of pins knowled down and a "split" indicator
;; - a "foul" throw
;; - an "open" position, like the second throw in a strike frame
;;
(declare-datatype Throw (
  (delivery (pins Int) (split Bool))
  foul
  incomplete
  open
))

;; A strike is a well-know type of throw
(define-const strike-throw Throw
  (delivery 10 false)
)

;;
;; A score is one of
;; - a "points" value
;; ' "incomplete", meaning a score which reference throws that are incomplete
;;
(declare-datatype Score (
  (points (count Int))
  incomplete
))

;;
;; `throw.score` computes a throw's score. The result is the pins count for a
;; delivery, 0 for fouls and open throws, an incompete if the throw itself is incomplete.
;; 
(define-fun throw.score ((t Throw)) Score
  (match t (
    (foul (points 0))
    (open (points 0))
    (incomplete (as incomplete Score))
    ((delivery p s) (points p))
  ))
)

;;
;; A convenience function to tell us if a throw is incomplete or not
;;
(define-fun throw.is_incomplete ((t Throw)) Bool
  (match t (
    (incomplete true)
    (otherwise false)
  ))
)

;;
;; A frame is comprised of to normal throw positions, and two bonus throw positions. Note
;; that any throws that haven't happened yet will be incomplete, and any throws that don't
;; turn out to be necessary, such as the second throw in a strike frame, are open.
;;
(declare-datatype Frame (
  (frame (throw1 Throw) (throw2 Throw) (bonus1 Throw) (bonus2 Throw))
))

;;
;; `empty-frame` is a frame with no throws applied to it yet. All normal and bonus throw positions
;; are incomplete.
;;
(define-const empty-frame Frame
  (frame (as incomplete Throw) (as incomplete Throw) (as incomplete Throw) (as incomplete Throw))
)

;;
;; Applying a throw to a frame is the crux of the bowling algorithm. The output frame
;; is the frame state after applying the input throw to the input frame.
;;
(define-fun frame.apply-throw ((f Frame) (t Throw)) (Pair Frame Bool)
  (match (throw1 f) (
    (incomplete
      (pair
        (frame
          t
          (ite (= (pins t) 10) open (as incomplete Throw))
          (bonus1 f)
          (ite (= (pins t) 10) (as incomplete Throw) open))
        false)) ; false b/c applied throw stored in throw1, not either of the bonus fields

    (t1 (match (throw2 f) (
      (incomplete
        (pair
          (frame
            (throw1 f)
            t
            (ite (= (+ (count (throw.score (throw1 f))) (count (throw.score t))) 10)
              (as incomplete Throw)
              open)
            open)
          false)) ; false b/c applied throw stored in throw1, not either of the bonus fields

      (t2 (match (bonus1 f) (
        (incomplete
          (pair (frame (throw1 f) (throw2 f) t (bonus2 f)) true)) ; true b/c applied throw stored in bonus field

        (b1 (match (bonus2 f) (
          (incomplete
            (pair (frame (throw1 f) (throw2 f) (bonus1 f) t) true)) ; true b/c applied throw stored in bonus field

          (b2 (pair f false)) ; default option: there are no incomplete fields -- original frame and false returned
        )))
      )))
    )))
  ))
)

;;
;; A frame's score is the summation of the normal and bonus throws in the frame. If any fields are incomplete,
;; then the frame's score is incomplete. Otherwise, sum up the throw.score value of each of the frame's
;; fields to get the frame's score
;;
(define-fun frame.score ((f Frame)) Score
   (match f (
     ((frame t1 t2 b1 b2)
       (ite (or (throw.is_incomplete t1) (throw.is_incomplete t2) (throw.is_incomplete b1) (throw.is_incomplete b2))
         (as incomplete Score)
         (points (+ (count (throw.score t1)) (count (throw.score t2)) (count (throw.score b1)) (count (throw.score b2))))))
   ))
)

;;
;; A game is just a sequence of frames
;;
(declare-datatype Game (
  (game (frames (List Frame)))
))

;;
;; `empty-game` is a game with 10 empty frames.
;;
(define-const empty-game Game
  (game
    (insert empty-frame
      (insert empty-frame
        (insert empty-frame
          (insert empty-frame
            (insert empty-frame
              (insert empty-frame
                (insert empty-frame
                  (insert empty-frame
                    (insert empty-frame
                      (insert empty-frame nil))))))))))))

;;
;; Apply a throw to a frame by applying the throw to the first non-complete frame,
;; If the throw is stored in a bonus throw position, recursively apply the same throw
;; to the next frame, until the throw is applied to a throw position in a frame, then
;; stop the recursion.
;;
(define-fun-rec frame-list.apply-throw ((l (List Frame)) (t Throw)) (List Frame)
  (match l (
    ((insert hd tl) 
      (match (frame.score hd) (
        ((points p) (insert hd (frame-list.apply-throw tl t)))
        (incomplete (match (frame.apply-throw hd t) (
          ((pair new_hd flag) (ite flag
            ;; ...true bonus flag means the throw was stored in a bonus position
            ;;    => continue to apply throw to later frames...
            (insert new_hd (frame-list.apply-throw tl t))

            ;; ...false bonus flag means the throw was stored in a throw positon
            ;;    => throw is not applied to later frames...
            (insert new_hd tl)
          ))
        )))
      ))
    )

    ;; ...we have reached the end of the list of frames. There's nowhere to place this throw.
    (nil nil)
  ))
)

;;
;; `frame-list.score` computes the sum of the scores of each frame in the list. Rather than use strict recursion,
;; this method does some pattern matching to simplify the SMT prover's job.
;;
(define-fun-rec frame-list.score ((l (List Frame))) Score
  (match l (
    ((insert hd tl)
      (match (frame.score hd) (
        (incomplete (as incomplete Score))
        ((points hdc)
            (match (frame-list.score tl) (
              (incomplete (as incomplete Score))
              ((points tlc) (points (+ hdc tlc)))
            )))
      )))
    (nil (points 0))
  ))
)

(define-fun game.apply-throw ((g Game) (t Throw)) Game
  (game (frame-list.apply-throw (frames g) t))
)

(define-fun game.score ((g Game)) Score
  (frame-list.score (frames g))
)

;;
;; `frame.partial-score` sum the point values of all frames in the list which have
;; point values. All other frames are ignored.
;;
;; This is a recursive fold function, which is a really good place to employ
;; loop unrolling for Z3 (and other SMT solvers) to be able to reason more quickly
;; when matching against the value of this function. 3 levels of loop unrolling => 8x
;; fewer branches.
;;
(define-fun-rec frame-list.partial-score ((l (List Frame))) Score
  (points 0)
)

(define-fun game.partial-score ((g Game)) Score
  (frame-list.partial-score (frames g))
)

