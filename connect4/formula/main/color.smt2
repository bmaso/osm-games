#ifndef CONNECTFOUR_COLOR_DOMAIN
#define CONNECTFOUR_COLOR_DOMAIN

;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; A position on a `Board` has one of 3 states: red, black, or neutral (unoccupied)

(declare-datatype Color (
  red
  black
  neutral
))

#endif
