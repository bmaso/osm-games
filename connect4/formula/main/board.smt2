#include "maybe.smt2"
#include "row-col.smt2"
#include "color.smt2"

#ifndef CONNECTFOUR_BOARD_DOMAIN
#define CONNECTFOUR_BOARD_DOMAIN

;; || __FILE_ || __LINE__ ||

;;;;;;;;;;
;; A `Board` is comprised of:
;; * _an array of `Coordinate` -> `Color`, termed the `table`_. Since `RowId` and `ColId` are finite types, then the product type `Coordinate`
;;   is also finite. The finite `table` array associates a marker color, or `Neutral`, with each table position.
;; * _a `current_player` value of type `Color`_. This value is toggled each player turn.
;; * _a `winner` value, also of type `Color`_. This value is `Neutral` until a winner is declared.
;;
;; A `Board` is valid so long as:
;; * in each column of the table, there are no `Neutral` coordinates below non-`Neutral` positions. This reflects the way markers are "dropped"
;;   into columns in Connect Four. A `Neutral` position below a non-`Neutral` one would mean a marker is "floating" in the air. Encoded in
;;   validation function `board.validation.no-floating-pieces`.
;; * IF the `current_player` is `Neutral`, THEN there are no non-`Neutral` positions in the array. Encoded in the validation function
;;   `board.validation.board-empty-before-first-turn`.
;; * it is completely valid for a `Board` to have no winner even if there are 4 markers of the same color in a horizontal, verical, or
;;   diagonal sequence; a winner must be _declared_, which is a game operation. (I recall playing Connect Four games with my brother
;;   where neither of us realized someone had already achieved 4-in-a-row several turns ago!). The universal restriction on `winner`
;;   is that IF there is a winner, THEN there must be a horizontal, vertical, or diagonal sequence of 4 markers that are the same color
;;   as the winner. Encoded in validation function `board.validation.winner-consistent-with-table-markers`.

(declare-datatype Board (
  (board
    (table (Array Coordinate Color))
    (current_player Color)
    (winner Color))))

;;;;
;; The empty board: all table positions as `neutral`, as are the `current_player` and `winner` values.

(define-const board.empty Board
  (board
    (as const (Aray Coordinate Color) neutral)  ;; table
    neutral                                     ;; current_player
    neutral))                                   ;; winner

;;;;
;; board validation rule: there are no `neutral` table positions below non-`neutral` ones

(define-fun board.validation.no-floating-markers ((b Board)) Bool
  (not (exists ((rowid RowId) (colid ColId))
    (and
      (= neutral (select (table b) (coord rowid colid)))
      (match (above (select row_by_id rowid)) (
        ((some above_rowid)
          (not (= neutral (select (table b) (coord above_rowid colid)))))
        (none false)))))))

;;;;
;; board validation rule: IF the `current_player` is `neutral`, THEN all positions in the board table are also `neutral`

(define-fun board.validation.board-empty-before-first-turn ((b Board)) Bool
  (=>
    (= neutral (current_player b))
    (forall ((rowid RowId) (colid ColId))
      (= neutral (select (table b) (coord rowid colid))))))

;;;;
;; board validation rules: IF there is a winner color, THEN there must exist a known winning `Quad` of coordinates on the board that are all
;; the winner's color.

(define-fun board.validation.winner-consistent-with-table-markers ((b Board)) Bool
  (=>
    (not (= neutral (winner b)))
    (exists ((c Coordinate) (dir Direction))
      (table.verify-winner (table b) c dir (winner b)))))

;;;;
;; All the baord validation rules together in a single conjunction

(define-fun board.validation ((b Board) Bool
  (and
    (board.validation.no-floating-markers b)
    (board.validation.board-empty-before-first-turn b)
    (board.validation.winner-consistent-with-table-markers b))))

#endif
