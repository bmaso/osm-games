
#ifndef CONNECTFOUR_MAYBE_DOMAIN
#define CONNECTFOUR_MAYBE_DOMAIN

;;;;;;;;;;
;; The `Maybe` datatype, with its concrete instantiations `None` and `Just`, are used to represent
;; conditional values.
;;
;; In Conection Four it is used to represent a row's `above` and `below` references, since some
;; rows don't have a row above or below them.
;;
;; In Connection Four it is also used to represent a columns's `left` and `right` references, since
;; some columns don't have a column to the left or to the right.

(declare-datatype Maybe (par (T) (
  (none)
  (some (value T))
)))

#endif
