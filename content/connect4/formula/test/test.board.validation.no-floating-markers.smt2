#import "board.smt2"

;;;;;;;;;;
;; Proves that there are no valid boards with a neutral position below a non-neutral one according to the
;; `board.validation.no-floating-pieces` validation function.

(declare-const sut Board)

(assert (not (exists ((above_rowid RowId) (below_rowid RowId) (colid ColId))
  (and
    (= (some below_rowid) (below (select row_by_id above_rowid)))
    (= neutral (select (table sut) (coord below_rowid colid)))
    (not (= neutral (select (table sut) (coord above_rowid colid))))
    (board.validation.no-floating-markers sut)))))

(check-sat)

;;
;; positive example proving there does exist a non-empty board which does pass this test

(declare-const sut.p-ex Board)

(assert
  (exists ((rowid RowId) (colid ColId))
    (and
      (board.validation.no-floating-markers sut.p-ex)
      (not (= neutral (select (table sut.p-ex) (coord rowid colid)))))))

(check-sat)
