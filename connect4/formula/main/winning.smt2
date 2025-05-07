#include "row-col.smt2"
#include "color.smt2"

#ifndef CONNECTFOUR_WINNING_DOMAIN
#define CONNECTFOUR_WINNING_DOMAIN

;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; Encoding the winning conditions. The simplest way is to store all possible winning quad-coordinate tuples in arrays, indexed
;; on the upper-right-most coordinate in the quad. A verification function `table.verify-winning` is `true` when 4 either horizontal,
;; vertical or diagonal positions relative to a given "root" position are all the same color.
;; 
;; In traditional programming we would define a for-comprehension that explicitly examines all 4 positions extending from a root position
;; in some direction. Of course smtlib2 does not have for-comprehensions, only universal quantifiers over finite ranges or finitely-valued
;; types. Using arrays to store computed values greatly simplifies the SMT solver's job when the array index type is finitely-valued.
;;
;; (One could use a pre-processor macro library, such as Metalang99, to generate these computed values.)

(declare-datatype Direction (
  horizontal
  vertical
  down-left-diagonal
  down-right-diagonal))

(declare-datatype Quad (
  (quad
    (p1 Coordinate)
    (p2 Coordinate)
    (p3 Coordinate)
    (p4 Coordinate))))

(define-const winning-horizontal-seqs (Array Coordinate (Maybe Quad))
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
    ((as const (Array Coordinate (Maybe Quad))) none)
    (coord row_a col_1) (some (quad (coord row_a col_1) (coord row_a col_2) (coord row_a col_3) (coord row_a col_4))))
    (coord row_b col_1) (some (quad (coord row_b col_1) (coord row_b col_2) (coord row_b col_3) (coord row_b col_4))))
    (coord row_c col_1) (some (quad (coord row_c col_1) (coord row_c col_2) (coord row_c col_3) (coord row_c col_4))))
    (coord row_d col_1) (some (quad (coord row_d col_1) (coord row_d col_2) (coord row_d col_3) (coord row_d col_4))))
    (coord row_e col_1) (some (quad (coord row_e col_1) (coord row_e col_2) (coord row_e col_3) (coord row_e col_4))))
    (coord row_f col_1) (some (quad (coord row_f col_1) (coord row_f col_2) (coord row_f col_3) (coord row_f col_4))))

    (coord row_a col_2) (some (quad (coord row_a col_2) (coord row_a col_3) (coord row_a col_4) (coord row_a col_5))))
    (coord row_b col_2) (some (quad (coord row_b col_2) (coord row_b col_3) (coord row_b col_4) (coord row_b col_5))))
    (coord row_c col_2) (some (quad (coord row_c col_2) (coord row_c col_3) (coord row_c col_4) (coord row_c col_5))))
    (coord row_d col_2) (some (quad (coord row_d col_2) (coord row_d col_3) (coord row_d col_4) (coord row_d col_5))))
    (coord row_e col_2) (some (quad (coord row_e col_2) (coord row_e col_3) (coord row_e col_4) (coord row_e col_5))))
    (coord row_f col_2) (some (quad (coord row_f col_2) (coord row_f col_3) (coord row_f col_4) (coord row_f col_5))))

    (coord row_a col_3) (some (quad (coord row_a col_3) (coord row_a col_4) (coord row_a col_5) (coord row_a col_6))))
    (coord row_b col_3) (some (quad (coord row_b col_3) (coord row_b col_4) (coord row_b col_5) (coord row_b col_6))))
    (coord row_c col_3) (some (quad (coord row_c col_3) (coord row_c col_4) (coord row_c col_5) (coord row_c col_6))))
    (coord row_d col_3) (some (quad (coord row_d col_3) (coord row_d col_4) (coord row_d col_5) (coord row_d col_6))))
    (coord row_e col_3) (some (quad (coord row_e col_3) (coord row_e col_4) (coord row_e col_5) (coord row_e col_6))))
    (coord row_f col_3) (some (quad (coord row_f col_3) (coord row_f col_4) (coord row_f col_5) (coord row_f col_6))))

    (coord row_a col_4) (some (quad (coord row_a col_3) (coord row_a col_4) (coord row_a col_5) (coord row_a col_6))))
    (coord row_b col_4) (some (quad (coord row_b col_3) (coord row_b col_4) (coord row_b col_5) (coord row_b col_6))))
    (coord row_c col_4) (some (quad (coord row_c col_3) (coord row_c col_4) (coord row_c col_5) (coord row_c col_6))))
    (coord row_d col_4) (some (quad (coord row_d col_3) (coord row_d col_4) (coord row_d col_5) (coord row_d col_6))))
    (coord row_e col_4) (some (quad (coord row_e col_3) (coord row_e col_4) (coord row_e col_5) (coord row_e col_6))))
    (coord row_f col_4) (some (quad (coord row_f col_3) (coord row_f col_4) (coord row_f col_5) (coord row_f col_6)))))

