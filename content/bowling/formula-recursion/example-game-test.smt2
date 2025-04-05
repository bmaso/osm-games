#include "bowling.smt2"

;;;;
;; The one and only sample game provided by the USBC.
;;
;; This test pretty much proves that recursion and SMT just don't work nicely together.
;;
(define-const ten-frames-empty (List Frame)
  (insert empty-frame
    (insert empty-frame
      (insert empty-frame
        (insert empty-frame
          (insert empty-frame
            (insert empty-frame
              (insert empty-frame
                (insert empty-frame
                  (insert empty-frame
                    (insert empty-frame nil))))))))))
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

;;;;
;; verify the frames look like and are scored like we expect,
;; frame-by-frame
(define-const frame1 Frame (head example-game))
(assert (= (count (frame.score frame1)) 30))

(define-const frame2 Frame (head (tail example-game)))
(assert (= (count (frame.score frame2)) 27))

(define-const frame3 Frame (head (tail (tail example-game))))
(assert (= (count (frame.score frame3)) 19))

(define-const frame4 Frame (head (tail (tail (tail example-game)))))
(assert (= (count (frame.score frame4)) 9))

(define-const frame5 Frame (head (tail (tail (tail (tail example-game))))))
(assert (= (count (frame.score frame5)) 10))

(check-sat)



