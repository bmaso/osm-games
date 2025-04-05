#ifndef BACKGAMMON_DOMAIN_COLOR
#define BACKGAMMON_DOMAIN_COLOR

; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; The two players are represented by the "colots" `Red` and `Black`. The special color `Neutral`
;; is used as a "no color" option in some parts of the domain model -- specifically when a `Point`
;; or a `Bar` has no peices on it.

(declare-datatype Color (
  Red
  Black
  Neutral
))

;;;;
;; convenience function `color.opponent-of`: equals `Red` for `Black` and vice versa, and `Neutral` for `Neutral`

(define-fun color.opponent-of ((c Color)) Color
  (ite
    (= c Red) Black
    (ite
      (= c Black) Red
      Neutral))
)

#endif