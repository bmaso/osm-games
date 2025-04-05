#include "winning.smt2"

;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; proves that the function that determines winners works as intended

(declare-const t (Array Coordinate Color))
(assert (forall ((coord Coordinate))
  (= red (select t coord))))

(assert (forall ((coord Coordinate))
  (=
    (or
      (= (colid coord) col_1)
      (= (colid coord) col_2)
      (= (colid coord) col_3)
      (= (colid coord) col_4))
    (table.verify-winning t coord horizontal red))))

(assert (forall ((coord Coordinate))
  (=
    (or
      (= (rowid coord) row_f)
      (= (rowid coord) row_e)
      (= (rowid coord) row_d))
    (table.verify-winning t coord vertical red))))

(assert (forall ((coord Coordinate))
  (=
    (and
      (or
        (= (colid coord) col_4)
        (= (colid coord) col_5)
        (= (colid coord) col_6)
        (= (colid coord) col_7))
      (or
        (= (rowid coord) row_f)
        (= (rowid coord) row_e)
        (= (rowid coord) row_d)))
    (table.verify-winning t coord down-left-diagonal red))))

(assert (forall ((coord Coordinate))
  (=
    (and
      (or
        (= (colid coord) col_1)
        (= (colid coord) col_2)
        (= (colid coord) col_3)
        (= (colid coord) col_4))
      (or
        (= (rowid coord) row_f)
        (= (rowid coord) row_e)
        (= (rowid coord) row_d)))
    (table.verify-winning t coord down-right-diagonal red))))

(check-sat)