(define-const winning-vertical-seqs (Array Coordinate (Maybe Quad))
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
    ((as const (Array Coordinate (Maybe Quad))) none)
    (coord row_f col_1) (some (quad (coord row_f col_1) (coord row_e col_1) (coord row_d col_1) (coord row_c col_1))))
    (coord row_f col_2) (some (quad (coord row_f col_2) (coord row_e col_2) (coord row_d col_2) (coord row_c col_2))))
    (coord row_f col_3) (some (quad (coord row_f col_3) (coord row_e col_3) (coord row_d col_3) (coord row_c col_3))))
    (coord row_f col_4) (some (quad (coord row_f col_4) (coord row_e col_4) (coord row_d col_4) (coord row_c col_4))))
    (coord row_f col_5) (some (quad (coord row_f col_5) (coord row_e col_5) (coord row_d col_5) (coord row_c col_5))))
    (coord row_f col_6) (some (quad (coord row_f col_6) (coord row_e col_6) (coord row_d col_6) (coord row_c col_6))))
    (coord row_f col_7) (some (quad (coord row_f col_7) (coord row_e col_7) (coord row_d col_7) (coord row_c col_7))))

    (coord row_e col_1) (some (quad (coord row_e col_1) (coord row_d col_1) (coord row_c col_1) (coord row_b col_1))))
    (coord row_e col_2) (some (quad (coord row_e col_2) (coord row_d col_2) (coord row_c col_2) (coord row_b col_2))))
    (coord row_e col_3) (some (quad (coord row_e col_3) (coord row_d col_3) (coord row_c col_3) (coord row_b col_3))))
    (coord row_e col_4) (some (quad (coord row_e col_4) (coord row_d col_4) (coord row_c col_4) (coord row_b col_4))))
    (coord row_e col_5) (some (quad (coord row_e col_5) (coord row_d col_5) (coord row_c col_5) (coord row_b col_5))))
    (coord row_e col_6) (some (quad (coord row_e col_6) (coord row_d col_6) (coord row_c col_6) (coord row_b col_6))))
    (coord row_e col_7) (some (quad (coord row_e col_7) (coord row_d col_7) (coord row_c col_7) (coord row_b col_7))))

    (coord row_d col_1) (some (quad (coord row_d col_1) (coord row_c col_1) (coord row_b col_1) (coord row_a col_1))))
    (coord row_d col_2) (some (quad (coord row_d col_2) (coord row_c col_2) (coord row_b col_2) (coord row_a col_2))))
    (coord row_d col_3) (some (quad (coord row_d col_3) (coord row_c col_3) (coord row_b col_3) (coord row_a col_3))))
    (coord row_d col_4) (some (quad (coord row_d col_4) (coord row_c col_4) (coord row_b col_4) (coord row_a col_4))))
    (coord row_d col_5) (some (quad (coord row_d col_5) (coord row_c col_5) (coord row_b col_5) (coord row_a col_5))))
    (coord row_d col_6) (some (quad (coord row_d col_6) (coord row_c col_6) (coord row_b col_6) (coord row_a col_6))))
    (coord row_d col_7) (some (quad (coord row_d col_7) (coord row_c col_7) (coord row_b col_7) (coord row_a col_7)))))

