;; || __FILE__ || __LINE__ ||
#include "bowling.smt2"

(push 1)

;;;;;;;;;;
;; Verification tests for frame-list.apply-throw, frame-list.score
;; and frame-list.partial-score. The following test cases ensure that
;; the same throw can appear as a bonus throw in one frame and also
;; as a normal throw in a subsequent frame. These tests target 3-frame
;; lists to ensure the correct behavior in scratch, spare and strike scenarios
;; only requires 3 frames at most.
;;;;;;;;;;

;;
;; useful constants
;;

(define-const three-frames-empty (List Frame)
  (insert empty-frame
    (insert empty-frame
      (insert empty-frame nil)))
)

(define-const eight-throw Throw (delivery 8 false))
(define-const five-throw Throw (delivery 5 false))
(define-const two-throw Throw (delivery 2 false))
(define-const one-throw Throw (delivery 1 false))

;;;;
;; one scratch throw takes first throw position in first frame. Score is incomplete, and partial score
;; is zero since there are no completed frames.
;;
(define-const one-scratch-three-frames (List Frame)
  (frame-list.apply-throw three-frames-empty eight-throw)
)

(assert (=
  one-scratch-three-frames
  (insert (frame eight-throw (as incomplete Throw) (as incomplete Throw) open)
    (insert empty-frame
      (insert empty-frame nil)))
))

(assert (= (frame-list.score one-scratch-three-frames) (as incomplete Score)))

;(assert (= (frame-list.partial-score one-scratch-three-frames) (points 0)))


;;;;
;; three scratch throws: first two take positions in first frame,
;; third one takes position in second frame. Partial score only includes first frame
;; because second and third are incomplete.
;;
(define-const three-scratch-throws-three-frames (List Frame)
  (frame-list.apply-throw
    (frame-list.apply-throw
      (frame-list.apply-throw three-frames-empty
        five-throw)
        two-throw)
        eight-throw)
)

(assert (=
  three-scratch-throws-three-frames
  (insert (frame five-throw two-throw open open)
    (insert (frame eight-throw (as incomplete Throw) (as incomplete Throw) open)
      (insert empty-frame nil)))
))

(assert (= (frame-list.score three-scratch-throws-three-frames) (as incomplete Score)))

;(assert (= (frame-list.partial-score three-scratch-throws-three-frames) (points 7)))


;;;;
;; six scratch throws: all 3 frames in the the frame list end up complete, and
;; the score and partial score are the sum of all throws
;; 

(define-const six-scratch-throws-three-frames (List Frame)
  (frame-list.apply-throw
    (frame-list.apply-throw
      (frame-list.apply-throw
        (frame-list.apply-throw
          (frame-list.apply-throw
            (frame-list.apply-throw three-frames-empty
              two-throw)
              five-throw)
              one-throw)
              five-throw)
              two-throw)
              one-throw)
)

(assert (=
  six-scratch-throws-three-frames
  (insert (frame two-throw five-throw open open)
    (insert (frame one-throw five-throw open open)
      (insert (frame two-throw one-throw open open) nil)))
))

(assert (= (frame-list.score six-scratch-throws-three-frames) (points 16)))

;(assert (= (frame-list.partial-score six-scratch-throws-three-frames) (points 16)))


;;;;
;; spare -> strike -> one scratch throw. Spare is complete and score includes 10 bonus, strike is
;; incomplete w/ one bonus value filled in. Filed frame is also incomplete.
;;

(define-const spare-strike-one-scratch-three-frames (List Frame)
  (frame-list.apply-throw
    (frame-list.apply-throw
      (frame-list.apply-throw
        (frame-list.apply-throw three-frames-empty
          eight-throw)
          two-throw)
          strike-throw)
          eight-throw)
)

(assert (=
  spare-strike-one-scratch-three-frames
  (insert (frame eight-throw two-throw strike-throw open)
    (insert (frame strike-throw open eight-throw (as incomplete Throw))
      (insert (frame eight-throw (as incomplete Throw) (as incomplete Throw) open) nil)))
))

(assert (= (frame-list.score spare-strike-one-scratch-three-frames) (as incomplete Score)))

;(assert (= (frame-list.partial-score spare-strike-one-scratch-three-frames) (points 20)))


;;;;
;; strike->strike->strike + 2 bonus throws that are also strikes -- a series of 3 "turkies". All 3
;; frames are complete and total score is 90.
;;
(define-const three-full-turkies (List Frame)
  (frame-list.apply-throw
    (frame-list.apply-throw
      (frame-list.apply-throw
        (frame-list.apply-throw
          (frame-list.apply-throw three-frames-empty
            strike-throw)
            strike-throw)
            strike-throw)
            strike-throw)
            strike-throw)
)         

