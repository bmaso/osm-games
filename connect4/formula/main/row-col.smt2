#import "maybe.smt2"

#ifndef CONNECTFOUR_ROWCOL_DOMAIN
#define CONNECTFOUR_ROWCOL_DOMAIN

;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; Rows and columns are a restricted set of values -- only the values necessary to represent a 6x7 board.
;; 
;; The 6 row values have an optional `above` relationships to other rows.
;;
;; The finitely-valued datatypes `RowId` and `ColId` are used to identify rows and columns. Row and column
;; identifiers are finitely-numbered types, which solvers will use to perform exhaustive case analysis
;; very efficiently. The product type `Coordinate` has members of type `RowId` and `ColId`, making the
;; `Coordinate type alfo finite with 6x7=42 different members.
;;
;; There is an urge to use integer or natural numbers as row and column identifiers, because integers are ordered --
;; "left" and "right" or "above" and "below" naturally map to natural number successor and predecessor relationships.
;; However, integers are also infinite, so exhaustive case analysis is not possible. Range quantifiers can express restrictions
;; on a _finite range_ of integer values, but they cannot be used to express usable restrictions on unbounded ranges.
;; 
;; That is, in a game of Connect Four that uses integers to identify rows and columns it is very difficult
;; to declare that a valid game `Board` _cannot_ have a marker of either color in column 15,865,422 (or any
;; column outside the finite range 1-7). But if you use a `ColId` type that only has 7 members, then there can only
;; be 7 unique columns in a `Board`.

(declare-datatype RowId (
  (row_a)
  (row_b)
  (row_c)
  (row_d)
  (row_e)
  (row_f)
))

(declare-datatype ColId (
  (col_1)
  (col_2)
  (col_3)
  (col_4)
  (col_5)
  (col_6)
  (col_7)
))

(declare-datatype Coordinate (
  (coord
    (rowid RowId)
    (colid ColId))))

(define-fun above ((rowid RowId)) (Maybe RowId)
  (ite (= rowid row_f) (some row_e)
    (ite (= rowid row_e) (some row_d)
      (ite (= rowid row_d) (some row_c)
        (ite (= rowid row_c) (some row_b)
          (ite (= rowid row_b) (some row_a) none))))))

#endif

