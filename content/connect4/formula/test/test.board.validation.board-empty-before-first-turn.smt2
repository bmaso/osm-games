#import "board.smt2"

;;;;;;;;;;
;; Proves that there are no valid boards with a non-`neutral` current player and an empty table

(declare-const sut Board)

(assert (not (exists ((rowid RowId) (colid ColId))
  (and
    (not (= neutral (select (table sut) (coord rowid colid))))
    (= neutral (current_player sut))
    (board.validation.board-empty-before-first-turn sut)))))

(check-sat)

;;
;; positive example proving there is a board passes this test, so long as we remove the requirement that there
;; is a non-`neutral` position on the board

(declare-const sut.p-ex Board)

(assert
  (and
    (= neutral (current_player sut.p-ex))
    (board.validation.board-empty-before-first-turn sut.p-ex)))

(check-sat)