(define-const winning-down-right-diagonal-seqs (Array Coordinate (Maybe Quad))
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
    ((as const (Array Coordinate (Maybe Quad))) none)
    (coord row_f col_1) (some (quad (coord row_f col_1) (coord row_e col_2) (coord row_d col_3) (coord row_c col_4))))
    (coord row_f col_2) (some (quad (coord row_f col_2) (coord row_e col_3) (coord row_d col_4) (coord row_c col_5))))
    (coord row_f col_3) (some (quad (coord row_f col_3) (coord row_e col_4) (coord row_d col_5) (coord row_c col_6))))
    (coord row_f col_4) (some (quad (coord row_f col_4) (coord row_e col_5) (coord row_d col_6) (coord row_c col_7))))

    (coord row_e col_1) (some (quad (coord row_e col_1) (coord row_d col_2) (coord row_c col_3) (coord row_b col_4))))
    (coord row_e col_2) (some (quad (coord row_e col_2) (coord row_d col_3) (coord row_c col_4) (coord row_b col_5))))
    (coord row_e col_3) (some (quad (coord row_e col_3) (coord row_d col_4) (coord row_c col_5) (coord row_b col_6))))
    (coord row_e col_4) (some (quad (coord row_e col_4) (coord row_d col_5) (coord row_c col_6) (coord row_b col_7))))

    (coord row_d col_1) (some (quad (coord row_d col_1) (coord row_c col_2) (coord row_b col_3) (coord row_a col_4))))
    (coord row_d col_2) (some (quad (coord row_d col_2) (coord row_c col_3) (coord row_b col_4) (coord row_a col_5))))
    (coord row_d col_3) (some (quad (coord row_d col_3) (coord row_c col_4) (coord row_b col_5) (coord row_a col_6))))
    (coord row_d col_4) (some (quad (coord row_d col_4) (coord row_c col_5) (coord row_b col_6) (coord row_a col_7)))))

(define-const winning-down-left-diagonal-seqs (Array Coordinate (Maybe Quad))
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
    ((as const (Array Coordinate (Maybe Quad))) none)
    (coord row_f col_4) (some (quad (coord row_f col_4) (coord row_e col_3) (coord row_d col_2) (coord row_c col_1))))
    (coord row_f col_5) (some (quad (coord row_f col_5) (coord row_e col_4) (coord row_d col_3) (coord row_c col_2))))
    (coord row_f col_6) (some (quad (coord row_f col_6) (coord row_e col_5) (coord row_d col_4) (coord row_c col_3))))
    (coord row_f col_7) (some (quad (coord row_f col_7) (coord row_e col_6) (coord row_d col_5) (coord row_c col_4))))

    (coord row_e col_4) (some (quad (coord row_e col_4) (coord row_d col_3) (coord row_c col_2) (coord row_b col_1))))
    (coord row_e col_5) (some (quad (coord row_e col_5) (coord row_d col_4) (coord row_c col_3) (coord row_b col_2))))
    (coord row_e col_6) (some (quad (coord row_e col_6) (coord row_d col_5) (coord row_c col_4) (coord row_b col_3))))
    (coord row_e col_7) (some (quad (coord row_e col_7) (coord row_d col_6) (coord row_c col_5) (coord row_b col_4))))

    (coord row_d col_4) (some (quad (coord row_d col_4) (coord row_c col_3) (coord row_b col_2) (coord row_a col_1))))
    (coord row_d col_5) (some (quad (coord row_d col_5) (coord row_c col_4) (coord row_b col_3) (coord row_a col_2))))
    (coord row_d col_6) (some (quad (coord row_d col_6) (coord row_c col_5) (coord row_b col_4) (coord row_a col_3))))
    (coord row_d col_7) (some (quad (coord row_d col_7) (coord row_c col_6) (coord row_b col_5) (coord row_a col_4)))))

;;;;
;; This function verifies a winning 4-in-a-row is rooted at a particular coordinate, is in a certain direction, and matches
;; a certain color
(define-fun table.verify-winning ((t (Array Coordinate Color)) (rootCoord Coordinate) (dir Direction) (c Color)) Bool
  (match dir (
    (horizontal (match (select winning-horizontal-seqs rootCoord) (
      (none false)
      ((some q)
        (and
          (= c (select t (p1 q)))
          (= c (select t (p2 q)))
          (= c (select t (p3 q)))
          (= c (select t (p4 q))))))))
    (vertical (match (select winning-vertical-seqs rootCoord) (
      (none false)
      ((some q)
        (and
          (= c (select t (p1 q)))
          (= c (select t (p2 q)))
          (= c (select t (p3 q)))
          (= c (select t (p4 q))))))))
    (down-right-diagonal (match (select winning-down-right-diagonal-seqs rootCoord) (
      (none false)
      ((some q)
        (and
          (= c (select t (p1 q)))
          (= c (select t (p2 q)))
          (= c (select t (p3 q)))
          (= c (select t (p4 q))))))))
    (down-left-diagonal (match (select winning-down-left-diagonal-seqs rootCoord) (
      (none false)
      ((some q)
        (and
          (= c (select t (p1 q)))
          (= c (select t (p2 q)))
          (= c (select t (p3 q)))
          (= c (select t (p4 q)))))))))))

#endif