(assert (=
  three-full-turkies
  (insert (frame strike-throw open strike-throw strike-throw)
    (insert (frame strike-throw open strike-throw strike-throw)
      (insert (frame strike-throw open strike-throw strike-throw) nil)))
))

(assert (= (frame-list.score three-full-turkies) (points 90)))

;(assert (= (frame-list.partial-score three-full-turkies) (points 90)))

;;;;
;; 4 frames taken from a sample game
;;
(define-const four-frames-empty (List Frame)
  (insert empty-frame
    (insert empty-frame
      (insert empty-frame
        (insert empty-frame nil))))
)

(define-const example-4-frames (List Frame)
  (frame-list.apply-throw
    (frame-list.apply-throw
      (frame-list.apply-throw
        (frame-list.apply-throw
          (frame-list.apply-throw four-frames-empty
            strike-throw)
            strike-throw)
            strike-throw)
            (delivery 7 false))
            (delivery 2 false))
)

(assert (= (frame-list.score example-4-frames) (points 85)))

;(assert (= (frame-list.partial-score example-4-frames) (points 85)))


;;;;
;; 5 complete frames and 1 incomplete frame taken from a sample game. Sixth frame includes bonus throw to complete final spare,
;; but not 2nd throw.
;;
(define-const six-frames-empty (List Frame)
  (insert empty-frame
    (insert empty-frame
      (insert empty-frame
        (insert empty-frame
          (insert empty-frame
            (insert empty-frame nil))))))
)

(define-const example-6-incomplete-frames (List Frame)
  (frame-list.apply-throw
    (frame-list.apply-throw
      (frame-list.apply-throw
        (frame-list.apply-throw
          (frame-list.apply-throw
            (frame-list.apply-throw
              (frame-list.apply-throw
                (frame-list.apply-throw six-frames-empty
                  strike-throw)
                  strike-throw)
                  strike-throw)
                  (delivery 7 false))
                  (delivery 2 false))
                  (delivery 8 true))
                  (delivery 2 false))
                  foul)
)

(assert (= (frame-list.score example-6-incomplete-frames) (as incomplete Score)))

;(assert (= (frame-list.partial-score example-6-incomplete-frames) (points 95)))


;;;;
;; The one and only sample game provided by the USBC.
;;
(define-const ten-frames-empty (List Frame)
  (insert empty-frame
    (insert empty-frame
      (insert empty-frame
        (insert empty-frame
          (insert empty-frame six-frames-empty)))))
)

(define-const example-game (List Frame)
  (frame-list.apply-throw
    (frame-list.apply-throw
      (frame-list.apply-throw
        (frame-list.apply-throw
          (frame-list.apply-throw
            (frame-list.apply-throw
              (frame-list.apply-throw
                (frame-list.apply-throw
                  (frame-list.apply-throw
                    (frame-list.apply-throw
                      (frame-list.apply-throw
                        (frame-list.apply-throw
                          (frame-list.apply-throw
                            (frame-list.apply-throw
                              (frame-list.apply-throw
                                (frame-list.apply-throw
                                  (frame-list.apply-throw ten-frames-empty
                                    strike-throw)
                                    strike-throw)
                                    strike-throw)
                                    (delivery 7 false))
                                    (delivery 2 false))
                                    (delivery 8 true))
                                    (delivery 2 false))
                                    foul)
                                    (delivery 9 false))
                                    strike-throw)
                                    (delivery 7 false))
                                    (delivery 3 false))
                                    (delivery 9 false))
                                    (delivery 0 false))
                                    strike-throw)
                                    strike-throw)
                                    (delivery 8 false))
)

(assert (= example-game
  (insert (frame strike-throw open strike-throw strike-throw)
    (insert (frame strike-throw open strike-throw (delivery 7 false))
      (insert (frame strike-throw open (delivery 7 false) (delivery 2 false))
        (insert (frame (delivery 7 false) (delivery 2 false) open open)
          (insert (frame (delivery 8 true) (delivery 2 false) foul open)
            (insert (frame foul (delivery 9 false) open open)
              (insert (frame strike-throw open (delivery 7 false) (delivery 3 false))
                (insert (frame (delivery 7 false) (delivery 3 false) (delivery 9 false) open)
                  (insert (frame (delivery 9 false) (delivery 0 false) open open)
                    (insert (frame strike-throw open strike-throw (delivery 8 false))
                      nil))))))))))
))

;(assert (= (frame-list.score example-game) (points 180)))


(check-sat)
(echo "Frame-list function tests")

(get-value (example-game))
(pop 1)
